@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
call "%~dp0utils.bat"

cls
echo %GREEN%🔀 Switching branch for repository: %~1%RESET%
echo %WHITE%==========================================%RESET%
echo.

echo %WHITE%Available branches:%RESET%
echo ----------------
git branch -a
echo.

set /p "branch_name=%WHITE%Enter branch name to switch: %RESET%"

:: Check for uncommitted changes
git status --porcelain | findstr . >nul 2>&1
if not errorlevel 1 (
    echo %YELLOW%⚠ You have uncommitted changes!%RESET%
    set /p "stash=%YELLOW%Stash them? (y/n): %RESET%
    if /i "!stash!"=="y" (
        git stash
        echo %GREEN%Changes stashed%RESET%
        set "stashed=1"
    )
)

git checkout !branch_name! 2>&1
if errorlevel 1 (
    echo %RED%❌ Error switching to branch '!branch_name!'%RESET%
) else (
    echo %GREEN%✅ Switched to branch '!branch_name!'%RESET%
    
    if defined stashed (
        set /p "apply=%YELLOW%Restore stashed changes? (y/n): %RESET%
        if /i "!apply!"=="y" (
            git stash pop
            echo %GREEN%Changes restored%RESET%
        )
    )
)

echo.
pause