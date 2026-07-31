# recover-missing-images.ps1
#
# Recovers the 128 images that are referenced by posts but missing from
# content/assets/uploads/ (casualties of the original WordPress -> Hugo migration).
#
# RUN THIS ON YOUR OWN MACHINE from the repo root. It could NOT be run from the
# build server because WordPress.com IP-blocks that datacenter's media requests.
#
#   pwsh ./recover-missing-images.ps1
#
# It downloads each image, saves it under content/assets/uploads/, and writes any
# it still could not find to still-missing-images.txt. Then commit the new files.

$base = 'newsqldbawiththebeard'
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

$ok = 0; $skip = 0; $fail = @()
foreach ($p in $paths) {
    $rel  = $p -replace '^/assets/uploads/', ''            # e.g. 2017/07/foo.png
    $dest = Join-Path 'content/assets/uploads' $rel
    if (Test-Path $dest) { $skip++; continue }
    $dir = Split-Path $dest -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }

    $urls = @(
        "https://i0.wp.com/$base.wordpress.com/wp-content/uploads/$rel",   # Jetpack CDN (usually works)
        "https://$base.wordpress.com/wp-content/uploads/$rel",             # direct
        "https://$base.files.wordpress.com/$rel"                          # files subdomain
    )
    $done = $false
    foreach ($u in $urls) {
        try {
            Invoke-WebRequest -Uri $u -OutFile $dest -UseBasicParsing -TimeoutSec 30 `
                -Headers @{ 'User-Agent' = 'Mozilla/5.0'; 'Referer' = "https://$base.wordpress.com/" }
            if ((Get-Item $dest).Length -gt 200) { $done = $true; break }
            Remove-Item $dest -Force -ErrorAction SilentlyContinue
        } catch { }
    }
    if ($done) { $ok++; Write-Host "OK   $rel" -ForegroundColor Green }
    else       { $fail += $p; Write-Host "MISS $rel" -ForegroundColor Yellow }
}

Write-Host ""
Write-Host "Recovered $ok, already-present $skip, still-missing $($fail.Count) of $($paths.Count)."
if ($fail.Count) {
    $fail | Set-Content 'still-missing-images.txt'
    Write-Host "Wrote still-missing-images.txt (these may be permanently gone)."
}
Write-Host "Next: git add content/assets/uploads ; git commit -m 'recover missing images from WordPress'"
