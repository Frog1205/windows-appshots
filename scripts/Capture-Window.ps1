param(
  [string]$OutputDir = "$env:USERPROFILE\.codex\appshots\windows",
  [int]$DelaySeconds = 2,
  [switch]$IncludeText,
  [int]$MaxTextNodes = 250
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ($DelaySeconds -gt 0) {
  Start-Sleep -Seconds $DelaySeconds
}

Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

Add-Type @"
using System;
using System.Runtime.InteropServices;
using System.Text;

public static class Win32Appshot {
  [DllImport("user32.dll")]
  public static extern IntPtr GetForegroundWindow();

  [DllImport("user32.dll")]
  public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

  [DllImport("user32.dll", SetLastError=true)]
  public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);

  [DllImport("user32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
  public static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);

  [DllImport("user32.dll", SetLastError=true)]
  public static extern bool SetProcessDPIAware();

  [StructLayout(LayoutKind.Sequential)]
  public struct RECT {
    public int Left;
    public int Top;
    public int Right;
    public int Bottom;
  }
}
"@

[void][Win32Appshot]::SetProcessDPIAware()

$hwnd = [Win32Appshot]::GetForegroundWindow()
if ($hwnd -eq [IntPtr]::Zero) {
  throw "No foreground window found."
}

$rect = New-Object Win32Appshot+RECT
if (-not [Win32Appshot]::GetWindowRect($hwnd, [ref]$rect)) {
  throw "Could not read foreground window bounds."
}

$width = [Math]::Max(1, $rect.Right - $rect.Left)
$height = [Math]::Max(1, $rect.Bottom - $rect.Top)

$titleBuilder = New-Object System.Text.StringBuilder 1024
[void][Win32Appshot]::GetWindowText($hwnd, $titleBuilder, $titleBuilder.Capacity)
$title = $titleBuilder.ToString()

$processId = 0
[void][Win32Appshot]::GetWindowThreadProcessId($hwnd, [ref]$processId)
$processName = $null
try {
  $processName = (Get-Process -Id $processId -ErrorAction Stop).ProcessName
} catch {
  $processName = "unknown"
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
$timestamp = (Get-Date).ToUniversalTime().ToString("yyyyMMdd-HHmmss")
$safeProcess = ($processName -replace "[^A-Za-z0-9_.-]", "_")
$baseName = "$timestamp-$safeProcess"
$pngPath = Join-Path $OutputDir "$baseName.png"
$jsonPath = Join-Path $OutputDir "$baseName.json"
$mdPath = Join-Path $OutputDir "$baseName.md"

$bitmap = New-Object System.Drawing.Bitmap $width, $height
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
try {
  $graphics.CopyFromScreen($rect.Left, $rect.Top, 0, 0, (New-Object System.Drawing.Size $width, $height))
  $bitmap.Save($pngPath, [System.Drawing.Imaging.ImageFormat]::Png)
} finally {
  $graphics.Dispose()
  $bitmap.Dispose()
}

$uiText = @()
if ($IncludeText) {
  try {
    Add-Type -AssemblyName UIAutomationClient
    Add-Type -AssemblyName UIAutomationTypes
    $root = [System.Windows.Automation.AutomationElement]::FromHandle($hwnd)
    $queue = New-Object "System.Collections.Generic.Queue[System.Windows.Automation.AutomationElement]"
    if ($null -ne $root) {
      $queue.Enqueue($root)
    }
    while ($queue.Count -gt 0 -and $uiText.Count -lt $MaxTextNodes) {
      $node = $queue.Dequeue()
      $name = $node.Current.Name
      if (-not [string]::IsNullOrWhiteSpace($name)) {
        $controlType = $node.Current.ControlType.ProgrammaticName -replace "^ControlType\.", ""
        $uiText += [pscustomobject]@{
          controlType = $controlType
          name = $name
        }
      }
      $children = $node.FindAll([System.Windows.Automation.TreeScope]::Children, [System.Windows.Automation.Condition]::TrueCondition)
      foreach ($child in $children) {
        if ($queue.Count + $uiText.Count -lt $MaxTextNodes) {
          $queue.Enqueue($child)
        }
      }
    }
  } catch {
    $uiText += [pscustomobject]@{
      controlType = "Error"
      name = "UI Automation text capture failed: $($_.Exception.Message)"
    }
  }
}

$result = [pscustomobject]@{
  capturedAtUtc = (Get-Date).ToUniversalTime().ToString("o")
  title = $title
  processId = $processId
  processName = $processName
  hwnd = $hwnd.ToInt64()
  bounds = [pscustomobject]@{
    left = $rect.Left
    top = $rect.Top
    width = $width
    height = $height
  }
  imagePath = $pngPath
  metadataPath = $jsonPath
  markdownPath = $mdPath
  uiText = $uiText
}

$result | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $jsonPath -Encoding UTF8

$md = @(
  "# Windows Appshot"
  ""
  "- Captured UTC: $($result.capturedAtUtc)"
  "- Window title: $title"
  "- Process: $processName ($processId)"
  "- Image: $pngPath"
  "- Metadata: $jsonPath"
  ""
  "![Windows appshot]($pngPath)"
)

if ($IncludeText -and $uiText.Count -gt 0) {
  $md += ""
  $md += "## UI Text"
  foreach ($item in $uiText) {
    $md += "- [$($item.controlType)] $($item.name)"
  }
}

$md | Set-Content -LiteralPath $mdPath -Encoding UTF8

$result | ConvertTo-Json -Depth 8
