---
title: "Instances and Ports with PowerShell"
date: "2015-04-22"
categories: 
  - Blog
  - SQL Server
  - PowerShell
tags: 
  - Instance
  - Ports

---

Just a quick post and a day late for [#SQLNewBlogger](https://twitter.com/hashtag/sqlnewblogger) There are some excellent posts on that hashtag and I recommend that you read them

When you know a server name but not the name of the instances or the ports that they are using this function will be of use
```
<#
.SYNOPSIS
Shows the Instances and the Port Numbers on a SQL Server

.DESCRIPTION
This function will show the Instances and the Port Numbers on a SQL Server using WMI

.PARAMETER Server
The Server Name

.EXAMPLE
Get-SQLInstancesPort Fade2Black

This will display the instances and the port numbers on the server Fade2Black
.NOTES
AUTHOR: Rob Sewell sqldbawithabeard.com
DATE: 22/04/2015
#>

function Get-SQLInstancesPort {

    param ([string]$Server)

    [system.reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")|Out-Null
    [system.reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement")|Out-Null
    $mc = new-object Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer $Server
    $Instances = $mc.ServerInstances

    foreach ($Instance in $Instances) {
        $port = @{Name = "Port"; Expression = {$_.ServerProtocols['Tcp'].IPAddresses['IPAll'].IPAddressProperties['TcpPort'].Value}}
        $Parent = @{Name = "Parent"; Expression = {$_.Parent.Name}}
        $Instance|Select $Parent, Name, $Port
    }
}
```