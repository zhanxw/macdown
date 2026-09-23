#!/bin/bash
# Build a locally runnable app for the current Mac, without a signing account.
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ ! -f Pods/Manifest.lock || ! -d Dependency/prism/components ]]; then
    echo 'Dependencies are missing. Follow the Environment Setup in README.md.' >&2
    exit 1
fi

xcodebuild -workspace MacDown.xcworkspace -scheme MacDown \
    -configuration Release -destination "platform=macOS,arch=$(uname -m)" \
    -derivedDataPath Build ONLY_ACTIVE_ARCH=YES CODE_SIGN_IDENTITY=- \
    CODE_SIGNING_REQUIRED=YES build

app="$PWD/Build/Build/Products/Release/MacDown.app"
lipo -verify_arch "$(uname -m)" "$app/Contents/MacOS/MacDown"
codesign --verify --deep --strict "$app"
printf '\nBuilt app: %s\n' "$app"
