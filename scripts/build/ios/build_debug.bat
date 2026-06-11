@echo off

REM Build Flutter iOS Debug version

cls
echo Building iOS Debug version...

REM Build iOS Debug version
flutter build ios --debug

if %ERRORLEVEL% equ 0 (
    echo Build successful!
) else (
    echo Build failed!
    pause
    exit /b 1
)

echo Build completed. Results in iOS build directory
pause
