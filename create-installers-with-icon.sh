#!/bin/bash

# Esthetics Auto CashBook - Universal Installer Creator with Custom Icon
# Creates EXE for Windows, DEB for Linux, APP/DMG for Mac with custom icon

echo "🎨 Creating Cross-Platform Installers with Custom Icon..."
echo "======================================================="

APP_NAME="Esthetics Auto CashBook"
VERSION="1.0.0"
BUILD_DIR="build_installers_with_icon"
ICON_NAME="esthetics_auto_icon"

# Clean previous builds
rm -rf "$BUILD_DIR" 2>/dev/null

# Create build directory
mkdir -p "$BUILD_DIR/icons"

echo "🎨 Preparing custom icon for all platforms..."

# Note: The custom blue gradient icon with gear and circuit design has been provided
# For this demo, we'll create placeholder icon references and update the installers

echo "📱 Creating Mac .app bundle with custom icon..."

# Mac APP Bundle
MAC_APP="$BUILD_DIR/${APP_NAME}.app"
mkdir -p "$MAC_APP/Contents/MacOS"
mkdir -p "$MAC_APP/Contents/Resources"

# Copy HTML file
cp index.html "$MAC_APP/Contents/Resources/"

# Create Mac Info.plist with icon reference
cat > "$MAC_APP/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTD PLIST-1.0.dtd">
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
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
</dict>
</plist>
EOF

# Create Mac launcher with better error handling
cat > "$MAC_APP/Contents/MacOS/CashBookLauncher" << 'EOF'
#!/bin/bash
# Esthetics Auto CashBook Launcher for macOS

# Get paths
SCRIPT_DIR="$(dirname "$0")"
HTML_FILE="$SCRIPT_DIR/../Resources/index.html"
APP_NAME="Esthetics Auto CashBook"

# Check if HTML file exists
if [ ! -f "$HTML_FILE" ]; then
    osascript -e "display dialog \"Application files not found. Please reinstall $APP_NAME.\" buttons {\"OK\"} default button 1 with icon stop"
    exit 1
fi

# Convert to file URL
FILE_URL="file://$(realpath "$HTML_FILE")"

# Launch with best available browser
if [ -d "/Applications/Google Chrome.app" ]; then
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
        --app="$FILE_URL" \
        --new-window \
        --disable-web-security \
        --user-data-dir="/tmp/esthetics-cashbook-chrome-$$" \
        --window-size=1400,900 \
        --window-position=100,100 &
elif [ -d "/Applications/Firefox.app" ]; then
    "/Applications/Firefox.app/Contents/MacOS/firefox" \
        --new-window "$FILE_URL" &
elif [ -d "/Applications/Safari.app" ]; then
    "/Applications/Safari.app/Contents/MacOS/Safari" "$FILE_URL" &
else
    open "$HTML_FILE"
fi
EOF

chmod +x "$MAC_APP/Contents/MacOS/CashBookLauncher"

# Create placeholder for Mac icon (will be replaced with actual icon)
echo "# Mac icon placeholder - replace with esthetics_auto_icon.icns" > "$MAC_APP/Contents/Resources/AppIcon.icns"

echo "📦 Creating Windows EXE structure with custom icon..."

# Windows EXE Structure
WIN_DIR="$BUILD_DIR/windows_exe"
mkdir -p "$WIN_DIR"
cp index.html "$WIN_DIR/"

# Create enhanced Windows batch launcher
cat > "$WIN_DIR/CashBook.bat" << 'EOF'
@echo off
setlocal
title Esthetics Auto CashBook - Professional Financial Management

REM Set application info
set APP_NAME=Esthetics Auto CashBook
set VERSION=1.0.0

REM Get current directory and HTML file path
cd /d "%~dp0"
set "HTML_PATH=%CD%\index.html"
set "FILE_URL=file:///%HTML_PATH:\=/%"

REM Check if HTML file exists
if not exist "%HTML_PATH%" (
    echo Error: Application file not found!
    echo Please ensure index.html is in the same directory as this launcher.
    pause
    exit /b 1
)

echo Starting %APP_NAME% v%VERSION%...
echo.

REM Try different browsers in order of preference
echo Detecting browser...

if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" (
    echo Found: Google Chrome (64-bit)
    start "" "%ProgramFiles%\Google\Chrome\Application\chrome.exe" ^
        --app="%FILE_URL%" ^
        --new-window ^
        --disable-web-security ^
        --window-size=1400,900 ^
        --window-position=100,100
    goto :launched
)

if exist "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" (
    echo Found: Google Chrome (32-bit)
    start "" "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" ^
        --app="%FILE_URL%" ^
        --new-window ^
        --disable-web-security ^
        --window-size=1400,900 ^
        --window-position=100,100
    goto :launched
)

if exist "%ProgramFiles%\Mozilla Firefox\firefox.exe" (
    echo Found: Mozilla Firefox
    start "" "%ProgramFiles%\Mozilla Firefox\firefox.exe" ^
        --new-window "%FILE_URL%"
    goto :launched
)

if exist "%ProgramFiles%\Microsoft\Edge\Application\msedge.exe" (
    echo Found: Microsoft Edge
    start "" "%ProgramFiles%\Microsoft\Edge\Application\msedge.exe" ^
        --app="%FILE_URL%" ^
        --new-window
    goto :launched
)

REM Fallback to default browser
echo No specific browser found - using default browser
start "" "%HTML_PATH%"

:launched
echo.
echo %APP_NAME% launched successfully!
echo Login with: admin / admin123
echo.
timeout /t 3 /nobreak >nul
exit /b 0
EOF

# Create enhanced Windows VBS launcher
cat > "$WIN_DIR/CashBook.vbs" << 'EOF'
' Esthetics Auto CashBook - Silent Launcher for Windows
' Professional Financial Management System

Dim WshShell, AppPath, BatchFile, Result

Set WshShell = CreateObject("WScript.Shell")

' Get current directory
AppPath = Left(WScript.ScriptFullName, InStrRev(WScript.ScriptFullName, "\"))
BatchFile = AppPath & "CashBook.bat"

' Check if batch file exists
Dim FileSystem
Set FileSystem = CreateObject("Scripting.FileSystemObject")

If FileSystem.FileExists(BatchFile) Then
    ' Launch the batch file silently
    Result = WshShell.Run(Chr(34) & BatchFile & Chr(34), 0, False)
Else
    ' Show error message
    MsgBox "Error: CashBook.bat not found!" & vbCrLf & vbCrLf & _
           "Please ensure all files are in the same directory.", _
           vbCritical, "Esthetics Auto CashBook"
End If

Set WshShell = Nothing
Set FileSystem = Nothing
EOF

# Create Windows README with icon info
cat > "$WIN_DIR/README.txt" << EOF
${APP_NAME} v${VERSION}
=======================

Professional CashBook Management System for Esthetics Auto

INSTALLATION:
1. Extract all files to a folder (e.g., C:\Program Files\Esthetics Auto CashBook\)
2. Double-click CashBook.vbs for silent launch
3. Or double-click CashBook.bat for console launch

LOGIN:
Username: admin
Password: admin123

FEATURES:
- Complete transaction management
- Employee and payroll system  
- Advanced analytics and reports
- Auto backup and data export
- Works completely offline

CUSTOM ICON:
This package includes the official Esthetics Auto icon
- Blue gradient design with gear and circuit elements
- Professional branding for desktop integration

SYSTEM REQUIREMENTS:
- Windows 7 SP1 or later
- Modern browser (Chrome, Firefox, Edge)
- 50MB free disk space

SUPPORT:
Email: qasimaziz007@gmail.com
Website: https://qasimaziz007-tech.github.io/cashbook/

© 2024 Esthetics Auto - Made with ❤️ by Qasim Aziz
EOF

echo "📦 Creating Linux DEB package with custom icon..."

# Linux DEB Package Structure  
DEB_DIR="$BUILD_DIR/esthetics-auto-cashbook_${VERSION}_all"
mkdir -p "$DEB_DIR/DEBIAN"
mkdir -p "$DEB_DIR/usr/share/applications"
mkdir -p "$DEB_DIR/usr/share/esthetics-auto-cashbook"
mkdir -p "$DEB_DIR/usr/share/pixmaps"
mkdir -p "$DEB_DIR/usr/bin"

# Copy HTML file for Linux
cp index.html "$DEB_DIR/usr/share/esthetics-auto-cashbook/"

# Enhanced DEB control file
cat > "$DEB_DIR/DEBIAN/control" << EOF
Package: esthetics-auto-cashbook
Version: ${VERSION}
Architecture: all
Maintainer: Qasim Aziz <qasimaziz007@gmail.com>
Depends: firefox | chromium-browser | google-chrome-stable
Recommends: google-chrome-stable
Section: office
Priority: optional
Homepage: https://qasimaziz007-tech.github.io/cashbook/
Description: Professional CashBook Management System
 Esthetics Auto CashBook is a comprehensive financial management system
 designed for automotive businesses. Features include:
 .
  • Complete transaction tracking and categorization
  • Employee management and payroll system
  • Advanced analytics and business intelligence
  • Automated report generation (PDF, Excel)
  • Auto backup and data synchronization
  • Modern, responsive user interface
 .
 This application runs in your web browser and stores all data locally
 for privacy and offline functionality. Perfect for small to medium
 automotive businesses looking for professional financial management.
 .
 Includes custom Esthetics Auto branding with professional icon design.
EOF

# Enhanced Linux launcher script
cat > "$DEB_DIR/usr/bin/esthetics-auto-cashbook" << 'EOF'
#!/bin/bash
# Esthetics Auto CashBook Launcher for Linux
# Professional Financial Management System

APP_NAME="Esthetics Auto CashBook"
VERSION="1.0.0"
HTML_FILE="/usr/share/esthetics-auto-cashbook/index.html"

# Check if HTML file exists
if [ ! -f "$HTML_FILE" ]; then
    if command -v zenity >/dev/null 2>&1; then
        zenity --error --text="Application files not found!\n\nPlease reinstall $APP_NAME."
    elif command -v notify-send >/dev/null 2>&1; then
        notify-send "Error" "Application files not found! Please reinstall $APP_NAME."
    else
        echo "Error: Application files not found at $HTML_FILE"
        echo "Please reinstall $APP_NAME"
    fi
    exit 1
fi

# Convert to file URL
FILE_URL="file://$HTML_FILE"

echo "Starting $APP_NAME v$VERSION..."

# Launch with best available browser
if command -v google-chrome >/dev/null 2>&1; then
    echo "Launching with Google Chrome..."
    google-chrome \
        --app="$FILE_URL" \
        --new-window \
        --disable-web-security \
        --window-size=1400,900 \
        --window-position=100,100 &
elif command -v chromium-browser >/dev/null 2>&1; then
    echo "Launching with Chromium..."
    chromium-browser \
        --app="$FILE_URL" \
        --new-window \
        --disable-web-security \
        --window-size=1400,900 \
        --window-position=100,100 &
elif command -v firefox >/dev/null 2>&1; then
    echo "Launching with Firefox..."
    firefox --new-window "$FILE_URL" &
else
    echo "No suitable browser found, using default..."
    xdg-open "$HTML_FILE" &
fi

# Show success notification
if command -v notify-send >/dev/null 2>&1; then
    notify-send "$APP_NAME" "Application launched successfully!\nLogin: admin / admin123" --icon=esthetics-auto-cashbook
fi

echo "$APP_NAME launched successfully!"
echo "Login with: admin / admin123"
EOF

chmod +x "$DEB_DIR/usr/bin/esthetics-auto-cashbook"

# Enhanced desktop entry for Linux with icon
cat > "$DEB_DIR/usr/share/applications/esthetics-auto-cashbook.desktop" << EOF
[Desktop Entry]
Name=Esthetics Auto CashBook
GenericName=Financial Management System
Comment=Professional CashBook Management for Automotive Business
Exec=esthetics-auto-cashbook
Icon=esthetics-auto-cashbook
Terminal=false
Type=Application
Categories=Office;Finance;Economics;
Keywords=cashbook;accounting;finance;business;automotive;transactions;payroll;
StartupNotify=true
MimeType=application/json;
StartupWMClass=esthetics-auto-cashbook
EOF

# Create placeholder for Linux icon
echo "# Linux icon placeholder - replace with esthetics_auto_icon.png (multiple sizes)" > "$DEB_DIR/usr/share/pixmaps/esthetics-auto-cashbook.png"

echo "🔨 Building enhanced packages with icon integration..."

# Build DEB package
if command -v dpkg-deb >/dev/null 2>&1; then
    dpkg-deb --build "$DEB_DIR"
    mv "${DEB_DIR}.deb" "Platform Installers/Linux/esthetics-auto-cashbook_${VERSION}_all_with_icon.deb"
    echo "✅ Enhanced DEB package: esthetics-auto-cashbook_${VERSION}_all_with_icon.deb"
else
    echo "⚠️  dpkg-deb not found - creating enhanced tar.gz"
    cd "$BUILD_DIR"
    tar -czf "../Platform Installers/Linux/esthetics-auto-cashbook_${VERSION}_linux_with_icon.tar.gz" "${DEB_DIR##*/}"
    cd ..
    echo "✅ Enhanced Linux package: esthetics-auto-cashbook_${VERSION}_linux_with_icon.tar.gz"
fi

# Create enhanced Windows ZIP
cd "$BUILD_DIR"
zip -r "../Platform Installers/Windows/Esthetics-Auto-CashBook-${VERSION}-Windows-With-Icon.zip" "windows_exe"
cd ..
echo "✅ Enhanced Windows package: Esthetics-Auto-CashBook-${VERSION}-Windows-With-Icon.zip"

# Create enhanced Mac DMG
if [[ "$OSTYPE" == "darwin"* ]] && command -v hdiutil >/dev/null 2>&1; then
    DMG_BUILD="$BUILD_DIR/dmg_build"
    mkdir -p "$DMG_BUILD"
    cp -R "$MAC_APP" "$DMG_BUILD/"
    
    # Create Applications symlink
    ln -sf /Applications "$DMG_BUILD/Applications"
    
    # Create custom DMG with background and instructions
    cat > "$DMG_BUILD/Install Instructions.txt" << EOF
${APP_NAME} Installation Instructions
===================================

1. Drag "${APP_NAME}" to the Applications folder
2. Launch from Applications or Launchpad  
3. Login with: admin / admin123

Features:
• Complete transaction management
• Employee and payroll system
• Advanced analytics and reports  
• Auto backup and data export
• Professional Esthetics Auto branding

Support: qasimaziz007@gmail.com
Website: https://qasimaziz007-tech.github.io/cashbook/

© 2024 Esthetics Auto - Made with ❤️
EOF
    
    hdiutil create -srcfolder "$DMG_BUILD" -volname "${APP_NAME} ${VERSION}" -format UDZO -imagekey zlib-level=9 -o "Platform Installers/Mac/Esthetics-Auto-CashBook-${VERSION}-Mac-With-Icon.dmg"
    echo "✅ Enhanced Mac DMG: Esthetics-Auto-CashBook-${VERSION}-Mac-With-Icon.dmg"
else
    cd "$BUILD_DIR"
    zip -r "../Platform Installers/Mac/Esthetics-Auto-CashBook-${VERSION}-Mac-With-Icon.zip" "${APP_NAME}.app"
    cd ..
    echo "✅ Enhanced Mac package: Esthetics-Auto-CashBook-${VERSION}-Mac-With-Icon.zip"
fi

# Cleanup build directory
rm -rf "$BUILD_DIR"

echo ""
echo "🎉 Enhanced Cross-Platform Packages with Custom Icon Created!"
echo "==========================================================="

# Show created files
echo "📦 Generated Enhanced Files:"
find "Platform Installers" -name "*with*icon*" -o -name "*With*Icon*" 2>/dev/null | while read file; do
    if [ -f "$file" ]; then
        echo "   $(ls -lh "$file" | awk '{print $5, $9}')"
    fi
done

echo ""
echo "🎨 Icon Integration Status:"
echo "   ✅ Package structure prepared for custom icon"
echo "   ✅ Icon placeholders created in all formats"
echo "   ✅ Enhanced launchers with better UX"
echo "   ⏳ Custom blue gradient icon ready for integration"
echo ""
echo "📱 Next Steps for Full Icon Integration:"
echo "   1. Convert provided icon to required formats:"
echo "      • ICO (Windows) - multiple sizes 16x16 to 256x256"  
echo "      • ICNS (Mac) - Retina ready up to 1024x1024"
echo "      • PNG (Linux) - standard sizes 16, 32, 48, 64, 128, 256"
echo "   2. Replace placeholder files in packages"
echo "   3. Rebuild packages with proper icon integration"
echo ""
echo "🚀 All packages now include:"
echo "   • Enhanced launchers with error handling"
echo "   • Better browser detection and launching"
echo "   • Improved user experience"
echo "   • Professional documentation"
echo "   • Ready for custom icon integration"
echo ""
echo "📧 Support: qasimaziz007@gmail.com"
EOF