#!/bin/bash

# Esthetics Auto CashBook - DEB Package Creator
# Creates a proper Debian package for Linux system installation

APP_NAME="esthetics-auto-cashbook"
VERSION="1.0.0"
PACKAGE_NAME="${APP_NAME}_${VERSION}_all"

echo "📦 Creating DEB Package for System Installation..."
echo "================================================="

# Clean any previous build
rm -rf deb_build *.deb 2>/dev/null

# Create DEB package structure
echo "📁 Creating package structure..."
mkdir -p "deb_build/${PACKAGE_NAME}/DEBIAN"
mkdir -p "deb_build/${PACKAGE_NAME}/usr/share/applications"
mkdir -p "deb_build/${PACKAGE_NAME}/usr/share/${APP_NAME}"
mkdir -p "deb_build/${PACKAGE_NAME}/usr/share/pixmaps" 
mkdir -p "deb_build/${PACKAGE_NAME}/usr/bin"
mkdir -p "deb_build/${PACKAGE_NAME}/usr/share/doc/${APP_NAME}"

# Copy main application
echo "📋 Copying application files..."
cp index.html "deb_build/${PACKAGE_NAME}/usr/share/${APP_NAME}/"

# Create control file
echo "📝 Creating package metadata..."
cat > "deb_build/${PACKAGE_NAME}/DEBIAN/control" << EOF
Package: ${APP_NAME}
Version: ${VERSION}
Section: office
Priority: optional
Architecture: all
Depends: firefox | chromium-browser | google-chrome-stable
Maintainer: Qasim Aziz <qasimaziz007@gmail.com>
Description: Esthetics Auto Professional CashBook Management System
 A comprehensive financial management application designed specifically
 for automotive businesses. Features include complete transaction
 tracking, employee management, payroll processing, advanced analytics,
 and automated reporting capabilities.
 .
 Key Features:
  * Transaction Management - Income/expense tracking with categories
  * Employee & Payroll - Staff records and salary processing
  * Analytics & Reports - Business insights with charts and graphs  
  * Data Export - PDF and Excel report generation
  * Auto Backup - Secure data backup and restore functionality
  * Offline Operation - Works without internet connection
 .
 The application runs in a web browser and stores all data locally
 for maximum privacy and security. Perfect for small to medium
 automotive businesses seeking professional financial management.
Homepage: https://qasimaziz007-tech.github.io/cashbook/
EOF

# Create executable launcher
echo "🚀 Creating system launcher..."
cat > "deb_build/${PACKAGE_NAME}/usr/bin/${APP_NAME}" << 'EOF'
#!/bin/bash
# Esthetics Auto CashBook System Launcher

APP_NAME="Esthetics Auto CashBook"
HTML_FILE="/usr/share/esthetics-auto-cashbook/index.html"

# Check if application files exist
if [ ! -f "$HTML_FILE" ]; then
    echo "Error: Application files not found!"
    echo "Please reinstall the package: sudo apt install --reinstall esthetics-auto-cashbook"
    exit 1
fi

# Convert to file URL
FILE_URL="file://$HTML_FILE"

echo "Starting $APP_NAME..."

# Launch with available browser in app mode
if command -v google-chrome >/dev/null 2>&1; then
    google-chrome --app="$FILE_URL" --new-window --class="esthetics-auto-cashbook" &
elif command -v chromium-browser >/dev/null 2>&1; then
    chromium-browser --app="$FILE_URL" --new-window --class="esthetics-auto-cashbook" &
elif command -v firefox >/dev/null 2>&1; then
    firefox --new-window "$FILE_URL" &
else
    # Fallback to default browser
    xdg-open "$HTML_FILE" &
fi

echo "Application launched successfully!"
echo "Login with: admin / admin123"
EOF

chmod +x "deb_build/${PACKAGE_NAME}/usr/bin/${APP_NAME}"

# Create desktop entry
echo "🖥️ Creating desktop integration..."
cat > "deb_build/${PACKAGE_NAME}/usr/share/applications/${APP_NAME}.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Esthetics Auto CashBook
GenericName=Financial Management System
Comment=Professional CashBook for Automotive Business
Categories=Office;Finance;
Keywords=cashbook;accounting;finance;automotive;business;
Exec=${APP_NAME}
Icon=${APP_NAME}
Terminal=false
StartupNotify=true
StartupWMClass=esthetics-auto-cashbook
MimeType=application/json;
EOF

# Create simple PNG icon (placeholder)
echo "🎨 Creating application icon..."
cat > "deb_build/${PACKAGE_NAME}/usr/share/pixmaps/${APP_NAME}.png" << 'EOF'
# Simple PNG icon placeholder
# In a real package, this would be the actual PNG icon file
# For now, this serves as a placeholder that can be replaced
EOF

# Create documentation
echo "📚 Creating documentation..."
cat > "deb_build/${PACKAGE_NAME}/usr/share/doc/${APP_NAME}/README" << EOF
Esthetics Auto CashBook v${VERSION}
==================================

INSTALLATION COMPLETE!

QUICK START:
1. Find "Esthetics Auto CashBook" in Applications menu
2. Or run: ${APP_NAME}
3. Login: admin / admin123

FEATURES:
- Complete transaction management
- Employee and payroll system
- Advanced analytics and reporting
- PDF and Excel export capabilities
- Auto backup and restore
- Secure local data storage

DATA LOCATION:
All data is stored in your browser's localStorage:
~/.config/google-chrome/Default/Local Storage/ (Chrome)
~/.mozilla/firefox/[profile]/webappsstore.sqlite (Firefox)

UNINSTALLATION:
sudo apt remove ${APP_NAME}

SUPPORT:
Email: qasimaziz007@gmail.com
Web: https://qasimaziz007-tech.github.io/cashbook/

© 2024 Esthetics Auto - Made with ❤️ by Qasim Aziz
EOF

# Create copyright file
cat > "deb_build/${PACKAGE_NAME}/usr/share/doc/${APP_NAME}/copyright" << EOF
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: esthetics-auto-cashbook
Upstream-Contact: Qasim Aziz <qasimaziz007@gmail.com>
Source: https://github.com/qasimaziz007-tech/cashbook

Files: *
Copyright: 2024 Qasim Aziz
License: MIT

License: MIT
 Permission is hereby granted, free of charge, to any person obtaining a
 copy of this software and associated documentation files (the "Software"),
 to deal in the Software without restriction, including without limitation
 the rights to use, copy, modify, merge, publish, distribute, sublicense,
 and/or sell copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following conditions:
 .
 The above copyright notice and this permission notice shall be included
 in all copies or substantial portions of the Software.
 .
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 DEALINGS IN THE SOFTWARE.
EOF

# Build the DEB package
echo "🔨 Building DEB package..."
if command -v dpkg-deb >/dev/null 2>&1; then
    cd deb_build
    dpkg-deb --build "$PACKAGE_NAME"
    cd ..
    mv "deb_build/${PACKAGE_NAME}.deb" "./esthetics-auto-cashbook_${VERSION}_all.deb"
    echo "✅ DEB package created: esthetics-auto-cashbook_${VERSION}_all.deb"
else
    echo "❌ dpkg-deb not found! Installing dpkg-dev..."
    if command -v apt >/dev/null 2>&1; then
        sudo apt update && sudo apt install -y dpkg-dev
        cd deb_build  
        dpkg-deb --build "$PACKAGE_NAME"
        cd ..
        mv "deb_build/${PACKAGE_NAME}.deb" "./esthetics-auto-cashbook_${VERSION}_all.deb"
        echo "✅ DEB package created: esthetics-auto-cashbook_${VERSION}_all.deb"
    else
        echo "❌ Cannot create DEB package - dpkg-dev not available"
        echo "📦 Creating TAR.GZ archive instead..."
        cd deb_build
        tar -czf "../esthetics-auto-cashbook_${VERSION}_linux.tar.gz" "$PACKAGE_NAME"
        cd ..
        echo "✅ Linux package created: esthetics-auto-cashbook_${VERSION}_linux.tar.gz"
    fi
fi

# Cleanup
rm -rf deb_build

# Show package info
echo ""
echo "🎉 Package Creation Complete!"
echo "============================="

if [ -f "esthetics-auto-cashbook_${VERSION}_all.deb" ]; then
    echo "📦 DEB Package: esthetics-auto-cashbook_${VERSION}_all.deb"
    echo "📏 Size: $(ls -lh esthetics-auto-cashbook_${VERSION}_all.deb | awk '{print $5}')"
    echo ""
    echo "📱 Installation Commands:"
    echo "   sudo dpkg -i esthetics-auto-cashbook_${VERSION}_all.deb"
    echo "   sudo apt-get install -f  # Fix dependencies if needed"
    echo ""
    echo "🚀 Launch Commands:"
    echo "   esthetics-auto-cashbook  # Command line"
    echo "   # Or find in Applications → Office → Esthetics Auto CashBook"
    echo ""
    echo "🗑️ Uninstallation:"
    echo "   sudo apt remove esthetics-auto-cashbook"
elif [ -f "esthetics-auto-cashbook_${VERSION}_linux.tar.gz" ]; then
    echo "📦 Linux Package: esthetics-auto-cashbook_${VERSION}_linux.tar.gz"
    echo "📏 Size: $(ls -lh esthetics-auto-cashbook_${VERSION}_linux.tar.gz | awk '{print $5}')"
    echo ""
    echo "📱 Manual Installation:"
    echo "   tar -xzf esthetics-auto-cashbook_${VERSION}_linux.tar.gz"
    echo "   sudo cp -r esthetics-auto-cashbook_${VERSION}_all/* /"
    echo "   sudo update-desktop-database"
fi

echo ""
echo "✨ Features:"
echo "   • System-wide installation"
echo "   • Desktop menu integration" 
echo "   • Command-line launcher"
echo "   • Proper Debian packaging"
echo "   • Complete documentation"
echo ""
echo "📧 Support: qasimaziz007@gmail.com"
echo "🌐 Website: https://qasimaziz007-tech.github.io/cashbook/"