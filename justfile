# primaviz development commands

# Default: show available recipes
default:
    @just --list

# Compile the demo
demo:
    typst compile --root . examples/demo.typ

# Compile the showcase
showcase:
    typst compile --root . examples/showcase.typ

# Compile all per-chart demos
demos:
    #!/usr/bin/env bash
    for f in examples/demos/demo-*.typ; do
        typst compile --root . "$f" || exit 1
    done
    echo "Compiled $(ls examples/demos/demo-*.typ | wc -l) demos"

# Watch demo for live reload
watch:
    typst watch --root . examples/demo.typ

# Watch showcase for live reload
watch-showcase:
    typst watch --root . examples/showcase.typ

# Watch a specific per-chart demo (e.g., just watch-demo bar)
watch-demo name:
    typst watch --root . examples/demos/demo-{{name}}.typ

# Run all compilation tests
test:
    typst compile --root . tests/test-all.typ

# Regenerate all screenshots from demos and showcase
screenshots:
    #!/usr/bin/env bash
    mkdir -p screenshots/demo screenshots/showcase
    for f in examples/demos/demo-*.typ; do
        base=$(basename "$f" .typ)
        typst compile --root . "$f" "screenshots/demo/${base}.png" || exit 1
    done
    typst compile --root . examples/showcase.typ "screenshots/showcase/page-{0p}.png"
    optipng -o2 -quiet screenshots/demo/*.png screenshots/showcase/*.png || echo "optipng not found, skipping optimization"
    echo "Generated $(ls screenshots/demo/*.png screenshots/showcase/*.png | wc -l) screenshots"

# Compile demo + demos + showcase + tests (full CI check)
check: demo demos showcase test
    @echo "All compilations passed"

# Open the demo PDF
open: demo
    xdg-open examples/demo.pdf 2>/dev/null || open examples/demo.pdf

# Watch and open demo
dev:
    typst watch --root . examples/demo.typ &
    sleep 1
    xdg-open examples/demo.pdf 2>/dev/null || open examples/demo.pdf

# Clean generated artifacts
clean:
    rm -f examples/*.pdf examples/demos/*.pdf tests/*.pdf

# Full release prep: test, screenshots, clean build artifacts
release: check screenshots
    @echo "Release artifacts ready"

# Show project stats
stats:
    @echo "Chart modules:    $(ls src/charts/*.typ | wc -l)"
    @echo "Primitive modules: $(ls src/primitives/*.typ | wc -l)"
    @echo "Total .typ files:  $(find src/ -name '*.typ' | wc -l)"
    @echo "Demo files:        $(ls examples/demos/demo-*.typ | wc -l)"
    @echo "Screenshots:       $(ls screenshots/demo/*.png screenshots/showcase/*.png 2>/dev/null | wc -l)"
