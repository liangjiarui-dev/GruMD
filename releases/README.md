# Local package output

This folder holds **locally built** DMGs from:

```bash
./scripts/build_and_package.sh
```

Files here are **not committed** to git. Users download from **GitHub Releases**:

**https://github.com/liangjiarui-dev/GruMD/releases**

| File (example) | Architecture |
|----------------|--------------|
| `GruMD-1.2.0-apple-silicon.dmg` | arm64 |
| `GruMD-1.2.0-intel.dmg` | x86_64 |
| `GruMD-1.2.0-universal.dmg` | arm64 + x86_64 |

Publish (or push a `v*` tag to trigger GitHub Actions):

```bash
./scripts/publish_release.sh 1.2.0
# or: git tag v1.2.0 && git push origin v1.2.0
```
