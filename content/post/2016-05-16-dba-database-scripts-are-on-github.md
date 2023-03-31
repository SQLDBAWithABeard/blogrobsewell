---
title: "DBA Database scripts are on Github"
categories:
  - Blog

tags:
  - automate
  - automation
  - backup
  - backups
  - powershell
  - psconfeu
  - script
  - smo

header:
  teaser: assets/uploads/2016/05/tweets.png)](/assets/uploads/2016/05/tweets.png
---
It started with a tweet from Dusty

[![Tweets](/assets/uploads/2016/05/tweets.png)](/assets/uploads/2016/05/tweets.png)

The second session I presented at the fantastic [PowerShell Conference Europe](http://psconf.eu) was about using the DBA Database to automatically install DBA scripts like [sp_Blitz, sp_AskBrent, sp_Blitzindex from Brent Ozar](https://www.brentozar.com/first-aid/sql-server-downloads/) , [Ola Hallengrens Maintenance Solution](https://ola.hallengren.com/) , [Adam Mechanics sp_whoisactive](http://sqlblog.com/blogs/adam_machanic/archive/2012/03/22/released-who-is-active-v11-11.aspx) , [This fantastic script for logging the results from sp_whoisactive to a table](https://www.brentozar.com/responder/log-sp_whoisactive-to-a-table/) , Extended events sessions and other goodies for the sanity of the DBA.

By making use of the `dbo.InstanceList `in my DBA database I am able to target instances, by SQL Version, OS Version, Environment, Data Centre, System, Client or any other variable I choose. An agent job that runs every night will automatically pick up the instances and the scripts that are marked as needing installing. This is great when people release updates to the above scripts allowing you to target the development environment and test before they get put onto live.

I talked to a lot of people in Hannover and they all suggested that I placed the scripts onto GitHub and after some how-to instructions from a few people (Thank you Luke) I spent the weekend updating and cleaning up the code and you can now find it on [GitHub here](https://github.com/SQLDBAWithABeard/DBA-Database)

[![github](/assets/uploads/2016/05/github.png)](/assets/uploads/2016/05/github.png)

I have added the DBA Database project, the Powershell scripts and Agent Job creation scripts to call those scripts and everything else I use. Some of the DBA Scripts I use (and links to those you need to go and get yourself for licensing reasons) and the Power Bi files as well. I will be adding some more jobs that I use to gather other information soon.

Please go and have a look and see if it is of use to you. It is massively customisable and I have spoken to various people who have extended it in interesting ways so I look forward to hearing about what you do with it.

As always, questions and comments welcome
