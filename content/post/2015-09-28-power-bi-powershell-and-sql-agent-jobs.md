---
title: "Power Bi, PowerShell and SQL Agent Jobs"
date: "2015-09-28"
date: "2015-09-28" 
categories: 
  - Power Bi
  - PowerShell
  - SQL Server
tags: 
  - SQL Agent Jobs
  - automate
  - automation
  - backups
  - DBA Database
  - Power Bi
  - PowerShell
  - SMO
  - SQL Server
---

Continuing [my series on using Power Bi with my DBA Database](https://blog.robsewell.com/tags/#dba-database) I am going to show in this post how I create the most useful daily report for DBAs - The SQL Agent Job report. [You can get the scripts and reports here](https://1drv.ms/f/s!Ah9eXQJC3wLIh8BKfjiXBs7g6m7hfw)

Please note this project became [dbareports.io](http://dbareports.io)

[![AG1](https://sqldbawithabeard.com/wp-content/uploads/2015/09/ag1.jpg?w=300)](https://sqldbawithabeard.com/wp-content/uploads/2015/09/ag1.jpg)

This gives a quick overview of the status of the Agent Jobs across the estate and also quickly identifies recent failed jobs enabling the DBA to understand their focus and prioritise their morning efforts.

I gather the information into 2 tables AgentJobDetail
```
CREATE TABLE [Info].[AgentJobDetail](
[AgetnJobDetailID] [int] IDENTITY(1,1) NOT NULL,
[Date] [datetime] NOT NULL,
[InstanceID] [int] NOT NULL,
[Category] [nvarchar](50) NOT NULL,
[JobName] [nvarchar](250) NOT NULL,
[Description] [nvarchar](750) NOT NULL,
[IsEnabled] [bit] NOT NULL,
[Status] [nvarchar](50) NOT NULL,
[LastRunTime] [datetime] NOT NULL,
[Outcome] [nvarchar](50) NOT NULL,
CONSTRAINT [PK_info.AgentJobDetail] PRIMARY KEY CLUSTERED
(
[AgetnJobDetailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
```
and AgentJobServer
```
CREATE TABLE [Info].[AgentJobServer](
[AgentJobServerID] [int] IDENTITY(1,1) NOT NULL,
[Date] [datetime] NOT NULL,
[InstanceID] [int] NOT NULL,
[NumberOfJobs] [int] NOT NULL,
[SuccessfulJobs] [int] NOT NULL,
[FailedJobs] [int] NOT NULL,
[DisabledJobs] [int] NOT NULL,
[UnknownJobs] [int] NOT NULL,
CONSTRAINT [PK_Info.AgentJobServer] PRIMARY KEY CLUSTERED
(
[AgentJobServerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
```
The Detail table holds the results of every Agent Job and the Server table holds a roll up for each server. The script to gather this information is based on the script I used to put the information into an Excel Sheet as described in my post [How I Check Hundreds of Agent Jobs in 60 Seconds with PowerShell](https://blog.robsewell.com/blog/how-i-check-hundreds-of-sql-agent-jobs-in-60-seconds-with-powershell/) which I also altered to send an HTML email to the DBA team each morning. This however is a much better solution and allows for better monitoring and trending.

As I have explained [in my previous posts](https://blog.robsewell.com/tags/#dba-database) I use an Instance List table to hold the information about each instance in the estate and a series of PowerShell scripts which run via Agent Jobs to gather the information into various tables. These posts describe the use of the Write-Log function and the methodology of gathering the required information and looping through each instance so I wont repeat that here. There is an extra check I do however for Express Edition as this does not contain the Agent service
```
$edition = $srv.Edition
if ($Edition -eq 'Express') {
    Write-Log -Path $LogFile -Message "No Information gathered as this Connection $Connection is Express"
    continue
}
```
The Agent Job information can be found in SMO by exploring the `$srv.JobServer.Jobs` object and I gather the information by iterating through each job and setting the values we require to variables
```
try {
    $JobCount = $srv.JobServer.jobs.Count
    $successCount = 0
    $failedCount = 0
    $UnknownCount = 0
    $JobsDisabled = 0
    #For each job on the server
    foreach ($jobin$srv.JobServer.Jobs)
    {
        $jobName = $job.Name;
        $jobEnabled = $job.IsEnabled;
        $jobLastRunOutcome = $job.LastRunOutcome;
        $Category = $Job.Category;
        $RunStatus = $Job.CurrentRunStatus;
        $Time = $job.LastRunDate;
        if ($Time -eq '01/01/000100:00:00')
        {$Time = ''}
        $Description = $Job.Description;
        #Counts for jobs Outcome
        if ($jobEnabled -eq $False)
        {$JobsDisabled += 1}
        elseif ($jobLastRunOutcome -eq "Failed")
        {$failedCount += 1; }
        elseif ($jobLastRunOutcome -eq "Succeeded")
        {$successCount += 1; }
        elseif ($jobLastRunOutcome -eq "Unknown")
        {$UnknownCount += 1; }
    }    
}
```
I found that some Jobs had names and descriptions that had ' in them which would cause the SQL update or insert statement to fail so I use the replace method to replace the ' with ''
```
if ($Description -eq $null) {
    $Description = ' '
}
$Description = $Description.replace('''', '''''')
if ($jobName -eq $Null) {
    $jobName = 'None'
}
$JobName = $JobName.replace('''', '''''')
```
I then insert the data per job after checking that it does not already exist which allows me to re-run the job should a number of servers be uncontactable at the time of the job running without any additional work
```
IF NOT EXISTS (
SELECT  [AgetnJobDetailID]
FROM [DBADatabase].[Info].[AgentJobDetail]
where jobname = '$jobName'
and InstanceID = (SELECT [InstanceID]
FROM [DBADatabase].[dbo].[InstanceList]
WHERE [ServerName] = '$ServerName'
AND [InstanceName] = '$InstanceName'
AND [Port] = '$Port')
and lastruntime = '$Time'
)
INSERT INTO [Info].[AgentJobDetail]
([Date]
,[InstanceID]
,[Category]
,[JobName]
,[Description]
,[IsEnabled]
,[Status]
,[LastRunTime]
,[Outcome])
VALUES
(GetDate()
,(SELECT [InstanceID]
FROM [DBADatabase].[dbo].[InstanceList]
WHERE [ServerName] = '$ServerName'
AND [InstanceName] = '$InstanceName'
AND [Port] = '$Port')
,'$Category'
,'$jobName'
,'$Description'
,'$jobEnabled'
,'$RunStatus'
,'$Time'
,'$jobLastRunOutcome')
```
I put this in a here-string variable and pass it to Invoke-SQLCmd I do the same with the roll up using this query
```
INSERT INTO [Info].[AgentJobServer]
([Date]
,[InstanceID]
,[NumberOfJobs]
,[SuccessfulJobs]
,[FailedJobs]
,[DisabledJobs]
,[UnknownJobs])
VALUES
(GetDate()
,(SELECT [InstanceID]
FROM [DBADatabase].[dbo].[InstanceList]
WHERE [ServerName] = '$ServerName'
AND [InstanceName] = '$InstanceName'
AND [Port] = '$Port')
,'$JobCount'
,'$successCount'
,'$failedCount'
,'$JobsDisabled'
,'$UnknownCount')
```
This job runs as a SQL Agent Job every morning a half an hour or so before the DBA arrives for the morning shift vastly improving the ability of the DBA to prioritise their morning routine.

To create the report open Power Bi Desktop and click Get Data

[![ag2](https://sqldbawithabeard.com/wp-content/uploads/2015/09/ag2.jpg?w=300)](https://sqldbawithabeard.com/wp-content/uploads/2015/09/ag2.jpg)

Then choose SQL Server and click connect

[![ag3](https://sqldbawithabeard.com/wp-content/uploads/2015/09/ag3.jpg?w=274)](https://sqldbawithabeard.com/wp-content/uploads/2015/09/ag3.jpg)

Enter the Connection string, the database and the  query to gather the data

[![ag5](https://sqldbawithabeard.com/wp-content/uploads/2015/09/ag5.jpg?w=300)](https://sqldbawithabeard.com/wp-content/uploads/2015/09/ag5.jpg)

The query is
```
Select IL.InstanceID,
IL.ServerName,
IL.InstanceName,
IL.Environment,
IL.Location,
AJD.Category,
AJD.Date,
AJD.Description,
AJD.IsEnabled,
AJD.JobName,
AJD.LastRunTime,
AJD.Outcome,
AJD.Status
FROM [dbo].[InstanceList] IL
JOIN [Info].[AgentJobDetail] AJD
ON IL.InstanceID = AJD.InstanceID
WHERE LastRunTime > DATEADD(Day,-31,GETDATE())
```
Once we have gathered the data we then create some extra columns and measures for the reports. First I create a date column from the datetime Date Column
```
DayDate = DATE(YEAR('Agent Job Detail'[Date]),MONTH('Agent Job Detail'[Date]),DAY('Agent Job Detail'[Date]))
```
I also do the same for the LastRuntime. I create a day of the week column so that I can report on jobs outcome by day
```
DayyOfWeek = CONCATENATE(WEEKDAY('Agent Job Detail'[Date],2),FORMAT('Agent Job Detail'[Date]," -dddd"))
```
My friend Terry McCann [b](http://hyperbi.co.uk) | [t](https://twitter.com/@sqlshark) helped me create a column that returns true if the last run time is within 24 hours of the current time to help identify the recent jobs that have failed NOTE - On a Monday morning you will need to change this if you do not check your jobs on the weekend.
```
Last Run Relative Hour = ((1.0\*(NOW()-'Agent Job Detail'[LastRunTime]))\*24)<24
```
I create a measure for Succeeded, Failed and Unknown
```
Succeeded = IF('Agent Job Detail'[Outcome] = "Succeeded"
, 1
, 0)
```
Next we have to create some measures for the sum of failed jobs and the averages This is the code for 7 day sum
```
Failed7Days = CALCULATE(SUM('Agent Job Detail'[Failed]),FILTER (
ALL ( 'Agent Job Detail'[Last Run Date] ),
'Agent Job Detail'[Last Run Date] > ( MAX ( 'Agent Job Detail'[Last Run Date]  ) - 7 )
&& 'Agent Job Detail'[Last Run Date]  <= MAX ( 'Agent Job Detail'[Last Run Date]  )     ) )
```
and for the 7 Day average
```
Failed7DayAverage = DIVIDE([Failed7Days],7)
```
I did the same for 30 days. I used the [TechNet reference for DAX expressions](http://social.technet.microsoft.com/wiki/contents/articles/680.powerpivot-dax-filter-functions.aspx) and got ideas from [Chris Webbs blog](http://blog.crossjoin.co.uk/category/dax/)

[![ag6](https://sqldbawithabeard.com/wp-content/uploads/2015/09/ag6.jpg?w=83)](https://sqldbawithabeard.com/wp-content/uploads/2015/09/ag6.jpg) First I created the 30 day historical trend chart using a Line and Clustered column chart using the last run date as the axis and the succeed measure as the column and the Failed, Failed 7 Day Average and failed 30 day average as the lines

I then formatted the lines and title and column

[![ag7](https://sqldbawithabeard.com/wp-content/uploads/2015/09/ag7.jpg?w=300)](https://sqldbawithabeard.com/wp-content/uploads/2015/09/ag7.jpg)

To create the gauge which shows how well we have done today I created a measure to quickly identify todays jobs
```
LastRun Relative Date Offset = INT('Agent Job Detail'[LastRunTime] - TODAY())
```
which I use as a filter for the gauge as shown below. I also create two measures zero and twenty for the minimum and maximum for the gauge

[![ag8](https://sqldbawithabeard.com/wp-content/uploads/2015/09/ag8.jpg?w=300)](https://sqldbawithabeard.com/wp-content/uploads/2015/09/ag8.jpg)

The rest of the report is measures for 7 day average and 30 day average, a slicer for environment  and two tables, one to show the historical job counts and one to show the jobs that have failed in the last 24 hours using the Last Run Relative Hour measure from above

[![ag9](https://sqldbawithabeard.com/wp-content/uploads/2015/09/ag9.jpg?w=300)](https://sqldbawithabeard.com/wp-content/uploads/2015/09/ag9.jpg)

There are many other reports that you can or may want to create maybe by day of the week or by category depending on your needs. Once you have the data gathered you are free to play with the data as you see fit. Please add any further examples of reports you can run or would like to run in the comments below.

Once you have your report written you can publish it to PowerBi.com and create a dashboard and query it with natural language. I have explained the process [in previous posts](https://blog.robsewell.com/tags/#dba-database)

For example - How many Jobs failed today

[![ag110](https://sqldbawithabeard.com/wp-content/uploads/2015/09/ag110.jpg?w=300)](https://sqldbawithabeard.com/wp-content/uploads/2015/09/ag110.jpg)

Which server had most failed jobs

[![ag11](https://sqldbawithabeard.com/wp-content/uploads/2015/09/ag11.jpg?w=300)](https://sqldbawithabeard.com/wp-content/uploads/2015/09/ag11.jpg)

or using the category field which database maintenance jobs failed today

[![ag13](https://sqldbawithabeard.com/wp-content/uploads/2015/09/ag13.jpg?w=300)](https://sqldbawithabeard.com/wp-content/uploads/2015/09/ag13.jpg)

I hope these posts have given you ideas about how you can use PowerShell, a DBA Database and Power Bi to help you to manage and report on your environment.

[You can get the scripts and reports here](https://1drv.ms/f/s!Ah9eXQJC3wLIh8BKfjiXBs7g6m7hfw)

I have written further posts about this

[**Using Power Bi with my DBA Database**](https://blog.robsewell.com/sql%20server/using-power-bi-with-my-dba-database/ )

[**Populating My DBA Database for Power Bi with PowerShell – Server Info**](https://blog.robsewell.com/power%20bi/powershell/sql%20server/populating-my-dba-database-for-power-bi-with-powershell-server-info/ )

[**Populating My DBA Database for Power Bi with PowerShell – SQL Info**](https://blog.robsewell.com/power%20bi/powershell/sql%20server/populating-my-dba-database-for-power-bi-with-powershell-sql-info/ )

[**Populating My DBA Database for Power Bi with PowerShell – Databases**](https://blog.robsewell.com/power%20bi/powershell/sql%20server/populating-my-dba-database-for-power-bi-with-powershell-databases/ )

[**Power Bi, PowerShell and SQL Agent Jobs**](https://blog.robsewell.com/power%20bi/powershell/sql%20server/power-bi-powershell-and-sql-agent-jobs/ )
