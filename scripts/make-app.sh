#!/bin/bash
# Builds Retone.app into dist/. Pass --install to also copy it to /Applications.
set -euo pipefail

cd "$(dirname "$0")/.."

swift build -c release

APP=dist/Retone.app
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp .build/release/Retone "$APP/Contents/MacOS/Retone"
cp Resources/Info.plist "$APP/Contents/Info.plist"
[[ -f Resources/AppIcon.icns ]] || scripts/make-icns.sh
cp Resources/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"
codesign --force --sign - "$APP"

echo "Built $APP"

if [[ "${1:-}" == "--install" ]]; then
    rm -rf /Applications/Retone.app
    cp -R "$APP" /Applications/Retone.app
    echo "Installed to /Applications/Retone.app"
fi
