---
title: "SQL Express Migration Auto Close Setting"
categories:
  - Blog

tags:
  - automation
  - migration
  - PowerShell

header:
  teaser: /assets/uploads/2013/08/image_thumb.png

---
With over 700 databases to look after at MyWork automation is high on my list of priorities. I have two PowerShell scripts which run regularly checking SQL Error logs. One checks for the output from DBCC CHECKDB and one for errors. They then email the results to the DBA team.

This week we noticed that a new database was creating a lot of entries. It appeared to be starting up every few minutes. A bit of investigation by my colleague revealed that this database had been created on SQL Express and migrated to SQL Server.

SQL Express sets AUTO_CLOSE to on by default and this is what was creating the entries.

What does the AUTO_CLOSE setting do?

According to BoL [Link](http://technet.microsoft.com/en-us/library/ms190249(v=sql.105).aspx)


|Description|Default value|
|---|---|
|When set to ON, the database is shut down cleanly and its resources are freed after the last user exits. The database automatically reopens when a user tries to use the database again.|True for all databases when using SQL Server 2000 Desktop Engine or SQL Server Express, and False for all other editions, regardless of operating system.|
|When set to OFF, the database remains open after the last user exits.|  |
|||


That explains what was happening, the database was shutting down as the session finished and then starting back up again when the next one started. Repeatedly. Filling up the log files with entries, resetting the DMVs and using resources unnecessarily.

To find databases with this setting on query the master.sys.databases for the is_auto_close_on column [Link](http://technet.microsoft.com/en-us/library/ms178534.aspx) or check the properties page in SSMS

[![image](https://blog.robsewell.com/assets/uploads/2013/08/image_thumb.png)](https://i0.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/08/image.png)

You can change the setting there or with T-SQL

[![image](https://blog.robsewell.com/assets/uploads/2013/08/image3.png)](https://blog.robsewell.com/assets/uploads/2013/08/image3.png)

Of course I like to do it with PowerShell!!

To find the databases with AUTO_CLOSE setting on

[![image](https://blog.robsewell.com/assets/uploads/2013/08/image_thumb1.png "image")](https://blog.robsewell.com/assets/uploads/2013/08/image1.png)

To change the setting with PowerShell

[![image](https://blog.robsewell.com/assets/uploads/2013/08/image_thumb2.png "image")](https://blog.robsewell.com/assets/uploads/2013/08/image2.png)

    $svrs = ## list of servers Get-Content from text fiel etc
    
    foreach ($svr in $svrs) {
        $server = New-Object Microsoft.SQLServer.Management.Smo.Server $svrs
        foreach ($db in $server.Databases) {
            if ($db.AutoClose = $true) {
                Write-Output "$Server - $($DB.Name) AutoClose ON"
            }        
        }
        
    }
    
    $Svr = 'SERVERNAME'
    $DB = 'DatabaseName'
    $server = New-Object Microsoft.SQLServer.Management.Smo.Server $svrs
    $db.AutoClose = $false
    $db.Alter()

