#!/usr/bin/env bash
# Replace OWNER placeholder in docs with your GitHub username (or org).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OWNER="${1:-}"

if [[ -z "$OWNER" ]]; then
  echo "Usage: $0 <github-username-or-org>" >&2
  echo "Example: $0 alice" >&2
  exit 1
fi

# Only replace the placeholder OWNER in GitHub URLs / paths, not other words.
for f in "$ROOT/README.md" "$ROOT/releases/README.md"; do
  if [[ -f "$f" ]]; then
    # macOS sed
    sed -i '' "s|github.com/OWNER/GruMD|github.com/${OWNER}/GruMD|g" "$f"
    echo "Updated $f"
  fi
done

echo "Done. Download links now point to https://github.com/${OWNER}/GruMD/releases"
