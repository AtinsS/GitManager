@echo off
chcp 65001 >nul
call "%~dp0utils.bat"

echo ⚡ Быстрый Commit + Push для репозитория: %~1
echo ==============================================

:: Получаем текущую дату и время для комментария
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set datetime=%datetime:~0,4%-%datetime:~4,2%-%datetime:~6,2% %datetime:~8,2%:%datetime:~10,2%

:: Автоматический комментарий
set "auto_msg=Авто-коммит %datetime%"

echo Добавление всех изменений...
git add .

echo Создание коммита: "%auto_msg%"
git commit -m "%auto_msg%"

if errorlevel 1 (
    if errorlevel 1 (
        echo ⚠ Нет изменений для коммита?
    ) else (
        echo ❌ Ошибка при коммите!
        pause
        goto :eof
    )
)

echo Отправка в remote...
git push

if errorlevel 1 (
    echo ❌ Ошибка при отправке!
) else (
    echo ✅ Готово! Изменения отправлены с комментарием: "%auto_msg%"
)
echo.
pause