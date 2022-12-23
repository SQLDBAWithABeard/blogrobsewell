---
title: "Test your Sqlserver backups on Linux with PowerShell and dbatools"
categories:
  - Blog

tags:
  - automate
  - backup
  - backups
  - dbatools
  - linux
  - PowerShell

---
<P>I have written about <A href="https://dbatools.io/functions/test-dbalastbackup/" target=_blank>Test-DbaLastBackup</A> in posts <A href="https://blog.robsewell.com/testing-your-sql-server-backups-the-easy-way-with-powershell-dbatools/" target=_blank>here</A>, <A href="https://blog.robsewell.com/taking-dbatools-test-dbalastbackup-a-little-further/">here </A>and<A href="https://blog.robsewell.com/using-pester-with-dbatools-test-dbalastbackup/" target=_blank> here</A>. They have been Windows only posts.</P>
<P>With <A href="https://blogs.technet.microsoft.com/dataplatforminsider/2017/03/17/sql-server-next-version-ctp-1-4-now-available/" target=_blank>SQL Server vNext CTP 1.4 </A>now available and providing SQL Agent capability on Linux, I wrote here about using Ola Hallengrens scripts on Linux SQL Servers so can <A href="https://dbatools.io/functions/test-dbalastbackup/" target=_blank><SPAN style="COLOR: #0066cc">Test-DbaLastBackup</SPAN></A>&nbsp;work with Linux?</P>
<P><IMG class="alignnone size-full wp-image-4288" alt="01 - Yes it does.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/01-yes-it-does.png?resize=630%2C211&amp;ssl=1" width=630 height=211 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/01-yes-it-does.png?fit=630%2C211&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/01-yes-it-does.png?fit=300%2C100&amp;ssl=1" data-image-description="" data-image-title="01 – Yes it does" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1622,542" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/01-yes-it-does.png?fit=1622%2C542&amp;ssl=1" data-permalink="https://blog.robsewell.com/test-your-sqlserver-backups-on-linux-with-powershell-and-dbatools/01-yes-it-does/#main" data-attachment-id="4288"></P>
<P>Yes it does!!</P>
<P>and I caught the database being restored in SSMS as well</P>
<P><IMG class="alignnone size-full wp-image-4291" alt="02 - SSMS.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/02-ssms.png?resize=493%2C477&amp;ssl=1" width=493 height=477 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/02-ssms.png?fit=493%2C477&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/02-ssms.png?fit=300%2C290&amp;ssl=1" data-image-description="" data-image-title="02 – SSMS" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="493,477" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/02-ssms.png?fit=493%2C477&amp;ssl=1" data-permalink="https://blog.robsewell.com/test-your-sqlserver-backups-on-linux-with-powershell-and-dbatools/02-ssms/#main" data-attachment-id="4291"></P>
<P>Happy Automating 🙂</P>
<P>&nbsp;</P>

