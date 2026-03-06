@echo off
:: Утилиты для Git скриптов

:: Установка кодировки
chcp 65001 >nul
setlocal enabledelayedexpansion

:: Цветовые коды (опционально)
set "GREEN=[32m"
set "RED=[31m"
set "YELLOW=[33m"
set "RESET=[0m"

:: Функция проверки Git репозитория
:check_git_repo
git status >nul 2>&1
if errorlevel 1 (
    echo ❌ Текущая папка не является Git репозиторием!
    pause
    exit /b 1
)
goto :eof

:: Функция проверки наличия изменений
:has_changes
git status --porcelain | findstr . >nul
if errorlevel 1 (
    exit /b 1
) else (
    exit /b 0
)
goto :eof