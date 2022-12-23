---
title: "Max Length of a column in a DataTable in PowerShell"
categories:
  - Blog

tags:
  - datatable
  - PowerShell
  - snippet
  - snippets

---
<P>Whilst I was writing my <A href="https://dbatools.io/functions/test-dbalastbackup/" rel=noopener target=_blank>Test-DbaLastBackup</A> Posts I ran into a common error I get when importing datatables into a database</P>
<P>I was using this table</P>
<P><IMG class="alignnone size-full wp-image-4014" alt="01 - table" src="https://blog.robsewell.com/assets/uploads/2017/03/01-table.png?resize=404%2C233&amp;ssl=1" width=404 height=233 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/01-table.png?fit=404%2C233&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/01-table.png?fit=300%2C173&amp;ssl=1" data-image-description="" data-image-title="01 – table" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="404,233" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/01-table.png?fit=404%2C233&amp;ssl=1" data-permalink="https://blog.robsewell.com/max-length-of-a-column-in-a-datatable-in-powershell/01-table/#main" data-attachment-id="4014"></P>
<P>and when I tried to add the results of the Test-DbaLastBackup I got this</P>
<P><IMG class="alignnone size-full wp-image-4018" alt="02 -error.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/02-error.png?resize=630%2C85&amp;ssl=1" width=630 height=85 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/02-error.png?fit=630%2C85&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/02-error.png?fit=300%2C40&amp;ssl=1" data-image-description="" data-image-title="02 -error" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1201,162" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/02-error.png?fit=1201%2C162&amp;ssl=1" data-permalink="https://blog.robsewell.com/max-length-of-a-column-in-a-datatable-in-powershell/02-error/#main" data-attachment-id="4018"></P>
<BLOCKQUOTE>
<P>Exception calling “WriteToServer” with “1” argument(s): “The given value of type String from the data source cannot be converted to type nvarchar of the<BR>specified target column.”<BR>At line:356 char:4<BR>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; $bulkCopy.WriteToServer($InputObject)<BR>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~<BR>+ CategoryInfo&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; : NotSpecified: (:) [], MethodInvocationException<BR>+ FullyQualifiedErrorId : InvalidOperationException</P></BLOCKQUOTE>
<P>Hmm, it says that it can’t convert a string to a nvarchar, that doesn’t sound right.To find out what was happening I used a little bit of code that I use every single day</P><PRE class="lang:ps decode:true"> $Error[0] | Fl -force</PRE>
<P>All errors from your current session are stored in the $error array so [0] accesses the most recent one and fl is an alias for <A href="https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.utility/format-list" rel=noopener target=_blank>Format-List</A> and the force switch expands the object. This is what I saw</P>
<P><IMG class="alignnone size-full wp-image-4028" alt="03 expanded error.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/03-expanded-error.png?resize=630%2C355&amp;ssl=1" width=630 height=355 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/03-expanded-error.png?fit=630%2C355&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/03-expanded-error.png?fit=300%2C169&amp;ssl=1" data-image-description="" data-image-title="03 expanded error" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1298,731" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/03-expanded-error.png?fit=1298%2C731&amp;ssl=1" data-permalink="https://blog.robsewell.com/max-length-of-a-column-in-a-datatable-in-powershell/03-expanded-error/#main" data-attachment-id="4028"></P>
<BLOCKQUOTE>
<P>System.Management.Automation.MethodInvocationException: Exception calling “WriteToServer” with “1” argument(s): “The given value of<BR>type String from the data source cannot be converted to type nvarchar of the specified target column.” —&gt;<BR>System.InvalidOperationException: The given value of type String from the data source cannot be converted to type nvarchar of the<BR>specified target column. —&gt; System.InvalidOperationException: String or binary data would be truncated.</P></BLOCKQUOTE>
<P>String or binary data would be truncated. OK that makes sense, one of my columns has larger data than the destination column but which one? Lets take a look at some of the data</P>
<P>SourceServer&nbsp; : SQL2016N3<BR>TestServer&nbsp;&nbsp;&nbsp; : SQL2016N1<BR>Database&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; : RidetheLightning<BR>FileExists&nbsp;&nbsp;&nbsp; : Skipped<BR>RestoreResult : Restore not located on shared location<BR>DbccResult&nbsp;&nbsp;&nbsp; : Skipped<BR>SizeMB&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; : 4.08<BR>BackupTaken&nbsp;&nbsp; : 3/19/2017 12:00:03 AM<BR>BackupFiles&nbsp;&nbsp; : C:\MSSQL\Backup\SQL2016N3\RidetheLightning\FULL\SQL2016N3_RidetheLightning_FULL_20170319_000003.bak</P>
<P>SourceServer&nbsp; : SQL2016N3<BR>TestServer&nbsp;&nbsp;&nbsp; : SQL2016N1<BR>Database&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; : TheCallofKtulu<BR>FileExists&nbsp;&nbsp;&nbsp; : Skipped<BR>RestoreResult : Restore not located on shared location<BR>DbccResult&nbsp;&nbsp;&nbsp; : Skipped<BR>SizeMB&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; : 4.08<BR>BackupTaken&nbsp;&nbsp; : 3/19/2017 12:00:04 AM<BR>BackupFiles&nbsp;&nbsp; : C:\MSSQL\Backup\SQL2016N3\TheCallofKtulu\FULL\SQL2016N3_TheCallofKtulu_FULL_20170319_000004.bak</P>
<P>SourceServer&nbsp; : SQL2016N3<BR>TestServer&nbsp;&nbsp;&nbsp; : SQL2016N1<BR>Database&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; : TrappedUnderIce<BR>FileExists&nbsp;&nbsp;&nbsp; : Skipped<BR>RestoreResult : Restore not located on shared location<BR>DbccResult&nbsp;&nbsp;&nbsp; : Skipped<BR>SizeMB&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; : 4.08<BR>BackupTaken&nbsp;&nbsp; : 3/19/2017 12:00:04 AM<BR>BackupFiles&nbsp;&nbsp; : C:\MSSQL\Backup\SQL2016N3\TrappedUnderIce\FULL\SQL2016N3_TrappedUnderIce_FULL_20170319_000004.bak</P>
<P>Hmm, its not going to be easy to work out which bit of data is too big here.</P>
<P>All I need to know is the maximum length of the columns in the datatable though so I have a little snippet that will do that for me</P>
<DIV><PRE class="lang:ps decode:true">$columns = ($datatable | Get-Member -MemberType Property).Name
foreach($column in $Columns) {
$max = 0
foreach ($a in $datatable){
       if($max -lt $a.$column.length){
        $max = $a.$column.length
       }
}
Write-Output "$column max length is $max"
}</PRE></DIV>
<P>and the output looks like this</P>
<DIV></DIV>
<DIV><IMG class="alignnone size-full wp-image-4041" alt="04 - max length.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/04-max-length.png?resize=630%2C351&amp;ssl=1" width=630 height=351 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/04-max-length.png?fit=630%2C351&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/04-max-length.png?fit=300%2C167&amp;ssl=1" data-image-description="" data-image-title="04 – max length" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="645,359" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/04-max-length.png?fit=645%2C359&amp;ssl=1" data-permalink="https://blog.robsewell.com/max-length-of-a-column-in-a-datatable-in-powershell/04-max-length/#main" data-attachment-id="4041"></DIV>
<DIV></DIV>
<P>So&nbsp;we can quickly see that the backupfiles property is too big and change the table accordingly and no more error.</P>
<DIV>Its pretty quick too, scanning 105 rows in 56 milliseconds in this example</DIV>
<DIV></DIV>
<DIV>
<DIV><IMG class="alignnone size-full wp-image-4045" alt="05 - how long.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/05-how-long.png?resize=514%2C483&amp;ssl=1" width=514 height=483 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/05-how-long.png?fit=514%2C483&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/05-how-long.png?fit=300%2C282&amp;ssl=1" data-image-description="" data-image-title="05 – how long" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="514,483" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/05-how-long.png?fit=514%2C483&amp;ssl=1" data-permalink="https://blog.robsewell.com/max-length-of-a-column-in-a-datatable-in-powershell/05-how-long/#main" data-attachment-id="4045"></DIV>
<DIV></DIV></DIV>
<P>I keep this little snippet in <A href="https://github.com/SQLDBAWithABeard/Functions/blob/master/Snippets%20List.ps1">my snippets list for PowerShell ISE which you can find here</A></P>
<DIV></DIV>
<DIV>Here is the code to add this as a snippet to ISE</DIV>
<DIV></DIV>
<DIV><PRE class="lang:ps decode:true">## A list of snippets
$snips = Get-IseSnippet
## Add a snippet
if(!$snips.Where{$_.Name -like 'Max Length of Datatable*'})
{
$snippet = @{
 Title = 'Max Length of Datatable'
 Description = 'Takes a datatable object and iterates through it to get the max length of the string columns - useful for data loads'
 Text = @"
`$columns = (`$datatable | Get-Member -MemberType Property).Name
foreach(`$column in `$Columns)
{
`$max = 0
foreach (`$a in `$datatable)
{
if(`$max -lt `$a.`$column.length)
{
`$max = `$a.`$column.length
}
}
Write-Output "`$column max length is `$max"
}

"@
}
New-IseSnippet @snippet
}</PRE></DIV>
<DIV></DIV>
<DIV>and if you want to add it to your VSCode snippets then you need to edit the PowerShell.json file which is located in your user home AppData folder&nbsp;‘C:\Users\User\AppData\Roaming\Code\User\snippets\powershell.json’ or by clicking File –&gt; Preferences –&gt; User Snippets and typing PowerShell</DIV>
<DIV></DIV>
<DIV></DIV>
<DIV><IMG class="alignnone size-full wp-image-4072" alt="04 user snippets.gif" src="https://blog.robsewell.com/assets/uploads/2017/03/04-user-snippets.gif?resize=630%2C360&amp;ssl=1" width=630 height=360 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/04-user-snippets.gif?fit=630%2C360&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/04-user-snippets.gif?fit=300%2C171&amp;ssl=1" data-image-description="" data-image-title="04 user snippets" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1400,800" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/04-user-snippets.gif?fit=1400%2C800&amp;ssl=1" data-permalink="https://blog.robsewell.com/max-length-of-a-column-in-a-datatable-in-powershell/04-user-snippets/#main" data-attachment-id="4072"></DIV>
<DIV></DIV>
<P>Then you can add this bit of json inside the curly braces</P>
<DIV><PRE class="theme:solarized-light lang:xhtml decode:true">"Max Length of Datatable": {
    "prefix": "Max Length of Datatable",
    "body": [
        "$$columns = ($$datatable | Get-Member -MemberType Property).Name",
        "foreach($$column in $$Columns) {",
        "    $$max = 0",
        "    foreach ($$a in $$datatable){",
        "        if($$max -lt $$a.$$column.length){",
        "            $$max = $$a.$$column.length",
        "        }",
        "    }",
        "    Write-Output \"$$column max length is $$max\"",
        "}"
    ],
    "description": "Takes a datatable object and iterates through it to get the max length of the string columns - useful for data loads"
},</PRE>
<P>&nbsp;</P></DIV>
<P>and you have your snippet ready for use</P>
<DIV></DIV>
<DIV><IMG class="alignnone size-full wp-image-4075" alt="07 - snippet in vscode.gif" src="https://blog.robsewell.com/assets/uploads/2017/03/07-snippet-in-vscode.gif?resize=630%2C360&amp;ssl=1" width=630 height=360 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/07-snippet-in-vscode.gif?fit=630%2C360&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/07-snippet-in-vscode.gif?fit=300%2C171&amp;ssl=1" data-image-description="" data-image-title="07 – snippet in vscode" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1400,800" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/07-snippet-in-vscode.gif?fit=1400%2C800&amp;ssl=1" data-permalink="https://blog.robsewell.com/max-length-of-a-column-in-a-datatable-in-powershell/07-snippet-in-vscode/#main" data-attachment-id="4075"></DIV>
<DIV></DIV>
<P>Happy Automating</P>
<DIV></DIV>
<DIV></DIV>
<P>&nbsp;</P>
<P>&nbsp;</P>

