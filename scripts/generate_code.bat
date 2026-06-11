@echo off

REM Change to project root directory
cd /d %~dp0..

REM Generate localization files
echo Generating localization files...
call flutter gen-l10n

if %errorlevel% neq 0 (
    echo Failed to generate localization files!
    pause
    exit /b %errorlevel%
)

echo Localization files generated successfully!

REM Generate Freezed code
echo Generating Freezed code...
call flutter pub run build_runner build --delete-conflicting-outputs

if %errorlevel% neq 0 (
    echo Failed to generate Freezed code!
    pause
    exit /b %errorlevel%
)

echo Freezed code generated successfully!

echo All code generation tasks completed!
pause