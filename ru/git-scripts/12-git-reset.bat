@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ============================================
:: ЦВЕТА (если utils.bat не подключён)
:: ============================================
if not defined ESC (
    for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
)
set "RED=%ESC%[91m"
set "GREEN=%ESC%[92m"
set "YELLOW=%ESC%[93m"
set "WHITE=%ESC%[97m"
set "RESET=%ESC%[0m"

:: ============================================
:: ОСНОВНОЙ КОД
:: ============================================
cls
echo %BOLD%%CYAN%    ════════════════════════════════════════════════════════════%RESET%
echo %BOLD%%CYAN%    🔍 ОТКАТ НА КОНКРЕТНЫЙ КОММИТ%RESET%
echo %BOLD%%CYAN%    ════════════════════════════════════════════════════════════%RESET%
echo.

:: Поиск коммита
echo %WHITE%Поиск коммитов по тексту:%RESET%
set /p "search_text=Введите текст для поиска (Enter - показать все): "

if "!search_text!"=="" (
    echo.
    echo %WHITE%Последние 20 коммитов:%RESET%
    echo ----------------------------------------
    git log --oneline --graph -20
    echo ----------------------------------------
) else (
    echo.
    echo %WHITE%Коммиты, содержащие "!search_text!":%RESET%
    echo ----------------------------------------
    git log --oneline --grep="!search_text!" -20
    echo ----------------------------------------
)

echo.
echo %WHITE%Введите хеш коммита (первые 7 символов):%RESET%
set /p "commit_hash=Хеш: "

if "!commit_hash!"=="" (
    echo %RED%❌ Хеш не указан!%RESET%
    pause
    goto :eof
)

:: Показываем информацию о коммите
echo.
echo %WHITE%Информация о коммите %commit_hash%:%RESET%
echo ----------------------------------------
git show %commit_hash% --stat --oneline
echo ----------------------------------------

:: Выбор типа отката
echo.
echo %WHITE%Выберите тип отката:%RESET%
echo %GREEN%  1.%RESET% Мягкий (--soft) - изменения останутся в индексе
echo %YELLOW%  2.%RESET% Смешанный (--mixed) - изменения останутся в рабочей папке
echo %RED%  3.%RESET% Жесткий (--hard) - ВСЕ изменения будут УТЕРЯНЫ!
echo %RED%  0.%RESET% Отмена
echo.

set /p "reset_type=Выберите тип отката (0-3): "

if "%reset_type%"=="0" (
    echo %YELLOW%⚠ Отменено пользователем%RESET%
    pause
    goto :eof
)

if "%reset_type%"=="1" set "reset_mode=--soft"
if "%reset_type%"=="2" set "reset_mode=--mixed"
if "%reset_type%"=="3" set "reset_mode=--hard"

if "%reset_mode%"=="" (
    echo %RED%❌ Неверный выбор!%RESET%
    pause
    goto :eof
)

:: Предупреждение для жесткого отката
if "%reset_mode%"=="--hard" (
    echo.
    echo %RED%╔══════════════════════════════════════════════════════════════╗%RESET%
    echo %RED%║  ⚠ ВНИМАНИЕ! ЖЕСТКИЙ ОТКАТ УДАЛИТ ВСЕ НЕСОХРАНЕННЫЕ ИЗМЕНЕНИЯ! ║%RESET%
    echo %RED%╚══════════════════════════════════════════════════════════════╝%RESET%
    echo.
    set /p "confirm=Вы уверены? Введите 'yes' для подтверждения: "
    if /i not "!confirm!"=="yes" (
        echo %YELLOW%❌ Откат отменен%RESET%
        pause
        goto :eof
    )
)

:: Выполняем откат
echo.
echo ⏳ Выполняется откат %reset_mode% к %commit_hash%...
git reset %reset_mode% %commit_hash% 2>&1

if errorlevel 1 (
    echo %RED%❌ Ошибка при откате!%RESET%
    echo %YELLOW%💡 Проверьте, что хеш коммита верный и у вас есть права%RESET%
) else (
    echo %GREEN%✅ Откат успешно выполнен!%RESET%
    
    if "%reset_mode%"=="--soft" (
        echo %GREEN%📝 Изменения сохранены в индексе (готовы к коммиту)%RESET%
    )
    if "%reset_mode%"=="--mixed" (
        echo %GREEN%📁 Изменения сохранены в рабочей папке%RESET%
    )
    if "%reset_mode%"=="--hard" (
        echo %RED%⚠ Все изменения после выбранного коммита УДАЛЕНЫ!%RESET%
    )
)

echo.
pause
exit /b