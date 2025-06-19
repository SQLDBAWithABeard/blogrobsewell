---
title: "Write Your first Pester Test Today"
date: "2017-11-16"
categories:
  - Blog

tags:
  - automation
  - dbatools
  - logins
  - pester
  - PowerShell
  - SQLBits

---
I was in Glasgow this Friday enjoying the fantastic hospitality of the [Glasgow SQL User Group](http://sqlglasgow.co.uk) [@SQLGlasgow](https://twitter.com/SqlGlasgow) and presenting sessions with [Andre Kamman](https://twitter.com/AndreKamman), [William Durkin](https://twitter.com/sql_williamd), and [Chrissy LeMaire](https://twitter.com/cl).

I presented “Green is Good Red is Bad – Turning your checklists into Pester Tests”. I had to make sure I had enough energy beforehand so I treated myself to a fabulous burger.

![20171110_114933-compressor.jpg](https://blog.robsewell.com/assets/uploads/2017/11/20171110_114933-compressor.jpg?resize=630%2C354&ssl=1)

Afterwards I was talking to some of the attendees and realised that maybe I could show how easy it was to start writing your first Pester test. Here are the steps to follow so that you can write your first Pester test:

- Decide the information you wish to test
- Understand how to get it with PowerShell
- Understand what makes it pass and what makes it fail
- Write a Pester Test

The first bit is up to you. I cannot decide what you need to test for on your servers in your environments. Whatever is the most important. For now, pick one thing.

**Logins** – Let's pick logins as an example for this post. It is good practice to disable the sa account (advice you’ll read all over the internet and often written into estate documentation), so let’s write a test for that.

Now we need the PowerShell command to return the information to test for. We need a command that will get information about logins on a SQL server and if it can return disabled logins then all the better.

As always when starting to use PowerShell with SQL Server I would start with [dbatools](http://dbatools.io). If we run [Find-DbaCommand](https://dbatools.io/functions/find-dbacommand/) we can search for commands in the module that support logins. (If you have chosen something non-SQL Server related then you can use [Get-Command](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/get-command?view=powershell-5.1) or the internet to find the command you need.)

![find-dbacommand.png](https://blog.robsewell.com/assets/uploads/2017/11/find-dbacommand.png?resize=630%2C169&ssl=1)

[Get-DbaLogin](https://dbatools.io/functions/get-dbalogin/) looks like the one that we want. Now we need to understand how to use it. Always, always use Get-Help to do this. If we run

```powershell
Get-Help Get-DbaLogins -detailed