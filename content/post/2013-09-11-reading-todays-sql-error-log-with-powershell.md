---
title: "Reading Todays SQL Error Log With PowerShell"
categories:
  - Blog

tags:
  - automate
  - PowerShell
  - box-of-tricks

---
<P>Todays post from my <A href="https://blog.robsewell.com/tags/#box-of-tricks" rel=noopener target=_blank>PowerShell Box of Tricks</A> series is about the SQL Error Log.</P>
<P>DBAs need to read the error log for many reasons and there are different ways to do it. <A href="http://subhrosaha.wordpress.com/2012/12/10/sp_readerrorlog-reading-sql-server-error-log-with-sql-command/" rel=noopener target=_blank>sp_readerrorlog</A>, <A href="http://blog.sqltechie.com/2011/03/xpreaderrorlog-parameter-detail.html" rel=noopener target=_blank>xp_readerrorlog</A>, <A href="http://technet.microsoft.com/en-us/library/ms187109.aspx" rel=noopener target=_blank>using SSMS</A> opening the file in notepad. I’m sure every DBA has their own favourite. This one is mine.Of course, it uses PowerShell</P>
<P>It is very simple as there is a method on the server property called ReadErrorLog.</P>
<P>In this function I read the latest Error Log and filter it for the last 24 hours using the `Get-Date` cmdlet and the AddDays Method</P>
<P><A href="https://i1.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image59.png"><IMG title=image style="BORDER-LEFT-WIDTH: 0px; BORDER-RIGHT-WIDTH: 0px; BACKGROUND-IMAGE: none; BORDER-BOTTOM-WIDTH: 0px; PADDING-TOP: 0px; PADDING-LEFT: 0px; DISPLAY: inline; PADDING-RIGHT: 0px; BORDER-TOP-WIDTH: 0px" border=0 alt=image src="https://i1.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image_thumb59.png?resize=630%2C61" width=630 height=61 data-recalc-dims="1" loading="lazy"></A></P>
<P>Here is the output</P>
<P><A href="https://i0.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image60.png"><IMG title=image style="BORDER-LEFT-WIDTH: 0px; BORDER-RIGHT-WIDTH: 0px; BACKGROUND-IMAGE: none; BORDER-BOTTOM-WIDTH: 0px; PADDING-TOP: 0px; PADDING-LEFT: 0px; DISPLAY: inline; PADDING-RIGHT: 0px; BORDER-TOP-WIDTH: 0px" border=0 alt=image src="https://i2.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image_thumb60.png?resize=630%2C92" width=630 height=92 data-recalc-dims="1" loading="lazy"></A></P>
<P>You can also save the output to a text file and open it by piping the function to Out-File</P>

    Show-LatestSQLErrorLog fade2black|Out-File -FilePath c:\temp\log.txt
    Invoke-Item c:\temp\log.txt

<P>or send it by email</P>
<P><A href="https://i1.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image61.png"><IMG title=image style="BORDER-LEFT-WIDTH: 0px; BORDER-RIGHT-WIDTH: 0px; BACKGROUND-IMAGE: none; BORDER-BOTTOM-WIDTH: 0px; PADDING-TOP: 0px; PADDING-LEFT: 0px; DISPLAY: inline; PADDING-RIGHT: 0px; BORDER-TOP-WIDTH: 0px" border=0 alt=image src="https://i2.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image_thumb61.png?resize=630%2C34" width=630 height=34 data-recalc-dims="1" loading="lazy"></A></P>
<P>or as an attachment</P>
<P><A href="https://i0.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image62.png"><IMG title=image style="BORDER-LEFT-WIDTH: 0px; BORDER-RIGHT-WIDTH: 0px; BACKGROUND-IMAGE: none; BORDER-BOTTOM-WIDTH: 0px; PADDING-TOP: 0px; PADDING-LEFT: 0px; DISPLAY: inline; PADDING-RIGHT: 0px; BORDER-TOP-WIDTH: 0px" border=0 alt=image src="https://i0.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image_thumb62.png?resize=630%2C165" width=630 height=165 data-recalc-dims="1" loading="lazy"></A></P>
<P>PowerShell is cool.</P>
<P>The code can be found here Show-Last24HoursSQLErrorLog</P>

    #############################################################################    ################
    #
    # NAME: Show-Last24HoursSQLErrorLog.ps1
    # AUTHOR: Rob Sewell http://newsqldbawiththebeard.wordpress.com
    # DATE:22/07/2013
    #
    # COMMENTS: Load function for reading last days current SQL Error Log for     Server
    # ————————————————————————
    Function Show-Last24HoursSQLErrorLog ([string]$Server)     {                      
        $srv = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $server 
        $logDate = (get-date).AddDays(-1)
        $Results = $srv.ReadErrorLog(0) |Where-Object {$_.LogDate -gt $logDate}|     format-table -Wrap -AutoSize 
        $Results         
    }
