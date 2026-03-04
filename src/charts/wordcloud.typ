// wordcloud.typ - Word cloud chart (flowing text layout with shape masks)
#import "../theme.typ": resolve-theme, _resolve-ctx, get-color
#import "../util.typ": nonzero
#import "../validate.typ": validate-wordcloud-data
#import "../primitives/container.typ": chart-container

/// Renders a word cloud where each word's font size is proportional to its weight.
///
/// Words are sorted by weight descending and laid out within a shaped region.
/// Larger words dominate visually, creating the characteristic word-cloud appearance.
///
/// - data (dictionary): Must contain a `words` array of dictionaries,
///   each with `text` (string) and `weight` (number) keys.
/// - width (length): Chart width
/// - height (length): Chart height
/// - min-size (length): Font size for the lowest-weight word
/// - max-size (length): Font size for the highest-weight word
/// - title (none, content): Optional chart title
/// - padding (length): Inner padding around the word area
/// - shape (str): Layout shape — `"rectangle"` (default text flow),
///   `"circle"`, `"diamond"`, or `"triangle"`
/// - theme (none, dictionary): Theme overrides
/// -> content
#let word-cloud(
  data,
  width: 300pt,
  height: 200pt,
  min-size: 8pt,
  max-size: 36pt,
  title: none,
  padding: 8pt,
  shape: "rectangle",
  theme: none,
) = context {
  validate-wordcloud-data(data, "word-cloud")
  let t = _resolve-ctx(theme)
  let words = data.words

  if words.len() == 0 { return }

  // Sort by weight descending
  let sorted-words = words.sorted(key: w => -w.weight)

  // Find weight range for size mapping
  let max-weight = sorted-words.at(0).weight
  let min-weight = sorted-words.last().weight
  let weight-range = nonzero(max-weight - min-weight)

  // Font weight alternation for visual variety
  let font-weights = ("bold", "regular", "bold", "medium", "regular")

  // For shaped layouts, resolve relative lengths via layout()
  if shape != "rectangle" and (type(width) != length or type(height) != length) {
    // Wrap in layout() to resolve relative dimensions
    return layout(size => {
      let abs-w = if type(width) == length { width } else { size.width }
      let abs-h = if type(height) == length { height } else { size.height }
      word-cloud(data, width: abs-w, height: abs-h, min-size: min-size, max-size: max-size,
        title: title, padding: padding, shape: shape, theme: theme)
    })
  }

  if shape == "rectangle" {
    // Original flow-based layout
    chart-container(width, height, title, t, extra-height: 10pt)[
      #box(width: width, height: height, clip: true, inset: padding)[
        #set align(center)
        #set par(leading: 2pt, spacing: 4pt)
        #for (i, w) in sorted-words.enumerate() {
          let frac = (w.weight - min-weight) / weight-range
          let size = min-size + frac * (max-size - min-size)
          let color = get-color(t, i)
          let fw = font-weights.at(calc.rem(i, font-weights.len()))
          box(inset: (x: 3pt, y: 1pt))[
            #text(size: size, fill: color, weight: fw)[#w.text]
          ]
        }
      ]
    ]
  } else {
    // Shaped layout: place words row-by-row, clipping each row to the shape mask.
    // We estimate word widths and lay them out in centered rows that respect
    // the shape boundary at each y-level.

    let inner-w = width - 2 * padding
    let inner-h = height - 2 * padding
    let cx = inner-w / 2
    let cy = inner-h / 2
    let rx = inner-w / 2  // horizontal radius
    let ry = inner-h / 2  // vertical radius

    // Shape width at a given y-fraction (0 = top, 1 = bottom) relative to center
    // Returns the usable row width at that y position
    let shape-width-at(y-frac) = {
      // y-frac: 0..1 where 0 = top of shape area, 1 = bottom
      let dy = y-frac - 0.5  // -0.5 to 0.5 from center
      if shape == "circle" {
        // Ellipse: w = 2 * rx * sqrt(1 - (dy/ry_frac)^2)
        let t = 2 * dy  // -1 to 1
        let sq = 1.0 - t * t
        if sq <= 0 { 0pt } else { inner-w * calc.sqrt(sq) }
      } else if shape == "diamond" {
        // Diamond: width decreases linearly from center
        let t = calc.abs(2 * dy)  // 0 at center, 1 at edges
        inner-w * calc.max(0, 1 - t)
      } else if shape == "triangle" {
        // Triangle: widest at bottom, narrows to top
        inner-w * y-frac
      } else {
        inner-w  // fallback to rectangle
      }
    }

    // Pre-compute word sizes and estimated widths
    let word-data = sorted-words.enumerate().map(((i, w)) => {
      let frac = (w.weight - min-weight) / weight-range
      let size = min-size + frac * (max-size - min-size)
      let est-width = size * 0.6 * w.text.len() + 8pt  // rough text width estimate
      let line-height = size * 1.4
      let color = get-color(t, i)
      let fw = font-weights.at(calc.rem(i, font-weights.len()))
      (text: w.text, size: size, est-width: est-width, line-height: line-height, color: color, fw: fw)
    })

    // Greedy row packing: fill rows top-to-bottom, respecting shape width
    let rows = ()
    let current-row = ()
    let current-row-width = 0pt
    let current-row-height = 0pt
    let y-cursor = 0pt
    let word-idx = 0

    for wd in word-data {
      // Determine available width at current y position
      let y-frac = (y-cursor + wd.line-height / 2) / inner-h
      let y-frac = calc.max(0, calc.min(1, y-frac))
      let avail = shape-width-at(y-frac)

      if current-row-width + wd.est-width > avail and current-row.len() > 0 {
        // Commit current row
        rows.push((words: current-row, y: y-cursor, height: current-row-height, avail-width: avail))
        y-cursor = y-cursor + current-row-height + 2pt
        current-row = ()
        current-row-width = 0pt
        current-row-height = 0pt

        // Recalculate available width at new y
        let y-frac2 = (y-cursor + wd.line-height / 2) / inner-h
        let y-frac2 = calc.max(0, calc.min(1, y-frac2))
        avail = shape-width-at(y-frac2)
      }

      // If single word is wider than available space, try to fit it anyway
      if current-row.len() == 0 or current-row-width + wd.est-width <= avail + 10pt {
        current-row.push(wd)
        current-row-width = current-row-width + wd.est-width
        if wd.line-height > current-row-height {
          current-row-height = wd.line-height
        }
      }

      // Stop if we've exceeded the shape height
      if y-cursor + current-row-height > inner-h {
        if current-row.len() > 0 {
          let y-frac3 = (y-cursor + current-row-height / 2) / inner-h
          let y-frac3 = calc.max(0, calc.min(1, y-frac3))
          rows.push((words: current-row, y: y-cursor, height: current-row-height, avail-width: shape-width-at(y-frac3)))
        }
        current-row = ()
        break
      }
    }
    // Commit last row
    if current-row.len() > 0 {
      let y-frac4 = (y-cursor + current-row-height / 2) / inner-h
      let y-frac4 = calc.max(0, calc.min(1, y-frac4))
      rows.push((words: current-row, y: y-cursor, height: current-row-height, avail-width: shape-width-at(y-frac4)))
    }

    // Center vertically: compute total used height and offset
    let total-used-h = if rows.len() > 0 {
      rows.last().y + rows.last().height
    } else { 0pt }
    let y-offset = calc.max(0pt, (inner-h - total-used-h) / 2)

    chart-container(width, height, title, t, extra-height: 10pt)[
      #box(width: width, height: height, clip: true, inset: padding)[
        #for row in rows {
          // Center each row horizontally within the shape width at this y
          let row-total-w = row.words.map(w => w.est-width).sum()
          let row-x = cx - row-total-w / 2

          for wd in row.words {
            place(left + top,
              dx: row-x,
              dy: row.y + y-offset,
              box(width: wd.est-width, height: row.height,
                align(center + horizon,
                  text(size: wd.size, fill: wd.color, weight: wd.fw)[#wd.text]))
            )
            row-x = row-x + wd.est-width
          }
        }
      ]
    ]
  }
}
