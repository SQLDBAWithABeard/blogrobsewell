---
title: "Adding a T-SQL Job Step to a SQL Agent Job with PowerShell"
categories:
  - Blog

tags:
  - automate
  - automation
  - backups
  - PowerShell
  - script

---
<P><A href="https://blog.robsewell.com/altering-a-job-step-on-hundreds-of-sql-servers-with-powershell/" target=_blank>In my last post</A>, I explained how to alter an existing job step across many servers. I also had cause to add a T-SQL Job step to a large number of jobs as well. This is how I did it.<BR>As before I gathered the required jobs using Get-SQLAgentJob command from the sqlserver module which you can get by installing the latest SSMS from <A href="https://sqlps.io/dl" target=_blank>https://sqlps.io/dl&nbsp;</A></P>
<P>This code was run on PowerShell version 5 and will not run on PowerShell version 3 or earlier as it uses the where method<BR>I put all of our jobs that I required&nbsp;on the estate into a variable called $Jobs. (You will need to fill the $Servers variable with the names of your instances, maybe from a database or CMS or a text file</P><PRE class="lang:ps decode:true">$Jobs = (Get-SQLAgentJob -ServerInstance $Servers).Where{$_.Name -like '*PartOfNameOfJob*' -and $_.IsEnabled -eq $true}</PRE>
<P>Then I can iterate through them with a foreach loop</P><PRE class="lang:ps decode:true">foreach($Job in $Jobs)</PRE>
<P>Then we need to create a new job step which is done with the following code</P><PRE class="lang:ps decode:true">$NewStep = New-Object Microsoft.SqlServer.Management.Smo.Agent.JobStep </PRE>
<P>To find out what is available for this object you can run</P><PRE class="lang:ps decode:true">$NewStep | Get-Member -MemberType Property</PRE>
<P><IMG class="alignnone wp-image-3393" alt=job-step-properties src="https://blog.robsewell.com/assets/uploads/2017/02/job-step-properties.png?resize=630%2C315&amp;ssl=1" width=630 height=315 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/02/job-step-properties.png?fit=630%2C314&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/02/job-step-properties.png?fit=300%2C150&amp;ssl=1" data-image-description="" data-image-title="job-step-properties" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1492,744" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/02/job-step-properties.png?fit=1492%2C744&amp;ssl=1" data-permalink="https://blog.robsewell.com/altering-a-job-step-on-hundreds-of-sql-servers-with-powershell/job-step-properties/#main" data-attachment-id="3393"></P>
<P>We need to set the name, the parent (The job), the database, the command, the subsystem, the on fail action, on success action and the id for the job step.<BR>I set the command to a variable to make the code easier to read</P><PRE class="lang:ps decode:true">$Command = "SELECT Name from sys.databases"</PRE>
<P>the rest of the properties I fill in inside the loop. To find out what the properties can hold I look at <A href="https://msdn.microsoft.com/en-us/library/microsoft.sqlserver.management.smo.agent.jobstep.aspx?WT.mc_id=DP-MVP-5002693" target=_blank>MSDN for a Microsoft.SqlServer.Management.Smo.Agent.JobStep</A> &nbsp;The ID property is the number of the job step starting at 1 so this example will add a new job step that will be the first to run</P><PRE class="lang:ps decode:true">$NewStep = New-Object Microsoft.SqlServer.Management.Smo.Agent.JobStep
$NewStep.Name = 'A descriptive name for the job step'
$NewStep.Parent = $Job
$NewStep.DatabaseName = 'master'
$NewStep.Command = $Command
$NewStep.SubSystem = 'TransactSql'
$NewStep.OnFailAction = 'QuitWithFailure'
$NewStep.OnSuccessAction = 'GoToNextStep'
$NewStep.ID = 1</PRE>
<P>Once the object has all of the properties all we need to do is create it and alter the job</P><PRE class="lang:ps decode:true">$NewStep.create()
$Job.Alter() </PRE>
<P>and putting it all together it looks like this</P><PRE class="lang:ps decode:true">$Jobs = (Get-SQLAgentJob -ServerInstance $Servers).Where{$_.Name -like '*PartOfNameOfJob*' -and $_.IsEnabled -eq $true}
$Command = "Select name from sys.databases"
foreach($Job in $Jobs)
{
$NewStep = New-Object Microsoft.SqlServer.Management.Smo.Agent.JobStep
$NewStep.Name = 'A descriptive name for the job step1asdfsfasdfa'
$NewStep.Parent = $Job
$NewStep.DatabaseName = 'master'
$NewStep.Command = $Command
$NewStep.SubSystem = 'TransactSql'
$NewStep.OnFailAction = 'QuitWithFailure'
$NewStep.OnSuccessAction = 'GoToNextStep'
$NewStep.ID = 1
$NewStep.create()
$Job.Alter()
}
</PRE>
<P>Hopefully this will help you if you need to add a T-SQL Job Step to a large number of servers<BR>Happy Automating</P>

