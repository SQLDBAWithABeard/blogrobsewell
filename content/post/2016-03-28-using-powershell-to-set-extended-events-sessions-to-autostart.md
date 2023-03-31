---
title: "Using PowerShell to set Extended Events Sessions to AutoStart"
date: "2016-03-28"
categories:
  - Blog

tags:
  - powershell
  - smo

---
When you look after more than a few SQL Servers you will need to perform the same actions against a number of  them and that is where PowerShell will be of great benefit. Recently I needed to ensure that all SQL Servers had a certain Extended Event Session set to auto-start and that it was running. I have used the Always On health session in the example below but you could use the same code below and do this for any Extended Event session. Just note that the code below checks for the existence of an Availability Group which may not be what you require.

As always when I started to look at Powershell for a solution [I turned to MSDN and found this page](https://msdn.microsoft.com/en-us/library/ff877887.aspx) and also a quick search [found Mike Fals blogpost](http://www.mikefal.net/2015/06/09/tsql2sday-powershell-and-extended-events/) which showed me how to get going.

I used my [DBA Database as described in my previous posts ](/using-power-bi-with-my-dba-database/)and created a query to check for all of the servers that were active and contactable
```
SELECT

IL.ServerName

FROM [dbo].[InstanceList] IL

WHERE NotContactable = 0

AND Inactive = 0

and used Invoke-SQLCMD to gather the Server Names

$Results = (Invoke-Sqlcmd -ServerInstance $DBADatabaseServer -Database DBADatabase -Query $query -ErrorAction Stop).ServerName
```
Then it was a case of looping through the servers and connecting to the XEvent Store and checking if the required extended event was started and set to auto-start and if not altering those settings
```
## Can we connect to the XEStore?
if(Test-Path SQLSERVER:\XEvent\$Server)
{
$XEStore = get-childitem -path SQLSERVER:\XEvent\$Server -ErrorAction SilentlyContinue  | where {$_.DisplayName -ieq 'default'}
$AutoStart = $XEStore.Sessions[$XEName].AutoStart
$Running = $XEStore.Sessions[$XEName].IsRunning
Write-Output "$server for $AGNames --- $XEName -- $AutoStart -- $Running"
if($AutoStart -eq $false)

{
$XEStore.Sessions[$XEName].AutoStart = $true
$XEStore.Sessions[$XEName].Alter()
}

if($Running -eq $false)
{
$XEStore.Sessions[$XEName].Start()
}
}
```
Very quick and simple and hopefully of use to people, this could easily be turned into a function. The full script is below and also available [here on the Powershell gallery](https://www.powershellgallery.com/packages/Set-ExtendedEventsSessionstoAutoStart/1.0/DisplayScript) or by running  `Save-Script -Name Set-ExtendedEventsSessionstoAutoStart -Path <path>`
```
<#
.Synopsis
   Connects to the servers in the DBA Database and for Servers above 2012 sets alwayson_health Extended Events Sessions to Auto-Start and starts it if it is not running
.DESCRIPTION
   Sets Extended Events Sessions to Auto-Start and starts it if it is not running
.EXAMPLE
   Alter the XEvent name and DBADatabase name or add own server list and run
.NOTES
   AUTHOR - Rob Sewell
   BLOG - 
   DATE - 20/03/2016
#>
$DBADatabaseServer 
$XEName = 'AlwaysOn_health'
## Query to gather the servers required
$Query = @"

SELECT 

IL.ServerName

FROM [dbo].[InstanceList] IL

WHERE NotContactable = 0

AND Inactive = 0

"@

Try 
{
$Results = (Invoke-Sqlcmd -ServerInstance $DBADatabaseServer -Database DBADatabase -Query $query -ErrorAction Stop).ServerName
}

catch 
{
Write-Error "Unable to Connect to the DBADatabase - Please Check"
}

foreach($Server in $Results)

    {
        try
            {
            $srv = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $Server
            }
        catch
            {
            Write-Output " Failed to connect to $Server"
            continue
            }
            # To ensure we have a connection to the server
            if (!( $srv.version)){
            Write-Output " Failed to Connect to $Server"
            continue
            }
        if($srv.versionmajor -ge '11')
            {
            ## NOTE this checks if there are Availability Groups - you may need to change this
            if ($srv.AvailabilityGroups.Name)
                {
                $AGNames = $srv.AvailabilityGroups.Name   
                ## Can we connect to the XEStore?                             
                if(Test-Path SQLSERVER:\XEvent\$Server)
                    {
                    $XEStore = get-childitem -path SQLSERVER:\XEvent\$Server -ErrorAction SilentlyContinue  | where {$_.DisplayName -ieq 'default'} 
                    $AutoStart = $XEStore.Sessions[$XEName].AutoStart
                    $Running = $XEStore.Sessions[$XEName].IsRunning
                    Write-Output "$server for $AGNames --- $XEName -- $AutoStart -- $Running"
                    if($AutoStart -eq $false)
                    
                        {
                        $XEStore.Sessions[$XEName].AutoStart = $true
                        $XEStore.Sessions[$XEName].Alter()
                        }
                    
                      if($Running -eq $false)
                        {
                        $XEStore.Sessions[$XEName].Start()
                        } 
                    }
                else
                    {
                    Write-Output "Failed to connect to XEvent on $Server"
                    }
                }

            else
                {
                ## Write-Output "No AGs on $Server"
                }
            }
        else
            {
            ##  Write-Output "$server not 2012 or above"
            }
}
```
