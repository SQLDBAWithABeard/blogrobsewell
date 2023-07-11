---
title: "#TSQL2sDay Why My Head is Always in The Cloud"
slug: "TSQL2sDay Why My Head is Always in The Cloud"
date: "2013-11-10"
categories:
  - Blog

tags:
  - TSql2sDay
  - azure
  - PowerShell
  - SQLBits
  - giving back

---
[![](https://i1.wp.com/www.sqlchicken.com/wp-content/uploads/2013/11/20121003200545_thumb.jpg?resize=175%2C175)](http://www.sqlchicken.com/2013/11/t-sql-tuesday-48-cloud-atlas/)

Todays post is my first for the TSQL2sDay series. For those not familiar this is rotating blog party that was started by Adam Machanic [(@AdamMachanic](http://twitter.com/adammachanic) [blog](http://sqlblog.com/blogs/adam_machanic/)) back in 2009. If you want to catch up on all the fun to date check out this nice archive ([link](http://t.co/g3tzA9nP27)) put together by Steve Jones [(@way0utwest](http://twitter.com/way0utwest) [blog](http://voiceofthedba.com/)). Thank you Steve!!!

[![Azure Ballon - Credit http://owenrichardson.com/](https://owenrichardson.files.wordpress.com/2011/07/wpid-photo-jul-7-2011-1738.jpg?w=432&h=650&resize=207%2C310 "Azure Ballon - Credit http://owenrichardson.com/")](http://owenrichardson.com/2011/07/07/cloud-computing/)

This one is hosted by Jorge Segarra [@SQLChicken:](https://twitter.com/SQLChicken)  [who said](http://www.sqlchicken.com/2013/11/t-sql-tuesday-48-cloud-atlas/) This month’s topic is all about the cloud. What’s your take on it? Have you used it? If so, let’s hear your experiences. Haven’t used it? Let’s hear why or why not? Do you like/dislike recent changes made to cloud services? It’s clear skies for writing! So let’s hear it folks, where do you stand with the cloud?

My wife would tell you that my head is always in the cloud and she’s right (she usually is) just not like that picture! I would love to float gracefully above the land and gaze upon the view but its the landing that bothers me and will always stop me from trying it

Credit [http://owenrichardson.com/](http://owenrichardson.com/)

She’s right, pedantically and literally too, because this year I have spent a lot of time with my head and my fingers and my thinking in [Virtual Machines using Windows Azure](http://www.windowsazure.com/). That is where I have learnt a lot of my SQL and Powershell this year. After [SQL Saturday Exeter](http://sqlsouthwest.co.uk/sqlsat269/) and [SQL Bits in Nottingham](https://blog.robsewell.com/12-things-i-learnt-at-sqlbits-xi/) this year I have needed a place to practice and learn, an environment to try things and break things and mend them again and experiment.

I learn just as well by doing things as I do reading about them. Stuart Moore  [@napalmgram](https://twitter.com/napalmgram) has a great post called [Learning to Play with SQL Server](http://stuart-moore.com/learning-play-sql-server/ "http://stuart-moore.com/learning-play-sql-server/") and whist I haven’t been as rough with my Azure SQL instances as he suggests I have been able to practice at will without worry and thanks to my MSDN subscription without cost. I have taken examples from blog posts and demos from User Group Sessions and run them on my Windows Azure VMs

Every single blog post I have written this year that has examples has been written in Azure and screen shots from Azure. Whilst some of my Powershell scripts in the [PowerShell Box of Tricks](https://blog.robsewell.com/tags/#box-of-tricks) series had already been written to solve one particular problem or another at MyWork, every single one was refined and demo’d and all the screen shots were from Azure and several were developed on Azure too

My first ever session to the SQL South West user group was about [Spinning up and Shutting Down VMS in Azure](https://blog.robsewell.com/spinning-up-and-shutting-down-windows-azure-lab-with-powershell/) was about Azure and was an interesting experience in [Murphys Law](http://en.wikipedia.org/wiki/Murphy's_law) which meant I [ended up having to deliver it  on Azure](https://blog.robsewell.com/lessons-learnt-from-my-first-talk-at-sql-southwest/).

The second time I have talked was about the PowerShell Box of Tricks series to the Cardiff User Group. Having learnt my lesson from the first time I had bought a mini HDMI to VGA converter and I had tested it using a couple of monitors at home and it worked wonderfully. However, when I got to Cardiff my little Asus convertible didn’t provide enough grunt to power the funky presentation screen. Luckily thanks to Stuart Moore [@napalmgram](https://twitter.com/napalmgram) who was also there doing his [excellent PowerShell Back Up and Restore Sessio](http://stuart-moore.com/category/31-days-of-sql-server-backup-and-restore-with-powershell/)n who let me use his Mac I was able to deliver the session using Office Web App to run the PowerPoint from my SkyDrive whilst all the demos were on ………Yup you guessed it Windows Azure !!!

So I feel qualified to answer Jorge’s questions and take part in T-SQL Tuesday this time round.

I like Azure. I like the ease I can spin up and down machines or any PaaS services at will. I love that I can do it with PowerShell because I really enjoy using PowerShell in my day to day work and at home too. Living as I do in a beautifully convenient bungalow in the country, I still enjoy the frustration of watching that spinning ring as my videos buffer on our 1.8Mbs at best internet connection. Whilst that does have an impact on using Azure it is a damn sight better than waiting many days trying to download one single file. Something like an ISO file for the latest SQL Server CTP for example.

There is no way I would have got a look at SQL Server 2014 if it wasn’t for Azure. I was able to spin up a SQL Server 2014 machine in only a few minutes and log in and have a play and then delete it. I have done the same with Server 2012 and 2012 R2. It has enabled me to try setting up Availability Groups and other technologies not yet implemented at MyWork

I wouldn’t have been able to do any of that on my machines at home as I don’t have anything capable of running Hyper-V whilst this 8 year old desktop still keeps hanging on despite the odd noises. (Negotiations are currently in place to replace it with something shiny and new. [Just need that lottery win now !!)](https://blog.robsewell.com/?p=513)

I have also transferred my Cricket Averages database to WASD and am talking with a friend of mine about developing an app that will use the mobile service as well.

The rate of change is much quicker in the cloud, things change and change quickly. As quickly as I had written my post about [Spinning up and Shutting Down VMS in Azure](https://blog.robsewell.com/spinning-up-and-shutting-down-windows-azure-lab-with-powershell/) Microsoft changed the rules and didn’t charge for machines that were turned off. New services appear all the time. New services move quickly through from Preview to release and as [Grant Fritchey noticed this week](http://www.scarydba.com/2013/11/05/more-azure-goodies/) new views have been added to to Windows Azure SQL Database under the covers. I think this is something we are just going to have to live with. The scale of the cloud means it is much easier to test improvements at large scale and that means they can be released quicker.  It makes it more challenging to keep up I admit but it’s a constant drip of new things rather than a big bang all at once.

Azure has brought me to where I am today and I think it will continue to be part of my future. If I remember to submit my PowerShell session for SQL Saturday Exeter ([Submit yours here](http://www.sqlsaturday.com/269/callforspeakers.aspx)) and it gets chosen then you will be able to see me there [(if you register here](http://www.sqlsaturday.com/269/)) using Azure to give back to the SQL Community
