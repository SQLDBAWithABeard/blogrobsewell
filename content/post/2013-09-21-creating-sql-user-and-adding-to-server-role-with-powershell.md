---
title: "Creating SQL User and adding to Server Role with PowerShell"
categories:
  - Blog

tags:
  - account
  - automate
  - PowerShell
  - roles
  - sql
  - SQL Server
  - box-of-tricks

---
Another post in the [PowerShell Box of Tricks](https://blog.robsewell.com/tags/#box-of-tricks) series.

In yesterdays post [Creating a Windows User and Adding to SQL Role](https://blog.robsewell.com/creating-a-windows-user-and-adding-to-a-sql-server-role-with-powershell/) we created a Windows User, today it’s a SQL User. Again it is nice and simple and allows you to pipe input from other sources enabling you to easily and quickly repeat any process that needs SQL Users.

It is pretty similar as you would expect. We create a Login Object, set the Logintype to  SqlLogin add the Password and create it with the Create Method. It is then added to the Role Specified

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image69.png)](https://blog.robsewell.com/assets/uploads/2013/09/image69.png)

The same error checking is performed as the Windows Login function. If the login already exists on the server it will just add it to the role and if the role has been mistyped it will let you know. It does this by checking if the role object is Null for the Roles and the Contains Method for the Logins

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image99.png)](https://blog.robsewell.com/assets/uploads/2013/09/image99.png)

The function is called as follows.

    Add-SQLAccountToSQLRole FADE2BLACK Test Password01 dbcreator

The code can be found here

    #############################################################    ###########
    #
    # NAME: Add-SQLAccountToSQLRole.ps1
    # AUTHOR: Rob Sewell https://blog.robsewell.com
    # DATE:11/09/2013
    #
    # COMMENTS: Load function to create a sql user and add them     to a server role
    #
    # USAGE: Add-SQLAccountToSQLRole FADE2BLACK Test Password01     dbcreator
    #        Add-SQLAccountToSQLRole FADE2BLACK Test Password01     public
    
    Function Add-SQLAccountToSQLRole ([String]$Server, [String]     $User, [String]$Password, [String]$Role) {
    
        $Svr = New-Object ('Microsoft.SqlServer.Management.Smo.    Server') $server
    
        # Check if Role entered Correctly
        $SVRRole = $svr.Roles[$Role]
        if ($SVRRole -eq $null) {
            Write-Host " $Role is not a valid Role on $Server"
        }
    
        else {
            #Check if User already exists
            if ($svr.Logins.Contains($User)) {
                $SqlUser = New-Object -TypeName Microsoft.    SqlServer.Management.Smo.Login $Server, $User
                $LoginName = $SQLUser.Name
                if ($Role -notcontains "public")     {                   
                    $SVRRole.AddMember($LoginName)
                }
            }
            else {
                $SqlUser = New-Object -TypeName Microsoft.    SqlServer.Management.Smo.Login $Server, $User
                $SqlUser.LoginType = 'SqlLogin'
                $SqlUser.PasswordExpirationEnabled = $false
                $SqlUser.Create($Password)
                $LoginName = $SQLUser.Name
                if ($Role -notcontains "public") {
                    $SVRRole.AddMember($LoginName)
                }
            }
        }
    }

