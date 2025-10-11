# 🐧 Linux Installation Package

## 📦 File Information
- **File**: `esthetics-auto-cashbook_1.0.0_linux.tar.gz`
- **Size**: 48KB
- **Platform**: Linux (Ubuntu 16.04+, Debian 9+, CentOS 7+)
- **Architecture**: All (browser-based)

## 🚀 Installation Steps

### **Method 1: Extract & Run**
```bash
# Extract the package
tar -xzf esthetics-auto-cashbook_1.0.0_linux.tar.gz

# Navigate to extracted folder
cd esthetics-auto-cashbook_1.0.0_all

# Run the launcher
./usr/bin/esthetics-auto-cashbook
```

### **Method 2: System Installation**
```bash
# Extract to system directory
sudo tar -xzf esthetics-auto-cashbook_1.0.0_linux.tar.gz -C /

# Create symlink for easy access
sudo ln -s /usr/bin/esthetics-auto-cashbook /usr/local/bin/cashbook

# Run from anywhere
cashbook
```

### **Method 3: User Installation**
```bash
# Extract to home directory
tar -xzf esthetics-auto-cashbook_1.0.0_linux.tar.gz -C ~/

# Add to PATH in ~/.bashrc
echo 'export PATH="$PATH:~/esthetics-auto-cashbook_1.0.0_all/usr/bin"' >> ~/.bashrc
source ~/.bashrc

# Run application
esthetics-auto-cashbook
```

## 📁 Package Structure
```
esthetics-auto-cashbook_1.0.0_all/
├── DEBIAN/
│   └── control (package metadata)
├── usr/
│   ├── bin/
│   │   └── esthetics-auto-cashbook (launcher script)
│   └── share/
│       ├── applications/
│       │   └── esthetics-auto-cashbook.desktop
│       └── esthetics-auto-cashbook/
│           └── index.html (main application)
```

## 💾 Data Storage Location
- **Path**: Browser's localStorage
- **Chrome**: `~/.config/google-chrome/Default/Local Storage`
- **Firefox**: `~/.mozilla/firefox/[profile]/webappsstore.sqlite`
- **Backup**: Use built-in backup feature in Settings

## 🔧 System Requirements
- **Linux Kernel**: 3.10+ (most modern distributions)
- **RAM**: 2GB minimum
- **Storage**: 50MB free space
- **Browser**: Chrome, Firefox, or Chromium
- **Display**: X11 or Wayland

## 🌐 Browser Dependencies
The application requires one of these browsers:
```bash
# Ubuntu/Debian
sudo apt install firefox
# or
sudo apt install chromium-browser
# or
wget -O google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome.deb

# Fedora/CentOS/RHEL
sudo dnf install firefox
# or
sudo dnf install chromium

# Arch Linux
sudo pacman -S firefox
# or
sudo pacman -S chromium
```

## 🖥️ Desktop Integration
- **Applications Menu**: Appears in Office/Finance category
- **Desktop File**: Creates proper `.desktop` entry
- **Icon**: Professional application icon (when provided)
- **Keywords**: Searchable via desktop search

## ⚡ Quick Launch Options

### **Command Line**
```bash
esthetics-auto-cashbook          # Full name
cashbook                         # Symlink (if created)
```

### **Desktop Search**
- Search for "Esthetics" or "CashBook"
- Found in Applications → Office → Finance

### **File Manager**
- Double-click the launcher script
- Or the desktop file in applications folder

## ✅ Features Available
- ✅ Native Linux integration
- ✅ Desktop file creation
- ✅ Applications menu entry
- ✅ Command-line launch
- ✅ Multiple browser support
- ✅ Keyboard shortcuts

## 🗑️ Uninstallation

### **User Installation**
```bash
rm -rf ~/esthetics-auto-cashbook_1.0.0_all
# Remove PATH entry from ~/.bashrc if added
```

### **System Installation**
```bash
sudo rm -rf /usr/share/esthetics-auto-cashbook
sudo rm /usr/bin/esthetics-auto-cashbook
sudo rm /usr/share/applications/esthetics-auto-cashbook.desktop
```

## 🔍 Troubleshooting

### **App doesn't launch**
```bash
# Check if browser is available
which firefox || which chromium-browser || which google-chrome

# Run with debug output
bash -x /usr/bin/esthetics-auto-cashbook
```

### **No desktop entry**
```bash
# Manually copy desktop file
sudo cp usr/share/applications/esthetics-auto-cashbook.desktop /usr/share/applications/
sudo update-desktop-database
```

---
**Native Linux experience with proper system integration!**