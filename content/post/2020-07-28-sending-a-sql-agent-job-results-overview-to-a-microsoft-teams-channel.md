---
title: "Sending a SQL Agent Job results overview to a Microsoft Teams Channel"
date: "2020-07-28" 
categories:
  - Blog
  - dbatools
  - PowerShell
  - SQL Server
  
tags:
  - automation
  - dbatools
  - PowerShell
  - Teams
  - SQL Agent


image: /assets/uploads/2020/07/image-11.png

---
Microsoft Teams is fantastic for collaboration. It enables groups of people, teams if you like to be able to communicate, collaborate on documents, hold meetings and much much more.

SQL Agent Job Overview
----------------------

Using [dbatools](http://dbatools.io) we can create a simple script to gather the results of Agent Jobs form a list of instances. Maybe it would be good to be able to get the job runs results every 12 hours so that at 6am in the morning the early-bird DBA can quickly identify if there are any failures that need immediate action and at 6pm , the team can check that everything was ok before they clock off.

Here is an example of such a script

    $SqlInstances = (Get-Vm -ComputerName BEARDNUC,BEARDNUC2).Where{$_.State -eq 'Running' -and $_.Name -like '*SQL*'}.Name
    $AllJobs = "
    SqlInstance...|...Total...|...Successful...|...FailedJobs...|...FailedSteps...|...Canceled...     
    ---------------------------------------------  
    "
    foreach ($Instance in $SQLInstances) {
        Write-Host "Connecting to $instance"
        try{
            $smo = Connect-DbaInstance $Instance -ErrorAction Stop
            Write-Host "Connected successfully to $instance"
        }
        catch{
            Write-Host "Failed to connect to $Instance" 
            $errorMessage = $_ | Out-String
            Write-Host $errorMessage
            Continue
        }
    
        Write-Host "Getting Agent Jobs on $instance"
        try {
            $AgentJobs = Get-DbaAgentJobHistory -SqlInstance $smo -EnableException -StartDate $startdate 
            Write-Host "Successfully got Agent Jobs on $instance"
        }
        catch {
            Write-Host "Failed to get agent jobs on $Instance" 
            $errorMessage = $_ | Out-String
            Write-Host $errorMessage
            Continue
        }
        
    
        $jobs = $agentJobs 
        $NumberOfJobs = ($Jobs |Where-Object {$PSitem.StepId -eq 0}).Count.ToString("00")
        $NumberOfFailedJobs = ($Jobs |Where-Object {$PSitem.StepId -eq 0}|  Where-Object {$PSItem.Status -eq 'Failed'}).StepName.Count.ToString("00")
        $NumberOfFailedJobSteps = ($Jobs |Where-Object {$PSitem.StepId -ne 0}|  Where-Object {$PSItem.Status -eq 'Failed'}).StepName.Count.ToString("00")
        $NumberOfSuccessfulJobs = ($Jobs |Where-Object {$PSitem.StepId -eq 0} | Where-Object {$PSItem.Status -eq 'Succeeded'}).StepName.Count.ToString("00")
        $NumberOfCanceledJobs = ($Jobs |Where-Object {$PSitem.StepId -eq 0} | Where-Object {$PSItem.Status -eq 'Canceled'}).StepName.Count.ToString("00")
    
         Write-Host "SqlInstance $Instance - Number of Jobs $NumberOfJobs - Number of Successful Jobs $NumberOfSuccessfulJobs  - Number of Failed Jobs $NumberOfFailedJobs"
    
        $AllJobs = $AllJobs + "$($Instance.Split('.')[0])..........<b>$NumberOfJobs</b>................<b>$NumberOfSuccessfulJobs</b>.........................<b>$NumberOfFailedJobs</b>............................<b>$NumberOfFailedJobSteps</b>..............................<b>$NumberOfCanceledJobs</b>........
    "
        try{
            $smo.ConnectionContext.Disconnect()
            Write-Host "Disconnecting $instance"
        }
        catch{
            Write-Host "Failed disconnect from  $Instance" 
            $errorMessage = $_ | Out-String
            Write-Host $errorMessage
            Continue
        }
    
    }
    
    Write-Host "Since $startdate"
    Write-Host "$AllJobs"

and an example of running it.

![](https://blog.robsewell.com/assets/uploads/2020/07/image-2.png)

Create a Teams Channel
----------------------

If you have permissions, you can create a new Teams channel by clicking on the 3 ellipses and add channel

![](https://blog.robsewell.com/assets/uploads/2020/07/image-3.png)

Then fill in the blanks

![](https://blog.robsewell.com/assets/uploads/2020/07/image-4.png)

Create a Webhook Connector for the channel
------------------------------------------

Next, you need to have a connector for the channel, click on the 3 ellipses for the channel and click on connectors

![](https://blog.robsewell.com/assets/uploads/2020/07/image-5.png)

Then you can choose the Incoming Webhook connector and click configure

![](https://blog.robsewell.com/assets/uploads/2020/07/image-6.png)

Give the connector a name and upload an image if you wish and click create

![](https://blog.robsewell.com/assets/uploads/2020/07/image-7.png)

The resulting screen will give you a URL that you can copy. If you need to find it again, then use the 3 ellipses again, click connectors and look at configured. You can then choose the webhook that you have created and click manage and you will find the URL.

![](https://blog.robsewell.com/assets/uploads/2020/07/image-8.png)

Send to Teams using PowerShell
------------------------------

Now you can send a message to that Teams channel using PowerShell. You will need to add the webhook URL from your Teams connector

    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $webhookurl = ""
    
        $Text =  @"
    # Here is a Title
    
    and a message
    
    Image is from
    
    https://www.flickr.com/photos/157270154@N05/38494483572
    
    Photo by CreditDebitPro
    "@
    
        $JSONBody = [PSCustomObject][Ordered]@{
            "@type"      = "MessageCard"
            "@context"   = "http://schema.org/extensions"
            "summary"    = "This is my summary"
            "themeColor" = '0078D7'
            "sections"   = @(
                @{
                    "activityTitle"    = "Something Important "
                    "activitySubtitle" = "I have something to say"
                    "activityImage"    = "https://live.staticflickr.com/4568/38494483572_a98d623854_k.jpg"
                    "text"             = $text
                    "markdown"         = $true
                }
            )
        }
     
        $TeamMessageBody = ConvertTo-Json $JSONBody -Depth 100
     
        $parameters = @{
            "URI"         = $webhookurl
            "Method"      = 'POST'
            "Body"        = $TeamMessageBody
            "ContentType" = 'application/json'
        }
     
        Invoke-RestMethod @parameters

The code above will send a message that looks like this

![](https://blog.robsewell.com/assets/uploads/2020/07/image-9.png)

Running as a SQL Agent Job
--------------------------

Now we can run this code as a SQL Agent Job and schedule it. Now, you may not be able to run that code on your SQL Server. It cannot connect to the internet, so how can we contact the Teams webhook?

There are probably a number of ways to do this but the solution that I took, was to allow a proxy account the ability to use PSRemoting and run the part of the script that connects to Teams on a different machine, that does have connectivity.

The script I used was as follows. You will need to add in the SQL Instances or better still dynamically gather them from your source of truth. You will need the webhook URL and the name of the server that can connect to Teams

    $SQLInstances = 'SQL2005Ser2003','SQL2008Ser12R2','SQL2014Ser12R2','SQL2016N1','SQL2016N2','SQL2016N3','SQL2017N5','SQL2019N20','SQL2019N21','SQL2019N22','SQL2019N5'
    
    $startdate = (Get-Date).AddHours(-12)
    $webhookurl = ""
    $NotifyServer = 'BeardNUC2'
    
    $AllJobs = "
    SqlInstance...|...Total...|...Successful...|...FailedJobs...|...FailedSteps...|...Canceled...     
    ---------------------------------------------  
    "
    foreach ($Instance in $SQLInstances) {
        Write-Host "Connecting to $instance"
        try{
            $smo = Connect-DbaInstance $Instance -ErrorAction Stop
            Write-Host "Connected successfully to $instance"
        }
        catch{
            Write-Host "Failed to connect to $Instance" 
            $errorMessage = $_ | Out-String
            Write-Host $errorMessage
            Continue
        }
    
        Write-Host "Getting Agent Jobs on $instance"
        try {
            $AgentJobs = Get-DbaAgentJobHistory -SqlInstance $smo -EnableException -StartDate $startdate 
            Write-Host "Successfully got Agent Jobs on $instance"
        }
        catch {
            Write-Host "Failed to get agent jobs on $Instance" 
            $errorMessage = $_ | Out-String
            Write-Host $errorMessage
            Continue
        }
        
    
        $jobs = $agentJobs 
        $NumberOfJobs = ($Jobs |Where-Object {$PSitem.StepId -eq 0}).Count.ToString("00")
        $NumberOfFailedJobs = ($Jobs |Where-Object {$PSitem.StepId -eq 0}|  Where-Object {$PSItem.Status -eq 'Failed'}).StepName.Count.ToString("00")
        $NumberOfFailedJobSteps = ($Jobs |Where-Object {$PSitem.StepId -ne 0}|  Where-Object {$PSItem.Status -eq 'Failed'}).StepName.Count.ToString("00")
        $NumberOfSuccessfulJobs = ($Jobs |Where-Object {$PSitem.StepId -eq 0} | Where-Object {$PSItem.Status -eq 'Succeeded'}).StepName.Count.ToString("00")
        $NumberOfCanceledJobs = ($Jobs |Where-Object {$PSitem.StepId -eq 0} | Where-Object {$PSItem.Status -eq 'Canceled'}).StepName.Count.ToString("00")
    
         Write-Host "SqlInstance $Instance - Number of Jobs $NumberOfJobs - Number of Successful Jobs $NumberOfSuccessfulJobs  - Number of Failed Jobs $NumberOfFailedJobs"
    
        $AllJobs = $AllJobs + "$($Instance.Split('.')[0])..........<b>$NumberOfJobs</b>................<b>$NumberOfSuccessfulJobs</b>.........................<b>$NumberOfFailedJobs</b>............................<b>$NumberOfFailedJobSteps</b>..............................<b>$NumberOfCanceledJobs</b>........
    "
        try{
            $smo.ConnectionContext.Disconnect()
            Write-Host "Disconnecting $instance"
        }
        catch{
            Write-Host "Failed disconnect from  $Instance" 
            $errorMessage = $_ | Out-String
            Write-Host $errorMessage
            Continue
        }
    
    }
    
    Write-Host "Since $startdate"
    Write-Host "$AllJobs"
    
    $NotifyCommand = {
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $webhookurl = $Using:TeamsWebhook
     
    $allJobsMessage = $Using:AllJobs 
        $Text =  @"
    # Overview of SQL Agent Jobs in Production since $($Using:startdate)  
    
    $allJobsMessage
    "@
    
        $JSONBody = [PSCustomObject][Ordered]@{
            "@type"      = "MessageCard"
            "@context"   = "http://schema.org/extensions"
            "summary"    = "Overview for the last 12 hours"
            "themeColor" = '0078D7'
            "sections"   = @(
                @{
                    "activityTitle"    = "Job Failures "
                    "activitySubtitle" = "Overview for the last 12 hours since $($Using:startdate)"
                    "activityImage"    = "https://live.staticflickr.com/4568/38494483572_a98d623854_k.jpg"
                    "text"             = $allJobsMessage
                    "markdown"         = $true
                }
            )
        }
     
        $TeamMessageBody = ConvertTo-Json $JSONBody -Depth 100
     
        $parameters = @{
            "URI"         = $webhookurl
            "Method"      = 'POST'
            "Body"        = $TeamMessageBody
            "ContentType" = 'application/json'
        }
     
        Invoke-RestMethod @parameters
    }
    
    $Session = New-PSSession -ComputerName $NotifyServer
    Invoke-Command -Session $Session -ScriptBlock $NotifyCommand

Then, follow the steps at [dbatools.io/agent](http://dbatools.io/agent) to create an agent job to run the script above on an instance with the dbatools module available to the SQL Service account. Use or create a proxy with permissions on the notify server and create an Agent Job.

    USE [msdb]
    GO
    
    /****** Object:  Job [I am a Job that notifies Teams]    Script Date: 27/07/2020 20:27:27 ******/
    BEGIN TRANSACTION
    DECLARE @ReturnCode INT
    SELECT @ReturnCode = 0
    /****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 27/07/2020 20:27:28 ******/
    IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
    BEGIN
    EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
    
    END
    
    DECLARE @jobId BINARY(16)
    EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'12 Hour Teams Notify', 
    		@enabled=1, 
    		@notify_level_eventlog=0, 
    		@notify_level_email=0, 
    		@notify_level_netsend=0, 
    		@notify_level_page=0, 
    		@delete_level=0, 
    		@description=N'This job will notify Teams every 12 hours', 
    		@category_name=N'[Uncategorized (Local)]', 
    		@owner_login_name=N'THEBEARD\SQL_SVC', @job_id = @jobId OUTPUT
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
    
    /****** Object:  Step [Notify Teams]    Script Date: 27/07/2020 20:27:28 ******/
    EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Notify Teams', 
    		@step_id=1, 
    		@cmdexec_success_code=0, 
    		@on_success_action=1, 
    		@on_success_step_id=0, 
    		@on_fail_action=2, 
    		@on_fail_step_id=0, 
    		@retry_attempts=0, 
    		@retry_interval=0, 
    		@os_run_priority=0, @subsystem=N'CmdExec', 
    		@command=N'powershell.exe -File C:\temp\AgentJobs\NotifyTeams.ps1', 
    		@flags=0, 
    		@proxy_name=N'TheBeardIsMighty'
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
    EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
    EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
    COMMIT TRANSACTION
    GOTO EndSave
    QuitWithRollback:
        IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
    EndSave:
    GO
    
    
    

When the job runs

![](https://blog.robsewell.com/assets/uploads/2020/07/image-10.png)

The results are posted to the Teams Channel

![](https://blog.robsewell.com/assets/uploads/2020/07/image-11.png)

If you can run the Agent Job on a machine that can connect to Teams and your SQL Instances then you can remove the need to use a remote session by using this code

    $SQLInstances = 'SQL2005Ser2003','SQL2008Ser12R2','SQL2014Ser12R2','SQL2016N1','SQL2016N2','SQL2016N3','SQL2017N5','SQL2019N20','SQL2019N21','SQL2019N22','SQL2019N5'
    
    $startdate = (Get-Date).AddHours(-12)
    $webhookurl = ""
    
    
    # Import-Module 'C:\Program Files\WindowsPowerShell\Modules\dbatools\1.0.107\dbatools.psd1'
    $AllJobs = "
    SqlInstance...|...Total...|...Successful...|...FailedJobs...|...FailedSteps...|...Canceled...     
    ---------------------------------------------  
    "
    foreach ($Instance in $SQLInstances) {
        Write-Host "Connecting to $instance"
        try{
            $smo = Connect-DbaInstance $Instance -ErrorAction Stop
            Write-Host "Connected successfully to $instance"
        }
        catch{
            Write-Host "Failed to connect to $Instance" 
            $errorMessage = $_ | Out-String
            Write-Host $errorMessage
            Continue
        }
    
        Write-Host "Getting Agent Jobs on $instance"
        try {
            $AgentJobs = Get-DbaAgentJobHistory -SqlInstance $smo -EnableException -StartDate $startdate 
            Write-Host "Successfully got Agent Jobs on $instance"
        }
        catch {
            Write-Host "Failed to get agent jobs on $Instance" 
            $errorMessage = $_ | Out-String
            Write-Host $errorMessage
            Continue
        }
        
    
        $jobs = $agentJobs 
        $NumberOfJobs = ($Jobs |Where-Object {$PSitem.StepId -eq 0}).Count.ToString("00")
        $NumberOfFailedJobs = ($Jobs |Where-Object {$PSitem.StepId -eq 0}|  Where-Object {$PSItem.Status -eq 'Failed'}).StepName.Count.ToString("00")
        $NumberOfFailedJobSteps = ($Jobs |Where-Object {$PSitem.StepId -ne 0}|  Where-Object {$PSItem.Status -eq 'Failed'}).StepName.Count.ToString("00")
        $NumberOfSuccessfulJobs = ($Jobs |Where-Object {$PSitem.StepId -eq 0} | Where-Object {$PSItem.Status -eq 'Succeeded'}).StepName.Count.ToString("00")
        $NumberOfCanceledJobs = ($Jobs |Where-Object {$PSitem.StepId -eq 0} | Where-Object {$PSItem.Status -eq 'Canceled'}).StepName.Count.ToString("00")
    
         Write-Host "SqlInstance $Instance - Number of Jobs $NumberOfJobs - Number of Successful Jobs $NumberOfSuccessfulJobs  - Number of Failed Jobs $NumberOfFailedJobs"
    
        $AllJobs = $AllJobs + "$($Instance.Split('.')[0])..........<b>$NumberOfJobs</b>................<b>$NumberOfSuccessfulJobs</b>.........................<b>$NumberOfFailedJobs</b>............................<b>$NumberOfFailedJobSteps</b>..............................<b>$NumberOfCanceledJobs</b>........
    "
        try{
            $smo.ConnectionContext.Disconnect()
            Write-Host "Disconnecting $instance"
        }
        catch{
            Write-Host "Failed disconnect from  $Instance" 
            $errorMessage = $_ | Out-String
            Write-Host $errorMessage
            Continue
        }
    
    }
    
    Write-Host "Since $startdate"
    Write-Host "$AllJobs"
    
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
     
    $allJobsMessage = $AllJobs 
        $Text =  @"
    # Overview of SQL Agent Jobs in Production since $($startdate)  
    
    $allJobsMessage
    "@
    
        $JSONBody = [PSCustomObject][Ordered]@{
            "@type"      = "MessageCard"
            "@context"   = "http://schema.org/extensions"
            "summary"    = "Overview for the last 12 hours"
            "themeColor" = '0078D7'
            "sections"   = @(
                @{
                    "activityTitle"    = "Job Results "
                    "activitySubtitle" = "Overview for the last 12 hours since $($startdate)"
                    "activityImage"    = "https://live.staticflickr.com/4568/38494483572_a98d623854_k.jpg"
                    "text"             = $allJobsMessage
                    "markdown"         = $true
                }
            )
        }
     
        $TeamMessageBody = ConvertTo-Json $JSONBody -Depth 100
     
        $parameters = @{
            "URI"         = $webhookurl
            "Method"      = 'POST'
            "Body"        = $TeamMessageBody
            "ContentType" = 'application/json'
        }
     
        Invoke-RestMethod @parameters
    

Happy automating!
