@echo off
title EE499-FYP Auto-Sync
echo Starting EE499-FYP file watcher...
"C:\Program Files\Git\bin\bash.exe" "%~dp0auto_sync.sh" 60
pause
