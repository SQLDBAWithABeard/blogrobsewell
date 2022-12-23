---
title: "Emailing Disk Space Alerting With Powershell"
date: "2014-11-04" 
categories:
  - Blog

tags:
  - automation
  - email
  - PowerShell
  - script
  - disk space
  - alerting


image: assets/uploads/2014/11/image_thumb.png

---
A DBA doesn’t want to run out of space on their servers, even in their labs! To avoid this happening I wrote a Powershell script to provide some alerts by email.

This is the script and how I worked my way through the solution. I hope it is of benefit to others.

The script works in the following way

*   Iterates through a list of servers
*   Runs a WMI query to gather disk information
*   If the free space has fallen below a threshold, checks to see if it has emailed before and if not emails a warning
*   Resets if free space has risen above the threshold
*   Logs what it does but manages the space the logs use

As you will have seen before I use a Servers text file in my scripts. This is a text file with a single server name on each line. You could also use a query against a DBA or MDW database using Invoke-SQLCMD2, which ever is the most suitable for you.

    $Servers = Get-Content 'PATH\\TO\\Servers.txt' foreach($Server in $Servers) { 

The WMI query is a very simple one to gather the disk information. I format the results and place them in variables for reuse

     $Disks = Get-WmiObject win32\_logicaldisk -ComputerName $Server | Where-Object {$\_.drivetype -eq 3} 
     $TotalSpace=\[math\]::Round(($Disk.Size/1073741824),2) 
     # change to gb and 2 decimal places 
     $FreeSpace=\[Math\]::Round(($Disk.FreeSpace/1073741824),2)
     # change to gb and 2 decimal places 
     $UsedSpace = $TotalSpace - $FreeSpace 
     $PercentFree = \[Math\]::Round((($FreeSpace/$TotalSpace)*100),2)
     # change to gb and 2 decimal places 

Use a bit of logic to check if the freespace is below a threshold and see if the email has already been sent

    # Check if percent free below warning level 
    if ($PercentFree -le $SevereLevel) { 
      # if text file has been created (ie email should already have been sent) do nothing 
      if(Test-Path $CheckFileSevere) {} 
      # if percent free below warning level and text file doesnot exist create text file and email 
      else { 

If it has not create a unique named text file and create the email body using HTML and the values stored in the variables

    New-Item $CheckFileSevere -ItemType File #Create Email Body $EmailBody = '' $EmailBody += " " 

and then send it

    $Subject = "URGENT Disk Space Alert 1%" 
    $Body = $EmailBody 
    $msg = new-object Net.Mail.MailMessage 
    $smtp = new-object Net.Mail.SmtpClient($smtpServer) 
    $smtp.port = '25' 
    $msg.From = $From 
    $msg.Sender = $Sender 
    $msg.To.Add($To) 
    $msg.Subject = $Subject 
    $msg.Body = $Body 
    $msg.IsBodyHtml = $True 
    $smtp.Send($msg) 

If the freespace is above all of the warning levels, check for existence of the text file and delete it if found so that the next time the script runs it will send an email.

    if(Test-Path $CheckFile) { 
      Remove-Item $CheckFile -Force

To enable logging create a log file each day

     $Logdate = Get-Date -Format yyyyMMdd 
     $LogFile = $Location + 'logfile' + $LogDate+ '.txt' 
     # if daily log file does not exist create one 
     if(!(Test-Path $LogFile)) { 
       New-Item $Logfile -ItemType File
     } 

And write the info to it at each action

     $logentrydate = (Get-Date).DateTime 
     $Log = $logentrydate + ' ' + $ServerName + ' ' + $DriveLetter + ' ' + $VolumeName + ' ' + $PercentFree +' -- Severe Email Sent' 
     Add-Content -Value $Log -Path $Logfile

Making sure that you clean up after

    # any logfiles older than 7 days delete 
    Get-ChildItem -Path $Location \*logfile\* |Where-Object {$_.LastWriteTime -gt (Get-Date).AddDays(7) }|Remove-Item -Force 

I run the script in a Powershell Step in an SQL Agent Job every 5 minutes and now I know when my servers in my lab are running out of space with an email like this

[![image](https://blog.robsewell.com/assets/uploads/2014/11/image_thumb.png)](https://blog.robsewell.com/assets/uploads/2014/11/image_thumb.png)

[You can find the script here](https://github.com/SQLDBAWithABeard/OldCodeFromBlog/tree/master/EmailingDiskAlertPost)
