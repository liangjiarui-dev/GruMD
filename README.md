# GruMD

Minimal macOS Markdown reader & light editor.

Open a local `.md` file, edit it, preview common GFM, save. No vault, no plugins, no AI, no cloud.

[![macOS 13+](https://img.shields.io/badge/macOS-13%2B-blue)](#requirements)
[![License: MIT](https://img.shields.io/badge/license-MIT-green)](LICENSE)

## Download

**→ [Get the latest release (v1.2.0)](https://github.com/liangjiarui-dev/GruMD/releases/latest)**

| Asset | Machine |
|-------|---------|
| `GruMD-*-apple-silicon.dmg` | Apple Silicon (M1 / M2 / M3 / M4 …) |
| `GruMD-*-intel.dmg` | Intel Mac |
| `GruMD-*-universal.dmg` | Either (one file for both) |

### Install

1. Open the DMG → drag **GruMD** into **Applications**.
2. First launch: if macOS warns about an unidentified developer, **right-click → Open → Open**.

## Features

- Open / edit / save local Markdown (Document-based app)
- Split layout: source + live GFM preview
- Layout switch: Split · Editor · Preview
- Optional reload when the file changes on disk
- System light / dark appearance
- Sandboxed, offline preview (bundled `marked.js`)

## Requirements

- macOS **13 Ventura** or later
- Apple Silicon **or** Intel

## Versions

| Version | What it is |
|---------|------------|
| **1.2.0** | **Current** — 1.1 UI + final Gru icon, clean icon set |
| 1.1.0 | Apple-style UI refresh |
| 1.0.0 | First release |
| 1.1.1 / 1.1.2 | Icon experiments only — use **1.2.0** instead |

Full notes: [CHANGELOG.md](CHANGELOG.md)

## Build from source

```bash
open GruMD.xcodeproj
# or:
./scripts/build_and_package.sh
```

Publish a version (needs `gh` logged in), or push a `v*` tag for GitHub Actions:

```bash
git tag v1.2.0 && git push origin v1.2.0
```

## Project layout

```
GruMD/
├── GruMD/                 # Sources & AppIcon assets
├── GruMD.xcodeproj/
├── scripts/
│   ├── build_and_package.sh
│   ├── publish_release.sh
│   └── set_github_owner.sh
├── docs/icons/            # Only classic + stockier Gru masters
├── releases/              # Local DMGs (gitignored)
├── CHANGELOG.md
└── README.md
```

## Privacy & security

- Local files only (App Sandbox)
- No network API, no telemetry
- See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)

## License

[MIT](LICENSE)
