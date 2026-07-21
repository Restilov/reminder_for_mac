#!/bin/bash
# Builds the ReminderForMac.app bundle (no Xcode required).
set -euo pipefail
cd "$(dirname "$0")"

echo "🔨 Building..."
swift build -c release

APP="ReminderForMac.app"
BINARY=".build/release/ReminderForMac"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BINARY" "$APP/Contents/MacOS/ReminderForMac"

cat > "$APP/Contents/Info.plist" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleExecutable</key>
	<string>ReminderForMac</string>
	<key>CFBundleIdentifier</key>
	<string>com.resti.reminderformac</string>
	<key>CFBundleName</key>
	<string>ReminderForMac</string>
	<key>CFBundleDisplayName</key>
	<string>Reminder</string>
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
