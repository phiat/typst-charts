#import "../src/theme.typ": *

#context {
  let t1 = _resolve-ctx((..themes.dark, base-size: 16pt, base-gap: 12pt))
  let t2 = _resolve-ctx(themes.dark)
  
  [t1 axis-label-size: #t1.axis-label-size \ ]
  [t2 axis-label-size: #t2.axis-label-size \ ]
  [t1 title-size: #t1.title-size \ ]
  [t2 title-size: #t2.title-size \ ]
  [t1 axis-padding-left: #t1.axis-padding-left \ ]
  [t2 axis-padding-left: #t2.axis-padding-left \ ]
  [t1 base-size: #t1.base-size \ ]
  [t2 base-size: #t2.base-size \ ]
}
