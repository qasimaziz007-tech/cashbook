#!/bin/bash

# Esthetics Auto CashBook - Mac App Creator
# Creates a standalone .app bundle for macOS

APP_NAME="Esthetics Auto CashBook"
APP_DIR="$HOME/Applications/${APP_NAME}.app"

echo "🍎 Creating Mac App: ${APP_NAME}"
echo "=================================="

# Remove existing app
if [ -d "$APP_DIR" ]; then
    echo "🗑️  Removing existing app..."
    rm -rf "$APP_DIR"
fi

# Create app structure
echo "📁 Creating app bundle..."
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

# Get the HTML content (either from local file or download)
if [ -f "index.html" ]; then
    echo "📋 Using local HTML file..."
    cp "index.html" "$APP_DIR/Contents/Resources/"
else
    echo "📥 Downloading latest version..."
    curl -fsSL "https://raw.githubusercontent.com/qasimaziz007-tech/cashbook/main/index.html" -o "$APP_DIR/Contents/Resources/index.html"
fi

# Create Info.plist
cat > "$APP_DIR/Contents/Info.plist" << EOF
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
    <string>1.0.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>LSMinimumSystemVersion</key>
    <string>10.12</string>
</dict>
</plist>
EOF

# Create executable launcher
cat > "$APP_DIR/Contents/MacOS/CashBookLauncher" << 'EOF'
#!/bin/bash
APP_DIR="$(dirname "$0")/.."
HTML_FILE="$APP_DIR/Resources/index.html"

# Try different browsers in order of preference
if [ -d "/Applications/Google Chrome.app" ]; then
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
        --app="file://$HTML_FILE" \
        --new-window \
        --disable-web-security \
        --disable-features=VizDisplayCompositor \
        --user-data-dir="/tmp/cashbook-chrome-$$" &
elif [ -d "/Applications/Firefox.app" ]; then
    "/Applications/Firefox.app/Contents/MacOS/firefox" \
        --new-window "file://$HTML_FILE" &
elif [ -d "/Applications/Safari.app" ]; then
    "/Applications/Safari.app/Contents/MacOS/Safari" "file://$HTML_FILE" &
else
    # Fallback to default browser
    open "$HTML_FILE"
fi
EOF

# Make launcher executable
chmod +x "$APP_DIR/Contents/MacOS/CashBookLauncher"

echo "✅ Mac app created successfully!"
echo "📍 Location: $APP_DIR"

# Create desktop shortcut
echo "🔗 Creating desktop shortcut..."
ln -sf "$APP_DIR" "$HOME/Desktop/${APP_NAME}.app"

# Create Applications alias for easier finding
if [ ! -L "/Applications/${APP_NAME}.app" ]; then
    sudo ln -sf "$APP_DIR" "/Applications/${APP_NAME}.app" 2>/dev/null || echo "⚠️  Could not create system-wide link (run with sudo for system access)"
fi

echo ""
echo "🎉 Installation Complete!"
echo "========================"
echo "✅ App: $APP_DIR"
echo "🖥️  Desktop shortcut created"
echo "🚀 Double-click to launch"
echo ""

# Ask to launch
read -p "Launch app now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    open "$APP_DIR"
fi

echo "💰 Happy accounting!"