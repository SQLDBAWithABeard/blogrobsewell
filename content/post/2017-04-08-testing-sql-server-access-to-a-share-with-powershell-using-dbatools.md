---
title: "Testing SQL Server Access to a share with PowerShell using dbatools"
date: "2017-04-08" 
categories:
  - Blog

tags:
  - backups
  - dbatools
   - GitHub  
  - issue
  - permissions
  - PowerShell

---
<P>A good security practice is to backup our SQL Servers to a network share but not allow users to be able to browse the share. How can we ensure that our SQL Server has access or test it if it has been set up by someone else?</P>
<P>Lets set this up.</P>
<P>First lets create a share for our backups</P><PRE class="lang:ps decode:true">$FileShareParams=@{
Name='SQLBackups'
Description='The Place for SQL Backups'
SourceVolume=(Get-Volume-DriveLetterD)
FileServerFriendlyName='beardnuc'
}
New-FileShare @FileShareParams
</PRE>
<P>This will create us a share called SQLBackups on the D drive of the server beardnuc, but without any permissions, lets grant permissions to everyone</P>
<DIV>
<DIV><PRE class="lang:ps decode:true">$FileSharePermsParams=@{
 Name = 'SQLBackups'
 AccessRight = 'Modify'
 AccountName = 'Everyone'}
Grant-FileShareAccess @FileSharePermsParams
</PRE></DIV></DIV>
<P><IMG class="alignnone size-full wp-image-4759" alt="01 file share.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/01-file-share.png?resize=358%2C180&amp;ssl=1" width=358 height=180 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/01-file-share.png?fit=358%2C180&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/01-file-share.png?fit=300%2C151&amp;ssl=1" data-image-description="" data-image-title="01 file share" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="358,180" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/01-file-share.png?fit=358%2C180&amp;ssl=1" data-permalink="https://blog.robsewell.com/testing-sql-server-access-to-a-share-with-powershell-using-dbatools/01-file-share/#main" data-attachment-id="4759"></P>
<DIV></DIV>
<P>The share is created and I can access it and create a file</P>
<P><IMG class="alignnone size-full wp-image-4762" alt="02 - create a file.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/02-create-a-file.png?resize=417%2C205&amp;ssl=1" width=417 height=205 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/02-create-a-file.png?fit=417%2C205&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/02-create-a-file.png?fit=300%2C147&amp;ssl=1" data-image-description="" data-image-title="02 – create a file" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="417,205" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/02-create-a-file.png?fit=417%2C205&amp;ssl=1" data-permalink="https://blog.robsewell.com/testing-sql-server-access-to-a-share-with-powershell-using-dbatools/02-create-a-file/#main" data-attachment-id="4762"></P>
<P>and as we can see the permissions are granted for everyone</P>
<DIV></DIV>
<P><IMG class="alignnone size-full wp-image-4766" alt="03 -permissions.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/03-permissions.png?resize=630%2C341&amp;ssl=1" width=630 height=341 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/03-permissions.png?fit=630%2C341&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/03-permissions.png?fit=300%2C163&amp;ssl=1" data-image-description="" data-image-title="03 -permissions" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1032,559" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/03-permissions.png?fit=1032%2C559&amp;ssl=1" data-permalink="https://blog.robsewell.com/testing-sql-server-access-to-a-share-with-powershell-using-dbatools/03-permissions/#main" data-attachment-id="4766"></P>
<DIV></DIV>
<P>OK, that’s not what we want so lets revoke that permission.</P>
<DIV></DIV><PRE class="lang:ps decode:true">Revoke-FileShareAccess Name SQLBackups AccountName 'Everyone'</PRE>
<DIV></DIV>
<P><IMG class="alignnone size-full wp-image-4770" alt="04 revoked.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/04-revoked.png?resize=368%2C449&amp;ssl=1" width=368 height=449 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/04-revoked.png?fit=368%2C449&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/04-revoked.png?fit=246%2C300&amp;ssl=1" data-image-description="" data-image-title="04 revoked" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="368,449" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/04-revoked.png?fit=368%2C449&amp;ssl=1" data-permalink="https://blog.robsewell.com/testing-sql-server-access-to-a-share-with-powershell-using-dbatools/04-revoked/#main" data-attachment-id="4770"></P>
<DIV></DIV>
<P>Now lets add permissions just for our SQL Server Service Accounts</P>
<DIV></DIV><PRE class="lang:ps decode:true">$FileSharePermsParams = @{
Name = 'SQLBackups'
AccessRight = 'Modify'
AccountName = 'SQL_DBEngine_Service_Accounts
}
Grant-FileShareAccess @FileSharePermsParams </PRE>
<DIV></DIV>
<DIV>and explicitly deny our DBA user accounts from accessing them.</DIV>
<DIV></DIV><PRE class="lang:ps decode:true">$BlockFileShareParams = @{
Name = 'SQLBackups'
AccountName = 'SQL_DBAs_The_Cool_Ones'
}
Block-FileShareAccess @BlockFileShareParams</PRE>
<DIV></DIV>
<DIV>In the GUI our permissions look like this</DIV>
<DIV></DIV>
<DIV class="tiled-gallery type-rectangular tiled-gallery-unresized" itemtype="http://schema.org/ImageGallery" itemscope data-carousel-extra='{"blog_id":1,"permalink":"https:\/\/blog.robsewell.com\/2017\/04\/08\/testing-sql-server-access-to-a-share-with-powershell-using-dbatools\/","likes_blog_id":46782976}' data-original-width="630">
<DIV class=gallery-row style="HEIGHT: 386px; WIDTH: 630px" data-original-width="630" data-original-height="386">
<DIV class="gallery-group images-1" style="HEIGHT: 386px; WIDTH: 314px" data-original-width="314" data-original-height="386">
<DIV class="tiled-gallery-item tiled-gallery-item-large" itemtype="http://schema.org/ImageObject" itemscope itemprop="associatedMedia"><A href="https://blog.robsewell.com/testing-sql-server-access-to-a-share-with-powershell-using-dbatools/05-deny/#main" itemprop="url" border="0">
<META content=310 itemprop="width">
<META content=382 itemprop="height"><IMG title="05 - deny" style="HEIGHT: 382px; WIDTH: 310px" alt="05 - deny" src="https://blog.robsewell.com/assets/uploads/2017/03/05-deny.png?w=310&amp;h=382&amp;ssl=1" width=310 height=382 data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/05-deny.png?fit=369%2C454&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/05-deny.png?fit=244%2C300&amp;ssl=1" data-image-description="" data-image-title="05 – deny" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="369,454" data-orig-file="https://blog.robsewell.com/wp-content/uploads/2017/03/05-deny.png" data-attachment-id="4779" data-original-width="310" data-original-height="382" itemprop="http://schema.org/image"> </A></DIV></DIV>
<DIV class="gallery-group images-1" style="HEIGHT: 386px; WIDTH: 316px" data-original-width="316" data-original-height="386">
<DIV class="tiled-gallery-item tiled-gallery-item-large" itemtype="http://schema.org/ImageObject" itemscope itemprop="associatedMedia"><A href="https://blog.robsewell.com/testing-sql-server-access-to-a-share-with-powershell-using-dbatools/06-allow/#main" itemprop="url" border="0">
<META content=312 itemprop="width">
<META content=382 itemprop="height"><IMG title="06 -allow" style="HEIGHT: 382px; WIDTH: 312px" alt="06 -allow" src="https://blog.robsewell.com/assets/uploads/2017/03/06-allow.png?w=312&amp;h=382&amp;ssl=1" width=312 height=382 data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/06-allow.png?fit=373%2C457&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/06-allow.png?fit=245%2C300&amp;ssl=1" data-image-description="" data-image-title="06 -allow" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="373,457" data-orig-file="https://blog.robsewell.com/wp-content/uploads/2017/03/06-allow.png" data-attachment-id="4780" data-original-width="312" data-original-height="382" itemprop="http://schema.org/image"> </A></DIV></DIV></DIV></DIV>
<DIV></DIV>
<DIV>and when I try to access as THEBEARD\Rob I get this</DIV>
<DIV></DIV>
<P><IMG class="alignnone size-full wp-image-4784" alt="07 -no permissions.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/07-no-permissions.png?resize=460%2C356&amp;ssl=1" width=460 height=356 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/07-no-permissions.png?fit=460%2C356&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/07-no-permissions.png?fit=300%2C232&amp;ssl=1" data-image-description="" data-image-title="07 -no permissions" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="460,356" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/07-no-permissions.png?fit=460%2C356&amp;ssl=1" data-permalink="https://blog.robsewell.com/testing-sql-server-access-to-a-share-with-powershell-using-dbatools/07-no-permissions/#main" data-attachment-id="4784"></P>
<DIV></DIV>
<P>So how can I check that I have access from my SQL Server? Sure I could get the password of the SQL Service account and run a process as that account, not saying that’s a good idea but it could be done. Of course it couldn’t be done if you are using <A href="https://technet.microsoft.com/en-us/library/dd560633(v=ws.10).aspx" target=_blank>Managed Service Accounts </A>or <A href="https://technet.microsoft.com/en-us/library/hh831782(v=ws.11).aspx" target=_blank>Group Managed Service Accounts</A>&nbsp;but there is a way</P>
<DIV></DIV>
<DIV>Enter dbatools to the rescue 😉 The <A href="https://dbatools.io" target=_blank>dbatools module</A> (for those that don’t know) is a PowerShell module written by amazing folks in the community designed to make administrating your SQL Server significantly easier using PowerShell. The instructions for installing it are <A href="https://dbatools.io/getting-started/" target=_blank><SPAN style="COLOR: #0066cc">available here</SPAN></A> It comprises of 182 separate commands at present</DIV>
<DIV></DIV>
<P>There is a command called <A href="https://dbatools.io/functions/test-sqlpath/" target=_blank>Test-SqlPath</A> As always start with Get-Help</P>
<DIV></DIV><PRE class="lang:ps decode:true">Get-Help Test-SqlPath -Full</PRE>
<DIV></DIV>
<P><IMG class="alignnone size-full wp-image-4796" alt="08 - get help.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/08-get-help.png?resize=630%2C495&amp;ssl=1" width=630 height=495 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/08-get-help.png?fit=630%2C495&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/08-get-help.png?fit=300%2C236&amp;ssl=1" data-image-description="" data-image-title="08 – get help" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="935,734" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/08-get-help.png?fit=935%2C734&amp;ssl=1" data-permalink="https://blog.robsewell.com/testing-sql-server-access-to-a-share-with-powershell-using-dbatools/08-get-help/#main" data-attachment-id="4796"></P>
<DIV></DIV>
<DIV>So it uses master.dbo.xp_fileexist to determine if a file or directory exists, from the perspective of the SQL Server service account, has three parameters Sqlserver, Path and SqlCredential for SQL Authentication. Of course if that stored procedure is disabled on your estate then this command will not be of use to you. With that in mind, lets run it and see what it does</DIV>
<DIV></DIV>
<DIV><PRE class="lang:ps decode:true">Test-SqlPath -SqlServer sql2016n1 -Path \\beardnuc\SQLBackups</PRE></DIV>
<DIV></DIV>
<DIV><IMG class="alignnone size-full wp-image-4803" alt="09 - path test" src="https://blog.robsewell.com/assets/uploads/2017/03/09-path-test.png?resize=630%2C39&amp;ssl=1" width=630 height=39 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/09-path-test.png?fit=630%2C39&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/09-path-test.png?fit=300%2C18&amp;ssl=1" data-image-description="" data-image-title="09 – path test" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="637,39" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/09-path-test.png?fit=637%2C39&amp;ssl=1" data-permalink="https://blog.robsewell.com/testing-sql-server-access-to-a-share-with-powershell-using-dbatools/09-path-test/#main" data-attachment-id="4803"></DIV>
<DIV></DIV>
<P>That’s good I have access, lets back&nbsp;a database up</P>
<DIV></DIV><PRE class="lang:ps decode:true">Backup-SqlDatabase -ServerInstance SQL2016N1 -Database DBA-Admin -CopyOnly -BackupAction Database -BackupFile '\\BeardNuc\SQLBackups\Test-DBA-Admin.bak'</PRE>
<DIV></DIV>
<DIV>Ah, I cant show you as I don’t have access. Better get in touch with the data centre admin to check 😉 Luckily, I am my own data centre admin and have another account I can use 🙂</DIV>
<DIV></DIV>
<DIV><IMG class="alignnone size-full wp-image-4813" alt="10 - check" src="https://blog.robsewell.com/assets/uploads/2017/03/10-check.png?resize=630%2C171&amp;ssl=1" width=630 height=171 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/10-check.png?fit=630%2C171&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/10-check.png?fit=300%2C81&amp;ssl=1" data-image-description="" data-image-title="10 – check" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="653,177" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/10-check.png?fit=653%2C177&amp;ssl=1" data-permalink="https://blog.robsewell.com/testing-sql-server-access-to-a-share-with-powershell-using-dbatools/10-check/#main" data-attachment-id="4813"></DIV>
<DIV></DIV>
<P>So what if we want to test all of our servers for access to the new share? I tried this</P>
<DIV></DIV><PRE class="lang:ps decode:true">$SQLServers = (Get-VM -ComputerName beardnuc).Where{$_.Name -like '*SQL*' -and $_.Name -notlike 'SQL2008Ser2008'}.Name
Test-SqlPath -SqlServer $SQLServers -Path '\\BeardNuc\SQLBackups'</PRE>
<DIV></DIV>
<DIV></DIV>
<DIV>but unfortunately I hit an error</DIV>
<DIV></DIV>
<DIV><IMG class="alignnone size-full wp-image-4820" alt="11 - error.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/11-error.png?resize=630%2C110&amp;ssl=1" width=630 height=110 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/11-error.png?fit=630%2C110&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/11-error.png?fit=300%2C53&amp;ssl=1" data-image-description="" data-image-title="11 – error" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1079,189" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/11-error.png?fit=1079%2C189&amp;ssl=1" data-permalink="https://blog.robsewell.com/testing-sql-server-access-to-a-share-with-powershell-using-dbatools/11-error/#main" data-attachment-id="4820"></DIV>
<DIV></DIV>
<DIV>It seems that at the moment (version 0.8.942) this command only accepts a single server. This is what you should do if you find either a bug or have an idea for dbatools. Raise an issue on Github</DIV>
<DIV></DIV>
<DIV>Navigate to the <A href="https://github.com/sqlcollaborative/dbatools" target=_blank>GitHub repository</A> and click on issues. I generally search for the command name in the issues to see if someone else has beaten me to it</DIV>
<DIV></DIV>
<DIV><IMG class="alignnone size-full wp-image-4827" alt="12 - issues" src="https://blog.robsewell.com/assets/uploads/2017/03/12-issues.png?resize=630%2C259&amp;ssl=1" width=630 height=259 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/12-issues.png?fit=630%2C259&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/12-issues.png?fit=300%2C123&amp;ssl=1" data-image-description="" data-image-title="12 – issues" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1208,496" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/12-issues.png?fit=1208%2C496&amp;ssl=1" data-permalink="https://blog.robsewell.com/testing-sql-server-access-to-a-share-with-powershell-using-dbatools/12-issues/#main" data-attachment-id="4827"></DIV>
<DIV></DIV>
<DIV>If those issues don’t match yours then click the green New Issue button</DIV>
<DIV></DIV>
<DIV>There is a template to fill in which asks you to specify your Windows, PowerShell and SQL versions with the commands that you need to do so included. Please do this and paste the results in as it will help the folks to replicate the issues in the case of more complicated&nbsp; bugs</DIV>
<DIV></DIV>
<DIV>I created <A href="https://github.com/sqlcollaborative/dbatools/issues/1004" target=_blank>this issue </A>with a potential fix as well, you don’t have to do that, just letting the folks know is good enough</DIV>
<DIV></DIV>
<DIV>Until that issue is resolved, you can check all of your servers as follows</DIV>
<DIV></DIV>
<DIV>
<DIV>
<DIV><PRE class="lang:ps decode:true">$SQLServers=(Get-VM -ComputerName beardnuc).Where{$_.Name -like '*SQL*' -and $_.Name -notlike 'SQL2008Ser2008'}.Name
foreach($Server in $SQLServers)
{
$Test = Test-SqlPath -SqlServer $Server -Path '\\BeardNuc\SQLBackups'
[PSCustomObject]@{
Server = $Server
Result = $Test
}
}</PRE></DIV></DIV></DIV>
<DIV></DIV>
<DIV><IMG class="alignnone size-full wp-image-4838" alt="13 - servers.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/13-servers.png?resize=630%2C251&amp;ssl=1" width=630 height=251 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/13-servers.png?fit=630%2C251&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/13-servers.png?fit=300%2C120&amp;ssl=1" data-image-description="" data-image-title="13 – servers" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1075,429" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/13-servers.png?fit=1075%2C429&amp;ssl=1" data-permalink="https://blog.robsewell.com/testing-sql-server-access-to-a-share-with-powershell-using-dbatools/13-servers/#main" data-attachment-id="4838"></DIV>
<DIV></DIV>
<DIV>and if I remove one of the service accounts from the group and restart the service an run the command again</DIV>
<DIV></DIV>
<DIV><IMG class="alignnone size-full wp-image-4842" alt="14 - one fails.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/14-one-fails.png?resize=630%2C250&amp;ssl=1" width=630 height=250 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/14-one-fails.png?fit=630%2C250&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/14-one-fails.png?fit=300%2C119&amp;ssl=1" data-image-description="" data-image-title="14 – one fails" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1075,427" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/14-one-fails.png?fit=1075%2C427&amp;ssl=1" data-permalink="https://blog.robsewell.com/testing-sql-server-access-to-a-share-with-powershell-using-dbatools/14-one-fails/#main" data-attachment-id="4842"></DIV>
<DIV></DIV>
<DIV>So that’s how to use dbatools to check that your SQL Server have access to a Network share and also how to create an issue on GitHub for dbatools and help it to get even better</DIV>
<DIV></DIV>
<DIV>
<P>Happy Automating</P>
<P>NOTE – The major 1.0 release of dbatools due in the summer 2017 may have breaking changes which will stop the above code from working. There are also new commands coming which may replace this command. This blog post was written using dbatools version 0.8.942 You can check your version using</P><PRE class="lang:ps decode:true"> Get-Module dbatools</PRE>
<P>and update it using an Administrator PowerShell session with</P><PRE class="lang:ps decode:true"> Update-Module dbatools</PRE>
<P>You may find that you get no output from Update-Module as you have the latest version. If&nbsp;you have not installed the&nbsp;module from the PowerShell Gallery using</P><PRE class="lang:ps decode:true">Install-Module dbatools</PRE>
<P>Then you can use</P><PRE class="lang:ps decode:true">Update-dbatools</PRE></DIV>

