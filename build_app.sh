#!/bin/bash
# Builds the AlarmForMac.app bundle (no Xcode required).
set -euo pipefail
cd "$(dirname "$0")"

echo "🔨 Building..."
swift build -c release

APP="AlarmForMac.app"
BINARY=".build/release/AlarmForMac"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BINARY" "$APP/Contents/MacOS/AlarmForMac"

cat > "$APP/Contents/Info.plist" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleExecutable</key>
	<string>AlarmForMac</string>
	<key>CFBundleIdentifier</key>
	<string>com.resti.alarmformac</string>
	<key>CFBundleName</key>
	<string>AlarmForMac</string>
	<key>CFBundleDisplayName</key>
	<string>Alarm</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>LSMinimumSystemVersion</key>
	<string>14.0</string>
	<key>LSUIElement</key>
	<true/>
	<key>NSHighResolutionCapable</key>
	<true/>
</dict>
</plist>
EOF

codesign --force --sign - "$APP"

echo "✅ $APP is ready. To launch: open $APP"
