#!/bin/bash

# Windows EXE Creator for Mac/Linux systems
echo "🖥️ Creating Windows Portable EXE..."

WIN_DIR="windows_portable"
APP_NAME="Esthetics Auto CashBook"

# Clean and create
rm -rf "$WIN_DIR" *.zip 2>/dev/null
mkdir -p "$WIN_DIR"

# Copy HTML file
cp index.html "$WIN_DIR/"

# Create batch launcher
cat > "$WIN_DIR/CashBook.bat" << 'EOF'
@echo off
title Esthetics Auto CashBook
cd /d "%~dp0"

REM Try Chrome first (best app mode)
if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" (
    start "" "%ProgramFiles%\Google\Chrome\Application\chrome.exe" --app="file:///%CD%/index.html" --new-window
) else if exist "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" (
    start "" "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" --app="file:///%CD%/index.html" --new-window
) else (
    start "" "index.html"
)
EOF

# Create VBS silent launcher (acts like EXE)
cat > "$WIN_DIR/CashBook.vbs" << 'EOF'
Set WshShell = CreateObject("WScript.Shell")
WshShell.Run Chr(34) & "CashBook.bat" & Chr(34), 0
Set WshShell = Nothing
EOF

# Create README
cat > "$WIN_DIR/README.txt" << EOF
${APP_NAME} - Portable Windows Version
=====================================

HOW TO USE:
1. Double-click "CashBook.vbs" to launch
2. Login: admin / admin123
3. Works completely offline

FEATURES:
- Complete transaction management
- Employee and payroll system
- Analytics and reports
- Auto backup system

SYSTEM REQUIREMENTS:
- Windows 7 or later
- Any modern browser (Chrome recommended)

SUPPORT: qasimaziz007@gmail.com

Made with ❤️ by Qasim Aziz
EOF

# Create ZIP package for Windows
zip -r "Esthetics-CashBook-Windows.zip" "$WIN_DIR"

# Cleanup
rm -rf "$WIN_DIR"

echo "✅ Windows Package Created: Esthetics-CashBook-Windows.zip"
ls -lh *.zip