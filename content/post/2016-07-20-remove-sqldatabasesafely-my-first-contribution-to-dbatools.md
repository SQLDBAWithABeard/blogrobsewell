---
title: "Remove-SQLDatabaseSafely My First Contribution to DBATools"
date: "2016-07-20"
categories:
  - Blog

tags:
  - napalmgram
  - automate
  - automation
  - backups
  - dbatools
  - github
  - rationalise
  - restore
  - slack

---
What is DBA Tools?

> A collection of modules for SQL Server DBAs. It initially started out as ‘sqlmigration’, but has now grown into a collection of various commands that help automate DBA tasks and encourage best practices.

You can read more about [here](https://dbatools.io) and it is [freely available for download on GitHub](https://github.com/ctrlbold/dbatools) I thoroughly recommend that [you watch this quick video](https://www.youtube.com/watch?v=PciYdDEBiDM) to see just how easy it is to migrate an entire SQL instance in one command ([Longer session here](https://www.youtube.com/watch?v=kQYUrSlb0wg) )

Installing it is as easy as

`Install-Module dbatools`

which will get you over 80 commands . Visit [https://dbatools.io/functions/](https://dbatools.io/functions/) to find out more information about them

[![cmdlets](/assets/uploads/2016/07/cmdlets.png)](/assets/uploads/2016/07/cmdlets.png)

The journey to `Remove-SQLDatabaseSafely` started with William Durkin [b](http://williamdurkin.com/) | [t](https://twitter.com/sql_williamd) who presented to the [SQL South West User Group](http://sqlsouthwest.co.uk/)  ([You can get his slides here)](http://www.sqlsaturday.com/269/Sessions/Details.aspx?sid=28201)

Following that session  I wrote a Powershell Script to gather information about the last used date for databases [which I blogged about here](/rationalisation-of-database-with-powershell-and-t-sql-part-one/) and then a T-SQL script to take a final backup and create a SQL Agent Job to restore from that back up [which I blogged about here](/rationalisation-of-database-with-powershell-and-t-sql-part-two-2/) The team have used this solution (updated to load the DBA Database and a report instead of using Excel) ever since and it proved invaluable when a read-only database was dropped and could quickly and easily be restored with no fuss.

I was chatting with Chrissy LeMaire who founded DBATools [b](https://blog.netnerds.net/) | [t](https://twitter.com/cl) about this process and when she asked for contributions in the [SQL Server Community Slack](https://sqlps.io/slack) I offered my help and she suggested I write this command. I have learnt so much. I thoroughly enjoyed and highly recommend working on projects collaboratively to improve your skills. It is amazing to work with such incredible professional PowerShell people.

I went back to the basics and thought about what was required and watched one of my favourite videos again. [Grant Fritcheys Backup Rant](https://sqlps.io/backuprant)

I decided that the process should be as follows

1.  Performs a DBCC CHECKDB
2.  Database is backed up WITH CHECKSUM
3.  Database is restored with VERIFY ONLY on the source
4.  An Agent Job is created to easily restore from that backup
5.  The database is dropped
6.  The Agent Job restores the database
7.  performs a DBCC CHECKDB and drops the database for a final time

This (hopefully) passes all of Grants checks. This is how I created the command

I check that the SQL Agent is running otherwise we wont be able to run the job. I use a while loop with a timeout like this
```
$agentservice = Get-Service -ComputerName $ipaddr -Name $serviceName
if ($agentservice.Status -ne 'Running') {
    $agentservice.Start()
    $timeout = new-timespan -seconds 60
    $sw = [diagnostics.stopwatch]::StartNew()
    $agentstatus = (Get-Service -ComputerName $ipaddr -Name $serviceName).Status
    while ($dbStatus -ne 'Running' -and $sw.elapsed -lt $timeout) {
        $dbStatus = (Get-Service -ComputerName $ipaddr -Name $serviceName).Status
    }
}
```
There are a lot more checks and logic than I will describe here to make sure that the process is as robust as possible. For example, the script can exit after errors are found using DBCC CHECKDB or continue and label the database backup file and restore job appropriately. Unless the force option is used it will exit if the job name already exists. We have tried to think of everything but if something has been missed or you have suggestions let us know (details at end of post)

The only thing I didn’t add was a LARGE RED POP UP SAYING ARE YOU SURE YOU WANT TO DROP THIS DATABASE but I considered it!!

Performs a DBCC CHECKDB
-----------------------

Running DBCC CHECKDB with Powershell is as easy as this
```
$sourceserver = New-Object Microsoft.SQLServer.Management.Smo.Server "ServerName"
$db = $sourceserver.databases[$dbname]
$null = $db.CheckTables('None')
```
[you can read more on MSDN](https://msdn.microsoft.com/en-us/library/microsoft.sqlserver.management.smo.database.checktables.aspx)

Database is backed up WITH CHECKSUM
-----------------------------------

Stuart Moore is my go to for doing [backups and restores with SMO](http://stuart-moore.com/category/31-days-of-sql-server-backup-and-restore-with-powershell/)

I ensured that the backup was performed with checksum like this
```
$backup = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Backup
$backup.Action = [Microsoft.SqlServer.Management.SMO.BackupActionType]::Database
$backup.BackupSetDescription = "Final Full Backup of $dbname Prior to Dropping"
$backup.Database = $dbname
$backup.Checksum = $True
```
Database is restored with VERIFY ONLY on the source
---------------------------------------------------

I used SMO all the way through this command and performed the restore verify only like this
```
$restoreverify = New-Object 'Microsoft.SqlServer.Management.Smo.Restore'
$restoreverify.Database = $dbname
$restoreverify.Devices.AddDevice($filename, $devicetype)
$result = $restoreverify.SqlVerify($sourceserver)
```
An Agent Job is created to easily restore from that backup
----------------------------------------------------------

First I created a category for the Agent Job
```
Function New-SqlAgentJobCategory {
    param ([string]$categoryname,
        [object]$jobServer)
    if (!$jobServer.JobCategories[$categoryname]) {
        if ($Pscmdlet.ShouldProcess($sourceserver, "Creating Agent Job Category $categoryname")
            {
                try {
                    Write-Output "Creating Agent Job Category $categoryname"
                    $category = New-Object Microsoft.SqlServer.Management.Smo.Agent.JobCategory
                    $category.Parent = $jobServer
                    $category.Name = $categoryname
                    $category.Create()
                    Write-Output "Created Agent Job Category $categoryname"
                }
                catch {
                    Write-Exception $_
                    throw "FAILED : To Create Agent Job Category $categoryname - Aborting"
                }
            }
        }
    }
}
```
and then generated the TSQL for the restore step by using the [script method on the Restore SMO object](https://msdn.microsoft.com/en-us/library/microsoft.sqlserver.management.smo.restore.script.aspx)

This is how to create an Agent Job
```
$job = New-Object Microsoft.SqlServer.Management.Smo.Agent.Job $jobServer, $jobname
$job.Name = $jobname
$job.OwnerLoginName = $jobowner
$job.Description = "This job will restore the $dbname database using the final backup located at $filename"
```
and then to add a job step to run the restore command
```
$jobStep = new-object Microsoft.SqlServer.Management.Smo.Agent.JobStep $job, $jobStepName $jobStep.SubSystem = 'TransactSql' # 'PowerShell' 
$jobStep.DatabaseName = 'master' 
$jobStep.Command = $jobStepCommmand 
$jobStep.OnSuccessAction = 'QuitWithSuccess' 
$jobStep.OnFailAction = 'QuitWithFailure' 
if ($Pscmdlet.ShouldProcess($destination, "Creating Agent JobStep on $destination")
    { 
        $null = $jobStep.Create()
    } 
    $job.ApplyToTargetServer($destination)
    $job.StartStepID = $jobStartStepid 
    $job.Alter()
```
The database is dropped
-----------------------

We try 3 different methods to drop the database
```
$server.KillDatabase($dbname)
$server.databases[$dbname].Drop()
$null = $server.ConnectionContext.ExecuteNonQuery("DROP DATABASE ")
```
The Agent Job restores the database
-----------------------------------

To run the Agent Job I call the start method of the Job SMO Object
```
    $job = $destserver.JobServer.Jobs[$jobname]
    $job.Start()
    $status = $job.CurrentRunStatus
    while ($status -ne 'Idle') {
        Write-Output &quot; Restore Job for $dbname on $destination is $status&quot;
        $job.Refresh()
        $status = $job.CurrentRunStatus
        Start-Sleep -Seconds 5
    }
```
Then we drop the database for the final time with the confidence that we have a safe backup and an easy one click method to restore it from that backup (as long as the backup is in the same location)

There are further details on the [functions page on dbatools](https://dbatools.io/functions/remove-sqldatabasesafely/)

Some videos of it in action are on YouTube [http://dbatools.io/video](http://dbatools.io/video)

You can take a look at [the code on GitHub here](https://github.com/ctrlbold/dbatools/blob/fbd2f19b4442a8065f3cb133d385fde9b2cddea0/functions/Remove-SqlDatabaseSafely.ps1)

You can install it with

`Install-Module dbatools`

You can provide feedback via the [Trello Board](https://dbatools.io/trello) or discuss it in the #dbatools channel in the [Sqlserver Community Slack](https://sqlps.io/slack)

You too can also become a contributor [https://dbatools.io/join-us/](https://dbatools.io/join-us/) Come and write a command to make it easy for DBAs to (this bit is up to your imagination).
