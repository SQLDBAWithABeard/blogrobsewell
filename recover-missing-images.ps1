# recover-missing-images.ps1
#
# Recovers the images that are referenced by posts but missing from
# content/assets/uploads/ (casualties of the original WordPress -> Hugo migration).
#
# It copies them from a local WordPress media export instead of downloading,
# because WordPress.com blocks media requests from some IPs.
#
# RUN THIS ON YOUR OWN MACHINE from the repo root:
#
#   pwsh ./recover-missing-images.ps1
#   # or with a different export location:
#   pwsh ./recover-missing-images.ps1 -ExportRoot 'E:\Downloads\media-export-46782976-from-0-to-11467'
#
# The export is laid out as <ExportRoot>\YYYY\MM\filename.ext, matching the
# uploads paths. For each missing image it looks in the matching year/month
# folder first, then falls back to a recursive search by filename across the
# whole export. Recovered files are written under content/assets/uploads/ and
# anything still not found is listed in still-missing-images.txt.

param(
    [string]$ExportRoot = 'E:\Downloads\media-export-46782976-from-0-to-11467'
)

$paths = @(
  '/assets/uploads/2013/08/image1.png',
  '/assets/uploads/2013/08/image2.png',
  '/assets/uploads/2013/11/image3.png',
  '/assets/uploads/2013/11/image4.png',
  '/assets/uploads/2014/02/image13.png',
  '/assets/uploads/2014/09/image2.png',
  '/assets/uploads/2014/09/image3.png',
  '/assets/uploads/2014/09/image4.png',
  '/assets/uploads/2014/09/image5.png',
  '/assets/uploads/2014/09/image6.png',
  '/assets/uploads/2014/09/image7.png',
  '/assets/uploads/2014/09/image.png',
  '/assets/uploads/2014/11/1untitled-picture.png',
  '/assets/uploads/2016/01/pester-error1_thumb1.jpg',
  '/assets/uploads/2016/01/pester-error3.jpg',
  '/assets/uploads/2016/01/pester-error3_thumb.jpg',
  '/assets/uploads/2016/01/pester-scripts_thumb.jpg',
  '/assets/uploads/2016/01/pester-success2.jpg',
  '/assets/uploads/2016/01/pester-success2_thumb.jpg',
  '/assets/uploads/2016/01/pester-success_thumb1.jpg',
  '/assets/uploads/2016/05/tweets.png',
  '/assets/uploads/2016/05/tweets.png)](/assets/uploads/2016/05/tweets.png',
  '/assets/uploads/2016/07/agentjobdetail.png',
  '/assets/uploads/2016/07/agent-job-out-gridview.png',
  '/assets/uploads/2016/07/jobhistory.png',
  '/assets/uploads/2016/07/jobs.png',
  '/assets/uploads/2016/07/sqlinstances.png',
  '/assets/uploads/2016/08/start-demo.png',
  '/assets/uploads/2016/09/agentjobhistoryproperties.png',
  '/assets/uploads/2016/09/duration1.png',
  '/assets/uploads/2016/09/formatted.png',
  '/assets/uploads/2016/09/getting-agent-jobs1.png',
  '/assets/uploads/2016/09/insert.png',
  '/assets/uploads/2016/09/methods.png',
  '/assets/uploads/2016/09/padlefterror.png',
  '/assets/uploads/2016/09/padleft-with-string.png',
  '/assets/uploads/2016/09/select.png',
  '/assets/uploads/2016/09/timespan.png',
  '/assets/uploads/2016/09/timespan-property.png',
  '/assets/uploads/2016/10/power1.gif',
  '/assets/uploads/2016/10/power2.gif',
  '/assets/uploads/2016/10/power3b.gif',
  '/assets/uploads/2016/10/powerbi2.png',
  '/assets/uploads/2016/10/powerbi3.png',
  '/assets/uploads/2016/10/powerbi4.gif',
  '/assets/uploads/2016/10/powerbi4.png',
  '/assets/uploads/2016/10/powerbi5.gif',
  '/assets/uploads/2016/10/powerbi5.png',
  '/assets/uploads/2016/10/powerbi6.png)](/assets/uploads/2016/10/powerbi6.png',
  '/assets/uploads/2016/10/powerbi7.png',
  '/assets/uploads/2016/10/powerbi8.gif',
  '/assets/uploads/2016/10/powerbi8.png',
  '/assets/uploads/2016/10/powerbi.png',
  '/assets/uploads/2016/12/deploying.png',
  '/assets/uploads/2016/12/local-admin.png',
  '/assets/uploads/2016/12/login.png',
  '/assets/uploads/2016/12/login-screen.png',
  '/assets/uploads/2016/12/rdp-file.png',
  '/assets/uploads/2016/12/set-up-programmatically1.png',
  '/assets/uploads/2016/12/vm-desktop.png',
  '/assets/uploads/2016/12/wp_20161209_19_21_06_pro.jpg',
  '/assets/uploads/2017/04/01-change-language.gif',
  '/assets/uploads/2017/04/02-extensions-gallery.png',
  '/assets/uploads/2017/04/03-debugging.png',
  '/assets/uploads/2017/04/05-change-settings.gif',
  '/assets/uploads/2017/04/06-compare.gif',
  '/assets/uploads/2017/04/wp_20170408_08_03_34_pro.jpg',
  '/assets/uploads/2017/05/01-pesters.gif',
  '/assets/uploads/2017/05/02-all.gif',
  '/assets/uploads/2017/05/03-none-and-header.png',
  '/assets/uploads/2017/05/04-summary.png',
  '/assets/uploads/2017/05/05-headerdesscribe-sumnmary.png',
  '/assets/uploads/2017/05/07-fails.png',
  '/assets/uploads/2017/05/08-pester-object.png',
  '/assets/uploads/2017/05/c_edtk0xoaa1pl7-2.jpg',
  '/assets/uploads/2017/07/01-sqldiagapi-commands.png',
  '/assets/uploads/2017/07/02-get-help-get-sqldiagfix.png',
  '/assets/uploads/2017/07/03-get-sqldiagfix.png',
  '/assets/uploads/2017/07/05-get-sqldiagfix-outgridview-search.gif',
  '/assets/uploads/2017/07/06-get-sqldiagproduct.png',
  '/assets/uploads/2017/07/07-get-sqldiagfix-product.png',
  '/assets/uploads/2017/07/08-get-sqldiagfix-product-search.png',
  '/assets/uploads/2017/07/10-get-sqldiagfix-by-feature.png',
  '/assets/uploads/2017/07/11-get-sqldiagfix-by-feature-query.png',
  '/assets/uploads/2017/07/12-get-sqldiagfix-by-feature-adn-product.png',
  '/assets/uploads/2017/09/keep-calm-and-PowerShell.jpg',
  '/assets/uploads/2017/09/PowerShell.png',
  '/assets/uploads/2017/11/20171110_114933-compressor.jpg',
  '/assets/uploads/2017/11/find-dbacommand.png',
  '/assets/uploads/2017/11/Testcases-test.png',
  '/assets/uploads/2017/11/whatif.png',
  '/assets/uploads/2018/05/02-creating-containers.png',
  '/assets/uploads/2018/05/03-Containers-at-the-ready.png',
  '/assets/uploads/2018/11/results.pnghttps://blog.robsewell.com/assets/uploads/2018/11/results.png',
  '/assets/uploads/2018/11/results-show.pnghttps://blog.robsewell.com/assets/uploads/2018/11/results-show.png',
  '/assets/uploads/2018/11/run-the-exe-with-powershell.pnghttps://blog.robsewell.com/assets/uploads/2018/11/run-the-exe-with-powershell.png',
  '/assets/uploads/2018/11/speed.png',
  '/assets/uploads/2018/11/striong-name-fail.pnghttps://blog.robsewell.com/assets/uploads/2018/11/striong-name-fail.png',
  '/assets/uploads/2019/03/image-20.png>',
  '/assets/uploads/2019/03/image-21.png>',
  '/assets/uploads/2019/03/image-22.png>',
  '/assets/uploads/2019/03/image-23.png>',
  '/assets/uploads/2019/03/image-24.png>',
  '/assets/uploads/2019/03/image-25.png>',
  '/assets/uploads/2019/03/image-26.png>',
  '/assets/uploads/2019/03/image-27.png>',
  '/assets/uploads/2019/03/image-28.png>',
  '/assets/uploads/2019/04/image-10.png',
  '/assets/uploads/2019/04/image-11.png',
  '/assets/uploads/2019/04/image-12.png',
  '/assets/uploads/2019/04/image-13.png',
  '/assets/uploads/2019/04/image-14.png',
  '/assets/uploads/2019/04/image-152.png',
  '/assets/uploads/2019/04/image-153.png',
  '/assets/uploads/2019/04/image-15.png',
  '/assets/uploads/2019/04/image-18.png',
  '/assets/uploads/2019/04/image-1.png',
  '/assets/uploads/2019/04/image-2.png',
  '/assets/uploads/2019/04/image-3.png',
  '/assets/uploads/2019/04/image-4.png',
  '/assets/uploads/2019/04/image-5.png',
  '/assets/uploads/2019/04/image-7.png',
  '/assets/uploads/2019/04/image-8.png',
  '/assets/uploads/2019/04/image-9.png',
  '/assets/uploads/2019/07/image-1.png',
  '/assets/uploads/2019/11/CloneRepo-2.png',
  '/assets/uploads/2020/02/image-12.png',
  '/assets/uploads/2022/containers2.jpg'
)

if (-not (Test-Path $ExportRoot)) {
    Write-Error "Export folder not found: $ExportRoot`nPass the correct path with -ExportRoot."
    return
}

# The export renames files as "<randomchars>-<originalfilename>", so we can't
# match on an exact basename -- we match the ORIGINAL name as a suffix
# ("*-image-10.png"). But generic paste names like image-10.png recur across
# many months (one copy per editing session), so a bare suffix match is
# ambiguous (8-10 hits each).
#
# The disambiguator is the EDITING SESSION: every image pasted into one post is
# uploaded to the SAME month folder in the export. So we resolve a post's images
# as a GROUP -- all uploads paths that share a referenced folder (e.g. the
# 2019/04 post's image-1..image-18, image-152, image-153). We find the single
# export folder that holds the most of that group's names (its "home" folder,
# revealed by the names that match uniquely, like image-152/153), then take each
# image from that one folder. Within a folder the original name is unique, so
# that collapses every generic name to exactly one file.
#
# Precedence per image: exact same-folder match > lone export-wide match >
# home-folder match > ambiguous (dumped with candidate folders for a manual pick).
Write-Host "Indexing export at $ExportRoot ..." -ForegroundColor Cyan
$rootFull = (Resolve-Path $ExportRoot).Path.TrimEnd('\','/')
$allFiles = @(Get-ChildItem -Path $ExportRoot -Recurse -File)
function Rel-Folder($f) { $f.Directory.FullName.Substring($rootFull.Length).Trim('\','/') -replace '\\','/' }
Write-Host "Indexed $($allFiles.Count) files." -ForegroundColor Cyan

# Files whose name equals $orig or ends with "-$orig" (the hash-prefix form).
function Find-Match($files, $orig) {
    if (-not $files) { return @() }
    $lc = $orig.ToLowerInvariant()
    @($files | Where-Object {
        $n = $_.Name.ToLowerInvariant()
        $n -eq $lc -or $n.EndsWith("-$lc")
    })
}

# Parse + sanitise every path into a work item, grouped by its referenced folder.
$items = @()
foreach ($p in $paths) {
    # Keep only YYYY/MM/filename.ext, dropping any trailing junk
    # (e.g. ")](/assets/...", a doubled "...pnghttps://...", or a trailing ">").
    if ($p -notmatch '/assets/uploads/(?<rel>\d{4}/(?:\d{2}/)?[^/]*?\.(?:png|jpe?g|gif))') {
        Write-Host "SKIP (unparseable) $p" -ForegroundColor DarkGray
        continue
    }
    $rel = $Matches['rel']
    $items += [pscustomobject]@{
        Rel    = $rel
        Name   = Split-Path $rel -Leaf
        Folder = (Split-Path $rel -Parent) -replace '\\','/'
        Dest   = Join-Path 'content/assets/uploads' $rel
        Cands  = Find-Match $allFiles (Split-Path $rel -Leaf)   # export-wide candidates
    }
}

# For each referenced folder, infer the export "home" folder: the export folder
# containing a matching candidate for the most images in the group.
$home = @{}
foreach ($grp in ($items | Group-Object Folder)) {
    $tally = @{}
    foreach ($it in $grp.Group) {
        foreach ($ef in (@($it.Cands | ForEach-Object { Rel-Folder $_ }) | Sort-Object -Unique)) {
            if (-not $tally.ContainsKey($ef)) { $tally[$ef] = 0 }
            $tally[$ef]++
        }
    }
    if ($tally.Count) {
        $best = ($tally.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 1)
        $home[$grp.Name] = $best.Key
        Write-Host ("group {0,-9} -> home export folder '{1}' (covers {2}/{3} images)" -f `
            $grp.Name, $best.Key, $best.Value, $grp.Count) -ForegroundColor Cyan
    }
}

$ok = 0; $skip = 0; $fail = @(); $ambiguous = @()
foreach ($it in $items) {
    if (Test-Path $it.Dest) { $skip++; continue }

    $chosen = $null; $why = ''
    # 1) exact same-folder match (referenced folder present in export)
    $same = @($it.Cands | Where-Object { (Rel-Folder $_) -ieq $it.Folder })
    if ($same.Count -eq 1) { $chosen = $same[0]; $why = 'exact-folder' }
    # 2) a single export-wide candidate -- unambiguous by itself
    elseif ($it.Cands.Count -eq 1) { $chosen = $it.Cands[0]; $why = 'lone' }
    # 3) the group's inferred home folder
    elseif ($home.ContainsKey($it.Folder)) {
        $inHome = @($it.Cands | Where-Object { (Rel-Folder $_) -ieq $home[$it.Folder] })
        if ($inHome.Count -eq 1) { $chosen = $inHome[0]; $why = "home:$($home[$it.Folder])" }
    }

    if ($chosen) {
        $dir = Split-Path $it.Dest -Parent
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        Copy-Item -Path $chosen.FullName -Destination $it.Dest -Force
        $ok++
        $tag = if ($why -eq 'exact-folder') { 'OK  ' } else { 'OK? ' }
        Write-Host "$tag $($it.Rel)  [$why -> $($chosen.Name)]" -ForegroundColor Green
    }
    elseif ($it.Cands.Count -gt 1) {
        Write-Host "AMBIG $($it.Rel)  ($($it.Cands.Count) candidates)" -ForegroundColor Magenta
        $ambiguous += "$($it.Rel):"
        $ambiguous += ($it.Cands | ForEach-Object { "    [$(Rel-Folder $_)]  $($_.FullName)" })
    }
    else {
        $fail += $it.Rel
        Write-Host "MISS  $($it.Rel)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Recovered $ok, already-present $skip, ambiguous $(($ambiguous | Where-Object { $_ -notlike '    *' }).Count), still-missing $($fail.Count)."
Write-Host "Review the 'home:' / OK? picks above -- those are inferred, not exact."
if ($fail.Count) {
    $fail | Set-Content 'still-missing-images.txt'
    Write-Host "Wrote still-missing-images.txt (not found in the export at all)."
}
if ($ambiguous.Count) {
    $ambiguous | Set-Content 'ambiguous-images.txt'
    Write-Host "Wrote ambiguous-images.txt -- candidates listed with their export folder; copy the right one by hand."
}
Write-Host "Next: git add content/assets/uploads ; git commit -m 'recover missing images from WordPress export'"
