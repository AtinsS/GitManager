@echo off
chcp 65001 >nul
call "%~dp0utils-en.bat"

echo ⚡ Quick Commit + Push for repository: %~1
echo ==============================================

:: Get current date and time for comment
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set datetime=%datetime:~0,4%-%datetime:~4,2%-%datetime:~6,2% %datetime:~8,2%:%datetime:~10,2%

:: Automatic comment
set "auto_msg=Auto-commit %datetime%"

echo Adding all changes...
git add .

echo Creating commit: "%auto_msg%"
git commit -m "%auto_msg%"

if errorlevel 1 (
    if errorlevel 1 (
        echo ⚠ No changes to commit?
    ) else (
        echo ❌ Commit error!
        pause
        goto :eof
    )
)

echo Pushing to remote...
git push

if errorlevel 1 (
    echo ❌ Push error!
) else (
    echo ✅ Done! Changes sent with message: "%auto_msg%"
)
echo.
pause