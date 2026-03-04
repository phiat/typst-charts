# Primaviz

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Typst](https://img.shields.io/badge/typst-%3E%3D0.12.0-239dad)](https://typst.app)
[![Charts](https://img.shields.io/badge/chart_types-51-orange)](screenshots/)
[![Pure Typst](https://img.shields.io/badge/dependencies-zero-brightgreen)]()

A charting library for [Typst](https://typst.app) built entirely with native primitives (`rect`, `circle`, `line`, `polygon`, `place`). No external dependencies required.

## Gallery

All 51 chart types across 8 pages — see [`examples/showcase.typ`](examples/showcase.typ) for the source:

![Showcase Page 1](screenshots/showcase-1.png)
![Showcase Page 2](screenshots/showcase-2.png)
![Showcase Page 3](screenshots/showcase-3.png)
![Showcase Page 4](screenshots/showcase-4.png)
![Showcase Page 5](screenshots/showcase-5.png)
![Showcase Page 6](screenshots/showcase-6.png)
![Showcase Page 7](screenshots/showcase-7.png)
![Showcase Page 8](screenshots/showcase-8.png)

## Per-Chart Demos

Each demo shows a chart family in a 2×2 grid with light/dark themes and variations.
See [`examples/demos/`](examples/demos/) for the source files.

| Demo | Charts shown |
|---|---|
| ![bar](screenshots/demo-bar.png) | `bar-chart`, `horizontal-bar-chart` (light + dark) |
| ![bar-multi](screenshots/demo-bar-multi.png) | `grouped-bar-chart`, `stacked-bar-chart` (light + dark) |
| ![bar-advanced](screenshots/demo-bar-advanced.png) | `grouped-stacked-bar-chart`, `diverging-bar-chart` (light + dark) |
| ![line](screenshots/demo-line.png) | `line-chart`, `multi-line-chart` (light + dark) |
| ![area](screenshots/demo-area.png) | `area-chart`, `stacked-area-chart` (light + dark) |
| ![dual-axis](screenshots/demo-dual-axis.png) | `dual-axis-chart` (light, dark, presentation, minimal) |
| ![pie](screenshots/demo-pie.png) | `pie-chart`, donut mode (light + dark) |
| ![radar](screenshots/demo-radar.png) | `radar-chart` (light, dark, 3-series, accessible) |
| ![scatter](screenshots/demo-scatter.png) | `scatter-plot`, `multi-scatter-plot`, `bubble-chart` |
| ![gauge](screenshots/demo-gauge.png) | `gauge-chart`, `progress-bar`, `circular-progress` |
| ![heatmap](screenshots/demo-heatmap.png) | `heatmap`, `calendar-heatmap`, `correlation-matrix` |
| ![statistical](screenshots/demo-statistical.png) | `histogram`, `box-plot`, `violin-plot`, `waterfall-chart` |
| ![comparison](screenshots/demo-comparison.png) | `slope-chart`, `dumbbell-chart`, `lollipop-chart`, `bullet-chart` |
| ![flow](screenshots/demo-flow.png) | `sankey-chart`, `gantt-chart`, `timeline-chart`, `chord-diagram` |
| ![misc](screenshots/demo-misc.png) | `waffle-chart`, `parliament-chart`, `radial-bar-chart`, `sunburst-chart` |
| ![dashboard](screenshots/demo-dashboard.png) | `metric-row`, `word-cloud`, sparklines table, `progress-bars` |
| ![rings](screenshots/demo-rings.png) | `ring-progress`, `treemap` (light + dark) |
| ![bump](screenshots/demo-bump.png) | `bump-chart`, `funnel-chart` (light + dark) |

## Examples

| File | Description |
|---|---|
| [`examples/demos/`](examples/demos/) | 18 per-chart demo files, each a 2×2 grid (light/dark + variations) |
| [`examples/showcase.typ`](examples/showcase.typ) | Compact 8-page showcase of all chart types (dark theme) |
| [`examples/demo.typ`](examples/demo.typ) | Comprehensive demo with all features, themes, and data loading |

Sample data files used by `demo.typ`:
- [`data/characters.json`](data/characters.json) — RPG character stats
- [`data/events.json`](data/events.json) — Conference/event data
- [`data/analytics.json`](data/analytics.json) — Dashboard analytics data

```bash
just demos      # Compile all per-chart demos
just showcase   # Compile the showcase
just demo       # Compile the comprehensive demo
```

## Features

- **51 chart types** for data visualization
- **JSON data input** — load data directly from JSON files
- **Theme system** — preset themes and custom overrides for consistent styling
- **Layout primitives** — shared utilities for label density, font scaling, and label placement
- **Annotations** — overlay reference lines, bands, and labels on Cartesian charts
- **Customizable** — colors, sizes, labels, legends
- **Pure Typst** — no packages or external tools needed

## Chart Types

### Bar Charts
- `bar-chart` - Vertical bar chart
- `horizontal-bar-chart` - Horizontal bar chart
- `grouped-bar-chart` - Side-by-side grouped bars
- `stacked-bar-chart` - Stacked bar segments
- `grouped-stacked-bar-chart` - Groups of stacked segments side by side
- `lollipop-chart` - Vertical stem + dot (cleaner bar alternative)
- `horizontal-lollipop-chart` - Horizontal stem + dot
- `diverging-bar-chart` - Left/right bars from center axis

### Line & Area Charts
- `line-chart` - Single line with points
- `multi-line-chart` - Multiple series comparison
- `dual-axis-chart` - Two independent Y-axes
- `area-chart` - Filled area under line
- `stacked-area-chart` - Stacked area series

### Circular Charts
- `pie-chart` - Pie chart with legend
- `pie-chart` (donut mode) - Donut/ring chart
- `radar-chart` - Spider/radar chart

### Scatter & Bubble
- `scatter-plot` - X/Y point plotting
- `multi-scatter-plot` - Multi-series scatter
- `bubble-chart` - Scatter with size dimension
- `multi-bubble-chart` - Multi-series bubble chart

### Gauges & Progress
- `gauge-chart` - Semi-circular dial gauge
- `progress-bar` - Horizontal progress bar
- `circular-progress` - Ring progress indicator
- `ring-progress` - Concentric fitness rings (Apple Watch style)
- `progress-bars` - Multiple comparison bars

### Sparklines (inline)
- `sparkline` - Tiny line chart for tables and text
- `sparkbar` - Tiny bar chart
- `sparkdot` - Tiny dot chart

### Heatmaps
- `heatmap` - Grid heatmap with color scale
- `calendar-heatmap` - GitHub-style activity grid
- `correlation-matrix` - Symmetric correlation display

### Statistical
- `histogram` - Auto-binned frequency distribution
- `waterfall-chart` - Bridge/waterfall chart with pos/neg/total segments
- `funnel-chart` - Conversion funnel with percentages
- `box-plot` - Box-and-whisker distribution plot
- `treemap` - Nested rectangles for hierarchical data
- `slope-chart` - Two-period comparison with connecting lines
- `bullet-chart` - Compact gauge with qualitative ranges and target
- `bullet-charts` - Multiple bullet charts stacked vertically

### Proportional & Hierarchical
- `waffle-chart` - 10×10 grid of colored squares for proportions
- `sunburst-chart` - Multi-level hierarchical pie with nested rings
- `parliament-chart` - Semicircle dot layout for seat visualization

### Comparison & Ranking
- `bump-chart` - Multi-period ranking chart
- `dumbbell-chart` - Before/after dot comparisons with connecting lines
- `radial-bar-chart` - Circular bars radiating from center

### Distribution
- `violin-plot` - Kernel density estimation with mirrored polygon

### Flow & Timeline
- `sankey-chart` - Flow diagram with curved bands between nodes
- `gantt-chart` - Timeline bar chart for project scheduling
- `timeline-chart` - Vertical event timeline with alternating layout
- `chord-diagram` - Circular flow diagram with chord bands

### Dashboard
- `metric-card` - KPI tile with value, delta, and sparkline
- `metric-row` - Horizontal row of metric cards
- `word-cloud` - Weighted text layout sized by importance

### Annotations
Overlay reference lines, bands, and labels on bar, line, and scatter charts:
- `h-line` - Horizontal reference line (target, average, threshold)
- `v-line` - Vertical reference line
- `h-band` - Horizontal shaded region (goal zone, range)
- `label` - Text label at a data point

## Installation

```typst
#import "@preview/primaviz:0.2.0": *
```

## Usage

```typst
#import "@preview/primaviz:0.2.0": *

// Load data from JSON
#let data = json("mydata.json")

// Create a bar chart
#bar-chart(
  (
    labels: ("A", "B", "C", "D"),
    values: (25, 40, 30, 45),
  ),
  width: 300pt,
  height: 200pt,
  title: "My Chart",
)

// Create a pie chart
#pie-chart(
  (
    labels: ("Red", "Blue", "Green"),
    values: (30, 45, 25),
  ),
  size: 150pt,
  donut: true,
)

// Create a radar chart
#radar-chart(
  (
    labels: ("STR", "DEX", "CON", "INT", "WIS", "CHA"),
    series: (
      (name: "Fighter", values: (18, 12, 16, 10, 13, 8)),
      (name: "Wizard", values: (8, 14, 12, 18, 15, 11)),
    ),
  ),
  size: 200pt,
  title: "Character Comparison",
)
```

## Theming

Every chart function accepts an optional `theme` parameter. Themes control colors, font sizes, grid lines, backgrounds, and other visual properties.

### Using a preset theme

```typst
#import "@preview/primaviz:0.2.0": *

#bar-chart(data, theme: themes.dark)
```

### Custom overrides

Pass a dictionary with only the keys you want to change. Unspecified keys fall back to the default theme:

```typst
#bar-chart(data, theme: (show-grid: true, palette: (red, blue, green)))
```

### Available presets

| Preset | Description |
|---|---|
| `themes.default` | Tableau 10 color palette, no grid, standard font sizes |
| `themes.minimal` | Lighter axis strokes, grid enabled, regular-weight titles |
| `themes.dark` | Dark background (`#1a1a2e`), vibrant neon palette (cyan, pink, purple, ...) |
| `themes.presentation` | Larger font sizes across the board for slides and projectors |
| `themes.print` | Grayscale palette with grid lines, optimized for black-and-white printing |
| `themes.accessible` | Okabe-Ito colorblind-safe palette |

## Data Formats

### Simple data (labels + values)
```typst
(
  labels: ("Jan", "Feb", "Mar"),
  values: (100, 150, 120),
)
```

### Multi-series data
```typst
(
  labels: ("Q1", "Q2", "Q3"),
  series: (
    (name: "Product A", values: (100, 120, 140)),
    (name: "Product B", values: (80, 90, 110)),
  ),
)
```

### Scatter/bubble data
```typst
(
  x: (1, 2, 3, 4, 5),
  y: (10, 25, 15, 30, 20),
  size: (5, 10, 8, 15, 12),  // for bubble chart
)
```

### Heatmap data
```typst
(
  rows: ("Row1", "Row2", "Row3"),
  cols: ("Col1", "Col2", "Col3"),
  values: (
    (1, 2, 3),
    (4, 5, 6),
    (7, 8, 9),
  ),
)
```

## Color Palette

The default theme uses Tableau 10 colors. You can access colors from any theme via the `get-color` function:

```typst
#import "@preview/primaviz:0.2.0": get-color, themes

// Default palette
#get-color(themes.default, 0)  // blue
#get-color(themes.default, 1)  // orange
#get-color(themes.default, 2)  // red

// Or use a theme preset
#get-color(themes.dark, 0)  // cyan
```

## Project Structure

```text
primaviz/
  src/
    lib.typ            # Public entrypoint - re-exports everything
    theme.typ          # Theme system and preset themes
    util.typ           # Shared utilities
    charts/            # One module per chart family
      bar.typ          # bar, horizontal, grouped, stacked, grouped-stacked
      line.typ         # line, multi-line
      dual-axis.typ    # dual Y-axis
      area.typ         # area, stacked-area
      pie.typ          # pie, donut
      radar.typ
      scatter.typ      # scatter, multi-scatter, bubble, multi-bubble
      gauge.typ        # gauge, progress-bar, circular-progress, progress-bars
      rings.typ        # ring-progress (fitness rings)
      heatmap.typ      # heatmap, calendar-heatmap, correlation-matrix
      sparkline.typ    # sparkline, sparkbar, sparkdot
      waterfall.typ
      funnel.typ
      boxplot.typ
      histogram.typ
      treemap.typ
      lollipop.typ     # lollipop, horizontal-lollipop
      sankey.typ
      bullet.typ       # bullet-chart, bullet-charts
      slope.typ
      diverging.typ
      gantt.typ
      waffle.typ
      bump.typ
      dumbbell.typ
      radial-bar.typ
      sunburst.typ
      metric.typ       # metric-card, metric-row
      violin.typ
      timeline.typ
      parliament.typ
      chord.typ
      wordcloud.typ
    primitives/        # Low-level drawing helpers
      axes.typ         # axis lines, ticks, labels, grid, cartesian-layout
      layout.typ       # label-fits-inside, density-skip, font-for-space, page-grid, place-cartesian-label
      annotations.typ
      container.typ
      legend.typ       # horizontal, vertical, draw-legend-auto
      polar.typ        # shared polar/radial helpers (arcs, slices, labels)
      title.typ
    validate.typ       # Input validation helpers
  examples/
    demos/             # Per-chart demo files (18 files, 2×2 grids)
      demo-bar.typ     # bar-chart, horizontal-bar-chart
      demo-bar-multi.typ  # grouped-bar, stacked-bar
      demo-bar-advanced.typ  # grouped-stacked, diverging
      demo-line.typ    # line-chart, multi-line-chart
      demo-area.typ    # area-chart, stacked-area-chart
      demo-dual-axis.typ  # dual-axis-chart (4 themes)
      demo-pie.typ     # pie-chart, donut
      demo-radar.typ   # radar-chart (4 variants)
      demo-scatter.typ # scatter, multi-scatter, bubble
      demo-gauge.typ   # gauge, progress-bar, circular-progress
      demo-heatmap.typ # heatmap, calendar-heatmap, correlation-matrix
      demo-statistical.typ  # histogram, box-plot, violin, waterfall
      demo-comparison.typ   # slope, dumbbell, lollipop, bullet
      demo-flow.typ    # sankey, gantt, timeline, chord
      demo-misc.typ    # waffle, parliament, radial-bar, sunburst
      demo-dashboard.typ    # metric-row, word-cloud, sparklines, progress-bars
      demo-rings.typ   # ring-progress, treemap
      demo-bump.typ    # bump-chart, funnel-chart
    showcase.typ       # 8-page compact showcase (dark theme)
    demo.typ           # Comprehensive demo with JSON data loading
  data/                # Sample JSON data files
  screenshots/         # Gallery images (demo-*.png + showcase-*.png)
  justfile             # Common dev commands
```

## Development

Dev commands via [just](https://github.com/casey/just):

```bash
just demos        # Compile all per-chart demos
just demo         # Compile the comprehensive demo
just showcase     # Compile the showcase
just watch        # Live-reload during development
just watch-demo bar  # Watch a specific demo (e.g., bar, pie, scatter)
just test         # Run all compilation tests
just check        # Full CI check (demo + demos + showcase + tests)
just screenshots  # Regenerate gallery images (demo-*.png + showcase-*.png)
just open         # Compile and open the demo PDF
just dev          # Watch with live-reload and open PDF
just clean        # Clean generated artifacts
just release      # Full release prep (check + screenshots)
just stats        # Show project stats
```

Issue tracking with [beads](https://github.com/steveyegge/beads).

## License

MIT
