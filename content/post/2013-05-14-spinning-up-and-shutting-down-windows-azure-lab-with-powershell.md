---
title: "Spinning up and shutting down Windows Azure Lab with Powershell"
date: "2013-05-14"
categories:
  - azure

tags:
  - PowerShell
  - SQLBits
---
So at SQL Bits I went to [Chris Testa-O’Neill’s](http://sqlbits.com/Speakers/Chris_Testa-O_Neill) session on certification. This has inspired me to start working on passing the MCSE exams. My PC at home doesn’t have much grunt and my tablet wont run SQL. I considered some new hardware but I knew I would have a hard time getting authorisation from the Home Financial Director (Mrs F2B) despite my all the amazing justification and benefits I could provide!!

So I looked at [Windows Azure](http://www.windowsazure.com/en-us/) as a means of having some servers to play with. After watching [this video](http://blogs.msdn.com/b/plankytronixx/archive/2013/03/19/video-explanation-of-pop-up-labs-in-the-cloud.aspx) and then [this video](http://channel9.msdn.com/Series/Windows-Azure-Virtual-Machines-and-Networking-Tutorials/Creating-Windows-Azure-Virtual-Machines-with-PowerShell) I took the plunge and dived in.

After setting up my account I read a few blogs about Powershell and Windows Azure.

[http://adminian.com/2013/04/16/how-to-setup-windows-azure-powershell/](http://adminian.com/2013/04/16/how-to-setup-windows-azure-powershell/)

Note – Here I only spin up extra small instances and don’t configure SQL as per Microsoft’s recommendations. I am only using these VMs for learning and talking at my user group your needs may be different

First you’ll need [Microsoft Web Platform Installer](http://www.microsoft.com/web/downloads/platform.aspx). Then download and install Windows Azure PowerShell,

    Import-Module c:\Program Files\Microsoft SDKs\Windows Azure\PowerShell\Azure\Azure.psd1

This gives you all the Windows Azure Powershell Cmdlets.

`Get-AzurePublishSettingsFile` which will give you a download for a file.  PowerShell will use this to control your Windows Azure so although you need it now, keep it safe and probably out of your usual directories so it doesn’t get compromised.

`Import-AzurePublishSettingsFile` and the file path to import it into Powershell.

`Get-AzureSubscription` to see the results and note the subscription name.

Now we create a storage account

    New-AzureStorageAccount -StorageAccountName chooseaname -label 'a label' -Description 'The Storage Account for the Lab Spin Up and Down' -Location 'West Europe'

`Get-AzureLocation `will show you the available locations if you want a different one.I then set the storage account to be default for my subscription

    Set-AzureSubscription -SubscriptionName 'Subscription Name from Earlier' -CurrentStorageAccount 'theoneyouchose'

I spent a couple of days sorting out the following scripts. They set up three SQL Servers, configure them to allow SSMS, Powershell and RDP connections and also remove them all. The reasoning behind this is that you will be charged for servers even when they are turned off

First we set some variables

    $image = 'fb83b3509582419d99629ce476bcb5c8__Microsoft-SQL-Server-2012SP1-Standard-CY13SU04-SQL11-SP1-CU3-11.0.3350.0-B'
    $SQL1 = 'SQL1'
    $SQL2 = 'SQL2'
    $SQL3 = 'SQL3'
    $size = 'ExtraSmall'
    $AdminUser = 'ChoosePCAdminName'
    $password = 'SUPERCOMpl1c@teDPassword'
    $Service = 'theservicenameyouchoose'
    $Location = 'West Europe'

To choose an image run `Get-AzureVMImage|select name` and pick the one for you. I chose a size of extra small as it is cheaper. As I won’t be pushing the servers very hard I don’t need any extra grunt. Set up a service the first time and use the location switch but then to use the same service again remove the location switch otherwise you will get an error stating DNS name already in use which is a little confusing until you know.

    $vm = New-AzureVMConfig -Name $SQL1 -InstanceSize $size -ImageName $image |
    Add-AzureProvisioningConfig -AdminUsername $AdminUser -Password $password -Windows |
    Add-AzureEndpoint -Name "SQL" -Protocol "tcp" -PublicPort 57502 -LocalPort 1433|
    Add-AzureEndpoint -Name PS-HTTPS -Protocol TCP -LocalPort 5986 -PublicPort 5986\

This creates a VM object and adds two endpoints for the server, one for Powershell and one for SSMS. When you provision more than one server you will need to make sure you use a different Public Port for each server otherwise you will get an error. You will need to note which server has which port when you need to connect with SSMS.

Once you have your VM object just pass it to New-AzureVM as shown

    New-AzureVM -ServiceName $Service -VMs $vm

Providing you have no errors you can then just wait until you see this.

[![image_thumb](https://i2.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/05/image_thumb_thumb.png "image_thumb")](https://i1.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/05/image_thumb1.png)

It will take a few minutes. Long enough to get a cuppa. Even then you won’t be able to connect straightaway as Azure will be provisioning the server still.

The next bit of the script downloads the RDP shortcut to a folder on the desktop and assigns a variable for the clean up script. I use this because the next time you spin up a server it may not use exactly the same port for RDP.

    $SQL1RDP = "$ENV:userprofile\Desktop\Azure\RDP\$SQL1.rdp"
    Get-AzureRemoteDesktopFile -ServiceName $Service -name $SQL1 -LocalPath $SQL1RDP
    Invoke-Expression $SQL1RDP

The `Invoke-Expression` will open up a RDP connection but unless you have gone to get a cuppa I would check in your management portal before trying to connect as the server may still be provisioning. In fact,I would go to your Windows Azure Management Portal and check your virtual machine tab where you will see your VMs being provisioned

Now you have three servers but to be able to connect to them from your desktop and practice managing them you still need to do a bit of work. RDP to each server run the following script in Powershell.

    # Configure PowerShell Execution Policy to Run all Scripts – It’s a one time Progress
    Set-ExecutionPolicy –ExecutionPolicy Unrestricted
    netsh advfirewall firewall add rule name=SQL-SSMS dir=in action=allow enable=yes profile=any
    netsh advfirewall firewall add rule name=SQL-SSMS dir=out action=allow program=any enable=yes profile=any
    netsh advfirewall firewall set rule group="Remote Administration" new enable=yes
    netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=yes
    netsh advfirewall firewall set rule group="Remote Service Management" new enable=yes
    netsh advfirewall firewall set rule group="Performance Logs and Alerts" new enable=yes
    netsh advfirewall firewall set rule group="Remote Event Log Management" new enable=yes
    netsh advfirewall firewall set rule group="Remote Scheduled Tasks Management" new enable=yes
    netsh advfirewall firewall set rule group="Remote Volume Management" new enable=yes
    netsh advfirewall firewall set rule group="Remote Desktop" new enable=yes
    netsh advfirewall firewall set rule group="Windows Firewall Remote Management" new enable =yes
    netsh advfirewall firewall set rule group="windows management instrumentation (wmi)" new enable =yes\

I use netsh advfirewall as I find it easy and I understand it. I know you can do it with `Set-NetFirewallProfile` but that’s the beauty of Powershell you can still use all your old cmd knowledge as well. This will allow you to remote manage the servers. You can do it from your laptop with the creation of some more endpoints but I just use one server as a management server for my learning.

The last part of the script changes SQL to Mixed authentication mode and creates a SQL user with sysadmin and restarts the SQL service on each server and that’s it. Its ready to go.

Open up SSMS on your desktop and connect to `YourServiceName.Cloudapp.Net, PortNumber` (57500-5702 in this example)
To remove all of the implementation run the code that is commented out in steps. First it assigns a variable to each VHD, then it removes the VM. You should then wait a while before removing the VHDs as it takes a few minutes to remove the lease and finally remove the RDP shortcuts as next time they will be different.

    <#
    .NOTES
        Name: CreateLab.ps1
        Author: Rob Sewell https://blog.robsewell.com
        Requires: Get the Windows Azures CmdLets then run this
        Version History:
                        Added New Header 23 August 2014

    .SYNOPSIS
    	This script will create 3 Windows Azure SQL Servers and open up RDP connections
    	ready for use. There is also the scripts to remove the Windows Azure Objects to save on
    	usage costs

    .DESCRIPTION

    .PARAMETER

    .PARAMETER

    .PARAMETER

    .EXAMPLE
    #>


    # Get the Subscription File and Import it
    Get-AzurePublishSettingsFile

    Import-AzurePublishSettingsFile FilepathtoPublishSettingsFile

    <# Run this once to set up a Storage Account
    New-AzureStorageAccount -StorageAccountName storageaccountname -location 'West Europe' -Label 'Storage Account for My Lab'
    #>

    Get-AzureSubscription #Note the name

    #Set the storage account to the subscription
    Set-AzureSubscription -SubscriptionName SubscriptionName -CurrentStorageAccount storageaccountname


    #Some variables

    # Use Get-AzureVMimage to find the one you want ie Get-AzureVMImage | where { ($_.ImageName -like "*SQL*") }|select ImageName

    $image = 'fb83b3509582419d99629ce476bcb5c8__Microsoft-SQL-Server-2012SP1-Standard-CY13SU04-SQL11-SP1-CU3-11.0.3350.0-B'
    $SQL1 = 'SQL1'
    $SQL2 = 'SQL2'
    $SQL3 = 'SQL3'
    $size = 'ExtraSmall'
    $AdminUser = 'ChoosePCAdminName'
    $password = 'SUPERCOMpl1c@teDPassword'
    $Service = 'theservicenameyouchoose'
    $Location = 'West Europe'

    <# Run this the first time to create a Service

    New-AzureService -ServiceName $Service  -Location $Location -Label 'SQLDBA with a Beard Service'

    #>

    #Configure the VMs

    $vm = New-AzureVMConfig -Name $SQL1 -InstanceSize $size -ImageName $image |
      Add-AzureProvisioningConfig -AdminUsername $AdminUser -Password $password -Windows|
      Add-AzureEndpoint -Name "SQL" -Protocol "tcp" -PublicPort 57500 -LocalPort 1433


    $vm2 = New-AzureVMConfig -Name $SQL2 -InstanceSize $size -ImageName $image |
      Add-AzureProvisioningConfig -AdminUsername $AdminUser -Password $password -Windows |
        Add-AzureEndpoint -Name "SQL" -Protocol "tcp" -PublicPort 57501 -LocalPort 1433


    $vm3 = New-AzureVMConfig -Name $SQL3 -InstanceSize $size -ImageName $image |
      Add-AzureProvisioningConfig -AdminUsername $AdminUser -Password $password -Windows |
        Add-AzureEndpoint -Name "SQL" -Protocol "tcp" -PublicPort 57502 -LocalPort 1433|
        Add-AzureEndpoint -Name PS-HTTPS -Protocol TCP -LocalPort 5986 -PublicPort 5986

    #Provision the VMs

    New-AzureVM -ServiceName $Service -VMs $vm, $vm2,$vm3

    # Get the RDP Files

    $SQL1RDP = "$ENV:userprofile\Desktop\Azure\RDP\$SQL1.rdp"
    $SQL2RDP = "$ENV:userprofile\Desktop\Azure\RDP\$SQL2.rdp"
    $SQL3RDP = "$ENV:userprofile\Desktop\Azure\RDP\$SQL3.rdp"

    Get-AzureRemoteDesktopFile -ServiceName $Service -name $SQL1 -LocalPath $SQL1RDP
    Get-AzureRemoteDesktopFile -ServiceName $Service -name $SQL2 -LocalPath $SQL2RDP
    Get-AzureRemoteDesktopFile -ServiceName $Service -name $SQL3 -LocalPath $SQL3RDP

    # Open the RDP Fies - Check the machine is up in your Management Portal

    Invoke-Expression $SQL1RDP
    Invoke-Expression $SQL2RDP
    Invoke-Expression $SQL3RDP

    # Now run the SetupVM script for each server

    <#

    This is the clean up script to remove the servers and services

    Run this first

     $SQL1Disk = Get-AzureDisk|where {$_.attachedto.rolename -eq $SQL1}
     $SQL2Disk = Get-AzureDisk|where {$_.attachedto.rolename -eq $SQL2}
     $SQL3Disk = Get-AzureDisk|where {$_.attachedto.rolename -eq $SQL3}

    #Then This

        Remove-AzureVM -Name $SQL1 -ServiceName $Service
        Remove-AzureVM -Name $SQL2 -ServiceName $Service
        Remove-AzureVM -Name $SQL3 -ServiceName $Service

    Then wait a while and run this

     $SQL1Disk|Remove-AzureDisk -DeleteVHD
     $SQL2Disk|Remove-AzureDisk -DeleteVHD
     $SQL3Disk|Remove-AzureDisk -DeleteVHD

      #Remove-AzureService $Service

      Get-ChildItem "$ENV:userprofile\Desktop\Azure\RDP\*.rdp"|Remove-Item

      #>

      <#

      This is the clean up script for variables


        Remove-Variable [a..z]* -Scope Global
        Remove-Variable [1..9]* -Scope Global

       #>

    .NOTES
        Name: SetUpVMSQL1.ps1
        Author: Rob Sewell https://blog.robsewell.com
        Requires:
        Version History:
                        Added New Header 23 August 2014

    .SYNOPSIS
     	This script will set up the SQL1 VM ready for use and enable SQL Authentication
    	Add a user called SQLAdmin with a password of P@ssw0rd
    	Restart SQL Service.Run on SQL1
    .DESCRIPTION

    .PARAMETER

    .PARAMETER

    .PARAMETER

    .EXAMPLE
    #>

        # Configure PowerShell Execution Policy to Run all Scripts � It�s a one time Progress
        Set-ExecutionPolicy �ExecutionPolicy Unrestricted

    netsh advfirewall firewall add rule name=SQL-SSMS dir=in action=allow enable=yes profile=any
    netsh advfirewall firewall add rule name=SQL-SSMS dir=out action=allow program=any enable=yes profile=any
    netsh advfirewall firewall set rule group="Remote Administration" new enable=yes
    netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=yes
    netsh advfirewall firewall set rule group="Remote Service Management" new enable=yes
    netsh advfirewall firewall set rule group="Performance Logs and Alerts" new enable=yes
    Netsh advfirewall firewall set rule group="Remote Event Log Management" new enable=yes
    Netsh advfirewall firewall set rule group="Remote Scheduled Tasks Management" new enable=yes
    netsh advfirewall firewall set rule group="Remote Volume Management" new enable=yes
    netsh advfirewall firewall set rule group="Remote Desktop" new enable=yes
    netsh advfirewall firewall set rule group="Windows Firewall Remote Management" new enable =yes
    netsh advfirewall firewall set rule group="windows management instrumentation (wmi)" new enable =yes

        # To Load SQL Server Management Objects into PowerShell
        [System.Reflection.Assembly]::LoadWithPartialName(�Microsoft.SqlServer.SMO�)  | out-null
        [System.Reflection.Assembly]::LoadWithPartialName(�Microsoft.SqlServer.SMOExtended�)  | out-null
        [System.Reflection.Assembly]::LoadWithPartialName(�Microsoft.SqlServer.SqlWmiManagement�) | out-null

    SQLPS

    $Name = 'SQL1'

    Invoke-Sqlcmd -ServerInstance $Name -Database master -Query "USE [master]
    GO
    EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'LoginMode', REG_DWORD, 2
    GO
    "


    Invoke-Sqlcmd -ServerInstance $Name  -Database master -Query "USE [master]
    GO
    CREATE LOGIN [SQLAdmin] WITH PASSWORD=N'P@ssw0rd', DEFAULT_DATABASE=[master]
    GO
    ALTER SERVER ROLE [sysadmin] ADD MEMBER [SQLAdmin]
    GO

    "
    get-Service -ComputerName $Name  -Name MSSQLSERVER|Restart-Service -force\

    <#
    .NOTES
        Name: SetUpVMSQL2.ps1
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
    # NAME: SetupVMSQL2.ps1
    # AUTHOR: Rob Sewell http://newsqldbawiththebeard.wordpress.com
    # DATE:10/05/2013
    #
    #
    # COMMENTS: This script will set up the SQL1 VM ready for use and enable SQL Authentication
    # Add a user called SQLAdmin with a password of P@ssw0rd
    # Restart SQL Service
    # ------------------------------------------------------------------------


       # Run on SQL2

        # Configure PowerShell Execution Policy to Run all Scripts � It�s a one time Progress
        Set-ExecutionPolicy �ExecutionPolicy Unrestricted

    netsh advfirewall firewall add rule name=SQL-SSMS dir=in action=allow enable=yes profile=any
    netsh advfirewall firewall add rule name=SQL-SSMS dir=out action=allow program=any enable=yes profile=any
    netsh advfirewall firewall set rule group="Remote Administration" new enable=yes
    netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=yes
    netsh advfirewall firewall set rule group="Remote Service Management" new enable=yes
    netsh advfirewall firewall set rule group="Performance Logs and Alerts" new enable=yes
    Netsh advfirewall firewall set rule group="Remote Event Log Management" new enable=yes
    Netsh advfirewall firewall set rule group="Remote Scheduled Tasks Management" new enable=yes
    netsh advfirewall firewall set rule group="Remote Volume Management" new enable=yes
    netsh advfirewall firewall set rule group="Remote Desktop" new enable=yes
    netsh advfirewall firewall set rule group="Windows Firewall Remote Management" new enable =yes
    netsh advfirewall firewall set rule group="windows management instrumentation (wmi)" new enable =yes

        # To Load SQL Server Management Objects into PowerShell
        [System.Reflection.Assembly]::LoadWithPartialName(�Microsoft.SqlServer.SMO�)  | out-null
        [System.Reflection.Assembly]::LoadWithPartialName(�Microsoft.SqlServer.SMOExtended�)  | out-null
        [System.Reflection.Assembly]::LoadWithPartialName(�Microsoft.SqlServer.SqlWmiManagement�) | out-null

    SQLPS

    $Name = 'SQL2'

    Invoke-Sqlcmd -ServerInstance $Name -Database master -Query "USE [master]
    GO
    EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'LoginMode', REG_DWORD, 2
    GO
    "


    Invoke-Sqlcmd -ServerInstance $Name  -Database master -Query "USE [master]
    GO
    CREATE LOGIN [SQLAdmin] WITH PASSWORD=N'P@ssw0rd', DEFAULT_DATABASE=[master]
    GO
    ALTER SERVER ROLE [sysadmin] ADD MEMBER [SQLAdmin]
    GO

    "
    get-Service -ComputerName $Name  -Name MSSQLSERVER|Restart-Service -force\

    <#
    .NOTES
        Name: SetUpVMSQL3.ps1
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
    # NAME: SetupVMSQL3.ps1
    # AUTHOR: Rob Sewell http://newsqldbawiththebeard.wordpress.com
    # DATE:10/05/2013
    #
    #
    # COMMENTS: This script will set up the SQL3 VM ready for use and enable SQL Authentication
    # Add a user called SQLAdmin with a password of P@ssw0rd
    # and enable PS Remoting
    # Restart SQL Service
    # ------------------------------------------------------------------------


       # Run on SQL3

        # Configure PowerShell Execution Policy to Run all Scripts � It�s a one time Progress
        Set-ExecutionPolicy �ExecutionPolicy Unrestricted



    netsh advfirewall firewall add rule name=SQL-SSMS dir=in action=allow enable=yes profile=any
    netsh advfirewall firewall add rule name=SQL-SSMS dir=out action=allow program=any enable=yes profile=any
    netsh advfirewall firewall set rule group="Remote Administration" new enable=yes
    netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=yes
    netsh advfirewall firewall set rule group="Remote Service Management" new enable=yes
    netsh advfirewall firewall set rule group="Performance Logs and Alerts" new enable=yes
    Netsh advfirewall firewall set rule group="Remote Event Log Management" new enable=yes
    Netsh advfirewall firewall set rule group="Remote Scheduled Tasks Management" new enable=yes
    netsh advfirewall firewall set rule group="Remote Volume Management" new enable=yes
    netsh advfirewall firewall set rule group="Remote Desktop" new enable=yes
    netsh advfirewall firewall set rule group="Windows Firewall Remote Management" new enable =yes
    netsh advfirewall firewall set rule group="windows management instrumentation (wmi)" new enable =yes

    #Extra one for PS Remoting
    netsh advfirewall firewall add rule name="Port 5986" dir=in action=allow protocol=TCP localport=5986

        # To Load SQL Server Management Objects into PowerShell
        [System.Reflection.Assembly]::LoadWithPartialName(�Microsoft.SqlServer.SMO�)  | out-null
        [System.Reflection.Assembly]::LoadWithPartialName(�Microsoft.SqlServer.SMOExtended�)  | out-null
        [System.Reflection.Assembly]::LoadWithPartialName(�Microsoft.SqlServer.SqlWmiManagement�) | out-null

    SQLPS

    $Name = 'SQL3'

    Invoke-Sqlcmd -ServerInstance $Name -Database master -Query "USE [master]
    GO
    EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'LoginMode', REG_DWORD, 2
    GO
    "


    Invoke-Sqlcmd -ServerInstance $Name  -Database master -Query "USE [master]
    GO
    CREATE LOGIN [SQLAdmin] WITH PASSWORD=N'P@ssw0rd', DEFAULT_DATABASE=[master]
    GO
    ALTER SERVER ROLE [sysadmin] ADD MEMBER [SQLAdmin]
    GO

    "
    get-Service -ComputerName $Name  -Name MSSQLSERVER|Restart-Service -force
    Enable-PSRemoting -force


Please don’t ever trust anything you read on the internet and certainly don’t implement it on production servers without first both understanding what it will do and testing it thoroughly. This solution worked for me in my environment I hope it is of use to you in yours but I know nothing about your environment and you know little about mine

