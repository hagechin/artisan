#!/bin/bash
# Sign an already-built Intel bundle on a Mac with a Developer ID Application identity.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="${1:?Usage: SIGNING_IDENTITY='Developer ID Application: ...' sign-hcoffee-mac-intel.sh path/to/artisan.app}"
SIGNING_IDENTITY="${SIGNING_IDENTITY:?Set SIGNING_IDENTITY to a Developer ID Application identity}"
ENTITLEMENTS="$ROOT/src/Artisan.entitlements"

test -d "$APP"
test "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$APP/Contents/Info.plist")" = jp.hatte.artisan
file "$APP/Contents/MacOS/artisan" | grep -q x86_64
codesign --force --deep --options runtime --timestamp \
  --entitlements "$ENTITLEMENTS" --sign "$SIGNING_IDENTITY" "$APP"
codesign --verify --deep --strict --verbose=2 "$APP"
codesign -dv --verbose=4 "$APP" 2>&1 | grep -q 'Authority=Developer ID Application:'
codesign -dv --verbose=4 "$APP" 2>&1 | grep -q 'flags=.*runtime'
codesign -d --entitlements - "$APP" | grep -q 'com.apple.security.cs.allow-unsigned-executable-memory'
