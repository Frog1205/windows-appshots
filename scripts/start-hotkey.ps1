$ErrorActionPreference = "Stop"

$pluginRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$listener = Join-Path $pluginRoot "src\windows_appshots\hotkey_listener.py"

Start-Process -WindowStyle Hidden -FilePath "python" -ArgumentList @($listener)

Write-Host "Windows Appshots hotkey listener started."
Write-Host "Press Ctrl+Alt+PrintScreen to capture the foreground window."
Write-Host "Snapshots are saved under $env:USERPROFILE\.codex\appshots\windows."
