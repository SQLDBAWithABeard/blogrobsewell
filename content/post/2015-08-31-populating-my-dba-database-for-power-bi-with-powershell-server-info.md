---
title: "Populating My DBA Database for Power Bi with PowerShell - Server Info"
date: "2015-08-31"
categories: 
  - Power Bi
  - PowerShell
  - SQL Server
tags: 
  - automate
  - automation
  - DBA Database
  - Power Bi
  - PowerShell
  - script
  - SMO
  - SQL Server
  - SQL South West
  - User Group
  - Windows Server
---

Following my last post about [using Power Bi with my DBA Database](https://blog.robsewell.com/sql%20server/using-power-bi-with-my-dba-database/) I have been asked if I would share the PowerShell scripts which I use to populate my database. They are the secondary part to my DBADatabase which I also use to automate the installation and upgrade of all of my DBA scripts as I started to blog about in this post [Installing and upgrading default scripts automation - part one - Introduction](https://blog.robsewell.com/powershell/sql%20server/installing-and-upgrading-default-scripts-automation-part-one-introduction/) which is a series I will continue later.

In this post I will show how to create the following report

[![1](https://sqldbawithabeard.com/wp-content/uploads/2015/08/18.png?w=300)](https://sqldbawithabeard.com/wp-content/uploads/2015/08/18.png)

[You will find the latest version of my DBADatabase creation scripts here](http://1drv.ms/1N4fqxt).

I create the following tables

- dbo.ClientDatabaseLookup 
- dbo.Clients 
- dbo.InstanceList
- dbo.InstanceScriptLookup 
- dbo.ScriptList 
- Info.AgentJobDetail 
- Info.AgentJobServer 
- Info.Databases 
- Info.Scriptinstall 
- Info.ServerOSInfo 
- Info.SQLInfo

By adding Server name, Instance Name , Port, Environment, NotContactable, and Location into the InstanceList table I can gather all of the information that I need and also easily add more information to other tables as I need to.

The not contactable column is so that I am able to add instances that I am not able to contact due to permission or environment issues. I can still gather information about them manually and add it to the table. I use the same script and change it to generate the SQL query rather than run it, save the query and then run the query manually to insert the data. This is why I have the DateAdded and Date Checked column so that I know how recent the data is. I don’t go as far as recording the change however as that will be added to a DBA-Admin database on every instance which stores every change to the instance.

The ServerOSInfo table is created like so
```
\*\*\*\*\*\* Object: Table [Info].[ServerOSInfo]    Script Date: 26/08/2015 19:50:38 \*\*\*\*\*\*
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Info].[ServerOSInfo](
[ServerOSInfoID] [int] IDENTITY(1,1) NOT NULL,
[DateAdded] [datetime] NULL,
[DateChecked] [datetime] NULL,
[ServerName] [nvarchar](50) NULL,
[DNSHostName] [nvarchar](50) NULL,
[Domain] [nvarchar](30) NULL,
[OperatingSystem] [nvarchar](100) NULL,
[NoProcessors] [tinyint] NULL,
[IPAddress] [nvarchar](15) NULL,
[RAM] [int] NULL,
CONSTRAINT [PK__ServerOS__50A5926BC7005F29] PRIMARY KEY CLUSTERED
(
[ServerOSInfoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
```
The PowerShell script uses Jason Wasser @wasserja Write-Log function to write to a text file but I also  enable some logging into a new event log by following the steps here [http://blogs.technet.com/b/heyscriptingguy/archive/2013/02/01/use-PowerShell-to-create-and-to-use-a-new-event-log.aspx](http://blogs.technet.com/b/heyscriptingguy/archive/2013/02/01/use-PowerShell-to-create-and-to-use-a-new-event-log.aspx?WT.mc_id=DP-MVP-5002693) to create a log named SQLAutoScript with a source SQLAUTOSCRIPT

To run the script I simply need to add the values for
```
$CentralDBAServer = '' ## Add the address of the instance that holds the DBADatabase
$CentralDatabaseName= 'DBADatabase' 
$LogFile = "\DBADatabaseServerUpdate_" + $Date + ".log" ## Set Path to Log File
```
And the script will do the rest. Call the script from a PowerShell Job Step and schedule it to run at the frequency you wish, I gather the information every week. You can get the [script from here](http://1drv.ms/1N4fqxt) or you can read on to see how it works and how to create the report

I create a function called Catch-Block to save keystrokes and put my commands inside a try catch to make the scripts as robust as possible.
```
function Catch-Block{
param ([string]$Additional)
$ErrorMessage = " On $Connection " + $Additional + $_.Exception.Message + $_.Exception.InnerException.InnerException.message
$Message = " This message came from the Automated PowerShell script updating the
DBA Database with Server Information"
$Msg = $Additional + $ErrorMessage + " " + $Message
Write-Log -Path $LogFile -Message $ErrorMessage -Level Error
Write-EventLog -LogName SQLAutoScript -Source "SQLAUTOSCRIPT" -EventId 1 -EntryType Error -Message $Msg
}
```
I give the function an additional parameter which will hold each custom error message which I write to both the event log and a text message to enable easy troubleshooting and include the message from the `$Error` variable by accessing it with `$_`. I won't include the try catch in the examples below. I gather all of the server names from the InstanceList table and set the results to an array variable called `$Servers`
```
$AlltheServers = Invoke-Sqlcmd -ServerInstance $CentralDBAServer -Database $CentralDatabaseName -Query "SELECT DISTINCT [ServerName] FROM [DBADatabase].[dbo].[InstanceList] WHERE Inactive = 0 OR NotContactable = 1"
$Servers = $AlltheServers| Select ServerName -ExpandProperty ServerName
```
I then loop through the array and gather the information with three WMI queries.
```
Write-Log -Path $LogFile -Message "Gathering Info for $Server "
foreach($Server in $Servers)
{
Write-Log -Path $LogFile -Message "Gathering Info for $Servers"
$DNSHostName = 'NOT GATHERED'
$Domain = 'NOT GATHERED'
$OperatingSystem = 'NOT GATHERED'
$IP = 'NOT GATHERED'
try{
$Info = get-wmiobject win32_computersystem -ComputerName $Server -ErrorAction Stop|select DNSHostName,Domain,
@{Name="RAM";Expression={"{0:n0}" -f($_.TotalPhysicalMemory/1gb)}},NumberOfLogicalProcessors
```
I give the variables some default values in case they are not picked up and set the error action for the command to Stop to exit the try and the first query gathers the DNSHostName, Domain Name, the amount of RAM in GB and the number of logical processors, the second gathers the Operating System version but the third was the most interesting to do. There are many methods of gathering the IP Address using PowerShell and I tried a few of them before finding one that would work with all of the server versions that I had in my estate but the one that worked remotely the best for me and this is a good point to say that this works in my lab and in my shop but may not necessarily work in yours, so understand, check and test this and any other script that you find on the internet before you let them anywhere near your production environment.

Unfortunately the one that worked everywhere remotely errored with the local server so I added a check to see if the server name in the variable matches the global environment variable of Computer Name
```
$OS =  gwmi Win32_OperatingSystem  -ComputerName $Server| select @{name='Name';Expression={($_.caption)}} 
if($Server -eq $env:COMPUTERNAME)
{$IP = (Get-WmiObject -ComputerName $Server -class win32_NetworkAdapterConfiguration -Filter 'ipenabled = "true"' -ErrorAction Stop).ipaddress[0] }
else {$IP = [System.Net.Dns]::GetHostAddresses($Server).IPAddressToString }
Write-Log -Path $LogFile -Message "WMI Info gathered for $Server "
```
Once I have all of the information I check if the server already exists in the ServerOs table and choose to either insert or update.
```
	$Exists = Invoke-Sqlcmd -ServerInstance $CentralDBAServer -Database $CentralDatabaseName -Query "SELECT [ServerName] FROM [DBADatabase].[Info].[ServerOSInfo] WHERE ServerName = '$Server'"
	
	if ($Exists)
	{
	$Query = @"
	UPDATE [Info].[ServerOSInfo]
	   SET [DateChecked] = GetDate()
	      ,[ServerName] = '$Server'
	      ,[DNSHostName] = '$DNSHostName'
	      ,[Domain] = '$Domain'
	      ,[OperatingSystem] = '$OperatingSystem'
	      ,[NoProcessors] = '$NOProcessors'
	      ,[IPAddress] = '$IP'
	      ,[RAM] = '$RAM'
	WHERE ServerName = '$Server'
	"@
	}
	else
	{
	$Query = @"
	INSERT INTO [Info].[ServerOSInfo]
	           ([DateChecked]
	           ,[DateAdded
	           ,[ServerName]
	           ,[DNSHostName]
	           ,[Domain]
	           ,[OperatingSystem]
	           ,[NoProcessors]
	           ,[IPAddress]
	           ,[RAM])
	     VALUES
	   ( GetDate()
	      ,GetDate()
	      ,'$Server'
	      ,'$DNSHostName'
	      ,'$Domain'
	      ,'$OperatingSystem'
	      ,'$NoProcessors'
	      ,'$IP'
	      ,'$RAM')
	"@
	}
	Invoke-Sqlcmd -ServerInstance $CentralDBAServer -Database $CentralDatabaseName -Query $Query
	```

And that’s it. Now if you wish to gather different data about your servers then you can examine the data available to you by
```
get-wmiobject Win32_OperatingSystem -ComputerName $Server | Get-Member
get-wmiobject win32_computersystem -ComputerName $Server | Get-Member
```
If you find something that you want to gather you can then add the property to the script and gather that information as well, make sure that you add the column to the table and to both the insert and update statements in the PowerShell Script

**Creating the report in Power Bi**

All data shown in the examples below has been generated from real-life data but all identifiable data has been altered or removed. I was born in Bolton and [SQL SouthWest](http://sqlsouthwest.co.uk/) is based in Exeter :-)

Open Power Bi Desktop and click get data. Add the connection details for your DBA Database server and database and add the query
```
	SELECT SOI.[ServerOSInfoID]
	      ,SOI.[DateChecked]
	      ,SOI.[ServerName]
	      ,SOI.[DNSHostName]
	      ,SOI.[Domain]
	      ,SOI.[OperatingSystem]
	      ,SOI.[NoProcessors]
	      ,SOI.[IPAddress]
	      ,SOI.[RAM]
	,IL.ServerName
	,IL.InstanceName
		  ,IL.Location
		  ,IL.Environment
		  ,IL.Inactive
		  ,IL.NotContactable
	        FROM [DBADatabase].[Info].[ServerOSInfo] as SOI
	  JOIN [dbo].[InstanceList] as IL
	  ON IL.ServerName =  SOI.[ServerName]
	```

[![2](https://sqldbawithabeard.com/wp-content/uploads/2015/08/21.png?w=300)](https://sqldbawithabeard.com/wp-content/uploads/2015/08/21.png)

Create a new column for the Operating Edition by clicking data on the left and using this code as described [in my previous post](https://blog.robsewell.com/sql%20server/using-power-bi-with-my-dba-database/)
```
Operating System Edition = SWITCH([OperatingSystem], "Microsoft Windows Server 2012 Datacenter", "DataCenter",
"Microsoft Windows Server 2012 Standard","Standard",
"Microsoft Windows Server 2012 R2 Datacenter", "DataCenter",
"Microsoft Windows Server 2008 R2 Standard", "Standard",
"Microsoft Windows Server 2008 R2 Enterprise", "Enterprise",
"Microsoft® Windows Server® 2008 Standard", "Standard",
"Microsoft® Windows Server® 2008 Enterprise","Enterprise",
"Microsoft(R) Windows(R) Server 2003, Standard Edition", "Standard",
"Microsoft(R) Windows(R) Server 2003, Enterprise Edition", "Enterprise",
"Microsoft Windows 2000 Server", "Server 2000",
"Unknown")
```
And one for OS Version using this code
```
OS Version = SWITCH([OperatingSystem], "Microsoft Windows Server 2012 Datacenter", "Server 2012",
"Microsoft Windows Server 2012 Standard","Server 2012",
"Microsoft Windows Server 2012 R2 Datacenter", "Server 2012 R2",
"Microsoft Windows Server 2008 R2 Standard", "Server 2008 R2",
"Microsoft Windows Server 2008 R2", "Server 2008 R2",
"Microsoft Windows Server 2008 R2 Enterprise", "Server 2008 R2",
"Microsoft® Windows Server® 2008 Standard", "Server 2008",
"Microsoft® Windows Server® 2008 Enterprise","Server 2008",
"Microsoft(R) Windows(R) Server 2003, Standard Edition", "Server 2003",
"Microsoft(R) Windows(R) Server 2003, Enterprise Edition", "Server 2003",
"Microsoft Windows 2000 Server", "Server 2000",
"Unknown")
```
I also created a new measure to count the distinct number of servers and instances as follows
```
Servers = DISTINCTCOUNT(Query1[Servers Name])

Instances = COUNT(Query1[Instance])
```
Then in the report area I start by creating a new text box and adding a title to the report and setting the page level filter to InActive is false so that all decommissioned servers are not included

[![3](https://sqldbawithabeard.com/wp-content/uploads/2015/08/31.png?w=300)](https://sqldbawithabeard.com/wp-content/uploads/2015/08/31.png)

I then create a donut chart for the number of servers by Operating System by clicking the donut chart in the visualisations and then dragging the OS version to the Details and the Servers Name to the Values

[![4](https://sqldbawithabeard.com/wp-content/uploads/2015/08/41.png?w=300)](https://sqldbawithabeard.com/wp-content/uploads/2015/08/41.png)

I then click the format button and added a proper title and the background colour

[![5](https://sqldbawithabeard.com/wp-content/uploads/2015/08/51.png?w=90)](https://sqldbawithabeard.com/wp-content/uploads/2015/08/51.png)

Then create the server numbers by location in the same way by clicking donut chart and adding location and count of server names and adding the formatting in the same way as the previous donut

[![6](https://sqldbawithabeard.com/wp-content/uploads/2015/08/61.png?w=300)](https://sqldbawithabeard.com/wp-content/uploads/2015/08/61.png)

I created a number of charts to hold single values for Domain, Instance, Server, RAM, Processors and the number of Not Contactable to provide a quick easy view of those figures, especially when you filter the report by clicking on a value within the donut chart. I find that managers really like this feature. They are all created in the same way by clicking the card in the visualisation and choosing the value

[![7](https://sqldbawithabeard.com/wp-content/uploads/2015/08/71.png?w=300)](https://sqldbawithabeard.com/wp-content/uploads/2015/08/71.png)

I also add a table for the number of servers by operating system and the number of servers by location by dragging those values to a table visualisation. I find that slicers are very useful ways of enabling information to be displayed as required, use the live visualisation to do this, I add the environment column to slice so that I can easily see values for the live environment or the development environment

I create a separate page in the report to display all of the server data as this can be useful for other teams such as the systems (server admin) team. I give them a lot of different slicers : - Domain, Location, Environment, OS Version, Edition and NotContactable with a table holding all of the relevant values to enable them to quickly see details

[![8](https://sqldbawithabeard.com/wp-content/uploads/2015/08/81.png?w=300)](https://sqldbawithabeard.com/wp-content/uploads/2015/08/81.png)

[You can get all of the scripts here](http://1drv.ms/1N4fqxt)

I have written further posts about this

[**Using Power Bi with my DBA Database**](https://blog.robsewell.com/sql%20server/using-power-bi-with-my-dba-database/ )

[**Populating My DBA Database for Power Bi with PowerShell – Server Info**](https://blog.robsewell.com/power%20bi/powershell/sql%20server/populating-my-dba-database-for-power-bi-with-powershell-server-info/ )

[**Populating My DBA Database for Power Bi with PowerShell – SQL Info**](https://blog.robsewell.com/power%20bi/powershell/sql%20server/populating-my-dba-database-for-power-bi-with-powershell-sql-info/ )

[**Populating My DBA Database for Power Bi with PowerShell – Databases**](https://blog.robsewell.com/power%20bi/powershell/sql%20server/populating-my-dba-database-for-power-bi-with-powershell-databases/ )

[**Power Bi, PowerShell and SQL Agent Jobs**](https://blog.robsewell.com/power%20bi/powershell/sql%20server/power-bi-powershell-and-sql-agent-jobs/ )
