---
title: "Changing Delay Between Responses for SQL Alerts with Powershell"
date: "2014-11-18" 
categories:
  - Blog

tags:
  - automate
  - automation
  - jonathan
  - PowerShell
  - smo
  - sql
  - SQL Alerts

---
So you have read that you should have alerts for severity levels 16 to 24 and 823,824 and 825 on [SQLSkills.com](http://www.sqlskills.com/blogs/glenn/the-accidental-dba-day-17-of-30-configuring-alerts-for-high-severity-problems/) or maybe you have used [sp_blitz](http://www.brentozar.com/blitz/) and received the [Blitz Result: No SQL Server Agent Alerts Configured](http://www.brentozar.com/blitz/configure-sql-server-alerts/) and like a good and conscientious DBA you have set them up.

Hopefully you also have [Jonathan Allens blog](https://www.simple-talk.com/blogs/author/13359-jonathan-allen/) on your feed and if you look at his historical posts and seen this one where [lack of a delay in response broke the Exchange Server!](https://www.simple-talk.com/blogs/2011/06/27/alerts-are-good-arent-they/)

However sometimes the oft used delay between responses of 1 minute is too much. Alerts should be actionable after all and maybe you sync your email every 15 minutes and don’t need to see 15 alerts for the same error or you decide that certain level of errors require a lesser response and therefore you only need to know about them every hour or three. Or possibly you want to enforce a certain delay for all servers and want to set up a system to check regularly and enforce your rule

Whatever the reason, changing the delay between response for every alert on every server with SSMS could be time consuming and (of course) I will use Powershell to do the job.

To find the alerts I follow the process I use when finding any new property in powershell

    $server = 'SERVERNAME'
    $srv = New-Object Microsoft.SqlServer.Management.Smo.Server $Server

I know that the Alerts will be found under the JobServer Property

    $srv.JobServer.Alerts|Get-Member

Shows me

> DelayBetweenResponses   Property   int DelayBetweenResponses {get;set;}

And

>  Alter                   Method     void Alter(), void IAlterable.Alter()

So I use both of those as follows

    Foreach($Alert in $srv.JobServer.Alerts){
        $Alert.DelayBetweenResponses = 600 # This is in seconds
        $Alert.Alter()
    }

And place it in a foreach loop for the servers I want to change. If I only want to change certain alerts I can do so by filtering on Name

    Foreach($Alert in $srv.JobServer.Alerts|Where-Object {$_.Name -eq 'NameOfAlert'})

Or by category

    Foreach($Alert in $srv.JobServer.Alerts|Where-Object {$_.CategoryName -eq 'Category Name'})

When you have 5 minutes go and look at the results of

    $srv.JobServer|Get-Member

And explore and let me know what you find
