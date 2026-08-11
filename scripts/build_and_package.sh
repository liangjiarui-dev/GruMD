#!/usr/bin/env bash
# Build GruMD for Apple Silicon, Intel, and Universal.
# Outputs only .dmg installers under releases/ (gitignored; publish with publish_release.sh).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
RELEASES="$ROOT/releases"
TMP="$ROOT/.package-tmp"
PROJECT="$ROOT/GruMD.xcodeproj"
SCHEME="GruMD"
VERSION="1.3.7"

rm -rf "$TMP"
mkdir -p "$TMP" "$RELEASES"

# Path only on stdout; logs on stderr.
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

make_dmg() {
  local app_path="$1"
  local dmg_name="$2"
  local dmg_src="$TMP/dmg_${dmg_name}"
  local dmg_out="$RELEASES/${dmg_name}.dmg"

  rm -rf "$dmg_src"
  mkdir -p "$dmg_src"
  cp -R "$app_path" "$dmg_src/GruMD.app"
  ln -sf /Applications "$dmg_src/Applications"

  codesign --force --deep --sign - "$dmg_src/GruMD.app" 2>/dev/null || true

  echo "==> Creating ${dmg_name}.dmg..." >&2
  rm -f "$dmg_out"
  hdiutil create \
    -volname "GruMD" \
    -srcfolder "$dmg_src" \
    -ov -format UDZO \
    "$dmg_out" >/dev/null
}

ARM_APP="$(build_arch arm64)"
X86_APP="$(build_arch x86_64)"

# Universal binary
UNI_APP="$TMP/universal/GruMD.app"
mkdir -p "$TMP/universal"
cp -R "$ARM_APP" "$UNI_APP"
lipo -create \
  "$ARM_APP/Contents/MacOS/GruMD" \
  "$X86_APP/Contents/MacOS/GruMD" \
  -output "$UNI_APP/Contents/MacOS/GruMD"
codesign --force --deep --sign - "$UNI_APP" 2>/dev/null || true

echo "==> Cleaning old release products..."
rm -rf \
  "$RELEASES/apple-silicon" \
  "$RELEASES/intel" \
  "$RELEASES/universal"
rm -f "$RELEASES"/*.dmg

make_dmg "$ARM_APP" "GruMD-${VERSION}-apple-silicon"
make_dmg "$X86_APP" "GruMD-${VERSION}-intel"
make_dmg "$UNI_APP" "GruMD-${VERSION}-universal"

rm -rf "$TMP"

echo
echo "==> Architectures (from temp build — packages are DMG only)"
echo "  apple-silicon: arm64"
echo "  intel:         x86_64"
echo "  universal:     arm64 + x86_64"
echo
echo "==> Releases"
ls -lh "$RELEASES"/*.dmg
echo
echo "Done. DMG installers are under: $RELEASES"
