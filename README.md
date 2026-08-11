# GruMD

Minimal macOS Markdown reader & light editor.

Open a local `.md` file, edit it, preview common GFM, save. No vault, no plugins, no AI, no cloud.

[![macOS 13+](https://img.shields.io/badge/macOS-13%2B-blue)](#requirements)
[![License: MIT](https://img.shields.io/badge/license-MIT-green)](LICENSE)

## Download

**→ [Get the latest release](https://github.com/liangjiarui-dev/GruMD/releases/latest)**

On the Releases page, pick the DMG that matches your Mac:

| Asset | Machine |
|-------|---------|
| `GruMD-*-apple-silicon.dmg` | Apple Silicon (M1 / M2 / M3 / M4 …) |
| `GruMD-*-intel.dmg` | Intel Mac |
| `GruMD-*-universal.dmg` | Either (one file for both) |

### Install

1. Open the DMG → drag **GruMD** into **Applications**.
2. First launch: if macOS warns about an unidentified developer, **right-click → Open → Open**.  
   (Builds are ad-hoc signed unless you notarize with a paid Apple Developer ID.)

> **Note for maintainers:** replace `OWNER` in the download link with your GitHub username after creating the repo (or run `./scripts/set_github_owner.sh yourname`).

## Features

- Open / edit / save local Markdown (Document-based app)
- Split layout: source + live GFM preview (tables, task lists, code, local images)
- Layout switch: Split · Editor · Preview
- Optional reload when the file changes on disk
- System light / dark appearance
- Sandboxed, offline preview (bundled `marked.js`)

## Requirements

- macOS **13 Ventura** or later
- Apple Silicon **or** Intel

## Build from source

```bash
open GruMD.xcodeproj
# or package DMGs locally:
./scripts/build_and_package.sh
```

Local DMGs land in `releases/` (gitignored). To publish them on GitHub:

```bash
# needs: git remote + GitHub CLI (gh) logged in
./scripts/publish_release.sh 1.0.0
```

## Project layout

```
GruMD/
├── GruMD/                    # App sources & resources
├── GruMD.xcodeproj/
├── scripts/
│   ├── build_and_package.sh  # → local releases/*.dmg
│   ├── publish_release.sh    # → GitHub Releases assets
│   └── set_github_owner.sh   # fix README download links
├── releases/                 # local DMG output only (not committed)
├── LICENSE
├── THIRD_PARTY_NOTICES.md
└── README.md
```

## Privacy & security

- Local files only (App Sandbox + user-selected file access)
- No network API, no telemetry
- External links in preview open in the system browser
- Dependencies: see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)

## License

[MIT](LICENSE)
