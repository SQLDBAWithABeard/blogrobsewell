---
title: "Getting SQL Server File Sizes and Space Used with dbatools"
date: "2017-03-29"
categories:
  - Blog

tags:
  - automate
  - automation
  - dbatools
  - files
  - PowerShell

---
I read a great blog post about answering the question [how big is the database using T-SQL on SQL Buffet](https://sqlbuffet.wordpress.com/2017/03/08/how-big-is-the-database-how-to-answer-that-annoying-question/) and wondered how much I could do with the [dbatools module](https://dbatools.io)

The dbatools module (for those that don’t know) is a PowerShell module written by amazing folks in the community designed to make administrating your SQL Server significantly easier using PowerShell. The instructions for installing it are [available here](https://dbatools.io/getting-started/) It comprises of 182 separate commands at present (11 March 2017 Version 0.8.938)

I know that there is a [Get-DBADatabaseFreeSpace Command](https://dbatools.io/functions/get-dbadatabasefreespace/) written by Mike Fal [b](http://mikefal.net) | [t](https://twitter.com/mike_fal) and using [Glenn Berry’s diagnostic queries](http://www.sqlskills.com/blogs/glenn/category/dmv-queries/))

First thing as always is to look at the help

` Get-Help Get-DbaDatabaseFreespace -ShowWindow`

which will show you the help for the command and some examples

Lets look at the details for a single instance

` Get-DbaDatabaseFreespace -sqlserver $server`

This is what it looks like

![02 - singel server.gif](https://blog.robsewell.com/assets/uploads/2017/03/02-singel-server.gif?resize=630%2C220&ssl=1)

and yes it really is that fast, I have not speeded this up. 232 ms to get those details for an instance with 19 databases

![03 - Measure Command.PNG](https://blog.robsewell.com/assets/uploads/2017/03/03-measure-command.png?resize=630%2C310&ssl=1)

What information do you get ? Lets look at the information for a single database, you get an object for each file

Server               : SQL2014SER12R2
Database             : DBA-Admin
FileName             : DBA-Admin_System
FileGroup            : PRIMARY
PhysicalName         : F:\\DBA-Admin_System.MDF
FileType             : ROWS
UsedSpaceMB          : 3
FreeSpaceMB          : 253
FileSizeMB           : 256
PercentUsed          : 1
AutoGrowth           : 0
AutoGrowType         : MB
SpaceUntilMaxSizeMB  : 16777213
AutoGrowthPossibleMB : 0
UnusableSpaceMB      : 16777213

Server               : SQL2014SER12R2
Database             : DBA-Admin
FileName             : DBA-Admin_Log
FileGroup            :
PhysicalName         : G:\\DBA-Admin_Log.LDF
FileType             : LOG
UsedSpaceMB          : 32
FreeSpaceMB          : 224
FileSizeMB           : 256
PercentUsed          : 12
AutoGrowth           : 256
AutoGrowType         : MB
SpaceUntilMaxSizeMB  : 2528
AutoGrowthPossibleMB : 2304
UnusableSpaceMB      : 0

Server               : SQL2014SER12R2
Database             : DBA-Admin
FileName             : DBA-Admin_User
FileGroup            : UserFG
PhysicalName         : F:\\DBA-Admin_User.NDF
FileType             : ROWS
UsedSpaceMB          : 1
FreeSpaceMB          : 255
FileSizeMB           : 256
PercentUsed          : 0
AutoGrowth           : 256
AutoGrowType         : MB
SpaceUntilMaxSizeMB  : 5119
AutoGrowthPossibleMB : 4864
UnusableSpaceMB      : 0

There is a lot of useful information returned for each file. Its better if you use `Out-GridView` as then you can order by columns and filter in the top bar.

![04 - single server ogv.gif](https://blog.robsewell.com/assets/uploads/2017/03/04-single-server-ogv.gif?resize=630%2C317&ssl=1)

As always, PowerShell uses the permissions of the account running the sessions to connect to the SQL Server unless you provide a separate credential for SQL Authentication. If you need to connect with a different windows account you will need to hold Shift down and right click on the PowerShell icon and click run as a different user.

Lets get the information for a single database. The command has dynamic parameters which populate the database names to save you time and keystrokes

![05 dynamic parameters.gif](https://blog.robsewell.com/assets/uploads/2017/03/05-dynamic-parameters.gif?resize=630%2C300&ssl=1)

But you may want to gather information about more than one server. lets take a list of servers and place them into a variable. You can add your servers to this variable in a number of ways, maybe by querying your CMDB or using your registered servers or central management server

`$SQLServers = 'SQL2005Ser2003','SQL2012Ser08AG3','SQL2012Ser08AG1','SQL2012Ser08AG2','SQL2014Ser12R2','SQL2016N1','SQL2016N2','SQL2016N3','SQLVnextN1','SQLvNextN2'`

and then

`Get-DbaDatabaseFreespace -SqlInstance $SQLServers | Out-GridView`

![06 - Many servers ogv.PNG](https://blog.robsewell.com/assets/uploads/2017/03/06-many-servers-ogv.png?resize=630%2C340&ssl=1)

As you can see, you get a warning quite correctly, that the information for the asynchronous secondary node of the availability group databases is not available and I did not have all of my servers running so there are a couple of could not connect warnings as well. You can still filter very quickly. dbatools is tested from SQL2000 to SQL vNext as you can see below (although I don’t have a SQL2000 instance)

![07 - filter ogv](https://blog.robsewell.com/assets/uploads/2017/03/07-filter-ogv.png?resize=630%2C417&ssl=1)

Not only on Windows, this command will work against SQL running on Linux as well

![08 - linux.PNG](https://blog.robsewell.com/assets/uploads/2017/03/08-linux.png?resize=630%2C289&ssl=1)

So if we want to know the total size of the files on disk for  the database we need to look at the FileSizeMB property
```
$server = 'SQL2014Ser12R2'
$dbName = 'AdventureWorksDW2014'
Get-DbaDatabaseFreespace -SqlServer $server -database $dbName |
Select Database,FileName,FileSizeMB
```
Of course that’s an easy calculation here

![08a - filesize.PNG](https://blog.robsewell.com/assets/uploads/2017/03/08a-filesize.png?resize=630%2C190&ssl=1)

but if we have numerous files then it may be tougher. we can use the Measure-Object command to sum the properties. We need to do a bit of preparation here and set a couple of calculated properties to make it more readable
```
$server = 'SQL2014Ser12R2'
$dbName = 'AdventureWorksDW2014'
$database = @{Name = 'Database'; Expression = {$dbname}}
$FileSize = @{Name = 'FileSize'; Expression = {$_.Sum}}
Get-DbaDatabaseFreespace -SqlServer $server -database $dbName |
Select Database,FileSizeMB |
Measure-Object FileSizeMB -Sum |
Select $database ,Property, $filesize
```
![09 - filessize](https://blog.robsewell.com/assets/uploads/2017/03/09-filessize.png?resize=630%2C225&ssl=1)

Maybe we want to look at all of the databases on an instance. Again, we have to do a little more work here
```
$server = 'SQL2014Ser12R2'
$srv = Connect-DbaSqlServer $server
$SizeonDisk = @()
$srv.Databases |ForEach-Object {
$dbName = $_.Name
$database = @{Name = 'Database'; Expression = {$dbname}}
$FileSize = @{Name = 'FileSize'; Expression = {$_.Sum}}
$SizeOnDisk += Get-DbaDatabaseFreespace -SqlServer $server -database $dbName | Select Database,FileSizeMB |  Measure-Object FileSizeMb -Sum | Select $database ,Property, $Filesize
}
$SizeOnDisk
```
![10 - size on disk](https://blog.robsewell.com/assets/uploads/2017/03/10-size-on-disk.png?resize=630%2C438&ssl=1)

If we wanted the databases ordered by the size of their files we could do this

`$SizeOnDisk |Sort-Object Filesize -Descending`

![11 - size sorted.PNG](https://blog.robsewell.com/assets/uploads/2017/03/11-size-sorted.png?resize=630%2C345&ssl=1)

As it is PowerShell we have an object and we can use it any way we like. Maybe we want that information in a text file or a csv or an excel file or in an email, PowerShell can do that
```
 ## In a text file
$SizeonDisk | Out-file C:\\temp\\Sizeondisk.txt
Invoke-Item C:\\temp\\Sizeondisk.txt
\## In a CSV
$SizeonDisk | Export-Csv C:\\temp\\Sizeondisk.csv -NoTypeInformation
notepad C:\\temp\\Sizeondisk.csv
\## Email
Send-MailMessage -SmtpServer $smtp -From DBATeam@TheBeard.local -To JuniorDBA-Smurf@TheBeard.Local `
-Subject "Smurf this needs looking At" -Body $SizeonDisk
\## Email as Attachment
Send-MailMessage -SmtpServer $smtp -From DBATeam@TheBeard.local -To JuniorDBA-Smurf@TheBeard.Local `
-Subject "Smurf this needs looking At" -Body "Smurf" -Attachments C:\\temp\\Sizeondisk.csv
```
I had a little play with [Boe Prox PoshCharts](https://github.com/proxb/PoshCharts/tree/Dev) (you have to use the dev branch) to see if I could get some nice charts and unfortunately the bar charts did not come out so well but luckily the donut and pie charts did. (I’m a DBA I love donuts!)
```
$SizeonDisk| Out-PieChart -XField Database -YField FileSize -Title "UsedSpaceMB per Database on $Server" -IncludeLegend -Enable3D
$SizeonDisk| Out-DoughnutChart -XField Database -YField FileSize -Title "UsedSpaceMB per Database on $Server" -IncludeLegend -Enable3D
```
![12 - donuts.PNG](https://blog.robsewell.com/assets/uploads/2017/03/12-donuts.png?resize=630%2C280&ssl=1)

So the point is, whatever you or your process requires you can pretty much bet that PowerShell can enable it for you to automate.

You can make use of all of the properties exposed by the command. If you want to only see the files with less than 20% space free

` Get-DbaDatabaseFreespace -SqlServer $server | Where-Object {$_.PercentUsed -gt 80}`

![13 - percent used.PNG](https://blog.robsewell.com/assets/uploads/2017/03/13-percent-used.png?resize=630%2C208&ssl=1)

you can also use the command to check for file growth settings as well

` Get-DbaDatabaseFreespace -SqlServer $server | Where-Object {$_.AutoGrowType  -ne 'Mb'}`

![14 - autogrowth.PNG](https://blog.robsewell.com/assets/uploads/2017/03/14-autogrowth.png?resize=630%2C196&ssl=1)

Or maybe you want to know the FileSize, Used and Free Space per database
```
 $server = 'SQL2014Ser12R2'
$srv = Connect-DbaSqlServer $server
$SizeonDisk = @()
$srv.Databases |ForEach-Object {
$dbName = $_.Name
$database = @{Name = 'Database'; Expression = {$dbname}}
$MB = @{Name = 'Mbs'; Expression = {$_.Sum}}
$SizeOnDisk += Get-DbaDatabaseFreespace -SqlServer $server -database $dbName | Select Database,FileSizeMB, UsedSpaceMB, FreeSpaceMb |  Measure-Object FileSizeMb , UsedSpaceMB, FreeSpaceMb -Sum  | Select $database ,Property, $Mb
}
$SizeOnDisk
```
![15 totals.PNG](https://blog.robsewell.com/assets/uploads/2017/03/15-totals.png?resize=630%2C504&ssl=1)

Hopefully that has given you a quick insight into another one of the fabulous dbatools commands. Any questions, comment below or head over to the SQL Server Community Slack via [https://sqlps.io/slack](https://sqlps.io/slack)

Happy Automating

NOTE – The major 1.0 release of dbatools due in the summer 2017 may have breaking changes which will stop the above code from working. There are also new commands coming which may replace this command. This blog post was written using dbatools version 0.8.942 You can check your version using

` Get-Module dbatools`

and update it using an Administrator PowerShell session with

` Update-Module dbatools`

You may find that you get no output from Update-Module as you have the latest version. If you have not installed the module from the PowerShell Gallery using

` Install-Module dbatools`

Then you can use

 `Update-dbatools`