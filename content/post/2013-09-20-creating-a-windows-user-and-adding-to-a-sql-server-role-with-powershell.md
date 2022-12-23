---
title: "Creating a Windows User and adding to a SQL Server Role with PowerShell"
categories:
  - Blog

tags:
  - automate
  - PowerShell
  - roles
  - box-of-tricks
  - SQL Server

---
<P>Another post in the <A href="https://blog.robsewell.com/tags/#box-of-tricks" rel=noopener target=_blank>PowerShell Box of Tricks</A> series.</P>
<P>In a previous post <A href="https://blog.robsewell.com/checking-sql-server-user-role-membership-with-powershell/" rel=noopener target=_blank>Checking SQL Server User Role Membership</A> we showed how to check which roles users were added to. This function allows you to add Windows Users to Server Roles. A nice simple function which can easily be piped into to allow users to be added form a list in a text file, csv file or even from Active Directory. This makes it easy to recreate Dev and Test environments and can be added to Disaster Recovery processes.</P>
<P>We create a Login Object, set the Logintype and create it with the Create Method. It is then added to the Role specified.</P>

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image67.png)](https://blog.robsewell.com/assets/uploads/2013/09/image67.png)

The function does some simple error checking. If the login already exists on the server it will just add it to the role and if the role has been mistyped it will let you know. It does this by checking if the Role object is Null for the Roles and the Contains Method for the Logins

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image98.png)](https://blog.robsewell.com/assets/uploads/2013/09/image98.png)

<P>The function is called as follows. To just create a login I add the user to the public role</P>

    Add-WindowsAccountToSQLRole FADE2BLACK ‘FADE2BLACK\Test’ public
    
<P>The code can be found here</P>


    ###########################################################
    #
    # NAME: Add-WindowsAccountToSQLRole.ps1
    # AUTHOR: Rob Sewell https://blog.robsewell.com
    # DATE:11/09/2013
    #
    # COMMENTS: Load function to create a windows user and add     them to a server role
    #
    # USAGE: Add-WindowsAccountToSQLRole FADE2BLACK     'FADE2BLACK\Test' dbcreator
    #        Add-WindowsAccountToSQLRole FADE2BLACK     'FADE2BLACK\Test' public
    
    Function Add-WindowsAccountToSQLRole ([String]$Server,     [String] $User, [String]$Role) {
    
        $Svr = New-Object ('Microsoft.SqlServer.Management.Smo.    Server') $server
    
        # Check if Role entered Correctly
        $SVRRole = $svr.Roles[$Role]
        if ($SVRRole -eq $null) {
            Write-Output " $Role is not a valid Role on $Server"
        }
        else {
            #Check if User already exists
            if ($svr.Logins.Contains($User)) {
                $SqlUser = New-Object -TypeName Microsoft.    SqlServer.Management.Smo.Login $Server, $User
                $LoginName = $SQLUser.Name
                if ($Role -notcontains "public") {
                    $svrole = $svr.Roles | where {$_.Name -eq     $Role}
                    $svrole.AddMember("$LoginName")
                }
            }
            else {
                $SqlUser = New-Object -TypeName Microsoft.    SqlServer.Management.Smo.Login $Server, $User
                $SqlUser.LoginType = 'WindowsUser'
                $SqlUser.Create()
                $LoginName = $SQLUser.Name
                if ($Role -notcontains "public") {
                    $svrole = $svr.Roles | where {$_.Name -eq     $Role}
                    $svrole.AddMember("$LoginName")
                }
            }
        }
    }

<P>&nbsp;</P>
<P>Tomorrow we will create and add a SQL Authenticated User</P>

