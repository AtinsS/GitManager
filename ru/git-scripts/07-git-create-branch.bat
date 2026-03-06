@echo off
chcp 65001 >nul
call "%~dp0utils.bat"

echo 🌿 Создание ветки для репозитория: %~1
echo ======================================

:: Показываем текущую ветку
echo Текущая ветка:
git branch --show-current
echo.

:: Создание новой ветки
set /p "branch_name=Введите название новой ветки: "
if "!branch_name!"=="" (
    echo ❌ Название ветки не может быть пустым!
    pause
    goto :eof
)

:: Проверяем, существует ли уже такая ветка
git show-ref --verify --quiet refs/heads/!branch_name!
if errorlevel 1 (
    git branch !branch_name!
    echo ✅ Ветка '!branch_name!' создана!
    
    set /p "switch=Переключиться на новую ветку? (y/n): "
    if /i "!switch!"=="y" (
        git checkout !branch_name!
        echo Переключено на ветку '!branch_name!'
    )
) else (
    echo ❌ Ветка '!branch_name!' уже существует!
)

echo.
pause