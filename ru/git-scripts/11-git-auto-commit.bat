@echo off
chcp 65001 >nul
call "%~dp0utils.bat"

echo 🤖 Авто-коммиты для репозитория: %~1
echo ====================================

set /p "interval=Интервал в минутах (например: 5): "
if "!interval!"=="" set interval=5

:: Конвертируем минуты в секунды
set /a "seconds=interval*60"

echo Авто-коммиты запущены! Интервал: %interval% мин.
echo Для остановки закройте окно или нажмите Ctrl+C
echo.
echo Начинаю работу в %date% %time%
echo ----------------------------------------

:auto_loop
:: Проверяем есть ли изменения
git status --porcelain | findstr . >nul
if errorlevel 1 (
    echo [%time%] Нет изменений
) else (
    set "timestamp=%date% %time%"
    git add .
    git commit -m "Авто-коммит [%timestamp%]"
    if errorlevel 1 (
        echo [%time%] ❌ Ошибка коммита
    ) else (
        echo [%time%] ✅ Изменения закоммичены
        
        :: Спрашиваем про push
        set /p "push_now=Отправить сейчас? (y/n): "
        if /i "!push_now!"=="y" (
            git push
            echo [%time%] ✅ Изменения отправлены
        )
    )
)

:: Ждем указанное количество секунд
timeout /t %seconds% /nobreak >nul
goto auto_loop