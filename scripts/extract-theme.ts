#!/usr/bin/env bun
/**
 * primaviz-theme-cli — Extract design tokens from any CSS file and generate
 * primaviz-compatible theme files (Typst and/or JSON).
 *
 * Usage:
 *   bun run scripts/extract-theme.ts <css-file> [options]
 *
 * Options:
 *   --out-dir <dir>       Output directory (default: ./typst)
 *   --format <fmt>        Output format: typst, json, both (default: both)
 *   --name <name>         Theme name prefix (default: theme)
 *   --dark-selector <s>   CSS selector for dark mode (default: .dark)
 *   --help                Print usage information
 */

import { readFileSync, writeFileSync, mkdirSync, existsSync } from "fs";
import { resolve, basename } from "path";
import { parse, formatHex, converter } from "culori";

// ─── Argument parsing ────────────────────────────────────────────────────────

interface CliOptions {
  cssFile: string;
  outDir: string;
  format: "typst" | "json" | "both";
  name: string;
  darkSelector: string;
}

function printHelp(): void {
  console.log(`
primaviz-theme-cli — Extract design tokens from CSS and generate primaviz theme files.

Usage:
  bun run scripts/extract-theme.ts <css-file> [options]

Arguments:
  <css-file>            Path to a CSS file containing design tokens (oklch, hsl, hex)

Options:
  --out-dir <dir>       Output directory (default: ./typst)
  --format <fmt>        Output format: typst, json, both (default: both)
  --name <name>         Theme name prefix (default: theme)
  --dark-selector <s>   CSS selector for dark mode (default: .dark)
  --help                Print this help message

Examples:
  bun run scripts/extract-theme.ts src/index.css
  bun run scripts/extract-theme.ts styles/globals.css --name shadcn --format typst
  bun run scripts/extract-theme.ts theme.css --out-dir output --dark-selector '[data-theme="dark"]'
`);
}

function parseArgs(argv: string[]): CliOptions | null {
  const args = argv.slice(2); // skip bun and script path

  if (args.length === 0 || args.includes("--help")) {
    printHelp();
    return null;
  }

  // First positional argument is the CSS file
  let cssFile = "";
  let outDir = "./typst";
  let format: "typst" | "json" | "both" = "both";
  let name = "theme";
  let darkSelector = ".dark";

  let i = 0;
  while (i < args.length) {
    const arg = args[i];
    if (arg === "--out-dir") {
      outDir = args[++i] || outDir;
    } else if (arg === "--format") {
      const fmt = args[++i];
      if (fmt === "typst" || fmt === "json" || fmt === "both") {
        format = fmt;
      } else {
        console.error(`Error: Invalid format "${fmt}". Must be typst, json, or both.`);
        process.exit(1);
      }
    } else if (arg === "--name") {
      name = args[++i] || name;
    } else if (arg === "--dark-selector") {
      darkSelector = args[++i] || darkSelector;
    } else if (!arg.startsWith("--")) {
      cssFile = arg;
    } else {
      console.error(`Error: Unknown option "${arg}". Use --help for usage.`);
      process.exit(1);
    }
    i++;
  }

  if (!cssFile) {
    console.error("Error: No CSS file specified. Use --help for usage.");
    process.exit(1);
  }

  return { cssFile: resolve(cssFile), outDir: resolve(outDir), format, name, darkSelector };
}

// ─── Color conversion ────────────────────────────────────────────────────────

const toRgb = converter("rgb");

/**
 * Convert any CSS color (oklch, hsl, rgb, hex) to a hex string.
 * Handles alpha by blending onto a background color.
 */
function colorToHex(raw: string, bgHex = "#FFFFFF"): string | null {
  const color = parse(raw);
  if (!color) return null;

  if (color.alpha != null && color.alpha < 1) {
    const fg = toRgb(color);
    const bg = toRgb(parse(bgHex)!);
    if (!fg || !bg) return formatHex(color);
    const a = color.alpha;
    return formatHex({
      mode: "rgb" as const,
      r: fg.r * a + bg.r * (1 - a),
      g: fg.g * a + bg.g * (1 - a),
      b: fg.b * a + bg.b * (1 - a),
    });
  }

  return formatHex(color);
}

// ─── CSS parsing ─────────────────────────────────────────────────────────────

/**
 * Extract CSS custom properties from a CSS block string.
 */
function extractVars(block: string): Record<string, string> {
  const vars: Record<string, string> = {};
  const re = /--([\w-]+):\s*(.+?);/g;
  let m;
  while ((m = re.exec(block)) !== null) {
    vars[m[1]] = m[2].trim();
  }
  return vars;
}

/**
 * Extract the contents of the :root { ... } block.
 */
function extractRootBlock(css: string): string {
  const match = css.match(/:root\s*\{([^}]+)\}/);
  return match ? match[1] : "";
}

/**
 * Extract the contents of a dark mode block by selector.
 * Handles class selectors (.dark), attribute selectors ([data-theme="dark"]),
 * and media queries (@media (prefers-color-scheme: dark)).
 */
function extractDarkBlock(css: string, selector: string): string {
  // Try the selector directly (e.g., .dark { ... })
  const escaped = selector.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  const directMatch = css.match(new RegExp(escaped + "\\s*\\{([^}]+)\\}"));
  if (directMatch) return directMatch[1];

  // Try as media query for prefers-color-scheme
  if (selector === "@media (prefers-color-scheme: dark)") {
    const mediaMatch = css.match(
      /@media\s*\(\s*prefers-color-scheme\s*:\s*dark\s*\)\s*\{[^}]*:root\s*\{([^}]+)\}/
    );
    if (mediaMatch) return mediaMatch[1];
    // Also try without :root nested inside
    const mediaMatch2 = css.match(
      /@media\s*\(\s*prefers-color-scheme\s*:\s*dark\s*\)\s*\{([^}]+)\}/
    );
    if (mediaMatch2) return mediaMatch2[1];
  }

  return "";
}

// ─── Token mapping ───────────────────────────────────────────────────────────

/**
 * Map of CSS custom property names to primaviz semantic token names.
 * The extractor looks for these properties in :root and dark blocks.
 */
const SEMANTIC_MAP: Record<string, string> = {
  foreground: "fg",
  "muted-foreground": "muted-fg",
  "primary-foreground": "primary-fg",
  background: "bg",
  border: "border-color",
  card: "card-bg",
  "card-foreground": "card-fg",
  primary: "primary",
  "primary-foreground": "primary-fg",
  secondary: "secondary",
  "secondary-foreground": "secondary-fg",
  muted: "muted-bg",
  accent: "accent",
  "accent-foreground": "accent-fg",
  destructive: "destructive",
  input: "input-border",
  ring: "ring",
};

/**
 * Detect chart color custom properties (--chart-1, --chart-2, etc.).
 * Returns sorted array of [index, cssPropertyName].
 */
function findChartProperties(vars: Record<string, string>): Array<[number, string]> {
  const charts: Array<[number, string]> = [];
  for (const key of Object.keys(vars)) {
    const m = key.match(/^chart-(\d+)$/);
    if (m) {
      charts.push([parseInt(m[1], 10), key]);
    }
  }
  return charts.sort((a, b) => a[0] - b[0]);
}

// ─── Theme extraction ────────────────────────────────────────────────────────

interface ThemeTokens {
  palette: string[];
  "text-color": string;
  "text-color-light": string;
  "text-color-inverse": string;
  background: string | null;
  "border-color": string;
  "border-radius": number;
  /** All extracted semantic colors for reference */
  all: Record<string, string>;
}

function extractThemeTokens(
  vars: Record<string, string>,
  bgHex: string,
  isDark: boolean
): ThemeTokens {
  // Convert all semantic tokens
  const converted: Record<string, string> = {};
  for (const [cssProp, tokenName] of Object.entries(SEMANTIC_MAP)) {
    const raw = vars[cssProp];
    if (!raw) continue;
    const hex = colorToHex(raw, bgHex);
    if (hex) converted[tokenName] = hex.toUpperCase();
  }

  // Convert chart colors
  const chartProps = findChartProperties(vars);
  const palette: string[] = [];
  for (const [, cssProp] of chartProps) {
    const raw = vars[cssProp];
    if (!raw) continue;
    const hex = colorToHex(raw, bgHex);
    if (hex) palette.push(hex.toUpperCase());
  }

  // Extract radius
  const radiusRaw = vars["radius"];
  let radiusPt = 8; // default
  if (radiusRaw) {
    const rem = parseFloat(radiusRaw);
    if (!isNaN(rem)) {
      radiusPt = Math.round(rem * 12); // approximate rem to pt
    }
  }

  return {
    palette,
    "text-color": converted["fg"] || (isDark ? "#FAFAFA" : "#0A0A0A"),
    "text-color-light": converted["muted-fg"] || (isDark ? "#8888AA" : "#888888"),
    "text-color-inverse": converted["primary-fg"] || "#FAFAFA",
    background: isDark ? (converted["bg"] || "#0A0A0A") : null,
    "border-color": converted["border-color"] || (isDark ? "#2A2A3E" : "#E2E2EE"),
    "border-radius": radiusPt,
    all: converted,
  };
}

// ─── Output generation ───────────────────────────────────────────────────────

function generateTypst(
  light: ThemeTokens,
  dark: ThemeTokens,
  themeName: string
): string {
  const lines: string[] = [
    `// Auto-generated primaviz theme — do not edit by hand`,
    `// Generated by primaviz-theme-cli`,
    "",
  ];

  // Light theme
  const varName = themeName.replace(/[^a-zA-Z0-9-]/g, "-");
  lines.push(`#let ${varName} = (`);
  lines.push(`  palette: (`);
  for (let i = 0; i < light.palette.length; i++) {
    lines.push(`    rgb("${light.palette[i]}"),  // --chart-${i + 1}`);
  }
  lines.push(`  ),`);
  lines.push(`  text-color: rgb("${light["text-color"]}"),`);
  lines.push(`  text-color-light: rgb("${light["text-color-light"]}"),`);
  lines.push(`  text-color-inverse: rgb("${light["text-color-inverse"]}"),`);
  lines.push(`  background: none,`);
  lines.push(`  border: 0.75pt + rgb("${light["border-color"]}"),`);
  lines.push(`  axis-stroke: 0.5pt + rgb("${light["border-color"]}"),`);
  lines.push(`  grid-stroke: 0.3pt + rgb("${light["border-color"]}"),`);
  lines.push(`  show-grid: true,`);
  lines.push(`  border-radius: ${light["border-radius"]}pt,`);
  lines.push(`)`);
  lines.push("");

  // Dark theme
  lines.push(`// Dark mode variant`);
  lines.push(`#let ${varName}-dark = (`);
  lines.push(`  palette: (`);
  for (let i = 0; i < dark.palette.length; i++) {
    lines.push(`    rgb("${dark.palette[i]}"),  // --chart-${i + 1}`);
  }
  lines.push(`  ),`);
  lines.push(`  text-color: rgb("${dark["text-color"]}"),`);
  lines.push(`  text-color-light: rgb("${dark["text-color-light"]}"),`);
  lines.push(`  text-color-inverse: rgb("${dark["text-color-inverse"]}"),`);
  lines.push(`  background: rgb("${dark.background || "#0A0A0A"}"),`);
  lines.push(`  border: 0.75pt + rgb("${dark["border-color"]}"),`);
  lines.push(`  axis-stroke: 0.5pt + rgb("${dark["border-color"]}"),`);
  lines.push(`  grid-stroke: 0.3pt + rgb("${dark["border-color"]}"),`);
  lines.push(`  show-grid: true,`);
  lines.push(`  border-radius: ${dark["border-radius"]}pt,`);
  lines.push(`)`);
  lines.push("");

  return lines.join("\n");
}

function generateJson(light: ThemeTokens, dark: ThemeTokens): string {
  const output = {
    light: {
      palette: light.palette,
      "text-color": light["text-color"],
      "text-color-light": light["text-color-light"],
      "text-color-inverse": light["text-color-inverse"],
      background: light.background,
      "border-color": light["border-color"],
      "border-radius": light["border-radius"],
    },
    dark: {
      palette: dark.palette,
      "text-color": dark["text-color"],
      "text-color-light": dark["text-color-light"],
      "text-color-inverse": dark["text-color-inverse"],
      background: dark.background,
      "border-color": dark["border-color"],
      "border-radius": dark["border-radius"],
    },
  };
  return JSON.stringify(output, null, 2) + "\n";
}

// ─── Main ────────────────────────────────────────────────────────────────────

function main(): void {
  const opts = parseArgs(process.argv);
  if (!opts) process.exit(0);

  // Read CSS file
  if (!existsSync(opts.cssFile)) {
    console.error(`Error: CSS file not found: ${opts.cssFile}`);
    process.exit(1);
  }
  const css = readFileSync(opts.cssFile, "utf-8");
  console.log(`Reading tokens from ${opts.cssFile}`);

  // Extract light mode variables from :root
  const rootBlock = extractRootBlock(css);
  const rootVars = extractVars(rootBlock);
  const rootVarCount = Object.keys(rootVars).length;

  if (rootVarCount === 0) {
    console.warn("Warning: No custom properties found in :root block.");
  } else {
    console.log(`Found ${rootVarCount} custom properties in :root`);
  }

  // Determine light background for alpha blending
  const lightBgRaw = rootVars["background"] || "#FFFFFF";
  const lightBgHex = colorToHex(lightBgRaw) || "#FFFFFF";

  // Extract light mode tokens
  const lightTokens = extractThemeTokens(rootVars, lightBgHex, false);

  // Extract dark mode variables
  const darkBlock = extractDarkBlock(css, opts.darkSelector);
  const darkVars = extractVars(darkBlock);
  const darkVarCount = Object.keys(darkVars).length;

  if (darkVarCount === 0) {
    console.warn(
      `Warning: No custom properties found for dark selector "${opts.darkSelector}".`
    );
    console.warn("Dark theme will use fallback values.");
  } else {
    console.log(
      `Found ${darkVarCount} custom properties in "${opts.darkSelector}"`
    );
  }

  // Determine dark background for alpha blending
  const darkBgRaw = darkVars["background"] || "oklch(0.145 0 0)";
  const darkBgHex = colorToHex(darkBgRaw) || "#0A0A0A";

  // Extract dark mode tokens
  const darkTokens = extractThemeTokens(darkVars, darkBgHex, true);

  // Ensure output directory exists
  if (!existsSync(opts.outDir)) {
    mkdirSync(opts.outDir, { recursive: true });
    console.log(`Created output directory: ${opts.outDir}`);
  }

  // Write output files
  if (opts.format === "typst" || opts.format === "both") {
    const typstPath = resolve(opts.outDir, `${opts.name}.typ`);
    const typstContent = generateTypst(lightTokens, darkTokens, opts.name);
    writeFileSync(typstPath, typstContent);
    console.log(
      `Wrote Typst theme (${lightTokens.palette.length} light + ${darkTokens.palette.length} dark palette colors) to ${typstPath}`
    );
  }

  if (opts.format === "json" || opts.format === "both") {
    const jsonPath = resolve(opts.outDir, `${opts.name}.json`);
    const jsonContent = generateJson(lightTokens, darkTokens);
    writeFileSync(jsonPath, jsonContent);
    console.log(`Wrote JSON tokens (light + dark) to ${jsonPath}`);
  }

  console.log("Done.");
}

main();
