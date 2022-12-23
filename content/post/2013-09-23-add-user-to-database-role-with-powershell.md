---
title: "Add User to SQL Server Database Role with PowerShell and Quickly Creating Test Users"
categories:
  - Blog
  - dbatools
  - PowerShell
  - SQL Server

tags:
  - automate
  - automation
  - PowerShell
  - roles
  - Users
  - SQL Server
  - box-of-tricks
  - dbatools

---
There is a newer [up to date version of this post here](https://blog.robsewell.com/blog/quickly-creating-test-users-in-sql-server-with-powershell-using-the-sqlserver-module-and-dbatools/) using the [dbatools module](https://dbatools.io) and the sqlserver module

But if you want to continue with this way read on!!

Having created [Windows Users](https://blog.robsewell.com/creating-a-windows-user-and-adding-to-a-sql-server-role-with-powershell/) or [SQL Users](https://blog.robsewell.com/creating-sql-user-and-adding-to-server-role-with-powershell/) using the last two days posts, today we shall add them to a role on a database.

As I discussed [previously](https://blog.robsewell.com/checking-sql-server-user-role-membership-with-powershell/) I believe that to follow good practice I try to ensure that database permissions are granted by role membership and each role is created with the minimum amount of permissions required for successful execution of the task involved.

So with each database having the correct roles created and the users created we just need to add the user to the database and to the role. This is easily done with PowerShell.

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image70.png)](https://blog.robsewell.com/assets/uploads/2013/09/image70.png)

The `Add-UserToRole` function takes four parameters Server,Database,User and Role and does a series of error checks.

With these functions you can easily create a number of Users and add them to database roles quickly and easily and repeatedly.

If the test team come to you and require 10 Test Users and 3 Test Administrators adding to the test database. I create 2 notepad files

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image71.png)](https://blog.robsewell.com/assets/uploads/2013/09/image71.png)  [![image](https://blog.robsewell.com/assets/uploads/2013/09/image72.png)](https://blog.robsewell.com/assets/uploads/2013/09/image72.png)

and use them with the `Add-SQLAccountToSQLRole` and `Add-UserToRole` functions to create the users

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image73.png)](https://blog.robsewell.com/assets/uploads/2013/09/image73.png)

Here are the results in PowerShell

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image74.png)](https://blog.robsewell.com/assets/uploads/2013/09/image74.png)

and in SSMS

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image75.png)](https://blog.robsewell.com/assets/uploads/2013/09/image75.png)

The Code is here


    #############################################################    ################################
    #
    # NAME: Add-UserToRole.ps1
    # AUTHOR: Rob Sewell https://blog.robsewell.com
    # DATE:11/09/2013
    #
    # COMMENTS: Load function to add user or group to a role on     a database
    #
    # USAGE: Add-UserToRole fade2black Aerosmith Test db_owner
    #        
    
    Function Add-UserToRole ([string] $server, [String]     $Database , [string]$User, [string]$Role)
    {
    $Svr = New-Object ('Microsoft.SqlServer.Management.Smo.    Server') $server
    #Check Database Name entered correctly
    $db = $svr.Databases[$Database]
        if($db -eq $null)
            {
            Write-Output " $Database is not a valid database on     $Server"
            Write-Output " Databases on $Server are :"
            $svr.Databases|select name
            break
            }
    #Check Role exists on Database
            $Rol = $db.Roles[$Role]
        if($Rol -eq $null)
            {
            Write-Output " $Role is not a valid Role on     $Database on $Server  "
            Write-Output " Roles on $Database are:"
            $db.roles|select name
            break
            }
        if(!($svr.Logins.Contains($User)))
            {
            Write-Output "$User not a login on $server create it     first"
            break
            }
        if (!($db.Users.Contains($User)))
            {
            # Add user to database
    
            $usr = New-Object ('Microsoft.SqlServer.Management.    Smo.User') ($db, $User)
            $usr.Login = $User
            $usr.Create()
    
            #Add User to the Role
            $Rol = $db.Roles[$Role]
            $Rol.AddMember($User)
            Write-Output "$User was not a login on $Database on     $server"
            Write-Output "$User added to $Database on $Server     and $Role Role"
            }
            else
            {
             #Add User to the Role
            $Rol = $db.Roles[$Role]
            $Rol.AddMember($User)
            Write-Output "$User added to $Role Role in $Database     on $Server "
            }
    }
