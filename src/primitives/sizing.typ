// sizing.typ - Sizing and grid layout utilities

/// Resolves width and height to absolute lengths using the available region size.
/// Call inside `layout(size => ...)`. Handles ratio (100%), relative (100% - 5pt),
/// and absolute (300pt) values.
///
/// When `container: true` (the default), reserves space for chart-container's
/// inset padding so charts don't overflow their grid cells. Set `container: false`
/// for charts that render into a plain box without chart-container.
///
/// - width (length, ratio, relative): Width to resolve
/// - height (length, ratio, relative): Height to resolve
/// - size (dictionary): Available region from `layout(size => ...)`
/// - container (bool): Whether to reserve space for chart-container inset
/// -> dictionary with `width` and `height` keys
#let resolve-size(width, height, size, container: true) = {
  import "../primitives/container.typ": container-inset
  let margin = if container { 2 * container-inset } else { 0pt }
  let resolve(val, avail) = {
    let resolved = if type(val) == length { val }
      else if type(val) == ratio { avail * (val / 100%) }
      else if type(val) == relative { val.length + avail * (val.ratio / 100%) }
      else { val }
    // Clamp to available space so charts don't overflow containers.
    if type(resolved) == length and type(avail) == length and avail > 0pt {
      calc.min(resolved, avail - margin)
    } else {
      resolved
    }
  }
  (width: resolve(width, size.width), height: resolve(height, size.height))
}

/// Lays out items in a paged grid with automatic pagebreaks.
///
/// Groups items into pages of `cols * rows`, rendering each page as a grid
/// and inserting `#pagebreak()` between pages.
///
/// - items (array): Array of content items (charts, blocks, etc.)
/// - cols (int): Number of columns per page
/// - rows (int): Number of rows per page
/// - col-gutter (length): Horizontal gap between columns
/// - row-gutter (length): Vertical gap between rows
/// -> content
#let page-grid(items, cols: 2, rows: 4, col-gutter: 8pt, row-gutter: 4pt) = {
  let per-page = cols * rows
  let pages = calc.ceil(items.len() / per-page)
  for p in array.range(pages) {
    if p > 0 { pagebreak() }
    let start = p * per-page
    let end = calc.min(start + per-page, items.len())
    let page-items = items.slice(start, end)
    grid(
      columns: array.range(cols).map(_ => 1fr),
      column-gutter: col-gutter,
      row-gutter: row-gutter,
      ..page-items,
    )
  }
}
