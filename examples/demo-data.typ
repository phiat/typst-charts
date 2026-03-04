// demo-data.typ — Shared datasets for all demo and showcase charts
//
// Three themed datasets cover every chart data shape:
//   sales.*     — SaaS company metrics (bars, lines, funnels, gauges, flows)
//   codebase.*  — Open source project stats (lollipops, waffle, chord, word cloud)
//   league.*    — Soccer league data (radar, scatter, distributions, rankings)

// ── Sales: SaaS company ─────────────────────────────────────────────────────

#let sales = (
  // Simple: department metrics
  departments: (
    labels: ("Sales", "Eng", "Marketing", "Support", "Design", "Ops"),
    values: (4820, 3150, 8930, 2710, 2340, 1890),
  ),

  // Multi-series: quarterly revenue by product line
  quarterly: (
    labels: ("Q1", "Q2", "Q3", "Q4"),
    series: (
      (name: "Enterprise", values: (120, 150, 180, 210)),
      (name: "Growth", values: (80, 95, 110, 140)),
      (name: "Starter", values: (40, 45, 50, 55)),
    ),
  ),

  // Grouped-stacked: quarterly by product × channel
  channels: (
    labels: ("Q1", "Q2", "Q3", "Q4"),
    groups: (
      (name: "Enterprise", segments: (
        (name: "Online", values: (40, 50, 60, 70)),
        (name: "Retail", values: (30, 35, 40, 45)),
      )),
      (name: "Growth", segments: (
        (name: "Online", values: (55, 65, 75, 90)),
        (name: "Retail", values: (20, 25, 28, 35)),
      )),
    ),
  ),

  // Monthly trend (7 months)
  monthly: (
    labels: ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul"),
    values: (120, 135, 142, 158, 165, 182, 195),
  ),

  // Monthly multi-series
  monthly-series: (
    labels: ("Jan", "Feb", "Mar", "Apr", "May", "Jun"),
    series: (
      (name: "Revenue ($K)", values: (120, 150, 180, 165, 210, 240)),
      (name: "Costs ($K)", values: (80, 85, 95, 90, 100, 110)),
      (name: "Profit ($K)", values: (40, 65, 85, 75, 110, 130)),
    ),
  ),

  // Dual-axis: revenue + user growth (different scales)
  dual-axis: (
    labels: ("Jan", "Feb", "Mar", "Apr", "May", "Jun"),
    left: (name: "Revenue ($K)", values: (120, 150, 180, 165, 210, 240)),
    right: (name: "Users (K)", values: (1.2, 1.8, 2.1, 2.5, 3.0, 3.8)),
  ),

  // Funnel: sales pipeline
  funnel: (
    labels: ("Leads", "Qualified", "Demo", "Proposal", "Closed"),
    values: (1200, 800, 450, 280, 120),
  ),

  // Waterfall: P&L bridge
  waterfall: (
    labels: ("Start", "+Sales", "+Services", "-COGS", "-OpEx", "Total"),
    values: (1200, 350, 180, -280, -150, 1300),
  ),

  // Diverging: product satisfaction (negative = detractors, positive = promoters)
  satisfaction: (
    labels: ("Enterprise", "Growth", "Starter", "Free Tier"),
    left-values: (15, 30, 45, 60),
    right-values: (85, 70, 55, 40),
  ),

  // Slope: before/after comparison
  slope: (
    labels: ("Enterprise", "Growth", "Starter", "Free Tier"),
    start-values: (85, 70, 60, 45),
    end-values: (65, 90, 55, 80),
  ),

  // Dumbbell: Q1 vs Q4 performance
  dumbbell: (
    labels: ("Revenue", "Users", "NPS", "Uptime", "Latency"),
    start-values: (45, 60, 72, 88, 35),
    end-values: (78, 85, 68, 95, 22),
  ),

  // Budget flow (sankey)
  budget-flow: (
    nodes: ("Revenue", "Salaries", "R&D", "Marketing", "Infra", "Savings", "Growth Fund", "Reserve"),
    flows: (
      (from: 0, to: 1, value: 5000),
      (from: 0, to: 2, value: 2000),
      (from: 0, to: 3, value: 1500),
      (from: 0, to: 4, value: 800),
      (from: 2, to: 5, value: 1200),
      (from: 2, to: 6, value: 800),
      (from: 4, to: 7, value: 500),
    ),
  ),

  // Project schedule (gantt)
  schedule: (
    tasks: (
      (name: "Research", start: 0, end: 3, group: "Plan"),
      (name: "Design", start: 2, end: 5, group: "Plan"),
      (name: "Backend", start: 4, end: 9, group: "Build"),
      (name: "Frontend", start: 5, end: 10, group: "Build"),
      (name: "Testing", start: 8, end: 11, group: "QA"),
      (name: "Launch", start: 11, end: 13, group: "Ship"),
    ),
    time-labels: ("W1", "W2", "W3", "W4", "W5", "W6", "W7", "W8", "W9", "W10", "W11", "W12", "W13"),
  ),

  // Product milestones (timeline)
  milestones: (
    events: (
      (date: "Jan 2024", title: "Kickoff", description: "Project started"),
      (date: "Mar 2024", title: "Alpha", description: "Internal release"),
      (date: "Jun 2024", title: "Beta", description: "Public beta"),
      (date: "Sep 2024", title: "v1.0", description: "Stable release"),
    ),
  ),

  // Org hierarchy (sunburst/treemap)
  org: (
    name: "Company",
    children: (
      (name: "Eng", value: 40, children: (
        (name: "Backend", value: 25),
        (name: "Frontend", value: 15),
      )),
      (name: "Sales", value: 35, children: (
        (name: "Enterprise", value: 20),
        (name: "SMB", value: 15),
      )),
      (name: "Ops", value: 25),
    ),
  ),

  // Expense breakdown (treemap flat)
  expenses: (
    labels: ("Salaries", "Infra", "Marketing", "Office", "R&D", "Legal"),
    values: (1200, 800, 400, 300, 500, 250),
  ),

  // Weekly activity heatmap
  activity: (
    rows: ("Sales", "Eng", "Marketing", "Support"),
    cols: ("Mon", "Tue", "Wed", "Thu", "Fri"),
    values: (
      (82, 95, 78, 88, 65),
      (45, 52, 68, 71, 38),
      (33, 41, 55, 48, 29),
      (91, 87, 93, 85, 72),
    ),
  ),

  // Daily deals closed (calendar heatmap) — March 2024
  daily-deals: (
    dates: ("2024-03-01", "2024-03-02", "2024-03-03", "2024-03-04", "2024-03-05",
            "2024-03-06", "2024-03-07", "2024-03-08", "2024-03-09", "2024-03-10",
            "2024-03-11", "2024-03-12", "2024-03-13", "2024-03-14", "2024-03-15",
            "2024-03-16", "2024-03-17", "2024-03-18", "2024-03-19", "2024-03-20",
            "2024-03-21", "2024-03-22", "2024-03-23", "2024-03-24", "2024-03-25",
            "2024-03-26", "2024-03-27", "2024-03-28"),
    values: (12, 8, 3, 15, 22, 18, 5, 9, 14, 2, 20, 25, 11, 7, 16, 4, 1, 19, 23, 13, 10, 6, 17, 8, 21, 15, 12, 9),
  ),

  // KPI gauges
  conversion-rate: 78,
  uptime: 94,
  nps: 67,

  // Metric cards
  kpis: (
    (value: 12847, label: "Users", delta: 12.3, trend: (45, 52, 48, 61, 58, 72)),
    (value: 94.2, label: "Uptime", delta: 0.5, suffix: "%", trend: (91, 93, 92, 94, 93, 94)),
    (value: 342, label: "Issues", delta: -8.1, trend: (380, 365, 370, 355, 350, 342)),
  ),

  // Department targets (progress bars)
  targets: (
    labels: ("Sales", "Eng", "Marketing", "Support", "Design"),
    values: (87, 72, 65, 91, 58),
  ),

  // Bullet chart: revenue target
  revenue-target: (actual: 275, target: 250, ranges: (150, 225, 300)),

  // Sparkline trends (for inline tables)
  sparklines: (
    networking: (45, 52, 48, 61, 58, 72, 68),
    memory: (32, 28, 35, 31, 38, 42, 40),
    storage: (22, 25, 19, 28, 24, 30, 27),
  ),
)

// ── Codebase: open source project ───────────────────────────────────────────

#let codebase = (
  // Subsystem stats
  subsystems: (
    labels: ("net", "fs", "drivers", "mm", "arch", "kernel"),
    values: (4820, 3150, 8930, 2710, 2340, 1890),
  ),

  // Subsystem patches (horizontal)
  patches: (
    labels: ("drivers", "net", "fs", "arch", "sound", "crypto"),
    values: (312, 187, 145, 98, 67, 42),
  ),

  // Language proportions
  languages: (
    labels: ("Rust", "C", "Python", "Go", "Other"),
    values: (35, 28, 18, 12, 7),
  ),

  // Contributor categories (parliament)
  contributors: (
    labels: ("Core Team", "Regular", "Occasional", "Drive-by", "Bots"),
    values: (120, 95, 55, 25, 5),
  ),

  // Module hierarchy (sunburst)
  modules: (
    name: "src",
    children: (
      (name: "charts", value: 40, children: (
        (name: "bar", value: 15),
        (name: "line", value: 12),
        (name: "misc", value: 13),
      )),
      (name: "primitives", value: 35, children: (
        (name: "axes", value: 20),
        (name: "legend", value: 15),
      )),
      (name: "util", value: 25),
    ),
  ),

  // Module dependencies (chord)
  dependencies: (
    labels: ("charts", "primitives", "theme", "util", "validate"),
    matrix: (
      (0, 25, 15, 10, 5),
      (20, 0, 30, 8, 12),
      (5, 10, 0, 15, 3),
      (8, 5, 12, 0, 10),
      (15, 8, 5, 10, 0),
    ),
  ),

  // Contributor rankings over releases (bump)
  rankings: (
    labels: ("v0.1", "v0.2", "v0.3", "v0.4", "v0.5"),
    series: (
      (name: "Alice", values: (1, 2, 1, 3, 2)),
      (name: "Bob", values: (3, 1, 2, 1, 1)),
      (name: "Carol", values: (2, 3, 3, 2, 3)),
    ),
  ),

  // Subsystem health scores (radial bar)
  health: (
    labels: ("net", "fs", "drivers", "mm", "arch"),
    values: (85, 72, 95, 60, 78),
  ),

  // Commit activity (calendar heatmap) — reuse sales daily-deals shape
  // (demos can reference sales.daily-deals or define inline)

  // Subsystem correlation
  correlation: (
    labels: ("net", "fs", "mm", "drv", "arch"),
    values: (
      (1.0, 0.7, 0.3, 0.5, 0.2),
      (0.7, 1.0, 0.4, 0.6, 0.3),
      (0.3, 0.4, 1.0, 0.2, 0.8),
      (0.5, 0.6, 0.2, 1.0, 0.4),
      (0.2, 0.3, 0.8, 0.4, 1.0),
    ),
  ),

  // Word cloud: tech keywords
  words: (words: (
    (text: "Typst", weight: 10), (text: "Charts", weight: 9),
    (text: "Data", weight: 8), (text: "Visualization", weight: 8),
    (text: "Plots", weight: 7), (text: "Graphs", weight: 7),
    (text: "Dashboard", weight: 6), (text: "Analytics", weight: 6),
    (text: "Metrics", weight: 5), (text: "Reports", weight: 5),
    (text: "Trends", weight: 5), (text: "Insights", weight: 4),
    (text: "KPI", weight: 4), (text: "Pie", weight: 4),
    (text: "Scatter", weight: 4), (text: "Histogram", weight: 3),
    (text: "Radar", weight: 3), (text: "Heatmap", weight: 3),
    (text: "Funnel", weight: 3), (text: "Gantt", weight: 3),
    (text: "Treemap", weight: 3), (text: "Waterfall", weight: 3),
    (text: "Violin", weight: 2), (text: "Sankey", weight: 2),
    (text: "Chord", weight: 2), (text: "Sunburst", weight: 2),
    (text: "Timeline", weight: 2), (text: "Waffle", weight: 2),
    (text: "Donut", weight: 2), (text: "Bubble", weight: 2),
    (text: "Sparkline", weight: 2), (text: "Lollipop", weight: 2),
    (text: "Dumbbell", weight: 1), (text: "Bullet", weight: 1),
    (text: "Parliament", weight: 1), (text: "Slope", weight: 1),
    (text: "Ring", weight: 1), (text: "Diverging", weight: 1),
    (text: "Stacked", weight: 1), (text: "Grouped", weight: 1),
    (text: "Progress", weight: 1), (text: "Gauge", weight: 1),
    (text: "Calendar", weight: 1), (text: "Correlation", weight: 1),
    (text: "Bump", weight: 1), (text: "Radial", weight: 1),
  )),
)

// ── League: soccer/sports ───────────────────────────────────────────────────

#let league = (
  // Team standings
  standings: (
    labels: ("Arsenal", "Liverpool", "Man City", "Chelsea", "Spurs", "Newcastle"),
    values: (72, 68, 65, 58, 52, 48),
  ),

  // Player stats (radar) — multi-series
  player-stats: (
    labels: ("Pace", "Shooting", "Passing", "Dribbling", "Defense", "Physical"),
    series: (
      (name: "Striker", values: (88, 92, 75, 85, 35, 78)),
      (name: "Midfielder", values: (72, 68, 90, 82, 70, 75)),
      (name: "Defender", values: (65, 45, 60, 52, 92, 80)),
    ),
  ),

  // Team scatter: goals scored vs goals conceded
  team-scatter: (
    x: (68, 72, 65, 52, 48, 55),
    y: (28, 32, 30, 45, 50, 42),
    labels: ("Arsenal", "Liverpool", "Man City", "Chelsea", "Spurs", "Newcastle"),
  ),

  // Bubble: goals × possession × market value
  team-bubble: (
    x: (68, 72, 65, 52, 48),
    y: (58, 55, 62, 48, 45),
    size: (850, 720, 950, 580, 420),
    labels: ("Arsenal", "Liverpool", "Man City", "Chelsea", "Spurs"),
  ),

  // Multi-scatter: home vs away
  home-away: (
    series: (
      (name: "Home", points: ((38, 12), (40, 14), (35, 16), (28, 22), (25, 25))),
      (name: "Away", points: ((30, 16), (32, 18), (30, 14), (24, 23), (23, 25))),
    ),
  ),

  // Season rankings (bump)
  season-rankings: (
    labels: ("GW5", "GW10", "GW15", "GW20", "GW25"),
    series: (
      (name: "Arsenal", values: (2, 1, 1, 1, 1)),
      (name: "Liverpool", values: (1, 2, 2, 3, 2)),
      (name: "Man City", values: (3, 3, 3, 2, 3)),
    ),
  ),

  // Home vs away (dumbbell)
  home-vs-away: (
    labels: ("Arsenal", "Liverpool", "Man City", "Chelsea", "Spurs"),
    start-values: (42, 38, 36, 30, 28),
    end-values: (30, 30, 29, 28, 24),
  ),

  // Slope: start vs end of season
  season-slope: (
    labels: ("Arsenal", "Liverpool", "Man City", "Chelsea"),
    start-values: (3, 1, 2, 4),
    end-values: (1, 2, 3, 4),
  ),

  // Head-to-head (correlation matrix)
  head-to-head: (
    labels: ("Arsenal", "Liverpool", "Man City", "Chelsea", "Spurs"),
    values: (
      (1.0, 0.6, 0.4, 0.8, 0.9),
      (0.4, 1.0, 0.5, 0.7, 0.8),
      (0.6, 0.5, 1.0, 0.6, 0.7),
      (0.2, 0.3, 0.4, 1.0, 0.5),
      (0.1, 0.2, 0.3, 0.5, 1.0),
    ),
  ),

  // Goal distribution (histogram)
  goals-per-match: (2, 3, 3, 4, 4, 4, 5, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 9, 9, 10, 10, 11, 12, 14, 15, 18, 22, 25, 30, 35, 42, 55, 70, 95),

  // Minutes played (box-plot)
  minutes-played: (
    labels: ("Forwards", "Midfield", "Defense", "Keepers"),
    boxes: (
      (min: 15, q1: 45, median: 68, q3: 82, max: 90),
      (min: 20, q1: 55, median: 72, q3: 85, max: 90),
      (min: 30, q1: 60, median: 78, q3: 88, max: 90),
      (min: 45, q1: 75, median: 85, q3: 90, max: 90),
    ),
  ),

  // Player rating distributions (violin)
  ratings: (
    labels: ("Forwards", "Midfield", "Defense"),
    datasets: (
      (5, 8, 12, 15, 18, 22, 25, 28, 30, 32, 35, 38, 40, 42, 45, 48, 50, 52, 55, 58),
      (10, 15, 20, 22, 25, 28, 30, 32, 35, 38, 40, 42, 45, 48, 50, 55, 58, 60, 62, 65),
      (15, 18, 22, 25, 28, 30, 32, 35, 38, 40, 42, 45, 48, 50, 52, 55, 58, 60, 65, 70),
    ),
  ),

  // Season targets (ring progress)
  season-targets: (
    (name: "Wins", value: 24, max: 38),
    (name: "Goals", value: 68, max: 80),
    (name: "Clean Sheets", value: 12, max: 20),
  ),

  // Bullet: points target
  points-target: (actual: 72, target: 70, ranges: (40, 60, 80)),
)
