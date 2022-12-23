---
title: "Checking Drive Sizes with PowerShell"
date: "2013-09-06" 
categories:
  - Blog

tags:
  - automate
  - permissions
  - PowerShell
  - roles
  - box-of-tricks

---
<P>I have developed a series of PowerShell functions over time which save me time and effort whilst still enabling me to provide a good service to my customers. &nbsp;I call it my <A href="https://blog.robsewell.com/tags/#box-of-tricks" rel=noopener target=_blank>PowerShell Box of Tricks</A>&nbsp;and this is another post in the series.</P>
<P>Todays question which I often get asked is <STRONG>How much space is free on the drive?</STRONG></P>
<P>A question often asked by developers during development and by DBAs when looking at provisioning new databases so I use this simple function to return the drive sizes using a WMI call with PowerShell</P>
<P>I first write the date out to the console with the Server name as I found that useful to show how much space had been freed when archiving data. Then a WMI query and a bit of maths and output to the console. The /1GB converts the drive size to something meaningful and you can see how the PercentFree is calculated from the two values using “{0:P2}”</P>

![image](https://blog.robsewell.com/assets/uploads/2013/09/image31.png)

<P>Call it like this</P>

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image32.png )](https://blog.robsewell.com/assets/uploads/2013/09/image32.png)

and here are the results from my Azure VM. (See [My previous posts on how to create your own Azure VMs with PowerShell](https://blog.robsewell.com/spinning-up-and-shutting-down-windows-azure-lab-with-powershell/))

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image33.png)](https://blog.robsewell.com/assets/uploads/2013/09/image33.png)

<P>You can find the script below</P>

    #############################################################################
    #
    # NAME: Show-DriveSizes.ps1
    # AUTHOR: Rob Sewell http://sqldbawiththebeard.com
    # DATE:22/07/2013
    #
    # COMMENTS: Load function for displaying drivesizes
    # USAGE: Show-DriveSizes server1
    ###########################################
    
    
    Function Show-DriveSizes ([string]$Server) {
        $Date = Get-Date
        Write-Host -foregroundcolor DarkBlue -backgroundcolor yellow "$Server -     - $Date"
        #interogate wmi service and return disk information
        $disks = Get-WmiObject -Class Win32_logicaldisk -Filter "Drivetype=3"     -ComputerName $Server
        $diskData = $disks | Select DeviceID, VolumeName , 
        # select size in Gbs as int and label it SizeGb
        @{Name = "SizeGB"; Expression = {$_.size / 1GB -as [int]}},
        # select freespace in Gbs  and label it FreeGb and two deciaml places
        @{Name = "FreeGB"; Expression = {"{0:N2}" -f ($_.Freespace / 1GB)}},
        # select freespace as percentage two deciaml places  and label it     PercentFree 
        @{Name = "PercentFree"; Expression = {"{0:P2}" -f ($_.Freespace / $_.    Size)}}
        $diskdata 
                                                      
    }                                                      
