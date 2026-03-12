param(
    [Parameter(Mandatory = $false)]
    [string]$Version,

    [Parameter(Mandatory = $false)]
    [string]$OutputDir
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function New-DefaultVersion {
    $ts = Get-Date -Format "yyyyMMdd-HHmmss"
    return "dev-$ts"
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path (Join-Path $scriptDir "..")

if ([string]::IsNullOrWhiteSpace($Version)) {
    $Version = New-DefaultVersion
}

if ([string]::IsNullOrWhiteSpace($OutputDir)) {
    $OutputDir = Join-Path $repoRoot "release"
}

$outputPath = Resolve-Path -LiteralPath $OutputDir -ErrorAction SilentlyContinue
if (-not $outputPath) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    $outputPath = Resolve-Path -LiteralPath $OutputDir
}

$windowsDir = Join-Path $repoRoot "windows"
$readmeFile = Join-Path $repoRoot "README.md"

if (-not (Test-Path -LiteralPath $windowsDir -PathType Container)) {
    throw "Missing required directory: $windowsDir"
}
if (-not (Test-Path -LiteralPath $readmeFile -PathType Leaf)) {
    throw "Missing required file: $readmeFile"
}

$packageName = "codex-now-windows-$Version"
$zipFileName = "$packageName.zip"
$zipPath = Join-Path $outputPath $zipFileName
$shaPath = "$zipPath.sha256"

if (Test-Path -LiteralPath $zipPath) {
    Remove-Item -LiteralPath $zipPath -Force
}
if (Test-Path -LiteralPath $shaPath) {
    Remove-Item -LiteralPath $shaPath -Force
}

$tmpRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("codex-now-release-" + [guid]::NewGuid().ToString("N"))
$stagingDir = Join-Path $tmpRoot $packageName

try {
    New-Item -ItemType Directory -Path $stagingDir -Force | Out-Null

    Copy-Item -LiteralPath $readmeFile -Destination $stagingDir -Force
    Copy-Item -LiteralPath $windowsDir -Destination $stagingDir -Recurse -Force

    $licenseFile = Join-Path $repoRoot "LICENSE"
    if (Test-Path -LiteralPath $licenseFile -PathType Leaf) {
        Copy-Item -LiteralPath $licenseFile -Destination $stagingDir -Force
    }

    Compress-Archive -Path $stagingDir -DestinationPath $zipPath -CompressionLevel Optimal -Force

    $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $zipPath).Hash.ToLowerInvariant()
    "$hash *$zipFileName" | Set-Content -LiteralPath $shaPath -NoNewline -Encoding ascii

    Write-Host ""
    Write-Host "Release package created:"
    Write-Host "  ZIP:    $zipPath"
    Write-Host "  SHA256: $shaPath"
    Write-Host ""
    Write-Host "Verify example:"
    Write-Host "  certutil -hashfile `"$zipPath`" SHA256"
}
finally {
    if (Test-Path -LiteralPath $tmpRoot) {
        Remove-Item -LiteralPath $tmpRoot -Recurse -Force
    }
}
