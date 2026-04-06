@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ЦВЕТА
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "GREEN=%ESC%[92m"
set "YELLOW=%ESC%[93m"
set "RED=%ESC%[91m"
set "CYAN=%ESC%[96m"
set "WHITE=%ESC%[97m"
set "BOLD=%ESC%[1m"
set "RESET=%ESC%[0m"

cls
echo %BOLD%%CYAN%    ОТКАТ НА КОНКРЕТНЫЙ КОММИТ%RESET%
echo.

:: Показываем коммиты
git log --oneline -10
echo.

set /p "commit_hash=%WHITE%Хеш коммита: %RESET%"
if "!commit_hash!"=="" exit /b 0

echo.
echo 1. Мягкий (--soft)
echo 2. Смешанный (--mixed)
echo 3. Жесткий (--hard)
echo 0. Отмена
echo.

set /p "reset_type=%WHITE%Выбор: %RESET%"

if "%reset_type%"=="0" exit /b 0
if "%reset_type%"=="1" git reset --soft %commit_hash%
if "%reset_type%"=="2" git reset --mixed %commit_hash%
if "%reset_type%"=="3" git reset --hard %commit_hash%

echo.
echo %GREEN%✅ Готово!%RESET%
echo.
echo %BOLD%%YELLOW%════════════════════════════════════════════════════════════%RESET%
echo %BOLD%%WHITE%  Нажмите любую клавишу для выхода...%RESET%
echo %BOLD%%YELLOW%════════════════════════════════════════════════════════════%RESET%

cmd /c "pause >nul"

exit /b 0