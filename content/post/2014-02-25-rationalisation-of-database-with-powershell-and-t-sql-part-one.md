---
title: "Rationalisation of Database with Powershell and T-SQL part one"
categories:
  - Blog

tags:
  - automate
  - database
  - Excel
  - PowerShell
  - rationalise

header:
  teaser: /assets/uploads/2014/02/usage-excel.jpg

---
I have recently been involved in a project to rationalise databases. It is easy in a large organisation for database numbers to rapidly increase and sometimes the DBA may not be aware of or be able to control the rise if they don’t have knowledge of all of the database servers on the estate.

There are lots of benefits of rationalisation to the business. Reduced cpu usage = reduced heat released = lower air-con bill for the server room and less storage used = quicker backups and less tapes used or better still less requirement for that expensive new SAN. You may be able to consolidate data and provide one version of the truth for the business as well. Removing servers can release licensing costs which could then be diverted elsewhere or pay for other improvements.

William Durkin [b](http://williamdurkin.com/)  [t](https://twitter.com/sql_williamd) presented to the [SQL South West User Group](http://sqlsouthwest.co.uk) about this and will be doing the session at SQL Saturday in Exeter in March 2014 Please check out his session for a more detailed view

I needed to be able to identify databases that could possibly be deleted and realised that an easy way to achieve this would be to use a script to check for usage of the database.

No need to recreate the wheel so I went to Aaron Bertrands blog [http://sqlblog.com/blogs/aaron_bertrand/archive/2008/05/06/when-was-my-database-table-last-accessed.aspx](http://sqlblog.com/blogs/aaron_bertrand/archive/2008/05/06/when-was-my-database-table-last-accessed.aspx) and used his script. Instead of using an audit file I decided to use Powershell so that I could output the results to Excel and colour code them. This made it easier to check the results and also easier to show to Managers and Service Owners

    #################################################################################
    # NAME: lastdbusage.ps1
    # AUTHOR: Rob Sewell
    # https://blog.robsewell.com
    # DATE:19/10/2013
    #
    # COMMENTS: Fill Excel WorkBook with details fo last access times for each database
    #
    # NOTES : Does NOT work with SQL 2000 boxes
    $FileName = '' # Set a filename for the output
    # Get List of sql servers to check
    $sqlservers = Get-Content '' # serverlist, database query whatever
    
    # Set SQL Query
    $query = "WITH agg AS
    (
    SELECT
    max(last_user_seek) last_user_seek,
    max(last_user_scan) last_user_scan,
    max(last_user_lookup) last_user_lookup,
    max(last_user_update) last_user_update,
    sd.name dbname
    FROM
    sys.dm_db_index_usage_stats, master..sysdatabases sd
    WHERE
    sd.name not in('master','tempdb','model','msdb')
    AND
    database_id = sd.dbid group by sd.name
    )
    SELECT
    dbname,
    last_read = MAX(last_read),
    last_write = MAX(last_write)
    FROM
    (
    SELECT dbname, last_user_seek, NULL FROM agg
    UNION ALL
    SELECT dbname, last_user_scan, NULL FROM agg
    UNION ALL
    SELECT dbname, last_user_lookup, NULL FROM agg
    UNION ALL
    SELECT dbname, NULL, last_user_update FROM agg
    ) AS x (dbname, last_read, last_write)
    GROUP BY
    dbname
    ORDER BY 1;
    "
    #Open Excel
    $xl = new-object -comobject excel.application
    $wb = $xl.Workbooks.Add()
    
    # Load SMO extension
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null;
    
    # Loop through each sql server from sqlservers.txt
    foreach ($sqlserver in $sqlservers) {
        # Get the time SQL was restarted
        $svr = New-Object 'Microsoft.SQLServer.Management.Smo.Server' $SQLServer
        $db = $svr.Databases['TempDB']
        $CreateDate = $db.CreateDate
    
        #Run Query against SQL Server
        $Results = Invoke-Sqlcmd -ServerInstance $sqlServer -Query $query -Database master
        # Add a new sheet
        $ws = $wb.Worksheets.Add()
        $name = "$sqlserver"
        # Name the Sheet
        $ws.name = $Name
        $cells = $ws.Cells
        $xl.Visible = $true
        #define some variables to control navigation
        $row = 2
        $col = 2
        $cells.item($row, $col) = $SQLServer + ' Was Rebooted at ' + $CreateDate
        $cells.item($row, $col).font.size = 16
        $Cells.item($row, $col).Columnwidth = 10
        $row = 3
        $col = 2
        # Set some titles
        $cells.item($row, $col) = "Server"
        $cells.item($row, $col).font.size = 16
        $Cells.item($row, $col).Columnwidth = 10
        $col++
        $cells.item($row, $col) = "Database"
        $cells.item($row, $col).font.size = 16
        $Cells.item($row, $col).Columnwidth = 40
        $col++
        $cells.item($row, $col) = "Last Read"
        $cells.item($row, $col).font.size = 16
        $Cells.item($row, $col).Columnwidth = 20
        $col++
        $cells.item($row, $col) = "Last Write"
        $cells.item($row, $col).font.size = 16
        $Cells.item($row, $col).Columnwidth = 20
        $col++
    
        foreach ($result in $results) {
            # Check if value is NULL
            $DBNull = [System.DBNull]::Value
            $LastRead = $Result.last_read
            $LastWrite = $Result.last_write
    
            $row++
            $col = 2
            $cells.item($Row, $col) = $sqlserver
            $col++
            $cells.item($Row, $col) = $Result.dbname
            $col++
            if ($LastRead -eq $DBNull) {
                $LastRead = "Not Since Last Reboot"
                $colour = "46"
                $cells.item($Row, $col).Interior.ColorIndex = $colour
                $cells.item($Row, $col) = $LastRead
            }
            else {
                $cells.item($Row, $col) = $LastRead
            }
            $col++
            if ($LastWrite -eq $DBNull) {
                $LastWrite = "Not Since Last Reboot"
                $colour = "46"
                $cells.item($Row, $col).Interior.ColorIndex = $colour
                $cells.item($Row, $col) = $LastWrite
            }
            else {
                $cells.item($Row, $col) = $LastWrite
            }
        }
    }
    
    $xl.DisplayAlerts = $false
    $wb.Saveas($FileName)
    $xl.quit()
    Stop-Process -Name *excel*

What it does is place the query in a variable. Get the contents of the SQL Server text file holding all my known SQL Servers and runs the query against each of them storing the results in a variable. It then creates an Excel Workbook and a new sheet for each server and populates the sheet including a bit of colour formatting before saving it. The results look like this

[![usage excel](https://blog.robsewell.com/assets/uploads/2014/02/usage-excel.jpg)](https://blog.robsewell.com/assets/uploads/2014/02/usage-excel.jpg)

The tricky bit was understanding how to match the NULL result from the query. This was done by assigning a variable to `[System.DBNull]::Value` and using that.

Of course these stats are reset when SQL Server restarts so I also included the SQL server restart time using the create date property  of the TempDB. I gathered these stats for a few months before starting any rationalisation.

My next post will be about the next step in the process. 

