---
title: "Some Pester Tests for SQL Defaults"
date: "2016-05-24"
categories:
  - Blog
  - PSConfEU
  - PowerShell
  - GitHub
  - Automation
  
tags:
  - alerts
  - automate
  - databases
  - defaults
  - documentation
  - function
  - github
  - pbm
  - pester
  - report
  - splatting
  - sql

---
When I was at [PowerShell Conference EU](http://www.psconf.eu/) in Hannover last month (The videos are available now – [click here](https://www.youtube.com/c/powershellconferenceeu) and the [slides and code here](https://github.com/psconfeu/2016)) I found out about [Irwin Strachans Active Directory Operations Test](https://pshirwin.wordpress.com/2016/04/08/active-directory-operations-test/) which got me thinking.

I decided to do the same for my usual SQL Set-up. Treating all of your servers to the same defaults makes it even easier to manage at scale remotely.

I am comfortable with using SMO to gather and change properties on SQL Instances so I started by doing this
```
        It 'Should have a default Backup Directory of F:\SQLBACKUP\BACKUPS' {
$Scriptblock = {
[void][reflection.assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo');
$srv = New-Object Microsoft.SqlServer.Management.Smo.Server .
return $srv.BackupDirectory}
$State = Invoke-Command -ComputerName ROB-SURFACEBOOK -ScriptBlock $Scriptblock
$State |Should Be 'F:\SQLBACKUP\BACKUPS'
```
This is the how to find the properties that you want
```
  ## Load the Assemblies
[void][reflection.assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo');
## Create a Server SMO object
$srv = New-Object Microsoft.SqlServer.Management.Smo.Server SERVERNAME

## Explore it
$srv|gm

## If you find an array pick the first one and expand and then explore that  

$srv.Databases[0] | select *
$srv.Databases[0] | gm
```
I quickly found as I added more tests that it was taking a long time to perform the tests (about 5 seconds each test) and that it took an age to fail each of the tests if the server name was incorrect or the server unavailable.

I fixed the first one by testing with a ping before running the tests
```
   ## Check for connectivity
if((Test-Connection $Server -count 1 -Quiet) -eq $false){
Write-Error 'Could not connect to $Server'
$_
continue
}
```
The continue is there because I wanted to loop through an array of servers

I improved the performance using a remote session and a custom object
```
      Describe "$Server" {
BeforeAll {
$Scriptblock = {
[pscustomobject]$Return = @{}
$srv = ''
$SQLAdmins = $Using:SQLAdmins
[void][reflection.assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo');
$srv = New-Object Microsoft.SQLServer.Management.SMO.Server $Server
$Return.DBAAdminDb = $Srv.Databases.Name.Contains('DBA-Admin')
$Logins = $srv.Logins.Where{$_.IsSystemObject -eq $false}.Name
$Return.SQLAdmins = @(Compare-Object $Logins $SQLAdmins -SyncWindow 0).Length - $Logins.count -eq $SQLAdmins.Count
$SysAdmins = $Srv.Roles['sysadmin'].EnumMemberNames()
$Return.SQLAdmin = @(Compare-Object $SysAdmins $SQLAdmins -SyncWindow 0).Length - $SysAdmins.count -eq $SQLAdmins.Count
$Return.BackupDirectory = $srv.BackupDirectory
$Return.DataDirectory = $srv.DefaultFile
```
The BeforeAll script block is run, as it sounds like it should, once before all of the tests, BeforeEach would run once before each of the tests. I define an empty custom object and then create an SMO object and add the properties I am interested in testing to it. I then return the custom object at the end
```
   $Return.Alerts82345Exist = ($srv.JobServer.Alerts |Where {$_.Messageid -eq 823 -or $_.Messageid -eq 824 -or $_.Messageid -eq 825}).Count
$Return.Alerts82345Enabled = ($srv.JobServer.Alerts |Where {$_.Messageid -eq 823 -or $_.Messageid -eq 824 -or $_.Messageid -eq 825 -and $_.IsEnabled -eq $true}).Count
$Return.SysDatabasesFullBackupToday = $srv.Databases.Where{$_.IsSystemObject -eq $true -and $_.Name -ne 'tempdb' -and $_.LastBackupDate -lt (Get-Date).AddDays(-1)}.Count
Return $Return
}
try {
$Return = Invoke-Command -ScriptBlock $Scriptblock -ComputerName $Server -ErrorAction Stop
}
catch {
Write-Error "Unable to Connect to $Server"
$Error
continue

I was then able to test against the property of the custom object

   It 'Should have Alerts for Severity 20 and above' {
$Return.Alerts20SeverityPlusExist | Should Be 6
}
It 'Severity 20 and above Alerts should be enabled' {
$Return.Alerts20SeverityPlusEnabled | Should Be 6
}
It 'Should have alerts for 823,824 and 825' {
$Return.Alerts82345Exist |Should Be 3
}
It 'Alerts for 823,824 and 825 should be enebled' {
$Return.Alerts82345Enabled |Should Be 3
}

Occasionally, for reasons I haven’t explored I had to test against the value property of the returned object

          It "The Full User Database Backup should be scheduled Weekly $OlaUserFullSchedule" {
$Return.OlaUserFullSchedule.value | Should Be $OlaUserFullSchedule
}
```
I wanted to be able to run the tests against environments or groups of servers with different default values so I parameterised the Test Results as well and then the logical step was to turn it into a function and then I could do some parameter splatting. This also gives me the opportunity to show all of the things that I am currently giving parameters to the test for
```
   $Parms = @{
Servers = 'SQLServer1','SQLServer2','SQLServer3';
SQLAdmins = 'THEBEARD\Rob','THEBEARD\SQLDBAsAlsoWithBeards';
BackupDirectory = 'C:\MSSQL\Backup';
DataDirectory = 'C:\MSSQL\Data\';
LogDirectory = 'C:\MSSQL\Logs\';
MaxMemMb = '4096';
Collation = 'Latin1_General_CI_AS';
TempFiles = 4 ;
OlaSysFullFrequency = 'Daily';
OlaSysFullStartTime = '21:00:00';
OlaUserFullSchedule = 'Weekly';
OlaUserFullFrequency = 1 ;## 1 for Sunday
OlaUserFullStartTime = '22:00:00';
OlaUserDiffSchedule = 'Weekly';
OlaUserDiffFrequency = 126; ## 126 for every day except Sunday
OlaUserDiffStartTime = '22:00:00';
OlaUserLogSubDayInterval = 15;
OlaUserLoginterval = 'Minute';
HasSPBlitz = $true;
HasSPBlitzCache = $True;
HasSPBlitzIndex = $True;
HasSPAskBrent = $true;
HASSPBlitzTrace =  $true;
HasSPWhoisActive = $true;
LogWhoIsActiveToTable = $true;
LogSPBlitzToTable = $true;
LogSPBlitzToTableEnabled = $true;
LogSPBlitzToTableScheduled = $true;
LogSPBlitzToTableSchedule = 'Weekly';
LogSPBlitzToTableFrequency = 2 ; # 2 means Monday
LogSPBlitzToTableStartTime  = '03:00:00'}

Test-SQLDefault @Parms
```
I have some other tests which always return what I want, particularly the firewall rules which you will have to modify to suit your own environment

To be able to run this you will need to have the Pester Module. If you are using Windows 10 then it is installed by default, if not

  `Find-Module –Name 'Pester' | Install-Module`

You can find more about Pester [here](https://mcpmag.com/articles/2016/05/11/testing-powershell-scripts-with-pester.aspx?utm_content=buffer5606b&utm_medium=social&utm_source=twitter.com&utm_campaign=buffer) and [here](http://mikefrobbins.com/category/pester/) and also these [videos from the conference](https://www.youtube.com/channel/UCxgrI58XiKnDDByjhRJs5fg/search?query=pester)  
You can find the tests on [GitHub here](https://github.com/SQLDBAWithABeard/Functions/blob/master/Test-SQLDefaults.ps1) and I will continue to add to the defaults that I check.  
This is not a replacement for other SQL configuration tools such as PBM but it is a nice simple way of giving a report on the current status of a SQL installation either at a particular point in time when something is wrong or after an installation prior to passing the server over to another team or into service
