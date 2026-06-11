@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ========================================
echo     APK Install Script
echo ========================================
echo.

set "APK_PATH=%~dp0..\..\build\app\outputs\flutter-apk\app-release.apk"

if not exist "%APK_PATH%" (
    echo [Error] APK file not found: %APK_PATH%
    echo Please run build script first to generate APK
    pause
    exit /b 1
)

echo [Info] APK path: %APK_PATH%
echo.

echo [Info] Checking connected devices...
adb devices
echo.

echo [Info] Installing APK...
adb install -r "%APK_PATH%"

if %ERRORLEVEL% equ 0 (
    echo.
    echo ========================================
    echo     Install Success!
    echo ========================================
) else (
    echo.
    echo ========================================
    echo     Install Failed!
    echo ========================================
)

echo.
pause
