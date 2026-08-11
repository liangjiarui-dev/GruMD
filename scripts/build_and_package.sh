#!/usr/bin/env bash
# Build GruMD for Apple Silicon, Intel, and Universal.
# Outputs standard .app bundles + a Universal DMG under releases/ (no zip).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
RELEASES="$ROOT/releases"
TMP="$ROOT/.package-tmp"
PROJECT="$ROOT/GruMD.xcodeproj"
SCHEME="GruMD"
VERSION="1.0.0"

rm -rf "$TMP"
mkdir -p "$TMP" "$RELEASES"

# Echo path only on stdout; logs go to stderr so command substitution stays clean.
build_arch() {
  local target_arch="$1"
  local out="$TMP/${target_arch}"
  echo "==> Building ${target_arch}..." >&2
  xcodebuild \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration Release \
    -derivedDataPath "$out" \
    -arch "${target_arch}" \
    ONLY_ACTIVE_ARCH=YES \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_ALLOWED=YES \
    CODE_SIGNING_REQUIRED=NO \
    build >&2

  local app="$out/Build/Products/Release/GruMD.app"
  if [[ ! -d "$app" ]]; then
    app="$(find "$out" -name 'GruMD.app' -type d | head -1)"
  fi
  if [[ ! -d "$app" ]]; then
    echo "error: GruMD.app not found for ${target_arch}" >&2
    exit 1
  fi
  printf '%s\n' "$app"
}

ARM_APP="$(build_arch arm64)"
X86_APP="$(build_arch x86_64)"

echo "==> Staging releases..."
rm -rf \
  "$RELEASES/apple-silicon" \
  "$RELEASES/intel" \
  "$RELEASES/universal" \
  "$RELEASES/GruMD-${VERSION}-universal.dmg"

mkdir -p \
  "$RELEASES/apple-silicon" \
  "$RELEASES/intel" \
  "$RELEASES/universal"

cp -R "$ARM_APP" "$RELEASES/apple-silicon/GruMD.app"
cp -R "$X86_APP" "$RELEASES/intel/GruMD.app"

# Universal
cp -R "$ARM_APP" "$RELEASES/universal/GruMD.app"
lipo -create \
  "$ARM_APP/Contents/MacOS/GruMD" \
  "$X86_APP/Contents/MacOS/GruMD" \
  -output "$RELEASES/universal/GruMD.app/Contents/MacOS/GruMD"

for app in \
  "$RELEASES/apple-silicon/GruMD.app" \
  "$RELEASES/intel/GruMD.app" \
  "$RELEASES/universal/GruMD.app"; do
  codesign --force --deep --sign - "$app" 2>/dev/null || true
done

# DMG (Universal only)
echo "==> Creating DMG..."
DMG_SRC="$TMP/dmg_src"
mkdir -p "$DMG_SRC"
cp -R "$RELEASES/universal/GruMD.app" "$DMG_SRC/"
ln -sf /Applications "$DMG_SRC/Applications"
hdiutil create \
  -volname "GruMD" \
  -srcfolder "$DMG_SRC" \
  -ov -format UDZO \
  "$RELEASES/GruMD-${VERSION}-universal.dmg" >/dev/null

rm -rf "$TMP"

echo
echo "==> Architectures"
echo -n "  apple-silicon: "; lipo -info "$RELEASES/apple-silicon/GruMD.app/Contents/MacOS/GruMD"
echo -n "  intel:         "; lipo -info "$RELEASES/intel/GruMD.app/Contents/MacOS/GruMD"
echo -n "  universal:     "; lipo -info "$RELEASES/universal/GruMD.app/Contents/MacOS/GruMD"
echo
echo "==> Releases layout"
find "$RELEASES" \( -name 'GruMD.app' -o -name '*.dmg' -o -name 'README.md' \) | sort
du -sh "$RELEASES"/* 2>/dev/null || true
echo
echo "Done. Install packages are under: $RELEASES"
