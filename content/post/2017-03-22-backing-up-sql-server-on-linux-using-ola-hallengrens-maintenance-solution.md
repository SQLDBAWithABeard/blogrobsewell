---
title: "Backing up SQL Server on Linux using Ola Hallengrens Maintenance Solution"
date: "2017-03-22" 
categories:
  - Blog

tags:
  - backup
  - backups
  - linux
  - PowerShell
  - sql

---
<P>With <A href="https://blogs.technet.microsoft.com/dataplatforminsider/2017/03/17/sql-server-next-version-ctp-1-4-now-available/" rel=noopener target=_blank>the release of SQL Server vNext CTP 1.4 </A>SQL Agent was released for use on Linux. To install it on Ubuntu you need to upgrade your SQL Server to CTP 1.4. On Ubuntu you do this with</P><PRE class="lang:sh decode:true">sudo apt-get update
sudo apt-get install mssql-server</PRE>
<P>Once you have CTP 1.4 you can install SQL Agent as follows</P><PRE class="lang:sh decode:true">sudo apt-get update
sudo apt-get install mssql-server-agent
sudo systemctl restart mssql-server</PRE>
<P>for different flavours of Linux <A href="https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-setup-sql-agent" rel=noopener target=_blank>follow the steps here</A></P>
<P>Once you have done that you will see that the Agent is now available</P>
<P><IMG class="alignnone size-full wp-image-4183" alt="01 - SSMS Agent Linux.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/01-ssms-agent-linux.png?resize=336%2C574&amp;ssl=1" width=336 height=574 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/01-ssms-agent-linux.png?fit=336%2C574&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/01-ssms-agent-linux.png?fit=176%2C300&amp;ssl=1" data-image-description="" data-image-title="01 – SSMS Agent Linux" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="336,574" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/01-ssms-agent-linux.png?fit=336%2C574&amp;ssl=1" data-permalink="https://blog.robsewell.com/backing-up-sql-server-on-linux-using-ola-hallengrens-maintenance-solution/01-ssms-agent-linux/#main" data-attachment-id="4183"></P>
<P>So now I can schedule backups and maintenance for my Linux SQL databases using the agent. I immediately turned to <A href="https://ola.hallengren.com/" rel=noopener target=_blank>Ola Hallengrens Maintenance Solution</A> I downloaded the SQL file and ran it against my Linux server once I had changed the path for the backups to a directory I had created at /var/opt/mssql/backups&nbsp;notice that it is specified using Windows notation with C:\ at the root</P><PRE class="theme:classic lang:tsql decode:true">SET @CreateJobs= 'Y' -- Specify whether jobs should be created. 
SET @BackupDirectory = N'C:\var\opt\mssql\backups' -- Specify the backup root directory. 
SET @CleanupTime = 350 -- Time in hours, after which backup files are deleted. If no time is specified, then no backup files are deleted. 
SET @OutputFileDirectory = NULL -- Specify the output file directory. If no directory is specified, then the SQL Server error log directory is used. 
SET @LogToTable = 'Y' -- Log commands to a table.</PRE>
<P>The stored procedures were created</P>
<P><IMG class="alignnone size-full wp-image-4200" alt="03 - stored procedures" src="https://blog.robsewell.com/assets/uploads/2017/03/03-stored-procedures.png?resize=342%2C263&amp;ssl=1" width=342 height=263 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/03-stored-procedures.png?fit=342%2C263&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/03-stored-procedures.png?fit=300%2C231&amp;ssl=1" data-image-description="" data-image-title="03 – stored procedures" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="342,263" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/03-stored-procedures.png?fit=342%2C263&amp;ssl=1" data-permalink="https://blog.robsewell.com/backing-up-sql-server-on-linux-using-ola-hallengrens-maintenance-solution/03-stored-procedures/#main" data-attachment-id="4200"></P>
<P>and&nbsp;the jobs were created</P>
<P><IMG class="alignnone size-full wp-image-4201" alt="04 - jobs.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/04-jobs.png?resize=376%2C399&amp;ssl=1" width=376 height=399 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/04-jobs.png?fit=376%2C399&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/04-jobs.png?fit=283%2C300&amp;ssl=1" data-image-description="" data-image-title="04 – jobs" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="376,399" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/04-jobs.png?fit=376%2C399&amp;ssl=1" data-permalink="https://blog.robsewell.com/backing-up-sql-server-on-linux-using-ola-hallengrens-maintenance-solution/04-jobs/#main" data-attachment-id="4201"></P>
<P>Now the jobs are not going to run as they are as they&nbsp;have CmdExec steps and this is not supported in SQL on Linux so we have to make some changes to the steps. As I <A href="https://blog.robsewell.com/altering-a-job-step-on-hundreds-of-sql-servers-with-powershell/">blogged previously</A>, this is really easy&nbsp;using PowerShell</P>
<P>First we need to grab the jobs into a variable. We will use <A href="https://docs.microsoft.com/en-us/powershell/sqlserver/sqlserver-module/vlatest/get-sqlagentjobhistory" rel=noopener target=_blank>Get-SQLAgentJobHistory</A> from the sqlserver module which you need to download SSMS 2016 or later to get. You can get it from <A href="https://sqlps.io/dl" rel=noopener target=_blank>https://sqlps.io/dl</A> As&nbsp;we are targeting a&nbsp;Linux SQL Server&nbsp;we will use SQL authentication which we will provide via <A href="https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.security/get-credential" rel=noopener target=_blank>Get-Credential</A> and then take a look at the jobs</P>
<DIV>
<DIV><PRE class="lang:ps decode:true">Import-Module sqlserver
$cred = Get-Credential
$Jobs = Get-SqlAgentJob -ServerInstance LinuxvVNext -Credential $cred
$jobs |ft -auto</PRE></DIV></DIV>
<DIV><IMG class="alignnone size-full wp-image-4218" alt="05 Powershell jobs.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/05-powershell-jobs.png?resize=630%2C202&amp;ssl=1" width=630 height=202 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/05-powershell-jobs.png?fit=630%2C202&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/05-powershell-jobs.png?fit=300%2C96&amp;ssl=1" data-image-description="" data-image-title="05 Powershell jobs" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1208,388" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/05-powershell-jobs.png?fit=1208%2C388&amp;ssl=1" data-permalink="https://blog.robsewell.com/backing-up-sql-server-on-linux-using-ola-hallengrens-maintenance-solution/05-powershell-jobs/#main" data-attachment-id="4218"></DIV>
<P>Once&nbsp;the jobs were in&nbsp;the variable&nbsp;I decided to filter out only the jobs that are calling the stored procedures to perform the backups, DBCC and Index optimisation and loop through them first. Backups are the most important after all</P><PRE class="lang:ps decode:true">## Find the jobs we want to change foreach($Job in $jobs.Where{$_.Name -like '*DATABASES*'})</PRE>
<P>Then it is simply a case of replacing the sqlcmd text in the command to return it to T-SQL, adding the database name (I installed Ola’s stored procedures into the master database and changing the subsystem to use T-SQL instead of CmdExec</P>
<DIV>
<DIV>
<DIV><PRE class="lang:ps decode:true">## replace the text as required
$job.jobsteps[0].command = $job.jobsteps[0].command.Replace('sqlcmd -E -S $(ESCAPE_SQUOTE(SRVR)) -d master -Q "' , '').Replace('" -b','')
## Change the subsystem
$job.jobsteps[0].subsystem = 'TransactSQL'
## Add the databasename
$job.jobsteps[0].DatabaseName = 'master'
## Alter the jobstep
$job.jobsteps[0].Alter()</PRE></DIV></DIV></DIV>
<P>We can check that it has done this using PowerShell</P>
<DIV>
<DIV>
<DIV><PRE class="lang:ps decode:true">$Jobs = Get-SqlAgentJob -ServerInstance LinuxvVNext -Credential $cred
foreach ($Job in $jobs.Where{$_.Name -like '*DATABASES*'}) {
    foreach ($step in $Job.JobSteps) {
        $step | Select Parent, Name, Command, DatabaseName, Subsystem
    }
}</PRE></DIV></DIV></DIV>
<DIV><IMG class="alignnone size-full wp-image-4234" alt="06 - Jobs changed.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/06-jobs-changed.png?resize=630%2C426&amp;ssl=1" width=630 height=426 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/06-jobs-changed.png?fit=630%2C426&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/06-jobs-changed.png?fit=300%2C203&amp;ssl=1" data-image-description="" data-image-title="06 – Jobs changed" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1236,835" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/06-jobs-changed.png?fit=1236%2C835&amp;ssl=1" data-permalink="https://blog.robsewell.com/backing-up-sql-server-on-linux-using-ola-hallengrens-maintenance-solution/06-jobs-changed/#main" data-attachment-id="4234"></DIV>
<DIV></DIV>
<P>or by looking in SSMS if you prefer</P>
<DIV></DIV>
<DIV><IMG class="alignnone size-full wp-image-4238" alt="07 - jobs changed ssms.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/07-jobs-changed-ssms.png?resize=630%2C402&amp;ssl=1" width=630 height=402 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/07-jobs-changed-ssms.png?fit=630%2C402&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/07-jobs-changed-ssms.png?fit=300%2C191&amp;ssl=1" data-image-description="" data-image-title="07 – jobs changed ssms" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1079,688" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/07-jobs-changed-ssms.png?fit=1079%2C688&amp;ssl=1" data-permalink="https://blog.robsewell.com/backing-up-sql-server-on-linux-using-ola-hallengrens-maintenance-solution/07-jobs-changed-ssms/#main" data-attachment-id="4238"></DIV>
<DIV></DIV>
<P>Now lets run the jobs and check the history using <A href="https://docs.microsoft.com/en-us/powershell/sqlserver/sqlserver-module/vlatest/get-sqlagentjobhistory" rel=noopener target=_blank>Get-SqlAgentJobHistory</A></P>
<DIV><PRE class="lang:ps decode:true">Get-SqlAgentJobHistory -ServerInstance linuxvnextctp14 -Credential $cred | select RunDate,StepID,Server,JobName,StepName,Message|Out-GridView</PRE></DIV>
<DIV></DIV>
<DIV><IMG class="alignnone size-full wp-image-4247" alt="08 - ogv for jobs.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/08-ogv-for-jobs.png?resize=630%2C204&amp;ssl=1" width=630 height=204 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/08-ogv-for-jobs.png?fit=630%2C204&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/08-ogv-for-jobs.png?fit=300%2C97&amp;ssl=1" data-image-description="" data-image-title="08 – ogv for jobs" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1651,535" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/08-ogv-for-jobs.png?fit=1651%2C535&amp;ssl=1" data-permalink="https://blog.robsewell.com/backing-up-sql-server-on-linux-using-ola-hallengrens-maintenance-solution/08-ogv-for-jobs/#main" data-attachment-id="4247"></DIV>
<DIV></DIV>
<P>Which pretty much matches what you see in SSMS</P>
<DIV></DIV>
<DIV><IMG class="alignnone size-full wp-image-4249" alt="09 - ssms jobs view.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/09-ssms-jobs-view.png?resize=630%2C297&amp;ssl=1" width=630 height=297 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/09-ssms-jobs-view.png?fit=630%2C297&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/09-ssms-jobs-view.png?fit=300%2C141&amp;ssl=1" data-image-description="" data-image-title="09 – ssms jobs view" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1452,684" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/09-ssms-jobs-view.png?fit=1452%2C684&amp;ssl=1" data-permalink="https://blog.robsewell.com/backing-up-sql-server-on-linux-using-ola-hallengrens-maintenance-solution/09-ssms-jobs-view/#main" data-attachment-id="4249"></DIV>
<DIV></DIV>
<P>and if you look in the directory you see the files exactly as you would expect them to be</P>
<DIV></DIV>
<DIV><IMG class="alignnone size-full wp-image-4252" alt="10 - Files in Linux" src="https://blog.robsewell.com/assets/uploads/2017/03/10-files-in-linux.png?resize=630%2C500&amp;ssl=1" width=630 height=500 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/10-files-in-linux.png?fit=630%2C500&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/10-files-in-linux.png?fit=300%2C238&amp;ssl=1" data-image-description="" data-image-title="10 – Files in Linux" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="928,737" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/10-files-in-linux.png?fit=928%2C737&amp;ssl=1" data-permalink="https://blog.robsewell.com/backing-up-sql-server-on-linux-using-ola-hallengrens-maintenance-solution/10-files-in-linux/#main" data-attachment-id="4252"></DIV>
<DIV></DIV>
<P>We still need to change the other jobs that Ola’s script create. If we look at the command steps</P>
<P>&nbsp;</P>
<DIV><IMG class="alignnone size-full wp-image-4271" alt="11 - job comands.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/11-job-comands.png?resize=630%2C361&amp;ssl=1" width=630 height=361 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/11-job-comands.png?fit=630%2C361&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/11-job-comands.png?fit=300%2C172&amp;ssl=1" data-image-description="" data-image-title="11 – job comands" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1164,667" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/11-job-comands.png?fit=1164%2C667&amp;ssl=1" data-permalink="https://blog.robsewell.com/backing-up-sql-server-on-linux-using-ola-hallengrens-maintenance-solution/11-job-comands/#main" data-attachment-id="4271"></DIV>
<DIV></DIV>
<P>We can see that the CommandLog Cleanup job can use the same PowerShell code as the backup jobs, the sp_delete_backuphistory and sp_purgejobhistory jobs need to refer to the msdb database instead of master. For the moment the Output File Cleanup job is the one that is not able to be run on Linux. Hopefully soon we will be able to run PowerShell job steps and that will be resolved as well</P>
<P>Here is the full snippet of code to change all of the jobs</P>
<DIV>
<DIV>
<DIV><PRE class="lang:ps decode:true ">$server = 'Linuxvnextctp14'
$cred = Get-Credential
$Jobs = Get-SqlAgentJob -ServerInstance $server -Credential $cred
## Find the jobs we want to change
foreach ($Job in $jobs) {
    if ($Job.Name -like '*DATABASES*' -or $Job.Name -like '*CommandLog*') {
        ## replace the text as required
        $job.jobsteps[0].command = $job.jobsteps[0].command.Replace('sqlcmd -E -S $(ESCAPE_SQUOTE(SRVR)) -d master -Q "' , '').Replace('" -b', '')
        ## Change the subsystem
        $job.jobsteps[0].subsystem = 'TransactSQL'
        ## Add the databasename
        $job.jobsteps[0].DatabaseName = 'master'
        ## Alter the jobstep
        $job.jobsteps[0].Alter()
    }
    if ($Job.Name -like '*history*') {
        ## replace the text as required
        $job.jobsteps[0].command = $job.jobsteps[0].command.Replace('sqlcmd -E -S $(ESCAPE_SQUOTE(SRVR)) -d msdb -Q "' , '').Replace('" -b', '')
        ## Change the subsystem
        $job.jobsteps[0].subsystem = 'TransactSQL'
        ## Add the databasename
        $job.jobsteps[0].DatabaseName = 'msdb'
        ## Alter the jobstep
        $job.jobsteps[0].Alter()
    }
}</PRE>
<DIV>&nbsp;Happy Automating</DIV></DIV></DIV></DIV>

