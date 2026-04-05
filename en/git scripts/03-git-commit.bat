@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

call "%~dp0utils.bat"

:: Colors if not loaded
if not defined ESC (
    for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
)
if "%GREEN%"=="" set "GREEN=%ESC%[92m"
if "%YELLOW%"=="" set "YELLOW=%ESC%[93m"
if "%RED%"=="" set "RED=%ESC%[91m"
if "%CYAN%"=="" set "CYAN=%ESC%[96m"
if "%WHITE%"=="" set "WHITE=%ESC%[97m"
if "%BOLD%"=="" set "BOLD=%ESC%[1m"
if "%RESET%"=="" set "RESET=%ESC%[0m"

cls
echo %BOLD%%CYAN%╔════════════════════════════════════════════════════════════════════╗%RESET%
echo %BOLD%%CYAN%║                        📝 GIT COMMIT                              ║%RESET%
echo %BOLD%%CYAN%╚════════════════════════════════════════════════════════════════════╝%RESET%
echo.
echo %WHITE%  📁 Repository: %GREEN%%~1%RESET%
echo.

:: Check Git repository
git status >nul 2>&1
if errorlevel 1 (
    echo %RED%  ❌ Error: Current folder is not a Git repository!%RESET%
    echo.
    echo %YELLOW%  💡 Run this script from a Git repository folder%RESET%
    pause
    exit /b 1
)

:: Show status
echo %BOLD%%WHITE%  📊 Current status:%RESET%
echo %CYAN%  ────────────────────────────────────────────────────────────────────────%RESET%
git status -s
echo %CYAN%  ────────────────────────────────────────────────────────────────────────%RESET%
echo.

:: Check if there are changes
git status --porcelain | findstr . >nul 2>&1
if errorlevel 1 (
    echo %YELLOW%  ⚠ No changes to commit!%RESET%
    echo.
    set /p "continue=%WHITE%  Continue anyway? (y/n): %RESET%"
    if /i not "!continue!"=="y" (
        echo %YELLOW%  ❌ Operation cancelled%RESET%
        pause
        exit /b 0
    )
)

:: Add files
echo %BOLD%%WHITE%  📦 Adding files:%RESET%
echo %YELLOW%    Examples:%RESET%
echo %WHITE%    - Enter %GREEN%→%RESET%%WHITE% all files%RESET%
echo %WHITE%    - file1.txt %GREEN%→%RESET%%WHITE% specific file%RESET%
echo %WHITE%    - *.txt %GREEN%→%RESET%%WHITE% all txt files%RESET%
echo %WHITE%    - src/ %GREEN%→%RESET%%WHITE% entire folder%RESET%
echo.
set /p "files=%WHITE%  Files: %RESET%"

if "!files!"=="" (
    echo %YELLOW%  ⏳ Adding all changes...%RESET%
    git add . 2>nul
) else (
    echo %YELLOW%  ⏳ Adding: %CYAN%!files!%RESET%...
    git add !files! 2>nul
    if errorlevel 1 (
        echo.
        echo %RED%  ❌ Error adding files!%RESET%
        echo %YELLOW%  💡 Check if the specified files exist%RESET%
        pause
        exit /b 1
    )
)

:: Check if there is anything to commit
git diff --cached --quiet
if errorlevel 1 (
    echo %GREEN%  ✅ Files added to index%RESET%
) else (
    echo %RED%  ❌ No files to commit!%RESET%
    pause
    exit /b 1
)

:: Commit
echo.
echo %BOLD%%WHITE%  💾 Creating commit%RESET%
set /p "commit_msg=%WHITE%  Message: %RESET%"
if "!commit_msg!"=="" set "commit_msg=Update %date% %time%"

echo %YELLOW%  ⏳ Creating commit...%RESET%
git commit -m "!commit_msg!" 2>&1

if errorlevel 1 (
    echo.
    echo %RED%  ❌ Commit error!%RESET%
    echo %YELLOW%  💡 Possible reasons:%RESET%
    echo %WHITE%     - Git user not configured%RESET%
    echo %WHITE%     - No changes to commit%RESET%
    echo.
    echo %WHITE%  Configure user:%RESET%
    echo %CYAN%     git config user.name "Your Name"%RESET%
    echo %CYAN%     git config user.email "your@email.com"%RESET%
    pause
    exit /b 1
) else (
    echo %GREEN%  ✅ Commit successfully created!%RESET%
    echo %WHITE%     📝 Message: %CYAN%!commit_msg!%RESET%
)

:: Push
echo.
echo %BOLD%%WHITE%  🚀 Pushing to server:%RESET%
set /p "push_confirm=%YELLOW%  Push changes? (y/n): %RESET%"

if /i "!push_confirm!"=="y" (
    echo %YELLOW%  ⏳ Running git push...%RESET%
    
    for /f "tokens=*" %%b in ('git branch --show-current 2^>nul') do set "branch=%%b"
    if "!branch!"=="" set "branch=main"
    
    echo %WHITE%     Branch: %CYAN%!branch!%RESET%
    echo.
    
    git push 2>&1
    
    if errorlevel 1 (
        echo.
        echo %RED%  ❌ Push error!%RESET%
        echo %YELLOW%  💡 Possible reasons:%RESET%
        echo %WHITE%     - No internet connection%RESET%
        echo %WHITE%     - No write permissions%RESET%
        echo %WHITE%     - Branch not configured for push%RESET%
        echo.
        set /p "retry=%YELLOW%  Try git push -u origin !branch!? (y/n): %RESET%"
        if /i "!retry!"=="y" (
            echo %YELLOW%  ⏳ Retrying...%RESET%
            git push -u origin !branch! 2>&1
            if errorlevel 1 (
                echo %RED%  ❌ Still failing!%RESET%
            ) else (
                echo %GREEN%  ✅ Changes pushed and branch configured!%RESET%
            )
        )
    ) else (
        echo.
        echo %GREEN%  ✅ Changes successfully pushed to server!%RESET%
    )
) else (
    echo %YELLOW%  ⚠ Push cancelled.%RESET%
    echo %WHITE%     💡 To push later: %CYAN%git push%RESET%
)

:: Finish
echo.
echo %BOLD%%GREEN%╔════════════════════════════════════════════════════════════════════╗%RESET%
echo %BOLD%%GREEN%║                         ✅ DONE                                   ║%RESET%
echo %BOLD%%GREEN%╚════════════════════════════════════════════════════════════════════╝%RESET%
echo.
echo %WHITE%  Press any key to exit...%RESET%
pause >nul

exit /b 0