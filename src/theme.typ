// theme.typ - Theme system for primaviz

// Global theme state — set via with-theme(), read by chart functions
#let _primaviz-theme = state("primaviz-theme", none)

// Default theme — flat keys, no nesting
#let default-theme = (
  palette: (
    rgb("#4e79a7"),
    rgb("#f28e2b"),
    rgb("#e15759"),
    rgb("#76b7b2"),
    rgb("#59a14f"),
    rgb("#edc948"),
    rgb("#b07aa1"),
    rgb("#ff9da7"),
    rgb("#9c755f"),
    rgb("#bab0ac"),
  ),
  title-size: 11pt,
  title-weight: "bold",
  axis-label-size: 7pt,
  axis-title-size: 8pt,
  legend-size: 8pt,
  value-label-size: 8pt,
  axis-stroke: 0.5pt + black,
  axis-padding-left: 40pt,
  axis-padding-bottom: 20pt,
  axis-padding-top: 10pt,
  axis-padding-right: 10pt,
  tick-count: 5,
  number-format: "auto",
  grid-stroke: 0.5pt + luma(230),
  show-grid: false,
  legend-position: "bottom",
  legend-swatch-size: 10pt,
  legend-gap: 10pt,
  title-gap: 5pt,
  text-color: black,
  text-color-light: gray,
  text-color-inverse: white,
  background: none,
  border: none,
  border-radius: 4pt,
)

/// Merges a user's partial theme dictionary onto the default theme.
/// Custom keys not in default-theme are preserved (passthrough).
/// An optional `overrides` dictionary is applied after the user theme,
/// useful for per-chart parameter overrides (e.g., `show-grid: true`).
///
/// - user-theme (none, dictionary): Partial theme overrides; `none` returns the default theme
/// - overrides (none, dictionary): Additional per-call overrides applied last
/// -> dictionary
#let resolve-theme(user-theme, overrides: none) = {
  let result = (:)
  for (key, val) in default-theme {
    if user-theme != none and key in user-theme {
      result.insert(key, user-theme.at(key))
    } else {
      result.insert(key, val)
    }
  }
  // Passthrough: preserve custom keys not in default-theme
  if user-theme != none {
    for (key, val) in user-theme {
      if key not in result { result.insert(key, val) }
    }
  }
  if overrides != none {
    for (key, val) in overrides {
      result.insert(key, val)
    }
  }
  result
}

/// Builds a primaviz theme dictionary from a JSON tokens object.
/// Expects keys: `palette` (array of hex strings), `text-color`, `text-color-light`,
/// `text-color-inverse`, `background` (hex or null), `border-color`, `border-radius` (number in pt).
/// Unknown keys are preserved as custom passthrough keys.
///
/// - tokens (dictionary): Parsed JSON tokens object
/// -> dictionary
#let theme-from-json(tokens) = {
  let pal = tokens.at("palette", default: ()).map(c => rgb(c))
  let bg = tokens.at("background", default: none)
  let bg = if bg != none and type(bg) == str { rgb(bg) } else { none }
  let border-hex = tokens.at("border-color", default: "#ddd")
  let radius = tokens.at("border-radius", default: 4)

  let theme = (
    palette: if pal.len() > 0 { pal } else { default-theme.palette },
    text-color: if "text-color" in tokens { rgb(tokens.text-color) } else { default-theme.text-color },
    text-color-light: if "text-color-light" in tokens { rgb(tokens.at("text-color-light")) } else { default-theme.text-color-light },
    text-color-inverse: if "text-color-inverse" in tokens { rgb(tokens.at("text-color-inverse")) } else { default-theme.text-color-inverse },
    background: bg,
    border: 0.75pt + rgb(border-hex),
    axis-stroke: 0.5pt + rgb(border-hex),
    grid-stroke: 0.3pt + rgb(border-hex),
    show-grid: true,
    border-radius: radius * 1pt,
  )

  // Passthrough: preserve any extra keys from tokens
  for (key, val) in tokens {
    if key not in theme and key != "palette" and key != "border-color" and key != "border-radius" {
      theme.insert(key, val)
    }
  }

  resolve-theme(theme)
}

/// Context-aware theme resolver — reads from state when user-theme is none.
/// When user-theme is provided, it merges onto the global state (set via
/// `with-theme`) rather than replacing it, so partial overrides like
/// `theme: (show-grid: true)` inside a `with-theme` block work correctly.
/// Custom keys not in default-theme are preserved (passthrough).
/// Must be called inside a `context` block.
///
/// - user-theme (none, dictionary): Explicit theme overrides (merged onto global state)
/// - overrides (none, dictionary): Additional per-call overrides
/// -> dictionary
#let _resolve-ctx(user-theme, overrides: none) = {
  let global = _primaviz-theme.get()  // may be none
  // Merge: default ← global ← user-theme (each layer wins over the one below)
  let result = (:)
  for (key, val) in default-theme {
    let resolved = val
    if global != none and key in global { resolved = global.at(key) }
    if user-theme != none and key in user-theme { resolved = user-theme.at(key) }
    result.insert(key, resolved)
  }
  // Passthrough: preserve custom keys from global and user-theme
  for source in (global, user-theme) {
    if source != none {
      for (key, val) in source {
        if key not in result { result.insert(key, val) }
      }
    }
  }
  if overrides != none {
    for (key, val) in overrides {
      result.insert(key, val)
    }
  }
  result
}

/// Sets a default theme for all charts in `body`.
///
/// Charts inside `body` that don't pass an explicit `theme:` parameter
/// will use this theme instead of `themes.default`.
///
/// ```typst
/// #with-theme(themes.dark)[
///   #bar-chart(data)       // uses dark theme
///   #pie-chart(data2)      // uses dark theme
///   #line-chart(data3, theme: themes.minimal) // explicit override wins
/// ]
/// ```
///
/// Can also be used as a show rule for the entire document:
/// ```typst
/// #show: with-theme.with(themes.dark)
/// ```
///
/// - theme (dictionary): Theme to use as default
/// - body (content): Content whose charts inherit this theme
/// -> content
#let with-theme(theme, body) = {
  _primaviz-theme.update(theme)
  body
  _primaviz-theme.update(none)
}

/// Returns a color from the theme palette, cycling if the index exceeds palette length.
///
/// - theme (dictionary): Resolved theme dictionary
/// - index (int): Color index (wraps around via modulo)
/// -> color
#let get-color(theme, index) = {
  let pal = theme.palette
  pal.at(calc.rem(index, pal.len()))
}

// --- Named preset themes ---

// Preset themes — each is a partial override dict resolved against default-theme.
// Usage: `chart(data, theme: minimal-theme)` or `chart(data, theme: dark-theme)`

#let minimal-theme = resolve-theme((
  axis-stroke: 0.3pt + luma(150),
  grid-stroke: 0.3pt + luma(240),
  show-grid: true,
  title-size: 10pt,
  title-weight: "regular",
  border: none,
))

#let dark-theme = resolve-theme((
  background: rgb("#1a1a2e"),
  palette: (
    rgb("#00d2ff"), rgb("#ff6b6b"), rgb("#c56cf0"), rgb("#ffdd59"), rgb("#0be881"),
    rgb("#ff9f43"), rgb("#48dbfb"), rgb("#ff6348"), rgb("#1dd1a1"), rgb("#f368e0"),
  ),
  axis-stroke: 0.5pt + rgb("#cccccc"),
  grid-stroke: 0.5pt + rgb("#333355"),
  text-color: rgb("#e0e0e0"),
  text-color-light: rgb("#888899"),
  text-color-inverse: rgb("#1a1a2e"),
))

#let presentation-theme = resolve-theme((
  title-size: 14pt,
  axis-label-size: 9pt,
  axis-title-size: 10pt,
  legend-size: 10pt,
  value-label-size: 10pt,
  legend-swatch-size: 12pt,
))

#let print-theme = resolve-theme((
  palette: (
    luma(40), luma(90), luma(140), luma(180), luma(60),
    luma(110), luma(160), luma(200), luma(80), luma(130),
  ),
  show-grid: true,
  grid-stroke: 0.4pt + luma(200),
))

#let accessible-theme = resolve-theme((
  palette: (
    rgb("#E69F00"), rgb("#56B4E9"), rgb("#009E73"), rgb("#F0E442"),
    rgb("#0072B2"), rgb("#D55E00"), rgb("#CC79A7"), rgb("#000000"),
  ),
))

#let compact-theme = resolve-theme((
  title-size: 8pt,
  axis-label-size: 5pt,
  axis-title-size: 6pt,
  legend-size: 6pt,
  value-label-size: 6pt,
  legend-swatch-size: 7pt,
  legend-gap: 6pt,
  title-gap: 3pt,
  axis-padding-left: 25pt,
  axis-padding-bottom: 12pt,
  axis-padding-top: 5pt,
  axis-padding-right: 5pt,
  show-grid: true,
  grid-stroke: 0.3pt + luma(230),
  border-radius: 2pt,
))

#let themes = (
  default: default-theme,
  minimal: minimal-theme,
  dark: dark-theme,
  presentation: presentation-theme,
  print: print-theme,
  accessible: accessible-theme,
  compact: compact-theme,
)
