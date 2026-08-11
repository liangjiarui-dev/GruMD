#!/usr/bin/env bash
# Build DMGs and publish them as a GitHub Release.
# Prerequisites:
#   - git remote origin → GitHub repo
#   - GitHub CLI: https://cli.github.com  (brew install gh)
#   - gh auth login
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="${1:-}"
RELEASES="$ROOT/releases"

if [[ -z "$VERSION" ]]; then
  echo "Usage: $0 <version>" >&2
  echo "Example: $0 1.0.0" >&2
  exit 1
fi

# Strip leading v if present for filenames; tag always has v.
VERSION="${VERSION#v}"
TAG="v${VERSION}"

if ! command -v gh >/dev/null 2>&1; then
  echo "error: GitHub CLI (gh) not found. Install with: brew install gh" >&2
  exit 1
fi

if ! git -C "$ROOT" remote get-url origin >/dev/null 2>&1; then
  echo "error: no git remote 'origin'. Create a GitHub repo and:" >&2
  echo "  git remote add origin https://github.com/YOU/GruMD.git" >&2
  exit 1
fi

echo "==> Building packages for ${TAG}..."
# Keep VERSION in sync for filenames inside the build script
sed -i '' "s/^VERSION=.*/VERSION=\"${VERSION}\"/" "$ROOT/scripts/build_and_package.sh"
"$ROOT/scripts/build_and_package.sh"

ASSETS=(
  "$RELEASES/GruMD-${VERSION}-apple-silicon.dmg"
  "$RELEASES/GruMD-${VERSION}-intel.dmg"
  "$RELEASES/GruMD-${VERSION}-universal.dmg"
)

for f in "${ASSETS[@]}"; do
  if [[ ! -f "$f" ]]; then
    echo "error: missing asset $f" >&2
    exit 1
  fi
done

# Ensure working tree is clean enough to tag (optional soft check)
if ! git -C "$ROOT" diff --quiet || ! git -C "$ROOT" diff --cached --quiet; then
  echo "warning: you have uncommitted changes. Tagging current HEAD anyway." >&2
fi

if git -C "$ROOT" rev-parse "$TAG" >/dev/null 2>&1; then
  echo "error: tag $TAG already exists locally. Delete it or bump the version." >&2
  exit 1
fi

echo "==> Creating tag ${TAG}..."
git -C "$ROOT" tag -a "$TAG" -m "GruMD ${VERSION}"

echo "==> Pushing tag..."
git -C "$ROOT" push origin "$TAG"

NOTES="$(cat <<EOF
## GruMD ${VERSION}

Minimal macOS Markdown reader & light editor.

### Downloads

| File | Mac |
|------|-----|
| \`GruMD-${VERSION}-apple-silicon.dmg\` | Apple Silicon (M-series) |
| \`GruMD-${VERSION}-intel.dmg\` | Intel |
| \`GruMD-${VERSION}-universal.dmg\` | Universal (both) |

### Install

1. Open the DMG and drag **GruMD** to Applications.
2. If Gatekeeper blocks the app: right-click → **Open** → **Open**.
EOF
)"

echo "==> Creating GitHub Release ${TAG}..."
gh release create "$TAG" \
  "${ASSETS[@]}" \
  --title "GruMD ${VERSION}" \
  --notes "$NOTES"

echo
echo "Done."
echo "  Release page: $(gh browse --no-browser -R "$(gh repo view --json nameWithOwner -q .nameWithOwner)" 2>/dev/null || true)"
gh release view "$TAG" --web 2>/dev/null || \
  echo "  Open: https://github.com/$(gh repo view --json nameWithOwner -q .nameWithOwner)/releases/tag/${TAG}"
