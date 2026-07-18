#!/bin/bash
# Builds Refine.app into dist/. Pass --install to also copy it to /Applications.
set -euo pipefail

cd "$(dirname "$0")/.."

swift build -c release

APP=dist/Refine.app
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp .build/release/Refine "$APP/Contents/MacOS/Refine"
cp Resources/Info.plist "$APP/Contents/Info.plist"
[[ -f Resources/AppIcon.icns ]] || scripts/make-icns.sh
cp Resources/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"
codesign --force --sign - "$APP"

echo "Built $APP"

if [[ "${1:-}" == "--install" ]]; then
    rm -rf /Applications/Refine.app
    cp -R "$APP" /Applications/Refine.app
    echo "Installed to /Applications/Refine.app"
fi
