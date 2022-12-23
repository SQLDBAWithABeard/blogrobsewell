---
title: "Enable CLR with Powershell"
date: "2014-05-05" 
categories:
  - Blog

tags:
  - PowerShell
  - Invoke-SqlCmd2
  - Configuration


image: /assets/uploads/2014/05/050514_0904_enableclrwi2.png

---
I had an email last night from someone who attended my PowerShell Box of Tricks session at [SQL Saturday Exeter](http://sqlsouthwest.co.uk/sqlsat269/)

He was getting an error whilst trying to set CLR Enabled during an automatic install and asked if I had any ideas. The error he had was related to Invoke-SQLcmd and the method he was calling the PowerShell script

I was unable to replicate his problem on my servers so I looked at other methods that may assist as well as following up with him to try and understand what was causing his issue. In doing so I worked out the following method to change the CLR Enabled setting by SMO and thought it worth a blog post to share

One way around his issue is to define and then call [Invoke-SQLCmd2 by Chad Miller](http://gallery.technet.microsoft.com/scriptcenter/7985b7ef-ed89-4dfd-b02a-433cc4e30894) within his script. So his script would look in part as follows

![](https://blog.robsewell.com/assets/uploads/2014/05/050514_0904_enableclrwi1.png)

However, I prefer to use SMO so I examined the Server SMO as follows notice the “.” for local server

    $srv = New-Object Microsoft.SQLServer.Management.SMO.Server .
    $srv |gm

And noticed the Configuration property

     $srv.Configuration |Get-Member


Enabled me to see the IsCLREnabled Property and using Get-Member I could see that the config value was settable

![](https://blog.robsewell.com/assets/uploads/2014/05/050514_0904_enableclrwi2.png)

With this information I could write a simple script to alter the settings.

Prior to running the script

![](https://blog.robsewell.com/assets/uploads/2014/05/050514_0904_enableclrwi3.png)

We then run the following script

![](https://blog.robsewell.com/assets/uploads/2014/05/050514_0904_enableclrwi4.png)

Line 1 creates a Server SMO object there is a “.” to denote local server at the end of the line although you can use the server name as well

Line 4 sets the configvalue for the IsCLREnabled property

And Line 5 Alters the Config object, essentially running the reconfigure

After running the script

![](https://blog.robsewell.com/assets/uploads/2014/05/050514_0904_enableclrwi5.png)

Hopefully this short post shows how easy it is to set SQL Server configuration values with Powershell using SMO

Any questions or comments please feel free to ask
