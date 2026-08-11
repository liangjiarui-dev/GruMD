# Install packages

Pre-built macOS apps for **GruMD 1.0.0**. Pick one folder (or the DMG).

| Path | Who should use it |
|------|-------------------|
| `apple-silicon/GruMD.app` | M1 / M2 / M3 / M4 Macs |
| `intel/GruMD.app` | Intel Macs |
| `universal/GruMD.app` | Works on both (slightly larger) |
| `GruMD-1.0.0-universal.dmg` | Drag-to-Applications installer (Universal) |

## Install

1. Open the matching folder (or the DMG).
2. Drag **GruMD.app** into **Applications**.
3. First launch: if macOS says the developer cannot be verified, **right-click → Open → Open**.

These builds are ad-hoc signed (no paid Apple Developer ID). That is normal for personal / friend distribution. See the root [README](../README.md).

## Rebuild from source

```bash
./scripts/build_and_package.sh
```

Outputs refresh this directory (`.app` + `.dmg` only — no zip).
