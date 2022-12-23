---
title: "Checking for SQL Server logins with PowerShell"
categories:
  - Blog

tags:
  - automate
  - automation
  - logins
  - PowerShell

---
As some of you may know, I love PowerShell!

I use it all the time in my daily job as a SQL DBA and at home whilst learning as well.

Not only do I use PowerShell for automating tasks such as Daily Backup Checks, Drive Space Checks, Service Running Checks, File Space Checks, Failed Agent Job Checks, SQL Error Log Checks, DBCC Checks and more but also for those questions which come up daily and interfere with concentrating on a complex or time consuming task.

I have developed a series of functions over time which save me time and effort whilst still enabling me to provide a good service to my customers. I keep them all in a functions folder and call them whenever I need them. I also have a very simple GUI which I have set up for my colleagues to enable them to easily answer simple questions quickly and easily which I will blog about later. I call it my [PowerShell Box of Tricks](https://blog.robsewell.com/tags/#box-of-tricks)

I am going to write a short post about each one over the next few weeks as I write my presentation on the same subject which I will be presenting to SQL User Groups.

Todays question which I often get asked is Which database does this account have access to?

This question can come from Support Desks when they are investigating a users issue, Developers when they are testing an application as well as audit activities. It is usually followed by what permissions do they have which is covered by my next blog post.

I start by getting the list of servers from my text file and creating an array of logins for each domain as I work in a multi domain environment

[![image](https://i0.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image_thumb10.png?resize=538%2C98 "image")](https://i0.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image10.png)

Then loop through each server and if the login exists write it out to the window.

[![image](https://i0.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image_thumb19.png?resize=567%2C173 "image")](https://i2.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image19.png)

I then repeat this but loop through each database as well

[![image](https://i1.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image_thumb20.png?resize=572%2C155 "image")](https://i0.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image20.png)

A little bit of formatting is added and then a quick easy report that can easily be copied to an email as required.

To call it simply load the function

[![image](https://i2.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image_thumb22.png?resize=357%2C23 "image")](https://i1.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image22.png)

and get the results

[![image](https://i1.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image_thumb21.png?resize=624%2C226 "image")](https://i2.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image21.png)

The code is below

    <#
    .Synopsis
       A workflow to display users server and database logins across a SQL estate
    .DESCRIPTION
        Display a list of server login and database user and login for SQL servers listed 
     in sqlservers.txt file from a range of domains
        AUTHOR: Rob Sewell https://blog.robsewell.com
        LAST UPDATE: DATE:07/01/2015
    .EXAMPLE
       Show-SQLUserLogins DBAwithaBeard
    
       Shows the SQL Server logins and database users matching DOMAIN1\DBAWithaBeard,DOMAIN2\DBAWithaBeard, DBAWithaBeard
    #>
    
    Workflow Show-UserLogins
    {
        
    param ([string]$usr)
    $servers = Get-Content '\sql\Powershell Scripts\sqlservers.txt'
    $ErrorActionPreference = "SilentlyContinue"
    
    # Create an array for the username and each domain slash username
    
    $logins = @("DOMAIN1\$usr","DOMAIN2\$usr", "DOMAIN3\$usr" ,"$usr" )
    
    Write-Output "#################################" 
    Write-Output "SQL Servers, Databases and Logins for `n$logins displayed below " 
    Write-Output "################################# `n" 
    
    #loop through each server and each database and display usernames, servers and databases
    Write-Output " Server Logins`n"
    
    foreach -parallel ($server in $servers)
        {
        inlinescript
            {
            [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
            $srv = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $Using:server
            if(!$srv.Version)
                {
                Write-Output "$Using:server is not contactable - Please Check Manually"
                }
            else
                {              
                foreach ($login in $Using:logins)
                    {      
                    if($srv.Logins.Contains($login))
                        {
                        Write-Output " $Using:server -- $login " 
                        }           
                    else
                        {
                        continue
                        }
                    } 
                }         
            }
        }
    Write-Output "`n###########################"
    Write-Output "`n Database Logins`n"
    foreach -parallel ($server in $servers)
        {
        inlinescript
            {
            $srv = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $Using:server
            if(!$srv.Version)
                {
                Write-Output "$Using:server is not contactable - Please Check Manually"
                }
            else
                {                                                                
                foreach($database in $srv.Databases|Where-Object{$_.IsAccessible -eq $True})
                    {
                    foreach($login in $Using:logins)
                        {
                        if($database.Users.Contains($login))
                            {
                            Write-Output " $Using:server -- $database -- $login " 
                            }
                        else
                            {
                            }   
                        }
                    }
                }
            }
        }    
    Write-Output "`n#########################################"
    Write-Output "Finished - If there are no logins displayed above then no logins were found!"    
    Write-Output "#########################################"  
    }
