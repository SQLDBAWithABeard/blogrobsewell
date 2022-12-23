---
title: "Export SQL User Permissions to T-SQL script using PowerShell and dbatools"
date: "2017-04-10" 
categories:
  - Blog

tags:
  - dbatools
  - permissions
  - PowerShell

---

NOTE - Updated November 2022 for this site and the correct command name.

There are times when DBA’s are required to export database user permissions to a file. This may be for a number of reasons. Maybe for DR purposes, for auditing, for transfer to another database or instance. Sometimes we need to create a new user with the same permissions as another user or perhaps nearly the same permissions. I was having a conversation with my good friend and [MVP Cláudio Silva](https://twitter.com/claudioessilva) and we were talking about how [Export-DbaUser](https://docs.dbatools.io/Export-DbaUser) from [dbatools](https://dbatools.io) could help in these situations and he suggested that I blogged about it so here it is.

The [dbatools module](https://dbatools.io) (for those that don’t know) is a PowerShell module written by amazing folks in the community designed to make administrating your SQL Server significantly easier using PowerShell. The instructions for installing it are [available here](https://dbatools.io/getting-started/) It comprises of 182 separate commands at present

Cláudio wrote [Export-DbaUser](https://docs.dbatools.io/Export-DbaUser) to solve a problem. You should always start with Get-Help whenever you are starting to use a new PowerShell command

`Get-Help Export-DbaUser -ShowWindow`

![01 - get help.PNG](https://blog.robsewell.com/assets/uploads/2017/04/01-get-help.png)

The command exports users creation and its permissions to a T-SQL file or host. Export includes user, create and add to role(s), database level permissions, object level permissions and also the Create Role statements for any roles, although the script does not create IF NOT EXISTS statements which would be an improvement. It also excludes the system databases so if you are scripting users who need access to those databases then that needs to be considered. Cláudio is aware of these and is looking at improving the code to remove those limitations.

It takes the following parameters

*   SqlInstance  
    The SQL Server instance name. SQL Server 2000 and above supported.
*   User  
    Export only the specified database user(s). If not specified will export all users from the database(s)
*   DestinationVersion  
    Which SQL version the script should be generated using. If not specified will use the current database compatibility level
*   FilePath  
    The filepath to write to export the T-SQL.
*   SqlCredential  
    Allows you to login to servers using alternative credentials
*   NoClobber  
    Do not overwrite the file
*   Append  
    Append to the file
*   Databases  
    Not in the help but a dynamic parameter allowing you to specify one or many databases

Lets take a look at it in action

`Export-DbaUser -SqlInstance SQL2016N2 -FilePath C:\temp\SQL2016N2-Users.sql`
`Notepad C:\temp\SQL2016N2-Users.sql`

![02 - Export user server.PNG](https://blog.robsewell.com/assets/uploads/2017/04/02-export-user-server.png)

Lets take a look at a single database

```
Export-DbaUser -SqlInstance SQL2016N2 -FilePath C:\temp\SQL2016N2-Fadetoblack.sql -Databases Fadetoblack  
notepad C:\temp\SQL2016N2-Fadetoblack.sql
```
![03 single database.PNG](https://blog.robsewell.com/assets/uploads/2017/04/03-single-database.png)

This is so cool and so easy. It is possible to do this in T-SQL. I found this script on [SQLServerCentral](http://www.sqlservercentral.com/scripts/Security/71562/) for example which is 262 lines and would then require some mouse action to save to a file

We can look at a single user as well. Lets see what Lars Ulrich can see on the FadeToBlack database

![04 - export lars.PNG](https://blog.robsewell.com/assets/uploads/2017/04/04-export-lars.png)

```
USE [FadetoBlack]
GO
CREATE USER [UlrichLars] FOR LOGIN [UlrichLars] WITH DEFAULT_SCHEMA=[dbo]
GO
GRANT CONNECT TO [UlrichLars]
GO
DENY INSERT ON [dbo].[Finances] TO [UlrichLars]
GO
DENY SELECT ON [dbo].[RealFinances] TO [UlrichLars]
GO
GRANT SELECT ON [dbo].[Finances] TO [UlrichLars]
GO
```

So he can select data from the Finances table but cannot insert and cannot read the RealFinances data. Now lets suppose a new manager comes in and he wants to be able to look at the data in this database. As the manager though he wants to be able to read the RealFinances table  and insert into the Finances table. He requests that we add those permissions to the database. We can create the T-SQL for Lars user and then do a find and replace for `UlrichLars` with `TheManager` , `DENY INSERT ON [dbo].[Finances]` with `GRANT INSERT ON [dbo].[Finances]` and `DENY SELECT ON [dbo].[RealFinances]` with `GRANT SELECT ON [dbo].[RealFinances]` and save to a new file.

```
$LarsPermsFile = 'C:\temp\SQL2016N2-Lars-Fadetoblack.sql'
$ManagerPermsFile = 'C:\temp\SQL2016N2-Manager-Fadetoblack.sql'
Export-DbaUser -SqlInstance SQL2016N2 -FilePath $LarsPermsFile -User UlrichLars -Databases Fadetoblack
$ManagerPerms = Get-Content $LarsPermsFile
## replace permissions
$ManagerPerms = $ManagerPerms.Replace('DENY INSERT ON [dbo].[Finances]','GRANT INSERT ON [dbo].[Finances]')
$ManagerPerms = $ManagerPerms.Replace('DENY SELECT ON [dbo].[RealFinances]','GRANT SELECT ON [dbo].[RealFinances]')
$ManagerPerms = $ManagerPerms.Replace('UlrichLars','TheManager')
Set-Content -path $ManagerPermsFile -Value $ManagerPerms
```
I will open this in Visual Studio Code Insiders using

`code-insiders $LarsPermsFile , $ManagerPermsFile`

if you are not using the insiders preview remove the “-insiders”

![05 - code insiders.PNG](https://blog.robsewell.com/assets/uploads/2017/04/05-code-insiders.png)

You can right click on the Lars file and click select for compare and then right click on the Managers file and select compare with Lars File and get a nice colour coded diff

![06 - compare.gif](https://blog.robsewell.com/assets/uploads/2017/04/06-compare.gif)

Perfect, we can run that code and complete the request. When we impersonate Lars we get

![07 - lars.PNG](https://blog.robsewell.com/assets/uploads/2017/04/07-lars.png)

but when we run as the manager we get

![08 - the manager.PNG](https://blog.robsewell.com/assets/uploads/2017/04/08-the-manager.png)

Excellent! All is well.

It turns out that there is another Fadetoblack database on a SQL2000 instance which for reasons lost in time never had its data imported into the newer database. It is still used for reporting purposes. The manager needs to have the same permissions as on the SQL2016N2 instance. Obviously the T-SQL we have just created will not work as that syntax did not exist for SQL 2000 but Cláudio has thought of that too. We can use the DestinationVersion parameter to create the SQL2000 (2005,2008/20008R2,2012,2014,2016) code

We just run

```
Export-DbaUser -SqlInstance SQL2016N2 -Databases FadetoBlack -User TheManager  -FilePath C:\temp\S
QL2016N2-Manager-2000.sql  -DestinationVersion SQLServer2000
Notepad C:\temp\SQL2016N2-Manager-2000.sql
```

and our SQL2000 compatible code is created

![09- manager 2000.PNG](https://blog.robsewell.com/assets/uploads/2017/04/09-manager-2000.png)

Simply awesome. Thank you Cláudio

Happy Automating

NOTE – The major 1.0 release of dbatools due in the summer 2017 may have breaking changes which will stop the above code from working. There are also new commands coming which may replace this command. This blog post was written using dbatools version 0.8.942 You can check your version using

 `Get-Module dbatools`

and update it using an Administrator PowerShell session with

 `Update-Module dbatools`

You may find that you get no output from Update-Module as you have the latest version. If you have not installed the module from the PowerShell Gallery using

`Install-Module dbatools`

Then you can use

`Update-dbatools`
