# GruMD

Minimal macOS Markdown reader & light editor.

Open a local `.md` file, edit it, preview common GFM, save. No vault, no plugins, no AI, no cloud.

![Platform](https://img.shields.io/badge/macOS-13%2B-blue)
![Arch](https://img.shields.io/badge/arch-arm64%20%7C%20x86__64%20%7C%20universal-lightgrey)
![License](https://img.shields.io/badge/license-MIT-green)

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

## Install (friends / daily use)

Pre-built apps live in [`releases/`](releases/):

| Package | Use when |
|---------|----------|
| [`releases/apple-silicon/GruMD.app`](releases/apple-silicon/) | M-series Mac |
| [`releases/intel/GruMD.app`](releases/intel/) | Intel Mac |
| [`releases/universal/GruMD.app`](releases/universal/) | Either (one binary for both) |
| [`releases/GruMD-1.0.0-universal.dmg`](releases/GruMD-1.0.0-universal.dmg) | Prefer a classic DMG installer |

1. Drag `GruMD.app` into **Applications**.  
2. First open may need **right-click → Open** (ad-hoc signature, no paid Developer ID).

Details: [releases/README.md](releases/README.md).

## Build from source

```bash
# Xcode 15+ recommended
open GruMD.xcodeproj

# Or command line (Release for arm64 + intel + universal + DMG)
./scripts/build_and_package.sh
```

Artifacts are written to `releases/`.

## Project layout

```
GruMD/
├── GruMD/                 # App sources & resources
│   ├── *.swift
│   ├── Resources/         # marked.min.js, preview.css
│   ├── Assets.xcassets/
│   ├── Info.plist
│   └── GruMD.entitlements
├── GruMD.xcodeproj/
├── scripts/
│   └── build_and_package.sh
├── releases/              # Install packages (.app + .dmg)
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
