@echo off
chcp 65001 >nul
call "%~dp0utils.bat"

echo 📋 Ветки для слияния
echo ====================
echo.

:: Получаем текущую ветку
for /f "tokens=*" %%b in ('git branch --show-current 2^>nul') do set "current_branch=%%b"
if "!current_branch!"=="" (
    for /f "tokens=2" %%b in ('git branch 2^>nul ^| find "*"') do set "current_branch=%%b"
)
if "!current_branch!"=="" set "current_branch=неизвестно"

echo %GREEN%Текущая ветка: !current_branch!%RESET%
echo.
echo %WHITE%Все ветки (можно сливать любую в текущую):%RESET%
echo ------------------------------------------------

:: Показываем ветки с дополнительной информацией
for /f "tokens=*" %%b in ('git branch -v 2^>nul') do (
    echo %%b | find "*" >nul && (
        echo %GREEN%  %%b%RESET%
    ) || (
        echo %YELLOW%  %%b%RESET%
    )
)

echo.
echo %WHITE%Удаленные ветки:%RESET%
echo ------------------------------------------------
git branch -r 2>nul | findstr /v "HEAD" | findstr /v "->"

echo.
echo %WHITE%💡 Совет:%RESET%
echo   Для слияния ветки в текущую используйте опцию "10" в главном меню
echo   или выполните команду: git merge ^<имя_ветки^>
echo.
pause