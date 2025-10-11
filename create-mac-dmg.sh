#!/bin/bash

# Esthetics Auto CashBook - Mac DMG Creator
# Creates a professional DMG installer for macOS

APP_NAME="Esthetics Auto CashBook"
VERSION="1.0.0"
DMG_NAME="Esthetics-Auto-CashBook-${VERSION}-Mac"

echo "🍎 Creating Mac DMG Installer..."
echo "================================"

# Clean previous builds
rm -rf build_mac *.dmg 2>/dev/null

# Create build directory
BUILD_DIR="build_mac"
APP_DIR="${BUILD_DIR}/${APP_NAME}.app"

echo "📁 Creating Mac app bundle..."
mkdir -p "${APP_DIR}/Contents/MacOS"
mkdir -p "${APP_DIR}/Contents/Resources"

# Copy main application file
cp index.html "${APP_DIR}/Contents/Resources/"

echo "📝 Creating app bundle configuration..."

# Create Info.plist
cat > "${APP_DIR}/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>CashBookLauncher</string>
    <key>CFBundleIdentifier</key>
    <string>com.estheticsauto.cashbook</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleDisplayName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleVersion</key>
    <string>${VERSION}</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
    <key>LSMinimumSystemVersion</key>
    <string>10.12</string>
</dict>
</plist>
EOF

echo "🚀 Creating launcher executable..."

# Create launcher script
cat > "${APP_DIR}/Contents/MacOS/CashBookLauncher" << 'EOF'
#!/bin/bash
# Esthetics Auto CashBook Launcher for macOS

APP_DIR="$(dirname "$0")/../.."
HTML_FILE="$APP_DIR/Contents/Resources/index.html"
APP_NAME="Esthetics Auto CashBook"

# Check if HTML file exists
if [ ! -f "$HTML_FILE" ]; then
    osascript -e "display dialog \"Application files not found. Please reinstall $APP_NAME.\" buttons {\"OK\"} default button 1 with icon stop"
    exit 1
fi

# Convert to file URL
FILE_URL="file://$(realpath "$HTML_FILE")"

echo "Starting $APP_NAME..."

# Launch with best available browser in app mode
if [ -d "/Applications/Google Chrome.app" ]; then
    echo "Launching with Chrome..."
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
        --app="$FILE_URL" \
        --new-window \
        --window-size=1400,900 \
        --window-position=100,100 \
        --disable-web-security \
        --user-data-dir="/tmp/esthetics-cashbook-$$" &
elif [ -d "/Applications/Firefox.app" ]; then
    echo "Launching with Firefox..."
    "/Applications/Firefox.app/Contents/MacOS/firefox" \
        --new-window "$FILE_URL" &
elif [ -d "/Applications/Safari.app" ]; then
    echo "Launching with Safari..."
    "/Applications/Safari.app/Contents/MacOS/Safari" "$FILE_URL" &
else
    echo "Using default browser..."
    open "$HTML_FILE"
fi

echo "$APP_NAME launched successfully!"
echo "Login: admin / admin123"
EOF

# Make launcher executable
chmod +x "${APP_DIR}/Contents/MacOS/CashBookLauncher"

echo "📦 Creating DMG installer..."

# Create DMG staging area
DMG_DIR="${BUILD_DIR}/dmg_staging"
mkdir -p "$DMG_DIR"

# Copy app to staging
cp -R "$APP_DIR" "$DMG_DIR/"

# Create Applications symlink for easy installation
ln -sf "/Applications" "$DMG_DIR/Applications"

# Create installation instructions
cat > "$DMG_DIR/Installation Instructions.txt" << EOF
${APP_NAME} v${VERSION}
Installation Instructions
========================

1. Drag "${APP_NAME}" to the Applications folder
2. Launch from Applications folder or Launchpad
3. Login with: admin / admin123

Features:
• Complete financial management system
• Transaction tracking and categorization  
• Employee management and payroll
• Advanced analytics and reporting
• PDF and Excel export capabilities
• Auto backup and restore functionality
• Secure local data storage

Requirements:
• macOS 10.12 Sierra or later
• Modern web browser (Safari, Chrome, Firefox)
• 50MB free disk space

Support:
Email: qasimaziz007@gmail.com
Website: https://qasimaziz007-tech.github.io/cashbook/

© 2024 Esthetics Auto - Made with ❤️ by Qasim Aziz
EOF

# Create DMG using hdiutil
echo "🔨 Building DMG file..."

# Create temporary DMG
TEMP_DMG="temp_${DMG_NAME}.dmg"
hdiutil create -srcfolder "$DMG_DIR" -volname "${APP_NAME} ${VERSION}" -fs HFS+ -fsargs "-c c=64,a=16,e=16" -format UDRW -size 100m "$TEMP_DMG"

# Mount the DMG for customization
echo "🎨 Customizing DMG appearance..."
DEVICE=$(hdiutil attach -readwrite -noverify -noautoopen "$TEMP_DMG" | egrep '^/dev/' | sed 1q | awk '{print $1}')
VOLUME="/Volumes/${APP_NAME} ${VERSION}"

# Wait for mount
sleep 2

# Set DMG window properties using AppleScript
if [ -d "$VOLUME" ]; then
    osascript << EOD
tell application "Finder"
    tell disk "${APP_NAME} ${VERSION}"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {400, 100, 900, 500}
        set viewOptions to the icon view options of container window
        set arrangement of viewOptions to not arranged
        set icon size of viewOptions to 128
        set background picture of viewOptions to file ".background:background.png"
        make new alias file at container window to POSIX file "/Applications" with properties {name:"Applications"}
        set position of item "${APP_NAME}" of container window to {150, 200}
        set position of item "Applications" of container window to {350, 200}
        set position of item "Installation Instructions.txt" of container window to {250, 350}
        close
        open
        update without registering applications
        delay 2
    end tell
end tell
EOD
fi

# Unmount the DMG
echo "💾 Finalizing DMG..."
hdiutil detach "$DEVICE"

# Convert to compressed, read-only DMG
echo "🗜️ Compressing DMG..."
hdiutil convert "$TEMP_DMG" -format UDZO -imagekey zlib-level=9 -o "${DMG_NAME}.dmg"

# Cleanup
rm -f "$TEMP_DMG"
rm -rf "$BUILD_DIR"

# Show results
if [ -f "${DMG_NAME}.dmg" ]; then
    DMG_SIZE=$(ls -lh "${DMG_NAME}.dmg" | awk '{print $5}')
    echo ""
    echo "🎉 Mac DMG Created Successfully!"
    echo "==============================="
    echo "✅ File: ${DMG_NAME}.dmg"
    echo "📏 Size: $DMG_SIZE"
    echo "📍 Location: $(pwd)/${DMG_NAME}.dmg"
    echo ""
    echo "📱 Installation:"
    echo "   1. Double-click ${DMG_NAME}.dmg"
    echo "   2. Drag app to Applications folder"
    echo "   3. Launch from Applications or Launchpad"
    echo "   4. Login: admin / admin123"
    echo ""
    echo "✨ Features:"
    echo "   • Native macOS app bundle"
    echo "   • Professional DMG installer"
    echo "   • Applications folder integration"
    echo "   • Launchpad and Spotlight support"
    echo "   • Optimized for Retina displays"
    echo ""
    echo "🔧 System Requirements:"
    echo "   • macOS 10.12 Sierra or later"
    echo "   • Intel or Apple Silicon Mac"
    echo "   • 50MB free disk space"
    echo ""
    echo "📞 Support: qasimaziz007@gmail.com"
    echo ""
    
    # Ask to open DMG for testing
    read -p "🔍 Open DMG to test installation? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        open "${DMG_NAME}.dmg"
    fi
else
    echo "❌ DMG creation failed!"
    exit 1
fi

echo "💰 Ready for distribution!"