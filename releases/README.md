# Local package output

This folder holds **locally built** DMGs from:

```bash
./scripts/build_and_package.sh
```

Files here are **not committed** to git. Users download from **GitHub Releases**:

**https://github.com/OWNER/GruMD/releases**

| File (example) | Architecture |
|----------------|--------------|
| `GruMD-1.0.0-apple-silicon.dmg` | arm64 |
| `GruMD-1.0.0-intel.dmg` | x86_64 |
| `GruMD-1.0.0-universal.dmg` | arm64 + x86_64 |

Publish:

```bash
./scripts/publish_release.sh 1.0.0
```
