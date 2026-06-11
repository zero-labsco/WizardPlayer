@echo off

REM Build Flutter Android Release version

cls
echo Building Android Release version...

REM Build Android Release APK
flutter build apk --release

if %ERRORLEVEL% equ 0 (
    echo Build successful!
) else (
    echo Build failed!
    pause
    exit /b 1
)

echo Build completed. Results in build/app/outputs/apk/release directory
pause
