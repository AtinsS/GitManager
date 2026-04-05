@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
call "%~dp0utils.bat"

echo 🔀 Merging branches for repository: %~1
echo ======================================
echo.

:: Get current branch
for /f "tokens=*" %%b in ('git branch --show-current 2^>nul') do set "current_branch=%%b"
if "!current_branch!"=="" (
    for /f "tokens=2" %%b in ('git branch 2^>nul ^| find "*"') do set "current_branch=%%b"
)
if "!current_branch!"=="" set "current_branch=unknown"

echo Current branch: %GREEN%!current_branch!%RESET%
echo.
echo %YELLOW%⚠ WARNING: You will merge the selected branch INTO the current branch (!current_branch!)%RESET%
echo.

:: Show all branches
echo Available branches:
echo ----------------
git branch -a
echo.

:: Select branch to merge
set /p "merge_branch=%WHITE%Enter branch name to merge: %RESET%"

if "!merge_branch!"=="" (
    echo %RED%❌ Branch name cannot be empty!%RESET%
    pause
    exit /b
)

:: Check if branch exists (local)
git show-ref --verify --quiet refs/heads/!merge_branch!
if errorlevel 1 (
    :: Check remote branch
    git show-ref --verify --quiet refs/remotes/origin/!merge_branch!
    if errorlevel 1 (
        echo %RED%❌ Branch '!merge_branch!' does not exist!%RESET%
        pause
        exit /b
    ) else (
        echo %YELLOW%⚠ Branch '!merge_branch!' is remote. Not available locally.%RESET%
        set /p "fetch_first=Run git fetch first? (y/n): "
        if /i "!fetch_first!"=="y" (
            git fetch origin !merge_branch!
        )
    )
)

:: Confirmation
echo.
echo %YELLOW%⚠ You are about to merge branch '!merge_branch!' into '!current_branch!'%RESET%
set /p "confirm=Confirm merge? (y/n): "

if /i not "!confirm!"=="y" (
    echo %YELLOW%❌ Merge cancelled%RESET%
    pause
    exit /b
)

:: Check for uncommitted changes before merge
git status --porcelain | findstr . >nul
if not errorlevel 1 (
    echo %YELLOW%⚠ You have uncommitted changes!%RESET%
    set /p "stash=Stash them before merge? (y/n): "
    if /i "!stash!"=="y" (
        git stash
        echo Changes stashed
        set "stashed=1"
    )
)

:: Perform merge
echo.
echo ⏳ Merging...
git merge "!merge_branch!" --no-edit 2>&1

if errorlevel 1 (
    echo.
    echo %RED%❌ MERGE CONFLICT!%RESET%
    echo %YELLOW%📋 Recommendations:%RESET%
    echo   1. Fix conflicts manually in files
    echo   2. Then run: git add . ^&^& git commit -m "Merge resolved"
    echo   3. Or abort merge with: git merge --abort
    echo.
    git status
) else (
    echo %GREEN%✅ Merge completed successfully!%RESET%
)

:: Restore stashed changes if any
if defined stashed (
    echo.
    set /p "apply_stash=Restore stashed changes? (y/n): "
    if /i "!apply_stash!"=="y" (
        git stash pop
        if errorlevel 1 (
            echo %YELLOW%⚠ Possible conflicts when restoring changes%RESET%
        ) else (
            echo Changes restored
        )
    )
)

echo.
pause