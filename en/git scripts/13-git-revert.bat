@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: Load utilities
call "%~dp0utils.bat"

:: Set colors manually if not loaded
if not defined ESC (
    for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
)
if "%GREEN%"=="" set "GREEN=%ESC%[92m"
if "%YELLOW%"=="" set "YELLOW=%ESC%[93m"
if "%RED%"=="" set "RED=%ESC%[91m"
if "%WHITE%"=="" set "WHITE=%ESC%[97m"
if "%BLUE%"=="" set "BLUE=%ESC%[94m"
if "%RESET%"=="" set "RESET=%ESC%[0m"

cls
echo %WHITE%╔══════════════════════════════════════════════════════════════╗%RESET%
echo %WHITE%║              🔄 UNDO COMMIT (GIT REVERT)                     ║%RESET%
echo %WHITE%╚══════════════════════════════════════════════════════════════╝%RESET%
echo.

:: Check if there are commits
git log -1 >nul 2>&1
if errorlevel 1 (
    echo %RED%❌ No commits in repository!%RESET%
    pause
    exit /b 0
)

:: Show recent commits
echo %WHITE%Last 10 commits:%RESET%
echo ----------------------------------------
git log --oneline --graph -10
echo ----------------------------------------
echo.

echo %WHITE%What do you want to do?%RESET%
echo %GREEN%  1.%RESET% Undo last commit
echo %YELLOW%  2.%RESET% Undo specific commit (by hash)
echo %BLUE%  3.%RESET% Undo multiple commits (range)
echo %RED%  0.%RESET% Cancel
echo.

set /p "revert_type=%WHITE%Choose (0-3): %RESET%"

if "%revert_type%"=="0" (
    echo %YELLOW%⚠ Operation cancelled%RESET%
    pause
    exit /b 0
)

if "%revert_type%"=="1" (
    echo.
    echo %WHITE%Last commit:%RESET%
    git log -1 --oneline
    echo.
    set /p "confirm=%YELLOW%Undo last commit? (y/n): %RESET%"
    if /i "!confirm!"=="y" (
        echo.
        echo ⏳ Running revert...
        git revert HEAD --no-edit 2>&1
        if errorlevel 1 (
            echo %RED%❌ Error undoing commit!%RESET%
            echo %YELLOW%💡 Possible solutions:%RESET%
            echo   1. If there are conflicts, fix them and run: git revert --continue
            echo   2. To abort: git revert --abort
            echo   3. For manual message: git revert HEAD
            echo.
            git status
        ) else (
            echo %GREEN%✅ Commit successfully undone! New revert commit created.%RESET%
        )
    ) else (
        echo %YELLOW%❌ Cancelled%RESET%
    )
    goto END
)

if "%revert_type%"=="2" (
    echo.
    set /p "commit_hash=%WHITE%Enter commit hash to undo: %RESET%"
    
    if "!commit_hash!"=="" (
        echo %RED%❌ Hash not specified!%RESET%
        pause
        exit /b 0
    )
    
    :: Check if commit exists
    git cat-file -e %commit_hash% 2>nul
    if errorlevel 1 (
        echo %RED%❌ Commit '%commit_hash%' not found!%RESET%
        pause
        exit /b 0
    )
    
    echo.
    echo %WHITE%Commit to undo:%RESET%
    echo ----------------------------------------
    git show %commit_hash% --stat --oneline
    echo ----------------------------------------
    echo.
    set /p "confirm=%YELLOW%Undo this commit? (y/n): %RESET%"
    
    if /i "!confirm!"=="y" (
        echo.
        echo ⏳ Running revert...
        git revert %commit_hash% --no-edit 2>&1
        if errorlevel 1 (
            echo %RED%❌ Error undoing commit!%RESET%
            echo %YELLOW%💡 Possible solutions:%RESET%
            echo   1. If there are conflicts, fix them and run: git revert --continue
            echo   2. To abort: git revert --abort
            echo   3. For manual message: git revert %commit_hash%
            echo.
            git status
        ) else (
            echo %GREEN%✅ Commit successfully undone! New revert commit created.%RESET%
        )
    ) else (
        echo %YELLOW%❌ Cancelled%RESET%
    )
    goto END
)

if "%revert_type%"=="3" (
    echo.
    echo %WHITE%Enter commit range:%RESET%
    echo %YELLOW%  Examples:%RESET%
    echo    - HEAD~3..HEAD     (last 3 commits)
    echo    - 1a2b3c4..5d6e7f8 (range between hashes)
    echo    - HEAD~5..HEAD~1   (commits 2-5 from end)
    echo.
    set /p "range=%WHITE%Range: %RESET%"
    
    if "!range!"=="" (
        echo %RED%❌ Range not specified!%RESET%
        pause
        exit /b 0
    )
    
    echo.
    echo %WHITE%Commits to undo:%RESET%
    echo ----------------------------------------
    git log %range% --oneline 2>nul
    if errorlevel 1 (
        echo %RED%❌ Invalid range format!%RESET%
        pause
        exit /b 0
    )
    echo ----------------------------------------
    echo.
    set /p "confirm=%YELLOW%Undo these commits? (y/n): %RESET%"
    
    if /i "!confirm!"=="y" (
        echo.
        echo ⏳ Running revert range...
        git revert %range% --no-edit 2>&1
        if errorlevel 1 (
            echo %RED%❌ Error undoing commits!%RESET%
            echo %YELLOW%💡 Possible solutions:%RESET%
            echo   1. If there are conflicts, fix them and run: git revert --continue
            echo   2. To abort: git revert --abort
            echo   3. Try undoing commits one by one
            echo.
            git status
        ) else (
            echo %GREEN%✅ Commits successfully undone!%RESET%
        )
    ) else (
        echo %YELLOW%❌ Cancelled%RESET%
    )
    goto END
)

echo %RED%❌ Invalid choice!%RESET%

:END
echo.
pause
exit /b 0