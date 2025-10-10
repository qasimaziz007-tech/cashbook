#!/bin/bash

# Quick Mac Setup for Esthetics Auto CashBook
# This script downloads and installs the desktop app automatically

echo "🚀 Esthetics Auto CashBook - Mac Quick Setup"
echo "============================================"

# Create temporary directory
TEMP_DIR="/tmp/esthetics-cashbook-setup"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

echo "📥 Downloading installation files..."

# Download the main HTML file
curl -fsSL "https://raw.githubusercontent.com/qasimaziz007-tech/cashbook/main/index.html" -o "index.html"

if [ ! -f "index.html" ]; then
    echo "❌ Failed to download application files"
    echo "🌐 Please check your internet connection"
    exit 1
fi

echo "✅ Files downloaded successfully"

# Create app bundle
APP_NAME="Esthetics Auto CashBook"
APP_DIR="$HOME/Applications/${APP_NAME}.app"
CONTENTS_DIR="${APP_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

echo "📁 Creating Mac app bundle..."
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
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
RESOURCES_DIR="${DIR}/../Resources"

# Try different browsers in app mode
if command -v "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" >/dev/null 2>&1; then
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --app="file://${RESOURCES_DIR}/index.html" --new-window --disable-web-security --user-data-dir="/tmp/esthetics-cashbook-chrome" &
elif command -v "/Applications/Firefox.app/Contents/MacOS/firefox" >/dev/null 2>&1; then
    "/Applications/Firefox.app/Contents/MacOS/firefox" --new-window "file://${RESOURCES_DIR}/index.html" &
elif command -v "/Applications/Safari.app/Contents/MacOS/Safari" >/dev/null 2>&1; then
    "/Applications/Safari.app/Contents/MacOS/Safari" "file://${RESOURCES_DIR}/index.html" &
else
    open "${RESOURCES_DIR}/index.html"
fi
EOF

chmod +x "${MACOS_DIR}/esthetics-cashbook"

# Copy application files
cp "index.html" "${RESOURCES_DIR}/"

echo "✅ Mac app created successfully!"
echo "📍 Location: ${APP_DIR}"

# Create desktop shortcut
read -p "🔗 Create desktop shortcut? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ln -sf "${APP_DIR}" "$HOME/Desktop/${APP_NAME}.app"
    echo "✅ Desktop shortcut created!"
fi

# Test launch
read -p "🚀 Launch the app now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    open "${APP_DIR}"
fi

# Cleanup
cd /
rm -rf "$TEMP_DIR"

echo ""
echo "🎉 Installation Complete!"
echo "========================"
echo "✅ ${APP_NAME} is now installed in Applications"
echo "🖱️  Double-click to launch anytime"
echo "📱 Works completely offline"
echo "💾 All data stored locally on your Mac"
echo ""
echo "📞 Support: qasimaziz007@gmail.com"
echo "🌐 Live Demo: https://qasimaziz007-tech.github.io/cashbook/"
echo ""
echo "Happy accounting! 💰"