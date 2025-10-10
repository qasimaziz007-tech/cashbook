#!/bin/bash

# Esthetics Auto CashBook - Auto Installer Script for macOS/Linux

set -e

echo "🚀 Esthetics Auto CashBook - Auto Installer"
echo "============================================="

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed."
    echo "📥 Please install Node.js from: https://nodejs.org/"
    echo "   Recommended version: v18 or higher"
    exit 1
fi

echo "✅ Node.js found: $(node --version)"

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed."
    exit 1
fi

echo "✅ npm found: $(npm --version)"

# Create app directory
APP_DIR="$HOME/Applications/Esthetics-Auto-CashBook"
echo "📁 Creating app directory: $APP_DIR"
mkdir -p "$APP_DIR"
cd "$APP_DIR"

# Download or clone the repository
if command -v git &> /dev/null; then
    echo "📥 Cloning repository..."
    git clone https://github.com/qasimaziz007-tech/cashbook.git .
else
    echo "❌ Git not found. Please install git or download manually."
    exit 1
fi

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Build the application
echo "🔨 Building application for your platform..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    echo "🍎 Building for macOS..."
    npm run build:mac
    
    # Move app to Applications
    if [ -d "dist/mac/Esthetics Auto CashBook.app" ]; then
        echo "📱 Installing app to /Applications..."
        sudo cp -R "dist/mac/Esthetics Auto CashBook.app" /Applications/
        echo "✅ App installed successfully!"
        echo "🎉 You can now find 'Esthetics Auto CashBook' in your Applications folder"
        
        # Create desktop shortcut
        read -p "🔗 Create desktop shortcut? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            ln -sf "/Applications/Esthetics Auto CashBook.app" "$HOME/Desktop/Esthetics Auto CashBook.app"
            echo "✅ Desktop shortcut created!"
        fi
    else
        echo "❌ Build failed. Check the dist folder."
        exit 1
    fi
    
elif [[ "$OSTYPE" == "linux"* ]]; then
    # Linux
    echo "🐧 Building for Linux..."
    npm run build
    
    # Install AppImage
    if [ -f dist/*.AppImage ]; then
        echo "📱 Installing AppImage..."
        chmod +x dist/*.AppImage
        cp dist/*.AppImage "$HOME/.local/bin/esthetics-auto-cashbook"
        
        # Create desktop entry
        mkdir -p "$HOME/.local/share/applications"
        cat > "$HOME/.local/share/applications/esthetics-auto-cashbook.desktop" << EOF
[Desktop Entry]
Name=Esthetics Auto CashBook
Comment=Professional CashBook Management System
Exec=$HOME/.local/bin/esthetics-auto-cashbook
Icon=$APP_DIR/assets/icon.png
Terminal=false
Type=Application
Categories=Office;Finance;
EOF
        
        echo "✅ App installed successfully!"
        echo "🎉 You can now find 'Esthetics Auto CashBook' in your applications menu"
    else
        echo "❌ Build failed. Check the dist folder."
        exit 1
    fi
fi

# Cleanup
echo "🧹 Cleaning up temporary files..."
rm -rf node_modules/.cache

echo ""
echo "🎉 Installation Complete!"
echo "================================"
echo "✅ Esthetics Auto CashBook has been installed successfully"
echo "🚀 Launch the app from your Applications folder or menu"
echo "📧 Support: qasimaziz007@gmail.com"
echo "🌐 Live Demo: https://qasimaziz007-tech.github.io/cashbook/"
echo ""
echo "Happy accounting! 💰"