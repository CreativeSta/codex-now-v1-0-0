param(
    [Parameter(Mandatory = $false)]
    [string]$TargetDir
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Windows.Forms

$logFile = Join-Path $env:USERPROFILE ".codex-now-launch.log"
function Write-LaunchLog([string]$message) {
    $line = "$(Get-Date -Format s)  $message"
    Add-Content -LiteralPath $logFile -Value $line -Encoding UTF8
}

$mainLauncher = Join-Path $env:USERPROFILE "bin\codex-now.cmd"
if (-not (Test-Path -LiteralPath $mainLauncher -PathType Leaf)) {
    [System.Windows.Forms.MessageBox]::Show(
        "Launcher not found: $mainLauncher`nPlease run install.bat first.",
        "Codex Now",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    ) | Out-Null
    exit 1
}

if ([string]::IsNullOrWhiteSpace($TargetDir)) {
    $TargetDir = $env:USERPROFILE
}

# Explorer may pass extra wrapping quotes; normalize aggressively.
$rawTargetDir = $TargetDir
$TargetDir = $TargetDir.Trim()
$TargetDir = $TargetDir.Trim('"').Trim("'")

if (-not (Test-Path -LiteralPath $TargetDir -PathType Container)) {
    $TargetDir = $env:USERPROFILE
}

$TargetDir = [System.IO.Path]::GetFullPath($TargetDir)
if ($TargetDir.Length -gt 3) {
    $TargetDir = $TargetDir.TrimEnd('\')
}

Write-LaunchLog "raw='$rawTargetDir' normalized='$TargetDir'"
# Start-Process does not auto-quote .cmd arguments; quote explicitly for paths with spaces.
$quotedTargetDir = '"' + $TargetDir + '"'
Write-LaunchLog "launchArg=$quotedTargetDir"
Start-Process -FilePath $mainLauncher -WorkingDirectory $TargetDir -ArgumentList @($quotedTargetDir) -WindowStyle Normal | Out-Null
