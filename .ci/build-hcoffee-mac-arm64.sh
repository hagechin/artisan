#!/bin/bash
# Local Apple Silicon test build for h.coffee's Artisan modification.
# Set VENV to a Python 3.14 environment with src/requirements.txt installed.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VENV="${VENV:?Set VENV to the Python 3.14 virtual environment}"
OUTPUT_DIR="${OUTPUT_DIR:-$ROOT/dist-hcoffee}"

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
{
  printf 'Source commit: %s\n' "$(git -C "$ROOT" rev-parse HEAD)"
  printf 'Build UTC: %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  printf 'Build definition: .ci/build-hcoffee-mac-arm64.sh\n'
} > "$APP/Contents/Resources/BUILD-SOURCE.txt"
codesign --force --deep --sign - "$APP"
codesign --verify --deep --strict "$APP"
file "$APP/Contents/MacOS/artisan"
ditto -c -k --sequesterRsrc --keepParent "$APP" "$OUTPUT_DIR/Artisan-hcoffee-mac-arm64-test.zip"
unzip -t "$OUTPUT_DIR/Artisan-hcoffee-mac-arm64-test.zip" | tail -1
shasum -a 256 "$OUTPUT_DIR/Artisan-hcoffee-mac-arm64-test.zip"
