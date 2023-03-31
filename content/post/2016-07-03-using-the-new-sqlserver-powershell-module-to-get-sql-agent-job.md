---
title: "Using the new SQLServer Powershell module to get SQL Agent Job Information"
categories:
  - Blog

tags:
  - automate
  - backups
  - documentation
  - PowerShell
  - script
  - sql
header:
  teaser: /assets/uploads/2016/07/getcomand-sqlagent.png
---
So with the July Release of SSMS everything changed for using PowerShell with SQL. [You can read the details here](https://blogs.technet.microsoft.com/dataplatforminsider/2016/06/30/sql-powershell-july-2016-update/) As I mentioned in my previous post the name of the module has changed to sqlserver

> _This means that if you have a PowerShell script doing_ Import-Module SQLPS_, it will need to be changed to be_ Import-Module SqlServer _in order to take advantage of the new provider functionality and new CMDLETs. The new module will be installed to_ “%Program Files\WindowsPowerShell\Modules\SqlServer_” and hence no update to $env:PSModulePath is required._

You can download [the latest SSMS release here](https://msdn.microsoft.com/en-us/library/mt238290.aspx) Once you have installed and rebooted you can start to look at the new Powershell CMDlets

`Import-module sqlserver`

Take a look at cmdlets

`  Get-command -module sqlserver`

Today I want to look at agent jobs

`  Get-command *sqlagent*`

[![getcomand sqlagent](/assets/uploads/2016/07/getcomand-sqlagent.png)](/assets/uploads/2016/07/getcomand-sqlagent.png)

So I decided to see how to gather the information I gather for the DBADatabase [as described here](/power-bi-powershell-and-sql-agent-jobs/)

This is the query I use to insert the data for the server level agent job information.
```
  $Query = @"
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
"@
```
So Get-SQLAgentJob looks like the one I need. Lets take a look at the help. This should be the starting point whenever you use a new cmdlet

`  Get-Help Get-SqlAgentJob -Full`

Which states

> Returns a SQL Agent Job object for each job that is present in the target instance of SQL Agent.

That sounds like it will meet my needs. Lets take a look

` Get-SqlAgentJob -ServerInstance $Connection|ft -AutoSize`

[![sqlinstances](/assets/uploads/2016/07/sqlinstances.png)](/assets/uploads/2016/07/sqlinstances.png)

I can get the information I require like this
```
 $JobCount = (Get-SqlAgentJob -ServerInstance $Connection ).Count
$successCount = (Get-SqlAgentJob -ServerInstance $Connection ).where{$_.LastRunOutcome -eq 'Succeeded'}.Count
$failedCount = (Get-SqlAgentJob -ServerInstance $Connection ).where{$_.LastRunOutcome -eq 'Failed'}.Count
$JobsDisabled = (Get-SqlAgentJob -ServerInstance $Connection ).where{$_.IsEnabled -eq $false}.Count
$UnknownCount = (Get-SqlAgentJob -ServerInstance $Connection ).where{$_.LastRunOutcome -eq 'Unknown'}.Count
```
NOTE – That code is for PowerShell V4 and V5, if you are using earlier versions of PowerShell you would need to use
```
 $JobCount = (Get-SqlAgentJob -ServerInstance $Connection ).Count
$successCount = (Get-SqlAgentJob -ServerInstance $Connection|Where-Object {$_.LastRunOutcome -eq 'Succeeded'}).Count
$failedCount = (Get-SqlAgentJob -ServerInstance $Connection |Where-Object {$_.LastRunOutcome -eq 'Failed'}).Count
$JobsDisabled = (Get-SqlAgentJob -ServerInstance $Connection |Where-Object{$_.IsEnabled -eq $false}).Count
$UnknownCount = (Get-SqlAgentJob -ServerInstance $Connection |Where-Object{$_.LastRunOutcome -eq 'Unknown'}).Count
```
But to make the code more performant it is better to do this
```
  [pscustomobject]$Jobs= @{}
$Jobs.JobCount = (Get-SqlAgentJob -ServerInstance $Connection ).Count
$Jobs.successCount = (Get-SqlAgentJob -ServerInstance $Connection ).where{$_.LastRunOutcome -eq 'Succeeded'}.Count
$Jobs.failedCount = (Get-SqlAgentJob -ServerInstance $Connection ).where{$_.LastRunOutcome -eq 'Failed'}.Count
$Jobs.JobsDisabled = (Get-SqlAgentJob -ServerInstance $Connection ).where{$_.IsEnabled -eq $false}.Count
$Jobs.UnknownCount = (Get-SqlAgentJob -ServerInstance $Connection ).where{$_.LastRunOutcome -eq 'Unknown'}.Count
$Jobs
```
[![jobs](/assets/uploads/2016/07/jobs.png)](/assets/uploads/2016/07/jobs.png)

Using Measure-Command showed that this completed in  
TotalSeconds : 0.9889336  
Rather than  
TotalSeconds : 2.9045701

Note that

`  (Get-SqlAgentJob -ServerInstance $Connection ).where{$_.Enabled -eq $false}.Count`

Does not work. I had to check the properties using
```
  Get-SqlAgentJob -ServerInstance $Connection |Get-Member -Type Properties
```
Which showed me

`IsEnabled Property bool IsEnabled {get;set;}`

So I tested this against the various SQL versions I had in my lab using this code
```
 $Table = $null
$Table = New-Object System.Data.DataTable "Jobs"
$Col1 = New-Object System.Data.DataColumn ServerName,([string])
$Col2 = New-Object System.Data.DataColumn JobCount,([int])
$Col3 = New-Object System.Data.DataColumn SuccessCount,([int])
$Col4 = New-Object System.Data.DataColumn FailedCount,([int])
$Col5 = New-Object System.Data.DataColumn DisabledCount,([int])
$Col6 = New-Object System.Data.DataColumn UnknownCount,([int])

$Table.Columns.Add($Col1)
$Table.Columns.Add($Col2)
$Table.Columns.Add($Col3)
$Table.Columns.Add($Col4)
$Table.Columns.Add($Col5)
$Table.Columns.Add($Col6)
foreach ($ServerName in $DemoServers)
{
## $ServerName
$InstanceName =  $ServerName|Select-Object InstanceName -ExpandProperty InstanceName
$Port = $ServerName| Select-Object Port -ExpandProperty Port
$ServerName = $ServerName|Select-Object ServerName -ExpandProperty ServerName
$Connection = $ServerName + '\' + $InstanceName + ',' + $Port
try
{
$srv = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $Connection
}
catch
{
"Failed to connect to $Connection"
}
if (!( $srv.version)){
"Failed to Connect to $Connection"
continue
}
[pscustomobject]$Jobs= @{}
$JobHistory = Get-SqlAgentJob -ServerInstance $Connection
$Row = $Table.NewRow()
$Row.ServerName = $ServerName
$Row.JobCount = $JobHistory.Count
$Row.SuccessCount = $JobHistory.where{$_.LastRunOutcome -eq 'Succeeded'}.Count
$Row.FailedCount = $JobHistory.where{$_.LastRunOutcome -eq 'Failed'}.Count
$Row.DisabledCount = $JobHistory.where{$_.IsEnabled -eq $false}.Count
$Row.UnknownCount = $JobHistory.where{$_.LastRunOutcome -eq 'Unknown'}.Count
$Table.Rows.Add($row)
}
$Table|ft
```
Here are the results

[![job data table](/assets/uploads/2016/07/job-data-table.png)](/assets/uploads/2016/07/job-data-table.png)

I also had a look at Get-SQLAgentJobHistory Lets take a look at the help

` Get-help get-SQLAgentJobHistory -showwindow`

> DESCRIPTION
> 
> Returns the JobHistory present in the target instance of SQL Agent.
> 
> This cmdlet supports the following modes of operation to return the JobHistory:
> 
> 1.  By specifying the Path of the SQL Agent instance.
> 2.  By passing the instance of the SQL Agent in the input.
> 3.  By invoking the cmdlet in a valid context.

So I ran

 `Get-SqlAgentJobHistory -ServerInstance sql2014ser12r2`

And got back a whole load of information. Every job history available on the server. Too much to look it immediately to work out what to do

So I looked at just one job

` Get-SqlAgentJobHistory -ServerInstance SQL2014Ser12R2 -JobName 'DatabaseBackup - SYSTEM_DATABASES - FULL - Local G Drive'`

And got back the last months worth of history for that one job as that is the schedule used to purge the job history for this server So then I added -Since Yesterday to only get the last 24 hours history

` Get-SqlAgentJobHistory -ServerInstance SQL2014Ser12R2 -JobName 'DatabaseBackup - SYSTEM_DATABASES - FULL - Local G Drive' -Since Yesterday`

[![agentjobdetail](/assets/uploads/2016/07/agentjobdetail.png)](/assets/uploads/2016/07/agentjobdetail.png)

The Since Parameter is described as

> -Since <SinceType>
> 
> A convenient abbreviation to avoid using the -StartRunDate parameter.  
> It can be specified with the -EndRunDate parameter.
> 
> Do not specify a -StartRunDate parameter, if you want to use it.
> 
> Accepted values are:  
> – Midnight (gets all the job history information generated after midnight)  
> – Yesterday (gets all the job history information generated in the last 24 hours)  
> – LastWeek (gets all the job history information generated in the last week)  
> – LastMonth (gets all the job history information generated in the last month)

When I run

` Get-SqlAgentJobHistory -ServerInstance SQL2014Ser12R2 -JobName 'DatabaseBackup - SYSTEM_DATABASES - FULL - Local G Drive' -Since Yesterday |Measure-Object`

I get

`Count : 3`

And if I run

` Get-SqlAgentJobHistory -ServerInstance SQL2014Ser12R2 -JobName 'DatabaseBackup - SYSTEM_DATABASES - FULL - Local G Drive' -Since Yesterday |select RunDate,StepID,Server,JobName,StepName,Message|Out-GridView`

I get

[![agent job out gridview](/assets/uploads/2016/07/agent-job-out-gridview.png)](/assets/uploads/2016/07/agent-job-out-gridview.png)

Which matches the view I see in SSMS Agent Job History

[![jobhistory](/assets/uploads/2016/07/jobhistory.png)](/assets/uploads/2016/07/jobhistory.png)

So `Get-SqlAgentJobHistory` will enable you to use PowerShell to gather information about the Job history for each step of the Agent Jobs and also the message which I can see being very useful.

Come and join us in the SQL Community Slack to discuss these CMDLets and all things SQL Community [https://sqlps.io/slack](https://sqlps.io/slack)

**CALL TO ACTION**
------------------

Microsoft are engaging with the community to improve the tools we all use in our day to day work. There is are two Trello boards set up for **YOU** to use to contribute

[https://sqlps.io/vote](https://sqlps.io/vote) for SQLPS sqlserver PowerShell module

[https://sqlps.io/ssms](https://sqlps.io/ssms) for SSMS

Go and join them and upvote **YOUR** preferred choice of the next lot of CMDlets

[![trellocount](/assets/uploads/2016/06/trellocount.png)](/assets/uploads/2016/06/trellocount.png)

We have also set up a SQL Community Slack for anyone in the community to discuss all things related to SQL including the Trello board items and already it seems a good place for people to get help with 150+ members in a few days. You can get an invite here [https://sqlps.io/slack](https://sqlps.io/slack)

Come and join us

