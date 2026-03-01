# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Awake - Keep PC awake
# @raycast.mode silent

# Optional parameters:
# @raycast.icon ☕
# @raycast.argument1 { "type": "dropdown", "placeholder": "Duration", "optional": true, "data": [{"title": "30 minutes (display on)", "value": "30"}, {"title": "4 hours (display off)", "value": "240"}] }
# @raycast.description Keep PC awake via PowerToys Awake

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

# Optional dropdown: default 30 min with display on
$minutes = 30
$displayOn = "true"
if ($arg1) {
  $minutes = [int]$arg1
  # 4 hours (240 min) = display off; 30 min = display on
  $displayOn = if ($minutes -eq 240) { "false" } else { "true" }
}

$timeLimitSeconds = $minutes * 60
$args = @("--time-limit", $timeLimitSeconds, "--display-on", $displayOn)
Start-Process -FilePath $AWAKE_EXE -ArgumentList $args
