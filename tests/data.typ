// data.typ — Shared test data for all test modules

#let simple-data = (
  labels: ("Q1", "Q2", "Q3", "Q4", "Q5"),
  values: (12, 26, 15, 34, 22),
)

#let multi-data = (
  labels: ("Q1", "Q2", "Q3", "Q4", "Q5"),
  series: (
    (name: "North", values: (12, 26, 15, 34, 22)),
    (name: "South", values: (20, 14, 28, 18, 31)),
  ),
)

#let scatter-data = (x: (1, 2, 3), y: (10, 20, 15))

#let bubble-data = (x: (1, 2, 3), y: (10, 20, 15), size: (5, 10, 8))

#let heatmap-data = (
  rows: ("R1", "R2"),
  cols: ("C1", "C2"),
  values: ((1, 2), (3, 4)),
)

#let calendar-data = (
  dates: ("2024-01-01", "2024-01-02", "2024-01-03", "2024-01-04", "2024-01-05", "2024-01-06", "2024-01-07"),
  values: (1, 3, 0, 5, 2, 4, 1),
)

#let correlation-data = (
  labels: ("A", "B"),
  values: ((1.0, 0.5), (0.5, 1.0)),
)

#let radar-data = (
  labels: ("A", "B", "C", "D"),
  series: ((name: "S1", values: (5, 8, 6, 7)),),
)

#let multi-scatter-data = (
  series: (
    (name: "G1", points: ((1, 2), (3, 4))),
    (name: "G2", points: ((2, 3), (4, 5))),
  ),
)

#let multi-bubble-data = (
  series: (
    (name: "Group A", points: ((1, 10, 5), (2, 20, 10), (3, 15, 8))),
    (name: "Group B", points: ((1.5, 12, 12), (2.5, 18, 6), (3.5, 22, 15))),
  ),
)

#let spark-data = (4, 7, 2, 9, 5, 8, 3, 6, 1, 8)

#let histogram-data = (2.1, 3.5, 4.2, 4.8, 5.1, 5.3, 5.7, 6.0, 6.2, 6.5, 6.8, 7.1, 7.3, 7.5, 7.8, 8.0, 8.2, 8.5, 9.0, 9.5)
