# ─────────────────────────────────────────────────────────────
# Downloads all 8 Hibana flower assets from Figma MCP URLs
# into projects/hibana-assets/
#
# Run this from your portfolio ROOT directory in PowerShell:
#   .\download-hibana-assets.ps1
#
# If you get a "running scripts is disabled" error, run this
# first (one-time, current session only):
#   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
# ─────────────────────────────────────────────────────────────

$dest = "projects\hibana-assets"
New-Item -ItemType Directory -Force -Path $dest | Out-Null

$flowers = @{
    "joy-gerbera"               = "4f86816e-3769-4e65-8faa-b241e57f5373"
    "fear-anemone"               = "97522c3f-7ddf-4472-a6e1-ceee9484914b"
    "surprise-bird-of-paradise"  = "94814faf-5182-441f-9d1f-28fd1bc4d38c"
    "embarrassment-peony"        = "13cde614-f942-4862-8326-5b7e12023b1f"
    "love-agapanthus"            = "cd6c648d-33ef-494d-b8fe-b5cc06c00794"
    "curiosity-hydrangea"        = "4fd73719-f725-4019-950f-9a085ff3065a"
    "anger-celosia"               = "da14d2aa-3d82-4870-a894-b28d930f902e"
    "sadness-gentian"            = "08aea47f-ba51-4920-b78e-2a461b780e4c"
}

$succeeded = @()
$failed = @()

foreach ($name in $flowers.Keys) {
    $uuid = $flowers[$name]
    $url  = "https://www.figma.com/api/mcp/asset/$uuid"
    $out  = Join-Path $dest "$name.png"

    Write-Host "-> $name.png"

    try {
        Invoke-WebRequest -Uri $url -OutFile $out -ErrorAction Stop
        $size = (Get-Item $out).Length
        if ($size -lt 1000) {
            Write-Host "   WARNING: small file ($size bytes) - may be an error response" -ForegroundColor Yellow
            $failed += $name
        } else {
            Write-Host "   OK - $size bytes" -ForegroundColor Green
            $succeeded += $name
        }
    } catch {
        Write-Host "   FAILED - URL likely expired ($($_.Exception.Message))" -ForegroundColor Red
        if (Test-Path $out) { Remove-Item $out }
        $failed += $name
    }
}

Write-Host ""
Write-Host "-----------------------------"
Write-Host "Success: $($succeeded.Count) / 8"
Write-Host "Failed:  $($failed.Count) / 8"

if ($failed.Count -gt 0) {
    Write-Host ""
    Write-Host "Re-export these from Figma directly and drop into $dest\ with matching filenames:"
    foreach ($f in $failed) { Write-Host "  - $f.png" }
}
