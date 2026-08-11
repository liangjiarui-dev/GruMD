# Changelog

All notable changes to GruMD are documented here.

## [1.1.1] — 2026-08-11

### Branding

- New shipping app icon: Apple-style MD document with an abstract dual-lens accent (quiet nod to the Gru / Bob nickname vibe — not a character mascot)
- Previous 1.1 classic icon kept under `docs/icons/app-icon-1.1-classic-1024.png`
- Alternate chevron + yellow accent variant saved as `docs/icons/app-icon-chevron-gru-1024.png`

## [1.1.0] — 2026-08-11

Visual redesign and polish release. Functionally compatible with 1.0; package and tag are **v1.1.0**.

### UI

- Apple-style chrome: frosted top bar, continuous rounded layout control, file title capsule
- Pane headers for Editor / Preview
- Status bar with line / word / character counts (toggle in Settings)
- Accent color and refined spacing / typography
- Grouped Settings with typography sliders and About section
- Default window size tuned for split editing

### Preview

- Reader-style CSS (SF Pro rhythm, softer tables, code blocks, blockquotes)
- Improved light / dark contrast and selection colors

### Branding

- New app icon (indigo document + MD monogram)

### Other

- Theme tokens centralized in `Theme.swift`
- Welcome document refreshed for 1.1

## [1.0.0] — 2026-08-11

Initial public release.

- Document-based Markdown open / edit / save
- Split / Editor / Preview layouts
- Offline GFM preview (marked.js)
- External file reload
- DMG packages: Apple Silicon, Intel, Universal
