---
title: "Triggering a System Center Configuration Manager deployment task"
date: "2015-02-18"
date: "2015-02-18" 
categories: 
  - PowerShell
tags: 
  - automate
  - automation
  - PowerShell
  - SCCM
---

A slightly different topic today.

Once you have built up knowledge, you become the person that people ask to solve things. This is something I really enjoy, taking a problem and solving it for people and in the process teaching them and enabling them to automate more things. 

A colleague was performing a new deployment of a product via SCCM and wanted to trigger the clients to update and receive the new update instead of waiting for it to be scheduled.  

They had found some code that would do this  
````
Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000121}"|Out-Null
Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000021}"|Out-Null
Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000022}"|Out-Null
Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000002}"|Out-Null
````
  
They had the idea of using this command and a text file containing the machines and PS Remote.  

I looked at it a different way and gave them a function so that they could provide the Collection Name (In SCCM a collection is a list of machines for a specific purpose) and the function would import the SCCM module, connect to the Site get the names of the machines in the collection and run the command on each one  

````
function Trigger-DeploymentCycle
{
param
(
[string]$CollectionName
)

# PS script to run

$scriptblock = {
    Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000121}"|Out-Null
    Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000021}"|Out-Null
    Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000022}"|Out-Null
    Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000002}"|Out-Null
    }

## import SCCM module
Import-Module (Join-Path $(Split-Path $env:SMS_ADMIN_UI_PATH) ConfigurationManager.psd1)
#open drive for SCCM 
cd <Site Code>:\ 
#### cd <Site Code>:\ replace with Site Code or add param $SiteCOde and use cd ${$SiteCode}:\ 
# Get Computer names in collection
$PCs = (Get-CMDeviceCollectionDirectMembershipRule -CollectionName $CollectionName).rulename
$Count = $PCs.count
Write-Output "Total number of PCs = $Count"

Invoke-Command –ComputerName $PCs –ScriptBlock $scriptblock –ThrottleLimit 50

}  
````
This would work very well but they wanted some error checking to enable them to identify machines they were unable to connect to following the deployment so the final solution which will run a little slower

Set up function and parameters and create log files

```
function Trigger-DeploymentCycle
{
param
(
[string]$CollectionName
)

# Create log file
$StartTime = Get-Date
$Date = Get-Date -Format ddMMyyHHss
$Errorlogpath = "C:\temp\SCCMError" + $Date + ".txt"
$Successlogpath = "C:\temp\SCCMSuccess" + $Date + ".txt"
New-Item -Path $Errorlogpath -ItemType File
New-Item -Path $Successlogpath -ItemType File

$StartLog = "Script Started at $StartTime"
$StartLog | Out-File -FilePath $Successlogpath -Append
```

Create the script block, import the SCCM module, connect to the SCCM site and get the machines in the collection. Note that you will have to change `<Site Code>` with your own site code

```
$scriptblock = {
    Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000121}"|Out-Null
    Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000021}"|Out-Null
    Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000022}"|Out-Null
    Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000002}"|Out-Null
    }

## import SCCM module
Import-Module (Join-Path $(Split-Path $env:SMS_ADMIN_UI_PATH) ConfigurationManager.psd1)
#open drive for SCCM 
cd <Site Code>:\ #### cd <Site Code>:\ replace with Site Code or add param $SiteCOde and use cd ${$SiteCode}:\ 
# Get Computer names in collection
$PCs = (Get-CMDeviceCollectionDirectMembershipRule -CollectionName $CollectionName).rulename
$Count = $PCs.count
Write-Output "Total number of PCs = $Count"
```

I wanted to give them a progress output so I needed to be able to identify the number of machines in the collection by using the count property. I then needed to output the number of the item within the array which I did with  

```
$a= [array]::IndexOf($PCs, $PC) + 1
Write-Output " Connecting to PC - $PC -- $a of $count"
```  

I then pinged the machine,ran the script block and wrote to the log files and finally opened the log files  

````
if (Test-Connection $PC -Quiet -Count 1)
{   
# Run command on PC
Invoke-Command -ComputerName $PC -scriptblock $scriptblock
$Success = "SUCCESS - finished - $PC -- $a of $count" 
 $Success | Out-File -FilePath $Successlogpath -Append
Write-Output $Success
}
else
{
$ErrorMessage = "ERROR - $PC is not available -- $PC -- $a of $count"
$ErrorMessage| Out-File -FilePath $Errorlogpath -Append 
Write-Output $ErrorMessage
}
}

notepad $Errorlogpath
notepad $Successlogpath
````
Now they can load the function into their PowerShell sessions and type

`TriggerDeplyment COLLECTIONNAME`  

and they will be able to manually trigger the tasks. This function will trigger the following tasks for a list of PCs in a collection.

 - Machine Policy Assignment Request -- {00000000-0000-0000-0000-000000000021} 
 - Machine Policy Evaluation -- {00000000-0000-0000-0000-000000000022} 
 - Software Inventory -- {00000000-0000-0000-0000-000000000002} 
 - Application Deployment Evaluation Cycle: {00000000-0000-0000-0000-000000000121}

Here is the list of other tasks you can trigger:

- Discovery Data Collection Cycle: {00000000-0000-0000-0000-000000000003} 
- Hardware Inventory Cycle: {00000000-0000-0000-0000-000000000001} 
- Machine Policy Retrieval and Evaluation Cycle: {00000000-0000-0000-0000-000000000021} 
- Software Metering Usage Report Cycle: {00000000-0000-0000-0000-000000000031} 
- Software Updates Deployment Evaluation Cycle: {00000000-0000-0000-0000-000000000108} 
- Software Updates Scan Cycle: {00000000-0000-0000-0000-000000000113} 
- Windows Installer Source List Update Cycle: {00000000-0000-0000-0000-000000000032} 
- Hardware Inventory={00000000-0000-0000-0000-000000000001} 
- Software Update Scan={00000000-0000-0000-0000-000000000113} 
- Software Update Deployment Re-eval={00000000-0000-0000-0000-000000000114} 
- Data Discovery={00000000-0000-0000-0000-000000000003} 
- Refresh Default Management Point={00000000-0000-0000-0000-000000000023} 
- Refresh Location (AD site or Subnet)={00000000-0000-0000-0000-000000000024} 
- Software Metering Usage Reporting={00000000-0000-0000-0000-000000000031}
- Sourcelist Update Cycle={00000000-0000-0000-0000-000000000032} 
- Cleanup policy={00000000-0000-0000-0000-000000000040} 
- Validate assignments={00000000-0000-0000-0000-000000000042} 
- Certificate Maintenance={00000000-0000-0000-0000-000000000051} 
- Branch DP Scheduled Maintenance={00000000-0000-0000-0000-000000000061} 
- Branch DP Provisioning Status Reporting={00000000-0000-0000-0000-000000000062} 
- Refresh proxy management point={00000000-0000-0000-0000-000000000037} 
- Software Update Deployment={00000000-0000-0000-0000-000000000108} 
- State Message Upload={00000000-0000-0000-0000-000000000111} 
- State Message Cache Cleanup={00000000-0000-0000-0000-000000000112}

You can find the function here

[Trigger-Deployment](https://gallery.technet.microsoft.com/scriptcenter/Trigger-DeploymentCycle-c27f7b9d?WT.mc_id=DP-MVP-5002693)

and all of [my Script Center Submissions](https://gallery.technet.microsoft.com/scriptcenter/site/search?f%5B0%5D.Type=User&f%5B0%5D.Value=Rob%20Sewell?WT.mc_id=DP-MVP-5002693) are here

As always – The internet lies, fibs and deceives and everything you read including this post should be taken with a pinch of salt and examined carefully. All code should be understood and tested prior to running in a live environment.
