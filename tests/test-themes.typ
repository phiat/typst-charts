// test-themes.typ — All 6 themes × 4 representative charts

#import "../src/lib.typ": *
#import "data.typ": simple-data, scatter-data

#set page(margin: 0.5cm)

= Theme Presets

== themes.default
#bar-chart(simple-data, title: "default theme", theme: themes.default)

== themes.minimal
#bar-chart(simple-data, title: "minimal theme", theme: themes.minimal)

== themes.dark
#bar-chart(simple-data, title: "dark theme", theme: themes.dark)

== themes.presentation
#bar-chart(simple-data, title: "presentation theme", theme: themes.presentation)

== themes.print
#bar-chart(simple-data, title: "print theme", theme: themes.print)

== themes.accessible
#bar-chart(simple-data, title: "accessible theme", theme: themes.accessible)

== themes.compact
#bar-chart(simple-data, title: "compact theme", theme: themes.compact)

#pagebreak()

= Theme Matrix

#let theme-list = (
  ("default", themes.default),
  ("minimal", themes.minimal),
  ("dark", themes.dark),
  ("presentation", themes.presentation),
  ("print", themes.print),
  ("accessible", themes.accessible),
  ("compact", themes.compact),
)

#for (name, t) in theme-list {
  [== #name]
  grid(
    columns: (1fr, 1fr),
    column-gutter: 10pt,
    row-gutter: 10pt,
    bar-chart(simple-data, width: 200pt, height: 130pt, title: "bar", theme: t),
    line-chart(simple-data, width: 200pt, height: 130pt, title: "line", theme: t),
    pie-chart(simple-data, size: 100pt, title: "pie", theme: t),
    scatter-plot(scatter-data, width: 200pt, height: 130pt, title: "scatter", theme: t),
  )
}

#pagebreak()

= with-theme

== with-theme block
#with-theme(themes.dark)[
  #bar-chart(simple-data, width: 200pt, height: 130pt, title: "dark via with-theme")
  #line-chart(simple-data, width: 200pt, height: 130pt, title: "dark via with-theme")
]

== explicit override inside with-theme
#with-theme(themes.dark)[
  #bar-chart(simple-data, width: 200pt, height: 130pt, title: "minimal override", theme: themes.minimal)
]

== chart after with-theme uses default
#bar-chart(simple-data, width: 200pt, height: 130pt, title: "back to default")
