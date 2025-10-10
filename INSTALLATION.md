# Esthetics Auto CashBook - Desktop App

## Installation Instructions

### For macOS Users:

1. **Download the app:**
   - Download `Esthetics-Auto-CashBook-1.0.0.dmg` from the releases
   
2. **Install the app:**
   - Double-click the `.dmg` file
   - Drag "Esthetics Auto CashBook" to Applications folder
   - Open Applications and double-click the app
   - If macOS shows security warning, go to System Preferences > Security & Privacy > Allow

3. **Alternative installation (if you have Node.js):**
   ```bash
   # Clone the repository
   git clone https://github.com/qasimaziz007-tech/cashbook.git
   cd cashbook
   
   # Install dependencies
   npm install
   
   # Build for macOS
   npm run build:mac
   
   # The app will be in dist folder
   ```

### For Windows Users:

1. **Download the app:**
   - Download `Esthetics-Auto-CashBook-Setup-1.0.0.exe` from the releases
   
2. **Install the app:**
   - Right-click the installer and "Run as administrator"
   - Follow the installation wizard
   - Choose installation directory (default: Program Files)
   - Create desktop shortcut (recommended)
   - Launch the app after installation

3. **Alternative installation (if you have Node.js):**
   ```cmd
   # Clone the repository
   git clone https://github.com/qasimaziz007-tech/cashbook.git
   cd cashbook
   
   # Install dependencies
   npm install
   
   # Build for Windows
   npm run build:win
   
   # The installer will be in dist folder
   ```

## Development Setup

If you want to run from source code:

### Prerequisites:
- Node.js (v16 or higher)
- npm or yarn

### Steps:
```bash
# Clone repository
git clone https://github.com/qasimaziz007-tech/cashbook.git
cd cashbook

# Install dependencies
npm install

# Run in development mode
npm start

# Build for all platforms
npm run build:all
```

## Features:
- 💰 Complete CashBook Management
- 👥 Employee Management & Payroll
- 📊 Advanced Analytics & Reports
- 📱 Cross-platform Desktop App
- 💾 Auto Backup & Data Export
- 🔒 Secure Local Data Storage
- 📈 Business Intelligence Dashboard

## System Requirements:

### macOS:
- macOS 10.12 or later
- Intel or Apple Silicon processor
- 100MB free disk space

### Windows:
- Windows 7 SP1 or later (64-bit)
- 2GB RAM minimum
- 100MB free disk space
- .NET Framework 4.5 or later

## Troubleshooting:

### macOS Issues:
- **App won't open:** Go to System Preferences > Security & Privacy > Allow
- **Permission denied:** Right-click app > Open, then click "Open" in dialog

### Windows Issues:
- **Installer blocked:** Right-click installer > Properties > Unblock > Apply
- **Antivirus warning:** Add exception for the app in your antivirus software

## Support:
- GitHub Issues: [Report bugs](https://github.com/qasimaziz007-tech/cashbook/issues)
- Email: qasimaziz007@gmail.com
- Live Demo: [https://qasimaziz007-tech.github.io/cashbook/](https://qasimaziz007-tech.github.io/cashbook/)

## License:
MIT License - See LICENSE file for details

---
**Developed by Qasim Aziz**  
© 2024 Esthetics Auto Account