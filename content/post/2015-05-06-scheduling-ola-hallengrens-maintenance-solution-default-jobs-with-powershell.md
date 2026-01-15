---
title: "Scheduling Ola Hallengrens Maintenance Solution Default Jobs with PowerShell"
date: "2015-05-06"

categories:
  - PowerShell
  - SQL Server
tags:
  - SQL Agent Jobs
  - automate
  - automation
  - backup
  - backups
  - Ola Hallengren
  - PowerShell
  - script
  - SMO
  - SQL
  - SQLBits
---

If you are a SQL Server DBA you should know about Ola Hallengren and will probably have investigated his Maintenance Solution.

If you haven't please start here [https://ola.hallengren.com/](https://ola.hallengren.com/)

You can also watch his presentation at SQLBits at this link

[http://sqlbits.com/Sessions/Event9/Inside_Ola_Hallengrens_Maintenance_Solution](http://sqlbits.com/Sessions/Event9/Inside_Ola_Hallengrens_Maintenance_Solution)

where he talks about and demonstrates the solution.

It is possible to just run his script to install the solution and schedule the jobs and know that you have made a good start in keeping your databases safe. You should be more proactive than that and set specific jobs for your own special requirements but you can and should find that information in other places including the FAQ on Ola's site

I particularly like the parameter @ChangeBackupType which when running the transaction log or differential backup will change the backup type to full if the backup type cannot be taken. This is excellent for picking up new databases and backing them up soon after creation

When you run the script the jobs are created but not scheduled and it is for this reason I created this function. All it does it schedule the jobs so that I know that they will be run when a new server is created and all the databases will be backed up. I can then go back at a later date and schedule them correctly for the servers workload or tweak them according to specific needs but this allows me that fuzzy feeling of knowing that the backups and other maintenance will be performed.

To accomplish this I pass a single parameter $Server to the function this is the connection string and should be in the format of `SERVERNAME`, `SERVERNAME\INSTANCENAME `or `SERVERNAME\INSTANCENAME,Port`

I then create a `$srv` SMO object as usual

`$srv = New-Object Microsoft.SQLServer.Management.SMO.Server $Server`

Create a JobServer object and a Jobs array which holds the Jobs
```
$JobServer = $srv.JobServer
$Jobs = $JobServer.Jobs
```
And set the schedule for each job. I pick each Job using the Where-Object Cmdlet and break out if the job does not exist
```
$Job = $Jobs|Where-Object {$_.Name -eq 'DatabaseBackup - SYSTEM_DATABASES - FULL'}
       if ($Job -eq $Null)
       {Write-Output "No Job with that name"
       break}
```
Then I create a Schedule object and set its properties and create the schedule
```
$Schedule = new-object Microsoft.SqlServer.Management.Smo.Agent.JobSchedule ($job, 'Daily - Midnight ++ Not Sunday')
$Schedule.ActiveEndDate = Get-Date -Month 12 -Day 31 -Year 9999
$Schedule.ActiveEndTimeOfDay = '23:59:59'
$Schedule.FrequencyTypes = "Weekly"
$Schedule.FrequencyRecurrenceFactor = 1
$Schedule.FrequencySubDayTypes = "Once"
$Schedule.FrequencyInterval = 126 # Weekdays 62 + Saturdays 64 - <a href="https://msdn.microsoft.com/en-us/library/microsoft.sqlserver.management.smo.agent.jobschedule.frequencyinterval.aspx">https://msdn.microsoft.com/en-us/library/microsoft.sqlserver.management.smo.agent.jobschedule.frequencyinterval.aspx</a>
$Schedule.ActiveStartDate = get-date
$schedule.ActiveStartTimeOfDay = '00:16:00'
$Schedule.IsEnabled = $true
$Schedule.Create()
```
I have picked this example for the blog as it shows some of the less obvious gotchas. Setting the active end date could only be achieved by using the Get-Date Cmdlet and defining the date. The schedule frequency interval above is for every day except Sundays. This achieved by using the following table from [MSDN](https://msdn.microsoft.com/en-us/library/microsoft.sqlserver.management.smo.agent.jobschedule.frequencyinterval.aspx?WT.mc_id=DP-MVP-5002693) which is always my first port of call when writing these scripts

> - WeekDays.Sunday = 1
> - WeekDays.Monday = 2
> - WeekDays.Tuesday = 4
> - WeekDays.Wednesday = 8
> - WeekDays.Thursday = 16
> - WeekDays.Friday = 32
> - WeekDays.Saturday = 64
> - WeekDays.WeekDays = 62
> - WeekDays.WeekEnds = 65
> - WeekDays.EveryDay = 127
>
> Combine values using an OR logical operator to set more than a single day. For example, combine WeekDays.Monday and WeekDays.Friday (FrequencyInterval = 2 + 32 = 34) to schedule an activity for Monday and Friday.

It is easy using this to set up whichever schedule you wish by combining the numbers. I would advise commenting it in the script so that your future self or following DBAs can understand what is happening.

You can tweak this script or use the code to work with any Agent Jobs and set the schedules accordingly and you can check that you have set the schedules correctly with this code
```
   $srv = New-Object Microsoft.SqlServer.Management.Smo.Server $Server
   $JObserver = $srv.JobServer
   $JObs = $JObserver.Jobs
   $ActiveStartTimeOfDay = @{Name = "ActiveStartTimeOfDay"; Expression = {$_.JobSchedules.ActiveStartTimeOfDay}}
   $FrequencyInterval = @{Name = "FrequencyInterval"; Expression = {$_.JobSchedules.FrequencyInterval}}
   $FrequencyTypes = @{Name = "FrequencyTypes"; Expression = {$_.JobSchedules.FrequencyTypes}}
   $IsEnabled = @{Name = "IsEnabled"; Expression = {$_.JobSchedules.IsEnabled}}
   $Jobs|Where-Object{$_.Category -eq 'Database Maintenance'}|select name,$IsEnabled,$FrequencyTypes,$FrequencyInterval,$ActiveStartTimeOfDay|Format-Table -AutoSize
```
You can get the script from Script Center via the link below or by searching for "Ola" using the [script browser add-in](http://www.microsoft.com/en-us/download/details.aspx?id=42525?WT.mc_id=DP-MVP-5002693) straight from ISE

[![browser](https://sqldbawithabeard.com/wp-content/uploads/2015/05/browser.jpg?w=300)](https://sqldbawithabeard.com/wp-content/uploads/2015/05/browser.jpg)

[https://gallery.technet.microsoft.com/scriptcenter/Schedule-Ola-Hallengrens-a66a3c89](https://gallery.technet.microsoft.com/scriptcenter/Schedule-Ola-Hallengrens-a66a3c89?WT.mc_id=DP-MVP-5002693)
