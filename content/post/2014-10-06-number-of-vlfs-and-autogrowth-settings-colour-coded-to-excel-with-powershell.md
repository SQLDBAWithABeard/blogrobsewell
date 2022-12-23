---
title: "Number of VLFs and Autogrowth Settings Colour Coded to Excel with PowerShell"
date: "2014-10-06" 
categories:
  - Blog

tags:
  - automation
  - colour
  - Excel
  - PowerShell
  - smo
  - snippet
  - VLF
  - Auto Growth


image: assets/uploads/2014/10/image_thumb.png
---
So you have read up on VLFs

No doubt you will have read [this post by Kimberly Tripp](http://www.sqlskills.com/blogs/kimberly/transaction-log-vlfs-too-many-or-too-few/) and this [one](http://www.sqlskills.com/blogs/kimberly/8-steps-to-better-transaction-log-throughput/) and maybe [this one too](https://www.simple-talk.com/sql/database-administration/sql-server-transaction-log-fragmentation-a-primer/) and you want to identify the databases in your environment which have a large number of VLFs and also the initial size and the autogrowth settings of the log files.

There are several posts about this and doing this with PowerShell [like this one](https://www.simple-talk.com/sql/database-administration/monitoring-sql-server-virtual-log-file-fragmentation/) or [this one](http://www.youdidwhatwithtsql.com/audit-vlfs-on-your-sql-server/1358/). As is my wont I chose to output to Excel and colour code the cells depending on the number of VLFs or the type of Autogrowth.

There is not a pure SMO way of identifying the number of VLFs in a log file that I am aware of and it is simple to use DBCC LOGINFO to get that info.

I also wanted to input the autogrowth settings, size, space used, the logical name and the file path. I started by getting all of my servers into a $Servers Array as follows

    $Servers = Get-Content 'PATHTO\sqlservers.txt'

Whilst presenting at the Newcastle User Group, Chris Taylor [b](http://chrisjarrintaylor.co.uk/) | [t](https://twitter.com/sqlgeordie) asked a good question. He asked if that was the only way to do this or if you could use your DBA database.

It is much better to make use of the system you already use to record your databases. It will also make it much easier for you to be able to run scripts against more specific groups of databases without needing to keep multiple text files up to date. You can accomplish this as follows

    $Query = 'SELECT Name FROM dbo.databases WHERE CONDITION meets your needs'
    $Servers = Invoke-Sqlcmd -ServerInstance MANAGEMENTSERVER -Database DBADATABASE -Query $query

I then create a foreach loop and a server SMO object (Did you read my [blog post](https://blog.robsewell.com/powershell-snippets-a-great-learning-tool) about snippets? the code for a SMO Server snippet is there) returned the number of rows for DBCC LOGINFO and the information I wanted.

    foreach ($Server in $Servers)
       {
         $srv = New-Object Microsoft.SqlServer.Management.Smo.Server $Server
         foreach ($db in $srv.Databases|Where-Object {$_.isAccessible -eq $True})
         {
           $DB.ExecuteWithResults('DBCC LOGINFO').Tables[0].Rows.Count
            $db.LogFiles | Select Growth,GrowthType,Size, UsedSpace,Name,FileName
          }
       }

It’s not very pretty or particularly user friendly so I decided to put it into Excel

I did this by using my Excel Snippet

     $snippet = @{
          Title = 'Excel Object';
          Description = 'Creates a Excel Workbook and Sheet';
          Text = @'
          # Create a .com object for Excel
        `$xl = new-object -comobject excel.application
        `$xl.Visible = `$true # Set this to False when you run in production
        `$wb = `$xl.Workbooks.Add() # Add a workbook
        `$ws = `$wb.Worksheets.Item(1) # Add a worksheet
        `$cells=`$ws.Cells
        #Do Some Stuff - perhaps -
          `$cells.item(`$row,`$col)=`'Server`'
          `$cells.item(`$row,`$col).font.size=16
          `$Cells.item(`$row,`$col).Columnwidth = 10
          `$col++
        `$wb.Saveas(`'C:\temp\Test`$filename.xlsx`')
        `$xl.quit()
        Stop-Process -Name EXCEL
        '@
        }
        New-IseSnippet @snippet

and placed the relevant bits into the foreach loop

    foreach ($Server in $Servers)
       {
         $srv = New-Object Microsoft.SqlServer.Management.Smo.Server $Server
         foreach ($db in $srv.Databases|Where-Object {$_.isAccessible -eq $True})
         {
           $VLF = $DB.ExecuteWithResults('DBCC LOGINFO').Tables[0].Rows.Count
           $logFile = $db.LogFiles | Select Growth,GrowthType,Size, UsedSpace,Name,FileName
           $Name = $DB.name
           $cells.item($row,$col)=$Server
           $col++
           $cells.item($row,$col)=$Name
           $col++
           $cells.item($row,$col)=$VLF
           $col++
           $col++
           $Type = $logFile.GrowthType.ToString()
           $cells.item($row,$col)=$Type
           $col++
           $cells.item($row,$col)=($logFile.Size)
           $col++
           $cells.item($row,$col)=($logFile.UsedSpace)
           $col++
           $cells.item($row,$col)=$logFile.Name
           $col++
           $cells.item($row,$col)=$logFile.FileName

I had to use the `ToString()` method on the Type property to get Excel to display the text. I wanted to set the colour for the VLF cells to yellow or red dependant on their value and the colour of the growth type cell to red if the value was Percent. This was achieved like this

    if($VLF -gt $TooMany)
       {
         $cells.item($row,$col).Interior.ColorIndex = 6 # Yellow
       }
       if($VLF -gt $WayTooMany)
       {
         $cells.item($row,$col).Interior.ColorIndex = 3 # Red
       }
       if($Type -eq 'Percent')
       {
         $cells.item($row,$col).Interior.ColorIndex = 3 #Red
       }

I also found [this excellent post](http://theolddogscriptingblog.wordpress.com/2010/06/01/powershell-excel-cookbook-ver-2/) by which has many many snippets of code to work with excel sheets.

I used

    $cells.item($row,$col).HorizontalAlignment = 3 #center
    $cells.item($row,$col).HorizontalAlignment = 4 #right
    $ws.UsedRange.EntireColumn.AutoFit()

although I had to move the Title so that it was after the above line so that it looked ok.

[  
![image](https://blog.robsewell.com/assets/uploads/2014/10/image_thumb.png)  
](https://blog.robsewell.com/wp-content/uploads/2014/10/image.png)

[You can find the script here.](https://gallery.technet.microsoft.com/scriptcenter/Number-of-VLFs-and-7ee0182a) As always test it somewhere safe first, understand what it is doing and any questions get in touch.

