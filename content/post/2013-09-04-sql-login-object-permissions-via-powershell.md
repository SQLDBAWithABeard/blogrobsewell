---
title: "SQL login object permissions via PowerShell"
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
<P>Todays question which I often get asked is What permissions do users have on that server?</P>
<P>In the last post on <A href="https://blog.robsewell.com/?p=114" rel=noopener target=_blank>Checking SQL Server User Role Membership with PowerShell</A> we checked the permissions a user had across the estate, this one answers the question about all users on a server.</P>
<P>This is generally asked by DBAs of each other <IMG class="wlEmoticon wlEmoticon-smile" style="BORDER-TOP-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none; BORDER-RIGHT-STYLE: none" alt=Smile src="https://i0.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/wlemoticon-smile.png?w=630" data-recalc-dims="1">, auditors and the owners of the service</P>
<P>The first part of the script is very similar to the last post on <A href="https://blog.robsewell.com/?p=114" rel=noopener target=_blank>Checking SQL Server User Role Membership with PowerShell</A> but we use the EnumMembers method to display the members of the roles.</P>
<P><A href="https://i0.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image15.png"><IMG title=image style="BORDER-LEFT-WIDTH: 0px; BORDER-RIGHT-WIDTH: 0px; BACKGROUND-IMAGE: none; BORDER-BOTTOM-WIDTH: 0px; PADDING-TOP: 0px; PADDING-LEFT: 0px; DISPLAY: inline; PADDING-RIGHT: 0px; BORDER-TOP-WIDTH: 0px" border=0 alt=image src="https://i0.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image_thumb15.png?resize=630%2C169" width=630 height=169 data-recalc-dims="1" loading="lazy"></A></P>
<P>The second part – the object permissions comes with thanks to David Levy via <A href="http://adventuresinsql.com/2009/12/script-individual-user-rights-in-a-database-with-powershell/" rel=noopener target=_blank>This Link</A></P>
<P><A href="https://i0.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image16.png"><IMG title=image style="BORDER-LEFT-WIDTH: 0px; BORDER-RIGHT-WIDTH: 0px; BACKGROUND-IMAGE: none; BORDER-BOTTOM-WIDTH: 0px; PADDING-TOP: 0px; PADDING-LEFT: 0px; DISPLAY: inline; PADDING-RIGHT: 0px; BORDER-TOP-WIDTH: 0px" border=0 alt=image src="https://i0.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image_thumb16.png?resize=630%2C82" width=630 height=82 data-recalc-dims="1" loading="lazy"></A></P>
<P>To call it simply load the function</P>
<P><A href="https://i1.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image23.png"><IMG title=image style="BORDER-LEFT-WIDTH: 0px; BORDER-RIGHT-WIDTH: 0px; BACKGROUND-IMAGE: none; BORDER-BOTTOM-WIDTH: 0px; PADDING-TOP: 0px; PADDING-LEFT: 0px; DISPLAY: inline; PADDING-RIGHT: 0px; BORDER-TOP-WIDTH: 0px" border=0 alt=image src="https://i0.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image_thumb23.png?resize=540%2C31" width=540 height=31 data-recalc-dims="1" loading="lazy"></A></P>
<P>and a report</P>
<P><A href="https://i0.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image24.png"><IMG title=image style="BORDER-LEFT-WIDTH: 0px; BORDER-RIGHT-WIDTH: 0px; BACKGROUND-IMAGE: none; BORDER-BOTTOM-WIDTH: 0px; PADDING-TOP: 0px; PADDING-LEFT: 0px; DISPLAY: inline; PADDING-RIGHT: 0px; BORDER-TOP-WIDTH: 0px" border=0 alt=image src="https://i2.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image_thumb24.png?resize=630%2C314" width=630 height=314 data-recalc-dims="1" loading="lazy"></A></P>
<P>You can get the code here</P>


    #############################################################################    ################
    #
    # NAME: Show-SQLServerPermissions.ps1
    # AUTHOR: Rob Sewell http://newsqldbawiththebeard.wordpress.com
    # DATE:06/08/2013
    #
    # COMMENTS: Load function for Enumerating Server and Database Role     permissions or object permissions
    #
    # USAGE Show-SQLServerPermissions Server1
    # ————————————————————————
    
    Function Show-SQLServerPermissions ($SQLServer) {
        $server = new-object "Microsoft.SqlServer.Management.Smo.Server"     $SQLServer
    
        $selected = "" 
        $selected = Read-Host "Enter Selection 
                                    1.) Role Membership or 
                                    2.) Object Permissions"
        
        Switch ($Selected) {
            1 {
        
                Write-Host "####  Server Role Membership on $Server     ############################################## `n`n"
                foreach ($Role in $Server.Roles) {
                                    
                    if ($Role.EnumServerRoleMembers().count -ne 0) {
                        Write-Host "###############  Server Role Membership for     $role on $Server #########################`n" 
                        $Role.EnumServerRoleMembers()
                    }
    
                }
                Write-Host     "################################################################    ######################" 
                Write-Host     "################################################################    ######################`n `n `n" 
    
    
                foreach ($Database in $Server.Databases) {
                    Write-Host "`n####  $Database Permissions on $Server     ###############################################`n" 
                    foreach ($role in $Database.Roles) {
                        if ($Role.EnumMembers().count -ne 0) {
                            Write-Host "###########  Database Role Permissions     for $Database $Role on $Server ################`n"
                            $Role.EnumMembers()
                        }
    
                    }
    
                }
            } 
    
            2 {
    
                Write-Host "##################  Object Permissions on $Server     ################################`n"
                foreach ($Database in $Server.Databases) {
                    Write-Host "`n####  Object Permissions on $Database on     $Server #################################`n"
                    foreach ($user in $database.Users) {
                        foreach ($databasePermission in $database.    EnumDatabasePermissions($user.Name)) {
                            Write-Host $databasePermission.PermissionState     $databasePermission.PermissionType "TO"     $databasePermission.Grantee
                        }
                        foreach ($objectPermission in $database.    EnumObjectPermissions($user.Name)) {
                            Write-Host $objectPermission.PermissionState     $objectPermission.PermissionType "ON"     $objectPermission.ObjectName "TO" $objectPermission.    Grantee
                        }
                    }
                }
            }
        }
    }

<P>&nbsp;</P>

