---
title: "Using Get-SQLDiagFix to get information from the SQL Server Diagnostic API with PowerShell"
date: "2017-07-04"
categories:
  - Blog

tags:
  - dbatools
  - PowerShell

---
The SQL Server Diagnostics Preview was [announced just over a week ago](https://blogs.msdn.microsoft.com/sql_server_team/sql-server-diagnostics-preview/) It includes an add-on for SQL Server Management Studio to enable you to analyse SQL Server memory dumps and view information on the latest SQL Server cumulative updates for supported versions of SQL Server. [Arun Sirpal](https://twitter.com/blobeater1) has written a [good blog post showing how to install it and use it in SSMS to analyse dumps](https://blobeater.blog/2017/06/27/using-sql-server-diagnostics-preview/).

There is also a [developer API available](https://ecsapi.portal.azure-api.net/) so I thought I would write some PowerShell to consume it as there are no PowerShell code examples available in the documentation!

In a [previous post](https://blog.robsewell.com/creating-a-powershell-module-and-tdd-for-get-sqldiagrecommendations/) I have explained how I created the module and [a GitHub repository](https://github.com/SQLDBAWithABeard/SQLDiagAPI) and used Pester to help me to [develop the first command Get-SQLDIagRecommendations](https://blog.robsewell.com/powershell-module-for-the-sql-server-diagnostics-api-1st-command-get-sqldiagrecommendations/). At present the module has 5 commands, all for accessing the Recommendations API.

This post is about the command Get-SQLDiagFix which returns the Product Name, Feature Name/Area, KB Number, Title and URL for the Fixes in the Cumulative Updates returned from the SQL Server Diagnostics Recommendations API.

PowerShell Gallery
------------------

The module is [available on the PowerShell Gallery](https://www.powershellgallery.com/packages/SQLDiagAPI/) which means that you can install it using

Install-Module SQLDiagAPI

as long as you have the latest version of the PowerShellGet module. This is already installed in Windows 10 and with WMF 5 but you can install it on the following systems

*   Windows 8.1 Pro
*   Windows 8.1 Enterprise
*   Windows 7 SP1
*   Windows Server 2016 TP5
*   Windows Server 2012 R2
*   Windows Server 2008 R2 SP1

[following the instructions here.](https://msdn.microsoft.com/en-us/powershell/gallery/readme)

If you are not running your PowerShell using a local administrator account you will need to run

`Install-Module SQLDiagAPI -Scope CurrentUser`

to install the module.

If you can’t use the PowerShell Gallery you can install it [using the instructions on the repository](https://github.com/SQLDBAWithABeard/SQLDiagAPI/blob/master/install.md)

API Key
-------

To use the API you need an API Key. An API Key is a secret token that identifies the application to the API and is used to control access. You can [follow the instructions here](https://ecsapi.portal.azure-api.net/) to get one for the SQL Server Diagnostics API.

![01 - APIKey](https://blog.robsewell.com/assets/uploads/2017/06/01-apikey.png?resize=630%2C157&ssl=1)

You will need to store the key to use it. I recommend saving the API Key using the [Export-CliXML](https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.utility/export-clixml) command as described by Jaap Brasser [here .](http://www.jaapbrasser.com/tag/export-clixml/)

`Get-Credential | Export-CliXml -Path "${env:\userprofile}\SQLDiag.Cred"`

You need to enter a username even though it is not used and then enter the API Key as the password. It is saved in the root of the user profile folder as hopefully, user accounts will have access there in most shops.

This will save you from having to enter the APIKey every time you run the commands as the code is looking for it to be saved in that file.

The Commands
------------

Once you have installed the module and the APIKey it will be available whenever you start PowerShell. The first time you install you  may need to run

`Import-Module SQLDiagAPI`

to load it into your session. Once it is loaded you can view the available commands using

`Get-Command -Module SQLDiagAPI`

![01 - SQLDiagAPI Commands.png](https://blog.robsewell.com/assets/uploads/2017/07/01-sqldiagapi-commands.png?resize=630%2C146&ssl=1)

You can find out [more about the commands on the GitHub Repository ](https://github.com/SQLDBAWithABeard/SQLDiagAPI) and the Help files [are in the documentation.](https://github.com/SQLDBAWithABeard/SQLDiagAPI/tree/master/docs)

Get-Help
--------

Always, always when starting with a new module or function in PowerShell you should start with [`Get-Help`](https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.core/get-help). I like to use the -ShowWindow parameter to open the help in a separate window as it has all of the help and a handy search box.

`Get-Help Get-SQLDiagFix`

![02 - Get-Help Get-SQLDiagFix.png](https://blog.robsewell.com/assets/uploads/2017/07/02-get-help-get-sqldiagfix.png?resize=630%2C504&ssl=1)

Good help should always include plenty of examples to show people how to use the command. There are 12 examples in the help for Get-SQLDiagFix. You can view just the examples using

`Get-Help Get-SQLDiagFix -examples`

Get All Of The Fixes
--------------------

The easiest thing to do is to get all of the available fixes from the API. This is done using

`Get-SQLDiagFix`

which will return all 123 Fixes currently referenced in the API.

![03 get-sqldiagfix.png](https://blog.robsewell.com/assets/uploads/2017/07/03-get-sqldiagfix.png?resize=630%2C293&ssl=1)

That is just a lot of information on the screen. If we want to search through that with PowerShell we can use Out-GridView

`Get-SQLDiagFix | Select Product, Feature, KB, Title | Out-GridView`

![05 Get-SQLDiagFix OutGridView Search.gif](https://blog.robsewell.com/assets/uploads/2017/07/05-get-sqldiagfix-outgridview-search.gif?resize=630%2C354&ssl=1)

Or maybe if you want to put them in a database you could use [dbatools](https://dbatools.io)

`$Fixes = Get-SQLDiagFix | Out-DbaDataTable
Write-DbaDataTable -SqlServer $Server -Database $DB -InputObject $Fixes -Table Fixes -AutoCreateTable`

Get Fixes for a Product
-----------------------

If you only want to see the fixes for a particular product you can use the product parameter. To see all of the products available in the API you can run

`Get-SQLDiagProduct`

![06 Get-SQLDiagProduct.png](https://blog.robsewell.com/assets/uploads/2017/07/06-get-sqldiagproduct.png?resize=630%2C210&ssl=1)

You can either specify the product

`Get-SQLDiagFix -Product 'SQL Server 2016 SP1' | Format-Table`

![07 Get-SQLDiagFix Product.png](https://blog.robsewell.com/assets/uploads/2017/07/07-get-sqldiagfix-product.png?resize=630%2C226&ssl=1)

or you can pipe the results of Get-SQLDiagProduct to Get-SQLDiagFix which enables you to search. For example, to search for all fixes for SQL Server 2014 you can do

`Get-SQLDiagProduct 2014 | Get-SQLDiagFix | Format-Table -AutoSize`

![08 - Get-SQLDiagFix Product Search.png](https://blog.robsewell.com/assets/uploads/2017/07/08-get-sqldiagfix-product-search.png?resize=630%2C240&ssl=1)

Which will show the fixes available in the API for SQL Server 2014 SP1 and SQL Server 2014 SP2

Get The Fixes for A Feature
---------------------------

The fixes in the API are also categorised by feature area. You can see all of the feature areas using `Get-SQLDiagFeature`

`Get-SQLDiagFeature`

![09 get-sqldiagfeature.png](https://blog.robsewell.com/assets/uploads/2017/07/09-get-sqldiagfeature.png?resize=630%2C689&ssl=1)

You can see the fixes in a particular feature area using the Feature parameter with

`Get-SQLDiagFix -Feature Spatial | Format-Table -AutoSize`

![10 - Get-SQLDiagFix by feature.png](https://blog.robsewell.com/assets/uploads/2017/07/10-get-sqldiagfix-by-feature.png?resize=630%2C74&ssl=1)

or you can search for a feature with a name like query and show the fixes using

`Get-SQLDiagFix -Feature (Get-SQLDiagFeature query) | Format-Table -AutoSize`

![11 - Get-SQLDiagFix by feature query.png](https://blog.robsewell.com/assets/uploads/2017/07/11-get-sqldiagfix-by-feature-query.png?resize=630%2C157&ssl=1)
------------------------------------------------------------------------------------------------------------------------------------------------------------

Get Fixes for a Product and a Feature
-------------------------------------

You can combine the two approaches above to search for fixes by product and feature area. If you want to see the fixes for SQL Server 2016  to do with backups you can use

`Get-SQLDiagProduct 2016 | Get-SQLDiagFix -Feature (Get-SQLDiagFeature backup) | Format-Table -AutoSize`

![12 - Get-SQLDiagFix by feature adn product.png](https://blog.robsewell.com/assets/uploads/2017/07/12-get-sqldiagfix-by-feature-adn-product.png?resize=630%2C70&ssl=1)

No-one wants to see the words “…restore fails when….”! This is probably a good time to fix that.

Open the KB Article Web-Page
----------------------------

As well as getting the title and KB number of the fix, you can open the web-page. This code will open the fixes for all SP1 products in the feature area like al in Out-GridView and enable you to choose one (or more) and open them in your default browser

`Get-SQLDiagProduct SP1 | Get-SQLDiagFix -Feature (Get-SQLDiagFeature -Feature al) `
| Out-GridView -PassThru | ForEach-Object {Start-Process $_.URL}`

![13 - Open a webpage.gif](https://blog.robsewell.com/assets/uploads/2017/07/13-open-a-webpage.gif?resize=630%2C354&ssl=1)

There is a YouTube video as well showing how to use the command

You can find the GitHub repository at  [https://github.com/SQLDBAWithABeard/SQLDiagAPI](https://github.com/SQLDBAWithABeard/SQLDiagAPI)