@echo off

REM Build Flutter Linux Debug version

cls
echo Building Linux Debug version...

REM Build Linux Debug
flutter build linux --debug

if %ERRORLEVEL% equ 0 (
    echo Build successful!
) else (
    echo Build failed!
    pause
    exit /b 1
)

echo Build completed. Results in build\linux\x64\debug\bundle directory
pause
