#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# dependencies = ["coloraide"]
# ///
"""Extract design tokens from CSS and generate primaviz theme files.

Reads CSS custom properties (oklch, hsl, rgb, hex) from :root and .dark blocks,
converts to hex, and outputs primaviz-compatible theme files (.typ and/or .json).

Usage:
    uv run scripts/extract-theme.py <css-file> [options]

Options:
    --out-dir DIR         Output directory (default: ./typst)
    --format FORMAT       Output format: typst, json, both (default: both)
    --name NAME           Theme name prefix (default: theme)
    --dark-selector SEL   CSS selector for dark mode (default: .dark)

Examples:
    uv run scripts/extract-theme.py src/index.css
    uv run scripts/extract-theme.py styles.css --out-dir out --format json
    uv run scripts/extract-theme.py globals.css --name shadcn --dark-selector '[data-theme="dark"]'

Token mapping:
    --chart-1..N          → palette (array)
    --foreground          → text-color
    --muted-foreground    → text-color-light
    --primary-foreground  → text-color-inverse
    --background          → background
    --border              → border-color
    --radius              → border-radius
"""

import argparse
import json
import colorsys
import math
import os
import re
import sys


# ── Color conversion ──────────────────────────────────────────────────────────

def parse_hex(s):
    """Parse hex color to (r, g, b) floats 0-1."""
    s = s.strip().lstrip("#")
    if len(s) == 3:
        s = s[0]*2 + s[1]*2 + s[2]*2
    if len(s) == 6:
        return (int(s[0:2], 16) / 255, int(s[2:4], 16) / 255, int(s[4:6], 16) / 255, 1.0)
    if len(s) == 8:
        return (int(s[0:2], 16) / 255, int(s[2:4], 16) / 255, int(s[4:6], 16) / 255, int(s[6:8], 16) / 255)
    return None


def to_hex(r, g, b):
    """Convert (r, g, b) floats 0-1 to hex string."""
    return "#{:02X}{:02X}{:02X}".format(
        max(0, min(255, round(r * 255))),
        max(0, min(255, round(g * 255))),
        max(0, min(255, round(b * 255))),
    )


def parse_hsl(s):
    """Parse hsl/hsla(...) to (r, g, b, a) floats."""
    m = re.match(r"hsla?\(\s*([\d.]+)\s*[\s,]\s*([\d.]+)%?\s*[\s,]\s*([\d.]+)%?(?:\s*[/,]\s*([\d.]+%?))?\s*\)", s)
    if not m:
        return None
    h = float(m.group(1)) / 360
    s_val = float(m.group(2)) / 100
    l = float(m.group(3)) / 100
    a = 1.0
    if m.group(4):
        a_str = m.group(4).strip()
        a = float(a_str.rstrip("%")) / 100 if "%" in a_str else float(a_str)
    r, g, b = colorsys.hls_to_rgb(h, l, s_val)
    return (r, g, b, a)


def parse_oklch(s):
    """Parse oklch(...) to (r, g, b, a) floats via coloraide."""
    from coloraide import Color

    m = re.match(r"oklch\(\s*([\d.]+)\s+([\d.]+)\s+([\d.]+)(?:\s*/\s*([\d.]+%?))?\s*\)", s)
    if not m:
        return None

    L = float(m.group(1))
    C = float(m.group(2))
    h = float(m.group(3))
    a = 1.0
    if m.group(4):
        a_str = m.group(4).strip()
        a = float(a_str.rstrip("%")) / 100 if "%" in a_str else float(a_str)

    c = Color("oklch", [L, C, h])
    rgb = c.convert("srgb")
    return (max(0, min(1, rgb["red"])), max(0, min(1, rgb["green"])), max(0, min(1, rgb["blue"])), a)


def color_to_hex(raw, bg_hex="#FFFFFF"):
    """Convert any CSS color value to hex, blending alpha onto background."""
    raw = raw.strip()
    rgba = None

    if raw.startswith("oklch("):
        rgba = parse_oklch(raw)
    elif raw.startswith("hsl"):
        rgba = parse_hsl(raw)
    elif raw.startswith("#"):
        rgba = parse_hex(raw)
    elif raw.startswith("rgb"):
        m = re.match(r"rgba?\(\s*([\d.]+)\s*[\s,]\s*([\d.]+)\s*[\s,]\s*([\d.]+)(?:\s*[/,]\s*([\d.]+%?))?\s*\)", raw)
        if m:
            r, g, b = float(m.group(1)) / 255, float(m.group(2)) / 255, float(m.group(3)) / 255
            a = 1.0
            if m.group(4):
                a_str = m.group(4).strip()
                a = float(a_str.rstrip("%")) / 100 if "%" in a_str else float(a_str)
            rgba = (r, g, b, a)

    if rgba is None:
        return None

    r, g, b, a = rgba

    # Alpha blend onto background
    if a < 1.0:
        bg = parse_hex(bg_hex)
        if bg:
            r = r * a + bg[0] * (1 - a)
            g = g * a + bg[1] * (1 - a)
            b = b * a + bg[2] * (1 - a)

    return to_hex(r, g, b)


# ── CSS parsing ───────────────────────────────────────────────────────────────

def extract_vars(css, selector):
    """Extract CSS custom properties from a selector block."""
    # Handle both `:root` and arbitrary selectors like `.dark`
    escaped = re.escape(selector)
    pattern = re.compile(escaped + r"\s*\{([^}]+)\}", re.DOTALL)
    m = pattern.search(css)
    if not m:
        return {}

    block = m.group(1)
    props = {}
    for line in block.split(";"):
        line = line.strip()
        match = re.match(r"--([\w-]+)\s*:\s*(.+)", line)
        if match:
            props[match.group(1)] = match.group(2).strip()
    return props


def build_tokens(props, bg_hex="#FFFFFF"):
    """Convert CSS props dict to token dict."""
    tokens = {}

    # Palette: --chart-1, --chart-2, ...
    palette = []
    i = 1
    while f"chart-{i}" in props:
        hex_val = color_to_hex(props[f"chart-{i}"], bg_hex)
        if hex_val:
            palette.append(hex_val)
        i += 1
    if palette:
        tokens["palette"] = palette

    # Semantic tokens
    mapping = {
        "foreground": "text-color",
        "muted-foreground": "text-color-light",
        "primary-foreground": "text-color-inverse",
        "background": "background",
        "border": "border-color",
    }
    for css_key, token_key in mapping.items():
        if css_key in props:
            hex_val = color_to_hex(props[css_key], bg_hex)
            if hex_val:
                tokens[token_key] = hex_val

    # Background: null if white/transparent
    if "background" in tokens:
        bg = tokens["background"]
        if bg and bg.upper() in ("#FFFFFF", "#FFF"):
            tokens["background"] = None

    # Radius — convert to pt
    if "radius" in props:
        val = props["radius"].strip()
        m = re.match(r"([\d.]+)\s*(rem|px|pt)?", val)
        if m:
            num = float(m.group(1))
            unit = m.group(2) or "px"
            if unit == "rem":
                num = num * 16 * 0.75  # rem → px → pt
            elif unit == "px":
                num = num * 0.75  # px → pt
            # pt stays as-is
            tokens["border-radius"] = round(num, 1)

    return tokens


# ── Output generators ─────────────────────────────────────────────────────────

def generate_typst(name, light, dark):
    """Generate .typ file content with primaviz theme dicts."""
    lines = [
        f"// {name}.typ — auto-generated primaviz theme from CSS tokens",
        f"// Run: python scripts/extract-theme.py <css-file>",
        "",
    ]

    for label, tokens in (("", light), ("-dark", dark)):
        dict_name = f"{name.replace('-', '_')}" + ("_dark" if label else "")
        lines.append(f"#let {dict_name} = (")

        if "palette" in tokens:
            lines.append(f"  palette: (")
            for hex_val in tokens["palette"]:
                lines.append(f'    rgb("{hex_val}"),')
            lines.append(f"  ),")

        key_map = [
            ("text-color", "text-color"),
            ("text-color-light", "text-color-light"),
            ("text-color-inverse", "text-color-inverse"),
        ]
        for token_key, theme_key in key_map:
            if token_key in tokens:
                lines.append(f'  {theme_key}: rgb("{tokens[token_key]}"),')

        if "background" in tokens:
            bg = tokens["background"]
            if bg is None:
                lines.append("  background: none,")
            else:
                lines.append('  background: rgb("{}"),'.format(bg))

        if "border-color" in tokens:
            bc = tokens["border-color"]
            lines.append('  border: 0.75pt + rgb("{}"),'.format(bc))
            lines.append('  axis-stroke: 0.5pt + rgb("{}"),'.format(bc))
            lines.append('  grid-stroke: 0.3pt + rgb("{}"),'.format(bc))

        lines.append("  show-grid: true,")

        if "border-radius" in tokens:
            r = tokens["border-radius"]
            lines.append(f"  border-radius: {r}pt,")

        lines.append(")")
        lines.append("")

    return "\n".join(lines)


def generate_json(light, dark):
    """Generate JSON token file."""
    # Convert None to JSON null
    def clean(tokens):
        return {k: v for k, v in tokens.items()}

    return json.dumps({"light": clean(light), "dark": clean(dark)}, indent=2) + "\n"


# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(
        description="Extract CSS design tokens and generate primaviz theme files.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__.split("Usage:")[0],
    )
    parser.add_argument("css_file", help="Path to CSS file with custom properties")
    parser.add_argument("--out-dir", default="./typst", help="Output directory (default: ./typst)")
    parser.add_argument("--format", choices=["typst", "json", "both"], default="both",
                        help="Output format (default: both)")
    parser.add_argument("--name", default="theme", help="Theme name prefix (default: theme)")
    parser.add_argument("--dark-selector", default=".dark",
                        help="CSS selector for dark mode (default: .dark)")

    args = parser.parse_args()

    if not os.path.isfile(args.css_file):
        print(f"Error: file not found: {args.css_file}", file=sys.stderr)
        sys.exit(1)

    css = open(args.css_file).read()

    # Extract light (root) and dark tokens
    light_props = extract_vars(css, ":root")
    dark_props = extract_vars(css, args.dark_selector)

    if not light_props:
        print("Warning: no custom properties found in :root", file=sys.stderr)

    # Determine backgrounds for alpha blending
    light_bg_hex = "#FFFFFF"
    if "background" in light_props:
        bg = color_to_hex(light_props["background"])
        if bg:
            light_bg_hex = bg

    dark_bg_hex = "#0A0A0A"
    if "background" in dark_props:
        bg = color_to_hex(dark_props["background"])
        if bg:
            dark_bg_hex = bg

    light_tokens = build_tokens(light_props, light_bg_hex)
    dark_tokens = build_tokens(dark_props, dark_bg_hex)

    # Inherit light values for keys missing in dark (e.g., radius)
    for key in ("border-radius",):
        if key not in dark_tokens and key in light_tokens:
            dark_tokens[key] = light_tokens[key]

    print(f"Found {len(light_props)} light + {len(dark_props)} dark properties")
    print(f"Palette: {len(light_tokens.get('palette', []))} light, {len(dark_tokens.get('palette', []))} dark colors")

    # Create output directory
    os.makedirs(args.out_dir, exist_ok=True)

    if args.format in ("typst", "both"):
        path = os.path.join(args.out_dir, f"{args.name}.typ")
        with open(path, "w") as f:
            f.write(generate_typst(args.name, light_tokens, dark_tokens))
        print(f"Wrote {path}")

    if args.format in ("json", "both"):
        path = os.path.join(args.out_dir, f"{args.name}.json")
        with open(path, "w") as f:
            f.write(generate_json(light_tokens, dark_tokens))
        print(f"Wrote {path}")


if __name__ == "__main__":
    main()
