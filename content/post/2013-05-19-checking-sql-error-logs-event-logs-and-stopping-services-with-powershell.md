---
title: "Checking SQL Error Logs, Event Logs and Stopping Services with Powershell"
categories:
  - Blog

tags:
  - automate
  - automation
  - patching
  - ping
  - PowerShell
  - rdp

---
It was patching time this week at MyWork so I thought I would share some Powershell scripts I use to speed up the process.

I keep these in their own folder and cd to it. Then I can just type the first few letters and tab and Powershell completes it. Nice and easy and time saving

The first thing I do is to stop the SQL services with the StopSQLServices.ps1

Get the server name with Read-Host then I like to see the before and after using

    get-service -ComputerName $server|Where-Object { $_.Name -like '*SQL*' }

This uses the Get-service CMDlet to find the services with SQL in the name and display them. Then we pass the running services to an array and use the stop method with a while to check if the services are stopped before displaying the services again. Note this will stop all services with SQL in the name so if for example you are using Redgates SQL Monitor it will stop those services too. If that could be an issue then you may need to alter the where clause. As always test test test before implementing in any live environment.

Once the services are stopped I RDP using the RDP script which again uses Read-host to get a server and then opens up a RDP with a simple `Invoke-Command`. This means I can stay in Powershell.

Then I patch the server and reboot using the ping script to set up a continuous ping.

If you want to install Windows Updates via Powershell you can [use the details here.](http://blogs.technet.com/b/heyscriptingguy/archive/2012/11/08/use-a-powershell-module-to-run-windows-update.aspx) I like to jump on the box to keep an eye on it.

To check the event log The EventLog.ps1 script is very simple

    Get-EventLog  -computername $server -log $log -newest $latest | Out-GridView

Enter the server name and then application or system and it will display the results using out-gridview which will allow you to filter the results as required. I have another version of this script with a message search as well.

You can simply add `where {$_.entryType -match “Error”} `if you only want the errors or Warning for the warnings. I like to look at it all.

Check the SQL error log with this script which uses the SMO method

    $Server = Read-Host "Please Enter the Server" 
    $srv = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $server  
    $Results = $srv.ReadErrorLog(0) | format-table -Wrap -AutoSize  
    $Results
I love these four lines they make it so easy for me to look at the SQL error log whenever I need to. If you want you can pipe to Out-GridView or even to notepad. If I want to check one of the previous error logs I change ReadErrorLog(0) to ReadErrorLog(1) or 2 or 3 etc. I have a daily script which emails me any SQL error log errors and DBCC errors every day so I am aware of any issues before

Then the AutoServices.ps1 to show the state of the auto start services. Strangely you cannot get the Start Type from Get-Service so I use Get-WMIObject. If any have failed to start then I use Get-Service to get the service  and pipe to Start-Service

This is what works for me I hope it is of use to you

Please don’t ever trust anything you read on the internet and certainly don’t implement it on production servers without first both understanding what it will do and testing it thoroughly. This solution worked for me in my environment I hope it is of use to you in yours but I know nothing about your environment and you know little about mine

    <# 
    .NOTES 
        Name: StopSQLServices.ps1 
        Author: Rob Sewell https://blog.robsewell.com
        Requires: 
        Version History: 
                        Added New Header 23 August 2014
        
    .SYNOPSIS 
        
    .DESCRIPTION 
        
    .PARAMETER 
        
    .PARAMETER 
    
    .PARAMETER 
    
    .EXAMPLE 
    #> 
    #############################################################################################
    #
    # NAME: StopSQLServices.ps1
    # AUTHOR: Rob Sewell http://newsqldbawiththebeard.wordpress.com @fade2blackuk
    # DATE:15/05/2013
    #
    # COMMENTS: This script will stop all SQL Services on a server
    # ------------------------------------------------------------------------
    
    $Server = Read-Host "Please Enter the Server - This WILL stop all SQL services"
    
    Write-Host "###########  Services on $Server BEFORE  ##############" -ForegroundColor Green -BackgroundColor DarkYellow
    get-service -ComputerName $server|Where-Object { $_.Name -like '*SQL*' }Write-Host "###########  Services on $Server BEFORE  ##############" -ForegroundColor Green     -BackgroundColor DarkYellow
    ## $Services = Get-WmiObject Win32_Service -ComputerName $server|  Where-Object { $_.Name -like '*SQL*'-and $_.State-eq 'Running' }
    $Services = Get-Service -ComputerName $server|Where-Object { $_.Name -like '*SQL*' -and $_.Status -eq 'Running' }
    
    foreach ($Service in $Services) {
    
        $ServiceName = $Service.displayname
        (get-service -ComputerName $Server  -Name $ServiceName).Stop()
        while ((Get-Service -ComputerName $server -Name $ServiceName).status -ne 'Stopped')
        {<#do nothing#>}
    }
    Write-Host "###########  Services on $Server After  ##############" -ForegroundColor Green -BackgroundColor DarkYellow
    Get-Service -ComputerName $server|Where-Object { $_.Name -like '*SQL*' }
    Write-Host "###########  Services on $Server After  ##############" -ForegroundColor Green -BackgroundColor DarkYellow

 

    #############################################################################################
    #
    # NAME: RDP.ps1
    # AUTHOR: Rob Sewell http://newsqldbawiththebeard.wordpress.com @fade2blackuk
    # DATE:15/05/2013
    #
    # COMMENTS: This script to open a RDP
    # ------------------------------------------------------------------------
    
    $server = Read-Host "Server Name?"
    Invoke-Expression "mstsc /v:$server"

 

    #############################################################################################
    #
    # NAME: Ping.ps1
    # AUTHOR: Rob Sewell http://newsqldbawiththebeard.wordpress.com @fade2blackuk
    # DATE:15/05/2013
    #
    # COMMENTS: This script to set up a continous ping 
    # Use CTRL + C to stop it
    # ------------------------------------------------------------------------
    
    $server = Read-Host "Server Name?"
    Invoke-Expression "ping -t $server"

 

    #############################################################################################
    #
    # NAME: SQLErrorLog.ps1
    # AUTHOR: Rob Sewell http://newsqldbawiththebeard.wordpress.com @fade2blackuk
    # DATE:15/05/2013
    #
    # COMMENTS: This script will display the SQL Error Log for a remote server
    # ------------------------------------------------------------------------
    $Server = Read-Host "Please Enter the Server" 
    $srv = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $server  
    $srv.ReadErrorLog(0) | Out-GridView 

 

    #############################################################################################
    #
    # NAME: Autoservices.ps1
    # AUTHOR: Rob Sewell http://newsqldbawiththebeard.wordpress.com @fade2blackuk
    # DATE:15/05/2013
    #
    # COMMENTS: # Script to show the services running that are set to Automatic startup - 
    # good for checking after reboot
    # ------------------------------------------------------------------------
    
    $Server = Read-Host "Which Server?"
    
    Get-WmiObject Win32_Service -ComputerName $Server  |  
    Where-Object { $_.StartMode -like 'Auto' }| 
    Select-Object __SERVER, Name, StartMode, State | Format-Table -auto
    Write-Host "SQL Services"
    Get-WmiObject Win32_Service -ComputerName $Server  |  
    Where-Object { $_.DisplayName -like '*SQL*' }| 
    Select-Object __SERVER, Name, StartMode, State | Format-Table -auto
