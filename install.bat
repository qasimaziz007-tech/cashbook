@echo off
REM Esthetics Auto CashBook - Auto Installer Script for Windows

echo 🚀 Esthetics Auto CashBook - Auto Installer
echo =============================================

REM Check if Node.js is installed
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Node.js is not installed.
    echo 📥 Please install Node.js from: https://nodejs.org/
    echo    Recommended version: v18 or higher
    pause
    exit /b 1
)

echo ✅ Node.js found
node --version

REM Check if npm is installed
where npm >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ npm is not installed.
    pause
    exit /b 1
)

echo ✅ npm found
npm --version

REM Create app directory
set APP_DIR=%USERPROFILE%\AppData\Local\Esthetics-Auto-CashBook
echo 📁 Creating app directory: %APP_DIR%
if not exist "%APP_DIR%" mkdir "%APP_DIR%"
cd /d "%APP_DIR%"

REM Check if git is installed
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Git not found. Please install git or download manually.
    echo 📥 Download Git from: https://git-scm.com/download/win
    pause
    exit /b 1
)

echo 📥 Cloning repository...
git clone https://github.com/qasimaziz007-tech/cashbook.git .

echo 📦 Installing dependencies...
npm install

echo 🔨 Building application for Windows...
npm run build:win

REM Check if build was successful
if exist "dist\Esthetics-Auto-CashBook-Setup-*.exe" (
    echo 📱 Running installer...
    for %%f in (dist\Esthetics-Auto-CashBook-Setup-*.exe) do (
        start "" "%%f"
    )
    echo ✅ Installer launched successfully!
    echo 🎉 Follow the installation wizard to complete setup
    echo 💡 The installer will create desktop and start menu shortcuts
) else (
    echo ❌ Build failed. Check the dist folder.
    pause
    exit /b 1
)

echo.
echo 🎉 Installation Process Started!
echo ================================
echo ✅ The installer has been launched
echo 📱 Follow the setup wizard to install the app
echo 🖥️  Desktop shortcut will be created automatically
echo 📧 Support: qasimaziz007@gmail.com
echo 🌐 Live Demo: https://qasimaziz007-tech.github.io/cashbook/
echo.
echo Happy accounting! 💰
pause