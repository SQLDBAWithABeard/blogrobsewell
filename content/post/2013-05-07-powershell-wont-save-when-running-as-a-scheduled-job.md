---
title: "Powershell won’t save when running as a scheduled job"
categories:
  - Blog

tags:
  - laerte
  - mvp
  - PowerShell

---
### Or, How SQLBits put me in touch with Laerte and solved a problem

I have a scheduled Powershell job which I use to create an Excel file colour coded for backup checks. (I will blog about it another time) It works brilliantly on my desktop and saves the file to a UNC path and emails the team the location. It works brilliantly when run in Powershell on the server. When I schedule it to run though it doesn’t do so well. The job completes without errors but no file is saved.

If you examine the processes running at the time you can see the excel process is running  so I knew it was doing something but couldn’t work out why it was failing.

It was one of those jobs that gets put to the bottom of the list because the service worked ok I just needed to have it running on the server rather than a desktop for resilience, recovery and security purposes. Every now and then I would try and work out what was going on but new work and new problems would always arrive and it has been like that for 6 or maybe even 9 months.

[As you know](https://blog.robsewell.com/12-things-i-learnt-at-sqlbits-xi/) I attended SQLBits this weekend and I went into a session with Laerte Junior. Laerte is a SQL Server MVP and can be found at [simple-talk](https://www.simple-talk.com/author/laerte-junior/) as well as his own blog [http://shellyourexperience.com/](http://shellyourexperience.com/) or on twitter [@LaerteSQLDBA](https://twitter.com/LaerteSQLDBA) Oh and He loves Star Wars 🙂

[![Laerte_Junior[1]](https://i0.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/05/laerte_junior1_thumb.jpg?resize=168%2C223 "Laerte_Junior[1]")](https://i0.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/05/laerte_junior1.jpg)After a fascinating session I asked him if I could show him my problem. He very graciously said yes and after looking at the code and listening to me explain the problem he suggested this very simple solution which he said had taken him a great deal of searching to find. It’s a bug with COM objects and requires the creation of folders as shown below. I cam into work today, tried it and it worked. HOORAY another thing off my list and big thanks to Laerte

    #Region Bug_Jobs_ComObjects #(32Bit, always) 
    # Create Folder #
    New-Item –name C:\Windows\System32\config\systemprofile\Desktop  –itemtype directory 
    # #(64Bit) 
    # Create folder #
    New-Item –name C:\Windows\SysWOW64\config\systemprofile\Desktop  –itemtype directory
    #EndRegion Bug_Jobs_ComObjects

This worked for me however I had already implemented another fix for a possible gotcha so I will tell you of that one too

Sometimes Powershell cannot save to UNC paths because of  IE enhanced security.

Either log in as user and add server to intranet site zones or disable the warning in registry as follows

    [HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap] "UNCAsIntranet"=dword:00000000

Please don’t ever trust anything you read on the internet and certainly don’t implement it on production servers without first both understanding what it will do and testing it thoroughly. This solution worked for me in my environment I hope it is of use to you in yours but I know nothing about your environment and you know little about mine


