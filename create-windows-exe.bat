@echo off
REM Esthetics Auto CashBook - Windows Executable Creator
REM Creates a portable executable for Windows

setlocal EnableDelayedExpansion

set APP_NAME=Esthetics Auto CashBook
set INSTALL_DIR=%USERPROFILE%\Desktop\%APP_NAME%
set EXE_NAME=CashBook.exe

echo 🖥️ Creating Windows Executable: %APP_NAME%
echo =============================================

REM Remove existing installation
if exist "%INSTALL_DIR%" (
    echo 🗑️ Removing existing installation...
    rmdir /s /q "%INSTALL_DIR%"
)

echo 📁 Creating application directory...
mkdir "%INSTALL_DIR%"

REM Download or copy HTML file
if exist "index.html" (
    echo 📋 Using local HTML file...
    copy "index.html" "%INSTALL_DIR%\"
) else (
    echo 📥 Downloading latest version...
    powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/qasimaziz007-tech/cashbook/main/index.html' -OutFile '%INSTALL_DIR%\index.html'}"
)

if not exist "%INSTALL_DIR%\index.html" (
    echo ❌ Failed to get application file
    pause
    exit /b 1
)

REM Create batch launcher
echo 📝 Creating launcher executable...
> "%INSTALL_DIR%\%EXE_NAME%.bat" echo @echo off
>> "%INSTALL_DIR%\%EXE_NAME%.bat" echo title %APP_NAME%
>> "%INSTALL_DIR%\%EXE_NAME%.bat" echo cd /d "%%~dp0"
>> "%INSTALL_DIR%\%EXE_NAME%.bat" echo.
>> "%INSTALL_DIR%\%EXE_NAME%.bat" echo REM Hide this console window
>> "%INSTALL_DIR%\%EXE_NAME%.bat" echo if not DEFINED IS_MINIMIZED set IS_MINIMIZED=1 ^&^& start "" /min "%%~dpnx0" %%* ^&^& exit
>> "%INSTALL_DIR%\%EXE_NAME%.bat" echo.
>> "%INSTALL_DIR%\%EXE_NAME%.bat" echo REM Launch in best available browser
>> "%INSTALL_DIR%\%EXE_NAME%.bat" echo set "HTML_PATH=%%CD%%\index.html"
>> "%INSTALL_DIR%\%EXE_NAME%.bat" echo set "FILE_URL=file:///%%HTML_PATH:\=/%%"
>> "%INSTALL_DIR%\%EXE_NAME%.bat" echo.
>> "%INSTALL_DIR%\%EXE_NAME%.bat" echo if exist "%%ProgramFiles%%\Google\Chrome\Application\chrome.exe" (
>> "%INSTALL_DIR%\%EXE_NAME%.bat" echo     start "" "%%ProgramFiles%%\Google\Chrome\Application\chrome.exe" --app="%%FILE_URL%%" --new-window --disable-web-security
>> "%INSTALL_DIR%\%EXE_NAME%.bat" echo ^) else if exist "%%ProgramFiles(x86)%%\Google\Chrome\Application\chrome.exe" (
>> "%INSTALL_DIR%\%EXE_NAME%.bat" echo     start "" "%%ProgramFiles(x86)%%\Google\Chrome\Application\chrome.exe" --app="%%FILE_URL%%" --new-window --disable-web-security
>> "%INSTALL_DIR%\%EXE_NAME%.bat" echo ^) else if exist "%%ProgramFiles%%\Mozilla Firefox\firefox.exe" (
>> "%INSTALL_DIR%\%EXE_NAME%.bat" echo     start "" "%%ProgramFiles%%\Mozilla Firefox\firefox.exe" --new-window "%%FILE_URL%%"
>> "%INSTALL_DIR%\%EXE_NAME%.bat" echo ^) else if exist "%%ProgramFiles%%\Microsoft\Edge\Application\msedge.exe" (
>> "%INSTALL_DIR%\%EXE_NAME%.bat" echo     start "" "%%ProgramFiles%%\Microsoft\Edge\Application\msedge.exe" --app="%%FILE_URL%%" --new-window
>> "%INSTALL_DIR%\%EXE_NAME%.bat" echo ^) else (
>> "%INSTALL_DIR%\%EXE_NAME%.bat" echo     start "" "index.html"
>> "%INSTALL_DIR%\%EXE_NAME%.bat" echo ^)

REM Create a VBS script to run batch file silently (acts like EXE)
echo 📝 Creating silent launcher...
> "%INSTALL_DIR%\%EXE_NAME%.vbs" echo Set WshShell = CreateObject("WScript.Shell"^)
>> "%INSTALL_DIR%\%EXE_NAME%.vbs" echo WshShell.Run chr(34^) ^& "%INSTALL_DIR%\%EXE_NAME%.bat" ^& Chr(34^), 0
>> "%INSTALL_DIR%\%EXE_NAME%.vbs" echo Set WshShell = Nothing

REM Create desktop shortcut
echo 🔗 Creating desktop shortcut...
set SHORTCUT_PATH=%USERPROFILE%\Desktop\%APP_NAME%.lnk
powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%SHORTCUT_PATH%'); $Shortcut.TargetPath = '%INSTALL_DIR%\%EXE_NAME%.vbs'; $Shortcut.WorkingDirectory = '%INSTALL_DIR%'; $Shortcut.Description = '%APP_NAME% - Professional CashBook Management'; $Shortcut.Save()"

REM Create Start Menu shortcut
echo 📌 Creating Start Menu shortcut...
set STARTMENU_PATH=%APPDATA%\Microsoft\Windows\Start Menu\Programs\%APP_NAME%.lnk
powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%STARTMENU_PATH%'); $Shortcut.TargetPath = '%INSTALL_DIR%\%EXE_NAME%.vbs'; $Shortcut.WorkingDirectory = '%INSTALL_DIR%'; $Shortcut.Description = '%APP_NAME% - Professional CashBook Management'; $Shortcut.Save()"

REM Create README file
echo 📄 Creating README...
> "%INSTALL_DIR%\README.txt" echo %APP_NAME%
>> "%INSTALL_DIR%\README.txt" echo ========================
>> "%INSTALL_DIR%\README.txt" echo.
>> "%INSTALL_DIR%\README.txt" echo Professional CashBook Management System
>> "%INSTALL_DIR%\README.txt" echo.
>> "%INSTALL_DIR%\README.txt" echo HOW TO USE:
>> "%INSTALL_DIR%\README.txt" echo - Double-click desktop shortcut to launch
>> "%INSTALL_DIR%\README.txt" echo - Or run %EXE_NAME%.vbs from this folder
>> "%INSTALL_DIR%\README.txt" echo - Login: admin / admin123
>> "%INSTALL_DIR%\README.txt" echo.
>> "%INSTALL_DIR%\README.txt" echo FEATURES:
>> "%INSTALL_DIR%\README.txt" echo - Complete transaction management
>> "%INSTALL_DIR%\README.txt" echo - Employee and payroll system
>> "%INSTALL_DIR%\README.txt" echo - Advanced analytics and reports
>> "%INSTALL_DIR%\README.txt" echo - Auto backup and data export
>> "%INSTALL_DIR%\README.txt" echo - Works completely offline
>> "%INSTALL_DIR%\README.txt" echo.
>> "%INSTALL_DIR%\README.txt" echo SUPPORT: qasimaziz007@gmail.com
>> "%INSTALL_DIR%\README.txt" echo.
>> "%INSTALL_DIR%\README.txt" echo Made with ❤️ by Qasim Aziz

echo.
echo 🎉 Windows Executable Created Successfully!
echo ==========================================
echo ✅ Location: %INSTALL_DIR%
echo 📁 Main file: %EXE_NAME%.vbs
echo 🖥️ Desktop shortcut: %APP_NAME%.lnk  
echo 📌 Start Menu: Available in Start Menu
echo 📄 Documentation: README.txt
echo.
echo 💡 Usage:
echo - Double-click desktop shortcut to launch
echo - App will open in your default browser (app mode)
echo - All data saved locally on your computer
echo - Works without internet connection
echo.

set /p LAUNCH="Launch app now? (y/n): "
if /i "%LAUNCH%"=="y" (
    echo 🚀 Launching application...
    start "" "%INSTALL_DIR%\%EXE_NAME%.vbs"
)

echo.
echo 💰 Happy accounting!
pause