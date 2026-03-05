# Agent Instructions

## Project: Primaviz

Pure-Typst charting library — 50+ chart types, 6 theme presets, zero dependencies. Built on native Typst primitives (`rect`, `circle`, `line`, `polygon`, `place`).

- **Source:** `src/lib.typ` re-exports all charts, themes, and utilities
- **Charts:** `src/charts/*.typ` — one module per chart family (33 modules)
- **Primitives:** `src/primitives/*.typ` — axes, layout, legend, container, annotations, polar, title
- **Data loaders:** `src/data.typ` — `load-simple`, `load-series`, `load-scatter`, `load-bubble`, `load-hierarchy`
- **Examples:** `examples/demos/demo-*.typ` (19 per-chart demos), `examples/showcase.typ`, `examples/demo.typ`
- **Shared demo data:** `examples/demo-data.typ` — 5 themed datasets (sales, codebase, league, rpg, words) loaded from `data/*.json`
- **Tests:** `tests/test-all.typ`
- **Screenshots:** `screenshots/demo/*.png` + `screenshots/showcase/*.png`
- **Scripts:** `scripts/convert-data.py` — CLI JSON-to-chart-format converter
- **Dev commands:** `just build` (compile all + screenshots), `just push` (build + push), `just check`, `just demos`, `just showcase`, `just test`, `just convert`

## Visual Verification Rule

**After ANY change to chart code or primitives**, you MUST:
1. Run `just showcase` to compile
2. Render screenshots: `typst compile --root . examples/showcase.typ "screenshots/showcase/showcase-{0p}.png"`
3. Visually inspect each page for layout breakage — overlapping labels, legends clipping into adjacent cells, axis titles overlapping data
4. The showcase uses a tight 2-col × 4-row grid on A4 with small charts (250×95pt). Changes that look fine on large standalone charts can break the compact showcase layout. Always check both.

## Issue Tracking

This project uses **bd** (beads) for issue tracking. Run `bd onboard` to get started.

## Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --status in_progress  # Claim work
bd close <id>         # Complete work
bd sync               # Sync with git
```

## Landing the Plane (Session Completion)

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   bd sync
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds

## Publishing to Typst Packages Registry

Primaviz is published as `@preview/primaviz` on the [Typst packages registry](https://github.com/typst/packages).

### How it works
- The registry repo (`typst/packages`) has a directory per version: `packages/preview/primaviz/{version}/`
- Each version directory contains a full copy of the package source (everything not in `exclude` in `typst.toml`)
- Submit a PR adding `packages/preview/primaviz/{version}/` with the package files
- Once merged, users can `#import "@preview/primaviz:{version}": *`

### Release checklist
1. Bump version in `typst.toml`, `README.md`, `src/data.typ`
2. `just build` — verify everything compiles
3. Merge to main, tag (`git tag -a v{version}`), push tags
4. Create GitHub release (`gh release create v{version}`)
5. Fork/clone `typst/packages`, create branch `primaviz-{version}`
6. Copy package files into `packages/preview/primaviz/{version}/`
7. Open PR to `typst/packages` — title: `primaviz:{version}`
8. Close any older version PRs that haven't been merged

### What to include in the typst/packages directory
Everything in the repo EXCEPT what's listed in `typst.toml` `exclude`:
```
exclude = ["screenshots/*", ".beads/*", "examples/*", "data/*", "tests/*", "justfile", "AGENTS.md", "CLAUDE.md"]
```
So include: `src/`, `typst.toml`, `LICENSE`, `README.md`, `scripts/`

### Current state
- Published: 0.1.1
- Latest: 0.4.0 (tagged, released on GitHub)
- Typst packages PR: needs new PR for 0.4.0 (old 0.2.0 PR #4266 should be closed)

