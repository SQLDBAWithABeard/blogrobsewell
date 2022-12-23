---
title: "dbatools at #SQLSatDublin"
date: "2017-06-21" 
categories:
  - Blog

tags:
  - dbatools
  - PowerShell

---
<P>This weekend&nbsp;<A href="http://www.sqlsaturday.com/620/EventHome.aspx" rel=noopener target=_blank>SQL Saturday Dublin</A> occurred. For those that don’t know <A href="http://www.sqlsaturday.com/" rel=noopener target=_blank>SQL Saturdays</A> are free conferences with local and international speakers providing great sessions in the Data Platform sphere.</P>
<P>Chrissy LeMaire and I presented our session PowerShell SQL Server: Modern Database Administration with <A href="https://dbatools.io/" rel=noopener target=_blank>dbatools</A>. You can find <A href="https://github.com/sqlcollaborative/community-presentations/tree/master/rob-sewell-chrissy-lemaire" rel=noopener target=_blank>slides and code here </A>. We were absolutely delighted to be named Best Speaker which was decided from the attendees average evaluation.</P>
<DIV class=embed-twitter>
<BLOCKQUOTE class=twitter-tweet data-width="550">
<P lang=en dir=ltr>Wow, <A href="https://twitter.com/cl">@cl</A> and i won the coveted best speaker award at <A href="https://twitter.com/hashtag/SqlSatDublin?src=hash">#SqlSatDublin</A> Thank you so much. We are so pleased <A href="https://t.co/f0MPTJf74p">pic.twitter.com/f0MPTJf74p</A></P>
<P>— Rob Sewell (@sqldbawithbeard) <A href="https://twitter.com/sqldbawithbeard/status/876102653490720768">June 17, 2017</A></P></BLOCKQUOTE>
<P>
<SCRIPT charset=utf-8 src="//platform.twitter.com/widgets.js" async></SCRIPT>
</P></DIV>
<P>Chrissy also won the Best Lightning talk for her&nbsp;5 minute (technically 4 minutes and 55 seconds)&nbsp;presentation on <A href="https://dbatools.io/" rel=noopener target=_blank>dbatools</A> as well 🙂</P>
<DIV class=embed-twitter>
<BLOCKQUOTE class=twitter-tweet data-width="550">
<P lang=en dir=ltr>Look at how chuffed <A href="https://twitter.com/cl">@cl</A> is at winning the Lightning Talk award as well at <A href="https://twitter.com/hashtag/SqlSatDublin?src=hash">#SqlSatDublin</A> 😆😆 <A href="https://t.co/KN9CVtYnHa">pic.twitter.com/KN9CVtYnHa</A></P>
<P>— Rob Sewell (@sqldbawithbeard) <A href="https://twitter.com/sqldbawithbeard/status/876103098510475265">June 17, 2017</A></P></BLOCKQUOTE>
<P>
<SCRIPT charset=utf-8 src="//platform.twitter.com/widgets.js" async></SCRIPT>
</P></DIV>
<P>We thoroughly enjoy giving this presentation and I think it shows in the feedback we received.</P>
<P><A href="https://blog.robsewell.com/assets/uploads/2017/06/feedback.png?ssl=1" rel=noopener target=_blank><IMG class="alignnone wp-image-6137" alt=Feedback src="https://blog.robsewell.com/assets/uploads/2017/06/feedback.png?resize=552%2C352&amp;ssl=1" width=552 height=352 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/06/feedback.png?fit=630%2C402&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/06/feedback.png?fit=300%2C192&amp;ssl=1" data-image-description="" data-image-title="Feedback" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1485,948" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/06/feedback.png?fit=1485%2C948&amp;ssl=1" data-permalink="https://blog.robsewell.com/dbatools-at-sqlsatdublin/feedback/#main" data-attachment-id="6137"></A></P>
<H2>History</H2>
<P>We start with a little history of <A href="https://dbatools.io" rel=noopener target=_blank>dbatools</A>, how it started as one megalithic script Start-SQLMigration.ps1 and has evolved into (this number grows so often it is probably wrong by the time you read this) over 240 commands from 60 contributors</P>
<H2>Requirements</H2>
<P>We explain the requirements. You can see them here on the <A href="https://dbatools.io/download/" rel=noopener target=_blank>download page.</A></P>
<P>The minimum requirements for the Client are</P>
<UL>
<LI>PowerShell v3 
<LI>SSMS / SMO 2008 R2 </LI></UL>
<P>which we hope will cover a significant majority of peoples workstations.</P>
<P>The minimum requirements for the SQL Server are</P>
<UL>
<LI>SQL Server 2000 
<LI>No PowerShell for pure SQL commands 
<LI>PowerShell v2 for Windows commands 
<LI>Remote PowerShell enabled for Windows commands </LI></UL>
<P>As you can see the SQL server does not even need to have PowerShell installed (unless you want to use the Windows commands). We test our commands thoroughly using a test estate that encompasses all versions of SQL from 2000 through to 2017 and whenever there is a vNext available we will test against that too.</P>
<P>We recommend though that you are using PowerShell v5.1 with SSMS or SMO for SQL 2016 on the client</P>
<H2>Installation</H2>
<P>We love how easy and simple the installation of <A href="https://dbatools.io/" rel=noopener target=_blank>dbatools</A> is. As long as you have access to the internet (and permission from your companies security team to install 3rd party tools. Please don’t break your companies policies) you can simply install the module from the <A href="https://www.powershellgallery.com/" rel=noopener target=_blank>PowerShell Gallery</A> using</P><PRE class="lang:ps decode:true">Install-Module dbatools
</PRE>
<P>If you are not a local administrator on your machine you can use the -Scope parameter</P><PRE class="lang:ps decode:true">Install-Module dbatools -Scope CurrentUser
</PRE>
<P>Incidentally, if you or your security team have concerns about the quality or trust of the content in the PowerShell Gallery please <A href="https://blogs.msdn.microsoft.com/powershell/2015/08/06/powershell-gallery-new-security-scan/" rel=noopener target=_blank>read this post</A> which explains the steps that are taken when code is uploaded.</P>
<P>If you cannot use the PowerShell Gallery then you can use this line of code to install from GitHub</P><PRE class="lang:ps decode:true">Invoke-Expression (Invoke-WebRequest https://dbatools.io/in)
</PRE>
<P>There is a video on the&nbsp;<A href="https://dbatools.io/download/" rel=noopener target=_blank>download page</A> showing the installation on a Windows 7 machine and also some other methods of installing the module should you need them.</P>
<H2>Website</H2>
<P>Next we visit <A href="https://dbatools.io" rel=noopener target=_blank>the website dbatools.io</A>&nbsp;and look at the front page. We have our regular joke about how Chrissy doesn’t want to present on migrations but I think they are so cool so she makes me perform the commentary on the video. (Don’t tell anyone but it also helps us to get in as many of the 240+ commands in a one hour session as well 😉 ). You can watch the video on the <A href="https://dbatools.io" rel=noopener target=_blank>front page.</A>&nbsp;You definitely should as you have never seen migrations performed so easily.</P>
<P>Then we talk about the comments we have received from well respected people from both SQL and PowerShell community members so you can trust that its not just some girl with hair and some bloke with a beard saying that its awesome.</P>
<H2>Contributors</H2>
<P>Probably my&nbsp;<A href="https://dbatools.io/team/" rel=noopener target=_blank>favourite page on the web-site</A> is the team page showing all of the amazing fabulous wonderful people who have given their own time freely to make such a fantastic free tool. If we have contributors in the audience we do try to point them out. One of our aims with dbatools is to enable people to receive the recognition for the hard work that they put in and we do this via the <A href="https://dbatools.io/team/" rel=noopener target=_blank>team page</A>, our <A href="https://dbatools.io/linkedin" rel=noopener target=_blank>LinkedIn company page</A>&nbsp;as well as&nbsp;by linking back to the contributors in the help and the web-page for every command. I wish I could name check each one of you.</P>
<P>Thank You each and every one !!</P>
<H2>Finding Commands</H2>
<P>We then look at the&nbsp;<A href="https://dbatools.io/functions/" rel=noopener target=_blank>command page</A>&nbsp;and the <A href="https://dbatools.io/command-search/" rel=noopener target=_blank>new improved search page</A> and demonstrate how you can use them to find information about the commands that you need and the challenges in keeping this all maintained during a period of such rapid expansion.</P>
<H2>Demo</H2>
<P>Then it is time for me to say this phrase. “Strap yourselves in, do up your seatbelts, now we are going to show 240 commands in the next 40 minutes. Are you ready!!”</P>
<P>Of course, I am joking, one of the hardest things about doing a one hour presentation on <A href="https://dbatools.io/" rel=noopener target=_blank>dbatools</A>&nbsp;is the sheer number of commands that we have that we want to show off. Of course we have already shown some of them in the migration video above but we still have a lot more to show and there are a lot more that we wish we had time to show.</P>
<H2>Backup and Restore</H2>
<P>We start with a restore of one database&nbsp;and&nbsp;a single backup&nbsp;file using <A href="https://dbatools.io/functions/restore-dbadatabase/" rel=noopener target=_blank>Restore-DbaDatabase&nbsp;</A>showing you the easy to read warning that you get if the database already exists and then how to&nbsp;resolve that warning&nbsp;with the WithReplace switch</P>
<P>Then how to use it to restore an entire instance worth of backups to the latest available time&nbsp;by pointing&nbsp;<A href="https://dbatools.io/functions/restore-dbadatabase/" rel=noopener target=_blank>Restore-DbaDatabase</A> at a folder on a&nbsp;share</P>
<P>Then how to use <SPAN class=pl-c1><A href="https://dbatools.io/functions/Get-DbaDatabase/" rel=noopener target=_blank>Get-DbaDatabase</A>&nbsp;to get all of the databases on an instance and pass them to <A href="https://dbatools.io/functions/Backup-DbaDatabase" rel=noopener target=_blank>Backup-DbaDatabase</A>&nbsp;to back up an entire instance.</SPAN></P>
<P>We look at the Backup history of some databases using <A href="https://dbatools.io/functions/Get-DbaBackupHistory/" rel=noopener target=_blank><SPAN class=pl-c1>Get-DbaBackupHistory</SPAN></A>&nbsp;and&nbsp;<A href="https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.utility/out-gridview" rel=noopener target=_blank>Out-GridView</A>&nbsp;and examine detailed information about a backup file&nbsp;using <A href="https://dbatools.io/functions/Read-DbaBackupHeader/" rel=noopener target=_blank>Read-DbaBackupHeader.</A></P>
<P>We give thanks to Stuart Moore for his amazing work on these and several other backup and restore commands.</P>
<H2>SPN’s</H2>
<P>After a quick reminder that you can search for commands at the command line using <SPAN class=pl-c1><A href="https://dbatools.io/functions/Find-DbaCommand/" rel=noopener target=_blank>Find-DbaCommand,</A>&nbsp;we talk about SPNs and try to find someone, anyone, who actually likes working with SQL Server and SPNs and resolving the issues!!</SPAN></P>
<P>Then we show Drew’s SPN commands <SPAN class=pl-c1><A href="https://dbatools.io/functions/Get-DbaSpn" rel=noopener target=_blank>Get-DbaSpn</A>, <A href="https://dbatools.io/functions/Test-DbaSpn" rel=noopener target=_blank>Test-DbaSpn</A>, <A href="https://dbatools.io/functions/Set-DbaSpn" rel=noopener target=_blank>Set-DbaSpn</A>&nbsp; and <A href="https://dbatools.io/functions/Remove-DbaSpn/" rel=noopener target=_blank>Remove-DbaSpn&nbsp;</A></SPAN></P>
<H2>Holiday Tasks</H2>
<P>We then&nbsp;talk about the things we ensure we run before going on holiday to make sure we leave with a warm fuzzy feeling that everything will be ok until we return :-</P>
<UL>
<LI><SPAN class=pl-c1><A href="https://dbatools.io/functions/Get-DbaLastBackup" rel=noopener target=_blank>Get-DbaLastBackup</A> will show the last time the database had any type of backup.<BR></SPAN>
<LI><SPAN class=pl-c1><A href="https://dbatools.io/functions/Get-DbaLastGoodCheckDb" rel=noopener target=_blank>Get-DbaLastGoodCheckDb</A> which shows the last time that a database had a successful DBCC CheckDb and how we can gather the information for all the databases on all of your instances in just one line of code<BR></SPAN>
<LI><SPAN class=pl-c1><A href="https://dbatools.io/functions/Get-DbaDiskSpace/" rel=noopener target=_blank>Get-DbaDiskSpace</A>&nbsp;which will show the disk information for all of the drives including mount points and whether the disk is in use by SQL<BR></SPAN></LI></UL>
<H2>Testing Your Backup Files By Restoring Them</H2>
<P>We ask how many people test their backup files&nbsp;every single day and Dublin wins marks for a larger percentage than some other places we have given this talk. We show <SPAN class=pl-c1><A href="https://dbatools.io/functions/Test-DbaLastBackup/" rel=noopener target=_blank>Test-DbaLastBackup</A>&nbsp;in action so that you can see the files being created because we think it looks cool (and you can see the filenames!) Chrissy has written a great post about how you can <A href="https://dbatools.io/dedicated-server/" rel=noopener target=_blank>set up your own dedicated backup file test server</A></SPAN></P>
<H2>Free Space</H2>
<P>We show how to gather the file space information using <A href="http://Get-DbaDatabaseFreespace" rel=noopener target=_blank><SPAN class=pl-c1>Get-DbaDatabaseFreespace</SPAN></A>&nbsp;and then how you can put that (or the results of any PowerShell command) into a SQL database table using <SPAN class=pl-c1><A href="https://dbatools.io/functions/Out-DbaDataTable/" rel=noopener target=_blank>Out-DbaDataTable</A>&nbsp;and <A href="https://dbatools.io/functions/Write-DbaDataTable" rel=noopener target=_blank>Write-DbaDataTable</A></SPAN></P>
<H2>SQL Community</H2>
<P>Next we talk about how we love to take community members blog posts and turn them into <A href="https://dbatools.io" rel=noopener target=_blank>dbatools</A> commands.</P>
<P>We start with Jonathan Kehayias’s post about SQL Server Max memory (<A href="http://bit.ly/sqlmemcalc" rel=noopener target=_blank>http://bit.ly/sqlmemcalc</A>) and show <A href="https://dbatools.io/functions/Get-DbaMaxMemory/" rel=noopener target=_blank>Get-DbaMaxMemory</A>&nbsp;, <A href="https://dbatools.io/functions/Test-DbaMaxMemory/" rel=noopener target=_blank>Test-DbaMaxMemory</A>&nbsp;and <A href="https://dbatools.io/functions/Set-DbaMaxMemory/" rel=noopener target=_blank>Set-DbaMaxMemory</A></P>
<P>Then&nbsp;<A href="https://www.sqlskills.com/blogs/paul/new-script-is-that-database-really-in-the-full-recovery-mode/" rel=noopener target=_blank>Paul Randal’s blog post about Pseudo-Simple Mode&nbsp;</A>which inspired&nbsp; <A href="https://dbatools.io/functions/Test-DbaFullRecoveryModel/" rel=noopener target=_blank><SPAN class=pl-c1>Test-DbaFullRecoveryModel</SPAN></A></P>
<P>We talked about getting backup history earlier but now we talk about <A href="https://dbatools.io/functions/Get-DbaRestoreHistory/" rel=noopener target=_blank>Get-DbaRestoreHistory</A>&nbsp;a command inspired by <A href="https://sqlstudies.com/2016/07/27/when-was-this-database-restored/" rel=noopener target=_blank>Kenneth Fishers blog post</A> to show when a database was restored and which file was used.</P>
<P>Next a command from <A href="https://thomaslarock.com/" rel=noopener target=_blank>Thomas LaRock</A>&nbsp;which he gave us for testing linked servers <A href="https://dbatools.io/functions/Test-DbaLinkedServerConnection/" rel=noopener target=_blank>Test-DbaLinkedServerConnection.</A></P>
<P><A href="https://www.sqlskills.com/blogs/glenn/sql-server-diagnostic-information-queries-for-may-2017/" rel=noopener target=_blank>Glenn Berrys diagnostic information queries&nbsp;</A> are available thanks to André Kamman and the commands <SPAN class=pl-c1>Invoke-DbaDiagnosticQuery and Export-DbaDiagnosticQuery. The second one will output all of the results to csv files.</SPAN></P>
<P>Adam Mechanic’s <A href="http://sqlblog.com/blogs/adam_machanic/archive/tags/who+is+active/default.aspx" rel=noopener target=_blank>sp_whoisactive</A> is a common tool in SQL DBA’s toolkit and can now be installed using <A href="https://dbatools.io/functions/install-dbawhoisactive/" rel=noopener target=_blank>Install-DbaWhoIsActive </A><SPAN class=pl-c1>and run using <A href="https://dbatools.io/functions/invoke-dbawhoisactive/" rel=noopener target=_blank>Invoke-DbaWhoIsActive.</A></SPAN></P>
<H2>Awesome Contributor Commands</H2>
<P>Then we try to fit in as many commands that we can from our fantastic contributors showing how we can do awesome things with just one line of PowerShell code</P>
<DIV class=embed-twitter>
<BLOCKQUOTE class=twitter-tweet data-width="550">
<P lang=en dir=ltr>One line of code! Excellent 'Poweshell – SQL Server: Modern Database Administration' presentation by <A href="https://twitter.com/cl">@cl</A> <A href="https://twitter.com/sqldbawithbeard">@sqldbawithbeard</A> <A href="https://twitter.com/hashtag/SqlSatDublin?src=hash">#SqlSatDublin</A> <A href="https://t.co/TOIsi0FgAA">pic.twitter.com/TOIsi0FgAA</A></P>
<P>— Xavi Arnau (@xavidublin) <A href="https://twitter.com/xavidublin/status/876078661279117312">June 17, 2017</A></P></BLOCKQUOTE>
<P>
<SCRIPT charset=utf-8 src="//platform.twitter.com/widgets.js" async></SCRIPT>
</P></DIV>
<P>The awesome <A href="https://dbatools.io/functions/Find-DbaStoredProcedure" rel=noopener target=_blank>Find-DbaStoredProcedure</A>&nbsp;which you can <A href="https://dbatools.io/need-for-speed-find-dbastoredprocedure/" rel=noopener target=_blank>read more about here</A>&nbsp;which in tests searched 37,545 stored procedures on 9 instances in under 9 seconds for a particular string.</P>
<P><A href="https://dbatools.io/functions/Find-DbaOrphanedFile/" rel=noopener target=_blank>Find-DbaOrphanedFile</A> which enables you to identify the files left over from detaching databases.</P>
<P>Don’t know the SQL Admin password for an instance? <SPAN class=pl-c1><A href="https://dbatools.io/functions/other/reset-sqladmin/" rel=noopener target=_blank>Reset-SqlAdmin</A> can help you.</SPAN></P>
<P><SPAN class=pl-c1>It is normally somewhere around here that we finish and even though we have shown 32 commands (and a few more encapsulated in the Start-SqlMigration command)&nbsp;that is less than 15% of the total number of commands in the module!!!</SPAN></P>
<P>Somehow, we always manage&nbsp;to fit all of that into 60 minutes and have great fun doing it. Thank you to everyone who has come and seen our sessions in Vienna, Utrecht, PASS PowerShell Virtual Group, Hanover, Antwerp and Dublin.</P>
<H2>More</H2>
<P>So you want to know more about <A href="https://dbatools.io/" rel=noopener target=_blank>dbatools</A>&nbsp;? You can click the link and explore the website</P>
<P>You can look at <A href="https://github.com/sqlcollaborative/dbatools/" rel=noopener target=_blank>source code on GitHub</A></P>
<P>You can join us in the <A href="https://sqlps.io/slack" rel=noopener target=_blank>SQL Community Slack</A> in the #dbatools channel</P>
<P>You can watch videos on <A href="https://dbatools.io/youtube" rel=noopener target=_blank>YouTube</A></P>
<P>You can <A href="https://dbatools.io/presentations" rel=noopener target=_blank>see a list of all of the presentations</A>&nbsp;and get a lot of the slides and demos</P>
<P>If you want to see the slides and demos from our Dublin presentation you can find them <A href="https://github.com/sqlcollaborative/community-presentations/tree/master/rob-sewell-chrissy-lemaire" rel=noopener target=_blank>here</A></P>
<H2>Volunteers</H2>
<P>Lastly and most importantly of all. SQL Saturdays are run by volunteers so massive thanks to Bob, Carmel, Ben and the rest of the team who ensured that&nbsp;<A href="https://twitter.com/search?f=tweets&amp;vertical=default&amp;q=sqlsatdublin%20volunteers&amp;src=typd" rel=noopener target=_blank>SQL Saturday Dublin</A>&nbsp;went so very smoothly</P>
<DIV class=embed-twitter>
<BLOCKQUOTE class=twitter-tweet data-width="550">
<P lang=en dir=ltr>Massive thanks to the volunteers of <A href="https://twitter.com/hashtag/SqlSatDublin?src=hash">#SqlSatDublin</A> <A href="https://t.co/veE0UuQxeO">pic.twitter.com/veE0UuQxeO</A></P>
<P>— Shane O'Neill (@SOZDBA) <A href="https://twitter.com/SOZDBA/status/876068038671511553">June 17, 2017</A></P></BLOCKQUOTE>
<P>
<SCRIPT charset=utf-8 src="//platform.twitter.com/widgets.js" async></SCRIPT>
</P></DIV>
<P>&nbsp;</P>
<P>&nbsp;</P>

