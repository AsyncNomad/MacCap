#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="MacCap"
CONFIGURATION="${CONFIGURATION:-release}"
DIST_DIR="${DIST_DIR:-$ROOT_DIR/Dist}"
APP_DIR="$DIST_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
INFO_TEMPLATE="$ROOT_DIR/Distribution/Info.plist"
INFO_PLIST="$CONTENTS_DIR/Info.plist"

BUNDLE_IDENTIFIER="${BUNDLE_IDENTIFIER:-com.lee.MacCap}"
MARKETING_VERSION="${MARKETING_VERSION:-1.0.0}"
BUILD_VERSION="${BUILD_VERSION:-1}"
SIGNING_IDENTITY="${SIGNING_IDENTITY:-}"
KEYCHAIN_PATH="${KEYCHAIN_PATH:-}"

export HOME="${HOME_OVERRIDE:-$ROOT_DIR}"
export SWIFTPM_MODULECACHE_OVERRIDE="${SWIFTPM_MODULECACHE_OVERRIDE:-$ROOT_DIR/.build/module-cache}"
export CLANG_MODULE_CACHE_PATH="${CLANG_MODULE_CACHE_PATH:-$ROOT_DIR/.build/clang-module-cache}"

mkdir -p "$DIST_DIR" "$SWIFTPM_MODULECACHE_OVERRIDE" "$CLANG_MODULE_CACHE_PATH"

swift build -c "$CONFIGURATION" --product "$APP_NAME"
BIN_PATH="$(swift build -c "$CONFIGURATION" --show-bin-path)/$APP_NAME"

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"
cp "$BIN_PATH" "$MACOS_DIR/$APP_NAME"
cp "$INFO_TEMPLATE" "$INFO_PLIST"

/usr/bin/sed -i '' "s/__BUNDLE_IDENTIFIER__/$BUNDLE_IDENTIFIER/g" "$INFO_PLIST"
/usr/bin/sed -i '' "s/__MARKETING_VERSION__/$MARKETING_VERSION/g" "$INFO_PLIST"
/usr/bin/sed -i '' "s/__BUILD_VERSION__/$BUILD_VERSION/g" "$INFO_PLIST"

chmod +x "$MACOS_DIR/$APP_NAME"

if [[ -n "$SIGNING_IDENTITY" ]]; then
  CODESIGN_ARGS=(
    --force
    --options runtime
    --timestamp
    --sign "$SIGNING_IDENTITY"
  )

  if [[ -n "$KEYCHAIN_PATH" ]]; then
    CODESIGN_ARGS+=(--keychain "$KEYCHAIN_PATH")
  fi

  codesign \
    "${CODESIGN_ARGS[@]}" \
    "$APP_DIR"
fi

echo "Built app bundle at: $APP_DIR"
