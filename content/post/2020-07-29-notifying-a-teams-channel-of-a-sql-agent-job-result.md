---
title: "Notifying a Teams Channel of a SQL Agent Job result"
date: "2020-07-29" 
categories:
  - Blog
  - dbatools

tags:
  - automation
  - dbatools
  - PowerShell
  - Teams
  - SQL Agent


image: assets/uploads/2020/07/image-18.png

---
Following on from [yesterdays post about creating an overview of SQL Agent Job Results and sending it to a Teams channel](https://blog.robsewell.com/sending-a-sql-agent-job-results-overview-to-a-microsoft-teams-channel/), I was given another challenge

> Can you write a job step that I can add to SQL Agent jobs that can send the result of that job to a Teams Channel
> 
> A person with a need

The use case was for some migration projects that had steps that were scheduled via SQL Agent Jobs and instead of the DBA having to estimate when they would finish and keep checking so that they could let the next team know that it was time for their part to start, they wanted it to notify a Teams channel. This turned out especially useful as the job finished earlier than expected at 3am and the off-shore team could begin their work immediately.

Using SQL Agent Job tokens with PowerShell
------------------------------------------

You can use [SQL Agent job tokens in Job step commands to reference the existing instance or job](https://docs.microsoft.com/en-us/sql/ssms/agent/use-tokens-in-job-steps?view=sql-server-ver15?WT.mc_id=DP-MVP-5002693) but I did not know if you could use that with PowerShell until I read [Kendra Little’s blog post from 2009](https://littlekendra.com/2009/12/02/sql-2008-agent-jobs-tokens-work-in-powershell/).

Thank you Kendra

Nothing is ever as easy as you think
------------------------------------

So I thought, this is awesome, I can create a function and pass in the Instance and the JobId and all will be golden.

Nope

job_id <> $(JobID)
------------------

If we look in the sysjobs table at the Agent Job that we want to notify Teams about the result.

![](https://blog.robsewell.com/assets/uploads/2020/07/image-12.png)

We can see that the job_id is

    dc5937c3-766f-47b7-a5a5-48365708659a

If we look at the JobId property with PowerShell

![](https://blog.robsewell.com/assets/uploads/2020/07/image-15.png?resize=630%2C369&ssl=1)

We get

    dc5937c3-766f-47b7-a5a5-48365708659a

Awesome, they are the same

But

If we look at the value of the $(JobID) SQL Agent Job Token,

![](https://blog.robsewell.com/assets/uploads/2020/07/image-14.png)

we get

    C33759DC6F76B747A5A548365708659A

which makes matching it to the JobId tricky

I tried all sorts of ways of casting and converting this value in SQL and PowerShell and in the end I just decided to manually convert the value

        $CharArray = $JobID.ToCharArray()
    
        $JobGUID = $CharArray[8] + $CharArray[9] + $CharArray[6] + $CharArray[7] + $CharArray[4] + $CharArray[5] + $CharArray[2] + $CharArray[3] + '-' + $CharArray[12] + $CharArray[13] + $CharArray[10] + $CharArray[11] + '-' + $CharArray[16] + $CharArray[17] + $CharArray[14] + $CharArray[15] + '-' + $CharArray[18] + $CharArray[19] + $CharArray[20] + $CharArray[21] + '-' + $CharArray[22] + $CharArray[23] + $CharArray[24] + $CharArray[25] + $CharArray[26] + $CharArray[27] + $CharArray[28] + $CharArray[29] + $CharArray[30] + $CharArray[31] + $CharArray[32] + $CharArray[33]
    

Send the information to Teams
-----------------------------

Following the [same pattern as yesterdays post](https://blog.robsewell.com/sending-a-sql-agent-job-results-overview-to-a-microsoft-teams-channel/), I created a function to send a message, depending on the outcome of the job and post it to the Teams function.  
  
Again, I used Enter-PsSession to run the Teams notification from a machine that can send the message. (I have also included the code to do this without requiring that below so that you can send the message from the same machine that runs the job if required)

This code below is saved on a UNC share or the SQL Server as SingleNotifyTeams.ps1

    Param(
        $SqlInstance,
        $JobID
    )
    
    $webhookurl = ""
    
    $NotifyServer = 'BeardNUC2'
    function Notify-TeamsSQlAgentJob {
        Param(
            $SQLInstance,
            $JobID,
            $webhookurl
        )
    
        $SQLInstance = $SQLInstance 
        # Import-Module 'C:\Program Files\WindowsPowerShell\Modules\dbatools\1.0.107\dbatools.psd1'
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
        $CharArray = $JobID.ToCharArray()
    
        $JobGUID = $CharArray[8] + $CharArray[9] + $CharArray[6] + $CharArray[7] + $CharArray[4] + $CharArray[5] + $CharArray[2] + $CharArray[3] + '-' + $CharArray[12] + $CharArray[13] + $CharArray[10] + $CharArray[11] + '-' + $CharArray[16] + $CharArray[17] + $CharArray[14] + $CharArray[15] + '-' + $CharArray[18] + $CharArray[19] + $CharArray[20] + $CharArray[21] + '-' + $CharArray[22] + $CharArray[23] + $CharArray[24] + $CharArray[25] + $CharArray[26] + $CharArray[27] + $CharArray[28] + $CharArray[29] + $CharArray[30] + $CharArray[31] + $CharArray[32] + $CharArray[33]
    
        $Job = Get-DbaAgentJob -SQlInstance $SQLInstance | Where jobid -eq $JobGuiD
        $JobName = $Job.Name
        $Jobsteps = Get-DbaAgentJobStep -SQlInstance $SQLInstance -Job $JobName
    
        $JobStepNames = $Jobsteps.Name -join ' , '
        $JobStartDate = $job.JobSteps[0].LastRunDate
        $JobStatus = $job.LastRunOutcome
        $lastjobstepid = $jobsteps[-1].id
        $Jobstepsmsg = $Jobsteps | Out-String
        $JobStepStatus = ($Jobsteps | Where-Object {$_.id -ne $lastjobstepid -and $_.LastRunDate -ge $JobStartDate} ).ForEach{
            "   $($_.Name)  - $($_.LastRunDate) **$($_.LastRunOutCome)**  
    "
        } 
        
        $Text = @"
    # **$SqlInstance**   
    ## **$JobName**  
    
    $jobstepMsg
    
    Started at $JobStartDate 
    - The individual Job Steps status was  
    
    $JobStepStatus  
    
    
    "@
    
        if (( $jobsteps | Where id -ne $lastjobstepid).LastRunOutcome -contains 'Failed') {
            $JSONBody = [PSCustomObject][Ordered]@{
                "@type"      = "MessageCard"
                "@context"   = "http://schema.org/extensions"
                "summary"    = "There was a Job Failure"
                "themeColor" = '0078D7'
                "sections"   = @(
                    @{
                        "activityTitle"    = "The Job Failed"
                        "activitySubtitle" = "Work to do - Please investigate the following job by following the steps in the plan at LINKTOPLAN"
                        "activityImage"    = "https://fit93a.db.files.1drv.com/y4mTOWSzX1AfIWx-VdUgY_Qp3wqebttT7FWSvtKK-zAbpTJuU560Qccv1_Z_Oxd4T4zUtd5oVZGJeS17fkgbl1dXUmvbldnGcoThL-bnQYxrTrMkrJS1Wz2ZRV5RVtZS9f4GleZQOMuWXP1HMYSjYxa6w09nEyGg1masI-wKIZfdnEF6L8r83Q9BB7yIjlp6OXEmccZt99gpb4Qti9sIFNxpg"
                        "text"             = $text
                        "markdown"         = $true
                    }
                )
            }
        }
        else {
            $JSONBody = [PSCustomObject][Ordered]@{
                "@type"      = "MessageCard"
                "@context"   = "http://schema.org/extensions"
                "summary"    = "The Job Succeeded"
                "themeColor" = '0078D7'
                "sections"   = @(
                    @{
                        "activityTitle"    = "The Job Succeeded"
                        "activitySubtitle" = "All is well - Please continue with the next step in the plan at LINKTOPLAN"
                        "activityImage"    = "https://6f0bzw.db.files.1drv.com/y4mvnTDG9bCgNWTZ-2_DFl4-ZsUwpD9QIHUArsGF66H69zBO8a--FlflXiF7lrL2H3vgya0ogXIDx59hn62wo2tt3HWMbqnnCSp8yPmM1IFNwZMzgvSZBEs_n9B0v4h4M5PfOY45GVSjeFh8md140gWHaFpZoL4Vwh-fD7Zi3djU_r0PduZwNBVGOcoB6SMJ1m4NmMmemWr2lzBn57LutDkxw"
                        "text"             = $text
                        "markdown"         = $true
                    }
                )
            }
        }
    
        $TeamMessageBody = ConvertTo-Json $JSONBody -Depth 100
     
        $NotifyCommand = {
        $parameters = @{
            "URI"         = $Using:webhookurl
            "Method"      = 'POST'
            "Body"        = $Using:TeamMessageBody
            "ContentType" = 'application/json'
        }
     
        Invoke-RestMethod @parameters
    }
        $Session = New-PSSession -ComputerName $NotifyServer
        Invoke-Command -Session $Session -ScriptBlock $NotifyCommand
    }
    
    $msg = 'ServerName  = ' + $SQLInstance + 'JobId = ' + $JobID
    Write-Host $msg
    Notify-TeamsSQLAgentJob -SQlInstance $SqlInstance -JobID $JobID -webhookurl $webhookurl
    

Then it can be called in a SQL Agent job step, again following the guidelines at [dbatools.io/agent](http://dbatools.io/agent)  
  
It is called slightly differently as you ned to pass in the SQL Agent tokens as parameters to the script

![](https://blog.robsewell.com/assets/uploads/2020/07/image-16.png)

    powershell.exe -File path to Notify-TeamsSQLAgentJob.ps1 -SQLInstance  $(ESCAPE_SQUOTE(SRVR)) -JobID  $(ESCAPE_NONE(JOBID))

SQL Agent Job Step Success and Failure
--------------------------------------

We need to take another step to ensure that this works as expected. We have to change the On Failure action for each job step to the “Go To Notify Teams” step

![](https://blog.robsewell.com/assets/uploads/2020/07/image-17.png)

Making people smile
-------------------

You can also add images (make sure the usage rights allow) so that the success notification can look like this

![](https://blog.robsewell.com/assets/uploads/2020/07/image-18.png)

and the failure looks like this

![](https://blog.robsewell.com/assets/uploads/2020/07/image-19.png)

Happy Automating !

Here is the code that does not require remoting to another server to send the message

    Param(
        $SqlInstance,
        $JobID
    )
    
    $webhookurl = "https://outlook.office.com/webhook/5a8057cd-5e1a-4c84-9227-74a309f1c738@b122247e-1ebf-4b52-b309-c2aa7436fc6b/IncomingWebhook/affb85f05804438eb7ffb57665879248/f32fc7e6-a998-4670-8b33-635876559b80"
    
    function Notify-TeamsSQlAgentJob {
        Param(
            $SQLInstance,
            $JobID,
            $webhookurl
        )
    
        $SQLInstance = $SQLInstance 
        # Import-Module 'C:\Program Files\WindowsPowerShell\Modules\dbatools\1.0.107\dbatools.psd1'
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
        $CharArray = $JobID.ToCharArray()
    
        $JobGUID = $CharArray[8] + $CharArray[9] + $CharArray[6] + $CharArray[7] + $CharArray[4] + $CharArray[5] + $CharArray[2] + $CharArray[3] + '-' + $CharArray[12] + $CharArray[13] + $CharArray[10] + $CharArray[11] + '-' + $CharArray[16] + $CharArray[17] + $CharArray[14] + $CharArray[15] + '-' + $CharArray[18] + $CharArray[19] + $CharArray[20] + $CharArray[21] + '-' + $CharArray[22] + $CharArray[23] + $CharArray[24] + $CharArray[25] + $CharArray[26] + $CharArray[27] + $CharArray[28] + $CharArray[29] + $CharArray[30] + $CharArray[31] + $CharArray[32] + $CharArray[33]
    
        $Job = Get-DbaAgentJob -SQlInstance $SQLInstance | Where jobid -eq $JobGuiD
        $JobName = $Job.Name
        $Jobsteps = Get-DbaAgentJobStep -SQlInstance $SQLInstance -Job $JobName
    
        $JobStepNames = $Jobsteps.Name -join ' , '
        $JobStartDate = $job.JobSteps[0].LastRunDate
        $JobStatus = $job.LastRunOutcome
        $lastjobstepid = $jobsteps[-1].id
        $Jobstepsmsg = $Jobsteps | Out-String
        $JobStepStatus = ($Jobsteps | Where-Object {$_.id -ne $lastjobstepid -and $_.LastRunDate -ge $JobStartDate} ).ForEach{
            "   $($_.Name)  - $($_.LastRunDate) **$($_.LastRunOutCome)**  
    "
        } 
        
        $Text = @"
    # **$SqlInstance**   
    ## **$JobName**  
    
    $jobstepMsg
    
    Started at $JobStartDate 
    - The individual Job Steps status was  
    
    $JobStepStatus  
    
    
    "@
    
        if (( $jobsteps | Where id -ne $lastjobstepid).LastRunOutcome -contains 'Failed') {
            $JSONBody = [PSCustomObject][Ordered]@{
                "@type"      = "MessageCard"
                "@context"   = "http://schema.org/extensions"
                "summary"    = "There was a Job Failure"
                "themeColor" = '0078D7'
                "sections"   = @(
                    @{
                        "activityTitle"    = "The Job Failed"
                        "activitySubtitle" = "Work to do - Please investigate the following job by following the steps in the plan at LINKTOPLAN"
                        "activityImage"    = "https://fit93a.db.files.1drv.com/y4mTOWSzX1AfIWx-VdUgY_Qp3wqebttT7FWSvtKK-zAbpTJuU560Qccv1_Z_Oxd4T4zUtd5oVZGJeS17fkgbl1dXUmvbldnGcoThL-bnQYxrTrMkrJS1Wz2ZRV5RVtZS9f4GleZQOMuWXP1HMYSjYxa6w09nEyGg1masI-wKIZfdnEF6L8r83Q9BB7yIjlp6OXEmccZt99gpb4Qti9sIFNxpg"
                        "text"             = $text
                        "markdown"         = $true
                    }
                )
            }
        }
        else {
            $JSONBody = [PSCustomObject][Ordered]@{
                "@type"      = "MessageCard"
                "@context"   = "http://schema.org/extensions"
                "summary"    = "The Job Succeeded"
                "themeColor" = '0078D7'
                "sections"   = @(
                    @{
                        "activityTitle"    = "The Job Succeeded"
                        "activitySubtitle" = "All is well - Please continue with the next step in the plan at LINKTOPLAN"
                        "activityImage"    = "https://6f0bzw.db.files.1drv.com/y4mvnTDG9bCgNWTZ-2_DFl4-ZsUwpD9QIHUArsGF66H69zBO8a--FlflXiF7lrL2H3vgya0ogXIDx59hn62wo2tt3HWMbqnnCSp8yPmM1IFNwZMzgvSZBEs_n9B0v4h4M5PfOY45GVSjeFh8md140gWHaFpZoL4Vwh-fD7Zi3djU_r0PduZwNBVGOcoB6SMJ1m4NmMmemWr2lzBn57LutDkxw"
                        "text"             = $text
                        "markdown"         = $true
                    }
                )
            }
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
    
    $msg = 'ServerName  = ' + $SQLInstance + 'JobId = ' + $JobID
    Write-Host $msg
    Notify-TeamsSQLAgentJob -SQlInstance $SqlInstance -JobID $JobID -webhookurl $webhookurl
