# diagnose-image-candidates.ps1  (throwaway; delete after)
# 1) Looks for a manifest that maps the hashed export filenames back to their
#    original WordPress URL/path (the authoritative disambiguator).
# 2) Dumps the import-order block around the 2019/04 anchors as a fallback.
#
# Run it EXACTLY as:  .\diagnose-image-candidates.ps1  > diag-out.txt
# then paste diag-out.txt (or open it).
param([string]$ExportRoot = 'E:\Downloads\media-export-46782976-from-0-to-11467')

$rootFull = (Resolve-Path $ExportRoot).Path.TrimEnd('\','/')

Write-Host '=== (1) TOP-LEVEL of export (non-image files / manifests?) ===' -ForegroundColor Cyan
Get-ChildItem -LiteralPath $ExportRoot | ForEach-Object {
    $kind = if ($_.PSIsContainer) { '<DIR> ' } else { 'file  ' }
    Write-Host ('  ' + $kind + $_.Name + '   ' + $_.Length)
}
Write-Host ''
Write-Host '=== manifest-like files anywhere in export (csv/json/xml/txt/htm) ===' -ForegroundColor Cyan
Get-ChildItem -LiteralPath $ExportRoot -Recurse -File -Include *.csv,*.json,*.xml,*.txt,*.html,*.htm |
    ForEach-Object { Write-Host ('  ' + $_.FullName + '   ' + $_.Length + 'b') }

$all = Get-ChildItem -LiteralPath $ExportRoot -Recurse -File
function RelFolder($f){ $f.Directory.FullName.Substring($rootFull.Length).Trim('\','/') -replace '\\','/' }

# All names referenced by the 2019/04 post (+ the two unique anchors).
$names = @('image-1.png','image-2.png','image-3.png','image-4.png','image-5.png',
           'image-7.png','image-8.png','image-9.png','image-10.png','image-11.png',
           'image-12.png','image-13.png','image-14.png','image-15.png','image-18.png',
           'image-152.png','image-153.png')

Write-Host ''
Write-Host '=== (2) all 2019/04 candidates, in IMPORT ORDER (by timestamp) ===' -ForegroundColor Cyan
$rows = foreach($n in $names){
    $lc = $n.ToLowerInvariant()
    foreach($f in @($all | Where-Object { $_.Name.ToLowerInvariant() -eq $lc -or $_.Name.ToLowerInvariant().EndsWith("-$lc") })){
        [pscustomobject]@{ Name=$n; When=$f.LastWriteTime; Size=$f.Length; File=$f.Name; Full=$f.FullName }
    }
}
foreach($r in ($rows | Sort-Object When, Name)){
    $t    = $r.When.ToString('HH:mm:ss')
    $sz   = ([string]$r.Size).PadLeft(9)
    $nm   = $r.Name.PadRight(14)
    $anch = if ($r.Name -eq 'image-152.png' -or $r.Name -eq 'image-153.png') { ' <== ANCHOR' } else { '' }
    Write-Host ('  ' + $t + '  ' + $nm + $sz + 'b  ' + $r.File + $anch)
}
