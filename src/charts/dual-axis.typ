// dual-axis.typ - Dual Y-axis line chart
#import "../theme.typ": resolve-theme, get-color
#import "../validate.typ": validate-dual-axis-data
#import "../primitives/container.typ": chart-container
#import "../primitives/axes.typ": draw-grid, draw-axis-titles
#import "../primitives/legend.typ": draw-legend-auto
#import "../util.typ": format-number

#let dual-axis-chart(
  data,
  width: 400pt,
  height: 250pt,
  title: none,
  show-points: true,
  left-color: none,
  right-color: none,
  left-label: none,
  right-label: none,
  x-label: none,
  show-grid: auto,
  theme: none,
) = {
  validate-dual-axis-data(data, "dual-axis-chart")
  let merged = if theme == none { (:) } else { theme }
  if show-grid != auto {
    merged.insert("show-grid", show-grid)
  }
  let t = resolve-theme(merged)

  let labels = data.labels
  let left-series = data.left
  let right-series = data.right
  let n = labels.len()

  // Resolve colors
  let l-color = if left-color != none { left-color } else { get-color(t, 0) }
  let r-color = if right-color != none { right-color } else { get-color(t, 1) }

  // Compute left axis range
  let l-min = calc.min(..left-series.values)
  let l-max = calc.max(..left-series.values)
  let l-range = l-max - l-min
  if l-range == 0 { l-range = 1 }

  // Compute right axis range
  let r-min = calc.min(..right-series.values)
  let r-max = calc.max(..right-series.values)
  let r-range = r-max - r-min
  if r-range == 0 { r-range = 1 }

  let pad-left = t.axis-padding-left + 10pt
  let pad-right = t.axis-padding-left + 10pt  // same padding for right axis labels
  let pad-top = t.axis-padding-top
  let pad-bottom = t.axis-padding-bottom

  chart-container(width, height, title, t, extra-height: 50pt)[
    #let chart-height = height - pad-top - pad-bottom
    #let chart-width = width - pad-left - pad-right
    #let origin-x = pad-left
    #let origin-y = pad-top + chart-height

    #box(width: width, height: height)[
      // Grid lines (based on left axis scale)
      #draw-grid(origin-x, pad-top, chart-width, chart-height, t)

      // Left Y-axis line
      #place(left + top, line(start: (origin-x, pad-top), end: (origin-x, origin-y), stroke: t.axis-stroke))
      // Right Y-axis line
      #place(left + top, line(start: (origin-x + chart-width, pad-top), end: (origin-x + chart-width, origin-y), stroke: t.axis-stroke))
      // X-axis line
      #place(left + top, line(start: (origin-x, origin-y), end: (origin-x + chart-width, origin-y), stroke: t.axis-stroke))

      // Left Y-axis ticks — right-aligned into left padding
      #for i in array.range(t.tick-count) {
        let fraction = if t.tick-count > 1 { i / (t.tick-count - 1) } else { 0 }
        let y-val = l-min + l-range * fraction
        let y = pad-top + chart-height - fraction * chart-height
        place(left + top, dx: 0pt, dy: y,
          box(width: origin-x - 2pt, height: 0pt,
            align(right, move(dy: -0.5em,
              text(size: t.axis-label-size, fill: l-color)[#format-number(y-val, digits: 1, mode: t.number-format)])))
        )
      }

      // Right Y-axis ticks — left-aligned after right axis
      #for i in array.range(t.tick-count) {
        let fraction = if t.tick-count > 1 { i / (t.tick-count - 1) } else { 0 }
        let y-val = r-min + r-range * fraction
        let y = pad-top + chart-height - fraction * chart-height
        place(left + top, dx: origin-x + chart-width + 4pt, dy: y,
          move(dy: -0.5em,
            text(size: t.axis-label-size, fill: r-color)[#format-number(y-val, digits: 1, mode: t.number-format)])
        )
      }

      // Compute left series points
      #let l-points = ()
      #for (i, val) in left-series.values.enumerate() {
        let x = if n == 1 { origin-x + chart-width / 2 } else { origin-x + (i / (n - 1)) * chart-width }
        let y = pad-top + chart-height - ((val - l-min) / l-range) * chart-height
        l-points.push((x, y))
      }

      // Compute right series points (scaled to right axis)
      #let r-points = ()
      #for (i, val) in right-series.values.enumerate() {
        let x = if n == 1 { origin-x + chart-width / 2 } else { origin-x + (i / (n - 1)) * chart-width }
        let y = pad-top + chart-height - ((val - r-min) / r-range) * chart-height
        r-points.push((x, y))
      }

      // Draw left series line segments
      #for i in array.range(calc.max(n - 1, 0)) {
        let p1 = l-points.at(i)
        let p2 = l-points.at(i + 1)
        place(
          left + top,
          line(
            start: (p1.at(0), p1.at(1)),
            end: (p2.at(0), p2.at(1)),
            stroke: 1.5pt + l-color,
          )
        )
      }

      // Draw right series line segments
      #for i in array.range(calc.max(n - 1, 0)) {
        let p1 = r-points.at(i)
        let p2 = r-points.at(i + 1)
        place(
          left + top,
          line(
            start: (p1.at(0), p1.at(1)),
            end: (p2.at(0), p2.at(1)),
            stroke: 1.5pt + r-color,
          )
        )
      }

      // Draw points
      #if show-points {
        for pt in l-points {
          place(
            left + top,
            dx: pt.at(0) - 3pt,
            dy: pt.at(1) - 3pt,
            circle(radius: 3pt, fill: l-color, stroke: white + 0.5pt)
          )
        }
        for pt in r-points {
          place(
            left + top,
            dx: pt.at(0) - 3pt,
            dy: pt.at(1) - 3pt,
            circle(radius: 3pt, fill: r-color, stroke: white + 0.5pt)
          )
        }
      }

      // X-axis category labels — spread evenly across chart width
      #let x-spacing = if n > 1 { chart-width / (n - 1) } else { chart-width }
      #for (i, lbl) in labels.enumerate() {
        let x = if n == 1 { origin-x } else { origin-x + (i / (n - 1)) * chart-width }
        place(left + top, dx: x - x-spacing / 2, dy: origin-y + 4pt,
          box(width: x-spacing, height: 1.5em,
            align(center + top, text(size: t.axis-label-size, fill: t.text-color)[#lbl]))
        )
      }

      // Axis labels
      #if left-label != none {
        place(left + top, dx: 2pt, dy: origin-y / 2,
          rotate(-90deg, text(size: t.axis-title-size, fill: l-color)[#left-label])
        )
      }
      #if right-label != none {
        place(left + top, dx: width - 8pt, dy: origin-y / 2,
          rotate(-90deg, text(size: t.axis-title-size, fill: r-color)[#right-label])
        )
      }
      #if x-label != none {
        place(left + top, dx: origin-x + chart-width / 2, dy: origin-y + 1.5em,
          align(center, text(size: t.axis-title-size, fill: t.text-color)[#x-label])
        )
      }
    ]

    // Legend
    #draw-legend-auto(
      ((name: left-series.name, color: l-color), (name: right-series.name, color: r-color)),
      t, swatch-type: "line",
    )
  ]
}
