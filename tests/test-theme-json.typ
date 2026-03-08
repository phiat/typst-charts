// test-theme-json.typ — Tests for theme-from-json

#import "../src/lib.typ": *

#set page(margin: 0.5cm)

= theme-from-json

== Minimal tokens input

#let tokens = (
  palette: ("#e63946", "#457b9d", "#2a9d8f"),
  "text-color": "#1d3557",
  "text-color-light": "#6c757d",
  "text-color-inverse": "#f1faee",
  background: "#f8f9fa",
  "border-color": "#adb5bd",
  "border-radius": 6,
)

#let t = theme-from-json(tokens)

// Verify it returns a dictionary with expected theme keys
#assert(type(t) == dictionary)
#assert("palette" in t)
#assert("text-color" in t)
#assert("text-color-light" in t)
#assert("text-color-inverse" in t)
#assert("background" in t)
#assert("border" in t)
#assert("border-radius" in t)

// Palette should be converted to colors (not raw strings)
#assert(t.palette.len() == 3)
#assert(type(t.palette.at(0)) == color)

// border-radius should be resolved to pt
#assert(t.border-radius == 6pt)

// show-grid should be true (set by theme-from-json)
#assert(t.show-grid == true)

// Default keys from default-theme should be present (merged via resolve-theme)
#assert("title-size" in t)
#assert("axis-label-size" in t)
#assert("axis-stroke" in t)
#assert("tick-count" in t)
#assert("legend-position" in t)

// Render a chart with the JSON-derived theme
#bar-chart(
  (labels: ("X", "Y", "Z"), values: (25, 40, 30)),
  title: "JSON-derived theme",
  theme: t,
)

#pagebreak()

== Minimal tokens (palette only)

#let t2 = theme-from-json((
  palette: ("#264653", "#2a9d8f", "#e9c46a", "#f4a261", "#e76f51"),
))

#assert(t2.palette.len() == 5)
// Should still have all default keys
#assert("title-size" in t2)
#assert("axis-padding-left" in t2)

#bar-chart(
  (labels: ("A", "B", "C", "D", "E"), values: (10, 20, 30, 25, 15)),
  title: "palette-only JSON theme",
  theme: t2,
)

== Empty palette falls back to default

#let t3 = theme-from-json((palette: ()))
#assert(t3.palette.len() > 0)

== Passthrough of custom keys

#let t4 = theme-from-json((
  palette: ("#000000",),
  "my-custom-key": "hello",
))
#assert("my-custom-key" in t4)
#assert(t4.at("my-custom-key") == "hello")

== Null background

#let t5 = theme-from-json((palette: ("#111111",), background: none))
#assert(t5.background == none)

[All `theme-from-json` assertions passed.]
