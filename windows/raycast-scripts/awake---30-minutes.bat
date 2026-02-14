@echo off

REM Required parameters:
REM @raycast.schemaVersion 1
REM @raycast.title Awake - 30 minutes
REM @raycast.mode silent

REM Optional parameters:
REM @raycast.icon 🤖
REM @raycast.description Keep PC awake for 30 minutes via PowerToys Awake

REM Documentation:
REM @raycast.author NextMerge
REM @raycast.authorURL https://raycast.com/NextMerge
REM https://learn.microsoft.com/en-us/windows/powertoys/awake

set "AWAKE_EXE=%ProgramFiles%\PowerToys\PowerToys.Awake.exe"
if not exist "%AWAKE_EXE%" set "AWAKE_EXE=%LocalAppData%\Microsoft\WindowsApps\PowerToys.Awake.exe"

if not exist "%AWAKE_EXE%" (
  echo PowerToys Awake not found!
  exit /b 1
)

REM 30 minutes = 1800 seconds; --display-on true keeps screen on
REM Run via PowerShell hidden so no console/prompt appears
powershell -WindowStyle Hidden -NoProfile -Command "Start-Process -FilePath '"%AWAKE_EXE%"' -ArgumentList '--time-limit','1800','--display-on','true' -WindowStyle Hidden"
exit /b 0
