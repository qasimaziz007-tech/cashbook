@echo off
REM 🖥️ WINDOWS INSTALLER - Esthetics Auto CashBook
REM Simple installation for Windows (no Node.js required)

echo 🚀 Installing Esthetics Auto CashBook for Windows...
echo ==================================================

set APP_NAME=Esthetics Auto CashBook
set INSTALL_DIR=%USERPROFILE%\AppData\Local\%APP_NAME%

REM Remove existing installation
if exist "%INSTALL_DIR%" (
    echo 🗑️ Removing existing installation...
    rmdir /s /q "%INSTALL_DIR%"
)

echo � Creating installation directory...
mkdir "%INSTALL_DIR%"

echo 📥 Downloading application file...

REM Download using PowerShell (available on all modern Windows)
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/qasimaziz007-tech/cashbook/main/index.html' -OutFile '%INSTALL_DIR%\index.html'}"

if not exist "%INSTALL_DIR%\index.html" (
    echo ❌ Download failed. Please check internet connection.
    pause
    exit /b 1
)

echo ✅ Application downloaded successfully!

echo 📝 Creating launcher...
> "%INSTALL_DIR%\launch.bat" echo @echo off
>> "%INSTALL_DIR%\launch.bat" echo title %APP_NAME%
>> "%INSTALL_DIR%\launch.bat" echo cd /d "%%~dp0"
>> "%INSTALL_DIR%\launch.bat" echo.
>> "%INSTALL_DIR%\launch.bat" echo REM Try Chrome first (best app mode)
>> "%INSTALL_DIR%\launch.bat" echo if exist "%%ProgramFiles%%\Google\Chrome\Application\chrome.exe" (
>> "%INSTALL_DIR%\launch.bat" echo     start "" "%%ProgramFiles%%\Google\Chrome\Application\chrome.exe" --app="file:///%%CD:\=/%%/index.html" --new-window
>> "%INSTALL_DIR%\launch.bat" echo ^) else if exist "%%ProgramFiles(x86)%%\Google\Chrome\Application\chrome.exe" (
>> "%INSTALL_DIR%\launch.bat" echo     start "" "%%ProgramFiles(x86)%%\Google\Chrome\Application\chrome.exe" --app="file:///%%CD:\=/%%/index.html" --new-window
>> "%INSTALL_DIR%\launch.bat" echo ^) else if exist "%%ProgramFiles%%\Mozilla Firefox\firefox.exe" (
>> "%INSTALL_DIR%\launch.bat" echo     start "" "%%ProgramFiles%%\Mozilla Firefox\firefox.exe" --new-window "file:///%%CD:\=/%%/index.html"
>> "%INSTALL_DIR%\launch.bat" echo ^) else (
>> "%INSTALL_DIR%\launch.bat" echo     start "" "index.html"
>> "%INSTALL_DIR%\launch.bat" echo ^)

echo 🖥️ Creating desktop shortcut...
set DESKTOP_SHORTCUT=%USERPROFILE%\Desktop\%APP_NAME%.lnk
powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%DESKTOP_SHORTCUT%'); $Shortcut.TargetPath = '%INSTALL_DIR%\launch.bat'; $Shortcut.WorkingDirectory = '%INSTALL_DIR%'; $Shortcut.Description = '%APP_NAME% - Professional CashBook Management'; $Shortcut.Save()"

echo � Creating Start Menu shortcut...
set STARTMENU_DIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs
set STARTMENU_SHORTCUT=%STARTMENU_DIR%\%APP_NAME%.lnk
powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%STARTMENU_SHORTCUT%'); $Shortcut.TargetPath = '%INSTALL_DIR%\launch.bat'; $Shortcut.WorkingDirectory = '%INSTALL_DIR%'; $Shortcut.Description = '%APP_NAME% - Professional CashBook Management'; $Shortcut.Save()"

echo.
echo 🎉 Installation Complete!
echo ========================
echo ✅ %APP_NAME% installed successfully
echo 📍 Location: %INSTALL_DIR%
echo 🖥️  Desktop shortcut created
echo 📌 Start Menu entry added
echo � Double-click desktop icon to launch
echo.
echo 💡 Tips:
echo - Right-click taskbar icon and "Pin to taskbar"
echo - Works completely offline
echo - All data saved locally on your computer
echo.
echo 📧 Support: qasimaziz007@gmail.com
echo 🌐 Live Demo: https://qasimaziz007-tech.github.io/cashbook/
echo.

set /p LAUNCH="Launch app now? (y/n): "
if /i "%LAUNCH%"=="y" (
    echo 🚀 Launching application...
    start "" "%INSTALL_DIR%\launch.bat"
)

echo.
echo Happy accounting! 💰
pause