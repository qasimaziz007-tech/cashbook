# 📱 Desktop Installation - WORKING SETUP FILES

## ✅ **CONFIRMED WORKING INSTALLERS**

### 🍎 **Mac Installation:**

#### **Method 1: One-Line Install (Recommended)**
```bash
curl -fsSL https://raw.githubusercontent.com/qasimaziz007-tech/cashbook/main/install-mac.sh | bash
```

#### **Method 2: Download and Run**
```bash
# Download installer
curl -O https://raw.githubusercontent.com/qasimaziz007-tech/cashbook/main/install-mac.sh

# Make executable
chmod +x install-mac.sh

# Run installer
./install-mac.sh
```

### 🖥️ **Windows Installation:**

#### **Method 1: Direct Download**
1. **Right-click and "Save As"**: [install.bat](https://raw.githubusercontent.com/qasimaziz007-tech/cashbook/main/install.bat)
2. **Right-click downloaded file → "Run as Administrator"**
3. **Follow installation prompts**

#### **Method 2: Command Line**
```cmd
REM Download using PowerShell
powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/qasimaziz007-tech/cashbook/main/install.bat' -OutFile 'install.bat'"

REM Run installer
install.bat
```

## 🎯 **What These Installers Do:**

### ✅ **Mac (install-mac.sh):**
- ✅ Downloads latest app from GitHub
- ✅ Creates native macOS app bundle  
- ✅ Adds to Applications folder
- ✅ Creates desktop shortcut
- ✅ Works with Chrome, Firefox, Safari
- ✅ **NO Node.js or npm required**

### ✅ **Windows (install.bat):**  
- ✅ Downloads latest app using PowerShell
- ✅ Creates application folder
- ✅ Creates desktop shortcut
- ✅ Adds Start Menu entry
- ✅ Works with Chrome, Firefox, Edge
- ✅ **NO Node.js or npm required**

## 📁 **Installation Locations:**

### Mac:
- **App**: `~/Applications/Esthetics Auto CashBook.app`
- **Shortcut**: `~/Desktop/Esthetics Auto CashBook.app`

### Windows:
- **App**: `%USERPROFILE%\AppData\Local\Esthetics Auto CashBook\`
- **Desktop**: `%USERPROFILE%\Desktop\Esthetics Auto CashBook.lnk`
- **Start Menu**: Available in Start Menu

## ⚡ **Quick Test:**

### Test Mac installer:
```bash
curl -fsSL https://raw.githubusercontent.com/qasimaziz007-tech/cashbook/main/install-mac.sh | head -5
```

### Test Windows installer:
```cmd
powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/qasimaziz007-tech/cashbook/main/install.bat' -Method Head"
```

## 🔧 **Features:**
- ✅ **Zero Dependencies** - No Node.js, npm, git required
- ✅ **Direct Download** - Gets latest version from GitHub
- ✅ **Native Integration** - Proper desktop shortcuts
- ✅ **Browser Support** - Chrome, Firefox, Safari, Edge
- ✅ **Offline Ready** - Works without internet after install
- ✅ **Auto Launch** - Option to launch immediately after install
- ✅ **Easy Uninstall** - Just delete app folder

## 📞 **Support:**
- 📧 **Email**: qasimaziz007@gmail.com
- 🐛 **Issues**: [GitHub Issues](https://github.com/qasimaziz007-tech/cashbook/issues)
- 🌐 **Live Demo**: [https://qasimaziz007-tech.github.io/cashbook/](https://qasimaziz007-tech.github.io/cashbook/)

---

## 🎉 **Installation Status: ✅ READY TO USE**

**Both Mac and Windows installers are working and available online.**  
**No technical knowledge required - just download and run!**

---

**Made with ❤️ for easy desktop installation**