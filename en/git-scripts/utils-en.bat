@echo off
:: Utilities for Git scripts

:: Set encoding
chcp 65001 >nul
setlocal enabledelayedexpansion

:: Color codes (optional)
set "GREEN=[32m"
set "RED=[31m"
set "YELLOW=[33m"
set "RESET=[0m"

:: Function to check Git repository
:check_git_repo
git status >nul 2>&1
if errorlevel 1 (
    echo ❌ Current folder is not a Git repository!
    pause
    exit /b 1
)
goto :eof

:: Function to check if there are changes
:has_changes
git status --porcelain | findstr . >nul
if errorlevel 1 (
    exit /b 1
) else (
    exit /b 0
)
goto :eof