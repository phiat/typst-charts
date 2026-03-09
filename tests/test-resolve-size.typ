// test-resolve-size.typ — Tests for resolve-size clamping behavior

#import "../src/lib.typ": *

#set page(margin: 0.5cm)

= resolve-size

== Absolute values within available space

#layout(size => {
  let r = resolve-size(200pt, 150pt, size)
  // Should return the requested values (within available space)
  assert(type(r) == dictionary)
  assert("width" in r and "height" in r)
  assert(type(r.width) == length)
  assert(type(r.height) == length)
  [Absolute OK: #r.width × #r.height]
})

== Clamping in a constrained container

// Place resolve-size inside a small 100pt × 80pt box.
// Request 300pt × 250pt — should clamp to available minus container margin (2 × 8pt = 16pt).
#box(width: 100pt, height: 80pt, {
  layout(size => {
    let r = resolve-size(300pt, 250pt, size)
    // With container: true (default), margin is 16pt.
    // Clamped width should be 100pt - 16pt = 84pt
    // Clamped height should be 80pt - 16pt = 64pt
    assert(r.width == 84pt, message: "width should clamp to 84pt, got " + repr(r.width))
    assert(r.height == 64pt, message: "height should clamp to 64pt, got " + repr(r.height))
    [Clamped: #r.width × #r.height]
  })
})

== No container margin when container is false

#box(width: 100pt, height: 80pt, {
  layout(size => {
    let r = resolve-size(300pt, 250pt, size, container: false)
    // Without container margin, clamp to full available space
    assert(r.width == 100pt, message: "width should clamp to 100pt, got " + repr(r.width))
    assert(r.height == 80pt, message: "height should clamp to 80pt, got " + repr(r.height))
    [No-container clamped: #r.width × #r.height]
  })
})

== Ratio values

#box(width: 200pt, height: 100pt, {
  layout(size => {
    let r = resolve-size(50%, 50%, size)
    // 50% of 200pt = 100pt, 50% of 100pt = 50pt
    // Both within available minus margin, so no clamping
    assert(type(r.width) == length)
    assert(type(r.height) == length)
    [Ratio: #r.width × #r.height]
  })
})

== Small values are not clamped

#box(width: 200pt, height: 150pt, {
  layout(size => {
    let r = resolve-size(50pt, 40pt, size)
    // 50pt < 200pt - 16pt, so no clamping needed
    assert(r.width == 50pt, message: "small width should not be clamped")
    assert(r.height == 40pt, message: "small height should not be clamped")
    [Small: #r.width × #r.height]
  })
})

[All `resolve-size` assertions passed.]
