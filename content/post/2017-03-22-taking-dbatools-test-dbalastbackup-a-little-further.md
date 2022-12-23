---
title: "Taking dbatools Test-DbaLastBackup a little further"
categories:
  - Blog

tags:
  - automation
  - backups
  - database
  - databases
  - dbatools
  - Excel
  - html
  - json
  - PowerShell
  - restore

---
<P><A href="https://blog.robsewell.com/testing-your-sql-server-backups-the-easy-way-with-powershell-dbatools/" rel="noopener noreferrer" target=_blank>In a previous post </A>I showed how easy it is to test your backups using <A href="https://dbatools.io/functions/Test-DbaLastBackup/" rel="noopener noreferrer" target=_blank>Test-DbaLastBackup</A></P>
<P>Today I thought I would take it a little further and show you how PowerShell can be used to transmit or store this information in the manner you require</P>
<P>Test-DBALastBackup returns an object of information</P>
<P>SourceServer&nbsp; : SQL2016N2<BR>TestServer&nbsp;&nbsp;&nbsp; : SQL2016N2<BR>Database&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; : FadetoBlack<BR>FileExists&nbsp;&nbsp;&nbsp; : True<BR>RestoreResult : Success<BR>DbccResult&nbsp;&nbsp;&nbsp; : Success<BR>SizeMB&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; : 1243.26<BR>BackupTaken&nbsp;&nbsp; : 3/18/2017 12:36:07 PM<BR>BackupFiles&nbsp;&nbsp; : Z:\SQL2016N2\FadetoBlack\FULL_COPY_ONLY\SQL2016N2_FadetoBlack_FULL_COPY_ONLY_20170318_123607.bak</P>
<P>which shows the server, the database name, if the file exists, the restore result, the DBCC result, the size of the backup file, when the backup&nbsp;was taken and the path used</P>
<H2>Text File</H2>
<P>As it is an object we can make use of that in PowerShell. We can output the results to a file</P>
<P>Test-DbaLastBackup -SqlServer sql2016n2 -Destination SQL2016N1 -MaxMB 5 | Out-File C:\temp\Test-Restore.txt<BR>notepad C:\temp\Test-Restore.txt</P><FIGURE class=wp-block-image><IMG class=wp-image-3930 alt="01 - out file.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/01-out-file.png?resize=630%2C270&amp;ssl=1" width=630 height=270 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/01-out-file.png?fit=630%2C270&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/01-out-file.png?fit=300%2C128&amp;ssl=1" data-image-description="" data-image-title="01 – out file" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1365,584" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/01-out-file.png?fit=1365%2C584&amp;ssl=1" data-permalink="https://blog.robsewell.com/taking-dbatools-test-dbalastbackup-a-little-further/01-out-file/#main" data-attachment-id="3930"></FIGURE> 
<H2>CSV</H2>
<P>Or maybe you need a CSV</P><PRE class=wp-block-code><CODE>Test-DbaLastBackup -SqlServer sql2016n2 -Destination SQL2016N1 -MaxMB 5 | Export-Csv C:\temp\Test-Restore.csv -NoTypeInformation</CODE></PRE><FIGURE class=wp-block-image><IMG class=wp-image-3936 alt="02 - csv file.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/02-csv-file.png?resize=630%2C173&amp;ssl=1" width=630 height=173 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/02-csv-file.png?fit=630%2C173&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/02-csv-file.png?fit=300%2C83&amp;ssl=1" data-image-description="" data-image-title="02 – csv file" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1624,447" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/02-csv-file.png?fit=1624%2C447&amp;ssl=1" data-permalink="https://blog.robsewell.com/taking-dbatools-test-dbalastbackup-a-little-further/02-csv-file/#main" data-attachment-id="3936"></FIGURE> 
<H2>JSON</H2>
<P>Maybe you want some json</P><PRE class=wp-block-code><CODE>Test-DbaLastBackup -SqlServer sql2016n2 -Destination SQL2016N1| ConvertTo-Json | Out-file c:\temp\test-results.json</CODE></PRE><FIGURE class=wp-block-image><IMG class=wp-image-3967 alt="06 - json results.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/06-json-results.png?resize=630%2C351&amp;ssl=1" width=630 height=351 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/06-json-results.png?fit=630%2C351&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/06-json-results.png?fit=300%2C167&amp;ssl=1" data-image-description="" data-image-title="06 – json results" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1292,719" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/06-json-results.png?fit=1292%2C719&amp;ssl=1" data-permalink="https://blog.robsewell.com/taking-dbatools-test-dbalastbackup-a-little-further/06-json-results/#main" data-attachment-id="3967"></FIGURE> 
<H2>HTML</H2>
<P>Or an HTML page</P><PRE class="wp-block-code lang:ps decode:true"><CODE>$Results = Test-DbaLastBackup -SqlServer sql2016n2 -Destination SQL2016N1
$Results | ConvertTo-Html | Out-File c:\temp\test-results.html</CODE></PRE><FIGURE class=wp-block-image><IMG class=wp-image-3944 alt="03 - html.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/03-html.png?resize=630%2C228&amp;ssl=1" width=630 height=228 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/03-html.png?fit=630%2C228&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/03-html.png?fit=300%2C108&amp;ssl=1" data-image-description="" data-image-title="03 – html" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1568,567" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/03-html.png?fit=1568%2C567&amp;ssl=1" data-permalink="https://blog.robsewell.com/taking-dbatools-test-dbalastbackup-a-little-further/03-html/#main" data-attachment-id="3944"></FIGURE> 
<H2>Excel</H2>
<P>or perhaps you want a nice colour coded Excel sheet to show your manager or the auditors</P><PRE class="wp-block-code wrap:false minimize:true lang:ps decode:true"><CODE>Import-Module dbatools
$TestServer = 'SQL2016N1'
$Server = 'SQL2016N2'
## Run the test and save to a variable
$Results = Test-DbaLastBackup -SqlServer $server -Destination $TestServer
# Set the filename
$TestDate = Get-Date
$Date = Get-Date -Format ddMMyyy_HHmmss
$filename = 'C:\Temp\TestResults_' + $Date + '.xlsx'
# Create a .com object for Excel
$xl = new-object -comobject excel.application
$xl.Visible = $true # Set this to False when you run in production
$wb = $xl.Workbooks.Add() # Add a workbook
$ws = $wb.Worksheets.Item(1) # Add a worksheet
$cells = $ws.Cells
$col = 1
$row = 3
## Create a legenc
$cells.item($row, $col) = "Legend"
$cells.item($row, $col).font.size = 16
$Cells.item($row, $col).Columnwidth = 10
$Cells.item($row, $col).Interior.ColorIndex = 34
$row ++
$cells.item($row, $col) = "True or Success"
$cells.item($row, $col).font.size = 12
$Cells.item($row, $col).Columnwidth = 10
$Cells.item($row, $col).Interior.ColorIndex = 10
$row ++
$cells.item($row, $col) = "False or Failed"
$cells.item($row, $col).font.size = 12
$Cells.item($row, $col).Columnwidth = 10
$Cells.item($row, $col).Interior.ColorIndex = 3
$row ++
$cells.item($row, $col) = "Skipped"
$cells.item($row, $col).font.size = 12
$Cells.item($row, $col).Columnwidth = 10
$Cells.item($row, $col).Interior.ColorIndex = 16
$row ++
$cells.item($row, $col) = "Backup Under 7 days old"
$cells.item($row, $col).font.size = 12
$Cells.item($row, $col).Columnwidth = 10
$Cells.item($row, $col).Interior.ColorIndex = 4
$row ++
$cells.item($row, $col) = "Backup Over 7 days old"
$cells.item($row, $col).font.size = 12
$Cells.item($row, $col).Columnwidth = 10
$Cells.item($row, $col).Interior.ColorIndex = 3
## Create a header
$col ++
$row = 3
$cells.item($row, $col) = "Source Server"
$cells.item($row, $col).font.size = 16
$Cells.item($row, $col).Columnwidth = 10
$Cells.item($row, $col).Interior.ColorIndex = 34
$col ++
$cells.item($row, $col) = "Test Server"
$cells.item($row, $col).font.size = 16
$Cells.item($row, $col).Columnwidth = 10
$Cells.item($row, $col).Interior.ColorIndex = 34
$col ++
$cells.item($row, $col) = "Database"
$cells.item($row, $col).font.size = 16
$Cells.item($row, $col).Columnwidth = 10
$Cells.item($row, $col).Interior.ColorIndex = 34
$col ++
$cells.item($row, $col) = "File Exists"
$cells.item($row, $col).font.size = 16
$Cells.item($row, $col).Columnwidth = 10
$Cells.item($row, $col).Interior.ColorIndex = 34
$col ++
$cells.item($row, $col) = "Restore Result"
$cells.item($row, $col).font.size = 16
$Cells.item($row, $col).Columnwidth = 10
$Cells.item($row, $col).Interior.ColorIndex = 34
$col ++
$cells.item($row, $col) = "DBCC Result"
$cells.item($row, $col).font.size = 16
$Cells.item($row, $col).Columnwidth = 10
$Cells.item($row, $col).Interior.ColorIndex = 34
$col ++
$cells.item($row, $col) = "Size Mb"
$cells.item($row, $col).font.size = 16
$Cells.item($row, $col).Columnwidth = 10
$Cells.item($row, $col).Interior.ColorIndex = 34
$col ++
$cells.item($row, $col) = "Backup Date"
$cells.item($row, $col).font.size = 16
$Cells.item($row, $col).Columnwidth = 10
$Cells.item($row, $col).Interior.ColorIndex = 34
$col ++
$cells.item($row, $col) = "Backup Files"
$cells.item($row, $col).font.size = 16
$Cells.item($row, $col).Columnwidth = 10
$Cells.item($row, $col).Interior.ColorIndex = 34
$col = 2
$row = 4
foreach ($result in $results) {
    $col = 2
    $cells.item($row, $col) = $Result.SourceServer
    $cells.item($row, $col).font.size = 12
    $Cells.item($row, $col).Columnwidth = 10
    $col ++
    $cells.item($row, $col) = $Result.TestServer
    $cells.item($row, $col).font.size = 12
    $Cells.item($row, $col).Columnwidth = 10
    $col++
    $cells.item($row, $col) = $Result.Database
    $cells.item($row, $col).font.size = 12
    $Cells.item($row, $col).Columnwidth = 10
    $col++
    $cells.item($row, $col) = $Result.FileExists
    $cells.item($row, $col).font.size = 12
    $Cells.item($row, $col).Columnwidth = 10
    if ($result.FileExists -eq 'True') {
        $Cells.item($row, $col).Interior.ColorIndex = 10
    }
    elseif ($result.FileExists -eq 'False') {
        $Cells.item($row, $col).Interior.ColorIndex = 3
    }
    else {
        $Cells.item($row, $col).Interior.ColorIndex = 16
    }
    $col++
    $cells.item($row, $col) = $Result.RestoreResult
    $cells.item($row, $col).font.size = 12
    $Cells.item($row, $col).Columnwidth = 10
    if ($result.RestoreResult -eq 'Success') {
        $Cells.item($row, $col).Interior.ColorIndex = 10
    }
    elseif ($result.RestoreResult -eq 'Failed') {
        $Cells.item($row, $col).Interior.ColorIndex = 3
    }
    else {
        $Cells.item($row, $col).Interior.ColorIndex = 16
    }
    $col++
    $cells.item($row, $col) = $Result.DBCCResult
    $cells.item($row, $col).font.size = 12
    $Cells.item($row, $col).Columnwidth = 10
    if ($result.DBCCResult -eq 'Success') {
        $Cells.item($row, $col).Interior.ColorIndex = 10
    }
    elseif ($result.DBCCResult -eq 'Failed') {
        $Cells.item($row, $col).Interior.ColorIndex = 3
    }
    else {
        $Cells.item($row, $col).Interior.ColorIndex = 16
    }
    $col++
    $cells.item($row, $col) = $Result.SizeMb
    $cells.item($row, $col).font.size = 12
    $Cells.item($row, $col).Columnwidth = 10
    $col++
    $cells.item($row, $col) = $Result.BackupTaken
    $cells.item($row, $col).font.size = 12
    $Cells.item($row, $col).Columnwidth = 10
    if ($result.BackupTaken -gt (Get-Date).AddDays(-7)) {
        $Cells.item($row, $col).Interior.ColorIndex = 4
    }
    else {
        $Cells.item($row, $col).Interior.ColorIndex = 3
    }
    $col++
    $cells.item($row, $col) = $Result.BackupFiles
    $cells.item($row, $col).font.size = 12
    $Cells.item($row, $col).Columnwidth = 10
    $row++
}
[void]$ws.cells.entireColumn.Autofit()
## Add the title after the autofit
$col = 2
$row = 1
$cells.item($row, $col) = "This report shows the results of the test backups performed on $TestServer for $Server on $TestDate"
$cells.item($row, $col).font.size = 18
$Cells.item($row, $col).Columnwidth = 10
$wb.Saveas($filename)
$xl.quit()</CODE></PRE>
<P>It looks like this. Green is Good, Red is Bad, Grey is don’t care!</P><FIGURE class=wp-block-image><IMG class=wp-image-3960 alt="" src="https://blog.robsewell.com/assets/uploads/2017/03/04-excel-pretty.png?resize=630%2C188&amp;ssl=1" width=630 height=188 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/04-excel-pretty.png?fit=630%2C188&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/04-excel-pretty.png?fit=300%2C90&amp;ssl=1" data-image-description="" data-image-title="04 – excel pretty" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1907,570" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/04-excel-pretty.png?fit=1907%2C570&amp;ssl=1" data-permalink="https://blog.robsewell.com/taking-dbatools-test-dbalastbackup-a-little-further/04-excel-pretty/#main" data-attachment-id="3960"></FIGURE> 
<H2>Email</H2>
<P>You might need to email the results, here I am using GMail as an example. With 2 factor authentication you need to use an app password in the credential</P><PRE class=wp-block-code><CODE>Import-Module dbatools
$TestServer = 'SQL2016N1'$Server = 'SQL2016N2'
## Run the test and save to a variable
$Results = Test-DbaLastBackup -SqlServer $server -Destination $TestServer -MaxMB 5
$to = ''
$smtp = 'smtp.gmail.com'
$port = 587
$cred = Get-Credential
$from = 'Beard@TheBeard.Local'
$subject = 'The Beard Reports on Backup Testing'
$Body = $Results | Format-Table | Out-String
Send-MailMessage -To $to -From $from -Body $Body -Subject $subject -SmtpServer $smtp -Priority High -UseSsl -Port $port -Credential $cred&lt;/pre&gt;</CODE></PRE><FIGURE class=wp-block-image><IMG class=wp-image-3973 alt="07 -email" src="https://blog.robsewell.com/assets/uploads/2017/03/07-email.png?resize=630%2C243&amp;ssl=1" width=630 height=243 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/07-email.png?fit=630%2C243&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/07-email.png?fit=300%2C116&amp;ssl=1" data-image-description="" data-image-title="07 -email" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="893,345" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/07-email.png?fit=893%2C345&amp;ssl=1" data-permalink="https://blog.robsewell.com/taking-dbatools-test-dbalastbackup-a-little-further/07-email/#main" data-attachment-id="3973"></FIGURE> 
<P>You can of course attach any of the above files as an attachment using the -attachment parameter in <A href="https://msdn.microsoft.com/en-us/powershell/reference/5.0/microsoft.powershell.utility/send-mailmessage" rel="noreferrer noopener" target=_blank>Send-MailMessage</A></P>
<H2>Database</H2>
<P>Of course, as good data professionals we probably want to put the data into a database where we can ensure that it is kept safe and secure</P>
<P>dbatools has a couple of commands to help with that too. We can use <A href="https://dbatools.io/functions/out-dbadatatable/" rel="noopener noreferrer" target=_blank>Out-DbaDataTable</A> to create a datatable object and <A href="https://dbatools.io/functions/write-dbadatatable/" rel="noopener noreferrer" target=_blank>Write-DbaDatatable</A> to write it to a database</P>
<P>Create a table</P><PRE class="wp-block-code theme:classic lang:tsql decode:true"><CODE>USE [TestResults]
GO
CREATE TABLE [dbo].[backuptest](
[SourceServer] [nvarchar](250) NULL,
[TestServer] [nvarchar](250) NULL,
[Database] [nvarchar](250) NULL,
[FileExists] [nvarchar](10) NULL,
[RestoreResult] [nvarchar](200) NULL,
[DBCCResult] [nvarchar](200) NULL,
[SizeMB] [int] NULL,
[Backuptaken] [datetime] NULL,
[BackupFiles] [nvarchar](300) NULL
) ON [PRIMARY]
GO
</CODE></PRE>
<P>then add the data</P><PRE class="wp-block-code wrap:false lang:ps decode:true"><CODE>Import-Module dbatools
$TestServer = 'SQL2016N1'
$Server = 'SQL2016N2'
$servers = 'SQL2005Ser2003','SQL2012Ser08AG1','SQL2012Ser08AG2','SQL2012Ser08AG3','SQL2014Ser12R2','SQL2016N1','SQL2016N2','SQL2016N3'
## Run the test for each server and save to a variable (This uses PowerShell v4 or above code)
$Results = $servers.ForEach{Test-DbaLastBackup -SqlServer $_ -Destination $TestServer -MaxMB 5}
## Convert to a daatatable.
$DataTable = Out-DbaDataTable -InputObject $Results
## Write to the database
Write-DbaDataTable -SqlServer $Server -Database TestResults -Schema dbo -Table backuptest -KeepNulls -InputObject $DataTable
</CODE></PRE>
<P>and query it</P><FIGURE class=wp-block-image><IMG class=wp-image-4003 alt="08 - Database.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/08-database.png?resize=630%2C336&amp;ssl=1" width=630 height=336 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/08-database.png?fit=630%2C336&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/08-database.png?fit=300%2C160&amp;ssl=1" data-image-description="" data-image-title="08 – Database" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1534,819" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/08-database.png?fit=1534%2C819&amp;ssl=1" data-permalink="https://blog.robsewell.com/taking-dbatools-test-dbalastbackup-a-little-further/08-database/#main" data-attachment-id="4003"></FIGURE> 
<P>Hopefully that has given you some ideas of how you can make use of this great command and also one of the benefits of PowerShell and the ability to use objects for different purposes</P>
<P>Happy Automating</P>
<P>NOTE – The major 1.0 release of dbatools due in the summer 2017 may have breaking changes which will stop the above code from working. There are also new commands coming which may replace this command. This blog post was written using dbatools version 0.8.942 You can check your version using</P><PRE id=block-c17e32c9-7882-4030-930a-edde1c7e881c class=wp-block-code><CODE> Get-Module dbatools</CODE></PRE>
<P>and update it using an Administrator PowerShell session with</P><PRE class="wp-block-code lang:ps decode:true"><CODE> Update-Module dbatools</CODE></PRE>
<P>You may find that you get no output from Update-Module as you have the latest version. If&nbsp;you have not installed the&nbsp;module from the PowerShell Gallery using</P><PRE class="wp-block-code lang:ps decode:true"><CODE>Install-Module dbatools</CODE></PRE>
<P>Then you can use</P><PRE class="wp-block-code lang:ps decode:true"><CODE>Update-dbatools</CODE></PRE>

