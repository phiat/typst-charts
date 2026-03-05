// Compact showcase — All chart types using page-grid layout engine
#import "../src/lib.typ": *
#import "demo-data.typ": sales, codebase, league

#set page(margin: (x: 0.6cm, y: 0.6cm), paper: "a4", fill: rgb("#1a1a2e"))
#set text(size: 7pt, fill: rgb("#e0e0e0"))

#let dk = themes.dark
#let gk = (..dk, title-size: 7pt)

// Standard cell sizes for 2-col × 4-row layout on A4
#let W = 250pt
#let H = 100pt
#let Hs = 95pt

// ── All charts as a flat array ─────────────────────────────────────────────────

#page-grid(cols: 2, rows: 4, (

  // 1. bar-chart
  bar-chart(codebase.subsystems,
    width: W, height: H, title: "bar-chart", y-label: "LoC", theme: dk,
  ),

  // 2. horizontal-bar-chart
  horizontal-bar-chart(codebase.patches,
    width: W, height: H, title: "horizontal-bar-chart", x-label: "Patches", theme: dk,
  ),

  // 3. grouped-bar-chart
  grouped-bar-chart(sales.quarterly,
    width: W, height: H, title: "grouped-bar-chart", theme: dk,
  ),

  // 4. stacked-bar-chart
  stacked-bar-chart(sales.quarterly,
    width: W, height: H, title: "stacked-bar-chart", theme: dk,
  ),

  // 5. line-chart
  line-chart(sales.monthly,
    width: W, height: Hs, title: "line-chart", show-points: true, y-label: "Revenue ($K)", theme: dk,
  ),

  // 6. multi-line-chart
  multi-line-chart(sales.monthly-series,
    width: W, height: Hs, title: "multi-line-chart", theme: dk,
  ),

  // 7. area-chart
  area-chart(sales.monthly,
    width: W, height: Hs, title: "area-chart", fill-opacity: 40%, y-label: "Revenue ($K)", theme: dk,
  ),

  // 8. stacked-area-chart
  stacked-area-chart(sales.monthly-series,
    width: W, height: Hs, title: "stacked-area-chart", theme: dk,
  ),

  // ── page 2 ──

  // 9. pie-chart
  pie-chart(codebase.languages,
    size: 85pt, title: "pie-chart", theme: dk,
  ),

  // 10. pie-chart (donut)
  pie-chart(sales.expenses,
    size: 85pt, title: "pie-chart (donut)", donut: true, donut-ratio: 0.5, theme: dk,
  ),

  // 11. radar-chart
  radar-chart(
    (labels: league.player-stats.labels, series: league.player-stats.series.slice(0, 2)),
    size: 100pt, title: "radar-chart", fill-opacity: 15%, theme: dk,
  ),

  // 12. scatter-plot
  scatter-plot(league.team-scatter,
    width: W, height: Hs, title: "scatter-plot",
    x-label: "Goals Scored", y-label: "Goals Conceded",
    annotations: (
      (type: "h-line", value: 40, label: "Threshold", color: rgb("#ff6b6b"), dash: "dashed"),
    ),
    theme: dk,
  ),

  // 13. multi-scatter-plot
  multi-scatter-plot(league.home-away,
    width: W, height: Hs, title: "multi-scatter-plot",
    x-label: "Goals Scored", y-label: "Goals Conceded", theme: dk,
  ),

  // 14. bubble-chart
  bubble-chart(league.team-bubble,
    width: W, height: Hs, title: "bubble-chart",
    x-label: "Goals", y-label: "Possession %",
    show-labels: true, labels: league.team-bubble.labels, theme: dk,
  ),

  // 15. gauge-chart
  [
    #text(size: 8pt, weight: "bold", fill: rgb("#e0e0e0"))[gauge-chart]
    #v(2pt)
    #grid(
      columns: (1fr, 1fr, 1fr),
      gauge-chart(sales.conversion-rate, size: 55pt, title: "Conversion", label: "rate", theme: gk),
      gauge-chart(sales.uptime, size: 55pt, title: "Uptime", label: "%", theme: gk),
      gauge-chart(sales.nps, size: 55pt, title: "NPS", label: "score", theme: gk),
    )
  ],

  // 16. progress-bar + circular-progress
  [
    #text(size: 8pt, weight: "bold", fill: rgb("#e0e0e0"))[progress-bar · circular-progress]
    #v(3pt)
    #progress-bar(sales.targets.values.at(0), width: 230pt, title: sales.targets.labels.at(0), theme: dk)
    #v(3pt)
    #grid(
      columns: (1fr, 1fr, 1fr),
      circular-progress(sales.targets.values.at(0), size: 50pt, title: sales.targets.labels.at(0), theme: dk),
      circular-progress(sales.targets.values.at(1), size: 50pt, title: sales.targets.labels.at(1), color: rgb("#ff6b6b"), theme: dk),
      circular-progress(sales.targets.values.at(2), size: 50pt, title: sales.targets.labels.at(2), color: rgb("#0be881"), theme: dk),
    )
  ],

  // ── page 3 ──

  // 17. ring-progress
  ring-progress(league.season-targets,
    size: 85pt, ring-width: 8pt, title: "ring-progress", theme: dk,
  ),

  // 18. dual-axis-chart
  dual-axis-chart(sales.dual-axis,
    width: W, height: Hs, title: "dual-axis-chart", theme: dk,
  ),

  // 19. histogram
  histogram(league.goals-per-match,
    width: W, height: Hs, title: "histogram", bins: 12, theme: dk,
  ),

  // 20. waterfall-chart
  waterfall-chart(sales.waterfall,
    width: W, height: Hs, title: "waterfall-chart", theme: dk,
  ),

  // 21. funnel-chart
  funnel-chart(sales.funnel,
    width: W, height: 110pt, title: "funnel-chart", theme: dk,
  ),

  // 22. box-plot
  box-plot(league.minutes-played,
    width: W, height: 110pt, title: "box-plot", show-grid: true, theme: dk,
  ),

  // 23. heatmap
  heatmap(sales.activity,
    cell-size: 22pt, title: "heatmap", palette: "viridis", theme: dk,
  ),

  // 24. correlation-matrix
  correlation-matrix(codebase.correlation,
    cell-size: 22pt, title: "correlation-matrix", theme: dk,
  ),

  // ── page 4 ──

  // 25. calendar-heatmap
  calendar-heatmap(sales.daily-deals,
    cell-size: 10pt, title: "calendar-heatmap", palette: "heat", theme: dk,
  ),

  // 26. progress-bars
  progress-bars(sales.targets,
    width: W, title: "progress-bars", theme: dk,
  ),

  // 27. sparklines
  [
    #text(size: 8pt, weight: "bold", fill: rgb("#e0e0e0"))[sparkline · sparkbar · sparkdot]
    #v(2pt)
    #table(
      columns: (auto, auto, auto, auto),
      align: (left, center, center, center),
      inset: 3pt,
      stroke: rgb("#333355"),
      fill: rgb("#1a1a2e"),
      [*Metric*], [*sparkline*], [*sparkbar*], [*sparkdot*],
      [Networking], [#sparkline(sales.sparklines.networking, color: rgb("#00d2ff"), width: 50pt, height: 12pt)], [#sparkbar(sales.sparklines.networking, color: rgb("#ff9f43"), width: 50pt, height: 12pt)], [#sparkdot(sales.sparklines.networking, color: rgb("#ff6b6b"), width: 50pt, height: 12pt)],
      [Memory], [#sparkline(sales.sparklines.memory, color: rgb("#00d2ff"), width: 50pt, height: 12pt)], [#sparkbar(sales.sparklines.memory, color: rgb("#ff9f43"), width: 50pt, height: 12pt)], [#sparkdot(sales.sparklines.memory, color: rgb("#0be881"), width: 50pt, height: 12pt)],
      [Storage], [#sparkline(sales.sparklines.storage, color: rgb("#00d2ff"), width: 50pt, height: 12pt)], [#sparkbar(sales.sparklines.storage, color: rgb("#ff9f43"), width: 50pt, height: 12pt)], [#sparkdot(sales.sparklines.storage, color: rgb("#0be881"), width: 50pt, height: 12pt)],
    )
  ],

  // 28. treemap
  treemap(sales.expenses,
    width: W, height: 110pt, title: "treemap", theme: dk,
  ),

  // 29. sankey-chart
  sankey-chart(sales.budget-flow,
    width: W, height: 110pt, title: "sankey-chart", show-labels: true, theme: dk,
  ),

  // 30. lollipop-chart
  lollipop-chart(codebase.subsystems,
    width: W, height: Hs, title: "lollipop-chart", theme: dk,
  ),

  // 31. horizontal-lollipop-chart
  horizontal-lollipop-chart(codebase.patches,
    width: W, height: Hs, title: "horizontal-lollipop-chart", theme: dk,
  ),

  // 32. diverging-bar-chart
  diverging-bar-chart(
    (..sales.satisfaction, left-label: "Detractors", right-label: "Promoters"),
    width: W, height: Hs, title: "diverging-bar-chart", theme: dk,
  ),

  // ── page 5 ──

  // 33. slope-chart
  slope-chart(
    (..sales.slope, start-label: "H1", end-label: "H2"),
    width: W, height: 105pt, title: "slope-chart", theme: dk,
  ),

  // 34. bullet-chart
  [
    #text(size: 8pt, weight: "bold", fill: rgb("#e0e0e0"))[bullet-chart]
    #v(2pt)
    #bullet-chart(sales.revenue-target.actual, sales.revenue-target.target, sales.revenue-target.ranges, width: 230pt, height: 22pt, title: "Revenue", theme: dk)
    #v(2pt)
    #bullet-chart(82, 90, (60, 80, 100), width: 230pt, height: 22pt, title: "Satisfaction", theme: dk)
    #v(2pt)
    #bullet-chart(45, 50, (25, 40, 60), width: 230pt, height: 22pt, title: "Customers", theme: dk)
  ],

  // 35. grouped-stacked-bar-chart
  grouped-stacked-bar-chart(sales.channels,
    width: W, height: H, title: "grouped-stacked-bar-chart", theme: dk,
  ),

  // 36. gantt-chart
  [
    #text(size: 8pt, weight: "bold", fill: rgb("#e0e0e0"))[gantt-chart]
    #v(2pt)
    #gantt-chart(sales.schedule,
      width: 230pt, bar-height: 10pt, gap: 2pt, today: 7, title: none, theme: dk,
    )
  ],

  // 37. waffle-chart
  waffle-chart(codebase.languages,
    size: 120pt, gap: 1pt, title: "waffle-chart", theme: dk,
  ),

  // 38. bump-chart
  bump-chart(codebase.rankings,
    width: W, height: 110pt, title: "bump-chart", dot-size: 4pt, theme: dk,
  ),

  // 39. dumbbell-chart
  dumbbell-chart(
    (..sales.dumbbell, start-label: "Q1", end-label: "Q4"),
    width: W, height: 110pt, title: "dumbbell-chart", show-values: true, theme: dk,
  ),

  // 40. radial-bar-chart
  radial-bar-chart(codebase.health,
    size: 120pt, title: "radial-bar-chart", show-labels: true, theme: dk,
  ),

  // ── page 6 ──

  // 41. sunburst-chart
  sunburst-chart(sales.org,
    size: 120pt, inner-radius: 20pt, ring-width: 25pt, title: "sunburst-chart", theme: dk,
  ),

  // 42. metric-card + metric-row
  [
    #text(size: 8pt, weight: "bold", fill: rgb("#e0e0e0"))[metric-card · metric-row]
    #v(3pt)
    #metric-row(sales.kpis,
      width: 250pt, gap: 5pt, theme: dk,
    )
  ],

  // 43. violin-plot
  violin-plot(league.ratings,
    width: W, height: 115pt, title: "violin-plot", theme: dk,
  ),

  // 44. timeline-chart
  timeline-chart(sales.milestones,
    width: W, event-gap: 45pt, title: "timeline-chart", theme: dk,
  ),

  // 45. parliament-chart
  parliament-chart(codebase.contributors,
    size: 130pt, dot-size: 3pt, title: "parliament-chart", theme: dk,
  ),

  // 46. chord-diagram
  chord-diagram(codebase.dependencies,
    size: 130pt, arc-width: 10pt, title: "chord-diagram", theme: dk,
  ),

))

// ── Page 7: Full-page word cloud ─────────────────────────────────────────────
#pagebreak()
#word-cloud(codebase.words,
  width: 100%, height: 100%, title: "word-cloud", shape: "circle", theme: dk,
)
