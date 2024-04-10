---
title: "Comparing Agent Jobs across Availability Group Replicas with PowerShell"
date: "2017-11-10"
categories:
  - Blog

tags:
  - PowerShell

---
On the plane home from PASS Summit I was sat next to someone who had also attended and when he saw on my laptop that I was part of the SQL Community we struck up a conversation. He asked me how he could compare SQL Agent Jobs across availability group replicas to ensure that they were the same.

He already knew that he could use [Copy-DbaAgentJob](https://dbatools.io/functions/copy-dbaagentjob/) from [dbatools](http://dbatools.io) to copy the jobs between replicas and we discussed how to set up an Agent job to accomplish this. The best way to run an Agent Job with a PowerShell script [is described here](https://dbatools.io/agent/)

Compare-Object
--------------

I told him about [Compare-Object](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/compare-object?view=powershell-5.1) a function available in PowerShell for precisely this task. Take these two SQL instances and their respective Agent Jobs

![agentjobcompare.png](https://blog.robsewell.com/assets/uploads/2017/11/agentjobcompare.png?resize=630%2C363&ssl=1)

So we can see that some jobs are the same and some are different. How can we quickly and easily spot the differences?

$Default = Get-DbaAgentJob -SqlInstance rob-xps
$bolton = Get-DbaAgentJob -SqlInstance rob-xps\\bolton
Compare-Object $Default $bolton

Those three lines of code will do it. The first two get the agent jobs from each instance and assign them to a variable and the last one compares them. This is the output

![comparison.png](https://blog.robsewell.com/assets/uploads/2017/11/comparison.png?resize=630%2C215&ssl=1)

The arrows show that the first three jobs are only on the Bolton instance and the bottom three jobs are only on the default instance.

What If ?
---------

 Another option I showed was to use the -WhatIf switch on Copy-DbaAgentJob. This parameter is available on all good PowerShell functions and will describe what the command _would do if run_ WARNING – If you are using the old SQLPS module from prior to the SSMS 2016 release -WhatIf will actually run the commands so update your modules.

We can run

Copy-DbaAgentJob -Source rob-xps -Destination rob-xps\\bolton -WhatIf

and get the following result

![](https://blog.robsewell.com/assets/uploads/2017/11/whatif.png?resize=630%2C197&ssl=1)

which shows us that there are two jobs on Rob-XPS which would be created on the Bolton instance

And if they have been modified?
-------------------------------

Thats good he said, but what about if the jobs have been modified?

Well one thing you could do is to compare the jobs DateLastModified property by using the -Property parameter and the passthru switch

$Default = Get-DbaAgentJob -SqlInstance rob-xps
$Dave = Get-DbaAgentJob -SqlInstance rob-xps\\dave
 
$Difference = Compare-Object $Default $dave -Property DateLastModified -PassThru
$Difference | Sort-Object Name | Select-Object OriginatingServer,Name,DateLastModified

This is going to return the jobs which are the same but were modified at a different time

![sortedjobcompare.png](https://blog.robsewell.com/assets/uploads/2017/11/sortedjobcompare.png?resize=630%2C153&ssl=1)

so that you can examine when they were changed. Of course the problem with that is that the DateLastModified is a very precise time so it is pretty much always going to be different. We can fix that but now it is a little more complex.

Just the Date please
--------------------

We need to gather the jobs in the same way but create an array of custom objects with a calculated property like this

$Dave = Get-DbaAgentJob -SqlInstance rob-xps\\dave
\## Create a custom object array with the date instead of the datetime
$DaveJobs = @()
$Dave.ForEach{
    $DaveJobs += \[pscustomobject\]@{
        Server = $_.OriginatingServer
        Name   = $_.Name
        Date   = $_.DateLastModified.Date
    }
}

and then we can compare on the Date field. The full code is

\## Get the Agent Jobs
$Default = Get-DbaAgentJob -SqlInstance rob-xps
$Dave = Get-DbaAgentJob -SqlInstance rob-xps\\dave
\## Create a custom object array with the date instead of the datetime
$DaveJobs = @()
$Dave.ForEach{
    $DaveJobs += \[pscustomobject\]@{
        Server = $_.OriginatingServer
        Name   = $_.Name
        Date   = $_.DateLastModified.Date
    }
}
\## Create a custom object array with the date instead of the datetime
$DefaultJobs = @()
$Default.ForEach{
    $DefaultJobs += \[pscustomobject\]@{
        Server = $_.OriginatingServer
        Name   = $_.Name
        Date   = $_.DateLastModified.Date
    }
}
\## Perform a comparison
$Difference = Compare-Object $DefaultJobs $DaveJobs -Property date -PassThru
\## Sort by name and display
$Difference | Sort-Object Name | Select-Object Server, Name, Date

This will look like this

![datecompare.png](https://blog.robsewell.com/assets/uploads/2017/11/datecompare.png?resize=630%2C200&ssl=1)

Which is much better and hopefully more useful but it only works with 2 instances

I have more than 2 instances
----------------------------

So if we have more than 2 instances it gets a little more complicated as Compare-Object only supports two arrays. I threw together a quick function to compare each instance with the main instance. This is very rough and will work for now but I have also created [a feature request issue on the dbatools repository](https://github.com/sqlcollaborative/dbatools/issues/2610) so someone (maybe you ?? ) could go and help create those commands

FunctionCompare-AgentJobs {
    Param(
        $SQLInstances
    )
    ## remove jobs* variables from process
    Get-Variable jobs*|Remove-Variable
    ## Get the number of instances
    $count = $SQLInstances.Count
    ## Loop through instances
    $SQLInstances.ForEach{
        # Get the jobs and assign to a new dynamic variable
        $Number = \[array\]::IndexOf($SQLInstances, $_)
        $Job = Get-DbaAgentJob-SqlInstance $_
        New-Variable-Name "Jobs$Number"-Value $Job
    }
    $i = $count - 1
    $Primary = $SQLInstances\[0\]
    While ($i -gt 0) {
        ## Compare the jobs with Primary
        $Compare = $SQLInstances\[$i\]
        Write-Output"Comparing $Primary with $Compare "
        Compare-Object(Get-Variable Jobs0).Value (Get-Variable"Jobs$i").Value
        $i --
    }
}

which looks like this. It’s not perfect but it will do for now until the proper commands are created

![compare agent jobs.png](https://blog.robsewell.com/assets/uploads/2017/11/compare-agent-jobs.png?resize=630%2C238&ssl=1)