---
title: "PowerShell, Pester and Ola Hallengrens Maintenance Solution"
date: "2016-09-24"
categories:
  - Blog

tags:
  - automate
  - automation
  - backup
  - backups
  - pester
  - powershell
  - sql
  - Ola Hallengren
header:
  teaser: assets/uploads/2016/09/pester-ola-check.png
---
If you are a SQL DBA you will have heard of [Ola Hallengrens Maintenance solution](https://ola.hallengren.com/) If you haven’t go and click the link and look at the easiest way to ensure that all of your essential database maintenance is performed. You can also [watch a video from Ola at SQL Bits](https://sqlbits.com/Sessions/Event9/Inside_Ola_Hallengrens_Maintenance_Solution)  
Recently I was thinking about how I could validate that this solution was installed in the way that I wanted it to be so I turned to [Pester](https://github.com/pester/Pester) You can find a great [how to get started here](https://mcpmag.com/articles/2016/05/19/test-powershell-modules-with-pester.aspx) which will show you how to get Pester and how to get started with TDD.  
This isn’t TDD though this is Environment Validation and this is how I went about creating my test.  
First I thought about what I would look for in SSMS when I had installed the maintenance solution and made a list of the things that I would check which looked something like this. This would be the checklist you would create (or have already created) for yourself or a junior following this install. This is how easy you can turn that checklist into a Pester Test and remove the human element and open your install for automated testing

*   SQL Server Agent is running – Otherwise the jobs won’t run 🙂
*   We should have 4 backup jobs with a name of
*   DatabaseBackup – SYSTEM_DATABASES – FULL
*   DatabaseBackup – USER_DATABASES – FULL
*   DatabaseBackup – USER_DATABASES – DIFF
*   DatabaseBackup – USER_DATABASES – LOG
*   We should have Integrity Check and Index Optimisation Jobs
*   We should have the clean up jobs
*   All jobs should be scheduled
*   All jobs should be enabled
*   The jobs should have succeeded

I can certainly say that I have run through that check in my head and also written it down in an installation guide in the past. If I was being more careful I would have checked if there were the correct folders in the folder I was backing up to.

Ola’s script uses a default naming convention so this makes it easy. There should be a `SERVERNAME` or `SERVERNAME$INSTANCENAME` folder or if there is an Availability Group a `CLUSTERNAME$AGNAME` and in each of those a FULL DIFF and LOG folder which I can add to my checklist

So now we have our checklist we just need to turn in into a Pester Environmental Validation script

It would be useful to be able to pass in a number of instances so we will start with a foreach loop and then a [Describe Block](https://github.com/pester/Pester/wiki/Describe) then split the server name and instance name, get the agent jobs and set the backup folder name
```
$ServerName = $Server.Split('\')[0]
$InstanceName = $Server.Split('\')[1]
$ServerName = $ServerName.ToUpper()
Describe 'Testing $Server Backup solution'{
BeforeAll {$Jobs = Get-SqlAgentJob -ServerInstance $Server
$srv = New-Object Microsoft.SQLServer.Management.SMO.Server $Server
$dbs = $Srv.Databases.Where{$_.status -eq 'Normal'}.name
if($InstanceName)
{
$DisplayName = 'SQL Server Agent ($InstanceName)'
$Folder = $ServerName + '$' + $InstanceName
}
else
{
$DisplayName = 'SQL Server Agent (MSSQLSERVER)'
$Folder = $ServerName
}
}
if($CheckForBackups -eq $true)
{
$CheckForDBFolders -eq $true
}
$Root = $Share + '\' + $Folder 
```
I also set the Agent service display name so I can get its status. I split the jobs up using a [Context block](https://github.com/pester/Pester/wiki/Context), one each for Backups, Database maintenance and solution clean up but they all follow the same pattern. .First get the jobs
```
$Jobs = $Jobs.Where{($_.Name -like 'DatabaseBackup - SYSTEM_DATABASES - FULL*' + $JobSuffix + '*') -or ($_.Name -like 'DatabaseBackup - USER_DATABASES - FULL*' + $JobSuffix + '*') -or ($_.Name -like 'DatabaseBackup - USER_DATABASES - DIFF*' + $JobSuffix + '*') -or ($_.Name -like 'DatabaseBackup - USER_DATABASES - LOG*' + $JobSuffix + '*')}
```
Then we can iterate through them and check them but first lets test the Agent Service. You do this with an [It Block](https://github.com/pester/Pester/wiki/It) and in it put a single test like this

`actual-value | Should Be expected-value`

So to check the Agent Job is running we can do this
```
(Get-service -ComputerName $ServerName -DisplayName $DisplayName).Status | Should Be 'Running'
```
To find out how to get the right values for any test I check using get member so to see what is available for a job I gathered the Agent Jobs into a variable using the `Get-SQLAgentJob` command in the new sqlserver module (which you can get by installing the [latest SSMS from here](https://msdn.microsoft.com/en-us/library/mt238290.aspx)) and then explored their properties using [Get-Member](https://technet.microsoft.com/en-us/library/hh849928.aspx) and the values using [Select Object](https://technet.microsoft.com/en-us/library/hh849895.aspx)
```
$jobs = Get-SqlAgentJob -ServerInstance $server
($Jobs | Get-Member -MemberType Property).name
$Jobs[0] | Select-Object *
```
then using a foreach to loop through them I can check that the jobs, exists, is enabled, has a schedule and succeeded last time it ran like this
```
$Jobs = $Jobs.Where{($_.Name -eq 'DatabaseIntegrityCheck - SYSTEM_DATABASES') -or ($_.Name -eq 'DatabaseIntegrityCheck - USER_DATABASES') -or ($_.Name -eq 'IndexOptimize - USER_DATABASES')}
foreach($job in $Jobs)
{
$JobName = $Job.Name
It '$JobName Job Exists'{
$Job | Should Not BeNullOrEmpty
}
It '$JobName Job is enabled' {
$job.IsEnabled | Should Be 'True'
}
It '$JobName Job has schedule' {
$Job.HasSchedule | Should Be 'True'
}
if($DontCheckJobOutcome -eq $false)
{
It '$JobName Job succeeded' {
$Job.LastRunOutCome | Should Be 'Succeeded'
}
}
```
So I have checked the agent and the jobs and now I want to check the folders exist. First for the instance using [`Test-Path`](https://technet.microsoft.com/en-us/library/hh849776.aspx) so the user running the PowerShell session must have privileges and access to list the files and folders
```
Context '$Share Share For $Server' {
It 'Should have the root folder $Root' {
Test-Path $Root | Should Be $true
}
```
The for every database we need to set some variables for the Folder path. We don’t back up tempdb so we ignore that and then check if the server is SQL2012 or above and if it is check if the database is a member of an availability group and set the folder name appropriately
```
  foreach($db in $dbs.Where{$_ -ne 'tempdb'})
{

if($Srv.VersionMajor -ge 11)
{
If($srv.Databases[$db].AvailabilityGroupName)
{
$AG = $srv.Databases[$db].AvailabilityGroupName
$Cluster = $srv.ClusterName
$OLAAg = $Cluster + '$' + $AG
if($Share.StartsWith('\\') -eq $False)
{
$UNC = $Share.Replace(':','$')
$Root = '\\' + $ServerName + '\' + $UNC + '\' + $OlaAG
}
else
{
$Root = '\\' + $ServerName + '\' + $UNC + '\' + $Folder
}
}
else
{
if($Share.StartsWith('\\') -eq $False)
{
$UNC = $Share.Replace(':','$')
$Root = '\\' + $ServerName + '\' + $UNC + '\' + $Folder
}
else
{
$Root = $Share + '\' + $Folder
}
}
}
$db = $db.Replace(' ','')
$Dbfolder = $Root + &amp;quot;\$db&amp;quot;
$Full = $Dbfolder + '\FULL'
$Diff = $Dbfolder + '\DIFF'
$Log  = $Dbfolder + '\LOG'
If($CheckForDBFolders -eq $True)
{
Context &amp;quot;Folder Check for $db on $Server on $Share&amp;quot; {
It &amp;quot;Should have a folder for $db database&amp;quot; {
Test-Path $Dbfolder |Should Be $true
} 
```
But we need some logic for checking for folders because Ola is smart and checks for Log Shipping databases so as not to break the LSN chain and system databases only have full folders and simple recovery databases only have full and diff folders. I used the `System.IO.Directory` Exists method as I found it slightly quicker for UNC Shares
```
If($CheckForDBFolders -eq $True)
{
Context 'Folder Check for $db on $Server on $Share' {
It 'Should have a folder for $db database' {
Test-Path $Dbfolder |Should Be $true
}
if($Db -notin ('master','msdb','model') -and ($Srv.Databases[$db].RecoveryModel -ne 'Simple') -and ( $LSDatabases -notcontains $db))
{
It 'Has a Full Folder' {
[System.IO.Directory]::Exists($Full) | Should Be $True
}
It 'Has a Diff Folder' {
[System.IO.Directory]::Exists($Diff) | Should Be $True
}
It 'Has a Log Folder' {
[System.IO.Directory]::Exists($Log) | Should Be $True
}
} #
elseif(($Srv.Databases[$db].RecoveryModel -eq 'Simple') -and $Db -notin ('master','msdb','model') -or ( $LSDatabases -contains $db) )
{
It 'Has a Full Folder' {
[System.IO.Directory]::Exists($Full) | Should Be $True
}
It 'Has a Diff Folder' {
[System.IO.Directory]::Exists($Diff) | Should Be $True
}
} #
else
{
It 'Has a Full Folder' {
[System.IO.Directory]::Exists($Full) | Should Be $True
}
}#
} # End Check for db folders
}
```
and a similar thing for the files in the folders although this caused me some more issues with performance. I first used Get-ChildItem but in folders where a log backup is running every 15 minutes it soon became very slow. So I then decided to compare the create time of the folder with the last write time which was significantly quicker for directories with a number of files but then fell down when there was a single file in the directory so if the times match I revert back to `Get-ChildItem`.

If anyone has a better more performant option I would be interested in knowing. I used Øyvind Kallstad PowerShell Conference session Chasing the seconds [Slides](https://github.com/psconfeu/2016/tree/master/%C3%98yvind%20Kallstad) and [Video](https://www.youtube.com/watch?v=erwAsXZnQ58) and tried the methods in there with [Measure-Command](https://technet.microsoft.com/en-us/library/hh849910.aspx) but this was the best I came up with
```
If($CheckForBackups -eq $true)
{
Context ' File Check For $db on $Server on $Share' {
$Fullcreate = [System.IO.Directory]::GetCreationTime($Full)
$FullWrite = [System.IO.Directory]::GetLastWriteTime($Full)
if($Fullcreate -eq $FullWrite)
{
It 'Has Files in the FULL folder for $db' {
Get-ChildItem $Full*.bak | Should Not BeNullOrEmpty
}
}
else
{
It 'Has Files in the FULL folder for $db' {
$FullCreate | Should BeLessThan $FullWrite
}
}
It 'Full File Folder was written to within the last 7 days' {
$Fullwrite |Should BeGreaterThan (Get-Date).AddDays(-7)
}
if($Db -notin ('master','msdb','model'))
{
$Diffcreate = [System.IO.Directory]::GetCreationTime($Diff)
$DiffWrite = [System.IO.Directory]::GetLastWriteTime($Diff)
if($Diffcreate -eq $DiffWrite)
{
It 'Has Files in the DIFF folder for $db' {
Get-ChildItem $Diff*.bak | Should Not BeNullOrEmpty
}
}
else
{
It 'Has Files in the DIFF folder for $db' {
$DiffCreate | Should BeLessThan $DiffWrite
}
}&amp;amp;amp;amp;lt;/div&amp;amp;amp;amp;gt;&amp;amp;amp;amp;lt;div&amp;amp;amp;amp;gt;It 'Diff File Folder was written to within the last 24 Hours' {
$Diffwrite |Should BeGreaterThan (Get-Date).AddHours(-24)
}
}
if($Db -notin ('master','msdb','model') -and ($Srv.Databases[$db].RecoveryModel -ne 'Simple') -and ( $LSDatabases -notcontains $db))
{
$Logcreate = [System.IO.Directory]::GetCreationTime($Log)
$LogWrite = [System.IO.Directory]::GetLastWriteTime($Log)
if($Logcreate -eq $LogWrite)
{
It 'Has Files in the LOG folder for $db' {
Get-ChildItem $Log*.trn | Should Not BeNullOrEmpty
}
}
else
{
It 'Has Files in the LOG folder for $db' {
$LogCreate | Should BeLessThan $LogWrite
}
}
It 'Log File Folder was written to within the last 30 minutes' {
$Logwrite |Should BeGreaterThan (Get-Date).AddMinutes(-30)
}
}# Simple Recovery
}
}# Check for backups
```
You could just run the script you have just created from your check-list, hopefully this blog post can help you see that you  can do so.

But I like the message showing number of tests and successes and failures at the bottom and I want to use parameters in my script. I can do this like this
```
[CmdletBinding()]
## Pester Test to check OLA
Param(
$Instance,
$CheckForBackups,
$CheckForDBFolders,
$JobSuffix ,
$Share ,
[switch]$NoDatabaseRestoreCheck,
[switch]$DontCheckJobOutcome
)
```
and then call it using [`Invoke-Pester`](https://github.com/pester/Pester/wiki/Invoke-Pester) with the parameters like this
```
$Script = @{
Path = $Path;
Parameters = @{ Instance = Instance;
CheckForBackups = $true;
CheckForDBFolders = $true;
JobSuffix = 'BackupShare1';
Share = '\\Server1\BackupShare1';
NoDatabaseRestoreCheck= $true;
DontCheckJobOutcome = $true}
}
Invoke-Pester -Script $Script
```
but that’s a bit messy, hard to remember and won’t encourage people newer to Powershell to use it so I wrapped it in a function with some help and examples and put it in GitHub `Test-OlaInstance.ps1` and `Test-Ola`. There is one thing to remember. You will need to add the path to `Test-Ola.ps1` on Line 90 of `Test-OlaInstance `so that the script can find it

Once you have that you can call it for a single instance or a number of instances like so. Here I check for Folders and Backup files
```
$Servers =  'SQL2008Ser2008','SQL2012Ser08AG1','SQL2012Ser08AG2','SQL2014Ser12R2'
Test-OLAInstance -Instance $Servers -Share 'H:\' -CheckForBackups
```
and get  a nice result like this. In a little under 20 seconds I completed my checklist for 4 servers including checking if the files and folders exist for 61 databases 🙂 (The three failures were my Integrity Check jobs holding some test corrupt databases)

[![pester ola check.PNG](/assets/uploads/2016/09/pester-ola-check.png)](/assets/uploads/2016/09/pester-ola-check.png)

This gives me a nice and simple automated method of checking if Ola’s maintenance script has been correctly installed. I can use this for one server or many by passing in an array of servers (although they must use the same folder for backing up whether that is UNC or local) I can also add this to an automated build process to ensure that everything has been deployed correctly.

[You can find the two scripts on GitHub here](https://github.com/SQLDBAWithABeard/Functions)

I hope you find it useful
