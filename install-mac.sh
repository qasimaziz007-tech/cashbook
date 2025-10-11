#!/bin/bash

# 🍎 MAC INSTALLER - Esthetics Auto CashBook
# Simple one-click installation for macOS

echo "🚀 Installing Esthetics Auto CashBook for Mac..."
echo "================================================"

# App details
APP_NAME="Esthetics Auto CashBook"
APP_DIR="$HOME/Applications/${APP_NAME}.app"

# Remove existing app if present
if [ -d "$APP_DIR" ]; then
    echo "🗑️  Removing existing installation..."
    rm -rf "$APP_DIR"
fi

# Create app structure
echo "📁 Creating app structure..."
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

# Download main application file
echo "📥 Downloading application..."
curl -fsSL "https://raw.githubusercontent.com/qasimaziz007-tech/cashbook/main/index.html" -o "$APP_DIR/Contents/Resources/index.html"

if [ ! -f "$APP_DIR/Contents/Resources/index.html" ]; then
    echo "❌ Download failed. Please check internet connection."
    exit 1
fi

# Create Info.plist
cat > "$APP_DIR/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>launcher</string>
    <key>CFBundleIdentifier</key>
    <string>com.estheticsauto.cashbook</string>
    <key>CFBundleName</key>
    <string>Esthetics Auto CashBook</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

# Create launcher script
cat > "$APP_DIR/Contents/MacOS/launcher" << 'EOF'
#!/bin/bash
APP_PATH="$(dirname "$0")/../Resources/index.html"
FILE_URL="file://$(realpath "$APP_PATH")"

# Try Chrome first (best app mode support)
if [ -d "/Applications/Google Chrome.app" ]; then
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --app="$FILE_URL" --new-window &
# Try Firefox
elif [ -d "/Applications/Firefox.app" ]; then
    "/Applications/Firefox.app/Contents/MacOS/firefox" --new-window "$FILE_URL" &
# Try Safari
elif [ -d "/Applications/Safari.app" ]; then
    "/Applications/Safari.app/Contents/MacOS/Safari" "$FILE_URL" &
# Fall back to default browser
else
    open "$APP_PATH"
fi
EOF

# Make launcher executable
chmod +x "$APP_DIR/Contents/MacOS/launcher"

echo "✅ App created successfully!"

# Create desktop shortcut
echo "🔗 Creating desktop shortcut..."
ln -sf "$APP_DIR" "$HOME/Desktop/${APP_NAME}.app"

echo ""
echo "🎉 Installation Complete!"
echo "========================"
echo "✅ App installed: $APP_DIR"
echo "🖥️  Desktop shortcut created"
echo "🚀 Double-click desktop icon to launch"
echo ""

# Ask to launch now
read -p "Launch app now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    open "$APP_DIR"
fi

echo "📞 Support: qasimaziz007@gmail.com"
echo "💰 Happy accounting!"