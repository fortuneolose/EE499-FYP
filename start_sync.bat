@echo off
title EE499-FYP Auto-Sync
echo Starting EE499-FYP file watcher...

set "BASH_EXE="
if exist "%ProgramFiles%\Git\bin\bash.exe" set "BASH_EXE=%ProgramFiles%\Git\bin\bash.exe"
if not defined BASH_EXE if exist "%ProgramFiles(x86)%\Git\bin\bash.exe" set "BASH_EXE=%ProgramFiles(x86)%\Git\bin\bash.exe"
if not defined BASH_EXE if exist "%LocalAppData%\Programs\Git\bin\bash.exe" set "BASH_EXE=%LocalAppData%\Programs\Git\bin\bash.exe"
if not defined BASH_EXE if exist "C:\Users\21455956\AppData\Local\Programs\Git\bin\bash.exe" set "BASH_EXE=C:\Users\21455956\AppData\Local\Programs\Git\bin\bash.exe"

if not defined BASH_EXE (
    echo ERROR: Git Bash not found. Install Git for Windows from https://git-scm.com/download/win
    pause
    exit /b 1
)

"%BASH_EXE%" "%~dp0auto_sync.sh" 60
pause
