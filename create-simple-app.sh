#!/bin/bash

# Simple Desktop App Creator for Esthetics Auto CashBook
# Creates a standalone app without npm dependencies

echo "🚀 Creating Desktop App - Simple Method"
echo "======================================"

# Create app bundle for macOS
APP_NAME="Esthetics Auto CashBook"
APP_DIR="$HOME/Applications/${APP_NAME}.app"
CONTENTS_DIR="${APP_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

echo "📁 Creating app structure..."
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

# Create Info.plist
cat > "${CONTENTS_DIR}/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>esthetics-cashbook</string>
    <key>CFBundleIdentifier</key>
    <string>com.estheticsauto.cashbook</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

# Create launcher script
cat > "${MACOS_DIR}/esthetics-cashbook" << 'EOF'
#!/bin/bash
# Get the directory of this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
RESOURCES_DIR="${DIR}/../Resources"

# Check if we have a browser available
if command -v /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome >/dev/null 2>&1; then
    BROWSER="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
elif command -v /Applications/Safari.app/Contents/MacOS/Safari >/dev/null 2>&1; then
    BROWSER="/Applications/Safari.app/Contents/MacOS/Safari"
elif command -v firefox >/dev/null 2>&1; then
    BROWSER="firefox"
else
    BROWSER="open"
fi

# Launch the app
if [ "$BROWSER" = "open" ]; then
    open "${RESOURCES_DIR}/index.html"
else
    "$BROWSER" --app="${RESOURCES_DIR}/index.html" --new-window
fi
EOF

chmod +x "${MACOS_DIR}/esthetics-cashbook"

# Copy the HTML file and assets
echo "📋 Copying application files..."
cp "index.html" "${RESOURCES_DIR}/"

# Create a simple icon (text-based)
echo "🎨 Creating app icon..."
# This would normally be an .icns file, but for simplicity we'll skip it

echo "✅ Desktop app created successfully!"
echo "📍 Location: ${APP_DIR}"
echo "🚀 You can now launch it from Applications or double-click the app"

# Create desktop shortcut
read -p "🔗 Create desktop shortcut? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ln -sf "${APP_DIR}" "$HOME/Desktop/${APP_NAME}.app"
    echo "✅ Desktop shortcut created!"
fi

echo ""
echo "🎉 Installation Complete!"
echo "========================"
echo "✅ ${APP_NAME} is now available in your Applications"
echo "🖱️  Double-click to launch"
echo "📱 Works offline - no internet required"