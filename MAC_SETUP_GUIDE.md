# 📱 Mac Setup Files - Download & Install

## 🚀 **3 Different Ways to Install on Mac:**

### **Method 1: One-Line Install (Easiest)** ⭐
```bash
curl -fsSL https://raw.githubusercontent.com/qasimaziz007-tech/cashbook/main/mac-quick-setup.sh | bash
```

### **Method 2: Download & Run**
```bash
# Download setup file
curl -O https://raw.githubusercontent.com/qasimaziz007-tech/cashbook/main/create-simple-app.sh

# Make executable  
chmod +x create-simple-app.sh

# Run installer
./create-simple-app.sh
```

### **Method 3: Manual Download**
1. **Right-click and Save As:**
   - [mac-quick-setup.sh](https://raw.githubusercontent.com/qasimaziz007-tech/cashbook/main/mac-quick-setup.sh)
   - [create-simple-app.sh](https://raw.githubusercontent.com/qasimaziz007-tech/cashbook/main/create-simple-app.sh)

2. **Open Terminal and run:**
   ```bash
   chmod +x mac-quick-setup.sh
   ./mac-quick-setup.sh
   ```

## 📋 **All Available Setup Files:**

| File | Purpose | Size | Download Link |
|------|---------|------|---------------|
| `mac-quick-setup.sh` | **Recommended** - Full auto installer | 4KB | [Download](https://raw.githubusercontent.com/qasimaziz007-tech/cashbook/main/mac-quick-setup.sh) |
| `create-simple-app.sh` | Simple app creator | 3KB | [Download](https://raw.githubusercontent.com/qasimaziz007-tech/cashbook/main/create-simple-app.sh) |
| `install.sh` | Advanced Electron installer | 4KB | [Download](https://raw.githubusercontent.com/qasimaziz007-tech/cashbook/main/install.sh) |
| `package.json` | Electron configuration | 3KB | [Download](https://raw.githubusercontent.com/qasimaziz007-tech/cashbook/main/package.json) |
| `main.js` | Electron main process | 7KB | [Download](https://raw.githubusercontent.com/qasimaziz007-tech/cashbook/main/main.js) |

## 🎯 **What Each Method Does:**

### ✅ **mac-quick-setup.sh** (Recommended):
- Downloads latest app from GitHub automatically
- Creates proper macOS app bundle
- Adds to Applications folder
- Creates desktop shortcut
- Works with any browser (Chrome, Firefox, Safari)
- **No dependencies required**

### ✅ **create-simple-app.sh**:
- Uses local HTML file
- Creates basic app structure  
- Good if you already have files downloaded
- **No internet needed after download**

### ✅ **install.sh** (Advanced):
- Full Electron desktop app
- Requires Node.js and npm
- Native desktop features
- **For power users**

## 🔧 **Troubleshooting:**

### **"Permission Denied" Error:**
```bash
chmod +x filename.sh
```

### **"Cannot download" Error:**
```bash
# Check internet connection
curl -I https://github.com

# Try alternative download
wget https://raw.githubusercontent.com/qasimaziz007-tech/cashbook/main/mac-quick-setup.sh
```

### **"App won't open" Error:**
```bash
# Allow app in System Preferences:
# System Preferences → Security & Privacy → Allow
```

## 📞 **Need Help?**

**Contact:**
- 📧 Email: qasimaziz007@gmail.com
- 🐛 Issues: [GitHub Issues](https://github.com/qasimaziz007-tech/cashbook/issues)
- 🌐 Live Demo: [https://qasimaziz007-tech.github.io/cashbook/](https://qasimaziz007-tech.github.io/cashbook/)

---

**🎉 Choose any method above and get your Mac desktop app in under 2 minutes!**