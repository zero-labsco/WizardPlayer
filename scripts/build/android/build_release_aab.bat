@echo off

REM Build Flutter Android Release AAB (Android App Bundle)
REM AAB is required for Google Play publishing

REM Switch to project root directory (script is in scripts/build/android/)
cd /d "%~dp0..\..\.."

cls
echo Building Android Release AAB...
echo.

REM Check if key.properties exists
if not exist "android\key.properties" (
    echo ERROR: android\key.properties not found!
    echo Please create key.properties file with your keystore info.
    echo See docs\Google-Play-开发者账号指南.md for details.
    echo.
    pause
    exit /b 1
)

REM Check if keystore file exists
if not exist "android\invoice-zero-release-key.jks" (
    echo WARNING: android\invoice-zero-release-key.jks not found!
    echo Make sure you have your keystore file in place.
    echo.
)

REM Build Android App Bundle (with obfuscation)
flutter build appbundle --release --obfuscate --split-debug-info=build/debug_info

if %ERRORLEVEL% equ 0 (
    echo.
    echo ========================================
    echo Build successful!
    echo ========================================
    echo.
    echo Output location:
    echo build\app\outputs\bundle\release\app-release.aab
    echo.
    echo Next steps:
    echo 1. Upload this AAB to Google Play Console
    echo 2. Set up closed testing
    echo 3. Invite testers
    echo.
) else (
    echo.
    echo ========================================
    echo Build failed!
    echo ========================================
    echo.
)

pause
