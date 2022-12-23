---
title: "Adding a PowerShell Job Step to an existing SQL Agent Job Step with PowerShell"
categories:
  - Blog

tags:
  - automate
  - automation
  - PowerShell
  - script
  - smo
  - snippet

---
<P><A href="https://blog.robsewell.com/adding-a-t-sql-job-step-to-a-sql-agent-job-with-powershell/">In my last post</A> I showed how to add a T-SQL Job step to an existing SQL Agent Job. The process is exactly the same for a PowerShell job step.</P>
<P>As before I gathered the required jobs using Get-SQLAgentJob command from the sqlserver module which you can get by installing the latest SSMS from <A href="https://sqlps.io/dl" target=_blank>https://sqlps.io/dl&nbsp;</A></P>
<P>This code was run on PowerShell version 5 and will not run on PowerShell version 3 or earlier as it uses the where method<BR>I put all of our jobs that I required&nbsp;on the estate into a variable called $Jobs. (You will need to fill the $Servers variable with the names of your instances, maybe from a database or CMS or a text file and of course you can add more logic to filter those servers as required.</P><PRE class="lang:ps decode:true">$Jobs = (Get-SQLAgentJob -ServerInstance $Servers).Where{$_.Name -like '*PartOfNameOfJob*' -and $_.IsEnabled -eq $true}</PRE>
<P>Of course to add a PowerShell Job step the target server needs to be SQL 2008 or higher. If you have an estate with older versions it is worth creating a <A href="https://msdn.microsoft.com/en-us/library/microsoft.sqlserver.management.smo.server.aspx" target=_blank>SMO server object</A> (<A href="https://github.com/SQLDBAWithABeard/Functions/blob/master/Snippets%20List.ps1" target=_blank>you can use a snippet)</A> and checking the version and then getting the jobs like this</P><PRE class="lang:ps decode:true">foreach($Server in $Servers)
{
 $srv = New-Object Microsoft.SqlServer.Management.Smo.Server $Server
 if($srv.VersionMajor -ge 10)
 {
    $Jobs = $srv.JobServer.Jobs</PRE>
<P>and you could choose to create a CmdExec Job step for earlier verions in an else code block.</P>
<P>Once I have the Jobs I can iterate through them with a foreach loop</P><PRE class="lang:ps decode:true">foreach($Job in $Jobs)</PRE>
<P>Then we need to create a new job step which is done with the following code</P><PRE class="lang:ps decode:true">$NewStep = New-Object Microsoft.SqlServer.Management.Smo.Agent.JobStep </PRE>
<P>To find out what is available for this object you can run</P><PRE class="lang:ps decode:true">$NewStep | Get-Member -MemberType Property</PRE>
<P><IMG class="alignnone wp-image-3393" alt=job-step-properties src="https://blog.robsewell.com/assets/uploads/2017/02/job-step-properties.png?resize=630%2C315&amp;ssl=1" width=630 height=315 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/02/job-step-properties.png?fit=630%2C314&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/02/job-step-properties.png?fit=300%2C150&amp;ssl=1" data-image-description="" data-image-title="job-step-properties" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1492,744" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/02/job-step-properties.png?fit=1492%2C744&amp;ssl=1" data-permalink="https://blog.robsewell.com/altering-a-job-step-on-hundreds-of-sql-servers-with-powershell/job-step-properties/#main" data-attachment-id="3393"></P>
<P>We need to set the name, the parent (The job), the command, the subsystem, the on fail action, on success action and the id for the job step.<BR>I set the command to a variable to make the code easier to read</P><PRE class="lang:ps decode:true">$Command = "Get-Process"</PRE>
<P>the rest of the properties I fill in inside the loop. To find out what the properties can hold I look at <A href="https://msdn.microsoft.com/en-us/library/microsoft.sqlserver.management.smo.agent.jobstep.aspx" target=_blank>MSDN for a Microsoft.SqlServer.Management.Smo.Agent.JobStep</A> &nbsp;The ID property is the number of the job step starting at 1 so this example will add a new job step that will be the first to run</P><PRE class="lang:ps decode:true">$Name = $Job.Name
$JobServer = $srv.JobServer
$Job = $JobServer.Jobs[$Name]
$NewStep = New-Object Microsoft.SqlServer.Management.Smo.Agent.JobStep
$NewStep.Name = 'a descriptive name for my PowerShell script'
$NewStep.Parent = $Job
$NewStep.Command = $Command
$NewStep.SubSystem = 'PowerShell'
$NewStep.OnFailAction = 'QuitWithFailure'
$NewStep.OnSuccessAction = 'GoToNextStep'
$NewStep.ID = 1</PRE>
<P>Once the object has all of the properties all we need to do is create it and alter the job</P><PRE class="lang:ps decode:true">$NewStep.create()
$Job.Alter() </PRE>
<P>and putting it all together it looks like this</P><PRE class="lang:ps decode:true">foreach($Server in $Servers)
{
    $srv = New-Object Microsoft.SqlServer.Management.Smo.Server $Server
    if($srv.VersionMajor -ge 10)
    {
       $Jobs = $srv.JobServer.Jobs.Where{$_.Name -like '*PartOfNameOfJob*' -and $_.IsEnabled -eq $true}
       foreach($Job in $Jobs)
       {
           $NewStep = New-Object Microsoft.SqlServer.Management.Smo.Agent.JobStep
           $NewStep.Name = 'a descriptive name for my PowerShell script'
           $NewStep.Parent = $Job
           $NewStep.Command = $Command
           $NewStep.SubSystem = 'PowerShell'
           $NewStep.OnFailAction = 'QuitWithFailure'
           $NewStep.OnSuccessAction = 'GoToNextStep'
           $NewStep.ID = 1
           $NewStep.create()
           $Job.Alter()
       }
    }

}</PRE>
<P>Happy Automating</P>

