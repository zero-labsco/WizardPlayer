@echo off

REM Build Flutter iOS Release version

cls
echo Building iOS Release version...

REM Build iOS Release version
flutter build ios --release

if %ERRORLEVEL% equ 0 (
    echo Build successful!
) else (
    echo Build failed!
    pause
    exit /b 1
)

echo Build completed. Results in iOS build directory
pause
