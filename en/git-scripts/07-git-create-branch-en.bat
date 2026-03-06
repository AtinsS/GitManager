@echo off
chcp 65001 >nul
call "%~dp0utils-en.bat"

echo 🌿 Create branch for repository: %~1
echo ======================================

:: Show current branch
echo Current branch:
git branch --show-current
echo.

:: Create new branch
set /p "branch_name=Enter new branch name: "
if "!branch_name!"=="" (
    echo ❌ Branch name cannot be empty!
    pause
    goto :eof
)

:: Check if branch already exists
git show-ref --verify --quiet refs/heads/!branch_name!
if errorlevel 1 (
    git branch !branch_name!
    echo ✅ Branch '!branch_name!' created!
    
    set /p "switch=Switch to new branch? (y/n): "
    if /i "!switch!"=="y" (
        git checkout !branch_name!
        echo Switched to branch '!branch_name!'
    )
) else (
    echo ❌ Branch '!branch_name!' already exists!
)

echo.
pause