@echo off
:: Утилиты для Git скриптов

:: Установка кодировки
chcp 65001 >nul

:: Цветовые коды с поддержкой ESC
if not defined ESC (
    for /f %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
)
set "GREEN=%ESC%[92m"
set "RED=%ESC%[91m"
set "YELLOW=%ESC%[93m"
set "WHITE=%ESC%[97m"
set "BLUE=%ESC%[94m"
set "CYAN=%ESC%[96m"
set "MAGENTA=%ESC%[95m"
set "BOLD=%ESC%[1m"
set "RESET=%ESC%[0m"

:: Функция проверки Git репозитория
:check_git_repo
git status >nul 2>&1
if errorlevel 1 (
    echo %RED%❌ Текущая папка не является Git репозиторием!%RESET%
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

:: Функция получения текущей ветки
:get_current_branch
set "CURRENT_BRANCH="
for /f "tokens=*" %%b in ('git branch --show-current 2^>nul') do set "CURRENT_BRANCH=%%b"
if "!CURRENT_BRANCH!"=="" (
    for /f "tokens=2" %%b in ('git branch 2^>nul ^| find "*"') do set "CURRENT_BRANCH=%%b"
)
if "!CURRENT_BRANCH!"=="" set "CURRENT_BRANCH=unknown"
goto :eof

:: Функция проверки существования ветки
:branch_exists
git show-ref --verify --quiet "refs/heads/%~1"
if errorlevel 1 (
    git show-ref --verify --quiet "refs/remotes/origin/%~1"
    if errorlevel 1 (
        exit /b 1
    )
)
exit /b 0
goto :eof

:: Функция проверки активного слияния
:is_merging
git status 2>nul | find "merging" >nul
exit /b
goto :eof

:: Функция показа истории коммитов
:show_history
set "commit_count=%~1"
if "%commit_count%"=="" set commit_count=10
git log --oneline --graph -%commit_count%
goto :eof

:: Функция проверки существования коммита
:commit_exists
git cat-file -e %~1 2>nul
exit /b
goto :eof

:: Функция получения последнего коммита
:get_last_commit
for /f "tokens=1" %%c in ('git log -1 --format="%%h"') do set "LAST_COMMIT=%%c"
goto :eof