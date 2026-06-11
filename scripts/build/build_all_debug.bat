@echo off

REM Build all platforms in Debug mode

cls
echo Building all platforms in Debug mode...
echo ==================================

REM Build Android Debug
call scripts\build\android\build_debug.bat

if %ERRORLEVEL% equ 0 (
    echo.
echo ==================================
echo Android Debug build completed
) else (
    echo Android Debug build failed!
    pause
    exit /b 1
)

REM Build iOS Debug
call scripts\build\ios\build_debug.bat

if %ERRORLEVEL% equ 0 (
    echo.
echo ==================================
echo iOS Debug build completed
) else (
    echo iOS Debug build failed!
    pause
    exit /b 1
)

REM Build Linux Debug
call scripts\build\linux\build_debug.bat

if %ERRORLEVEL% equ 0 (
    echo.
echo ==================================
echo Linux Debug build completed
) else (
    echo Linux Debug build failed!
    pause
    exit /b 1
)

REM Build Windows Debug
call scripts\build\windows\build_debug.bat

if %ERRORLEVEL% equ 0 (
    echo.
echo ==================================
echo Windows Debug build completed
) else (
    echo Windows Debug build failed!
    pause
    exit /b 1
)

echo ==================================
echo All Debug builds completed successfully!
echo ==================================
pause
