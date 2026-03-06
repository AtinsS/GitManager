@echo off
chcp 65001 >nul
call "%~dp0utils-en.bat"

echo 🔀 Switch branch for repository: %~1
echo ==========================================

:: Show all branches
echo Available branches:
echo ----------------
git branch -a
echo.

:: Choose branch
set /p "branch_name=Enter branch name to switch to: "

:: Check for uncommitted changes
git status --porcelain | findstr . >nul
if errorlevel 0 (
    echo ⚠ You have uncommitted changes!
    set /p "stash=Stash them? (y/n): "
    if /i "!stash!"=="y" (
        git stash
        echo Changes stashed
    )
)

:: Switch branch
git checkout !branch_name!
if errorlevel 1 (
    echo ❌ Error switching to branch '!branch_name!'
) else (
    echo ✅ Switched to branch '!branch_name!'
    
    :: If changes were stashed, offer to restore
    if /i "!stash!"=="y" (
        set /p "apply=Restore stashed changes? (y/n): "
        if /i "!apply!"=="y" (
            git stash pop
        )
    )
)

echo.
pause