---
title: "Making a Change Log Easier With PowerShell"
categories:
  - Blog

tags:
  - automate
  - automation
  - documentation
  - PowerShell
  - sql
  - Change Log

---
Having a Change Log is a good thing. A quick and simple place to find out what has changed on a server and when. This can be invaluable when troubleshooting, matching a change to a symptom especially when assessed alongside your performance counter collection. Here is a simple way to make use of a change log and automate it

Create a simple table

    USE [MDW]
    GO
    
    CREATE TABLE [dbo].[ChangeLog](
     [ChangeID] [int] IDENTITY(1,1) PRIMARY KEY ,
     [Date] [datetime] NOT NULL,
     [Server] [varchar](50) NOT NULL,
     [UserName] [nvarchar](50) NOT NULL,
     [Change] [nvarchar](max) NOT NULL,
    )
    
    GO

You can keep this on a central server or create a database on each server, whichever fits your needs best. You can add other columns if you want your information in a different format

Once you have your table you can create a couple of Powershell functions to easily and quickly add to and retrieve data from the table. I make use of [Invoke-SQLCMD2](https://github.com/RamblingCookieMonster/PowerShell/blob/master/Invoke-Sqlcmd2.ps1) in these functions

This can then be included in any automation tasks that you use to update your environments whether you are using automated deployment methods for releases or using SCCM to patch your environments making it easy to update and also easy to automate by making it part of your usual deployment process.

To add a new change

    <#
    .Synopsis
     A function to add a ChangeLog information
    .DESCRIPTION
     Load function for adding a change to the changelog table in the MDW database on MDWSERVER.
     Use Get-ChangeLog $Server to see details
     Inputs the username of the account running powershell into the database as the user
    REQUIRES Invoke-SQLCMD2
    https://blog.robsewell.com
    .EXAMPLE
     Add-ChangeLog SERVERNAME "Altered AutoGrowth Settings for TempDB to None"
    
     Adds ServerName UserName and Altered AutoGrowth Settings for TempDB to None to the change log table
    #>
    Function Add-ChangeLog
    {
    [CmdletBinding()]
    Param(
     [Parameter(Mandatory=$True)]
     [string]$Server,
    
     [Parameter(Mandatory=$True)]
     [string]$Change
    )
    
    $UserName = $env:USERDOMAIN + '\' + $env:USERNAME
    
    $Query = "INSERT INTO [dbo].[ChangeLog]
     ([Date]
     ,[Server]
     ,[UserName]
     ,[Change])
     VALUES
     (GetDate()
     ,'$Server'
     ,'$UserName'
     ,'$Change')
    "
    Invoke-Sqlcmd2 -ServerInstance MDWSERVER -Database "MDW" -Query $Query -Verbose
    }

You can then run

    Add-ChangeLog SERVERNAME "Added New Database SuperAppData"

to add the change to the change log

To retrieve the data you can use

    <#
    .Synopsis
     A function to get ChangeLog information
    .DESCRIPTION
     Load function for finding ChangeLog information. Information is selected from the MDW Database on SERVERNAME
    REQUIRES Invooke-SQLCMD2
    https://blog.robsewell.com
    .EXAMPLE
     Get-ChangeLog SERVERNAME
    #>
    Function Get-ChangeLog
    {
     [CmdletBinding()]
     [OutputType([int])]
     Param
     (
     # Server Name Required
     [Parameter(Mandatory=$true,]
     $Server
     )
    
    $a = @{Expression={$_.Date};Label="Date";width=15}, `
    @{Expression={$_.Server};Label="Server";width=10},
    @{Expression={$_.UserName};Label="UserName";width=20}, `
    @{Expression={$_.Change};Label="Change";width=18}
    
    Invoke-Sqlcmd2 -ServerInstance MDWSERVER -Database "MDW" -Query "SELECT * FROM dbo.ChangeLog WHERE Server = '$Server';" -Verbose|Format-table $a -Auto -Wrap
    
    }

and use

    Get-ChangeLog SERVERNAME

To find out what changed when. Happy Automating

