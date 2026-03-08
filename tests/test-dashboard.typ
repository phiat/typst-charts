// test-dashboard.typ — Tests for card() and compact-table() dashboard primitives

#import "../src/lib.typ": *
#import "data.typ": simple-data

#set page(margin: 0.5cm)

= Dashboard Module

== Card — default theme
#card(title: "Basic Card", desc: "Default styling")[
  This is card body content with the default theme.
]

== Card — no title
#card[Just body content, no title or description.]

== Card — dark theme
#with-theme(themes.dark)[
  #card(title: "Dark Card", desc: "Dark theme inherited")[
    Card body picks up dark background from with-theme.
  ]
]

== Card — compact theme
#with-theme(themes.compact)[
  #card(title: "Compact Card", desc: "Smaller fonts")[
    Compact theme gives tighter styling.
  ]
]

== Card — explicit theme override
#card(title: "Custom Theme", theme: themes.minimal)[
  Explicit theme override on the card itself.
]

#pagebreak()

== Compact Table — default
#compact-table(
  ("Name", "Value", "Status"),
  (
    ("Alpha", "100", "OK"),
    ("Beta", "200", "Warn"),
    ("Gamma", "300", "OK"),
    ("Delta", "400", "Error"),
  ),
)

== Compact Table — with highlight column
#compact-table(
  ("Month", "Revenue", "Costs", "Profit"),
  (
    ("Jan", "$1200", "$800", "$400"),
    ("Feb", "$1500", "$900", "$600"),
    ("Mar", "$1100", "$700", "$400"),
  ),
  highlight-col: 3,
)

== Compact Table — custom column widths
#compact-table(
  ("Item", "Qty", "Price"),
  (
    ("Widget A", "50", "$10.00"),
    ("Widget B", "120", "$7.50"),
  ),
  col-widths: (2fr, 1fr, 1fr),
)

== Compact Table — dark theme
#with-theme(themes.dark)[
  #compact-table(
    ("Key", "Value"),
    (
      ("API calls", "42,800"),
      ("Errors", "127"),
      ("Uptime", "99.97%"),
    ),
    highlight-col: 1,
  )
]

#pagebreak()

== Card + Table combined
#card(title: "Data Summary", desc: "Embedded table")[
  #compact-table(
    ("Category", "Count", "Pct"),
    (
      ("API", "1200", "45%"),
      ("Web", "800", "30%"),
      ("Mobile", "670", "25%"),
    ),
    highlight-col: 2,
  )
]

== Card + Chart combined
#with-theme(themes.compact)[
  #card(title: "Sales", desc: "Bar chart in card")[
    #bar-chart(simple-data, width: 100%, height: 80pt, show-values: false)
  ]
]

#pagebreak()

= Alert

== All variants — default theme
#alert(title: "Deployment complete")[Service updated to v2.4.1.]
#v(4pt)
#alert(title: "High memory usage", variant: "warning")[Node pool at 87%.]
#v(4pt)
#alert(title: "Request timeout", variant: "error")[Gateway exceeded 30s timeout.]
#v(4pt)
#alert(title: "All checks passing", variant: "success")[CI green for 14 builds.]

== Alerts — dark theme
#with-theme(themes.dark)[
  #alert(title: "Dark info")[Dark theme alert.]
  #v(4pt)
  #alert(title: "Dark error", variant: "error")[Error in dark mode.]
]

== Alert — no title
#alert[A simple alert with no title, just body text.]

= Badge

== All variants
#badge("Default") #h(3pt)
#badge("Secondary", variant: "secondary") #h(3pt)
#badge("Destructive", variant: "destructive") #h(3pt)
#badge("Outline", variant: "outline") #h(3pt)
#badge("Success", variant: "success")

== Badges — dark theme
#with-theme(themes.dark)[
  #badge("Dark") #h(3pt)
  #badge("Outline", variant: "outline") #h(3pt)
  #badge("Success", variant: "success")
]

= Separator

== Default
#separator()

== Dark theme
#with-theme(themes.dark)[
  #separator()
]

= Theme merge test

== Partial override inside with-theme preserves global
#with-theme(themes.dark)[
  // This should use dark background + grid enabled from the partial override
  #bar-chart(simple-data, width: 200pt, height: 100pt, title: "dark + grid", theme: (show-grid: true))
]
