# Install packages

Pre-built **DMG** installers for **GruMD 1.0.0**. No loose `.app` folders — open a DMG and drag the app into Applications.

| File | Who should use it |
|------|-------------------|
| `GruMD-1.0.0-apple-silicon.dmg` | M1 / M2 / M3 / M4 Macs |
| `GruMD-1.0.0-intel.dmg` | Intel Macs |
| `GruMD-1.0.0-universal.dmg` | Works on both (slightly larger) |

## Install

1. Double-click the matching `.dmg`.
2. Drag **GruMD** into **Applications**.
3. Eject the disk image.
4. First launch: if macOS says the developer cannot be verified, **right-click → Open → Open**.

These builds are ad-hoc signed (no paid Apple Developer ID). That is normal for personal / friend distribution. See the root [README](../README.md).

## Rebuild from source

```bash
./scripts/build_and_package.sh
```

Outputs only `.dmg` files into this directory.
