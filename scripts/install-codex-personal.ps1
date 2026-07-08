param(
  [string]$PluginRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
  [string]$MarketplacePath = "$env:USERPROFILE\.agents\plugins\marketplace.json"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$pluginName = "windows-appshots"
$expectedPersonalPluginRoot = Join-Path $env:USERPROFILE "plugins\$pluginName"
$actualPluginRoot = (Resolve-Path $PluginRoot).Path

if ($actualPluginRoot -ne $expectedPersonalPluginRoot) {
  Write-Warning "Codex personal marketplace entries resolve ./plugins/$pluginName to:"
  Write-Warning "  $expectedPersonalPluginRoot"
  Write-Warning "Current plugin root is:"
  Write-Warning "  $actualPluginRoot"
  Write-Warning "For the simplest install, clone this repository to $expectedPersonalPluginRoot."
}

$marketplaceDir = Split-Path -Parent $MarketplacePath
New-Item -ItemType Directory -Force -Path $marketplaceDir | Out-Null

if (Test-Path -LiteralPath $MarketplacePath) {
  $marketplace = Get-Content -Raw -LiteralPath $MarketplacePath | ConvertFrom-Json
} else {
  $marketplace = [pscustomobject]@{
    name = "personal"
    interface = [pscustomobject]@{
      displayName = "Personal"
    }
    plugins = @()
  }
}

if (-not $marketplace.name) {
  $marketplace | Add-Member -NotePropertyName name -NotePropertyValue "personal"
}
if (-not $marketplace.interface) {
  $marketplace | Add-Member -NotePropertyName interface -NotePropertyValue ([pscustomobject]@{ displayName = "Personal" })
}
if (-not $marketplace.plugins) {
  $marketplace | Add-Member -NotePropertyName plugins -NotePropertyValue @()
}

$entry = [pscustomobject]@{
  name = $pluginName
  source = [pscustomobject]@{
    source = "local"
    path = "./plugins/$pluginName"
  }
  policy = [pscustomobject]@{
    installation = "AVAILABLE"
    authentication = "ON_INSTALL"
  }
  category = "Productivity"
}

$plugins = @($marketplace.plugins | Where-Object { $_.name -ne $pluginName })
$plugins += $entry
$marketplace.plugins = $plugins

$json = $marketplace | ConvertTo-Json -Depth 8
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($MarketplacePath, $json, $utf8NoBom)

Write-Host "Updated Codex personal marketplace:"
Write-Host "  $MarketplacePath"
Write-Host ""
Write-Host "Next:"
Write-Host "  codex plugin add windows-appshots@$($marketplace.name)"
