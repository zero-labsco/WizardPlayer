@echo off

REM Build all platforms in Release mode

cls
echo Building all platforms in Release mode...
echo ==================================

REM Build Android Release
call scripts\build\android\build_release.bat

if %ERRORLEVEL% equ 0 (
    echo.
echo ==================================
echo Android Release build completed
) else (
    echo Android Release build failed!
    pause
    exit /b 1
)

REM Build iOS Release
call scripts\build\ios\build_release.bat

if %ERRORLEVEL% equ 0 (
    echo.
echo ==================================
echo iOS Release build completed
) else (
    echo iOS Release build failed!
    pause
    exit /b 1
)

REM Build Linux Release
call scripts\build\linux\build_release.bat

if %ERRORLEVEL% equ 0 (
    echo.
echo ==================================
echo Linux Release build completed
) else (
    echo Linux Release build failed!
    pause
    exit /b 1
)

REM Build Windows Release
call scripts\build\windows\build_release.bat

if %ERRORLEVEL% equ 0 (
    echo.
echo ==================================
echo Windows Release build completed
) else (
    echo Windows Release build failed!
    pause
    exit /b 1
)

echo ==================================
echo All Release builds completed successfully!
echo ==================================
pause
