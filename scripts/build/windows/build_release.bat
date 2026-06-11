@echo off

REM Build Flutter Windows Release version

cls
echo Building Windows Release version...

REM Build Windows Release
flutter build windows --release

if %ERRORLEVEL% equ 0 (
    echo Build successful!
) else (
    echo Build failed!
    pause
    exit /b 1
)

echo Build completed. Results in build\windows\runner\Release directory
pause
