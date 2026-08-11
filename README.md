# GruMD

Minimal macOS Markdown reader & light editor.

Open a local `.md` file, edit it, preview common GFM, save. No vault, no plugins, no AI, no cloud.

[![macOS 13+](https://img.shields.io/badge/macOS-13%2B-blue)](#requirements)
[![License: MIT](https://img.shields.io/badge/license-MIT-green)](LICENSE)

## Download

**→ [Latest release (v1.3.0)](https://github.com/liangjiarui-dev/GruMD/releases/latest)**

| Asset | Machine |
|-------|---------|
| `GruMD-*-apple-silicon.dmg` | Apple Silicon |
| `GruMD-*-intel.dmg` | Intel Mac |
| `GruMD-*-universal.dmg` | Universal |

### Install

1. Open the DMG → drag **GruMD** into **Applications**.
2. First launch: if blocked, **right-click → Open → Open**.

## Features

- Open / edit / save local Markdown (single file)
- **Preview** (default) and **Split** layouts
- Find / Replace (in Split), export HTML, print
- Drag images into the editor → `![](relative path)`
- Offline GFM preview; optional reload when the file changes on disk
- Typography preferences
- TextEdit-style launch (Open panel / open file — no home screen)

## Requirements

- macOS **13 Ventura** or later
- Apple Silicon **or** Intel

## Releases (kept)

| Version | Role |
|---------|------|
| **[1.3.0](https://github.com/liangjiarui-dev/GruMD/releases/tag/v1.3.0)** | **Current product** — usable daily build |
| [1.2.0](https://github.com/liangjiarui-dev/GruMD/releases/tag/v1.2.0) | Branding (final Gru icon) |
| [1.1.0](https://github.com/liangjiarui-dev/GruMD/releases/tag/v1.1.0) | Apple-style UI |
| [1.0.0](https://github.com/liangjiarui-dev/GruMD/releases/tag/v1.0.0) | First public release |

Intermediate 1.3.x experiment tags/releases were removed.

See [CHANGELOG.md](CHANGELOG.md).

## Build

```bash
open GruMD.xcodeproj
./scripts/build_and_package.sh
# release: git tag vX.Y.Z && git push origin vX.Y.Z
```

## License

[MIT](LICENSE)
