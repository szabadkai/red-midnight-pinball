@echo off
cd /d "%~dp0"
node tools\pinball.mjs play
if errorlevel 1 pause
