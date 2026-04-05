@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
call "%~dp0utils.bat"

cls
echo %GREEN%🌿 Creating branch for repository: %~1%RESET%
echo %WHITE%======================================%RESET%
echo.
echo %WHITE%Current branch:%RESET%
git branch --show-current
echo.

set /p "branch_name=%WHITE%Enter new branch name: %RESET%"
if "!branch_name!"=="" (
    echo %RED%❌ Branch name cannot be empty!%RESET%
    pause
    exit /b 0
)

git show-ref --verify --quiet refs/heads/!branch_name!
if errorlevel 1 (
    git branch !branch_name!
    echo %GREEN%✅ Branch '!branch_name!' created!%RESET%
    
    set /p "switch=%YELLOW%Switch to new branch? (y/n): %RESET%"
    if /i "!switch!"=="y" (
        git checkout !branch_name!
        echo %GREEN%✅ Switched to branch '!branch_name!'%RESET%
    )
) else (
    echo %RED%❌ Branch '!branch_name!' already exists!%RESET%
)

echo.
pause