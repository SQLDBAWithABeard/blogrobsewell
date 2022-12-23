---
title: "#tsql2sday #130 - Automate your stress away - Getting more SSIS Agent Job information"
slug: "tsql2sday 130 - Automate your stress away - Getting more SSIS Agent Job information"
date: "2020-09-08" 
categories:
  - Blog
  - TSql2sDay
  - Jupyter Notebooks
  - Azure Data Studio
  - PowerShell

tags:
  - automate
  - automation
  - PowerShell
  - SQL Server
  - SSIS
  - SQL Agent Jobs
  - TSql2sDay
  - Jupyter Notebooks


image: assets/images/TSQL2sDay150x150.jpg

---
# Automation
<P>T-SQL Tuesday was started by Adam Machanic (<A href="http://sqlblog.com/blogs/adam_machanic/">blog</A>|<A href="http://twitter.com/adammachanic">twitter</A>) is hosted by a different person each month. The host selects the theme, and then the blogging begins. worldwide, on the second Tuesday of the month (all day, based on GMT time), bloggers attend this party by blogging about the theme.  You can find more T-SQL Tuesday posts on twitter <A href="https://twitter.com/hashtag/tsql2sday" target=_blank>https://twitter.com/hashtag/tsql2sday</A>

This month it is hosted by Elizabeth Noble <A href="https://sqlzelda.wordpress.com/2020/09/01/t-sql-tuesday-130-automate-your-stress-away/" target=_blank>blog</A> and <A href="https://www.twitter.com/SQLZelda" target=_blank>twitter</A>. 

Thank you Elizabeth</P>

![tsql2sday](https://blog.robsewell.com/assets/images/TSQL2sDay150x150.jpg)

Elizabeth asks

> My invitation to you is I want to know what you have automated to make your life easier? 

## From the Past

I am in the process of migrating my blog to GitHub pages and whilst doing so, I read my first ever technical blog post [You have to start somewhere](https://blog.robsewell.com/blog/you-have-to-start-somewhere/) In it I mention this blog post by John Sansom [The Best Database Administrators Automate Everything](http://www.johnsansom.com/the-best-database-administrators-automate-everything/) which I am pleased to see is still available nearly a decade later

Here is a quote from his blog entry

> ## Automate Everything
> 
> That’s right, I said everything. Just sit back and take the _time_ to consider this point for a moment. Let it wander around your mind whilst you consider the processes and tasks that you could look to potentially automate. Now eliminate the word _potentially_ from your vocabulary and evaluate how you could automate **e-v-e-r-y-t-h-i-n-g** that you do.
> 
> Even if you believe that there is only a remote possibility that you will need to repeat a given task, just go ahead and automate it anyway! Chances are that when the need to repeat the process comes around again, you will either be under pressure to get it done, or even better have more important _Proactive Mode_ tasks/projects to be getting on with

##  I love Automation

I have tried my best at all times to follow this advice in the last decade and pretty much I am happy that I have managed it.

- I use PowerShell (a lot!) to automate all sorts of routine tasks including migrating this blog
- I use [Jupyter Notebooks](https://blog.robsewell.com/tags/#jupyter-notebooks) to enable myself and others to automate Run Books, Training, Documentation, Demonstrations, Incident Response. You can find my notebooks [here](https://beard.media/Notebooks)
- I use Azure DevOps to automate infrastructure creation and changes with terraform and delivery of changes to code as well as unit testing.
- I use GitHub actions to create this blog, publish the [ADSNotebook](https://www.powershellgallery.com/packages/ADSNotebook) module
- I use [Chocolatey](https://chocolatey.org/) to install and update software
- I have used Desired State Configuration to ensure that infrastructure is as it is expected to be

At every point I am looking for a means to automate the thing that I am doing because it is almost guaranteed that there will be a time in the future after you have done a thing that there will be a need to do it again or to do it slightly differently.

## Whats the last thing that you automated?

Following my blog post about [Notifying a Teams Channel about a SQL Agent Job result](https://blog.robsewell.com/blog/notifying-a-teams-channel-of-a-sql-agent-job-result/) I was asked if this could be tweaked to reduce the time spent getting information about SSIS Execution failures.

### Finding SSIS failures

When you run an SSIS package in an Agent Job and it fails, the Agent Job History shows something along these lines

>The job failed. The Job was invoked by User MyDomain\MyUserName. The last step to run was step 1 (scheduling ssis package).
> Executed as user: NT Service\SQLSERVERAGENT. Microsoft (R) SQL Server Execute Package Utility Version 11.0.5058.0 for 64-bit Copyright (C) Microsoft Corporation. All rights reserved. Started: 4:17:12 PM Package execution on IS Server failed. **Execution ID: 123456789**, Execution Status:4. To view the details for the execution, right-click on the Integration Services Catalog, and open the [All Executions] report Started: 4:17:12 PM Finished: 4:17:12 PM Elapsed: 4.493 seconds. The package execution failed. The step failed.

The next step is to open SSMS, go to the SSISDb and click through to the  SSIS reports and then scroll through to find the package and then the message. This is not particularly efficient and the SSIS reports are not known for their speedy executions!

This meant that the team member responsible for checking in the morning, could see which instance and which job had failed from the Teams message but then had to manually follow the above steps to find an error message that they could take action on.

### Automate it

In the SSISDB database there is an `event_messages` view so if I could query that and filter by the Execution ID then I could get the message and place it into the Teams message. Now the Teams message contains the error for the SSIS execution and each time this happens it probably saves the team member 4 or 5 minutes :-)

In the code below, I   

1. check if the failure comes from an SSIS instance  
    if($Inst -in ($SSISInstances)){ 
2. Get the Execution ID from the Error message  
    `$ExecutionId = [regex]::matches($BaseerrMessage, 'Execution ID: (\d{3,})').groups[1].value`    
3. Create a query for the SSISDB  

    `$SSISQuery = @"`  
    `SELECT * FROM catalog.event_messages em`  
    `WHERE em.operation_id = $ExecutionId`  
    `AND (em.event_name = 'OnError')`  
    `ORDER BY em.event_message_id;`  
    `"@`

4. Set the Error Message and the Execution Path to variables  
`$errMessage = $SSISQueryResults.Message`  
`$ExecutionPath = $SSISQueryResults.execution_path`  
5. Get the Error Message for none SSIS failures  
`}else{`  
`$errMessage = $j.group[-1].Message`  
`$ExecutionPath = 'the job'`  
`}`  
6. Create the Teams message

You will see that I used `SELECT *` because someone will always ask for some extra information in the future!

![](https://blog.robsewell.com/assets/images/happyrob.jpg)

The full script is below, Happy Automating!

    $webhookurl = "https://outlook.office.com/webhook/ the rest of it here" 
    $SSISInstances = # to identify SSIS instances
    $ProdInstances = # ALL instances for checking
    $startdate = (Get-Date).AddHours(-1)
    
    $AllFailedJobs = foreach ($Instance in $ProdInstances) {
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
        
        $jobs = $agentJobs # | Where-Object { $Psitem.Job -match     '^Beard-\d\d\d\d\d' -or  $Psitem.Job -like 'BeardJob*'  } # if you need to     filter
        $FailedJobs = $jobs | Where-Object { $Psitem.Status -ne 'Succeeded' }
        $FailedJobs | Group-Object Job 
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
    Write-Host "We have  $($AllFailedJobs.Count) Failed Jobs"
    
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true     }
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
    foreach ($j in $AllFailedJobs) {
     
    $Inst = $j.group[-1].SqlInstance
    $jName = $j.name
    $sname = $j.group[-1].StepName
    $edate = $j.group[-1].EndDate
    if($Inst -in ($SSISInstances)){
        $BaseerrMessage = $j.group[-1].Message
        $ExecutionId = [regex]::matches($BaseerrMessage, 'Execution ID: (\d{3,})').groups[1].value
    $SSISQuery = @"
    SELECT * FROM catalog.event_messages em 
    WHERE em.operation_id = $ExecutionId 
    AND (em.event_name = 'OnError')
    ORDER BY em.event_message_id;
    "@
    
    $SSISQueryResults = Invoke-DbaQuery -SqlInstance $Inst -Database SSISDB -Query $SSISQuery
    $errMessage = $SSISQueryResults.Message
    $ExecutionPath = $SSISQueryResults.execution_path
    }else{
        $errMessage = $j.group[-1].Message
        $ExecutionPath = 'the job'
    }
    
    $Text =  @"
    # **$Inst**   
    ## **$JName**  
    - The Job step that failed is - **$sname**  
    - It failed at - **$edate**  
    - It failed in $ExecutionPath with the message   
    - $errMessage   
    "@
    
    $JSONBody = [PSCustomObject][Ordered]@{
        "@type"      = "MessageCard"
        "@context"   = "http://schema.org/extensions"
        "summary"    = "There was a Job Failure"
        "themeColor" = '0078D7'
        "sections"   = @(
            @{
                "activityTitle"    = "Job Failures "
                "activitySubtitle" = "in the Last 1 hour"
                "activityImage"    = "https://blog.robsewell.com/assets/images/sobrob.jpg"
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
    }
    
    if(-not $AllFailedJobs){
      
            $JSONBody = [PSCustomObject][Ordered]@{
                "@type"      = "MessageCard"
                "@context"   = "http://schema.org/extensions"
                "summary"    = "There were no job failures in the last hour at $    (Get-Date)"
                "themeColor" = '0078D7'
                "sections"   = @(
                    @{
                        "activityTitle"    = "There were no job failures at $    (Get-Date)"
                        "activitySubtitle" = "in the Last hour"
                        "activityImage"    = "https://blog.robsewell.com/assets/images/happyrob.jpg"
                        "text"             = "All is well"
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
