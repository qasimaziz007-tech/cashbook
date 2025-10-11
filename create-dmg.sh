#!/bin/bash

# Esthetics Auto CashBook - DMG Creator for macOS
# Creates a professional DMG installer file

APP_NAME="Esthetics Auto CashBook"
DMG_NAME="Esthetics-Auto-CashBook-Installer"
VERSION="1.0.0"
BUILD_DIR="build_dmg"
APP_DIR="${BUILD_DIR}/${APP_NAME}.app"

echo "📦 Creating DMG Installer for ${APP_NAME}"
echo "=========================================="

# Clean previous builds
if [ -d "$BUILD_DIR" ]; then
    echo "🗑️  Cleaning previous build..."
    rm -rf "$BUILD_DIR"
fi

if [ -f "${DMG_NAME}.dmg" ]; then
    rm -f "${DMG_NAME}.dmg"
fi

# Create build directory
echo "📁 Creating build structure..."
mkdir -p "$BUILD_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

# Get HTML content
if [ -f "index.html" ]; then
    echo "📋 Using local HTML file..."
    cp "index.html" "$APP_DIR/Contents/Resources/"
else
    echo "📥 Downloading latest version..."
    curl -fsSL "https://raw.githubusercontent.com/qasimaziz007-tech/cashbook/main/index.html" -o "$APP_DIR/Contents/Resources/index.html"
fi

# Verify HTML file exists
if [ ! -f "$APP_DIR/Contents/Resources/index.html" ]; then
    echo "❌ Failed to get application HTML file"
    exit 1
fi

echo "✅ Application file ready ($(wc -c < "$APP_DIR/Contents/Resources/index.html") bytes)"

# Create Info.plist with proper bundle info
echo "📝 Creating application bundle..."
cat > "$APP_DIR/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>CashBookApp</string>
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
    <key>CFBundleSignature</key>
    <string>CASH</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>LSMinimumSystemVersion</key>
    <string>10.12</string>
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
</dict>
</plist>
EOF

# Create executable launcher
cat > "$APP_DIR/Contents/MacOS/CashBookApp" << 'EOF'
#!/bin/bash

# Get app bundle path
BUNDLE_PATH="$(dirname "$0")/../.."
RESOURCES_PATH="$BUNDLE_PATH/Contents/Resources"
HTML_FILE="$RESOURCES_PATH/index.html"

# Ensure HTML file exists
if [ ! -f "$HTML_FILE" ]; then
    osascript -e 'display dialog "Application files not found. Please reinstall the application." buttons {"OK"} default button 1 with icon stop'
    exit 1
fi

# Function to launch in browser
launch_app() {
    local browser_path="$1"
    local browser_args="$2"
    
    if [ -f "$browser_path" ]; then
        "$browser_path" $browser_args "file://$HTML_FILE" &
        return 0
    fi
    return 1
}

# Try browsers in order of preference
if launch_app "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" "--app --new-window --disable-web-security --user-data-dir=/tmp/cashbook-chrome-$$"; then
    echo "Launched with Chrome"
elif launch_app "/Applications/Firefox.app/Contents/MacOS/firefox" "--new-window"; then
    echo "Launched with Firefox"
elif launch_app "/Applications/Safari.app/Contents/MacOS/Safari"; then
    echo "Launched with Safari"
else
    # Fallback to system default
    open "$HTML_FILE"
fi
EOF

# Make launcher executable
chmod +x "$APP_DIR/Contents/MacOS/CashBookApp"

# Create Applications symlink for easy installation
echo "🔗 Creating Applications link..."
ln -sf /Applications "$BUILD_DIR/Applications"

# Create DMG background and instructions
echo "📄 Creating installer instructions..."
cat > "$BUILD_DIR/INSTALL_INSTRUCTIONS.txt" << EOF
${APP_NAME} Installation Instructions
===================================

1. Drag "${APP_NAME}.app" to the Applications folder
2. Find the app in Launchpad or Applications folder  
3. Double-click to launch
4. Login with: admin / admin123

Features:
- Complete transaction management
- Employee and payroll system
- Advanced analytics and reports
- Auto backup and data export
- Works completely offline

Support: qasimaziz007@gmail.com

Enjoy your professional CashBook system!
EOF

# Create temporary DMG
TEMP_DMG="temp_${DMG_NAME}.dmg"
echo "📦 Creating DMG image..."

# Calculate size needed (app size + 50MB buffer)
APP_SIZE=$(du -sm "$BUILD_DIR" | cut -f1)
DMG_SIZE=$((APP_SIZE + 50))

hdiutil create -srcfolder "$BUILD_DIR" -volname "${APP_NAME} ${VERSION}" -fs HFS+ -fsargs "-c c=64,a=16,e=16" -format UDRW -size ${DMG_SIZE}m "$TEMP_DMG"

# Mount the DMG
echo "🔧 Mounting DMG for customization..."
DEVICE=$(hdiutil attach -readwrite -noverify -noautoopen "$TEMP_DMG" | egrep '^/dev/' | sed 1q | awk '{print $1}')
VOLUME="/Volumes/${APP_NAME} ${VERSION}"

# Wait for mount to complete
sleep 2

# Customize DMG appearance (if possible)
if [ -d "$VOLUME" ]; then
    echo "🎨 Customizing DMG appearance..."
    
    # Set custom icon positions (approximate)
    osascript << EOD
tell application "Finder"
    tell disk "${APP_NAME} ${VERSION}"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {400, 100, 900, 400}
        set viewOptions to the icon view options of container window
        set arrangement of viewOptions to not arranged
        set icon size of viewOptions to 72
        delay 1
        close
    end tell
end tell
EOD
fi

# Unmount the DMG
echo "💾 Finalizing DMG..."
hdiutil detach "$DEVICE"

# Convert to read-only, compressed DMG
echo "🗜️  Compressing final DMG..."
hdiutil convert "$TEMP_DMG" -format UDZO -imagekey zlib-level=9 -o "${DMG_NAME}.dmg"

# Clean up
rm -f "$TEMP_DMG"
rm -rf "$BUILD_DIR"

# Get final file info
if [ -f "${DMG_NAME}.dmg" ]; then
    DMG_SIZE_FINAL=$(ls -lh "${DMG_NAME}.dmg" | awk '{print $5}')
    echo ""
    echo "🎉 DMG Created Successfully!"
    echo "=========================="
    echo "✅ File: ${DMG_NAME}.dmg"
    echo "📏 Size: $DMG_SIZE_FINAL"
    echo "📍 Location: $(pwd)/${DMG_NAME}.dmg"
    echo ""
    echo "📱 Installation:"
    echo "1. Double-click the DMG file"
    echo "2. Drag app to Applications folder"
    echo "3. Launch from Applications or Launchpad"
    echo ""
    echo "🚀 Ready to distribute!"
    echo ""
    
    # Ask to open DMG
    read -p "Open DMG file to test? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        open "${DMG_NAME}.dmg"
    fi
else
    echo "❌ DMG creation failed"
    exit 1
fi

echo "💰 Happy accounting!"