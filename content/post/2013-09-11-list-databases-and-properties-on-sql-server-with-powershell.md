---
title: "List Databases (and Properties) on SQL Server with PowerShell"
date: "2013-09-11" 
categories:
  - Blog

tags:
  - automate
  - databases
  - PowerShell
  - properties
  - box-of-tricks
  - SQL Server

---
Another post in the [PowerShell Box of Tricks](https://blog.robsewell.com/tags/#box-of-tricks) series. Here is another script which I use to save me time and effort during my daily workload enabling me to spend more time on more important (to me) things!

Todays question which I often get asked is What databases are on that server?

This is often a follow up to a question that requires the [Find-Database script](https://blog.robsewell.com/using-powershell-to-find-a-database-amongst-hundreds/). It is often asked by support teams investigating issues. It can also be asked by developers checking the impact of other services on their DEV/UAT environments, by change managers investigating impact of changes, by service managers investigating the impact of downtime, when capacity planning for a new service and numerous other situations.

A simple quick and easy question made simpler with this function which can also be called when creating documentation

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image54.png)](https://blog.robsewell.com/assets/uploads/2013/09/image54.png)
<P>Simply call it with 

    Show-DatabasesOnServer SERVERNAME 
    
and use the results as you need</P>
[![image](https://blog.robsewell.com/assets/uploads/2013/09/image55.png)](https://blog.robsewell.com/assets/uploads/2013/09/image55.png)

This only shows you the name but if you need more information about your databases then have a look and see what you require.

Use \`Get-Member\` to see what is there. I ran the following code to count the number of Properties available for Databases (Using PowerShell V3 on SQL Server 2012 SP1 11.0.3350.0 )

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image56.png)](https://blog.robsewell.com/assets/uploads/2013/09/image56.png)

154 Properties that you can examine and that is just for databases:-)

Picking out a few properties you could do something like this

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image57.png)](https://blog.robsewell.com/assets/uploads/2013/09/image57.png)

If you want aliases for your column headings you will need to add a bit of code to the select.

For Example, maybe you want to Database Name as a heading and the Size in Gb (Its in Mb in the example above) You would need to create a hash table with a Label element and an Expression element. The Label is the column heading and the Expression can just be the data or a calculation on data.

So select Name becomes

    select @{label="Database Name";Expression={$_.Name}}

<P>The Column Heading is Database Name and the data is the Name property</P>
<P>and select Size becomes</P>

    Select @{label="Size GB";Expression={"{0:N3}" -f ($_.Size/1024)}}

<P>The Column Heading is Size GB and the data is the Size property divided by 1024 to 3 decimal places</P>
<P>then your code would look like this</P>

    $srv.databases|select @{label="Server";Expression={$_.Parent.name}},` 
    @{label="Database Name";Expression={$_.Name}}, Owner, Collation, CompatibilityLevel,` 
    RecoveryModel, @{label="Size GB";Expression={"{0:N3}" -f ($_.Size/1024)}}|` 
    Format-Table -Wrap –AutoSize

and the results

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image58.png?resize=630%2C173 "image")](https://blog.robsewell.com/assets/uploads/2013/09/image58.png)

and here is the full code

    <#PSScriptInfo
    
    .VERSION 1.0
    
    .GUID 48bf0316-66c3-4253-9154-6fc5b28e482a
    
    .AUTHOR Rob Sewell
    
    .DESCRIPTION Returns Database Name and Size in MB for databases on a SQL     server
          
    .COMPANYNAME 
    
    .COPYRIGHT 
    
    .TAGS SQL, Database, Databases, Size
    
    .LICENSEURI 
    
    .PROJECTURI 
    
    .ICONURI 
    
    .EXTERNALMODULEDEPENDENCIES 
    
    .REQUIREDSCRIPTS 
    
    .EXTERNALSCRIPTDEPENDENCIES 
    
    .RELEASENOTES
    
    #>
    <#
        .Synopsis
        Returns the databases on a SQL Server and their size
        .DESCRIPTION
        Returns Database Name and Size in MB for databases on a SQL server
        .EXAMPLE
        Show-DatabasesOnServer
    
        This will return the user database names and sizes on the local machine     default instance
        .EXAMPLE
        Show-DatabasesOnServer -Servers SERVER1
    
        This will return the database names and sizes on SERVER1
        .EXAMPLE
        Show-DatabasesOnServer -Servers SERVER1 -IncludeSystemDatabases
    
        This will return all of the database names and sizes on SERVER1     including system databases
        .EXAMPLE
        Show-DatabasesOnServer -Servers 'SERVER1','SERVER2\INSTANCE'
    
        This will return the user database names and sizes on SERVER1 and     SERVER2\INSTANCE
        .EXAMPLE
        $Servers = 'SERVER1','SERVER2','SERVER3'
        Show-DatabasesOnServer -Servers $servers|out-file c:\temp\dbsize.txt
    
        This will get the user database names and sizes on SERVER1, SERVER2 and     SERVER3 and export to a text file c:\temp\dbsize.txt
        .NOTES
        AUTHOR : Rob Sewell https://blog.robsewell.com
        Initial Release 22/07/2013
        Updated with switch for system databases added assembly loading and     error handling 20/12/2015
        Some tidying up and ping check 01/06/2016
        
    #>
    
    Function Show-DatabasesOnServer 
    {
        [CmdletBinding()]
        param (
            # Server Name or array of Server Names - Defaults to     $ENV:COMPUTERNAME
            [Parameter(Mandatory = $false, 
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true, 
                Position = 0)]
            $Servers = $Env:COMPUTERNAME,
            # Switch to include System Databases
            [Parameter(Mandatory = $false)]
            [switch]$IncludeSystemDatabases
        )
        [void][reflection.assembly]::LoadWithPartialName( "Microsoft.SqlServer.    Smo" );
        foreach ($Server in $Servers) {
            if ($Server.Contains('\')) {
                $ServerName = $Server.Split('\')[0]
                $Instance = $Server.Split('\')[1]
            }
            else {
                $Servername = $Server
            } 
    
            ## Check for connectivity
            if ((Test-Connection $ServerName -count 1 -Quiet) -eq $false) {
                Write-Error "Could not connect to $ServerName - Server did not     respond to ping"
                $_.Exception
                continue
            }
        
            $srv = New-Object ('Microsoft.SqlServer.Management.Smo.Server')     $Server
    
            if ($IncludeSystemDatabases) {
                try {
                    $Return = $srv.databases| Select Name, Size
                }
                catch {
                    Write-Error "Failed to get database information from $Server"
                    $_.Exception
                    continue
                }
            }
            else {
                try {
                    $Return = $srv.databases.Where{$_.IsSystemObject -eq $false}    | Select Name, Size
                }
                catch {
                    Write-Error "Failed to get database information from $Server"
                    $_.Exception
                    continue
                }
            }
            Write-Output "`n The Databases on $Server and their Size in MB `n"
            $Return
        }
    }
