---
title: "Getting SQL Server installation date with PowerShell using dbatools"
date: "2019-10-11" 
categories:
  - Blog
  - dbatools
  - PowerShell
  - SQL Server
  
tags:
  - PowerShell
  - SQL Server
  - dbatools
  - dbatoolsMoL
  - Installation

header:
  teaser: /assets/uploads/2019/10/image-7.png

---
Most of my writing time at the moment is devoted to  _[Learn dbatools in a Month of Lunches](https://dbatools.io/book)_ which is now available but here is a short post following a question someone asked me.

How can I get the Installation Date for SQL Server on my estate into a database with dbatools ?
-----------------------------------------------------------------------------------------------

You can get the date that SQL Server was installed using the creation date of the NT Authority\\System login using T-SQL

    SELECT create_date 
    FROM sys.server_principals 
    WHERE sid = 0x010100000000000512000000

![](https://blog.robsewell.com/assets/uploads/2019/10/image.png)

With dbatools
-------------

To do this with dbatools you can use the command [Get-DbaInstanceInstallDate](https://docs.dbatools.io/#Get-DbaInstanceInstallDate) command

    Get-DbaInstanceInstallDate -SqlInstance localhost 

![](https://blog.robsewell.com/assets/uploads/2019/10/image-1.png)

More than one instance
----------------------

If we want to get the installation date for more than one instance we can simply create an array of instances for the SqlInstance parameter

    Get-DbaInstanceInstallDate -SqlInstance localhost, localhost\DAVE

Get the Windows installation date too
-------------------------------------

![](https://blog.robsewell.com/assets/uploads/2019/10/image-2.png)

You can also get the windows installation date with the IncludeWindows switch

    Get-DbaInstanceInstallDate -SqlInstance localhost, localhost\DAVE -IncludeWindows 

![](https://blog.robsewell.com/assets/uploads/2019/10/image-3.png)

Gather your instances
---------------------

How you get the instances in your estate is going to be different per reader but here is an example using Registered Servers from my local registered servers list, you can also use a Central Management Server

    Get-DbaRegisteredServer -Group local 

![](https://blog.robsewell.com/assets/uploads/2019/10/image-4.png)

So we can gather those instances into a variable and pass that to Get-DbaInstanceInstallDate

    $SqlInstances = Get-DbaRegisteredServer -Group local 
    Get-DbaInstanceInstallDate -SqlInstance $SqlInstances 

![](https://blog.robsewell.com/assets/uploads/2019/10/image-5.png)

Add to database
---------------

To add the results of any PowerShell command to a database, you can pipe the results to [Write-DbaDbTableData](https://docs.dbatools.io/#Write-DbaDbTableData)

    $SqlInstances = Get-DbaRegisteredServer -Group local 
    
    $writeDbaDataTableSplat = @{
        SqlInstance = 'localhost'
        Table = 'InstallDate'
        Database = 'tempdb'
        Schema = 'dbo'
        AutoCreateTable = $true
    }
    
    Get-DbaInstanceInstallDate -SqlInstance $SqlInstances | Write-DbaDataTable @writeDbaDataTableSplat

![](https://blog.robsewell.com/assets/uploads/2019/10/image-6.png)

This will create a table called InstallDate and put the results of the Get-DbaInstanceInstallDate command. Note – If you want to try this code, I would advise using a different database than tempdb!!

![](https://blog.robsewell.com/assets/uploads/2019/10/image-7.png)

It is important to note that the table created may not have the most optimal data types and that you may want to pre-create the table.

So there you go, all the installation dates for your estate in a database table. Hope that helps you Jonny.
