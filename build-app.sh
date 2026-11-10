#!/bin/bash
# Builds MenuPulse and wraps it in a .app bundle (needed for "Launch at login"
# and so the app has no Dock icon).
set -euo pipefail
cd "$(dirname "$0")"

# Keep a copy of everything printed, so build errors can be read back later.
exec > >(tee build.log) 2>&1

swift build -c release
BIN="$(swift build -c release --show-bin-path)/MenuPulse"
APP="build/MenuPulse.app"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN" "$APP/Contents/MacOS/MenuPulse"
cp Support/Info.plist "$APP/Contents/Info.plist"
codesign --force --sign - "$APP"

echo "Built $APP"
echo "Run it with: open $APP"
