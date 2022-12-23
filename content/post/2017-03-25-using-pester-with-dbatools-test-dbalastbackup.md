---
title: "Using Pester with dbatools Test-DbaLastBackup"
categories:
  - Blog

tags:
  - automate
  - automation
  - backup
  - backups
  - dbatools
  - pester
  - PowerShell
  - restore

---
<P>In <A href="https://blog.robsewell.com/testing-your-sql-server-backups-the-easy-way-with-powershell-dbatools/">previous posts</A> I have shown how to use <A href="https://dbatools.io/functions/test-dbalastbackup/" target=_blank>Test-DbaLastBackup</A> from <A href="https://dbatools.io" target=_blank>dbatools</A> and <A href="https://blog.robsewell.com/taking-dbatools-test-dbalastbackup-a-little-further/" target=_blank>how you can make use of the results</A>. Today we will look at using &nbsp;<A href="https://github.com/pester/Pester" target=_blank>Pester</A>&nbsp;with the results</P>
<BLOCKQUOTE>
<P>Pester provides a framework for <STRONG>running unit tests to execute and validate PowerShell commands from within PowerShell</STRONG>. Pester consists of a simple set of functions that expose a testing domain-specific language (DSL) for isolating, running, evaluating and reporting the results of PowerShell commands.</P></BLOCKQUOTE>
<P>we shall use it to validate our results. First we need to gather our results as we have seen before, In this example I have set the MaxMb to 5 so change that if you are playing along</P><PRE class="lang:ps decode:true">Import-Module dbatools
$TestServer = 'SQL2016N1'
$Server = 'SQL2016N2'
$servers = 'SQL2016N1','SQL2016N2'
$Results = $servers.ForEach{Test-DbaLastBackup -SqlServer $_ -Destination $TestServer -MaxMB 5}</PRE>
<DIV></DIV>
<DIV>Then we need to write some Pester Tests. I tried to use Test Cases which are the correct method to iterate through collections as <A href="http://mikefrobbins.com/2016/12/09/loop-through-a-collection-of-items-with-the-pester-testcases-parameter-instead-of-using-a-foreach-loop/" target=_blank>Mike Robbins shows here</A>&nbsp;but Pester does not accept the type of object that is returned from this command for that. It’s ok though, because Pester is just PowerShell we can use a foreach loop.</DIV>
<DIV></DIV>
<DIV>In this scenario, we are testing&nbsp;for failures rather than when the backup test has skipped due to the file path not being a network share or&nbsp;the size being greater than our max size, so our checks are using the Should Not assertion. I have also added a test for the time the backup was taken.</DIV>
<DIV></DIV>
<DIV><PRE class="lang:ps decode:true">Describe "Last Backup Test results - NOTE THIS IGNORES Skipped restores,DBCC and BackupFiles" {
foreach($result in $results)
{
It "$($Result.Database) on $($Result.SourceServer) File Should Exist" {
$Result.FileExists| Should Not Be 'False'
}
It "$($Result.Database) on $($Result.SourceServer) Restore should be Success" {
$Result.RestoreResult| Should Not Be 'False'
}
It "$($Result.Database) on $($Result.SourceServer) DBCC should be Success" {
$Result.DBCCResult| Should Not Be 'False'
}
It "$($Result.Database) on $($Result.SourceServer) Backup Should be less than a week old" {
$Result.BackupTaken| Should BeGreaterThan (Get-Date).AddDays(-7)
}
}</PRE></DIV>
<DIV></DIV>
<DIV>If we run that we get an output like this. Green is Good Red is Bad 🙂</DIV>
<DIV></DIV>
<DIV><IMG class="alignnone size-full wp-image-4102" alt="01 - pester script.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/01-pester-script.png?resize=630%2C336&amp;ssl=1" width=630 height=336 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/01-pester-script.png?fit=630%2C336&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/01-pester-script.png?fit=300%2C160&amp;ssl=1" data-image-description="" data-image-title="01 – pester script" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="898,479" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/01-pester-script.png?fit=898%2C479&amp;ssl=1" data-permalink="https://blog.robsewell.com/using-pester-with-dbatools-test-dbalastbackup/01-pester-script/#main" data-attachment-id="4102"></DIV>
<DIV></DIV>
<DIV>We can save the script to a file and use the <A href="https://github.com/pester/Pester/wiki/Invoke-Pester" target=_blank>Invoke-Pester</A> to call it like this.</DIV>
<DIV></DIV>
<DIV><PRE class="lang:ps decode:true">Invoke-Pester C:\temp\BackupPester.ps1</PRE></DIV>
<DIV></DIV>
<DIV>(Some Restore Frames removed for brevity)</DIV>
<DIV></DIV>
<DIV><IMG class="alignnone size-full wp-image-4109" alt="02 -invoke pester.gif" src="https://blog.robsewell.com/assets/uploads/2017/03/02-invoke-pester.gif?resize=630%2C329&amp;ssl=1" width=630 height=329 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/02-invoke-pester.gif?fit=630%2C329&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/02-invoke-pester.gif?fit=300%2C156&amp;ssl=1" data-image-description="" data-image-title="02 -invoke pester" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1400,730" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/02-invoke-pester.gif?fit=1400%2C730&amp;ssl=1" data-permalink="https://blog.robsewell.com/using-pester-with-dbatools-test-dbalastbackup/02-invoke-pester/#main" data-attachment-id="4109"></DIV>
<DIV></DIV>
<DIV>invoke-Pester can output results to a file so we can output to XML which can be consumed by many things</DIV>
<DIV></DIV>
<DIV>
<DIV><PRE class="lang:ps decode:true">$Date = Get-Date -Format ddMMyyyHHmmss
$tempFolder = 'c:\temp\BackupTests\'
Push-Location $tempFolder
$XML = $tempFolder + "BackupTestResults_$Date.xml"
$script = 'C:\temp\BackupPester.ps1'
Invoke-Pester -Script $Script -OutputFile $xml -OutputFormat NUnitXml</PRE></DIV></DIV>
<DIV></DIV>
<DIV>will provide an XML file like this</DIV>
<DIV></DIV>
<DIV><IMG class="alignnone size-full wp-image-4116" alt="04 - XML output.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/04-xml-output.png?resize=630%2C282&amp;ssl=1" width=630 height=282 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/04-xml-output.png?fit=630%2C282&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/04-xml-output.png?fit=300%2C134&amp;ssl=1" data-image-description="" data-image-title="04 – XML output" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1602,716" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/04-xml-output.png?fit=1602%2C716&amp;ssl=1" data-permalink="https://blog.robsewell.com/using-pester-with-dbatools-test-dbalastbackup/04-xml-output/#main" data-attachment-id="4116"></DIV>
<DIV></DIV>
<DIV>We can also make use of the reportunit.exe from <A href="http://relevantcodes.com/" target=_blank>http://relevantcodes.com/</A> to create pretty HTML files from the XML files we created</DIV>
<DIV></DIV>
<DIV>This piece of code will download and extract the file if it does not exist in the directory</DIV>
<DIV></DIV>
<DIV>
<DIV>
<DIV><PRE class="lang:ps decode:true">#download and extract ReportUnit.exe
$url = 'http://relevantcodes.com/Tools/ReportUnit/reportunit-1.2.zip'
$fullPath = Join-Path $tempFolder $url.Split("/")[-1]
$reportunit = $tempFolder + '\reportunit.exe'
if((Test-Path $reportunit) -eq $false)
{
(New-Object Net.WebClient).DownloadFile($url,$fullPath)
Expand-Archive -Path $fullPath -DestinationPath $tempFolder
}</PRE></DIV>
<DIV></DIV></DIV>
<DIV>and this will run it against the XML and open the file</DIV></DIV>
<DIV></DIV>
<DIV><PRE class="lang:ps decode:true">##run reportunit against report.xml and display result in browser
$HTML = $tempFolder&nbsp; + 'index.html'
&amp; .\reportunit.exe $tempFolder
Invoke-Item $HTML</PRE></DIV>
<DIV></DIV>
<DIV>which will look&nbsp; like</DIV>
<DIV></DIV>
<DIV><IMG class="alignnone size-full wp-image-4125" alt="03 - pretty html file.gif" src="https://blog.robsewell.com/assets/uploads/2017/03/03-pretty-html-file.gif?resize=630%2C442&amp;ssl=1" width=630 height=442 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/03-pretty-html-file.gif?fit=630%2C442&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/03-pretty-html-file.gif?fit=300%2C210&amp;ssl=1" data-image-description="" data-image-title="03 – pretty html file" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1126,790" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/03-pretty-html-file.gif?fit=1126%2C790&amp;ssl=1" data-permalink="https://blog.robsewell.com/using-pester-with-dbatools-test-dbalastbackup/03-pretty-html-file/#main" data-attachment-id="4125"></DIV>
<DIV></DIV>
<DIV></DIV>
<DIV>Happy Automating</DIV>
<DIV></DIV>
<DIV></DIV>
<DIV></DIV>
<DIV>
<P>NOTE – The major 1.0 release of dbatools due in the summer 2017 may have breaking changes which will stop the above code from working. There are also new commands coming which may replace this command. This blog post was written using dbatools version 0.8.942 You can check your version using</P><PRE class="lang:ps decode:true"> Get-Module dbatools</PRE>
<P>and update it using an Administrator PowerShell session with</P><PRE class="lang:ps decode:true"> Update-Module dbatools</PRE>
<P>You may find that you get no output from Update-Module as you have the latest version. If&nbsp;you have not installed the&nbsp;module from the PowerShell Gallery using</P><PRE class="lang:ps decode:true">Install-Module dbatools</PRE>
<P>Then you can use</P><PRE class="lang:ps decode:true">Update-dbatools</PRE></DIV>
<DIV></DIV>

