@echo off

REM Build Flutter Linux Release version

cls
echo Building Linux Release version...

REM Build Linux Release
flutter build linux --release

if %ERRORLEVEL% equ 0 (
    echo Build successful!
) else (
    echo Build failed!
    pause
    exit /b 1
)

echo Build completed. Results in build\linux\x64\release\bundle directory
pause
