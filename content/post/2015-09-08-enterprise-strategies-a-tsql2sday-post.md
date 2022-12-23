---
title: "Enterprise Strategies - A #TSQL2sDay post"
date: "2015-09-08"
date: "2015-09-08" 
categories: 
  - PowerShell
  - SQL Server
  - TSQL2sDAY
  - Community
tags: 
  - TSQL2sDAY
  - alerts
  - automate
  - automation
  - documentation
  - SQL Family
  - User Group
---

[![](images/TSQL2sDay150x150.jpg)](http://www.midnightdba.com/Jen/2015/09/time-for-t-sql-tuesday-70/)

This months TSQL2sDay blog post party is hosted by [Jen McCown](http://www.midnightdba.com/Jen/2015/09/time-for-t-sql-tuesday-70/) and is about Enterprise Strategy.

Adam Mechanic started [TSQL Tuesdays over 5 years ago](http://sqlblog.com/blogs/adam_machanic/archive/2009/11/30/invitation-to-participate-in-t-sql-tuesday-001-date-time-tricks.aspx) and you will find many brilliant posts under that heading if [you search for them](https://www.google.co.uk/#q=tsql2sday)

Managing SQL servers at enterprise scale is not a straightforward task. Your aim as a DBA should be to simplify it as much as possible and to automate everything that you possibly can. [This post by John Sansom](http://www.johnsansom.com/the-best-database-administrators-automate-everything/) could have been written for this months party and I recommend that you read it.

So here are a few points that I think you should consider if you look after SQL in an Enterprise environment.

- Enterprise Strategy will undoubtedly garner a whole host of excellent posts and Jen will provide a round up post which will I am certain will be an excellent resource. [Take a look here](http://www.midnightdba.com/Jen/2015/09/the-tsql2sday-70-roundup/)
- Know where your instances are and have a single place that you can reference them from. Some people recommend a [Central Management Server](https://msdn.microsoft.com/en-us/library/bb895144.aspx?f=255&MSPPError=-2147217396) but I find this too restrictive for my needs. I use an InstanceList table in my DBA Database with the following columns [ServerName], [InstanceName] , [Port] , [AG] , [Inactive] , [Environment] and [Location]. This enables me to target instances not just by name but by environment (Dev, Test, Pre-Prod, Live etc), by location or by joining the InstanceList table with another table I can target by the application or any number of other factors. I also capture information about the servers at windows and SQL level to this database so I can target the SQL 2012 servers specifically if need be or any other metric. This is very powerful and enables far greater flexibility than the CMS in my opinion.
- Use PowerShell (no surprise I would mention this!) PowerShell is a brilliant tool for automation and I use it all of the time
- Get used to using this piece of PowerShell code
```
	 $Query = @"
	 SELECT [ServerName],[InstanceName],[Port]
	  FROM [DBADatabase].[dbo].[InstanceList]
	  Where Inactive = 0 AND NotContactable = 0
	"@
	try{
	$AlltheServers= Invoke-Sqlcmd -ServerInstance $CentralDBAServer -Database $CentralDatabaseName -Query $query
	$ServerNames = $AlltheServers| Select ServerName,InstanceName,Port
	}
	foreach ($ServerName in $ServerNames)
	{
	## $ServerName
	 $InstanceName =  $ServerName|Select InstanceName -ExpandProperty InstanceName
	 $Port = $ServerName| Select Port -ExpandProperty Port
	$ServerName = $ServerName|Select ServerName -ExpandProperty ServerName 
	 $Connection = $ServerName + '\' + $InstanceName + ',' + $Port
	
	 try
	 {
	 $srv = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $Connection
```
Notice the query variable above, this is where the power lies as it enables you to gather all the instances that you need for your task as described in the bullet post above. Once you get used to doing this you can do things like this identify all the instances with Remote DAC disabled using a query against the DBA Database and then enable it on all servers by adding this code to the loop above
```
$srv.RemoteDacEnabled = $true
$srv.alter()
```
Very quick very simple and very very powerful. You can also use this to run TSQL scripts against the instances you target but there are some [added complications with Invoke-SQLCmd](https://www.bing.com/search?q=issues%20with%20invoke-sqlcmd&form=EDGEAR&qs=PF&cvid=bafe07c6afd54a6cb0ce7a1583300a79&pq=issues%20with%20invoke-sqlcmd&elv=AF!A!XC!KoOyC2FxnVd!deIwlgRcylR4EqUAG2rfVDNS) that you need to be aware of

- BE CAREFUL. Test and understand and test before you run any script on a live system especially using a script like this which enables you to target ALL of your servers. You must definitely check that your $ServerNames array contains only the instances you need before you make any changes. You need to be ultra-cautious when it is possible to do great damage
- Write scripts that are robust and handle errors gracefully. I use Jason Wasser @wasserja Write-Log function to write to a text file and wrap my commands in a try catch block.
- Include comments in your scripts to assist either the future you or the folks in your position in 5 years time. I would also add one of my bug bears - Use the description block in Agent Jobs. The first place any DBA is going to go to when that job fails is to open the properties of the job. Please fill in that block so that anyone troubleshooting knows some information about what the job does or at the very least a link to some documentation about it
- Finally in my list, don't overdo the alerts. Alerting is vital for any DBA it is a brilliant way to ensure that you quickly know about any issues affecting your estate but [all alerts should be actionable](http://thomaslarock.com/2012/02/the-minimalist-guide-to-database-administration/) and in some cases you can automate the action that you can take but the message here is don't send messages to the DBA team email for every single tiny thing or they will get swamped and ignore the vital one. This holds for whichever alerting or monitoring system that you use

This is but a small sub-section of things that you need to consider when responsible for a large SQL estate but if you need help and advice or just moral support and you don’t already interact with the SQL community then make today the day you start. Maybe [this post by Thomas La Rock](http://thomaslarock.com/sql-family/) is a good place to start or [your nearest User Group/Chapter](http://www.sqlpass.org/PASSChapters.aspx) or the [#sqlfamily hashtag](https://twitter.com/hashtag/sqlfamily) or give me a shout and I will gladly help.
