---
title: "Show The Last Backups On A Server with PowerShell"
date: "2013-09-15" 
categories:
  - Blog

tags:
  - automation
  - backups
  - box-of-tricks
  - PowerShell
---
<P>Another day another <A href="https://blog.robsewell.com/tags/#box-of-tricks" rel=noopener target=_blank>PowerShell Box of Tricks</A> post</P>
<P>Auditors, managers and bosses often want proof of following processes successfully so when they come knocking on my door(I don’t have a door, it’s usually my shoulder they knock) asking when the last backups were taken I either use this function or show them the excel file my automated process creates. This depends on if I think the pretty colours in the excel sheet will impress them!</P>

The `Show-LastServerBackup` function iterates through each database on the server and takes each of the three properties mentioned in <A href="https://blog.robsewell.com/?p=378" rel=noopener target=_blank>yesterdays post</A>. However this time I created an empty hash table and added each result to it as follows

I created the hash table with `@()` and then assign each property to a variable inside the loop and add it to a temporary PSObject with some custom NoteProperties to fit the data

<P><A href="https://i1.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image77.png"><IMG title=image style="BORDER-LEFT-WIDTH: 0px; BORDER-RIGHT-WIDTH: 0px; BACKGROUND-IMAGE: none; BORDER-BOTTOM-WIDTH: 0px; PADDING-TOP: 0px; PADDING-LEFT: 0px; DISPLAY: inline; PADDING-RIGHT: 0px; BORDER-TOP-WIDTH: 0px" border=0 alt=image src="https://i1.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image_thumb77.png?resize=630%2C102" width=630 height=102 data-recalc-dims="1" loading="lazy"></A></P>
<P>The last line adds the temporary object to the hash table. I then simply pipe the hash table to Format-Table to show the results</P>
<P>Call it like this</P>
<P><A href="https://i1.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image78.png"><IMG title=image style="BORDER-LEFT-WIDTH: 0px; BORDER-RIGHT-WIDTH: 0px; BACKGROUND-IMAGE: none; BORDER-BOTTOM-WIDTH: 0px; PADDING-TOP: 0px; PADDING-LEFT: 0px; DISPLAY: inline; PADDING-RIGHT: 0px; BORDER-TOP-WIDTH: 0px" border=0 alt=image src="https://i2.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image_thumb78.png?resize=630%2C167" width=630 height=167 data-recalc-dims="1" loading="lazy"></A></P>
<P>Ooops I haven’t backed up my system databases! Luckily it is my Azure server for blogging and presenting and is torn down and recreated whenever it is needed</P>
<P>You can get the code here</P>

    #############################################################################    ################
    #
    # NAME: Show-LastServerBackup.ps1
    # AUTHOR: Rob Sewell http://newsqldbawiththebeard.wordpress.com
    # DATE:06/08/2013
    #
    # COMMENTS: Load function for Showing Last Backup of each database on a     server
    # ————————————————————————
    Function Show-LastServerBackup ($SQLServer) {
    
        $server = new-object "Microsoft.SqlServer.Management.Smo.Server"     $SQLServer
    
        $Results = @();
    
        foreach ($db in $server.Databases) {
            $DBName = $db.name
            $LastFull = $db.lastbackupdate
            if ($lastfull -eq '01 January 0001 00:00:00')
            {$LastFull = 'NEVER'}
    
            $LastDiff = $db.LastDifferentialBackupDate  
            if ($lastdiff -eq '01 January 0001 00:00:00')
            {$Lastdiff = 'NEVER'}
                                                                                                                                                                
            $lastLog = $db.LastLogBackupDate 
            if ($lastlog -eq '01 January 0001 00:00:00')
            {$Lastlog = 'NEVER'}
    
            $TempResults = New-Object PSObject;
            $TempResults | Add-Member -MemberType NoteProperty -Name "Server"     -Value $Server;
            $TempResults | Add-Member -MemberType NoteProperty -Name "Database"     -Value $DBName;
            $TempResults | Add-Member -MemberType NoteProperty -Name "Last Full     Backup" -Value $LastFull;
            $TempResults | Add-Member -MemberType NoteProperty -Name "Last Diff     Backup" -Value $LastDiff;
            $TempResults | Add-Member -MemberType NoteProperty -Name "Last Log     Backup" -Value $LastLog;
            $Results += $TempResults;
        }
        $Results
    }
