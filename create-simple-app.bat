@echo off
REM Simple Desktop App Creator for Windows
REM Creates a standalone app without npm dependencies

echo 🚀 Creating Desktop App - Simple Method
echo ======================================

set APP_NAME=Esthetics Auto CashBook
set INSTALL_DIR=%USERPROFILE%\AppData\Local\%APP_NAME%
set DESKTOP_SHORTCUT=%USERPROFILE%\Desktop\%APP_NAME%.lnk
set START_MENU=%APPDATA%\Microsoft\Windows\Start Menu\Programs\%APP_NAME%.lnk

echo 📁 Creating app directory...
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

echo 📋 Copying application files...
copy "index.html" "%INSTALL_DIR%\"

echo 📝 Creating launcher script...
> "%INSTALL_DIR%\launch.bat" echo @echo off
>> "%INSTALL_DIR%\launch.bat" echo REM Esthetics Auto CashBook Launcher
>> "%INSTALL_DIR%\launch.bat" echo cd /d "%%~dp0"
>> "%INSTALL_DIR%\launch.bat" echo.
>> "%INSTALL_DIR%\launch.bat" echo REM Try to launch with default browser in app mode
>> "%INSTALL_DIR%\launch.bat" echo if exist "%%PROGRAMFILES%%\Google\Chrome\Application\chrome.exe" (
>> "%INSTALL_DIR%\launch.bat" echo     "%%PROGRAMFILES%%\Google\Chrome\Application\chrome.exe" --app="file:///%%CD%%\index.html" --new-window
>> "%INSTALL_DIR%\launch.bat" echo ^) else if exist "%%PROGRAMFILES(X86)%%\Google\Chrome\Application\chrome.exe" (
>> "%INSTALL_DIR%\launch.bat" echo     "%%PROGRAMFILES(X86)%%\Google\Chrome\Application\chrome.exe" --app="file:///%%CD%%\index.html" --new-window
>> "%INSTALL_DIR%\launch.bat" echo ^) else if exist "%%PROGRAMFILES%%\Mozilla Firefox\firefox.exe" (
>> "%INSTALL_DIR%\launch.bat" echo     "%%PROGRAMFILES%%\Mozilla Firefox\firefox.exe" -new-window "file:///%%CD%%\index.html"
>> "%INSTALL_DIR%\launch.bat" echo ^) else (
>> "%INSTALL_DIR%\launch.bat" echo     start "" "index.html"
>> "%INSTALL_DIR%\launch.bat" echo ^)

echo 🖥️ Creating desktop shortcut...
powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%DESKTOP_SHORTCUT%'); $Shortcut.TargetPath = '%INSTALL_DIR%\launch.bat'; $Shortcut.WorkingDirectory = '%INSTALL_DIR%'; $Shortcut.Description = 'Professional CashBook Management System'; $Shortcut.Save()"

echo 📌 Creating Start Menu shortcut...
powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%START_MENU%'); $Shortcut.TargetPath = '%INSTALL_DIR%\launch.bat'; $Shortcut.WorkingDirectory = '%INSTALL_DIR%'; $Shortcut.Description = 'Professional CashBook Management System'; $Shortcut.Save()"

echo.
echo 🎉 Installation Complete!
echo ========================
echo ✅ %APP_NAME% has been installed successfully
echo 📍 Location: %INSTALL_DIR%
echo 🖥️  Desktop shortcut created
echo 📌 Start Menu shortcut created
echo 🚀 Double-click desktop icon to launch
echo 📱 Works offline - no internet required
echo.
echo 💡 Tips:
echo - Pin to taskbar for quick access
echo - App opens in browser but acts like desktop app
echo - All data saved locally on your computer
echo.

pause
echo.
echo 🚀 Launching app now...
start "" "%INSTALL_DIR%\launch.bat"