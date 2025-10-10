# 🖥️ Esthetics Auto CashBook - Desktop App Installation

Transform your web-based CashBook into a powerful desktop application for Mac and Windows!

## 🚀 Quick Installation

### 📱 For macOS Users:

#### Method 1: Auto Installer (Recommended)
```bash
# Run this command in Terminal:
curl -fsSL https://raw.githubusercontent.com/qasimaziz007-tech/cashbook/main/install.sh | bash
```

#### Method 2: Manual Installation
1. **Download & Install Node.js**: [https://nodejs.org/](https://nodejs.org/)
2. **Clone Repository**:
   ```bash
   git clone https://github.com/qasimaziz007-tech/cashbook.git
   cd cashbook
   ```
3. **Install & Build**:
   ```bash
   npm install
   npm run build:mac
   ```
4. **Install App**:
   ```bash
   sudo cp -R "dist/mac/Esthetics Auto CashBook.app" /Applications/
   ```

### 🖥️ For Windows Users:

#### Method 1: Auto Installer (Recommended)
1. Download `install.bat` from the repository
2. Right-click and "Run as Administrator"
3. Follow the automatic installation process

#### Method 2: Manual Installation
1. **Download & Install Node.js**: [https://nodejs.org/](https://nodejs.org/)
2. **Clone Repository**:
   ```cmd
   git clone https://github.com/qasimaziz007-tech/cashbook.git
   cd cashbook
   ```
3. **Install & Build**:
   ```cmd
   npm install
   npm run build:win
   ```
4. **Run Installer**: Execute the generated `.exe` file in `dist` folder

## ✨ Desktop App Features

### 🎯 Enhanced Experience:
- **Native Desktop Application** - No browser required
- **System Integration** - File dialogs, notifications, menu bar
- **Better Performance** - Optimized for desktop use
- **Offline Functionality** - Works without internet connection
- **Auto Updates** - Automatic app updates when available

### 💾 Advanced File Operations:
- **Native File Dialogs** - Choose backup locations easily
- **System File Integration** - Save backups anywhere on your system
- **Desktop Shortcuts** - Quick access from desktop/start menu
- **Menu Bar Integration** - Native application menus

### 🔒 Enhanced Security:
- **Local Data Storage** - All data stays on your computer
- **No Web Dependencies** - Reduced security risks
- **System-level Security** - Operating system protection

## 📋 System Requirements

### macOS:
- **OS Version**: macOS 10.12 (Sierra) or later
- **Processor**: Intel x64 or Apple Silicon (M1/M2)
- **Memory**: 4GB RAM recommended
- **Storage**: 200MB free space
- **Additional**: Xcode Command Line Tools (auto-installed)

### Windows:
- **OS Version**: Windows 7 SP1 or later (64-bit recommended)
- **Processor**: Intel/AMD x64 or x86
- **Memory**: 4GB RAM recommended
- **Storage**: 200MB free space
- **Additional**: .NET Framework 4.5+ (usually pre-installed)

## 🛠️ Development Setup

Want to customize or contribute? Set up the development environment:

```bash
# Clone the repository
git clone https://github.com/qasimaziz007-tech/cashbook.git
cd cashbook

# Install dependencies
npm install

# Run in development mode
npm start

# Build for specific platform
npm run build:mac    # macOS
npm run build:win    # Windows
npm run build:all    # All platforms
```

### 📁 Project Structure:
```
cashbook/
├── main.js              # Electron main process
├── preload.js           # Security bridge script
├── index.html           # Application UI
├── package.json         # Dependencies & build config
├── build/               # Platform-specific configs
├── assets/              # App icons & resources
└── dist/                # Built applications
```

## 🎨 Customization Options

### 🏢 Company Branding:
- Replace icons in `assets/` folder
- Modify company information in settings
- Customize color scheme in CSS variables

### ⚙️ Build Configuration:
- Edit `package.json` build section
- Modify installer options in electron-builder config
- Add custom file associations

## 🐛 Troubleshooting

### Common macOS Issues:

**"App can't be opened because it's from an unidentified developer"**
```bash
# Solution 1: Allow in System Preferences
System Preferences → Security & Privacy → Allow

# Solution 2: Command line override
sudo spctl --master-disable
```

**Permission Denied Errors:**
```bash
# Fix permissions
chmod -R 755 /Applications/Esthetics\ Auto\ CashBook.app
```

### Common Windows Issues:

**"Windows protected your PC" SmartScreen warning**
- Click "More info" → "Run anyway"
- Or disable SmartScreen temporarily

**Antivirus False Positive:**
- Add application folder to antivirus exclusions
- Common with Electron apps due to Node.js runtime

**Installation Failed:**
```cmd
# Run as Administrator
# Temporarily disable antivirus
# Check Windows version compatibility
```

## 🔄 Data Migration

### From Web Version:
1. **Export Data**: Use web version's export feature
2. **Install Desktop App**: Follow installation guide above  
3. **Import Data**: Use desktop app's import feature
4. **Verify Data**: Check all transactions and settings

### Between Computers:
1. **Create Backup**: Settings → Auto Backup → Create Backup Now
2. **Transfer File**: Copy backup file to new computer
3. **Install App**: On new computer, install desktop app
4. **Restore Data**: Settings → Import Data → Select backup file

## 📞 Support & Help

### 🆘 Getting Help:
- **Issues**: [GitHub Issues](https://github.com/qasimaziz007-tech/cashbook/issues)
- **Email**: qasimaziz007@gmail.com
- **Live Demo**: [https://qasimaziz007-tech.github.io/cashbook/](https://qasimaziz007-tech.github.io/cashbook/)

### 📚 Documentation:
- **User Guide**: Available in app's Help menu
- **API Reference**: For developers in `/docs` folder
- **Video Tutorials**: Coming soon!

### 🔍 Diagnostic Information:
When reporting issues, include:
- Operating System & Version
- Node.js version (`node --version`)
- Error messages or screenshots
- Steps to reproduce the issue

## 🎉 Success Stories

> "Migrated from web version to desktop app - the file integration and performance improvements are amazing!" - *Local Business Owner*

> "Auto backup to custom folders has saved me multiple times. Desktop app is much more reliable." - *Accounting Manager*

## 🚀 What's Next?

### Upcoming Features:
- 📱 **Mobile Companion App** - iOS/Android sync
- ☁️ **Cloud Sync Option** - Optional cloud backup
- 🔗 **API Integration** - Connect with accounting software
- 📊 **Advanced Analytics** - AI-powered insights
- 🌍 **Multi-language Support** - Arabic, Hindi, Urdu

### 🤝 Contributing:
We welcome contributions! See `CONTRIBUTING.md` for guidelines.

---

**Made with ❤️ by Qasim Aziz**  
*Transforming business accounting, one desktop app at a time.*

© 2024 Esthetics Auto Account - MIT License