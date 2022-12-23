---
title: "What Runs on the SQL Server when you run a PowerShell script?–Question from #SQLRelay"
categories:
  - Blog

tags:
  - backups
  - msdb
  - PowerShell
  - profiler
  - sqlrelay
  - SQL Server

---
Last week I ran a PowerShell lab at SQL Relay in Cardiff. There are still a few places available for SQL Relay week 2. [Take a look here for more details](http://www.sqlrelay.co.uk/) and follow the twitter [hashtag #SQLRelay](https://twitter.com/search?q=%23sqlrelay) for up to date information

The link for my slides and demos from the second part are here [https://t.co/Fik2odyUMA](https://t.co/Fik2odyUMA "https://t.co/Fik2odyUMA")

Whilst we were discussing [Show-LastDatabaseBackup](https://blog.robsewell.com/checking-for-a-database-backup-with-powershell/) Kev Chant [@KevChant](https://twitter.com/KevChant) asked where it was getting the information from and I answered that PowerShell was running SQL commands under the hood against the server and if you ran profiler that is what you would see. We didn’t have time to do that in Cardiff but I thought I would do it today to show what happens

A reminder of what `Show-LastDatabaseBackup` function does

[![image](https://blog.robsewell.com/assets/uploads/2013/11/image10.png)](https://blog.robsewell.com/assets/uploads/2013/11/image10.png)

If we start a trace with Profiler and run this function we get these results in PowerShell

[![image](https://blog.robsewell.com/assets/uploads/2013/11/image11.png)](https://blog.robsewell.com/assets/uploads/2013/11/image11.png)

In Profiler we see that it is running the following T-SQL for

[![image](https://blog.robsewell.com/assets/uploads/2013/11/image12.png)](https://blog.robsewell.com/assets/uploads/2013/11/image12.png)

    exec sp_executesql N' SELECT dtb.name AS [Name] FROM master.sys.databases AS dtb WHERE (dtb.name=@_msparam_0)',N'@_msparam_0 nvarchar(4000)',@_msparam_0=N'RageAgainstTheMachine'

and then for

[![image](https://blog.robsewell.com/assets/uploads/2013/11/image13.png)](https://blog.robsewell.com/assets/uploads/2013/11/image13.png)

    exec sp_executesql N' create table #tempbackup (database_name nvarchar(128), [type] char(1), backup_finish_date datetime) insert into #tempbackup select database_name, [type], max(backup_finish_date) from msdb..backupset where [type] = ''D'' or [type] = ''L'' or [type]=''I'' group by database_name, [type] SELECT (select backup_finish_date from #tempbackup where type = @_msparam_0 and db_id(database_name) = dtb.database_id) AS [LastBackupDate] FROM master.sys.databases AS dtb WHERE (dtb.name=@_msparam_1) drop table #tempbackup ',N'@_msparam_0 nvarchar(4000),@_msparam_1 nvarchar(4000)',@_msparam_0=N'D',@_msparam_1=N'RageAgainstTheMachine'


For

[![image](https://blog.robsewell.com/assets/uploads/2013/11/image14.png)](https://blog.robsewell.com/assets/uploads/2013/11/image14.png)

    exec sp_executesql N' create table #tempbackup (database_name nvarchar(128), [type] char(1), backup_finish_date datetime) insert into #tempbackup select database_name, [type], max(backup_finish_date) from msdb..backupset where [type] = ''D'' or [type] = ''L'' or [type]=''I'' group by database_name, [type] SELECT (select backup_finish_date from #tempbackup where type = @_msparam_0 and db_id(database_name) = dtb.database_id) AS [LastDifferentialBackupDate] FROM master.sys.databases AS dtb WHERE (dtb.name=@_msparam_1) &lt;mailto:dtb.name=@_msparam_1)&gt; drop table #tempbackup ',N'@_msparam_0 nvarchar(4000),@_msparam_1 nvarchar(4000)',@_msparam_0=N'I',@_msparam_1=N'RageAgainstTheMachine'

And for

[![image](https://blog.robsewell.com/assets/uploads/2013/11/image15.png)](https://blog.robsewell.com/assets/uploads/2013/11/image15.png)

    exec sp_executesql N' create table #tempbackup (database_name nvarchar(128), [type] char(1), backup_finish_date datetime) insert into #tempbackup select database_name, [type], max(backup_finish_date) from msdb..backupset where [type] = ''D'' or [type] = ''L'' or [type]=''I'' group by database_name, [type] SELECT (select backup_finish_date from #tempbackup where type = @_msparam_0 and db_id(database_name) = dtb.database_id) AS [LastLogBackupDate] FROM master.sys.databases AS dtb WHERE (dtb.name=@_msparam_1) &lt;mailto:dtb.name=@_msparam_1)&gt; drop table #tempbackup ',N'@_msparam_0 nvarchar(4000),@_msparam_1 nvarchar(4000)',@_msparam_0=N'L',@_msparam_1=N'RageAgainstTheMachine'

So the answer to your question Kev is

Yes it does get the information from the msdb database