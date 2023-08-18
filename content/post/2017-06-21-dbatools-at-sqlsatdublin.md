---
title: "dbatools at #SQLSatDublin"
date: "2017-06-21"
categories:
  - Blog

tags:
  - dbatools
  - PowerShell

---
This weekend [SQL Saturday Dublin](http://www.sqlsaturday.com/620/EventHome.aspx) occurred. For those that don’t know [SQL Saturdays](http://www.sqlsaturday.com/) are free conferences with local and international speakers providing great sessions in the Data Platform sphere.

Chrissy LeMaire and I presented our session PowerShell SQL Server: Modern Database Administration with [dbatools](https://dbatools.io/). You can find [slides and code here](https://github.com/sqlcollaborative/community-presentations/tree/master/rob-sewell-chrissy-lemaire) . We were absolutely delighted to be named Best Speaker which was decided from the attendees average evaluation.

> Wow, [@cl](https://twitter.com/cl) and i won the coveted best speaker award at [#SqlSatDublin](https://twitter.com/hashtag/SqlSatDublin?src=hash) Thank you so much. We are so pleased [pic.twitter.com/f0MPTJf74p](https://t.co/f0MPTJf74p)
>
> — Rob Sewell (@sqldbawithbeard) [June 17, 2017](https://twitter.com/sqldbawithbeard/status/876102653490720768)

Chrissy also won the Best Lightning talk for her 5 minute (technically 4 minutes and 55 seconds) presentation on [dbatools](https://dbatools.io/) as well 🙂

> Look at how chuffed [@cl](https://twitter.com/cl) is at winning the Lightning Talk award as well at [#SqlSatDublin](https://twitter.com/hashtag/SqlSatDublin?src=hash) 😆😆 [pic.twitter.com/KN9CVtYnHa](https://t.co/KN9CVtYnHa)
>
> — Rob Sewell (@sqldbawithbeard) [June 17, 2017](https://twitter.com/sqldbawithbeard/status/876103098510475265)

We thoroughly enjoy giving this presentation and I think it shows in the feedback we received.

[![Feedback](https://blog.robsewell.com/assets/uploads/2017/06/feedback.png?resize=552%2C352&ssl=1)](https://blog.robsewell.com/assets/uploads/2017/06/feedback.png?ssl=1)

History
-------

We start with a little history of [dbatools](https://dbatools.io), how it started as one megalithic script Start-SQLMigration.ps1 and has evolved into (this number grows so often it is probably wrong by the time you read this) over 240 commands from 60 contributors

Requirements
------------

We explain the requirements. You can see them here on the [download page.](https://dbatools.io/download/)

The minimum requirements for the Client are

*   PowerShell v3
*   SSMS / SMO 2008 R2

which we hope will cover a significant majority of peoples workstations.

The minimum requirements for the SQL Server are

*   SQL Server 2000
*   No PowerShell for pure SQL commands
*   PowerShell v2 for Windows commands
*   Remote PowerShell enabled for Windows commands

As you can see the SQL server does not even need to have PowerShell installed (unless you want to use the Windows commands). We test our commands thoroughly using a test estate that encompasses all versions of SQL from 2000 through to 2017 and whenever there is a vNext available we will test against that too.

We recommend though that you are using PowerShell v5.1 with SSMS or SMO for SQL 2016 on the client

Installation
------------

We love how easy and simple the installation of [dbatools](https://dbatools.io/) is. As long as you have access to the internet (and permission from your companies security team to install 3rd party tools. Please don’t break your companies policies) you can simply install the module from the [PowerShell Gallery](https://www.powershellgallery.com/) using

Install-Module dbatools

If you are not a local administrator on your machine you can use the -Scope parameter

Install-Module dbatools -Scope CurrentUser

Incidentally, if you or your security team have concerns about the quality or trust of the content in the PowerShell Gallery please [read this post](https://blogs.msdn.microsoft.com/powershell/2015/08/06/powershell-gallery-new-security-scan/) which explains the steps that are taken when code is uploaded.

If you cannot use the PowerShell Gallery then you can use this line of code to install from GitHub

Invoke-Expression (Invoke-WebRequest https://dbatools.io/in)

There is a video on the [download page](https://dbatools.io/download/) showing the installation on a Windows 7 machine and also some other methods of installing the module should you need them.

Website
-------

Next we visit [the website dbatools.io](https://dbatools.io) and look at the front page. We have our regular joke about how Chrissy doesn’t want to present on migrations but I think they are so cool so she makes me perform the commentary on the video. (Don’t tell anyone but it also helps us to get in as many of the 240+ commands in a one hour session as well 😉 ). You can watch the video on the [front page.](https://dbatools.io) You definitely should as you have never seen migrations performed so easily.

Then we talk about the comments we have received from well respected people from both SQL and PowerShell community members so you can trust that its not just some girl with hair and some bloke with a beard saying that its awesome.

Contributors
------------

Probably my [favourite page on the web-site](https://dbatools.io/team/) is the team page showing all of the amazing fabulous wonderful people who have given their own time freely to make such a fantastic free tool. If we have contributors in the audience we do try to point them out. One of our aims with dbatools is to enable people to receive the recognition for the hard work that they put in and we do this via the [team page](https://dbatools.io/team/), our [LinkedIn company page](https://dbatools.io/linkedin) as well as by linking back to the contributors in the help and the web-page for every command. I wish I could name check each one of you.

Thank You each and every one !!

Finding Commands
----------------

We then look at the [command page](https://dbatools.io/functions/) and the [new improved search page](https://dbatools.io/command-search/) and demonstrate how you can use them to find information about the commands that you need and the challenges in keeping this all maintained during a period of such rapid expansion.

Demo
----

Then it is time for me to say this phrase. “Strap yourselves in, do up your seatbelts, now we are going to show 240 commands in the next 40 minutes. Are you ready!!”

Of course, I am joking, one of the hardest things about doing a one hour presentation on [dbatools](https://dbatools.io/) is the sheer number of commands that we have that we want to show off. Of course we have already shown some of them in the migration video above but we still have a lot more to show and there are a lot more that we wish we had time to show.

Backup and Restore
------------------

We start with a restore of one database and a single backup file using [Restore-DbaDatabase ](https://dbatools.io/functions/restore-dbadatabase/)showing you the easy to read warning that you get if the database already exists and then how to resolve that warning with the WithReplace switch

Then how to use it to restore an entire instance worth of backups to the latest available time by pointing [Restore-DbaDatabase](https://dbatools.io/functions/restore-dbadatabase/) at a folder on a share

Then how to use [Get-DbaDatabase](https://dbatools.io/functions/Get-DbaDatabase/) to get all of the databases on an instance and pass them to [Backup-DbaDatabase](https://dbatools.io/functions/Backup-DbaDatabase) to back up an entire instance.

We look at the Backup history of some databases using [Get-DbaBackupHistory](https://dbatools.io/functions/Get-DbaBackupHistory/) and [Out-GridView](https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.utility/out-gridview) and examine detailed information about a backup file using [Read-DbaBackupHeader.](https://dbatools.io/functions/Read-DbaBackupHeader/)

We give thanks to Stuart Moore for his amazing work on these and several other backup and restore commands.

SPN’s
-----

After a quick reminder that you can search for commands at the command line using [Find-DbaCommand,](https://dbatools.io/functions/Find-DbaCommand/) we talk about SPNs and try to find someone, anyone, who actually likes working with SQL Server and SPNs and resolving the issues!!

Then we show Drew’s SPN commands [Get-DbaSpn](https://dbatools.io/functions/Get-DbaSpn), [Test-DbaSpn](https://dbatools.io/functions/Test-DbaSpn), [Set-DbaSpn](https://dbatools.io/functions/Set-DbaSpn)  and [Remove-DbaSpn ](https://dbatools.io/functions/Remove-DbaSpn/)

Holiday Tasks
-------------

We then talk about the things we ensure we run before going on holiday to make sure we leave with a warm fuzzy feeling that everything will be ok until we return :-

*   [Get-DbaLastBackup](https://dbatools.io/functions/Get-DbaLastBackup) will show the last time the database had any type of backup.

*   [Get-DbaLastGoodCheckDb](https://dbatools.io/functions/Get-DbaLastGoodCheckDb) which shows the last time that a database had a successful DBCC CheckDb and how we can gather the information for all the databases on all of your instances in just one line of code

*   [Get-DbaDiskSpace](https://dbatools.io/functions/Get-DbaDiskSpace/) which will show the disk information for all of the drives including mount points and whether the disk is in use by SQL


Testing Your Backup Files By Restoring Them
-------------------------------------------

We ask how many people test their backup files every single day and Dublin wins marks for a larger percentage than some other places we have given this talk. We show [Test-DbaLastBackup](https://dbatools.io/functions/Test-DbaLastBackup/) in action so that you can see the files being created because we think it looks cool (and you can see the filenames!) Chrissy has written a great post about how you can [set up your own dedicated backup file test server](https://dbatools.io/dedicated-server/)

Free Space
----------

We show how to gather the file space information using [Get-DbaDatabaseFreespace](http://Get-DbaDatabaseFreespace) and then how you can put that (or the results of any PowerShell command) into a SQL database table using [Out-DbaDataTable](https://dbatools.io/functions/Out-DbaDataTable/) and [Write-DbaDataTable](https://dbatools.io/functions/Write-DbaDataTable)

SQL Community
-------------

Next we talk about how we love to take community members blog posts and turn them into [dbatools](https://dbatools.io) commands.

We start with Jonathan Kehayias’s post about SQL Server Max memory ([http://bit.ly/sqlmemcalc](http://bit.ly/sqlmemcalc)) and show [Get-DbaMaxMemory](https://dbatools.io/functions/Get-DbaMaxMemory/) , [Test-DbaMaxMemory](https://dbatools.io/functions/Test-DbaMaxMemory/) and [Set-DbaMaxMemory](https://dbatools.io/functions/Set-DbaMaxMemory/)

Then [Paul Randal’s blog post about Pseudo-Simple Mode ](https://www.sqlskills.com/blogs/paul/new-script-is-that-database-really-in-the-full-recovery-mode/)which inspired  [Test-DbaFullRecoveryModel](https://dbatools.io/functions/Test-DbaFullRecoveryModel/)

We talked about getting backup history earlier but now we talk about [Get-DbaRestoreHistory](https://dbatools.io/functions/Get-DbaRestoreHistory/) a command inspired by [Kenneth Fishers blog post](https://sqlstudies.com/2016/07/27/when-was-this-database-restored/) to show when a database was restored and which file was used.

Next a command from [Thomas LaRock](https://thomaslarock.com/) which he gave us for testing linked servers [Test-DbaLinkedServerConnection.](https://dbatools.io/functions/Test-DbaLinkedServerConnection/)

[Glenn Berrys diagnostic information queries ](https://www.sqlskills.com/blogs/glenn/sql-server-diagnostic-information-queries-for-may-2017/) are available thanks to André Kamman and the commands Invoke-DbaDiagnosticQuery and Export-DbaDiagnosticQuery. The second one will output all of the results to csv files.

Adam Mechanic’s [sp_whoisactive](http://sqlblog.com/blogs/adam_machanic/archive/tags/who+is+active/default.aspx) is a common tool in SQL DBA’s toolkit and can now be installed using [Install-DbaWhoIsActive](https://dbatools.io/functions/install-dbawhoisactive/) and run using [Invoke-DbaWhoIsActive.](https://dbatools.io/functions/invoke-dbawhoisactive/)

Awesome Contributor Commands
----------------------------

Then we try to fit in as many commands that we can from our fantastic contributors showing how we can do awesome things with just one line of PowerShell code

> One line of code! Excellent 'Poweshell – SQL Server: Modern Database Administration' presentation by [@cl](https://twitter.com/cl) [@sqldbawithbeard](https://twitter.com/sqldbawithbeard) [#SqlSatDublin](https://twitter.com/hashtag/SqlSatDublin?src=hash) [pic.twitter.com/TOIsi0FgAA](https://t.co/TOIsi0FgAA)
>
> — Xavi Arnau (@xavidublin) [June 17, 2017](https://twitter.com/xavidublin/status/876078661279117312)

The awesome [Find-DbaStoredProcedure](https://dbatools.io/functions/Find-DbaStoredProcedure) which you can [read more about here](https://dbatools.io/need-for-speed-find-dbastoredprocedure/) which in tests searched 37,545 stored procedures on 9 instances in under 9 seconds for a particular string.

[Find-DbaOrphanedFile](https://dbatools.io/functions/Find-DbaOrphanedFile/) which enables you to identify the files left over from detaching databases.

Don’t know the SQL Admin password for an instance? [Reset-SqlAdmin](https://dbatools.io/functions/other/reset-sqladmin/) can help you.

It is normally somewhere around here that we finish and even though we have shown 32 commands (and a few more encapsulated in the Start-SqlMigration command) that is less than 15% of the total number of commands in the module!!!

Somehow, we always manage to fit all of that into 60 minutes and have great fun doing it. Thank you to everyone who has come and seen our sessions in Vienna, Utrecht, PASS PowerShell Virtual Group, Hanover, Antwerp and Dublin.

More
----

So you want to know more about [dbatools](https://dbatools.io/) ? You can click the link and explore the website

You can look at [source code on GitHub](https://github.com/sqlcollaborative/dbatools/)

You can join us in the [SQL Community Slack](https://sqlps.io/slack) in the #dbatools channel

You can watch videos on [YouTube](https://dbatools.io/youtube)

You can [see a list of all of the presentations](https://dbatools.io/presentations) and get a lot of the slides and demos

If you want to see the slides and demos from our Dublin presentation you can find them [here](https://github.com/sqlcollaborative/community-presentations/tree/master/rob-sewell-chrissy-lemaire)

Volunteers
----------

Lastly and most importantly of all. SQL Saturdays are run by volunteers so massive thanks to Bob, Carmel, Ben and the rest of the team who ensured that [SQL Saturday Dublin](https://twitter.com/search?f=tweets&vertical=default&q=sqlsatdublin%20volunteers&src=typd) went so very smoothly

> Massive thanks to the volunteers of [#SqlSatDublin](https://twitter.com/hashtag/SqlSatDublin?src=hash) [pic.twitter.com/veE0UuQxeO](https://t.co/veE0UuQxeO)
>
> — Shane O'Neill (@SOZDBA) [June 17, 2017](https://twitter.com/SOZDBA/status/876068038671511553)