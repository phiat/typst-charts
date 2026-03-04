// bump.typ - Bump chart (multi-period ranking chart)
#import "../theme.typ": resolve-theme, get-color
#import "../validate.typ": validate-series-data
#import "../primitives/container.typ": chart-container
#import "../primitives/axes.typ": draw-axis-lines, draw-grid, draw-axis-titles
#import "../primitives/legend.typ": draw-legend-auto

/// Renders a bump chart showing how items change ranking over time periods.
///
/// Rankings are displayed with rank 1 at the top and rank N at the bottom
/// (inverted Y-axis). Each series is drawn as a thick colored line with dots
/// at each time period, similar to F1 race position charts.
///
/// - data (dictionary): Dict with `labels` (time periods) and `series`
///   (each with `name` and `values` representing rankings per period)
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - dot-size (length): Diameter of point markers at each period
/// - line-width (length): Stroke width of ranking lines
/// - show-labels (bool): Show series name labels at start and end of lines
/// - show-legend (bool): Show series legend below the chart
/// - theme (none, dictionary): Theme overrides
/// -> content
#let bump-chart(
  data,
  width: 400pt,
  height: 250pt,
  title: none,
  dot-size: 5pt,
  line-width: 2.5pt,
  show-labels: true,
  show-legend: true,
  theme: none,
) = {
  validate-series-data(data, "bump-chart")
  let t = resolve-theme(theme)
  let labels = data.labels
  let series = data.series

  let n = labels.len()
  if n == 0 { return }
  let n-series = series.len()
  if n-series == 0 { return }

  // Determine the rank range across all values
  let all-values = series.map(s => s.values).flatten()
  let min-rank = calc.min(..all-values)
  let max-rank = calc.max(..all-values)
  let rank-range = max-rank - min-rank
  if rank-range == 0 { rank-range = 1 }

  let pad-left = t.axis-padding-left
  let pad-bottom = t.axis-padding-bottom
  let pad-top = t.axis-padding-top
  let pad-right = t.axis-padding-right

  chart-container(width, height, title, t, extra-height: 50pt)[
    #let chart-height = height - pad-top - pad-bottom
    #let chart-width = width - pad-left - pad-right
    #let origin-x = pad-left
    #let origin-y = pad-top + chart-height

    #box(width: width, height: height)[
      // Grid
      #draw-grid(origin-x, pad-top, chart-width, chart-height, t)

      // Axes
      #draw-axis-lines(origin-x, origin-y, origin-x + chart-width, pad-top, t)

      // Draw each series as a thick line with dots
      #for (si, s) in series.enumerate() {
        let values = s.values
        let color = get-color(t, si)

        // Compute point positions
        // Y is inverted: rank 1 at top, max-rank at bottom
        let points = ()
        for (i, val) in values.enumerate() {
          let x = if n == 1 { origin-x + chart-width / 2 } else { origin-x + (i / (n - 1)) * chart-width }
          let y = pad-top + ((val - min-rank) / rank-range) * chart-height
          points.push((x, y))
        }

        // Draw connecting lines
        for i in array.range(calc.max(n - 1, 0)) {
          let p1 = points.at(i)
          let p2 = points.at(i + 1)
          place(
            left + top,
            line(
              start: (p1.at(0), p1.at(1)),
              end: (p2.at(0), p2.at(1)),
              stroke: line-width + color,
            )
          )
        }

        // Draw dots at each period
        for pt in points {
          place(
            left + top,
            dx: pt.at(0) - dot-size / 2,
            dy: pt.at(1) - dot-size / 2,
            circle(radius: dot-size / 2, fill: color, stroke: white + 1pt)
          )
        }

        // Labels at start and end of each series line
        if show-labels {
          let first-pt = points.at(0)
          place(
            left + top,
            dx: 0pt,
            dy: first-pt.at(1),
            box(width: origin-x - 4pt, height: 0pt,
              align(right, move(dy: -0.5em,
                text(size: t.axis-label-size, fill: color, weight: "bold")[#s.name])))
          )

          if n > 1 {
            let last-pt = points.at(n - 1)
            place(
              left + top,
              dx: last-pt.at(0) + dot-size / 2 + 3pt,
              dy: last-pt.at(1),
              move(dy: -0.5em,
                text(size: t.axis-label-size, fill: color, weight: "bold")[#s.name])
            )
          }
        }
      }

      // X-axis labels — spread evenly across chart width
      #let x-spacing = if n > 1 { chart-width / (n - 1) } else { chart-width }
      #for (i, lbl) in labels.enumerate() {
        let x = if n == 1 { origin-x } else { origin-x + (i / (n - 1)) * chart-width }
        place(left + top, dx: x - x-spacing / 2, dy: origin-y + 4pt,
          box(width: x-spacing, height: 1.5em,
            align(center + top, text(size: t.axis-label-size, fill: t.text-color)[#lbl]))
        )
      }

      // Y-axis labels (rank numbers, 1 at top, max at bottom)
      #for rank in array.range(int(min-rank), int(max-rank) + 1) {
        let y = pad-top + ((rank - min-rank) / rank-range) * chart-height
        place(left + top, dx: 0pt, dy: y,
          box(width: origin-x - 2pt, height: 0pt,
            align(right, move(dy: -0.5em,
              text(size: t.axis-label-size, fill: t.text-color)[#rank])))
        )
      }
    ]

    #draw-legend-auto(series.map(s => s.name), t, show-legend: show-legend, swatch-type: "line")
  ]
}
