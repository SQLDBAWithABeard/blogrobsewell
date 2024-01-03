---
title: "Showing and Killing SQL Server Processes with PowerShell"
date: "2013-09-17" 
categories:
  - Blog

tags:
  - PowerShell
  - processes
  - sql
  - box-of-tricks

---
<P>Another post in the <A href="https://blog.robsewell.com/tags/#box-of-tricks" target=_blank>PowerShell Box of Tricks</A> series. There are much better ways of doing this I admit but as you can do it with PowerShell I created a function to do it.</P>

Create a Server Object and notice that there is a Method named EnumProcesses by piping it to `Get-Member` and then look at the Properties and Methods of EnumProcesses
<P><A href="https://i0.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image79.png"><IMG title=image style="BORDER-LEFT-WIDTH: 0px; BORDER-RIGHT-WIDTH: 0px; BACKGROUND-IMAGE: none; BORDER-BOTTOM-WIDTH: 0px; PADDING-TOP: 0px; PADDING-LEFT: 0px; DISPLAY: inline; PADDING-RIGHT: 0px; BORDER-TOP-WIDTH: 0px" border=0 alt=image src="https://i1.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image_thumb79.png?resize=575%2C49" width=575 height=49 data-recalc-dims="1" loading="lazy"></A></P>
<P>Once I had done that then it was easy to create a function to display what is going on. It’s quick and easy. Not as good as <A href="http://sqlblog.com/blogs/adam_machanic/archive/tags/sp_5F00_whoisactive/default.aspx" target=_blank>sp_WhoIsActive</A> but it displays about the same info as <A href="http://technet.microsoft.com/en-us/library/ms174313.aspx?WT.mc_id=DP-MVP-5002693" target=_blank>sp_who</A>, <A href="http://wikidba.wordpress.com/2012/03/28/difference-between-sp_who-sp_who2/" target=_blank>sp_who2</A></P>
<P><A href="https://i2.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image80.png"><IMG title=image style="BORDER-LEFT-WIDTH: 0px; BORDER-RIGHT-WIDTH: 0px; BACKGROUND-IMAGE: none; BORDER-BOTTOM-WIDTH: 0px; PADDING-TOP: 0px; PADDING-LEFT: 0px; DISPLAY: inline; PADDING-RIGHT: 0px; BORDER-TOP-WIDTH: 0px" border=0 alt=image src="https://i2.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image_thumb80.png?resize=630%2C24" width=630 height=24 data-recalc-dims="1" loading="lazy"></A></P>
<P><A href="https://i1.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image81.png"><IMG title=image style="BORDER-LEFT-WIDTH: 0px; BORDER-RIGHT-WIDTH: 0px; BACKGROUND-IMAGE: none; BORDER-BOTTOM-WIDTH: 0px; PADDING-TOP: 0px; PADDING-LEFT: 0px; DISPLAY: inline; PADDING-RIGHT: 0px; BORDER-TOP-WIDTH: 0px" border=0 alt=image src="https://i0.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image_thumb81.png?resize=630%2C79" width=630 height=79 data-recalc-dims="1" loading="lazy"></A></P>
<P>You can also find a Method called KillProcess on the Server Property so I asked a Yes/No question using Windows Forms. You can find much more detail on that <A href="http://technet.microsoft.com/en-us/library/ff730941.aspx?WT.mc_id=DP-MVP-5002693" target=_blank>here</A></P>
<P><A href="https://i0.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image82.png"><IMG title=image style="BORDER-LEFT-WIDTH: 0px; BORDER-RIGHT-WIDTH: 0px; BACKGROUND-IMAGE: none; BORDER-BOTTOM-WIDTH: 0px; PADDING-TOP: 0px; PADDING-LEFT: 0px; DISPLAY: inline; PADDING-RIGHT: 0px; BORDER-TOP-WIDTH: 0px" border=0 alt=image src="https://i1.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image_thumb82.png?resize=630%2C102" width=630 height=102 data-recalc-dims="1" loading="lazy"></A></P>
<P>All you need to supply is the spid</P>

    #######################################################################
    #
    # NAME: Show-SQLProcesses.ps1
    # AUTHOR: Rob Sewell http://sqldbawithabeard.com
    # DATE:06/08/2013
    #
    # COMMENTS: Load function for Showing Processes on a SQL Server
    ####################################
    
    Function Show-SQLProcesses ($SQLServer)
    
    {
    $server = new-object "Microsoft.SqlServer.Management.Smo.Server" $SQLServer
    $Server.EnumProcesses()|Select Spid,BlockingSpid, Login, Host,Status,Program,    Command,Database,Cpu,MemUsage |Format-Table -wrap -auto
    
    $OUTPUT= [System.Windows.Forms.MessageBox]::Show("Do you want to Kill a     process?" , "Question" , 4) 
    
    if ($OUTPUT -eq "YES" ) 
    {
    
    $spid = Read-Host "Which SPID?"
    $Server.KillProcess($Spid)
    
    
    } 
    else 
    { 
    
    }
    
    }

