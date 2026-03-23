@echo off
:: Получаем путь к папке с батником
set "SCRIPT_DIR=%~dp0"

:MENU_LOOP
cls
echo %BOLD%%CYAN%=== Меню отката ===%RESET%
echo.
echo %GREEN%    1.%RESET% Git reset (откат на коммит назад)
echo %GREEN%    2.%RESET% Git reset на конкретный коммит
echo %GREEN%    3.%RESET% Git revert (отмена коммита с сохранением истории)
echo %RED%    0.%RESET% Вернуться в главное меню	

echo.
set /p "reset_action=%BOLD%%WHITE%    ⚡ Выберите действие: %RESET%"

if "%reset_action%"=="1" (
    if exist "%SCRIPT_DIR%12-git-reset.bat" (
        call "%SCRIPT_DIR%12-git-reset.bat" "%current_repo%"
    ) else (
        echo %RED%    ❌ Скрипт отката не найден%RESET%
        pause
    )
    goto MENU_LOOP
)

if "%reset_action%"=="2" (
    if exist "%SCRIPT_DIR%13-git-reset-commit.bat" (
        call "%SCRIPT_DIR%13-git-reset-commit.bat" "%current_repo%"
    ) else (
        echo %RED%    ❌ Скрипт отката не найден%RESET%
        pause
    )
    goto MENU_LOOP
)

if "%reset_action%"=="3" (
    if exist "%SCRIPT_DIR%14-git-revert.bat" (
        call "%SCRIPT_DIR%14-git-revert.bat" "%current_repo%"
    ) else (
        echo %RED%    ❌ Скрипт отката не найден%RESET%
        pause
    )
    goto MENU_LOOP
)

if "%reset_action%"=="0" (
    exit /b
)

pause
goto MENU_LOOP