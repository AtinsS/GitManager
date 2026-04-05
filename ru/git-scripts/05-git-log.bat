@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
call "%~dp0utils.bat"

cls
echo %GREEN%📜 Git Log для репозитория: %~1%RESET%
echo %WHITE%================================%RESET%
echo.
echo %GREEN% 1.%RESET% Последние 5 коммитов
echo %GREEN% 2.%RESET% Последние 10 коммитов
echo %GREEN% 3.%RESET% Все коммиты
echo %GREEN% 4.%RESET% Граф коммитов
echo %GREEN% 5.%RESET% Поиск по комментарию
echo %RED% 0.%RESET% Назад
echo.

set /p "log_choice=%WHITE%Выберите: %RESET%"

if "%log_choice%"=="1" git log --oneline -5
if "%log_choice%"=="2" git log --oneline -10
if "%log_choice%"=="3" git log --oneline
if "%log_choice%"=="4" git log --graph --oneline --all
if "%log_choice%"=="5" (
    set /p "search=%WHITE%Введите текст для поиска: %RESET%"
    git log --oneline --grep="!search!"
)
if "%log_choice%"=="0" exit /b

echo.
pause