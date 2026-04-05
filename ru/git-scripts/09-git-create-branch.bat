@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
call "%~dp0utils.bat"

cls
echo %GREEN%🌿 Создание ветки для репозитория: %~1%RESET%
echo %WHITE%======================================%RESET%
echo.
echo %WHITE%Текущая ветка:%RESET%
git branch --show-current
echo.

set /p "branch_name=%WHITE%Введите название новой ветки: %RESET%"
if "!branch_name!"=="" (
    echo %RED%❌ Название ветки не может быть пустым!%RESET%
    pause
    exit /b 0
)

git show-ref --verify --quiet refs/heads/!branch_name!
if errorlevel 1 (
    git branch !branch_name!
    echo %GREEN%✅ Ветка '!branch_name!' создана!%RESET%
    
    set /p "switch=%YELLOW%Переключиться на новую ветку? (y/n): %RESET%"
    if /i "!switch!"=="y" (
        git checkout !branch_name!
        echo %GREEN%✅ Переключено на ветку '!branch_name!'%RESET%
    )
) else (
    echo %RED%❌ Ветка '!branch_name!' уже существует!%RESET%
)

echo.
pause