$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$listener = Join-Path $scriptDir "hotkey_listener.py"

Start-Process -WindowStyle Hidden -FilePath "python" -ArgumentList @($listener)

Write-Host "Windows Appshots hotkey listener started."
Write-Host "Press Ctrl+Alt+PrintScreen to capture the foreground window."
Write-Host "Snapshots are saved under $env:USERPROFILE\.codex\appshots\windows."
