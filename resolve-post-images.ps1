# resolve-post-images.ps1
#
# Resolves the missing generic-name images (image-1.png, image-10.png, ...) for
# ONE post, using the post's still-present sibling images as anchors.
#
# Why this works: each post's images were uploaded in one consecutive run, so in
# the 2024-07-17 bulk-reimport they occupy a contiguous timestamp block. The
# images from this post that are STILL in the repo have known exact byte sizes;
# we size-match them to their export copies to find that block, then take each
# MISSING image from the same time window (where its name is unique).
#
# Dry-run by default -- prints the proposed mapping. Add -Apply to copy.
#
#   git pull
#   .\resolve-post-images.ps1 -Post content/post/2019-04-05-10501.md
#   .\resolve-post-images.ps1 -Post content/post/2019-04-05-10501.md -Apply
param(
    [Parameter(Mandatory)] [string]$Post,
    [string]$ExportRoot = 'E:\Downloads\media-export-46782976-from-0-to-11467',
    [double]$PadSeconds = 2,
    [switch]$Apply
)

if (-not (Test-Path $Post))       { Write-Error "Post not found: $Post"; return }
if (-not (Test-Path $ExportRoot)) { Write-Error "Export not found: $ExportRoot"; return }

$rootFull = (Resolve-Path $ExportRoot).Path.TrimEnd('\','/')
$all = Get-ChildItem -LiteralPath $ExportRoot -Recurse -File
function RelFolder($f){ $f.Directory.FullName.Substring($rootFull.Length).Trim('\','/') -replace '\\','/' }
function Cands($name){
    $lc = $name.ToLowerInvariant()
    @($all | Where-Object { $_.Name.ToLowerInvariant() -eq $lc -or $_.Name.ToLowerInvariant().EndsWith("-$lc") })
}

# All uploads paths this post references (any year/month, image-*.png or otherwise).
$text = Get-Content -LiteralPath $Post -Raw
$refs = [regex]::Matches($text, 'uploads/(?<rel>\d{4}/(?:\d{2}/)?[^/"\)\s]*?\.(?:png|jpe?g|gif))') |
        ForEach-Object { $_.Groups['rel'].Value } | Sort-Object -Unique

$present = @(); $missing = @()
foreach ($rel in $refs) {
    $dest = Join-Path 'content/assets/uploads' $rel
    $o = [pscustomobject]@{ Rel=$rel; Name=(Split-Path $rel -Leaf); Dest=$dest }
    if (Test-Path $dest) { $present += $o } else { $missing += $o }
}
Write-Host "Post references $($refs.Count) images: $($present.Count) present (anchors), $($missing.Count) missing." -ForegroundColor Cyan

# Anchor: for each present image, find the export copy whose bytes match exactly.
$anchorTimes = @()
foreach ($a in $present) {
    $len = (Get-Item -LiteralPath $a.Dest).Length
    $hit = @(Cands $a.Name | Where-Object { $_.Length -eq $len })
    foreach ($h in $hit) { $anchorTimes += $h.LastWriteTime }
    if ($hit.Count -ge 1) {
        Write-Host ("  anchor {0,-14} {1,9}b -> {2}  @ {3}" -f `
            $a.Name, $len, $hit[0].Name, $hit[0].LastWriteTime.ToString('HH:mm:ss')) -ForegroundColor DarkGray
    }
}
if (-not $anchorTimes.Count) { Write-Host "No size-matched anchors -- cannot pin a block for this post." -ForegroundColor Red; return }

$t0 = ($anchorTimes | Measure-Object -Minimum).Minimum.AddSeconds(-$PadSeconds)
$t1 = ($anchorTimes | Measure-Object -Maximum).Maximum.AddSeconds( $PadSeconds)
Write-Host ("Block window: {0} .. {1}  (from {2} anchor matches)" -f `
    $t0.ToString('HH:mm:ss'), $t1.ToString('HH:mm:ss'), $anchorTimes.Count) -ForegroundColor Cyan

# Resolve each missing image to the unique candidate inside the block window.
$plan = @(); $ambig = @(); $none = @()
foreach ($m in $missing) {
    $inWin = @(Cands $m.Name | Where-Object { $_.LastWriteTime -ge $t0 -and $_.LastWriteTime -le $t1 })
    if ($inWin.Count -eq 1) {
        $plan += [pscustomobject]@{ Item=$m; Src=$inWin[0] }
        Write-Host ("  OK    {0,-14} -> {1}  @ {2}  ({3}b)" -f `
            $m.Name, $inWin[0].Name, $inWin[0].LastWriteTime.ToString('HH:mm:ss'), $inWin[0].Length) -ForegroundColor Green
    } elseif ($inWin.Count -gt 1) {
        $ambig += $m
        Write-Host ("  AMBIG {0,-14} {1} candidates in window:" -f $m.Name, $inWin.Count) -ForegroundColor Magenta
        $inWin | Sort-Object LastWriteTime | ForEach-Object {
            Write-Host ("          {0}  {1,9}b  {2}" -f $_.LastWriteTime.ToString('HH:mm:ss'), $_.Length, $_.Name) }
    } else {
        $none += $m
        Write-Host ("  MISS  {0,-14} (no candidate in window; {1} overall)" -f $m.Name, (Cands $m.Name).Count) -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host ("Plan: copy $($plan.Count), ambiguous $($ambig.Count), none $($none.Count).")
if ($Apply) {
    foreach ($p in $plan) {
        $dir = Split-Path $p.Item.Dest -Parent
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        Copy-Item -LiteralPath $p.Src.FullName -Destination $p.Item.Dest -Force
    }
    Write-Host "Applied: copied $($plan.Count) files. Review, then git add content/assets/uploads." -ForegroundColor Green
} else {
    Write-Host "Dry run. Re-run with -Apply to copy the OK rows." -ForegroundColor Cyan
}
