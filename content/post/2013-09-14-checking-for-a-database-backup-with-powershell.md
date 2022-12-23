---
title: "Checking For A Database Backup with PowerShell"
date: "2013-09-14" 
categories:
  - Blog

tags:
  - automate
  - backups
  - PowerShell
  - box-of-tricks

---
<P>Todays <A href="https://blog.robsewell.com/tags/#box-of-tricks" rel=noopener target=_blank>PowerShell Box of Tricks</A> Post is about backups</P>
<P>I highly recommend you go and <SPAN style="TEXT-DECORATION: line-through">read </SPAN>bookmark and come straight back <A href="http://stuart-moore.com/category/31-days-of-sql-server-backup-and-restore-with-powershell/" rel=noopener target=_blank>Stuart Moore’s series on Backups with Powershell</A> The link takes you to the category showing all of the posts in the series</P>
<P>Whilst I have many other methods to inform me if backups fail, sometimes someone walks up to the desk ignores the headphones in my ears (<A href="http://www.amazon.com/EMPIRE-Yellow-Stereo-Earbud-Headphones/dp/B00E3G3JBE">They are bright yellow</A> FFS), eyes fixed on the screen, face deep in concentration and asks me a question. It was for times like these that the functions from this series were written.</P>
<P>“When was this database last backed up?”</P>
<P>Auditors, managers, bosses, developers all can come and ask this question. I just turn to my PowerShell prompt type</P>
<P><A href="https://i2.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image76.png"><IMG title=image style="BORDER-LEFT-WIDTH: 0px; BORDER-RIGHT-WIDTH: 0px; BACKGROUND-IMAGE: none; BORDER-BOTTOM-WIDTH: 0px; PADDING-TOP: 0px; PADDING-LEFT: 0px; DISPLAY: inline; PADDING-RIGHT: 0px; BORDER-TOP-WIDTH: 0px" border=0 alt=image src="https://i2.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image_thumb76.png?resize=630%2C149" width=630 height=149 data-recalc-dims="1" loading="lazy"></A></P>
<P>and show him the screen. Job done (Sometimes)</P>
<P>As I mentioned previously there are 154 properties on the database object. Three of them are</P>
<P>LastBackupDate<BR>LastDifferentialBackupDate<BR>LastLogBackupDate</P>
<P>We simply call these and if the date reported is ’01 January 0001 00:00:00′ print NEVER</P>
<P>The Code is here</P>

    #############################################################################    ################
    #
    # NAME: Show-LastServerBackup.ps1
    # AUTHOR: Rob Sewell http://newsqldbawiththebeard.wordpress.com
    # DATE:06/08/2013
    #
    # COMMENTS: Load function for Showing Last Backup of each database on a     server
    # ————————————————————————
    
    Function Show-LastDatabaseBackup ($SQLServer, $sqldatabase) {
        $server = new-object "Microsoft.SqlServer.Management.Smo.Server"     $SQLServer
        $db = $server.Databases[$sqldatabase]
    
        Write-Output "Last Full Backup"
        $LastFull = $db.lastbackupdate
        if ($lastfull -eq '01 January 0001 00:00:00')
        {$LastFull = 'NEVER'}
        Write-Output $LastFull
        Write-Output "Last Diff Backup"
        $LastDiff = $db.LastDifferentialBackupDate  
        if ($lastdiff -eq '01 January 0001 00:00:00')
        {$Lastdiff = 'NEVER'}
        Write-Output $Lastdiff
        Write-Output "Last Log     Backup"                                                  $lastLog = $db.    LastLogBackupDate 
        if ($lastlog -eq '01 January 0001 00:00:00')
        {$Lastlog = 'NEVER'}
        Write-Output $lastlog
    }
