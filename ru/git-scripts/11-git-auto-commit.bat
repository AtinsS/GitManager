@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: Подключаем утилиты
call "%~dp0utils.bat"

:: Если utils.bat не задал цвета, устанавливаем вручную
if not defined ESC (
  for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
)
if "%GREEN%"=="" set "GREEN=%ESC%[92m"
if "%YELLOW%"=="" set "YELLOW=%ESC%[93m"
if "%RED%"=="" set "RED=%ESC%[91m"
if "%WHITE%"=="" set "WHITE=%ESC%[97m"
if "%RESET%"=="" set "RESET=%ESC%[0m"

cls
echo %WHITE%╔══════════════════════════════════════════════════════════════╗%RESET%
echo %WHITE%║  🤖 АВТО-КОММИТЫ  ║%RESET%
echo %WHITE%╚══════════════════════════════════════════════════════════════╝%RESET%
echo.

:: Проверяем, что мы в Git-репозитории
git status >nul 2>&1
if errorlevel 1 (
  echo %RED%❌ Ошибка: Текущая папка не является Git репозиторием!%RESET%
  echo.
  echo %YELLOW%💡 Запустите этот скрипт из папки Git-репозитория%RESET%
  pause
  exit /b 1
)

:: Получаем интервал
set /p "interval=%WHITE%Интервал в минутах (например: 5): %RESET%"
if "!interval!"=="" set interval=5
if !interval! lss 1 set interval=1

:: Конвертируем минуты в секунды
set /a "seconds=interval*60"

:: Спрашиваем про push один раз
echo.
set /p "auto_push=%WHITE%Автоматически отправлять на сервер (git push)? (y/n): %RESET%"
if /i "!auto_push!"=="y" (set "auto_push=1") else (set "auto_push=0")

:: Спрашиваем про сообщение коммита
echo.
set /p "custom_msg=%WHITE%Свое сообщение для коммита (Enter - авто-сообщение): %RESET%"

echo.
echo %GREEN%✅ Авто-коммиты запущены!%RESET%
echo %YELLOW%  Интервал: %interval% мин. (%seconds% сек.)%RESET%
if "%auto_push%"=="1" (
  echo %YELLOW%  Авто-отправка: ВКЛЮЧЕНА%RESET%
  ) else (
  echo %YELLOW%  Авто-отправка: ВЫКЛЮЧЕНА%RESET%
)
echo.
echo %RED%  Для остановки нажмите Ctrl+C%RESET%
echo.
echo %WHITE%════════════════════════════════════════════════════════════%RESET%
echo.

:auto_loop
:: Проверяем есть ли изменения
git status --porcelain | findstr . >nul 2>&1
if errorlevel 1 (
  echo [%time%] %YELLOW%📭 Нет изменений%RESET%
  ) else (
  set "timestamp=%date% %time%"
  
  :: Формируем сообщение коммита
  if "!custom_msg!"=="" (
    set "commit_msg=Авто-коммит [!timestamp!]"
    ) else (
    set "commit_msg=!custom_msg! [!timestamp!]"
  )
  
  :: Добавляем все изменения
  git add . 2>nul
  
  :: Создаем коммит
  git commit -m "!commit_msg!" 2>nul
  if errorlevel 1 (
    echo [%time%] %RED%❌ Ошибка коммита%RESET%
    ) else (
    echo [%time%] %GREEN%✅ Изменения закоммичены%RESET%
    echo [%time%]  📝 !commit_msg!
    
    :: Отправляем если включено
    if "%auto_push%"=="1" (
      echo [%time%] ⏳ Отправка на сервер...
      git push 2>nul
      if errorlevel 1 (
        echo [%time%] %RED%❌ Ошибка отправки%RESET%
        ) else (
        echo [%time%] %GREEN%✅ Изменения отправлены%RESET%
      )
    )
  )
)

:: Ждем указанное количество секунд
timeout /t %seconds% /nobreak >nul 2>&1
goto auto_loop

pause
exit /b 0
