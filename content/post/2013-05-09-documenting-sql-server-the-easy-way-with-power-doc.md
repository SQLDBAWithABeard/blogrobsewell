---
title: "Documenting SQL Server the easy way with Power Doc"
date: "2013-05-09" 
categories:
  - Blog

tags:
  - automation
  - documentation
  - powerdoc
  - PowerShell
  - sql

---
You know how it is. Question questions questions. As a DBA you are the fount of all knowledge. You are the protector of the data after all so obviously you know every little thing that is needed to be known.

Frequently, I am asked

How many processors does that server have?  
How much RAM is on that server? What type?  
What OS? Which Patches were installed

or more SQL based questions about configuration

Which SQL Product? Which version? Which Service Pack?  
What are the linked servers on that server?  
Or you want to know which login have which roles on the server or the autogrowth settings or any number of other ‘little things’

As the DBA as they are asking about my servers I should know and whilst I have a lot of info in my head, there’s not enough room for it all!! So I have to break from what I am doing and dive into Powershell or SSMS and get them the info that they need. When this happens I often thought I wish I could have this information to hand but I have never had time to organise it myself.

Worse still, imagine your boss walks through the door and says we have to provide information for an audit. Can you give me full details of all the SQL Servers and their configurations both windows and SQL and I need it by the end of play tomorrow.

It happens.

Its Personal Development Review time. I should have asked my boss to give me an objective of thoroughly documenting the SQL Server estate this year. I could have done it in a few hours. You only think of these things when its too late.

How can I do this? I hear you cry. Head over to [https://sqlpowerdoc.codeplex.com](https://sqlpowerdoc.codeplex.com "https://sqlpowerdoc.codeplex.com") and you will see.

SQL PowerDoc was written by Kendal VanDyke who is a practiced IT professional with over a decade of experience in SQL Server development and administration. Kendal is currently a principal consultant with UpSearch SQL, where he helps companies keep their SQL Servers running in high gear. Kendal is also a Microsoft MVP for SQL Server and president of the PASS chapter MagicPASS in Orlando, FL. You can find his blog at [http://www.kendalvandyke.com/](http://www.kendalvandyke.com/) and on Twitter at [@SQLDBA](https://twitter.com/@SQLDBA)

I found out about Power Doc a few weeks ago. It looked so cool, I tested it at home and then on my dev server and then on the whole estate. It is CPU heavy on the box it is running on if you have a load of servers. I don’t know how long it took to run as it ran overnight but the information you get back is staggering, enough to satisfy even the most inquisitive of auditors or questioners. You can pass it to your server team too and they will love it as it can do a Windows based inventory.

What does it document? What DOESNT it document? If you head over to [https://sqlpowerdoc.codeplex.com/wikipage?title=What%27s%20Documented](https://sqlpowerdoc.codeplex.com/wikipage?title=What%27s%20Documented) the list you see doesn’t reflect the sheer amount of data you can get back. Run it against your own machine and you will see what I mean.

As well as documenting everything it also runs around 100 checks to diagnose potential issues and problems. You can see where autogrowth is set to percentage, databases that haven’t been backed up, auto shrink, Max Memory set too high, the list goes on. Even the links to the MSDN articles are in there for the things it finds.

The documentation is thorough and even if you haven’t use Powershell before everything you need is on the website to run PowerDoc.

So much thought and effort has been put into this it’s difficult to see how it could be improved.

What I have done then is added the Excel file to our dba SharePoint team site and enabled the right people access to it. Equally they tell others and I get bothered slightly less.

