---
title: "Rationalisation of Database with Powershell and T-SQL part two"
date: "2014-03-03" 
categories:
  - Blog

tags:
  - automate
  - backup
  - rationalise
  - restore


image: assets/uploads/2014/03/030314_2100_rationalisa1.png

---
In the [previous post](https://blog.robsewell.com/rationalisation-of-database-with-powershell-and-t-sql-part-one/) I showed the script to create an Excel Workbook, colour coded showing the last used date for all of the databases on servers in my sqlservers.txt file. After gathering that information over several months, there is then a requirement for someone to make a decision as to which databases can be removed.

Obviously there will be some databases that are read-only or if not set specifically as read-only may only be used for reference without data being added. You should hopefully have knowledge of these databases and be able to take them off the list quickly.

There are other challenges for a DBA to overcome prior to any action. Many questions need to be answered such as

Who owns the database?  
Who is the service owner responsible for the service/application in use by the database?  
Even though they may be the service owner who will ultimately sign off permission to remove the database are they aware of how important it is for their people? Or what times of the year it is important to them?  
You may find test and development databases that have not been used for months but will they be required next week?  
Is it important enough for them to take the time to give the permission?

And plenty more… Add some in the comments below.

Our [Primary responsibility](http://www.johnsansom.com/the-database-administrators-primary-responsibility/) is the data. We need to be able to ensure that the data is safe and can be made available quickly and easily. In this situation we need to have a valid backup and a quick and easy method of restoring it. I chose to solve this by creating a T-SQL script which will :-

*   Perform a [DBCC CHECKDB](http://technet.microsoft.com/en-us/library/ms176064.aspx) on the database
*   [Backup the database with CHECKSUM](http://technet.microsoft.com/en-us/library/ms187893.aspx)
*   Perform a [VERIFY ONLY](http://technet.microsoft.com/en-us/library/ms188902.aspx) restore of the database
*   Drop the database
*   Create an agent job to restore the database from that backup

The reasoning for these steps is best explained by watching [this video](http://www.youtube.com/watch?v=Ah0jabU9G8o) and yes I always perform the last step too J

I could have used PowerShell to do this by examining The SMO for the Server and the JobServer but this time I decided to challenge myself by writing it in T-SQL as I am weaker in that area. The script below is the result of that work. It works for me. I expect that there are other ways of doing this and please feel free to point out any errors or suggestions. That is how I learn. Hopefully these posts will be of use to other DBAs like myself.

As always with anything you read on the internet. Validate and test. This script works for me on SQL Servers 2005, 2008,2008R2 and 2012 but if you are thinking of running it in your own Production Environment – DON’T.

Well not until you have tested it somewhere safe first J

The first challenge I encountered was that I wanted to only have to change the name of the database to be able to run the script and perform all of these steps. That will also lead onto a stored procedure and then I can automate more of this process and schedule at times to suit the database servers as well. I accomplished this by using a temp table and populating it with the variables I will need as shown below

    -- Drop temp table if it exists
    IF OBJECT_ID('tempdb..#vars') IS NOT NULL
    DROP TABLE #vars 
    -- Create table to hold global variable
    create table #vars (DBName nvarchar(50), PATH nvarchar(300),DataName nvarchar(50),LogName nvarchar (50),DataLoc nvarchar (256),LogLoc nvarchar (256))
    insert into #vars (DBName) values ('DATABASENAME')
    -- Declare and set variables
    DECLARE @PATH nvarchar(300)
    Set @Path = (SELECT 'PATH TO RATIONALISATION FOLDER WITH TRAILING SLASH' + @DBName + '_LastGolden_' + + convert(varchar(50),GetDate(),112) + '.bak' )
    DECLARE @DataName nvarchar(50)
    Set @DataName = (SELECT f.name
    FROM sys.master_files F
    join sys.databases D
    on&amp;nbsp;d.database_id = f.database_id
    WHERE F.type = 0
    AND d.Name = @DBNAME)
    -- Print @DataName
    DECLARE @LogName nvarchar (50)
    Set @LogName = (SELECT f.name
    FROM sys.master_files F
    join sys.databases D
    on&amp;nbsp;d.database_id = f.database_id
    WHERE F.type = 1
    AND d.Name = @DBNAME)
    -- PRINT @LogName
    Declare @DataLoc nvarchar (256)
    Set @DataLoc = (SELECT f.physical_name
    FROM sys.master_files F
    join sys.databases D
    on&amp;nbsp;d.database_id = f.database_id
    WHERE F.type = 0
    AND d.Name = @DBNAME)
    --Print @DataLoc
    Declare @LogLoc nvarchar (256)
    Set @LogLoc = (SELECT f.physical_name
    FROM sys.master_files F
    join sys.databases D
    on&amp;nbsp;d.database_id = f.database_id
    WHERE F.type = 1
    AND d.Name = @DBNAME)
    --Print @LogLoc
    update #vars Set PATH = @PATH
    update #vars Set DataName = @DataName
    update #vars Set LogName = @LogName
    update #vars Set DataLoc = @DataLoc
    update #vars Set LogLoc = @LogLoc
    -- Select * from #vars

I then use the variables throughout the script by selecting them from the temp table as follows

    DECLARE @DBName nvarchar(50)
    Set @DBName = (Select DBNAme from #vars)&lt;code&gt;

And using the variables to create and execute the T-SQL for each of the steps above.

It is pointless to move onto the next step of the previous one has failed so I created some error handling as follows

    if @@error != 0 raiserror('Rationalisation Script failed at Verify Restore', 20, -1) with log
    GO

I created the T-SQL for the agent job by first creating the restore script and adding it to a variable and then right-clicking on a previously created restore database job and using the script to new window command

![](https://blog.robsewell.com/assets/uploads/2014/03/030314_2100_rationalisa1.png)

It was then a case of adding single quotes and reading the code until it would successfully run

    /***
    Rationalisation Script
    
    Script to Automatically Backup, Drop and create Agent Job to restore from that backup
    
    AUTHOR - Rob Sewell https://blog.robsewell.com
    DATE - 19/01/2014
    
    USAGE - You need to Change the Database Name after " insert #vars values (' "
    		You also need to check that the folder after " Set @Path = (SELECT ' " is correct and exists 
    		and Find and replace both entries for THEBEARD\Rob with the account that will be the owner of the job and the database owner
    		
    Once this has been run AND you have checked that it has successfully backed up the database and created the job and you have checked hte job works
    You may delete the backups but keep the backup folder under UserDbs
    
    ***/
    
     --Drop temp table if it exists 
    IF OBJECT_ID('tempdb..#vars') IS NOT NULL
    DROP TABLE #vars	
    
    --Create table to hold global variable
    create table #vars (DBName nvarchar(50), PATH nvarchar(300),DataName nvarchar(50),LogName nvarchar (50),DataLoc nvarchar (256),LogLoc nvarchar (256))
    insert into #vars (DBName) values ('SQL2012Ser2012DB'
    					)
    
    --Declare and set variables	
    
    DECLARE @DBName nvarchar(50)
    Set @DBName = (Select DBNAme from #vars)			
    
    DECLARE @PATH nvarchar(300)
    Set @Path = (SELECT 'PATH TO RATIONALISATION FOLDER' + @DBName + '_LastGolden_' + + convert(varchar(50),GetDate(),112) + '.bak' )
    
    DECLARE @DataName nvarchar(50)
    Set @DataName = (SELECT f.name
    FROM sys.master_files F 
    join sys.databases D
    on
    d.database_id = f.database_id
    WHERE F.type = 0
    AND d.Name = @DBNAME)
    
    --Print @DataName
    
    DECLARE @LogName nvarchar (50)
    Set @LogName = (SELECT f.name
    FROM sys.master_files F 
    join sys.databases D
    on
    d.database_id = f.database_id
    WHERE F.type = 1
    AND d.Name = @DBNAME)
    
    --PRINT @LogName
    
    Declare @DataLoc nvarchar (256)
    Set @DataLoc = (SELECT f.physical_name
    FROM sys.master_files F 
    join sys.databases D
    on
    d.database_id = f.database_id
    WHERE F.type = 0
    AND d.Name = @DBNAME)
    
    --Print @DataLoc
    
    Declare @LogLoc nvarchar (256)
    Set @LogLoc = (SELECT f.physical_name
    FROM sys.master_files F 
    join sys.databases D
    on
    d.database_id = f.database_id
    WHERE F.type = 1
    AND d.Name = @DBNAME)
    
    --Print @LogLoc
    
    update #vars Set PATH = @PATH 
    update #vars Set DataName = @DataName
    update #vars Set LogName = @LogName
    update #vars Set DataLoc = @DataLoc
    update #vars Set LogLoc = @LogLoc
    
    -- Select * from #vars
    -- DBCC
    
    DECLARE @DBCCSQL nvarchar (4000)
    SET @DBCCSQL = '
    USE [' + @DBName + ']
    DBCC CHECKDB WITH NO_INFOMSGS, ALL_ERRORMSGS
    '
    -- Print @DBCCSQL
    
    EXECUTE(@DBCCSQL)
    
    -- Break out if error raised We need to do some work if there are errors here
    
    if @@error != 0 raiserror('Rationalisation Script failed at DBCC', 20, -1) with log
    GO
    
    -- Declare and set variables	
    			
    DECLARE @DBName nvarchar(50)
    Set @DBName = (Select DBNAme from #vars)
    
    DECLARE @PATH nvarchar(300)
    Set @Path = (SELECT PATH from #vars)
    
    Declare @BKUPName nvarchar(300)
    Set @BKUPName = (SELECT 'Last Golden Backup For ' + @DBName + '- Full Database Backup')
    
    DECLARE @BackupSQL nvarchar (4000)
    SET @BackupSQL = '
    BACKUP DATABASE [' + @DBName + '] TO  DISK = N''' + @PATH + '''
    WITH INIT,  NAME = N''' + @BKUPName + ''', 
    CHECKSUM, STATS = 10
    '
    
    --- PRINT @BackupSQL
    
    -- Backup database to Golden backup location
    
    EXECUTE(@BackupSQL)
    GO
    
    -- Break Out if there are errors here - If there is no backup we don't want to continue
    
    if @@error != 0 raiserror('Rationalisation Script failed at Backup', 20, -1) with log
    GO
    
    DECLARE @PATH nvarchar(300)
    Set @Path = (SELECT PATH from #vars)
    
    RESTORE VERIFYONLY
    FROM DISK = @PATH;
    
    if @@error != 0 raiserror('Rationalisation Script failed at Verify Restore', 20, -1) with log
    GO
    -- Declare variables for dropping database
    
    DECLARE @DBName nvarchar(50)
    Set @DBName = (Select DBNAme from #vars)
    
    DECLARE @DROPSQL nvarchar (4000)
    SET @DROPSQL = '
    USE [master]
    ALTER DATABASE [' + @DBName + '] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
    DROP DATABASE [' + @DBName + '] 
    '
    -- PRINT @DROPSQL
    
    --Drop database
    
    EXECUTE(@DROPSQL)
    GO
    if @@error != 0 raiserror('Rationalisation Script failed at Drop Database', 20, -1) with log
    GO
    
    --Declare variables for creating Job
    
    DECLARE @DBName nvarchar(50)
    Set @DBName = (Select DBNAme from #vars)
    
    DECLARE @PATH nvarchar(300)
    Set @Path = (Select PATH from #vars)
    
    DECLARE @DataName nvarchar(50)
    Set @DataName = (Select DataName from #vars)
    
    DECLARE @LogName nvarchar (50)
    Set @LogName = (Select LogName from #vars)
    
    Declare @DataLoc nvarchar (256)
    Set @DataLoc = (Select DataLoc from #vars)
    
    Declare @LogLoc nvarchar (256)
    Set @LogLoc = (Select LogLoc from #vars)
    
    DECLARE @RestoreCommand nvarchar(4000)
    Set @RestoreCommand = '''RESTORE DATABASE [' + @DBName + '] 
    FROM  DISK = N''''' + @PATH + '''''
    WITH  FILE = 1,  
    MOVE N''''' + @DataName +  ''''' TO N''''' + @DataLoc + ''''',  
    MOVE N''''' + @LogName + ''''' TO N''''' + @LogLoc + ''''',  
    NOUNLOAD,  REPLACE,  STATS = 10
    
    '''
    --print @RestoreCommand
    
    --Create Job creation tsql
    
    DECLARE @JOBSQL nvarchar (4000)
    SET @JOBSQL = 'USE [msdb]
    
    BEGIN TRANSACTION
    DECLARE @ReturnCode INT
    SELECT @ReturnCode = 0
    /****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 01/18/2014 14:12:04 ******/
    IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N''[Uncategorized (Local)]'' AND category_class=1)
    BEGIN
    EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N''JOB'', @type=N''LOCAL'', @name=N''[Uncategorized (Local)]''
    IF (@@ERROR &lt;&gt; 0 OR @ReturnCode &lt;&gt; 0) GOTO QuitWithRollback
    
    END
    
    DECLARE @JOBNAME nvarchar(300)
    set @JOBNAME = ''Rationlised - - Restore '  + @DBName + ' from Last Golden Backup''
    
    Declare @JobDesc nvarchar(300)
    Set @JobDesc = '' Rationalised Database Restore Script for ' + @DBName + '''
    
    DECLARE @jobId BINARY(16)
    
    EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name= @JOBNAME, 
    		@enabled=1, 
    		@notify_level_eventlog=0, 
    		@notify_level_email=0, 
    		@notify_level_netsend=0, 
    		@notify_level_page=0, 
    		@delete_level=0, 
    		@description=@JobDesc, 
    		@category_name=N''[Uncategorized (Local)]'', 
    		@owner_login_name=N''THEBEARD\Rob'', @job_id = @jobId OUTPUT
    IF (@@ERROR &lt;&gt; 0 OR @ReturnCode &lt;&gt; 0) GOTO QuitWithRollback
    /****** Object:  Step [Restore Database]    Script Date: 01/18/2014 14:12:04 ******/
    EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N''Restore Database'', 
    		@step_id=1, 
    		@cmdexec_success_code=0, 
    		@on_success_action=3, 
    		@on_success_step_id=0, 
    		@on_fail_action=2, 
    		@on_fail_step_id=0, 
    		@retry_attempts=0, 
    		@retry_interval=0, 
    		@os_run_priority=0, @subsystem=N''TSQL'', 
    		@command= ' + @RestoreCommand + ', 
    		@database_name=N''master'', 
    		@flags=4
    /****** Object:  Step [Set Owner]    Script Date: 01/19/2014 10:14:57 ******/
    EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N''Set Owner'', 
    		@step_id=2, 
    		@cmdexec_success_code=0, 
    		@on_success_action=1, 
    		@on_success_step_id=0, 
    		@on_fail_action=2, 
    		@on_fail_step_id=0, 
    		@retry_attempts=0, 
    		@retry_interval=0, 
    		@os_run_priority=0, @subsystem=N''TSQL'', 
    		@command=N''USE [' + @DBName + ']
    
    EXEC sp_changedbowner @loginame = N''''THEBEARD\Rob'''', @map = false'', 
    		@database_name=N''master'', 
    		@flags=0		
    IF (@@ERROR &lt;&gt; 0 OR @ReturnCode &lt;&gt; 0) GOTO QuitWithRollback
    EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
    IF (@@ERROR &lt;&gt; 0 OR @ReturnCode &lt;&gt; 0) GOTO QuitWithRollback
    EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N''(local)''
    IF (@@ERROR &lt;&gt; 0 OR @ReturnCode &lt;&gt; 0) GOTO QuitWithRollback
    COMMIT TRANSACTION
    GOTO EndSave
    QuitWithRollback:
        IF (@@TRANCOUNT &gt; 0) ROLLBACK TRANSACTION
    EndSave:
    
    
    '
    --PRINT @JOBSQL
    
    --Create Agent Job
    
    EXECUTE(@JOBSql)
    
    if @@error != 0 raiserror('Rationalisation Script failed at Create Job', 20, -1) with log
    GO
    
    DROP Table #vars

The process I have used is to change the database name in the script and run it and then run the Agent Job and check the database has been created. Then and only then can I drop the database and disable any jobs for the database. Yes that was the last step in the video J as Grant says “a file is just a file, a backup is a restored database”

Using this script you can reduce the footprint and load on your servers by removing unneeded or unused databases whilst still guaranteeing that should there be a requirement for them you KNOW you can easily restore them. You will still need to take some additional steps like adding a stop to the Agent Job to recreate any users and any other jobs that the database needs but that is more specific to your environment and you will be best placed to achieve this
