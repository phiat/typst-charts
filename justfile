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
        typst compile --root . "$f" "screenshots/demo/${base}-{0p}.png" || exit 1
    done
    typst compile --root . examples/showcase.typ "screenshots/showcase/showcase-{0p}.png"
    optipng -o2 -quiet screenshots/demo/*.png screenshots/showcase/*.png || echo "optipng not found, skipping optimization"
    echo "Generated $(ls screenshots/demo/*.png screenshots/showcase/*.png | wc -l) screenshots"

# Compile demo + demos + showcase + tests (full CI check)
check: demo demos showcase test
    @echo "All compilations passed"

# Full build: compile everything, regenerate screenshots
build: check screenshots
    @echo "Build complete — all artifacts up to date"

# Build everything, stage screenshots, commit if dirty, push
push: build
    #!/usr/bin/env bash
    set -e
    git add screenshots/
    if ! git diff --cached --quiet; then
        git commit -m "Regenerate screenshots"
    fi
    # Check only tracked files (build generates untracked PDFs)
    if git diff --name-only HEAD | grep -qv '\.pdf$'; then
        echo "ERROR: uncommitted tracked changes remain — commit before pushing"
        git diff --name-only HEAD | grep -v '\.pdf$'
        exit 1
    fi
    git push
    echo "Pushed $(git rev-parse --abbrev-ref HEAD) to origin"

# Open the demo PDF
open: demo
    xdg-open examples/demo.pdf 2>/dev/null || open examples/demo.pdf

# Watch and open demo
dev:
    typst watch --root . examples/demo.typ &
    sleep 1
    xdg-open examples/demo.pdf 2>/dev/null || open examples/demo.pdf

# Convert JSON data to chart-ready format (e.g., just convert data.json simple --pretty)
convert *args:
    python3 scripts/convert-data.py {{args}}

# Extract theme from CSS file (e.g., just extract-theme src/index.css --name shadcn)
extract-theme *args:
    uv run scripts/extract-theme.py {{args}}

# Extract theme from CSS file using Bun/TS (e.g., just extract-theme-ts src/index.css --name shadcn)
extract-theme-ts *args:
    bun run scripts/extract-theme.ts {{args}}

# Compile a single demo by name (e.g., just compile-demo pie)
compile-demo name:
    typst compile --root . examples/demos/demo-{{name}}.typ

# Diff screenshots against last commit (requires git)
diff-screenshots:
    @git diff --stat HEAD -- screenshots/ || echo "No screenshot changes"

# Clean generated artifacts
clean:
    rm -f examples/*.pdf examples/demos/*.pdf tests/*.pdf

# Clean screenshots too (for full regeneration)
clean-all: clean
    rm -f screenshots/demo/*.png screenshots/showcase/*.png

# Full release prep: build everything, verify clean
release: build
    @echo "Release artifacts ready"

# Show project stats
stats:
    @echo "Chart modules:    $(ls src/charts/*.typ | wc -l)"
    @echo "Primitive modules: $(ls src/primitives/*.typ | wc -l)"
    @echo "Total .typ files:  $(find src/ -name '*.typ' | wc -l)"
    @echo "Demo files:        $(ls examples/demos/demo-*.typ | wc -l)"
    @echo "Test files:        $(ls tests/test-*.typ | wc -l)"
    @echo "Screenshots:       $(ls screenshots/demo/*.png screenshots/showcase/*.png 2>/dev/null | wc -l)"
    @echo "Data files:        $(ls data/*.json 2>/dev/null | wc -l)"
    @echo "Scripts:           $(ls scripts/*.py scripts/*.ts 2>/dev/null | wc -l)"
