#!/bin/bash
# Local Apple Silicon build for h.coffee's Artisan modification.
# Set VENV to a Python 3.14 environment with src/requirements.txt installed.
# Set SIGNING_IDENTITY to a Developer ID Application identity for distribution;
# otherwise the build receives an ad-hoc signature and cannot be notarized.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VENV="${VENV:?Set VENV to the Python 3.14 virtual environment}"
OUTPUT_DIR="${OUTPUT_DIR:-$ROOT/dist-hcoffee}"
SOURCE_STATUS="$(git -C "$ROOT" status --porcelain --untracked-files=normal)"
if [[ -n "$SOURCE_STATUS" && "${REQUIRE_CLEAN_SOURCE:-0}" == 1 ]]; then
  echo 'Distribution builds require a clean Git working tree.' >&2
  exit 1
fi

# shellcheck source=/dev/null
source "$VENV/bin/activate"
export MACOSX_DEPLOYMENT_TARGET=13.0
export QT_PATH="$(python -c 'import PyQt6, pathlib; print(pathlib.Path(PyQt6.__file__).parent / "Qt6")')"
mkdir -p "$OUTPUT_DIR"
cd "$ROOT/src"
./build-derived.sh macos

SPEC=artisan-mac-hcoffee-arm64.spec
trap 'rm -f "$SPEC"' EXIT
python - <<'PY'
from pathlib import Path
source = Path('artisan-mac.spec').read_text()
assert "target_arch='x86_64'" in source
assert "'LSArchitecturePriority': ['x86_64']" in source
source = source.replace("target_arch='x86_64'", "target_arch='arm64'")
source = source.replace("'LSArchitecturePriority': ['x86_64']", "'LSArchitecturePriority': ['arm64']")
Path('artisan-mac-hcoffee-arm64.spec').write_text(source)
PY
python -m PyInstaller --clean --noconfirm "$SPEC"
APP=dist/artisan.app
test "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$APP/Contents/Info.plist")" = 'jp.hatte.artisan'
test -f "$APP/Contents/Resources/LICENSE-AGPL-3.0.txt"
test -f "$APP/Contents/Resources/DISTRIBUTION-NOTICE.txt"
test -f "$ROOT/distribution/third-party-python/INVENTORY.csv"
test -f "$ROOT/distribution/PYTHON-LICENSE.txt"
test -f "$ROOT/distribution/asset-licenses/README.md"
test -f "$ROOT/distribution/native-licenses/README.md"
cp -R "$ROOT/distribution/third-party-python" "$APP/Contents/Resources/THIRD-PARTY-LICENSES"
cp "$ROOT/distribution/PYTHON-LICENSE.txt" "$APP/Contents/Resources/THIRD-PARTY-LICENSES/PYTHON-LICENSE.txt"
cp -R "$ROOT/distribution/asset-licenses" "$APP/Contents/Resources/THIRD-PARTY-LICENSES/assets"
cp -R "$ROOT/distribution/native-licenses" "$APP/Contents/Resources/THIRD-PARTY-LICENSES/native"
{
  printf 'Source commit: %s\n' "$(git -C "$ROOT" rev-parse HEAD)"
  printf 'Uncommitted source changes: %s\n' "$([[ -n "$SOURCE_STATUS" ]] && echo yes || echo no)"
  printf 'Build UTC: %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  printf 'Build definition: .ci/build-hcoffee-mac-arm64.sh\n'
} > "$APP/Contents/Resources/BUILD-SOURCE.txt"
if [[ -n "${SIGNING_IDENTITY:-}" ]]; then
  codesign --force --deep --options runtime --timestamp \
    --entitlements "$ROOT/src/Artisan.entitlements" --sign "$SIGNING_IDENTITY" "$APP"
else
  codesign --force --deep --entitlements "$ROOT/src/Artisan.entitlements" --sign - "$APP"
fi
codesign --verify --deep --strict "$APP"
codesign -d --entitlements - "$APP" | grep -q 'com.apple.security.cs.allow-unsigned-executable-memory'
file "$APP/Contents/MacOS/artisan"
ditto -c -k --sequesterRsrc --keepParent "$APP" "$OUTPUT_DIR/Artisan-hcoffee-mac-arm64-test.zip"
unzip -t "$OUTPUT_DIR/Artisan-hcoffee-mac-arm64-test.zip" | tail -1
shasum -a 256 "$OUTPUT_DIR/Artisan-hcoffee-mac-arm64-test.zip"
