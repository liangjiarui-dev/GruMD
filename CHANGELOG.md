# Changelog

## [1.3.1] — 2026-08-11

### UI

- Layouts: **Split** and **Preview** only (removed Editor-only and Focus)
- Removed outline sidebar
- Find: magnifier toggles open/close; close also via the × control
- Larger default window size

## [1.3.0] — 2026-08-11

Better reading and writing — still a single-file local Markdown app.

### Features

- **Find / Replace** (⌘F / ⌥⌘F) with match count, next/previous, case toggle
- **Outline sidebar** for H1–H3 (⌘⌥O); click shows line number
- **Focus Preview** layout (⌘⇧F) — minimal chrome, large preview
- **Export HTML…** offline styled HTML (⌘⇧E)
- **Print…** system print panel for preview content (⌘P)
- **Recent files** on untitled welcome strip + Open…
- **Drag & drop images** into the editor → inserts `![](relative path)`
- **Typography settings**: mono/system editor font, preview max width & line height

### UI

- Layout control adds Focus mode
- Toolbar: outline, find, export/print menu
- Settings tabs: General / Editor / Preview

## [1.2.0] — 2026-08-11

Stable branding + cleanup.

- App icon: Q-version Gru with goggles + MD document
- Classic pure-document icon kept as alternate master
- Removed experimental icon variants from the repo

## [1.1.0] — 2026-08-11

### UI

- Apple-style chrome, layout control, file title capsule
- Editor / Preview pane headers
- Status bar (lines / words / characters)
- Grouped Settings, reader-style preview CSS

## [1.0.0] — 2026-08-11

Initial public release.

- Document-based open / edit / save
- Split · Editor · Preview
- Offline GFM preview
- External file reload
- DMG packages: Apple Silicon, Intel, Universal
