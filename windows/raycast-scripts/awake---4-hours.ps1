# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Awake - 4 hours
# @raycast.mode silent

# Optional parameters:
# @raycast.icon ☕
# @raycast.description Keep PC awake for 4 hours

# Documentation:
# @raycast.author NextMerge
# @raycast.authorURL https://raycast.com/NextMerge
# https://learn.microsoft.com/en-us/windows/powertoys/awake

param([string]$arg1)

$AWAKE_EXE = "$env:ProgramFiles\PowerToys\PowerToys.Awake.exe"
if (-not (Test-Path $AWAKE_EXE)) {
  $AWAKE_EXE = "$env:LocalAppData\Microsoft\WindowsApps\PowerToys.Awake.exe"
}

if (-not (Test-Path $AWAKE_EXE)) {
  Write-Error "PowerToys Awake not found!"
  exit 1
}

$minutes = 60 * 4
$displayOn = "false"

$timeLimitSeconds = $minutes * 60
$args = @("--time-limit", $timeLimitSeconds, "--display-on", $displayOn)
Start-Process -FilePath $AWAKE_EXE -ArgumentList $args

