---
title: "Searching the SQL Error Log with PowerShell"
categories:
  - Blog

tags:
  - automate
  - automation
  - PowerShell
  - box-of-tricks

---
<P>Another post in the <A href="https://blog.robsewell.com/tags/#box-of-tricks" rel=noopener target=_blank>PowerShell Box of Tricks</A> series. Here is another script which I use to save me time and effort during my daily workload enabling me to spend more time on more important (to me) things!</P>
<P>Yesterday we looked at <A href="https://blog.robsewell.com/reading-todays-sql-error-log-with-powershell/" rel=noopener target=_blank>Reading Todays SQL Error Log</A> Today we are going to search all* of the SQL Error Logs. This is usually used by DBAs to troubleshoot issues</P>
<P>The SQL Server Error Logs (by default) are located in the folder Program Files\Microsoft SQL Server\MSSQL.<EM>n</EM>\MSSQL\LOG\ERRORLOG and are named as ERRORLOG.<EM>n</EM> files. The most recent has no extension the rest 1 to 6.</P>
<P>Using PowerShell you can easily find the location of the SQL Error Log using the ErrorLogPath Property</P>
<P><A href="https://i2.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image63.png"><IMG title=image style="BORDER-LEFT-WIDTH: 0px; BORDER-RIGHT-WIDTH: 0px; BACKGROUND-IMAGE: none; BORDER-BOTTOM-WIDTH: 0px; PADDING-TOP: 0px; PADDING-LEFT: 0px; DISPLAY: inline; PADDING-RIGHT: 0px; BORDER-TOP-WIDTH: 0px" border=0 alt=image src="https://i1.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image_thumb63.png?resize=630%2C53" width=630 height=53 data-recalc-dims="1" loading="lazy"></A></P>
<P>You can also read it with PowerShell using the ReadErrorLog Method. This has the following properties LogDate, Processinfo and Text. You can easily filter by any of those with a bit of PowerShell 🙂</P>
<P>I have created a function which takes two parameters $SearchTerm and $SQLServer adds *’s to the Search Term to allow wildcards and searches each of the SQL Error Logs</P>
<P><A href="https://i0.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image64.png"><IMG title=image style="BORDER-LEFT-WIDTH: 0px; BORDER-RIGHT-WIDTH: 0px; BACKGROUND-IMAGE: none; BORDER-BOTTOM-WIDTH: 0px; PADDING-TOP: 0px; PADDING-LEFT: 0px; DISPLAY: inline; PADDING-RIGHT: 0px; BORDER-TOP-WIDTH: 0px" border=0 alt=image src="https://i1.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image_thumb64.png?resize=630%2C69" width=630 height=69 data-recalc-dims="1" loading="lazy"></A></P>
<P>Simply call it like this and use the results as needed</P>
<P><A href="https://i1.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image65.png"><IMG title=image style="BORDER-LEFT-WIDTH: 0px; BORDER-RIGHT-WIDTH: 0px; BACKGROUND-IMAGE: none; BORDER-BOTTOM-WIDTH: 0px; PADDING-TOP: 0px; PADDING-LEFT: 0px; DISPLAY: inline; PADDING-RIGHT: 0px; BORDER-TOP-WIDTH: 0px" border=0 alt=image src="https://i0.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image_thumb65.png?resize=630%2C173" width=630 height=173 data-recalc-dims="1" loading="lazy"></A></P>
<P>Of course, as the results are an object you can then carry on and do other things with them</P>
<P><A href="https://i1.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image66.png"><IMG title=image style="BORDER-LEFT-WIDTH: 0px; BORDER-RIGHT-WIDTH: 0px; BACKGROUND-IMAGE: none; BORDER-BOTTOM-WIDTH: 0px; PADDING-TOP: 0px; PADDING-LEFT: 0px; DISPLAY: inline; PADDING-RIGHT: 0px; BORDER-TOP-WIDTH: 0px" border=0 alt=image src="https://i0.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image_thumb66.png?resize=630%2C178" width=630 height=178 data-recalc-dims="1" loading="lazy"></A></P>
<P>The code can be found here</P>

    #############################################################################    ################
    #
    # NAME: Search-SQLErrorLog.ps1
    # AUTHOR: Rob Sewell http://newsqldbawiththebeard.wordpress.com
    # DATE:22/07/2013
    #
    # COMMENTS: Load function for Searching SQL Error Log and exporting and     displaying to CSV
    # ————————————————————————
    
    Function Search-SQLErrorLog ([string] $SearchTerm , [string] $SQLServer) {
     
        $FileName = 'c:\TEMP\SQLLogSearch.csv'
        $Search = '*' + $SearchTerm + '*'
        $server = new-object "Microsoft.SqlServer.Management.Smo.Server"     $SQLServer
        $server.ReadErrorLog(5)| Where-Object {$_.Text -like $Search} | Select     LogDate, ProcessInfo, Text |Export-Csv $FileName
        $server.ReadErrorLog(4)| Where-Object {$_.Text -like $Search} | Select     LogDate, ProcessInfo, Text |ConvertTo-Csv |Out-File $FileName -append
        $server.ReadErrorLog(3)| Where-Object {$_.Text -like $Search} | Select     LogDate, ProcessInfo, Text |ConvertTo-Csv |Out-File $FileName -append
        $server.ReadErrorLog(2)| Where-Object {$_.Text -like $Search} | Select     LogDate, ProcessInfo, Text |ConvertTo-Csv |Out-File $FileName -append
        $server.ReadErrorLog(1)| Where-Object {$_.Text -like $Search} | Select     LogDate, ProcessInfo, Text |ConvertTo-Csv |Out-File $FileName -append
        $server.ReadErrorLog(0)| Where-Object {$_.Text -like $Search} | Select     LogDate, ProcessInfo, Text |ConvertTo-Csv |Out-File $FileName -append
        Invoke-Item $filename
    }


<P>&nbsp;</P>
<P>* Technically we are only searching the default number of 7 but if your environment is different you can easily add the lines to the function</P>

