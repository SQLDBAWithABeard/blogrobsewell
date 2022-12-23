---
title: "Altering a Job Step on Hundreds of SQL Servers with PowerShell"
date: "2017-02-13" 
categories:
  - Blog
  - dbatools

tags:
  - automate
  - automation
  - backup
  - backups
  - PowerShell
  - script


image: https://dbatools.io/wp-content/uploads/2016/05/dbatools-logo-1.png

---
I flew to Utrecht last week to present with <A href="https://twitter.com/cl" target=_blank>Chrissy LeMaire</A> and <A href="https://twitter.com/SQLStad" target=_blank>Sander Stad</A> for the joint Dutch SQL and PowerShell User Groups. Whilst I was sat at the airport I got a phone call from my current client. 

> Them - We need to change the backup path for all of the servers to a different share, how long will it take you?
> 
> Me - About 5 minutes 

(PowerShell is very powerful – be careful when following these examples 😉 )


This code was run using PowerShell version 5 and will not work on Powershell version 3 or lower as it uses the where method.
Lets grab all of our jobs on the estate. (You will need to fill the $Servers variable with the names of your instances, maybe from a database or CMS or a text file)<PRE class="lang:ps decode:true">$Jobs = Get-SQLAgentJob -ServerInstance $Servers</PRE>
Once we have the jobs we need to iterate only through the ones we need to. This step could also have been done in the line above. Lets assume we are using the Ola Hallengren Solution to backup our estate<PRE class="lang:ps decode:true">Foreach($job in $Jobs.Where{$_.Name -like '*DatabaseBackup*' -and $_.isenabled -eq $true})</PRE>
Then because I have to target a specific job step I can iterate through those and filter in the same way<PRE class="lang:ps decode:true">foreach ($Step in $Job.jobsteps.Where{$_.Name -like '*DatabaseBackup*'})</PRE>
Now all I need to do is to replace C:\Backup with C:\MSSQL\Backup (in this example I am using my labs backup paths)<PRE class="lang:ps decode:true">$Step.Command = $Step.Command.Replace("Directory = N'C:\Backup'","Directory = N'C:\MSSQL\Backup'")</PRE>
And then call the Alter method<PRE class="lang:ps decode:true">$Step.Alter()</PRE>
And that is all there is to it. Here is the full script I used<PRE class="lang:ps decode:true">$Jobs = Get-SQLAgentJob -ServerInstance $Servers

Foreach($job in $Jobs.Where{$_.Name -like '*DatabaseBackup*' -and $_.isenabled -eq $true})
{
foreach ($Step in $Job.jobsteps.Where{$_.Name -like '*DatabaseBackup*'})
{
$Step.Command = $Step.Command.Replace("Directory = N'C:\Backup'","Directory = N'C:\MSSQL\Backup'")
$Step.Alter()
}
}</PRE>
In only a few minutes I had altered several hundred instances worth of Ola Hallengren Jobs 🙂
This is one of the many reasons I love PowerShell, it enables me to perform mass changes very quickly and easily. Of course, you need to make sure that you know that what you are changing is what you want to change. I have caused severe issues by altering the SQL alerts frequency to 1 second instead of one hour on an estate!! Although the beauty of PowerShell meant that I was able to change it very quickly once the problem was realised<BR>You can change a lot of settings. If you look at what is available at a job step level<BR><IMG class="alignnone size-full wp-image-3393" alt=job-step-properties src="https://blog.robsewell.com/assets/uploads/2017/02/job-step-properties.png?resize=630%2C314&amp;ssl=1" width=630 height=314 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/02/job-step-properties.png?fit=630%2C314&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/02/job-step-properties.png?fit=300%2C150&amp;ssl=1" data-image-description="" data-image-title="job-step-properties" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1492,744" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/02/job-step-properties.png?fit=1492%2C744&amp;ssl=1" data-permalink="https://blog.robsewell.com/altering-a-job-step-on-hundreds-of-sql-servers-with-powershell/job-step-properties/#main" data-attachment-id="3393"><BR>Happy Automating

