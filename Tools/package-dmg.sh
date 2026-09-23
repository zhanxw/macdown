#!/bin/bash
# Package an already built app with a drag-to-Applications shortcut.
set -euo pipefail
cd "$(dirname "$0")/.."

app="${1:-Build/Build/Products/Release/MacDown.app}"
dmg="${2:-Build/DMG/MacDown-universal.dmg}"
if [[ ! -d "$app" || ! -f "$app/Contents/MacOS/MacDown" ]]; then
    echo "App not found: $app. Build MacDown before packaging it." >&2
    exit 1
fi
codesign --verify --deep --strict "$app"
mkdir -p "$(dirname "$dmg")"
staging=$(mktemp -d "${TMPDIR:-/tmp}/macdown-dmg.XXXXXX")
trap 'rm -rf "$staging"' EXIT

ditto "$app" "$staging/MacDown.app"
ln -s /Applications "$staging/Applications"
hdiutil create -volname MacDown -srcfolder "$staging" \
    -format UDZO -fs HFS+ -ov "$dmg"
hdiutil verify "$dmg"
(
    cd "$(dirname "$dmg")"
    shasum -a 256 "$(basename "$dmg")" > "$(basename "$dmg").sha256"
)
printf '\nCreated %s\n' "$dmg"
