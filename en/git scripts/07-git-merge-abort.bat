@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
call "%~dp0utils.bat"

echo ⛔ Aborting merge (MERGE --ABORT)
echo =================================
echo.

:: Check if merge is in progress
git status 2>nul | find "merging" >nul
if errorlevel 1 (
    echo %YELLOW%⚠ No active merge process at the moment%RESET%
    echo.
    set /p "force_abort=Force reset state? (y/n): "
    if /i "!force_abort!"=="y" (
        echo.
        echo ⏳ Running git merge --abort...
        git merge --abort 2>&1
        if errorlevel 1 (
            echo %YELLOW%⚠ Command failed. Possibly no active merge%RESET%
        ) else (
            echo %GREEN%✅ Merge aborted%RESET%
        )
    ) else (
        echo %YELLOW%❌ Cancelled%RESET%
    )
    pause
    exit /b
)

echo %RED%⚠ Active merge process detected!%RESET%
echo.
echo %YELLOW%Running git merge --abort will cancel the current merge%RESET%
echo %YELLOW%and restore the repository to its state before the merge.%RESET%
echo.
set /p "confirm=Confirm merge abort? (y/n): "

if /i not "!confirm!"=="y" (
    echo %YELLOW%❌ Merge abort cancelled%RESET%
    pause
    exit /b
)

echo.
echo ⏳ Running git merge --abort...
git merge --abort 2>&1

if errorlevel 1 (
    echo %RED%❌ Error aborting merge!%RESET%
    echo %YELLOW%📋 Possible reasons:%RESET%
    echo   - No active merge
    echo   - Permission issues
) else (
    echo %GREEN%✅ Merge successfully aborted!%RESET%
    echo %GREEN%📁 Repository restored to original state%RESET%
)

echo.
pause