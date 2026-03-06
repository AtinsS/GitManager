@echo off
chcp 65001 >nul
call "%~dp0utils-en.bat"

echo 🤖 Auto-commits for repository: %~1
echo ====================================

set /p "interval=Interval in minutes (e.g., 5): "
if "!interval!"=="" set interval=5

:: Convert minutes to seconds
set /a "seconds=interval*60"

echo Auto-commits started! Interval: %interval% min.
echo To stop, close the window or press Ctrl+C
echo.
echo Starting at %date% %time%
echo ----------------------------------------

:auto_loop
:: Check if there are changes
git status --porcelain | findstr . >nul
if errorlevel 1 (
    echo [%time%] No changes
) else (
    set "timestamp=%date% %time%"
    git add .
    git commit -m "Auto-commit [%timestamp%]"
    if errorlevel 1 (
        echo [%time%] ❌ Commit error
    ) else (
        echo [%time%] ✅ Changes committed
        
        :: Ask about push
        set /p "push_now=Push now? (y/n): "
        if /i "!push_now!"=="y" (
            git push
            echo [%time%] ✅ Changes pushed
        )
    )
)

:: Wait specified number of seconds
timeout /t %seconds% /nobreak >nul
goto auto_loop