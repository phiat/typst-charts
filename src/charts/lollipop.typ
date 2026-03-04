// lollipop.typ - Lollipop charts (vertical and horizontal)
#import "../theme.typ": resolve-theme, get-color
#import "../util.typ": normalize-data
#import "../validate.typ": validate-simple-data
#import "../primitives/container.typ": chart-container
#import "../primitives/axes.typ": draw-axis-lines, draw-grid, draw-axis-titles, draw-y-ticks, draw-x-ticks, draw-x-category-labels
#import "../primitives/annotations.typ": draw-annotations

/// Renders a vertical lollipop chart with a thin stem and circle dot per category.
///
/// A lollipop chart is like a bar chart but uses a thin line (stem) capped by a
/// filled circle (dot) instead of a filled bar. Useful for ranked or comparison data
/// where a cleaner look is desired.
///
/// - data (dictionary, array): Label-value pairs as dict or array of tuples
/// - width (length): Chart width
/// - height (length): Chart height
/// - dot-size (length): Radius of the dot at the end of each stem
/// - stem-width (length): Thickness of the stem line
/// - title (none, content): Optional chart title
/// - show-values (bool): Display value labels above dots
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - annotations (none, array): Optional annotation descriptors
/// - theme (none, dictionary): Theme overrides
/// -> content
#let lollipop-chart(
  data,
  width: 300pt,
  height: 200pt,
  dot-size: 4pt,
  stem-width: 1.5pt,
  title: none,
  show-values: true,
  x-label: none,
  y-label: none,
  annotations: none,
  theme: none,
) = {
  validate-simple-data(data, "lollipop-chart")
  let t = resolve-theme(theme)
  let norm = normalize-data(data)
  let labels = norm.labels
  let values = norm.values

  let max-val = if values.len() > 0 { calc.max(..values) } else { 0 }
  if max-val == 0 { max-val = 1 }
  let n = values.len()
  if n == 0 { return }

  let pad-left = t.axis-padding-left
  let pad-bottom = t.axis-padding-bottom
  let pad-top = t.axis-padding-top
  let pad-right = t.axis-padding-right

  chart-container(width, height, title, t, extra-height: 30pt)[
    #let chart-height = height - pad-top - pad-bottom
    #let chart-width = width - pad-left - pad-right
    #let origin-x = pad-left
    #let origin-y = pad-top + chart-height

    #box(width: width, height: height)[
      // Grid
      #draw-grid(origin-x, pad-top, chart-width, chart-height, t)

      // Axes
      #draw-axis-lines(origin-x, origin-y, origin-x + chart-width, pad-top, t)

      // Y-axis ticks
      #draw-y-ticks(0, max-val, chart-height, pad-top, origin-x, t)

      #let spacing = chart-width / n

      #for (i, val) in values.enumerate() {
        let stem-h = (val / max-val) * chart-height
        let x-center = origin-x + i * spacing + spacing / 2

        // Stem
        place(
          left + top,
          dx: x-center,
          dy: origin-y,
          line(
            start: (0pt, 0pt),
            end: (0pt, -stem-h),
            stroke: get-color(t, i) + stem-width,
          )
        )

        // Dot
        place(
          left + top,
          dx: x-center - dot-size,
          dy: origin-y - stem-h - dot-size,
          circle(
            radius: dot-size,
            fill: get-color(t, i),
            stroke: none,
          )
        )

        // Value label — centered above dot
        if show-values {
          place(
            left + top,
            dx: x-center - spacing / 2,
            dy: origin-y - stem-h - dot-size * 2 - 1em,
            box(width: spacing,
              align(center, text(size: t.value-label-size, fill: t.text-color)[#val]))
          )
        }
      }

      // X-axis category labels
      #draw-x-category-labels(labels, origin-x, spacing, origin-y + 4pt, t)

      // Axis titles
      #draw-axis-titles(x-label, y-label, origin-x + chart-width / 2, origin-y / 2, t)

      // Annotations
      #draw-annotations(annotations, origin-x, pad-top, chart-width, chart-height, -0.5, n - 0.5, 0, max-val, t)
    ]
  ]
}

/// Renders a horizontal lollipop chart with category labels on the y-axis.
///
/// Like a horizontal bar chart but uses a thin line (stem) from the y-axis and a
/// filled circle (dot) at the value endpoint.
///
/// - data (dictionary, array): Label-value pairs as dict or array of tuples
/// - width (length): Chart width
/// - height (length): Chart height
/// - dot-size (length): Radius of the dot at the end of each stem
/// - stem-width (length): Thickness of the stem line
/// - title (none, content): Optional chart title
/// - show-values (bool): Display value labels beside dots
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - theme (none, dictionary): Theme overrides
/// -> content
#let horizontal-lollipop-chart(
  data,
  width: 350pt,
  height: 200pt,
  dot-size: 4pt,
  stem-width: 1.5pt,
  title: none,
  show-values: true,
  x-label: none,
  y-label: none,
  theme: none,
) = {
  validate-simple-data(data, "horizontal-lollipop-chart")
  let t = resolve-theme(theme)
  let norm = normalize-data(data)
  let labels = norm.labels
  let values = norm.values

  let max-val = if values.len() > 0 { calc.max(..values) } else { 0 }
  if max-val == 0 { max-val = 1 }
  let n = values.len()
  if n == 0 { return }

  let pad-left = t.axis-padding-left + 40pt  // extra space for category labels
  let pad-bottom = t.axis-padding-bottom
  let pad-top = t.axis-padding-top
  let pad-right = t.axis-padding-right

  chart-container(width, height, title, t, extra-height: 30pt)[
    #let chart-height = height - pad-top - pad-bottom
    #let chart-width = width - pad-left - pad-right
    #let origin-x = pad-left
    #let origin-y = pad-top + chart-height

    #box(width: width, height: height)[
      // Grid
      #draw-grid(origin-x, pad-top, chart-width, chart-height, t)

      // Axes
      #draw-axis-lines(origin-x, origin-y, origin-x + chart-width, pad-top, t)

      // X-axis ticks (numeric values along bottom)
      #draw-x-ticks(0, max-val, chart-width, origin-x, origin-y + 4pt, t, digits: 0)

      #let spacing = chart-height / n

      #for (i, val) in values.enumerate() {
        let stem-len = (val / max-val) * chart-width
        let y-center = pad-top + i * spacing + spacing / 2

        // Stem
        place(
          left + top,
          dx: origin-x,
          dy: y-center,
          line(
            start: (0pt, 0pt),
            end: (stem-len, 0pt),
            stroke: get-color(t, i) + stem-width,
          )
        )

        // Dot
        place(
          left + top,
          dx: origin-x + stem-len - dot-size,
          dy: y-center - dot-size,
          circle(
            radius: dot-size,
            fill: get-color(t, i),
            stroke: none,
          )
        )

        // Value label
        if show-values {
          place(
            left + top,
            dx: origin-x + stem-len + dot-size + 5pt,
            dy: y-center,
            move(dy: -0.5em, text(size: t.value-label-size, fill: t.text-color)[#val])
          )
        }

        // Y-axis label (category) — right-aligned into the padding area
        place(
          left + top,
          dx: 0pt,
          dy: y-center,
          box(width: origin-x - 4pt, height: 0pt,
            align(right, move(dy: -0.5em,
              text(size: t.axis-label-size, fill: t.text-color)[#labels.at(i)])))
        )
      }

      // Axis titles
      #draw-axis-titles(x-label, y-label, origin-x + chart-width / 2, origin-y / 2, t)
    ]
  ]
}
