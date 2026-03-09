#import "../src/lib.typ": *
#set page(margin: 0.5cm, paper: "a4")

#let sample = (labels: ("Jan", "Feb", "Mar", "Apr"), values: (120, 135, 142, 158))

#text(size: 12pt, weight: "bold")[0.5× scale]
#bar-chart(sample, width: 250pt, height: 150pt, title: "Revenue",
  y-label: "Value", x-label: "Month",
  theme: (base-size: 4pt, base-gap: 3pt, show-grid: true))

#v(10pt)
#text(size: 12pt, weight: "bold")[1× scale (default)]
#bar-chart(sample, width: 250pt, height: 150pt, title: "Revenue",
  y-label: "Value", x-label: "Month",
  theme: (base-size: 8pt, base-gap: 6pt, show-grid: true))

#v(10pt)
#text(size: 12pt, weight: "bold")[2× scale]
#bar-chart(sample, width: 250pt, height: 150pt, title: "Revenue",
  y-label: "Value", x-label: "Month",
  theme: (base-size: 16pt, base-gap: 12pt, show-grid: true))
