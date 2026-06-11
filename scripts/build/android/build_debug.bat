@echo off

REM Build Flutter Android Debug version

cls
echo Building Android Debug version...

REM Build Android Debug APK
flutter build apk --debug

if %ERRORLEVEL% equ 0 (
    echo Build successful!
) else (
    echo Build failed!
    pause
    exit /b 1
)

echo Build completed. Results in build/app/outputs/apk/debug directory
pause
