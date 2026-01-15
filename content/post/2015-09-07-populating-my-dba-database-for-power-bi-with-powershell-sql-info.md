---
title: "Populating My DBA Database for Power Bi with PowerShell - SQL Info"
date: "2015-09-07"

categories:
  - Power Bi
  - PowerShell
  - SQL Server
tags:
  - automate
  - automation
  - DBA Database
  - documentation
  - Power Bi
  - PowerShell
  - SMO
  - snippet
  - SQL
  - SQL DBA
  - SQL Server
---

Following my post about [using Power Bi with my DBA Database](http://wp.me/p3aio8-gj) I have been asked if I would share the PowerShell scripts which I use to populate my database.

In this post I will show how to create the following report

[![1](https://sqldbawithabeard.com/wp-content/uploads/2015/09/1.png?w=300)](https://sqldbawithabeard.com/wp-content/uploads/2015/09/1.png)

[![2](https://sqldbawithabeard.com/wp-content/uploads/2015/09/2.png?w=300)](https://sqldbawithabeard.com/wp-content/uploads/2015/09/2.png)

Although you will find so many items of data that I expect that you will want to create different reports for your own requirements. You will also want to put the report onto PowerBi.com and explore the natural language querying as I show at the end of this post

[You will find the latest version of my DBADatabase creation scripts and PowerShell scripts here.](http://1drv.ms/1N4fqxt)

The SQLInfo table is created using this code
```
CREATE TABLE [Info].[SQLInfo](
	[SQLInfoID] [int] IDENTITY(1,1) NOT NULL,
	[DateChecked] [datetime] NULL,
	[DateAdded] [datetime] NULL,
	[ServerName] [nvarchar](50) NULL,
	[InstanceName] [nvarchar](50) NULL,
	[SQLVersionString] [nvarchar](100) NULL,
	[SQLVersion] [nvarchar](100) NULL,
	[ServicePack] [nvarchar](3) NULL,
	[Edition] [nvarchar](50) NULL,
	[ServerType] [nvarchar](30) NULL,
	[Collation] [nvarchar](30) NULL,
	[IsHADREnabled] [bit] NULL,
	[SQLServiceAccount] [nvarchar](35) NULL,
	[SQLService] [nvarchar](30) NULL,
	[SQLServiceStartMode] [nvarchar](30) NULL,
	[BAckupDirectory] [nvarchar](256) NULL,
	[BrowserAccount] [nvarchar](50) NULL,
	[BrowserStartMode] [nvarchar](25) NULL,
	[IsSQLClustered] [bit] NULL,
	[ClusterName] [nvarchar](25) NULL,
	[ClusterQuorumstate] [nvarchar](20) NULL,
	[ClusterQuorumType] [nvarchar](30) NULL,
	[C2AuditMode] [nvarchar](30) NULL,
	[CostThresholdForParallelism] [tinyint] NULL,
	[MaxDegreeOfParallelism] [tinyint] NULL,
	[DBMailEnabled] [bit] NULL,
	[DefaultBackupCComp] [bit] NULL,
	[FillFactor] [tinyint] NULL,
	[MaxMem] [int] NULL,
	[MinMem] [int] NULL,
	[RemoteDacEnabled] [bit] NULL,
	[XPCmdShellEnabled] [bit] NULL,
	[CommonCriteriaComplianceEnabled] [bit] NULL,
	[DefaultFile] [nvarchar](100) NULL,
	[DefaultLog] [nvarchar](100) NULL,
	[HADREndpointPort] [int] NULL,
	[ErrorLogPath] [nvarchar](100) NULL,
	[InstallDataDirectory] [nvarchar](100) NULL,
	[InstallSharedDirectory] [nvarchar](100) NULL,
	[IsCaseSensitive] [bit] NULL,
	[IsFullTextInstalled] [bit] NULL,
	[LinkedServer] [nvarchar](max) NULL,
	[LoginMode] [nvarchar](20) NULL,
	[MasterDBLogPath] [nvarchar](100) NULL,
	[MasterDBPath] [nvarchar](100) NULL,
	[NamedPipesEnabled] [bit] NULL,
	[OptimizeAdhocWorkloads] [bit] NULL,
	[InstanceID] [int] NULL,
	[AGListener] [nvarchar](150) NULL,
	[AGs] [nvarchar](150) NULL,
 CONSTRAINT [PK__SQL__50A5926BC7005F29] PRIMARY KEY CLUSTERED
(
	[SQLInfoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [Info].[SQLInfo]  WITH CHECK ADD  CONSTRAINT [FK_SQLInfo_InstanceList] FOREIGN KEY([InstanceID])
REFERENCES [dbo].[InstanceList] ([InstanceID])
GO

ALTER TABLE [Info].[SQLInfo] CHECK CONSTRAINT [FK_SQLInfo_InstanceList]
GO
```
The PowerShell script uses Jason Wasser @wasserja Write-Log function to write to a text file but I also enable some logging into a new event log by following the steps here [http://blogs.technet.com/b/heyscriptingguy/archive/2013/02/01/use-PowerShell-to-create-and-to-use-a-new-event-log.aspx](http://blogs.technet.com/b/heyscriptingguy/archive/2013/02/01/use-PowerShell-to-create-and-to-use-a-new-event-log.aspx?WT.mc_id=DP-MVP-5002693) to create a log named SQLAutoScript with a source SQLAUTOSCRIPT

To run the script I simply need to add the values for
```
$CentralDBAServer = '' ## Add the address of the instance that holds the DBADatabase
$CentralDatabaseName = 'DBADatabase'
$LogFile = "\DBADatabaseServerUpdate_" + $Date + ".log" ## Set Path to Log File
```
And the script will do the rest. Call the script from a PowerShell Job Step and schedule it to run at the frequency you wish, I gather the information every week. You can get [the script from here](http://1drv.ms/1N4fqxt) or you can read on to see how it works and how to create the report and publish it to powerbi.com

I create a function called Catch-Block to save keystrokes and put my commands inside a try catch to make the scripts as robust as possible.
```
function Catch-Block
{
param ([string]$Additional)
$ErrorMessage = " On $Connection " + $Additional + $_.Exception.Message + $_.Exception.InnerException.InnerException.message
$Message = " This message came from the Automated PowerShell script updating the DBA Database with Server Information"
$Msg = $Additional + $ErrorMessage + " " + $Message
Write-Log -Path $LogFile -Message $ErrorMessage -Level Error
Write-EventLog -LogName SQLAutoScript -Source "SQLAUTOSCRIPT" -EventId 1 -EntryType Error -Message $Msg
}
```
I give the function an additional parameter which will hold each custom error message which I write to both the event log and a text message to enable easy troubleshooting and include the message from the $Error variable by accessing it with $_. I won't include the try catch in the examples below. I gather all of the server names from the InstanceList table and set the results to an array variable called $ServerNames holding the server name, instance name and port
```
 $Query = @"
 SELECT [ServerName]
      ,[InstanceName]
      ,[Port]
  FROM [DBADatabase].[dbo].[InstanceList]
  Where Inactive = 0
    AND NotContactable = 0
"@
try{
$AlltheServers= Invoke-Sqlcmd -ServerInstance $CentralDBAServer -Database $CentralDatabaseName -Query $query
$ServerNames = $AlltheServers| Select ServerName,InstanceName,Port
}
```
I then loop through the array and create a `$Connection` variable for my SMO connection string and connect to the server
```
foreach ($ServerName in $ServerNames)
{
## $ServerName
 $InstanceName =  $ServerName|Select InstanceName -ExpandProperty InstanceName
 $Port = $ServerName| Select Port -ExpandProperty Port
$ServerName = $ServerName|Select ServerName -ExpandProperty ServerName
 $Connection = $ServerName + '\' + $InstanceName + ',' + $Port

 try
 {
 $srv = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $Connection
```
Even though I place the creation of the SMO server object in a try block you still need to an additional check to ensure that you can connect and populate the object as the code above creates an empty SMO Server object with the name property set to the $Connection variable if you can't connect to that server and doesn’t error as you may expect The way I have always validated an SMO Server object is to check the version property. There is no justifiable reason for choosing that property, you could choose any one but that’s the one I have always used. I use an if statement to do this ( [This post about Snippets will show you the best way to learn PowerShell code](http://wp.me/p3aio8-cL)) The reference I use for exiting a loop in the way that you want is [this one](http://ss64.com/ps/break.html) In this case we use a continue to carry on iterating the loop

```
if (!( $srv.version)){
 Catch-Block " Failed to Connect to $Connection"
 continue
 }
```
If you wish to view all of the different properties that you can gather information on in this way you can use this code to take a look. (This is something you should get used to doing when writing new PowerShell scripts)
```
$srv = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $Connection
 $srv | Get-Member
```
As you can see from the screenshot below on my SQL2014 server there are 184 properties. I havent chosen to gather all of them, only the ones that are of interest to me, our team or others who request information from our team such as auditors and project managers etc

[![3](https://sqldbawithabeard.com/wp-content/uploads/2015/09/3.png?w=300)](https://sqldbawithabeard.com/wp-content/uploads/2015/09/3.png)

You can choose to use any or all of these properties as long as you ensure you have the columns in your table with the correct data type and that you have the correct knowledge and logic to stop the script from erroring if/when the property is not available. Here is an example
```
if ($srv.IsHadrEnabled -eq $True)
 {$IsHADREnabled = $True
 $AGs = $srv.AvailabilityGroups|Select Name -ExpandProperty Name|Out-String
 $Expression = @{Name = 'ListenerPort' ; Expression = {$_.Name + ',' + $_.PortNumber }}
 $AGListener =  $srv.AvailabilityGroups.AvailabilityGroupListeners|select $Expression|select ListenerPort -ExpandProperty ListenerPort
 }
 else
 {
 $IsHADREnabled = $false
 $AGs = 'None'
 $AGListener = 'None'
 }
 $BackupDirectory = $srv.BackupDirectory
```
I check if the property `IsHADREnabled` is true and if it is I then gather the information about the Availability Group names and the listener port and if it doesn’t exist I set the values to None.

You will find that not all of the properties that you want are at the root of the Server SMO object. If you want you max and min memory values and you want to know if `remote admin connections` or `xp_cmdshell` are enabled you will need to look at the `$Srv.Configuration` object
```
 $MaxMem = $srv.Configuration.MaxServerMemory.ConfigValue
 $MinMem = $srv.Configuration.MinServerMemory.ConfigValue
 $RemoteDacEnabled = $srv.Configuration.RemoteDacConnectionsEnabled.ConfigValue
 $XPCmdShellEnabled = $srv.Configuration.XPCmdShellEnabled.ConfigValue
```
You can look for the property that you want by using the Get-Member cmdlet as shown above or use MSDN to find it [starting from here](https://msdn.microsoft.com/en-us/library/microsoft.sqlserver.management.smo.server.aspx?WT.mc_id=DP-MVP-5002693) or by GoogleBingDuckDuckGo ing "PowerShell SMO" and the property you wish to find.

The rest of the script follows exactly the same pattern [as the previous post](http://sqldbawithabeard.com/2015/08/31/populating-my-dba-database-for-power-bi-with-PowerShell-server-info/) by checking the SQL Info table for an entry for that instance and updating the table if it exists and inserting if it does not.

There are other uses for gathering this information than just for reporting on it. You can target different versions of SQL for different scripts. You can identify values that are outside what is expected and change them. If xp_cmdshell should not be enabled, write the TSQL to gather the connection string of all of the servers from the DBADatabase where the SQLInfo table has `XPCMDShellenabled = 1` and loop through them exactly as above and change the value of `$srv.Configuration.XPCmdShellEnabled.ConfigValue` to 0 and then `$Srv.Alter()`

It is a very powerful way of dynamically targeting your estate if you are looking after many instances and with great power comes great responsibility.

ALWAYS TEST THESE AND ANY SCRIPTS YOU FIND OR SCRIPTS YOU WRITE BEFORE YOU RUN THEM IN YOUR PRODUCTION ENVIRONMENT

Yeah, I shouted and some people thought it was rude. But its important, it needs to be repeated and drilled in so that it becomes habitual. You can do great damage to your estate with only a few lines of PowerShell and a DBA Database so please be very careful and ensure that you have a suitable test subset of servers that you can use to test

The other thing we can do is report on the data and with Power Bi we can create self service reports and dashboards and also make use of the natural language query at powerbi.com so that when your systems team ask "What are all the servers in X data center?" you can enable them to answer it themselves or when the compliance officer asks how many SQL 2005 instances do we have and which clients do they serve you can give them a dashboard they can query themselves.

This is how I create the two reports you see at the top. I start by connecting to the data source, my DBA Database

[![4](https://sqldbawithabeard.com/wp-content/uploads/2015/09/4.png?w=300)](https://sqldbawithabeard.com/wp-content/uploads/2015/09/4.png)

And I use this query
```
SELECT
	IL.ServerName
	,IL.InstanceName
	  ,IL.Location
	  ,IL.Environment
	  ,IL.Inactive
	  ,IL.NotContactable
	  ,SI.[SQLInfoID]
      ,SI.[DateChecked]
      ,SI.[DateAdded]
      ,SI.[ServerName]
      ,SI.[InstanceName]
      ,SI.[SQLVersionString]
      ,SI.[SQLVersion]
      ,SI.[ServicePack]
      ,SI.[Edition]
      ,SI.[ServerType]
      ,SI.[Collation]
      ,SI.[IsHADREnabled]
      ,SI.[SQLServiceAccount]
      ,SI.[SQLService]
      ,SI.[SQLServiceStartMode]
      ,SI.[BAckupDirectory]
      ,SI.[BrowserAccount]
      ,SI.[BrowserStartMode]
      ,SI.[IsSQLClustered]
      ,SI.[ClusterName]
      ,SI.[ClusterQuorumstate]
      ,SI.[ClusterQuorumType]
      ,SI.[C2AuditMode]
      ,SI.[CostThresholdForParallelism]
      ,SI.[MaxDegreeOfParallelism]
      ,SI.[DBMailEnabled]
      ,SI.[DefaultBackupCComp]
      ,SI.[FillFactor]
      ,SI.[MaxMem]
      ,SI.[MinMem]
      ,SI.[RemoteDacEnabled]
      ,SI.[XPCmdShellEnabled]
      ,SI.[CommonCriteriaComplianceEnabled]
      ,SI.[DefaultFile]
      ,SI.[DefaultLog]
      ,SI.[HADREndpointPort]
      ,SI.[ErrorLogPath]
      ,SI.[InstallDataDirectory]
      ,SI.[InstallSharedDirectory]
      ,SI.[IsCaseSensitive]
      ,SI.[IsFullTextInstalled]
      ,SI.[LinkedServer]
      ,SI.[LoginMode]
      ,SI.[MasterDBLogPath]
      ,SI.[MasterDBPath]
      ,SI.[NamedPipesEnabled]
      ,SI.[OptimizeAdhocWorkloads]
      ,SI.[InstanceID]
      ,SI.[AGListener]
      ,SI.[AGs]
        FROM [DBADatabase].[Info].[SQLInfo] as SI
  JOIN [DBADatabase].[dbo].[InstanceList] as IL
  ON IL.InstanceID =  SI.InstanceID
```
So that I can easily add any and all the data to the reports if I choose or query using them in powerbi.com

First I created 3 measures.
```
 AG = DISTINCTCOUNT(Query1[AGs]) Instances = DISTINCTCOUNT(Query1[InstanceID]) Servers = DISTINCTCOUNT(Query1[ServerName])
```
I click on map

[![5](https://sqldbawithabeard.com/wp-content/uploads/2015/09/5.png?w=300)](https://sqldbawithabeard.com/wp-content/uploads/2015/09/5.png)

And drag the location column to location and the Instances measure to both the Values and Color Saturation

[![6](https://sqldbawithabeard.com/wp-content/uploads/2015/09/6.png?w=300)](https://sqldbawithabeard.com/wp-content/uploads/2015/09/6.png)

I then click on edit and format the title and change the colours for the data

[![7](https://sqldbawithabeard.com/wp-content/uploads/2015/09/7.png?w=300)](https://sqldbawithabeard.com/wp-content/uploads/2015/09/7.png)

Next I created I heat map for Instances by Edition. The picture shows the details

[![8](https://sqldbawithabeard.com/wp-content/uploads/2015/09/8.png?w=300)](https://sqldbawithabeard.com/wp-content/uploads/2015/09/8.png)

And a column chart for Instances by Version

[![9](https://sqldbawithabeard.com/wp-content/uploads/2015/09/9.png?w=300)](https://sqldbawithabeard.com/wp-content/uploads/2015/09/9.png)

I also add a table showing the number of instances in each location and a slicer for environment.

Even though you have added one slicer, you are able to slice the data by clicking on the charts. If I click on Developer Edition I can quickly see which versions and locations they are in

[![10](https://sqldbawithabeard.com/wp-content/uploads/2015/09/10.png?w=300)](https://sqldbawithabeard.com/wp-content/uploads/2015/09/10.png)

This works for the map and the column chart as well. This has all been created using live data as a base with all identifying information altered, Bolton is where I was born and the other locations are chosen at random, all other figures and rollups have also been altered.

[![11](https://sqldbawithabeard.com/wp-content/uploads/2015/09/11.png?w=300)](https://sqldbawithabeard.com/wp-content/uploads/2015/09/11.png)

To create the other report I create two donut charts for Instances by version and by location using steps similar to my previous post and then add some tables for location, edition and xp_cmdshell enabled as well as some cards showing total numbers of Servers, Instances and Availability Groups and a slicer for environment to create a report like this, you can use the donut charts to slice the data as well

[![12](https://sqldbawithabeard.com/wp-content/uploads/2015/09/12.png?w=300)](https://sqldbawithabeard.com/wp-content/uploads/2015/09/12.png)

But there are so many different points of information gathered by this script that you get extra value using the natural language query on powerbi.com.

Click Publish and enter your powerbi.com credentials and then log into powerbi.com in a browser and you will see your report and your dataset. (Note, you can easily filter to find your dashboards, reports and data sets)

[![13](https://sqldbawithabeard.com/wp-content/uploads/2015/09/13.png?w=173)](https://sqldbawithabeard.com/wp-content/uploads/2015/09/13.png)

Click the plus sign to create a new dashboard and click the pin on any of the objects in your report to pin them to the dashboard

[![14](https://sqldbawithabeard.com/wp-content/uploads/2015/09/14.png?w=300)](https://sqldbawithabeard.com/wp-content/uploads/2015/09/14.png)

Then you can view (and share) your dashboard

[![15](https://sqldbawithabeard.com/wp-content/uploads/2015/09/15.png?w=300)](https://sqldbawithabeard.com/wp-content/uploads/2015/09/15.png)

Once you have done this you can query your data using natural language. It will cope with spelling mistakes and expects the column names so you may want to think about renaming them in your report by right clicking on them after you get your data.

You can ask it questions and build up information on the fly and alter it as you need it. As a DBA doing this and imagining enabling others to be able to ask these questions whenever they want from a browser and as many times as they like, it was very cool!

[![16](https://sqldbawithabeard.com/wp-content/uploads/2015/09/16.png?w=300)](https://sqldbawithabeard.com/wp-content/uploads/2015/09/16.png)

[![17](https://sqldbawithabeard.com/wp-content/uploads/2015/09/17.png?w=300)](https://sqldbawithabeard.com/wp-content/uploads/2015/09/17.png)

[![18](https://sqldbawithabeard.com/wp-content/uploads/2015/09/18.png?w=300)](https://sqldbawithabeard.com/wp-content/uploads/2015/09/18.png)

[![19](https://sqldbawithabeard.com/wp-content/uploads/2015/09/19.png?w=300)](https://sqldbawithabeard.com/wp-content/uploads/2015/09/19.png)

[![20](https://sqldbawithabeard.com/wp-content/uploads/2015/09/20.png?w=300)](https://sqldbawithabeard.com/wp-content/uploads/2015/09/20.png)

Pretty cool, I think you and any of your 'requestors' would agree

[You can get all of the scripts here](http://1drv.ms/1N4fqxt)

I have written further posts about this

[**Using Power Bi with my DBA Database**](https://blog.robsewell.com/sql%20server/using-power-bi-with-my-dba-database/ )

[**Populating My DBA Database for Power Bi with PowerShell – Server Info**](https://blog.robsewell.com/power%20bi/powershell/sql%20server/populating-my-dba-database-for-power-bi-with-powershell-server-info/ )

[**Populating My DBA Database for Power Bi with PowerShell – SQL Info**](https://blog.robsewell.com/power%20bi/powershell/sql%20server/populating-my-dba-database-for-power-bi-with-powershell-sql-info/ )

[**Populating My DBA Database for Power Bi with PowerShell – Databases**](https://blog.robsewell.com/power%20bi/powershell/sql%20server/populating-my-dba-database-for-power-bi-with-powershell-databases/ )

[**Power Bi, PowerShell and SQL Agent Jobs**](https://blog.robsewell.com/power%20bi/powershell/sql%20server/power-bi-powershell-and-sql-agent-jobs/ )
