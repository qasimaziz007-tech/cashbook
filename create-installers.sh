#!/bin/bash

# Esthetics Auto CashBook - Universal Installer Creator
# Creates EXE for Windows and DEB for Linux, APP for Mac

echo "🚀 Creating Cross-Platform Installers..."
echo "========================================"

APP_NAME="Esthetics Auto CashBook"
VERSION="1.0.0"
BUILD_DIR="build_installers"

# Clean previous builds
rm -rf "$BUILD_DIR" *.exe *.deb *.dmg *.app *.zip 2>/dev/null

# Create build directory
mkdir -p "$BUILD_DIR"

echo "📱 Creating Mac .app bundle..."

# Mac APP Bundle
MAC_APP="$BUILD_DIR/${APP_NAME}.app"
mkdir -p "$MAC_APP/Contents/MacOS"
mkdir -p "$MAC_APP/Contents/Resources"

# Copy HTML file
cp index.html "$MAC_APP/Contents/Resources/"

# Create Mac Info.plist
cat > "$MAC_APP/Contents/Info.plist" << EOF
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
</dict>
</plist>
EOF

# Create Mac launcher
cat > "$MAC_APP/Contents/MacOS/CashBookLauncher" << 'EOF'
#!/bin/bash
HTML_FILE="$(dirname "$0")/../Resources/index.html"
FILE_URL="file://$(realpath "$HTML_FILE")"

# Launch in best available browser
if [ -d "/Applications/Google Chrome.app" ]; then
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --app="$FILE_URL" --new-window &
elif [ -d "/Applications/Firefox.app" ]; then
    "/Applications/Firefox.app/Contents/MacOS/firefox" --new-window "$FILE_URL" &
else
    open "$HTML_FILE"
fi
EOF

chmod +x "$MAC_APP/Contents/MacOS/CashBookLauncher"

echo "📦 Creating Windows EXE structure..."

# Windows EXE Structure
WIN_DIR="$BUILD_DIR/windows_exe"
mkdir -p "$WIN_DIR"
cp index.html "$WIN_DIR/"

# Create Windows batch launcher
cat > "$WIN_DIR/CashBook.bat" << 'EOF'
@echo off
title Esthetics Auto CashBook
cd /d "%~dp0"
set "HTML_PATH=%CD%\index.html"
set "FILE_URL=file:///%HTML_PATH:\=/%"

if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" (
    start "" "%ProgramFiles%\Google\Chrome\Application\chrome.exe" --app="%FILE_URL%" --new-window
) else if exist "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" (
    start "" "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" --app="%FILE_URL%" --new-window  
) else if exist "%ProgramFiles%\Mozilla Firefox\firefox.exe" (
    start "" "%ProgramFiles%\Mozilla Firefox\firefox.exe" --new-window "%FILE_URL%"
) else (
    start "" "index.html"
)
EOF

# Create Windows VBS silent launcher (acts like EXE)
cat > "$WIN_DIR/CashBook.vbs" << 'EOF'
Set WshShell = CreateObject("WScript.Shell")
WshShell.Run Chr(34) & "CashBook.bat" & Chr(34), 0
Set WshShell = Nothing
EOF

echo "📦 Creating Linux DEB package structure..."

# Linux DEB Package Structure  
DEB_DIR="$BUILD_DIR/esthetics-auto-cashbook_${VERSION}_all"
mkdir -p "$DEB_DIR/DEBIAN"
mkdir -p "$DEB_DIR/usr/share/applications"
mkdir -p "$DEB_DIR/usr/share/esthetics-auto-cashbook"
mkdir -p "$DEB_DIR/usr/bin"

# Copy HTML file for Linux
cp index.html "$DEB_DIR/usr/share/esthetics-auto-cashbook/"

# Create DEB control file
cat > "$DEB_DIR/DEBIAN/control" << EOF
Package: esthetics-auto-cashbook
Version: ${VERSION}
Architecture: all
Maintainer: Qasim Aziz <qasimaziz007@gmail.com>
Depends: firefox | chromium-browser | google-chrome-stable
Section: office
Priority: optional
Homepage: https://qasimaziz007-tech.github.io/cashbook/
Description: Professional CashBook Management System
 Esthetics Auto CashBook is a comprehensive financial management system
 designed for automotive businesses. Features include transaction tracking,
 employee management, payroll system, analytics, and automated reporting.
 .
 This application runs in your web browser and stores all data locally
 for privacy and offline functionality.
EOF

# Create Linux launcher script
cat > "$DEB_DIR/usr/bin/esthetics-auto-cashbook" << 'EOF'
#!/bin/bash
HTML_FILE="/usr/share/esthetics-auto-cashbook/index.html"
FILE_URL="file://$HTML_FILE"

# Launch in best available browser
if command -v google-chrome >/dev/null 2>&1; then
    google-chrome --app="$FILE_URL" --new-window &
elif command -v chromium-browser >/dev/null 2>&1; then
    chromium-browser --app="$FILE_URL" --new-window &
elif command -v firefox >/dev/null 2>&1; then
    firefox --new-window "$FILE_URL" &
else
    xdg-open "$HTML_FILE"
fi
EOF

chmod +x "$DEB_DIR/usr/bin/esthetics-auto-cashbook"

# Create desktop entry for Linux
cat > "$DEB_DIR/usr/share/applications/esthetics-auto-cashbook.desktop" << EOF
[Desktop Entry]
Name=Esthetics Auto CashBook
Comment=Professional CashBook Management System
Exec=esthetics-auto-cashbook
Icon=application-x-office
Terminal=false
Type=Application
Categories=Office;Finance;
Keywords=cashbook;accounting;finance;business;automotive;
StartupNotify=true
EOF

echo "🔨 Building packages..."

# Build DEB package (if dpkg-deb is available)
if command -v dpkg-deb >/dev/null 2>&1; then
    dpkg-deb --build "$DEB_DIR"
    mv "${DEB_DIR}.deb" "esthetics-auto-cashbook_${VERSION}_all.deb"
    echo "✅ DEB package created: esthetics-auto-cashbook_${VERSION}_all.deb"
else
    echo "⚠️  dpkg-deb not found - creating tar.gz instead of DEB"
    cd "$BUILD_DIR"
    tar -czf "../esthetics-auto-cashbook_${VERSION}_linux.tar.gz" "${DEB_DIR##*/}"
    cd ..
    echo "✅ Linux package created: esthetics-auto-cashbook_${VERSION}_linux.tar.gz"
fi

# Create Windows ZIP (portable EXE alternative)
cd "$BUILD_DIR"
zip -r "../Esthetics-Auto-CashBook-${VERSION}-Windows.zip" "windows_exe"
cd ..
echo "✅ Windows package created: Esthetics-Auto-CashBook-${VERSION}-Windows.zip"

# Create Mac DMG (if running on Mac)
if [[ "$OSTYPE" == "darwin"* ]] && command -v hdiutil >/dev/null 2>&1; then
    # Create temporary DMG directory
    DMG_BUILD="$BUILD_DIR/dmg_build"
    mkdir -p "$DMG_BUILD"
    cp -R "$MAC_APP" "$DMG_BUILD/"
    ln -sf /Applications "$DMG_BUILD/Applications"
    
    hdiutil create -srcfolder "$DMG_BUILD" -volname "${APP_NAME} ${VERSION}" -format UDZO -o "Esthetics-Auto-CashBook-${VERSION}-Mac.dmg"
    echo "✅ Mac DMG created: Esthetics-Auto-CashBook-${VERSION}-Mac.dmg"
else
    # Create Mac ZIP
    cd "$BUILD_DIR"
    zip -r "../Esthetics-Auto-CashBook-${VERSION}-Mac.zip" "${APP_NAME}.app"
    cd ..
    echo "✅ Mac package created: Esthetics-Auto-CashBook-${VERSION}-Mac.zip"
fi

# Cleanup build directory
rm -rf "$BUILD_DIR"

echo ""
echo "🎉 Cross-Platform Packages Created Successfully!"
echo "=============================================="

# Show created files
echo "📦 Generated Files:"
ls -lh *.deb *.zip *.dmg *.tar.gz 2>/dev/null | while read line; do
    echo "   $line"
done

echo ""
echo "📱 Installation Instructions:"
echo ""
echo "🍎 Mac:"
echo "   - DMG: Double-click .dmg → Drag app to Applications"
echo "   - ZIP: Extract → Drag .app to Applications"
echo ""
echo "🐧 Linux:"
echo "   - DEB: sudo dpkg -i esthetics-auto-cashbook_*.deb"  
echo "   - TAR: Extract to /opt/ and create symlinks"
echo ""
echo "🖥️  Windows:"
echo "   - Extract ZIP → Double-click CashBook.vbs"
echo "   - Or run CashBook.bat from command line"
echo ""
echo "✨ All packages are portable and work offline!"
echo "📧 Support: qasimaziz007@gmail.com"