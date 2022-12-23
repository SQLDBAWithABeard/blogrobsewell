---
title: "Show AutoGrowth Events with PowerShell to CSV"
date: "2015-02-15"
categories: 
  - PowerShell
  - SQL Server
tags: 
  - Auto Growth
  - automate
  - automation
  - CSV
  - PowerShell
  - SQL Server
---

This week I was reading Pinal Daves post about Autogrowth Events

[http://blog.sqlauthority.com/2015/02/03/sql-server-script-whenwho-did-auto-grow-for-the-database/](http://blog.sqlauthority.com/2015/02/03/sql-server-script-whenwho-did-auto-grow-for-the-database/)

as it happened I had a requirement to make use of the script only a few days later. I was asked to provide the information in a CSV so that the person who required the information could manipulate it in Excel.

I am a great believer in Automation. If you are going to do something more than once then automate it so I wrote two functions, added them to TFS and now they will be available to all of my team members next time they load PowerShell.

Why two functions? Well Pinal Daves script gets the information from the default trace for a single database but there may be times when you need to know the autogrowth events that happened on a server with multiple databases.

I use a very simple method for doing this as I have not found the correct way to parse the default trace with PowerShell. The functions rely on [Invoke-SQLCMD2](https://github.com/RamblingCookieMonster/PowerShell/blob/master/Invoke-Sqlcmd2.ps1) which I also have in my functions folder and pass the query from Pinal Daves Blog post as a here string

`$Results = Invoke-Sqlcmd2 -ServerInstance $Server -Database master -Query $Query`

To output to CSV I use the [Export-CSV cmdlet](https://technet.microsoft.com/en-us/library/hh849932.aspx?WT.mc_id=DP-MVP-5002693)

```
if($CSV)
{
$Results| Export-Csv -Path $CSV
}
```
And to open the CSV I add a `[switch]` parameter. You can find out more about parameters [here](https://technet.microsoft.com/en-us/library/hh847743.aspx?WT.mc_id=DP-MVP-5002693) or by

`Get-Help about_Functions_Advanced_Parameters`

so the parameter block of my function looks like

```
param
(
[Parameter(Mandatory=$true)]
[string]$Server,
[Parameter(Mandatory=$true)]
[string]$Database,
[Parameter(Mandatory=$false)]
[string]$CSV,
[Parameter(Mandatory=$false)]
[switch]$ShowCSV
)
```

Now when I am asked again to provide this information it is as easy as typing

`Show-AutogrowthServer -Server SQL2014Ser12R2` 

or

`Show-AutogrowthDatabase -Server SQL2014Ser12R2 -Database Autogrowth`

and the results will be displayed as below

[![autogrowth](https://sqldbawithabeard.com/wp-content/uploads/2015/02/autogrowth.jpg?w=660)](https://sqldbawithabeard.com/wp-content/uploads/2015/02/autogrowth.jpg)

just a side note. Pinal Daves script uses @@servername in the where clause and if you have renamed your host the script will be blank. The resolution to this is to runt he following T-SQL

``` 
sp_dropserver 'OLDSERVERNAME';
GO
sp_addserver NEWSERVERNAME, local;
GO
```

You can find the scripts here

[Show-AutoGrowthServer](https://gallery.technet.microsoft.com/scriptcenter/Show-Autogrowth-Events-for-8798a8b0?WT.mc_id=DP-MVP-5002693)

[Show-AutoGrowthDatabase](https://gallery.technet.microsoft.com/scriptcenter/Show-Autogrowth-Events-and-f4833cc8?WT.mc_id=DP-MVP-5002693)

[and all of my Script Center Submissions are here](https://gallery.technet.microsoft.com/scriptcenter/site/search?f%5B0%5D.Type=User&f%5B0%5D.Value=Rob%20Sewell?WT.mc_id=DP-MVP-5002693)

As always - The internet lies, fibs and deceives and everything you read including this post  should be taken with a pinch of salt and examined carefully. All code should be understood and tested prior to running in a live environment.
