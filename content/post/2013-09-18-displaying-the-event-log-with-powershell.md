---
title: "Displaying the Windows Event Log with PowerShell"
date: "2013-09-18" 
categories:
  - Blog

tags:
  - PowerShell
  - Event Log
  - box-of-tricks

---
<P>The latest post in the&nbsp; <A href="https://blog.robsewell.com/tags/#box-of-tricks" rel=noopener target=_blank>PowerShell Box of tricks</A> series is here.</P>

I’ll start by saying this is a bit of a cheat. PowerShell has a perfectly good cmdlet called [Get-EventLog](http://technet.microsoft.com/en-us/library/hh849834.aspx) and plenty of [ways to use it](http://technet.microsoft.com/en-us/library/ee176846.aspx)

<P>I created this function because I like to use Out-GridView and specify only a few records so it is quicker on remote systems. I like Out-GridView as it enables me to filter easily by typing in the top box. This is most often used via the simple GUI I have created. At the command line I would just use Get-EventLog</P>
<P><A href="https://i0.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image83.png"><IMG title=image style="BORDER-LEFT-WIDTH: 0px; BORDER-RIGHT-WIDTH: 0px; BACKGROUND-IMAGE: none; BORDER-BOTTOM-WIDTH: 0px; PADDING-TOP: 0px; PADDING-LEFT: 0px; DISPLAY: inline; PADDING-RIGHT: 0px; BORDER-TOP-WIDTH: 0px" border=0 alt=image src="https://i2.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image_thumb83.png?resize=630%2C155" width=630 height=155 data-recalc-dims="1" loading="lazy"></A></P>
<P>The function is shown below. It is important to know that the $log parameter is CaSeSensItive</P>
<P><A href="https://i2.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image84.png"><IMG title=image style="BORDER-LEFT-WIDTH: 0px; BORDER-RIGHT-WIDTH: 0px; BACKGROUND-IMAGE: none; BORDER-BOTTOM-WIDTH: 0px; PADDING-TOP: 0px; PADDING-LEFT: 0px; DISPLAY: inline; PADDING-RIGHT: 0px; BORDER-TOP-WIDTH: 0px" border=0 alt=image src="https://i1.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image_thumb84.png?resize=630%2C74" width=630 height=74 data-recalc-dims="1" loading="lazy"></A></P>
<P>The Code is here</P>

    #####################################################################
    #
    # NAME: Show-EventLog.ps1
    # AUTHOR: Rob Sewell http://newsqldbawiththebeard.wordpress.com
    # DATE:06/08/2013
    #
    # COMMENTS: Load function for Showing the windows event logs on a server
    # ————————————————————————
    # Define a server an event log the number of events and display
    # pipe to this and then to out-gridview to only show Errors -      where {$_.    entryType -match "Error"}
    
    Function Show-EventLog ($Server, $log, $Latest) {
    
        Get-EventLog  -computername $server -log $log -newest $latest |     Out-GridView
    }
