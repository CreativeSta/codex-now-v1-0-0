param(
    [Parameter(Mandatory = $true)]
    [string]$OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing
Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class NativeMethods {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool DestroyIcon(IntPtr hIcon);
}
"@

$dir = Split-Path -Parent $OutputPath
if (-not (Test-Path -LiteralPath $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}

$bmp = New-Object System.Drawing.Bitmap 64, 64
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.Clear([System.Drawing.Color]::Transparent)

$framePen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 55, 55, 65), 4)
$sandBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 244, 196, 48))
$glassBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(80, 180, 210, 235))

# Top and bottom caps
$g.DrawLine($framePen, 14, 10, 50, 10)
$g.DrawLine($framePen, 14, 54, 50, 54)

# Hourglass frame
$g.DrawLine($framePen, 16, 12, 30, 32)
$g.DrawLine($framePen, 48, 12, 34, 32)
$g.DrawLine($framePen, 30, 32, 16, 52)
$g.DrawLine($framePen, 34, 32, 48, 52)

# Glass interior
$topGlass = [System.Drawing.Point[]]@(
    (New-Object System.Drawing.Point 20, 15),
    (New-Object System.Drawing.Point 44, 15),
    (New-Object System.Drawing.Point 32, 30)
)
$bottomGlass = [System.Drawing.Point[]]@(
    (New-Object System.Drawing.Point 20, 49),
    (New-Object System.Drawing.Point 44, 49),
    (New-Object System.Drawing.Point 32, 34)
)
$g.FillPolygon($glassBrush, $topGlass)
$g.FillPolygon($glassBrush, $bottomGlass)

# Sand
$topSand = [System.Drawing.Point[]]@(
    (New-Object System.Drawing.Point 23, 20),
    (New-Object System.Drawing.Point 41, 20),
    (New-Object System.Drawing.Point 32, 30)
)
$bottomSand = [System.Drawing.Point[]]@(
    (New-Object System.Drawing.Point 24, 48),
    (New-Object System.Drawing.Point 40, 48),
    (New-Object System.Drawing.Point 32, 36)
)
$g.FillPolygon($sandBrush, $topSand)
$g.FillPolygon($sandBrush, $bottomSand)
$g.FillEllipse($sandBrush, 30, 31, 4, 4)

$hicon = [IntPtr]::Zero
$icon = $null
$fs = $null

try {
    $hicon = $bmp.GetHicon()
    $icon = [System.Drawing.Icon]::FromHandle($hicon)
    $fs = New-Object System.IO.FileStream($OutputPath, [System.IO.FileMode]::Create)
    $icon.Save($fs)
}
finally {
    if ($fs) { $fs.Dispose() }
    if ($icon) { $icon.Dispose() }
    if ($hicon -ne [IntPtr]::Zero) { [NativeMethods]::DestroyIcon($hicon) | Out-Null }
    $g.Dispose()
    $bmp.Dispose()
}
