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
if "%RESET%"=="" set "RESET=%ESC%[0m"

cls
echo %WHITE%╔══════════════════════════════════════════════════════════════╗%RESET%
echo %WHITE%║                    🤖 AUTO-COMMITS                           ║%RESET%
echo %WHITE%╚══════════════════════════════════════════════════════════════╝%RESET%
echo.

:: Check if we're in a Git repository
git status >nul 2>&1
if errorlevel 1 (
    echo %RED%❌ Error: Current folder is not a Git repository!%RESET%
    echo.
    echo %YELLOW%💡 Run this script from a Git repository folder%RESET%
    pause
    exit /b 1
)

:: Get interval
set /p "interval=%WHITE%Interval in minutes (e.g., 5): %RESET%"
if "!interval!"=="" set interval=5
if !interval! lss 1 set interval=1

:: Convert minutes to seconds
set /a "seconds=interval*60"

:: Ask about push once
echo.
set /p "auto_push=%WHITE%Auto-push to server? (y/n): %RESET%"
if /i "!auto_push!"=="y" (set "auto_push=1") else (set "auto_push=0")

:: Ask about commit message
echo.
set /p "custom_msg=%WHITE%Custom commit message (Enter - auto message): %RESET%"

echo.
echo %GREEN%✅ Auto-commits started!%RESET%
echo %YELLOW%  Interval: %interval% min (%seconds% sec)%RESET%
if "%auto_push%"=="1" (
    echo %YELLOW%  Auto-push: ENABLED%RESET%
) else (
    echo %YELLOW%  Auto-push: DISABLED%RESET%
)
echo.
echo %RED%  To stop, press Ctrl+C%RESET%
echo.
echo %WHITE%════════════════════════════════════════════════════════════%RESET%
echo.

:auto_loop
:: Check if there are changes
git status --porcelain | findstr . >nul 2>&1
if errorlevel 1 (
    echo [%time%] %YELLOW%📭 No changes%RESET%
) else (
    set "timestamp=%date% %time%"
    
    :: Form commit message
    if "!custom_msg!"=="" (
        set "commit_msg=Auto-commit [!timestamp!]"
    ) else (
        set "commit_msg=!custom_msg! [!timestamp!]"
    )
    
    :: Add all changes
    git add . 2>nul
    
    :: Create commit
    git commit -m "!commit_msg!" 2>nul
    if errorlevel 1 (
        echo [%time%] %RED%❌ Commit error%RESET%
    ) else (
        echo [%time%] %GREEN%✅ Changes committed%RESET%
        echo [%time%]  📝 !commit_msg!
        
        :: Push if enabled
        if "%auto_push%"=="1" (
            echo [%time%] ⏳ Pushing to server...
            git push 2>nul
            if errorlevel 1 (
                echo [%time%] %RED%❌ Push error%RESET%
            ) else (
                echo [%time%] %GREEN%✅ Changes pushed%RESET%
            )
        )
    )
)

:: Wait for specified seconds
timeout /t %seconds% /nobreak >nul 2>&1
goto auto_loop