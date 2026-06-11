@echo off

REM Build Flutter Windows Debug version

cls
echo Building Windows Debug version...

REM Build Windows Debug
flutter build windows --debug

if %ERRORLEVEL% equ 0 (
    echo Build successful!
) else (
    echo Build failed!
    pause
    exit /b 1
)

echo Build completed. Results in build\windows\runner\Debug directory
pause
