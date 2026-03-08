// test-data.typ — Tests for data loader functions

#import "../src/lib.typ": *

#set page(margin: 0.5cm)

= Data Loaders

== load-simple

// Dict input: key-value pairs
#let d1 = load-simple(("Jan": 300, "Feb": 303))
#assert("labels" in d1 and "values" in d1)
#assert(d1.values.len() == 2)

// Already-shaped passthrough
#let d2 = load-simple((labels: ("A", "B"), values: (10, 20)))
#assert(d2.labels == ("A", "B"))
#assert(d2.values == (10, 20))

// Array of pairs
#let d3 = load-simple((("Jan", 300), ("Feb", 303)))
#assert(d3.labels == ("Jan", "Feb"))
#assert(d3.values == (300, 303))

// Array of objects with "label" + "value" keys
#let d4 = load-simple(((label: "Jan", value: 300), (label: "Feb", value: 303)))
#assert(d4.labels == ("Jan", "Feb"))
#assert(d4.values == (300, 303))

// Array of objects with "name" + "value" keys
#let d5 = load-simple(((name: "X", value: 10), (name: "Y", value: 20)))
#assert(d5.labels == ("X", "Y"))
#assert(d5.values == (10, 20))

// Plain array of values — numeric labels
#let d6 = load-simple((5, 10, 15))
#assert(d6.labels == ("0", "1", "2"))
#assert(d6.values == (5, 10, 15))

// Empty array
#let d7 = load-simple(())
#assert(d7.labels == ())
#assert(d7.values == ())

// Render one to verify it works end-to-end with a chart
#bar-chart(load-simple(("A": 10, "B": 20, "C": 15)), title: "load-simple → bar-chart")

#pagebreak()

== load-series

// Dict of dicts
#let s1 = load-series(("Q1": ("A": 10, "B": 20), "Q2": ("A": 15, "B": 25)))
#assert("labels" in s1 and "series" in s1)
#assert(s1.series.len() == 2)
#assert(s1.series.at(0).name == "A" or s1.series.at(0).name == "B")

// Already-shaped passthrough
#let s2 = load-series((
  labels: ("A", "B"),
  series: ((name: "X", values: (10, 20)),),
))
#assert(s2.labels == ("A", "B"))

// Array of objects
#let s3 = load-series(((period: "Q1", A: 10, B: 20), (period: "Q2", A: 15, B: 25)), label-key: "period")
#assert(s3.labels == ("Q1", "Q2"))
#assert(s3.series.len() == 2)

// Empty array
#let s4 = load-series(())
#assert(s4.labels == ())

// Render
#grouped-bar-chart(
  load-series(("Q1": ("A": 10, "B": 20), "Q2": ("A": 15, "B": 25))),
  title: "load-series → grouped-bar-chart",
)

#pagebreak()

== load-scatter

// Dict passthrough
#let sc1 = load-scatter((x: (1, 2, 3), y: (10, 20, 15)))
#assert(sc1.x == (1, 2, 3))
#assert(sc1.y == (10, 20, 15))

// Array of objects
#let sc2 = load-scatter(((x: 1, y: 2), (x: 3, y: 4)))
#assert(sc2.x == (1, 3))
#assert(sc2.y == (2, 4))

// Array of objects with labels
#let sc3 = load-scatter(((x: 1, y: 2, label: "A"), (x: 3, y: 4, label: "B")))
#assert("labels" in sc3)
#assert(sc3.labels == ("A", "B"))

// Array of pairs
#let sc4 = load-scatter(((1, 2), (3, 4)))
#assert(sc4.x == (1, 3))
#assert(sc4.y == (2, 4))

// Array of triples (with labels)
#let sc5 = load-scatter(((1, 2, "P"), (3, 4, "Q")))
#assert("labels" in sc5)

// Empty array
#let sc6 = load-scatter(())
#assert(sc6.x == ())

// Render
#scatter-plot(load-scatter(((x: 1, y: 10), (x: 2, y: 20), (x: 3, y: 15))), title: "load-scatter → scatter-plot")

#pagebreak()

== load-bubble

// Dict passthrough
#let b1 = load-bubble((x: (1, 2), y: (10, 20), size: (5, 8)))
#assert(b1.x == (1, 2))
#assert(b1.size == (5, 8))

// Array of objects
#let b2 = load-bubble(((x: 1, y: 2, size: 5), (x: 3, y: 4, size: 8)))
#assert(b2.x == (1, 3))
#assert(b2.size == (5, 8))

// Array of objects with labels
#let b3 = load-bubble(((x: 1, y: 2, size: 5, label: "A"), (x: 3, y: 4, size: 8, label: "B")))
#assert("labels" in b3)
#assert(b3.labels == ("A", "B"))

// Array of triples
#let b4 = load-bubble(((1, 2, 5), (3, 4, 8)))
#assert(b4.x == (1, 3))
#assert(b4.size == (5, 8))

// Empty array
#let b5 = load-bubble(())
#assert(b5.x == () and b5.y == () and b5.size == ())

#pagebreak()

== load-hierarchy

// Already-shaped dict passthrough
#let h1 = load-hierarchy((name: "root", value: 100, children: ((name: "A", value: 60), (name: "B", value: 40))))
#assert(h1.name == "root")
#assert(h1.value == 100)
#assert(h1.children.len() == 2)

// Flat array with parent references
#let h2 = load-hierarchy((
  (name: "root", value: 100, parent: none),
  (name: "A", value: 60, parent: "root"),
  (name: "B", value: 40, parent: "root"),
))
#assert(h2.name == "root")
#assert(h2.children.len() == 2)

// Flat array with deeper nesting
#let h3 = load-hierarchy((
  (name: "root", value: 100, parent: none),
  (name: "child", value: 50, parent: "root"),
  (name: "grandchild", value: 20, parent: "child"),
))
#assert(h3.name == "root")
#assert(h3.children.at(0).name == "child")
#assert(h3.children.at(0).children.at(0).name == "grandchild")

[All `load-*` assertions passed.]
