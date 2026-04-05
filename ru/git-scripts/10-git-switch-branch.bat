@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
call "%~dp0utils.bat"

cls
echo %GREEN%🔀 Переключение ветки для репозитория: %~1%RESET%
echo %WHITE%==========================================%RESET%
echo.

echo %WHITE%Доступные ветки:%RESET%
echo ----------------
git branch -a
echo.

set /p "branch_name=%WHITE%Введите название ветки для переключения: %RESET%"

:: Исправленная проверка (было errorlevel 0, нужно errorlevel 1)
git status --porcelain | findstr . >nul 2>&1
if not errorlevel 1 (
    echo %YELLOW%⚠ У вас есть неподтвержденные изменения!%RESET%
    set /p "stash=%YELLOW%Спрятать их? (y/n): %RESET%
    if /i "!stash!"=="y" (
        git stash
        echo %GREEN%Изменения спрятаны%RESET%
        set "stashed=1"
    )
)

git checkout !branch_name! 2>&1
if errorlevel 1 (
    echo %RED%❌ Ошибка при переключении на ветку '!branch_name!'%RESET%
) else (
    echo %GREEN%✅ Переключено на ветку '!branch_name!'%RESET%
    
    if defined stashed (
        set /p "apply=%YELLOW%Восстановить спрятанные изменения? (y/n): %RESET%
        if /i "!apply!"=="y" (
            git stash pop
            echo %GREEN%Изменения восстановлены%RESET%
        )
    )
)

echo.
pause