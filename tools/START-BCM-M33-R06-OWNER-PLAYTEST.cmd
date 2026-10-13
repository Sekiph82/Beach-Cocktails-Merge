@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0BCM-M33-R06-Owner-Playtest.ps1"
if errorlevel 1 pause
endlocal
