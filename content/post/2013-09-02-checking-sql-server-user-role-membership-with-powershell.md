---
title: "Checking SQL Server User Role Membership with PowerShell"
categories:
  - Blog

tags:
  - automate
  - permissions
  - PowerShell
  - roles
  - box-of-tricks

---
<P>As you know, I love PowerShell!</P>
<P>I use it all the time in my daily job as a SQL DBA and at home whilst learning as well.</P>
<P>Not only do I use PowerShell for automating tasks such as Daily Backup Checks, Drive Space Checks, Service Running Checks, File Space Checks, Failed Agent Job Checks, SQL Error Log Checks, DBCC Checks and more but also for those questions which come up daily and interfere with concentrating on a complex or time consuming task.</P>
<P>I have developed a series of functions over time which save me time and effort whilst still enabling me to provide a good service to my customers. I keep them all in a functions folder and call them whenever I need them. I also have a very simple GUI which I have set up for my colleagues to enable them to easily answer simple questions quickly and easily which I will blog about later. I call it my <A href="https://blog.robsewell.com/tags/#box-of-tricks" rel=noopener target=_blank>PowerShell Box of Tricks</A></P>
<P>I am going to write a short post about each one over the next few weeks as I write my presentation on the same subject which I will be presenting to SQL User Groups.</P>
<P>Todays question which I often get asked is Which roles is this user a member of?</P>
<P>Obviously it is not normally asked exactly like that but for a DBA that is the question. Following good practice we try to ensure that database permissions are granted by role membership and each role is creatd with the minimum amount of permissions required for successful execution of the task involved. So I only concentrate on Role Membership for this script. The script in the next post will deal with Object permissions.</P>
<P>This question can come from Support Desks when they are investigating a users issue, Developers when they are testing an application as well as audit activities.</P>
<P>I start by getting the list of servers from my text file and creating an array of logins for each domain as I work in a multi domain environment</P>
<P>Edit April 2015 – Whilst I still use this technique in my presentations, I have found a more useful method of doing this nowadays. I have a DBA database which holds information about all of the servers and databases that we have. This enables me to get a list of servers that I wish to check by using Invoke-SQLCMD2 and passing in a query to get the servers that I require. This enables me to filter by Live/Dev/Test Servers or by Operating System or by SQL Version or any other filter I wish to add</P>
<P><A href="https://i2.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image25.png"><IMG title=image style="BORDER-LEFT-WIDTH: 0px; BORDER-RIGHT-WIDTH: 0px; BACKGROUND-IMAGE: none; BORDER-BOTTOM-WIDTH: 0px; PADDING-TOP: 0px; PADDING-LEFT: 0px; DISPLAY: inline; PADDING-RIGHT: 0px; BORDER-TOP-WIDTH: 0px" border=0 alt=image src="https://i1.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image_thumb25.png?resize=533%2C103" width=533 height=103 data-recalc-dims="1" loading="lazy"></A></P>
<P>Then loop through the list of servers and check if the login exists on that server</P>
<P><A href="https://i2.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image26.png"><IMG title=image style="BORDER-LEFT-WIDTH: 0px; BORDER-RIGHT-WIDTH: 0px; BACKGROUND-IMAGE: none; BORDER-BOTTOM-WIDTH: 0px; PADDING-TOP: 0px; PADDING-LEFT: 0px; DISPLAY: inline; PADDING-RIGHT: 0px; BORDER-TOP-WIDTH: 0px" border=0 alt=image src="https://i2.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image_thumb26.png?resize=532%2C120" width=532 height=120 data-recalc-dims="1" loading="lazy"></A></P>
<P>To check which Role the user is a member of I use the EnumMembers method and assign that to an array and then check if the user exists in the array</P>
<P><A href="https://i2.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image27.png"><IMG title=image style="BORDER-LEFT-WIDTH: 0px; BORDER-RIGHT-WIDTH: 0px; BACKGROUND-IMAGE: none; BORDER-BOTTOM-WIDTH: 0px; PADDING-TOP: 0px; PADDING-LEFT: 0px; DISPLAY: inline; PADDING-RIGHT: 0px; BORDER-TOP-WIDTH: 0px" border=0 alt=image src="https://i0.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image_thumb27.png?resize=537%2C155" width=537 height=155 data-recalc-dims="1" loading="lazy"></A></P>
<P>I do the same for the database roles</P>
<P><A href="https://i1.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image28.png"><IMG title=image style="BORDER-LEFT-WIDTH: 0px; BORDER-RIGHT-WIDTH: 0px; BACKGROUND-IMAGE: none; BORDER-BOTTOM-WIDTH: 0px; PADDING-TOP: 0px; PADDING-LEFT: 0px; DISPLAY: inline; PADDING-RIGHT: 0px; BORDER-TOP-WIDTH: 0px" border=0 alt=image src="https://i1.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image_thumb28.png?resize=630%2C155" width=630 height=155 data-recalc-dims="1" loading="lazy"></A></P>
<P>I then call it as follows</P>
<P><A href="https://i0.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image29.png"><IMG title=image style="BORDER-LEFT-WIDTH: 0px; BORDER-RIGHT-WIDTH: 0px; BACKGROUND-IMAGE: none; BORDER-BOTTOM-WIDTH: 0px; PADDING-TOP: 0px; PADDING-LEFT: 0px; DISPLAY: inline; PADDING-RIGHT: 0px; BORDER-TOP-WIDTH: 0px" border=0 alt=image src="https://i2.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image_thumb29.png?resize=447%2C24" width=447 height=24 data-recalc-dims="1" loading="lazy"></A></P>
<P>And get a handy report</P>
<P><A href="https://i1.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image30.png"><IMG title=image style="BORDER-LEFT-WIDTH: 0px; BORDER-RIGHT-WIDTH: 0px; BACKGROUND-IMAGE: none; BORDER-BOTTOM-WIDTH: 0px; PADDING-TOP: 0px; PADDING-LEFT: 0px; DISPLAY: inline; PADDING-RIGHT: 0px; BORDER-TOP-WIDTH: 0px" border=0 alt=image src="https://i1.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image_thumb30.png?resize=630%2C374" width=630 height=374 data-recalc-dims="1" loading="lazy"></A></P>
<P>Here is the full code</P>

    #############################################################################    ################
    #
    # NAME: Show-SQLUserPermissions.ps1
    # AUTHOR: Rob Sewell http://newsqldbawiththebeard.wordpress.com
    # DATE:06/08/2013
    #
    # COMMENTS: Load function to Display the permissions a user has across the     estate
    # NOTE - Will not show permissions granted through AD Group Membership
    # 
    # USAGE Show-SQLUserPermissions DBAwithaBeard
    
    
    Function Show-SQLUserPermissions ($user)
    {
    [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO')     | out-null
    
    # Suppress Error messages - They will be displayed at the end
    
    $ErrorActionPreference = "SilentlyContinue"
    #cls
    $Query = @"
    SELECT 
    IL.ServerName
    FROM [dbo].[InstanceList] IL
    WHERE NotContactable = 0
    AND Inactive = 0
    	AND DatabaseEngine = 'Microsoft SQL Server'
    "@
    
    Try
    {
    $Results = (Invoke-Sqlcmd -ServerInstance HMDBS02 -Database DBADatabase     -Query $query -ErrorAction Stop).ServerName
    }
    catch
    {
    Write-Error "Unable to Connect to the DBADatabase - Please Check"
    }
    # Create an array for the username and each domain slash username
    
    $logins = @("DOMAIN1\$user","DOMAIN3\$user", "DOMAIN4\$user" ,"$user" )
    Write-Output "#################################" 
                    Write-Output "Logins for `n $logins displayed below" 
                    Write-Output "################################# `n" 
    
    	#loop through each server and each database and display usernames, servers     and databases
           Write-Output " Server Logins"
             foreach($server in $Results)
    {
        $srv = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $server
        
        		foreach($login in $logins)
    		{
        
        			if($srv.Logins.Contains($login))
    			{
    
                                        Write-Output "`n $server , $login " 
                                                foreach ($Role in $Srv.Roles)
                                    {
                                        $RoleMembers = $Role.    EnumServerRoleMembers()
                                        
                                            if($RoleMembers -contains $login)
                                            {
                                            Write-Output " $login is a member of     $Role on $Server"
                                            }
                                    }
    
    			}
                
                else
                {
    
                }
             }
    }
          Write-Output "`n#########################################"
         Write-Output "`n Database Logins"               
    foreach($server in $servers)
    {
    	$srv = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $server
        
    	foreach($database in $srv.Databases)
    	{
    		foreach($login in $logins)
    		{
    			if($database.Users.Contains($login))
    			{
                                           Write-Output "`n $server , $database     , $login " 
                            foreach($role in $Database.Roles)
                                    {
                                        $RoleMembers = $Role.EnumMembers()
                                        
                                            if($RoleMembers -contains $login)
                                            {
                                            Write-Output " $login is a member of     $Role Role on $Database on $Server"
                                            }
                                    }
                        
    
    			}
                    else
                        {
                            continue
                        }   
               
    		}
    	}
        }
       Write-Output "`n#########################################"
       Write-Output "Finished - If there are no logins displayed above then no     logins were found!"    
       Write-Output "#########################################" 
    
    
    
    
    
    }



