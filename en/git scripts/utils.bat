@echo off
:: Utilities for Git scripts

:: Set encoding
chcp 65001 >nul

:: Color codes with ESC support
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

:: Function to check Git repository
:check_git_repo
git status >nul 2>&1
if errorlevel 1 (
    echo %RED%❌ Current folder is not a Git repository!%RESET%
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

:: Function to get current branch
:get_current_branch
set "CURRENT_BRANCH="
for /f "tokens=*" %%b in ('git branch --show-current 2^>nul') do set "CURRENT_BRANCH=%%b"
if "!CURRENT_BRANCH!"=="" (
    for /f "tokens=2" %%b in ('git branch 2^>nul ^| find "*"') do set "CURRENT_BRANCH=%%b"
)
if "!CURRENT_BRANCH!"=="" set "CURRENT_BRANCH=unknown"
goto :eof

:: Function to check if branch exists
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

:: Function to check if merging is active
:is_merging
git status 2>nul | find "merging" >nul
exit /b
goto :eof

:: Function to show commit history
:show_history
set "commit_count=%~1"
if "%commit_count%"=="" set commit_count=10
git log --oneline --graph -%commit_count%
goto :eof

:: Function to check if commit exists
:commit_exists
git cat-file -e %~1 2>nul
exit /b
goto :eof

:: Function to get last commit
:get_last_commit
for /f "tokens=1" %%c in ('git log -1 --format="%%h"') do set "LAST_COMMIT=%%c"
goto :eof