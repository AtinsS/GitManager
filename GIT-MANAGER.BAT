@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: Простые цвета
set "GREEN=[92m"
set "YELLOW=[93m"
set "RED=[91m"
set "RESET=[0m"

:: Пути к файлам
set "SCRIPT_DIR=%~dp0"
set "RU_MAIN=%SCRIPT_DIR%ru\GIT-MANAGER-RU.bat"
set "EN_MAIN=%SCRIPT_DIR%en\GIT-MANAGER-EN.bat"

:: Проверка Git
where git >nul 2>nul || (
    echo %YELLOW%Git not found! Please install Git for Windows: https://git-scm.com/%RESET%
    pause
    exit /b
)

:: Автоопределение языка
set "LANG=EN"

:: Способ 1: Проверка через реестр (язык интерфейса)
for /f "tokens=3" %%a in ('reg query "HKCU\Control Panel\Desktop" /v PreferredUILanguages 2^>nul') do (
    echo %%a | findstr /i "ru" >nul && set "LANG=RU"
)

:: Способ 2: Если не нашли, пробуем через системную локаль
if "!LANG!"=="EN" (
    for /f "tokens=2 delims==" %%a in ('wmic os get OSLanguage /value 2^>nul') do set "OSLANG=%%a"
    if "!OSLANG!"=="1049" set "LANG=RU"
    if "!OSLANG!"=="25" set "LANG=RU"
)

:: Способ 3: Проверка языковой раскладки клавиатуры
if "!LANG!"=="EN" (
    reg query "HKCU\Keyboard Layout\Preload" /s 2>nul | findstr /i "0419" >nul && set "LANG=RU"
)

:: Запуск нужной версии
if "%LANG%"=="RU" (
    if exist "%RU_MAIN%" (
        call "%RU_MAIN%"
    ) else (
        echo %RED%Ошибка: не найден файл %RU_MAIN%%RESET%
        pause
    )
) else (
    if exist "%EN_MAIN%" (
        call "%EN_MAIN%"
    ) else (
        echo %RED%Error: file not found %EN_MAIN%%RESET%
        pause
    )
)