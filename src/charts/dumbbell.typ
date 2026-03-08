// dumbbell.typ - Dumbbell chart (before/after or range comparison)
#import "../theme.typ": _resolve-ctx, get-color
#import "../util.typ": nonzero, nice-floor, nice-ceil
#import "../validate.typ": validate-dumbbell-data
#import "../primitives/container.typ": chart-container
#import "../primitives/legend.typ": draw-legend-auto
#import "../primitives/axes.typ": draw-y-label
#import "../primitives/layout.typ": resolve-size

/// Renders a dumbbell chart showing range or before/after comparisons.
///
/// Each category is drawn as a horizontal row with two dots (start and end
/// values) connected by a thin line. Categories appear on the Y-axis (left)
/// and values on the X-axis (bottom).
///
/// - data (dictionary): Must contain `labels`, `start-values`, `end-values`,
///   and optionally `start-label` and `end-label`.
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - dot-size (length): Radius of endpoint dots
/// - line-width (length): Stroke width of connecting lines
/// - show-values (bool): Display numeric values next to dots
/// - theme (none, dictionary): Theme overrides
/// -> content
#let dumbbell-chart(
  data,
  width: 400pt,
  height: 200pt,
  title: none,
  dot-size: 5pt,
  line-width: 1.5pt,
  show-values: false,
  theme: none,
) = context {
  layout(size => {
  let (width, height) = resolve-size(width, height, size)
  validate-dumbbell-data(data, "dumbbell-chart")
  let t = _resolve-ctx(theme)

  let labels = data.labels
  let start-values = data.start-values
  let end-values = data.end-values
  let start-label = if "start-label" in data { data.start-label } else { "Start" }
  let end-label = if "end-label" in data { data.end-label } else { "End" }
  let n = labels.len()

  // Compute global min/max across both value sets — use nice rounding for clean axes
  let all-values = start-values + end-values
  let min-val = nice-floor(calc.min(..all-values))
  let max-val = nice-ceil(calc.max(..all-values))
  let val-range = nonzero(max-val - min-val)

  // Layout constants — scale with chart dimensions; label area grows with width
  let label-margin = calc.min(100pt, calc.max(70pt, width * 0.25))
  let right-pad = calc.max(10pt, width * 0.05)
  let top-pad = calc.max(5pt, height * 0.06)
  let bottom-pad = calc.max(15pt, height * 0.15)
  let plot-left = label-margin + dot-size
  let plot-right = width - right-pad - dot-size
  let plot-width = plot-right - plot-left

  // Colors: start uses palette color 0, end uses palette color 1
  let start-color = get-color(t, 0)
  let end-color = get-color(t, 1)
  let connector-color = t.text-color-light

  // Build legend entries
  let legend-entries = (
    (name: start-label, color: start-color),
    (name: end-label, color: end-color),
  )

  let legend-content = draw-legend-auto(legend-entries, t, swatch-type: "circle")

  chart-container(width, height, title, t, extra-height: 30pt, legend: legend-content)[
    #let chart-height = height - 10pt

    #box(width: width, height: chart-height)[
      // Usable vertical space for rows
      #let usable-height = chart-height - top-pad - bottom-pad
      #let row-height = usable-height / n

      // Helper: map value to x position
      #let val-to-x(v) = {
        plot-left + (v - min-val) / val-range * plot-width
      }

      // Draw light horizontal grid lines
      #for i in range(n) {
        let y = top-pad + row-height * i + row-height / 2
        place(left + top,
          line(
            start: (plot-left, y),
            end: (plot-right, y),
            stroke: t.grid-stroke,
          )
        )
      }

      // Draw value axis line at bottom
      #place(left + top,
        line(
          start: (plot-left, chart-height - bottom-pad),
          end: (plot-right, chart-height - bottom-pad),
          stroke: t.axis-stroke,
        )
      )

      // Draw a few tick marks on the value axis
      #let tick-count = t.tick-count
      #for ti in range(tick-count + 1) {
        let frac = ti / tick-count
        let val = min-val + frac * val-range
        let x = plot-left + frac * plot-width
        // Tick mark
        place(left + top,
          line(
            start: (x, chart-height - bottom-pad),
            end: (x, chart-height - bottom-pad + 4pt),
            stroke: t.axis-stroke,
          )
        )
        // Tick label — centered on tick position
        let display-val = if val == calc.floor(val) { str(int(val)) } else { str(calc.round(val, digits: 1)) }
        place(left + top,
          dx: x - 1.5em,
          dy: chart-height - bottom-pad + 6pt,
          box(width: 3em, height: 1.5em,
            align(center + top, text(size: t.axis-label-size, fill: t.text-color)[#display-val]))
        )
      }

      // Draw each dumbbell row
      #for (i, lbl) in labels.enumerate() {
        let y = top-pad + row-height * i + row-height / 2
        let sv = start-values.at(i)
        let ev = end-values.at(i)
        let x-start = val-to-x(sv)
        let x-end = val-to-x(ev)

        // Category label on the left — right-aligned into label margin
        draw-y-label(lbl, y, label-margin, t)

        // Connecting line (muted gray)
        place(left + top,
          line(
            start: (x-start, y),
            end: (x-end, y),
            stroke: line-width + connector-color,
          )
        )

        // Start dot
        place(left + top,
          dx: x-start - dot-size,
          dy: y - dot-size,
          circle(radius: dot-size, fill: start-color, stroke: t.marker-stroke)
        )

        // End dot
        place(left + top,
          dx: x-end - dot-size,
          dy: y - dot-size,
          circle(radius: dot-size, fill: end-color, stroke: t.marker-stroke)
        )

        // Optional value labels — place on the outside of each dot
        if show-values {
          let label-gap = dot-size + 3pt
          let label-w = 20pt

          // Start value: place left of dot if room, else right
          let s-dx = if x-start - label-w - 2pt >= plot-left and sv <= ev {
            x-start - label-w - 2pt
          } else {
            x-start + label-gap
          }
          // End value: place right of dot if room, else left
          let e-dx = if ev >= sv {
            x-end + label-gap
          } else {
            if x-end - label-w - 2pt >= plot-left {
              x-end - label-w - 2pt
            } else {
              x-end + label-gap
            }
          }

          // If both labels would overlap (close values), offset vertically
          let same-side = (s-dx >= x-start and e-dx >= x-end) or (s-dx < x-start and e-dx < x-end)
          let s-dy-adj = 0pt
          let e-dy-adj = 0pt
          if calc.abs(sv - ev) <= (val-range * 0.08) {
            s-dy-adj = -0.6em
            e-dy-adj = 0.4em
          }

          place(left + top,
            dx: s-dx,
            dy: y,
            move(dy: -0.5em + s-dy-adj, text(size: t.value-label-size, fill: start-color)[#sv])
          )
          place(left + top,
            dx: e-dx,
            dy: y,
            move(dy: -0.5em + e-dy-adj, text(size: t.value-label-size, fill: end-color)[#ev])
          )
        }
      }
    ]
  ]
  })
}
