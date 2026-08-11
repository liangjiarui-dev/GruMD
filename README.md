# GruMD

Minimal macOS Markdown reader & light editor.

Open a local `.md` file, edit it, preview common GFM, save. No vault, no plugins, no AI, no cloud.

[![macOS 13+](https://img.shields.io/badge/macOS-13%2B-blue)](#requirements)
[![License: MIT](https://img.shields.io/badge/license-MIT-green)](LICENSE)

## Download

**→ [Get the latest release](https://github.com/liangjiarui-dev/GruMD/releases/latest)**

| Asset | Machine |
|-------|---------|
| `GruMD-*-apple-silicon.dmg` | Apple Silicon |
| `GruMD-*-intel.dmg` | Intel Mac |
| `GruMD-*-universal.dmg` | Universal |

### Install

1. Open the DMG → drag **GruMD** into **Applications**.
2. First launch: if blocked, **right-click → Open → Open**.

## Features (1.3)

- Open / edit / save local Markdown
- Split · Editor · Preview · **Focus** layouts
- **Find / Replace**, **outline** (H1–H3)
- **Export HTML**, **Print**
- **Recent files** welcome strip; drag images to insert paths
- Offline GFM preview; optional disk reload
- Typography preferences (editor + preview)

## Requirements

- macOS **13 Ventura** or later
- Apple Silicon **or** Intel

## Versions

| Version | Notes |
|---------|--------|
| **1.3.1** | **Current** — Split/Preview only, find magnifier toggle, larger window |
| 1.3.0 | Find/replace, export, print, drag images, typography |
| 1.2.0 | Final Gru icon branding |
| 1.1.0 | Apple-style UI |
| 1.0.0 | First release |

See [CHANGELOG.md](CHANGELOG.md).

## Build

```bash
open GruMD.xcodeproj
./scripts/build_and_package.sh
# or: git tag v1.3.0 && git push origin v1.3.0
```

## License

[MIT](LICENSE)
