// Rings & treemap: ring-progress light + dark, treemap light + dark
#import "../../src/lib.typ": *
#set page(margin: 0.5cm, paper: "a4")
#set text(size: 8pt)

#let lt = themes.default
#let dk = themes.dark
#let W = 250pt
#let H = 170pt

#page-grid(cols: 2, rows: 2, (
  ring-progress(
    (
      (name: "Move", value: 420, max: 500),
      (name: "Exercise", value: 28, max: 30),
      (name: "Stand", value: 10, max: 12),
    ),
    size: 130pt, ring-width: 12pt, title: "ring-progress (light)", theme: lt,
  ),
  ring-progress(
    (
      (name: "Move", value: 420, max: 500),
      (name: "Exercise", value: 28, max: 30),
      (name: "Stand", value: 10, max: 12),
    ),
    size: 130pt, ring-width: 12pt, title: "ring-progress (dark)", theme: dk,
  ),
  treemap(
    (labels: ("Rent", "Food", "Transport", "Fun", "Savings", "Health"),
     values: (1200, 800, 400, 300, 500, 250)),
    width: W, height: H, title: "treemap (light)", theme: lt,
  ),
  treemap(
    (labels: ("Rent", "Food", "Transport", "Fun", "Savings", "Health"),
     values: (1200, 800, 400, 300, 500, 250)),
    width: W, height: H, title: "treemap (dark)", theme: dk,
  ),
))
