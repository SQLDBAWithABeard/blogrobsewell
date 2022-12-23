---
title: "Comparing Agent Jobs across Availability Group Replicas with PowerShell"
categories:
  - Blog

tags:
  - PowerShell

---
<P>On the plane home from PAS Summit I was sat next to someone who had also attended and when he saw on my laptop that I was part of the SQL Community we struck up a conversation. He asked me how he could compare SQL Agent Jobs across availability group replicas to ensure that they were the same.</P>
<P>He already knew that he could use <A href="https://dbatools.io/functions/copy-dbaagentjob/" rel=noopener target=_blank>Copy-DbaAgentJob</A> from <A href="http://dbatools.io" rel=noopener target=_blank>dbatools</A> to copy the jobs between replicas and we discussed how to set up an Agent job to accomplish this. The best way to run an Agent Job with a PowerShell script&nbsp;<A href="https://dbatools.io/agent/" rel=noopener target=_blank>is described here</A></P>
<H2>Compare-Object</H2>
<P>I told him about <A href="https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/compare-object?view=powershell-5.1" rel=noopener target=_blank>Compare-Object</A> a function available in PowerShell for precisely this task. Take these two SQL instances and their respective Agent Jobs</P>
<P><IMG class="alignnone size-full wp-image-8608" alt=agentjobcompare.png src="https://blog.robsewell.com/assets/uploads/2017/11/agentjobcompare.png?resize=630%2C363&amp;ssl=1" width=630 height=363 sizes="(max-width: 630px) 100vw, 630px" data-recalc-dims="1" srcset="https://blog.robsewell.com/assets/uploads/2017/11/agentjobcompare.png?w=1120&amp;ssl=1 1120w,https://blog.robsewell.com/assets/uploads/2017/11/agentjobcompare.png?resize=300%2C173&amp;ssl=1 300w,https://blog.robsewell.com/assets/uploads/2017/11/agentjobcompare.png?resize=768%2C442&amp;ssl=1 768w,https://blog.robsewell.com/assets/uploads/2017/11/agentjobcompare.png?resize=1024%2C590&amp;ssl=1 1024w" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/11/agentjobcompare.png?fit=630%2C363&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/11/agentjobcompare.png?fit=300%2C173&amp;ssl=1" data-image-description="" data-image-title="agentjobcompare" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1120,645" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/11/agentjobcompare.png?fit=1120%2C645&amp;ssl=1" data-permalink="https://blog.robsewell.com/comparing-agent-jobs-across-availability-group-replicas-with-powershell/agentjobcompare/#main" data-attachment-id="8608"></P>
<P>So we can see that some jobs are the same and some are different. How can we quickly and easily spot the differences?</P>
<DIV><PRE class="lang:ps decode:true">$Default = Get-DbaAgentJob -SqlInstance rob-xps
$bolton = Get-DbaAgentJob -SqlInstance rob-xps\bolton
Compare-Object $Default $bolton</PRE></DIV>
<DIV>Those three lines of code will do it. The first two get the agent jobs from each instance and assign them to a variable and the last one compares them. This is the output</DIV>
<DIV></DIV>
<DIV><IMG class="alignnone size-full wp-image-8615" alt=comparison.png src="https://blog.robsewell.com/assets/uploads/2017/11/comparison.png?resize=630%2C215&amp;ssl=1" width=630 height=215 sizes="(max-width: 630px) 100vw, 630px" data-recalc-dims="1" srcset="https://blog.robsewell.com/assets/uploads/2017/11/comparison.png?w=1599&amp;ssl=1 1599w,https://blog.robsewell.com/assets/uploads/2017/11/comparison.png?resize=300%2C102&amp;ssl=1 300w,https://blog.robsewell.com/assets/uploads/2017/11/comparison.png?resize=768%2C262&amp;ssl=1 768w,https://blog.robsewell.com/assets/uploads/2017/11/comparison.png?resize=1024%2C350&amp;ssl=1 1024w,https://blog.robsewell.com/assets/uploads/2017/11/comparison.png?w=1260&amp;ssl=1 1260w" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/11/comparison.png?fit=630%2C215&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/11/comparison.png?fit=300%2C102&amp;ssl=1" data-image-description="" data-image-title="comparison" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1599,546" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/11/comparison.png?fit=1599%2C546&amp;ssl=1" data-permalink="https://blog.robsewell.com/comparing-agent-jobs-across-availability-group-replicas-with-powershell/comparison/#main" data-attachment-id="8615"></DIV>
<DIV></DIV>
<DIV>The arrows show that the first three jobs are only on the Bolton instance and the bottom three jobs are only on the default instance.</DIV>
<H2>What If ?</H2>
<DIV>&nbsp;Another option I showed was to use the -WhatIf switch on Copy-DbaAgentJob. This parameter is available on all good PowerShell functions and will describe what the command <EM>would do if run</EM> WARNING – If you are using the old SQLPS module from prior to the SSMS 2016 release -WhatIf will actually run the commands so update your modules.</DIV>
<DIV></DIV>
<DIV>We can run</DIV>
<DIV><PRE class="lang:ps decode:true ">Copy-DbaAgentJob -Source rob-xps -Destination rob-xps\bolton -WhatIf</PRE>
<P>and get the following result</P>
<P><IMG class="alignnone wp-image-8677" alt="" src="https://blog.robsewell.com/assets/uploads/2017/11/whatif.png?resize=630%2C197&amp;ssl=1" width=630 height=197 sizes="(max-width: 630px) 100vw, 630px" data-recalc-dims="1" srcset="https://blog.robsewell.com/assets/uploads/2017/11/whatif.png?resize=300%2C94&amp;ssl=1 300w,https://blog.robsewell.com/assets/uploads/2017/11/whatif.png?resize=768%2C240&amp;ssl=1 768w,https://blog.robsewell.com/assets/uploads/2017/11/whatif.png?resize=1024%2C320&amp;ssl=1 1024w,https://blog.robsewell.com/assets/uploads/2017/11/whatif.png?w=1260&amp;ssl=1 1260w,https://blog.robsewell.com/assets/uploads/2017/11/whatif.png?w=1890&amp;ssl=1 1890w" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/11/whatif.png?fit=630%2C197&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/11/whatif.png?fit=300%2C94&amp;ssl=1" data-image-description="" data-image-title="whatif" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="2806,876" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/11/whatif.png?fit=2806%2C876&amp;ssl=1" data-permalink="https://blog.robsewell.com/whatif/" data-attachment-id="8677"></P>
<P>which shows us that there are two jobs on Rob-XPS which would be created on the Bolton instance</P></DIV>
<H2>And if they have been modified?</H2>
<DIV>Thats good he said, but what about if the jobs have been modified?</DIV>
<DIV></DIV>
<DIV>Well one thing you could do is to compare the jobs DateLastModified property by using the -Property parameter and the passthru switch</DIV>
<DIV><PRE class="lang:ps decode:true">$Default = Get-DbaAgentJob -SqlInstance rob-xps
$Dave = Get-DbaAgentJob -SqlInstance rob-xps\dave
&nbsp;
$Difference = Compare-Object $Default $dave -Property DateLastModified -PassThru
$Difference | Sort-Object Name | Select-Object OriginatingServer,Name,DateLastModified</PRE></DIV>
<DIV>This is going to return the jobs which are the same but were modified at a different time</DIV>
<DIV></DIV>
<DIV><IMG class="alignnone size-full wp-image-8626" alt=sortedjobcompare.png src="https://blog.robsewell.com/assets/uploads/2017/11/sortedjobcompare.png?resize=630%2C153&amp;ssl=1" width=630 height=153 sizes="(max-width: 630px) 100vw, 630px" data-recalc-dims="1" srcset="https://blog.robsewell.com/assets/uploads/2017/11/sortedjobcompare.png?w=2214&amp;ssl=1 2214w,https://blog.robsewell.com/assets/uploads/2017/11/sortedjobcompare.png?resize=300%2C73&amp;ssl=1 300w,https://blog.robsewell.com/assets/uploads/2017/11/sortedjobcompare.png?resize=768%2C187&amp;ssl=1 768w,https://blog.robsewell.com/assets/uploads/2017/11/sortedjobcompare.png?resize=1024%2C249&amp;ssl=1 1024w,https://blog.robsewell.com/assets/uploads/2017/11/sortedjobcompare.png?w=1260&amp;ssl=1 1260w,https://blog.robsewell.com/assets/uploads/2017/11/sortedjobcompare.png?w=1890&amp;ssl=1 1890w" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/11/sortedjobcompare.png?fit=630%2C153&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/11/sortedjobcompare.png?fit=300%2C73&amp;ssl=1" data-image-description="" data-image-title="sortedjobcompare" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="2214,538" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/11/sortedjobcompare.png?fit=2214%2C538&amp;ssl=1" data-permalink="https://blog.robsewell.com/comparing-agent-jobs-across-availability-group-replicas-with-powershell/sortedjobcompare/#main" data-attachment-id="8626"></DIV>
<DIV></DIV>
<DIV>so that you can examine when they were changed. Of course the problem with that is that the DateLastModified is a very precise time so it is pretty much always going to be different. We can fix that but now it is a little more complex.</DIV>
<H2>Just the Date please</H2>
<DIV>We need to gather the jobs in the same way but create an array of custom objects with a calculated property like this</DIV>
<DIV>
<DIV><PRE class="lang:ps decode:true">$Dave = Get-DbaAgentJob -SqlInstance rob-xps\dave
## Create a custom object array with the date instead of the datetime
$DaveJobs = @()
$Dave.ForEach{
    $DaveJobs += [pscustomobject]@{
        Server = $_.OriginatingServer
        Name   = $_.Name
        Date   = $_.DateLastModified.Date
    }
}</PRE></DIV>
<DIV>and then we can compare on the Date field. The full code is</DIV></DIV>
<DIV>
<DIV><PRE class="lang:ps decode:true">## Get the Agent Jobs
$Default = Get-DbaAgentJob -SqlInstance rob-xps
$Dave = Get-DbaAgentJob -SqlInstance rob-xps\dave
## Create a custom object array with the date instead of the datetime
$DaveJobs = @()
$Dave.ForEach{
    $DaveJobs += [pscustomobject]@{
        Server = $_.OriginatingServer
        Name   = $_.Name
        Date   = $_.DateLastModified.Date
    }
}
## Create a custom object array with the date instead of the datetime
$DefaultJobs = @()
$Default.ForEach{
    $DefaultJobs += [pscustomobject]@{
        Server = $_.OriginatingServer
        Name   = $_.Name
        Date   = $_.DateLastModified.Date
    }
}
## Perform a comparison
$Difference = Compare-Object $DefaultJobs $DaveJobs -Property date -PassThru
## Sort by name and display
$Difference | Sort-Object Name | Select-Object Server, Name, Date</PRE></DIV>
<P>This will look like this</P></DIV>
<DIV><IMG class="alignnone size-full wp-image-8642" alt=datecompare.png src="https://blog.robsewell.com/assets/uploads/2017/11/datecompare.png?resize=630%2C200&amp;ssl=1" width=630 height=200 sizes="(max-width: 630px) 100vw, 630px" data-recalc-dims="1" srcset="https://blog.robsewell.com/assets/uploads/2017/11/datecompare.png?w=2093&amp;ssl=1 2093w,https://blog.robsewell.com/assets/uploads/2017/11/datecompare.png?resize=300%2C95&amp;ssl=1 300w,https://blog.robsewell.com/assets/uploads/2017/11/datecompare.png?resize=768%2C244&amp;ssl=1 768w,https://blog.robsewell.com/assets/uploads/2017/11/datecompare.png?resize=1024%2C325&amp;ssl=1 1024w,https://blog.robsewell.com/assets/uploads/2017/11/datecompare.png?w=1260&amp;ssl=1 1260w,https://blog.robsewell.com/assets/uploads/2017/11/datecompare.png?w=1890&amp;ssl=1 1890w" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/11/datecompare.png?fit=630%2C200&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/11/datecompare.png?fit=300%2C95&amp;ssl=1" data-image-description="" data-image-title="datecompare" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="2093,665" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/11/datecompare.png?fit=2093%2C665&amp;ssl=1" data-permalink="https://blog.robsewell.com/comparing-agent-jobs-across-availability-group-replicas-with-powershell/datecompare/#main" data-attachment-id="8642"></DIV>
<DIV></DIV>
<DIV>Which is much better and hopefully more useful but it only works with 2 instances</DIV>
<H2>I have more than 2 instances</H2>
<P>So if we have more than 2 instances it gets a little more complicated as Compare-Object only supports two arrays. I threw together a quick function to compare each instance with the main instance. This is very rough and will work for now but I have also created <A href="https://github.com/sqlcollaborative/dbatools/issues/2610" rel=noopener target=_blank>a feature request issue on the dbatools repository</A> so someone (maybe you ?? ) could go and help create those commands</P>
<DIV><PRE class="lang:ps decode:true">FunctionCompare-AgentJobs {
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
        $Number = [array]::IndexOf($SQLInstances, $_)
        $Job = Get-DbaAgentJob-SqlInstance $_
        New-Variable-Name "Jobs$Number"-Value $Job
    }
    $i = $count - 1
    $Primary = $SQLInstances[0]
    While ($i -gt 0) {
        ## Compare the jobs with Primary
        $Compare = $SQLInstances[$i]
        Write-Output"Comparing $Primary with $Compare "
        Compare-Object(Get-Variable Jobs0).Value (Get-Variable"Jobs$i").Value
        $i --
    }
}</PRE></DIV>
<DIV>which looks like this. It’s not perfect but it will do for now until the proper commands are created</DIV>
<P><IMG class="alignnone size-full wp-image-8672" alt="compare agent jobs.png" src="https://blog.robsewell.com/assets/uploads/2017/11/compare-agent-jobs.png?resize=630%2C238&amp;ssl=1" width=630 height=238 sizes="(max-width: 630px) 100vw, 630px" data-recalc-dims="1" srcset="https://blog.robsewell.com/assets/uploads/2017/11/compare-agent-jobs.png?w=1987&amp;ssl=1 1987w,https://blog.robsewell.com/assets/uploads/2017/11/compare-agent-jobs.png?resize=300%2C113&amp;ssl=1 300w,https://blog.robsewell.com/assets/uploads/2017/11/compare-agent-jobs.png?resize=768%2C290&amp;ssl=1 768w,https://blog.robsewell.com/assets/uploads/2017/11/compare-agent-jobs.png?resize=1024%2C387&amp;ssl=1 1024w,https://blog.robsewell.com/assets/uploads/2017/11/compare-agent-jobs.png?w=1260&amp;ssl=1 1260w,https://blog.robsewell.com/assets/uploads/2017/11/compare-agent-jobs.png?w=1890&amp;ssl=1 1890w" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/11/compare-agent-jobs.png?fit=630%2C238&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/11/compare-agent-jobs.png?fit=300%2C113&amp;ssl=1" data-image-description="" data-image-title="compare agent jobs" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1987,751" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/11/compare-agent-jobs.png?fit=1987%2C751&amp;ssl=1" data-permalink="https://blog.robsewell.com/comparing-agent-jobs-across-availability-group-replicas-with-powershell/compare-agent-jobs/#main" data-attachment-id="8672"></P>

