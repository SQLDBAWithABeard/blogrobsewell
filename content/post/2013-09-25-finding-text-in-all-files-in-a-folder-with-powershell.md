---
title: "Finding Text In All Files In A Folder With PowerShell"
categories:
  - Blog

tags:
  - files
  - PowerShell
  - automate
  - automation
  - SQL Server
  - box-of-tricks
---
Whilst writing my [PowerShell Box of Tricks GUI](https://blog.robsewell.com/?p=434) I realised that I had hard-coded the path to the sqlservers.txt file in several functions and I wanted one place where I could set this. At the top of the GUI script I added a variable and in the ReadMe explained this needed to be set but I needed to change it in all of the functions where it was referenced.

[The Hey Scripting Guy Blog came to the rescue](http://blogs.technet.com/b/heyscriptingguy/archive/2011/08/04/use-an-easy-powershell-command-to-search-files-for-information.aspx)

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image97.png)](https://blog.robsewell.com/assets/uploads/2013/09/image97.png)

Only four entries so i did them manually but [You can also use PowerShell to replace the entries.](http://blogs.technet.com/b/heyscriptingguy/archive/2008/01/17/how-can-i-use-windows-powershell-to-replace-characters-in-a-text-file.aspx)
