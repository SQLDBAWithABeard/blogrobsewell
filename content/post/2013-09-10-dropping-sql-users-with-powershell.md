---
title: "Dropping SQL Users with PowerShell"
date: "2013-09-10" 
categories:
  - Blog

tags:
  - automate
  - automation
  - box-of-tricks
  - Users
  - SQL Server

---
As you may have noticed, I love PowerShell!

I have developed a series of functions over time which save me time and effort whilst still enabling me to provide a good service to my customers. I keep them all in a functions folder and call them whenever. I call it my [PowerShell Box of Tricks](https://blog.robsewell.com/tags/#box-of-tricks)

I am going to write a short post about each one over the next few weeks as I write my presentation on the same subject which I will be presenting to SQL User Groups.

Todays post is not about a question but about a routine task DBAs do. Dropping Logins

Whilst best practice says add users to active directory groups, add the group to roles and give the roles the correct permissions there are many situations where this is not done and DBAs are required to manually remove logins. This can be a time consuming task but one that is essential. There was a time at MyWork when this was achieved via a script that identified which servers had a users login and the task was to connect to each server in SSMS and remove the user from each database and then drop the server login. As you can imagine it was not done diligently. Prior to an audit I was tasked with ensuring that users that had left MyWork did not have logins to any databases. It was this that lead to the [Checking for SQL Logins](https://blog.robsewell.com/checking-for-sql-server-logins-with-powershell/) script and to this one

It starts exactly the same as the Checking for SQL Logins script by grabbing the list of SQL Servers from the text file and creating an array of user names including all the domains as I work in a multi-domain environment

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image51.png)](https://blog.robsewell.com/assets/uploads/2013/09/image51.png)

Then iterate through each database ignoring those that may need special actions due to the application and call the drop method

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image52.png)](https://blog.robsewell.com/assets/uploads/2013/09/image52.png)

Repeat the process for the servers and send or save the report as required. Simple and easy and has undoubtedly saved me many hours compared to the previous way of doing things 🙂

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image53.png)](https://blog.robsewell.com/assets/uploads/2013/09/image53.png)

#### IMPORTANT NOTE

This script will not delete logins if they have granted permissions to other users. I always recommend running the [Checking for SQL Logins](https://blog.robsewell.com/checking-for-sql-server-logins-with-powershell/) script after running this script to ensure all logins have been dropped

This script can be found


    #############################################################################    ################
    #
    # NAME: Drop-SQLUsers.ps1
    # AUTHOR: Rob Sewell https://blog.robsewell.com
    # DATE:06/08/2013
    #
    # COMMENTS: Load function to Display a list of server, database and login     for SQL servers listed 
    # in sqlservers.txt file and then drop the users
    #
    # I always recommend running the Checking for SQL Logins script after     running this script to ensure all logins have been dropped
    #
    # Does NOT drop Users who have granted permissions
    #BE CAREFUL
    
    Function Drop-SQLUsers ($Usr) {
        [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.    SMO') | out-null
    
        # Suppress Error messages - They will be displayed at the end
        $ErrorActionPreference = "SilentlyContinue"
        # cls
    
        # Pull a list of servers from a local text file
    
        $servers = Get-Content 'c:\temp\sqlservers.txt'
    
        # Create an array for the username and each domain slash username
    
        $logins = @("DOMAIN1\$usr", "DOMAIN2\$usr", "DOMAIN3\$usr" , "$usr")
    
    				Write-Output "#################################"
        Write-Output "Dropping Logins for $Logins" 
    
    
        #loop through each server and each database and 
        Write-Output "#########################################"
        Write-Output "`n Database Logins`n"  
        foreach ($server in $servers) {      
            if (Test-Connection $Server -Count 1 -Quiet) {	
                $srv = New-Object ('Microsoft.SqlServer.Management.Smo.Server')     $server
                #drop database users
                foreach ($database in $srv.Databases) {
                    if ($database -notlike "*dontwant*") {
                        foreach ($login in $logins) {
                            if ($database.Users.Contains($login)) {
                                $database.Users[$login].Drop();
                                Write-Output " $server , $database , $login  -     Database Login has been dropped" 
                            }
                        }
                    }
                }
            }
        }
        
        Write-Output "`n#########################################"
        Write-Output "`n Servers Logins`n" 
          
        foreach ($server in $servers) {      	
            if (Test-Connection $Server -Count 1 -Quiet) {
                $srv = New-Object ('Microsoft.SqlServer.Management.Smo.Server')     $server
                #drop server logins
                foreach ($login in $logins) {
                    if ($srv.Logins.Contains($login)) { 
                        $srv.Logins[$login].Drop(); 
                        Write-Output " $server , $login Login has been dropped" 
                    }
                }
            }
        }
        Write-Output "`n#########################################"
        Write-Output "Dropping Database and Server Logins for $usr - Completed     "  
        Write-Output "If there are no logins displayed above then no logins were     found or dropped!"    
        Write-Output "###########################################" 
    }

