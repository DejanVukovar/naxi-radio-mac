#!/bin/bash
set -e

cd "$(dirname "$0")"

echo "▶ Building Naxi Radio..."
swift build -c release 2>&1

echo "▶ Pravljenje ikone..."
swift make_icon.swift 2>/dev/null
iconutil -c icns AppIcon.iconset -o AppIcon.icns

BINARY=".build/release/NaxiRadio"
APP="NaxiRadio.app"
CONTENTS="$APP/Contents"

rm -rf "$APP"
mkdir -p "$CONTENTS/MacOS" "$CONTENTS/Resources"

cp "$BINARY" "$CONTENTS/MacOS/NaxiRadio"
cp Info.plist "$CONTENTS/Info.plist"
cp AppIcon.icns "$CONTENTS/Resources/AppIcon.icns"

echo ""
echo "✅ NaxiRadio.app je napravljen!"
echo ""
echo "Da instalirate: cp -r NaxiRadio.app /Applications/"
echo "Da pokrenete:   open NaxiRadio.app"
