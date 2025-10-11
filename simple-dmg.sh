#!/bin/bash

# Simple DMG Creator - No hanging, fast execution
echo "📦 Creating Simple Mac DMG..."

APP_NAME="Esthetics Auto CashBook"
BUILD_DIR="dmg_build"

# Clean and create
rm -rf "$BUILD_DIR" *.dmg 2>/dev/null
mkdir -p "$BUILD_DIR/${APP_NAME}.app/Contents/MacOS"
mkdir -p "$BUILD_DIR/${APP_NAME}.app/Contents/Resources"

# Copy HTML
cp index.html "$BUILD_DIR/${APP_NAME}.app/Contents/Resources/"

# Create Info.plist
cat > "$BUILD_DIR/${APP_NAME}.app/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>launcher</string>
    <key>CFBundleIdentifier</key>
    <string>com.estheticsauto.cashbook</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
</dict>
</plist>
EOF

# Create simple launcher
cat > "$BUILD_DIR/${APP_NAME}.app/Contents/MacOS/launcher" << 'EOF'
#!/bin/bash
open "$(dirname "$0")/../Resources/index.html"
EOF

chmod +x "$BUILD_DIR/${APP_NAME}.app/Contents/MacOS/launcher"

# Create Applications link
ln -sf /Applications "$BUILD_DIR/"

# Create DMG quickly
hdiutil create -srcfolder "$BUILD_DIR" -volname "$APP_NAME" -format UDZO -o "Esthetics-CashBook.dmg"

# Cleanup
rm -rf "$BUILD_DIR"

echo "✅ DMG Created: Esthetics-CashBook.dmg"
ls -lh *.dmg