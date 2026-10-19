#!/bin/bash
# Build an Intel macOS test bundle from a clean h.coffee source checkout.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUTPUT_DIR="${OUTPUT_DIR:-$ROOT/dist-hcoffee}"
SOURCE_STATUS="$(git -C "$ROOT" status --porcelain --untracked-files=normal)"
if [[ -n "$SOURCE_STATUS" && "${REQUIRE_CLEAN_SOURCE:-0}" == 1 ]]; then
  echo 'Distribution builds require a clean Git working tree.' >&2
  exit 1
fi

if [[ -n "${VENV:-}" ]]; then
  # shellcheck source=/dev/null
  source "$VENV/bin/activate"
fi
test "$(uname -m)" = x86_64
test "$(python -c 'import platform; print(platform.machine())')" = x86_64
export MACOSX_DEPLOYMENT_TARGET=13.0
export QT_PATH="$(python -c 'import PyQt6, pathlib; print(pathlib.Path(PyQt6.__file__).parent / "Qt6")')"
mkdir -p "$OUTPUT_DIR"
cd "$ROOT/src"
./build-derived.sh macos
python -m PyInstaller --clean --noconfirm artisan-mac.spec
APP=dist/artisan.app
test "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$APP/Contents/Info.plist")" = jp.hatte.artisan
test -f "$APP/Contents/Resources/LICENSE-AGPL-3.0.txt"
test -f "$APP/Contents/Resources/DISTRIBUTION-NOTICE.txt"
file "$APP/Contents/MacOS/artisan" | grep -q x86_64

mkdir -p "$APP/Contents/Resources/THIRD-PARTY-LICENSES"
python "$ROOT/.ci/collect-hcoffee-python-licenses.py" "$APP/Contents/Resources/THIRD-PARTY-LICENSES/python"
cp "$ROOT/distribution/PYTHON-LICENSE.txt" "$APP/Contents/Resources/THIRD-PARTY-LICENSES/PYTHON-LICENSE.txt"
cp -R "$ROOT/distribution/asset-licenses" "$APP/Contents/Resources/THIRD-PARTY-LICENSES/assets"
cp -R "$ROOT/distribution/native-licenses" "$APP/Contents/Resources/THIRD-PARTY-LICENSES/native"
{
  printf 'Source commit: %s\n' "$(git -C "$ROOT" rev-parse HEAD)"
  printf 'Uncommitted source changes: %s\n' "$([[ -n "$SOURCE_STATUS" ]] && echo yes || echo no)"
  printf 'Build UTC: %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  printf 'Build definition: .ci/build-hcoffee-mac-intel.sh\n'
} > "$APP/Contents/Resources/BUILD-SOURCE.txt"

# CI has no Developer ID private key. Sign the downloaded bundle on the local
# signing Mac and notarize it only after inspecting the bundled dependencies.
codesign --force --deep --sign - "$APP"
codesign --verify --deep --strict "$APP"
ditto -c -k --sequesterRsrc --keepParent "$APP" "$OUTPUT_DIR/Artisan-hcoffee-mac-intel-test.zip"
unzip -t "$OUTPUT_DIR/Artisan-hcoffee-mac-intel-test.zip" | tail -1
shasum -a 256 "$OUTPUT_DIR/Artisan-hcoffee-mac-intel-test.zip"
