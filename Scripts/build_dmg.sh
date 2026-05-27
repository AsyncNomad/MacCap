#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="MacCap"
DIST_DIR="${DIST_DIR:-$ROOT_DIR/Dist}"
APP_DIR="$DIST_DIR/$APP_NAME.app"
DMG_STAGING_DIR="$DIST_DIR/dmg-staging"
DMG_PATH="$DIST_DIR/$APP_NAME.dmg"
ZIP_PATH="$DIST_DIR/$APP_NAME.zip"
SIGNING_IDENTITY="${SIGNING_IDENTITY:-}"
NOTARY_PROFILE="${NOTARY_PROFILE:-}"

"$ROOT_DIR/Scripts/build_app.sh"

rm -rf "$DMG_STAGING_DIR" "$DMG_PATH" "$ZIP_PATH"
mkdir -p "$DMG_STAGING_DIR"
cp -R "$APP_DIR" "$DMG_STAGING_DIR/$APP_NAME.app"
ln -s /Applications "$DMG_STAGING_DIR/Applications"

hdiutil create \
  -volname "$APP_NAME" \
  -srcfolder "$DMG_STAGING_DIR" \
  -ov \
  -format UDZO \
  "$DMG_PATH"

if [[ -n "$SIGNING_IDENTITY" ]]; then
  ditto -c -k --keepParent "$APP_DIR" "$ZIP_PATH"
fi

if [[ -n "$NOTARY_PROFILE" ]]; then
  if [[ -z "$SIGNING_IDENTITY" ]]; then
    echo "NOTARY_PROFILE requires SIGNING_IDENTITY to be set." >&2
    exit 1
  fi

  xcrun notarytool submit "$ZIP_PATH" --keychain-profile "$NOTARY_PROFILE" --wait
  xcrun stapler staple "$APP_DIR"

  rm -rf "$DMG_STAGING_DIR" "$DMG_PATH"
  mkdir -p "$DMG_STAGING_DIR"
  cp -R "$APP_DIR" "$DMG_STAGING_DIR/$APP_NAME.app"
  ln -s /Applications "$DMG_STAGING_DIR/Applications"

  hdiutil create \
    -volname "$APP_NAME" \
    -srcfolder "$DMG_STAGING_DIR" \
    -ov \
    -format UDZO \
    "$DMG_PATH"
fi

echo "Built dmg at: $DMG_PATH"
