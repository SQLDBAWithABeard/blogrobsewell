---
title: "Add Adventure Works Database to Windows Azure VM"
categories:
  - azure
  - Blog

tags:
  - PowerShell

---
This has been an interesting journey. The Adventure Works database is frequently used in blogs and reference books and I wanted to install it in my Windows Azure Learning Lab and I also wanted to automate the process.

The easiest way is to download the Windows Azure MDF file from  [http://msftdbprodsamples.codeplex.com/](http://msftdbprodsamples.codeplex.com/) jump through all the security warnings in Internet Explorer and save the file and then create the database as follows

    CREATE DATABASE AdventureWorks2012
    ON (FILENAME = 'PATH TO \AdventureWorks2012_Data.mdf')
    FOR ATTACH_REBUILD_LOG ;

That is the way I will do it from now on! After reading [this page](http://answers.oreilly.com/topic/2006-how-to-download-a-file-from-the-internet-with-windows-powershell/) I tried to download the file with Powershell but it would not as I could not provide a direct link to the file. Maybe someone can help me with that. So I thought I would use my SkyDrive to hold the MDF file and map a drive on the server.

to do this you need to add the Desktop Experience feature to the server. This can be done as follows

    Import-Module ServerManager
    Add-WindowsFeature Desktop-Experience -restart

This will take a few minutes to install, reboot and then configure the updates before you can log back in. While it is doing this log into your SkyDrive and navigate to a folder and copy the URL to notepad

It will look something like this

[https://skydrive.live.com/?lc=2137#cid=XXXXXXXXXXXXXXXX&id=CYYYYYYYYYYYYYYYY](https://skydrive.live.com/?lc=2137#cid=XXXXXXXXXXXXXXXX&id=CYYYYYYYYYYYYYYYY "https://skydrive.live.com/?lc=2137#cid=XXXXXXXXXXXXXXXX&id=CYYYYYYYYYYYYYYYY")

Copy the GUID after the cid=

and write this command

    net use T:  \\d.docs.live.net@SSL\XXXXXXXXXXXXXXXX /user:$user $password

I keep this in a script and pass the user and password in via `Read-Host`

However, if you try to copy the item from the folder you will get an error

The file size exceeds the limit allowed and cannot be saved

So you will need to alter a registry key as follows

    Set-ItemProperty -Path HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WebClient\Parameters -Name FileSizeLimitInBytes -Value 4294967295

and then restart the WebClient service Then run the `net use` command to map the drive and copy the file with `Copy-Item`

But my script to auto install the Adventure Works database via Powershell once you have completed all the pre-requisites is

    $user = Read-Host "user"
    $password = Read-Host "Password"
    net use T:  \\d.docs.live.net@SSL\XXXXXXXXXXXXXXX /user:$user $password
    New-Item c:\AW -ItemType directory
    Copy-Item T:\Documents\Azure\AdventureWorks2012_Data.mdf C:\AW
    Invoke-Sqlcmd -ServerInstance YourServerName -Database master -Query "CREATE DATABASE AdventureWorks2012
    ON (FILENAME = 'C:\AW\AdventureWorks2012_Data.mdf')
    FOR ATTACH_REBUILD_LOG ;"

To be honest I don’t think I will use this method as my copy failed twice before it succeeded so I will just download the file and create the database!!

Please don’t ever trust anything you read on the internet and certainly don’t implement it on production servers without first both understanding what it will do and testing it thoroughly. This solution worked for me in my environment I hope it is of use to you in yours but I know nothing about your environment and you know little about mine