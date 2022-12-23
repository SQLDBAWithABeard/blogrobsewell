---
title: "Refreshing Availability Group Database with PowerShell"
date: "2014-09-04" 
categories:
  - Blog

tags:
  - automate
  - backup
  - backups
  - documentation
  - PowerShell
  - restore
  - Availability Group
  - refresh

header:
  teaser: /assets/uploads/2014/09/image1.png

---
Following last weeks post on [Refreshing A Mirrored Database with PowerShell](https://blog.robsewell.com/refreshing-a-sql-mirrored-database-using-powershell-2/) I thought I would write the script to refresh an Availability Group Database.

An availability group supports a failover environment for a discrete set of user databases, known as availability databases, that fail over together. An availability group supports a set of primary databases and one to eight sets of corresponding secondary databases.You can read more about Availability groups [here](http://msdn.microsoft.com/en-GB/library/ff877884.aspx?WT.mc_id=DP-MVP-5002693)

There are situations where you may need to refresh these databases. Disaster Recovery is an obvious one but also during development to provide testing or development environments to test your High Availability implementations, run through disaster scenarios, create run books or ensure that the code changes still work with AG. There are other scenarios but this post covers the automation of restoring an Availability Group Database from a backup.

The steps that you need to take to restore an Availability Group Database are

- Remove Database from the Availability Group  
- Restore the Primary Replica Database  
- Backup the Primary Replica Database Transaction Log  
- Restore the Secondary and Tertiary Replica Databases with no recovery  
- Add the Database back into the Availability Group  
- Resolve Orphaned Users – Not covered in this script  
- Check the status

Here is my set up for this post

[![image](https://blog.robsewell.com/assets/uploads/2014/09/image_thumb.png)](https://blog.robsewell.com/assets/uploads/2014/09/image.png)

I have 3 servers SQL2012SER08AG1, SQL2012SER08AG2 and SQL2012SER08AG3 with 3 databases in an Availability Group called AG_THEBEARD1. SQL2012SER08AG2 is set up as a secondary replica using Synchronous-Commit Mode SQL2012SER08AG3 is set up as a read only replica using Asynchronous-Commit Mode. I have three databases in my Availability Group and today I shall use the database called TestDatabase (I have no imagination today!) to demonstrate the refresh

The script requires some variables to be set up at the beginning. You can easily change this and make the script into a function and call it if you desire, but for this post I shall consider the script as a standalone. The reasoning for this is that I imagine that it will be placed into a run book or stored for use in a repository for specific use and therefore reduces any pre-requisites for using it.

First we will remove the database from the Availability Group. This is achieved using the [Remove-SqlAvailabilityDatabase CMDLet](http://msdn.microsoft.com/en-us/library/hh213326.aspx#PowerShellProcedure?WT.mc_id=DP-MVP-5002693)

    Remove-SqlAvailabilityDatabase -Path     SQLSERVER:\SQL\$SecondaryServer\DEFAULT\AvailabilityGroups\$AGName\AvailabilityDatabases\$DBName
    Remove-SqlAvailabilityDatabase -Path     SQLSERVER:\SQL\$TertiaryServer\DEFAULT\AvailabilityGroups\$AGName\AvailabilityDatabases\$DBName 
    Remove-SqlAvailabilityDatabase -Path     SQLSERVER:\SQL\$PrimaryServer\DEFAULT\AvailabilityGroups\$AGName\AvailabilityDatabases\$DBName

Next Restore the Primary Replica Database, Backup the Primary Replica Database Transaction Log  
and Restore the Secondary and Tertiary Replica Databases with no recovery using Restore-SqlDatabase and Backup-SqlDatabase (You can also use the SMO method in [the previous post](https://blog.robsewell.com/refreshing-a-sql-mirrored-database-using-powershell-2) if you wish)

    Restore-SqlDatabase -Database $DBName -BackupFile $LoadDatabaseBackupFile  -ServerInstance $PrimaryServer -ReplaceDatabase
    
    # Backup Primary Database
    Backup-SqlDatabase -Database $DBName -BackupFile $LogBackupFile -ServerInstance $PrimaryServer -BackupAction 'Log'
    
    # Remove connections to database for Restore
    $srv = New-Object Microsoft.SqlServer.Management.Smo.Server $SecondaryServer
    $srv.KillAllProcesses($dbname)
    
    # Restore Secondary Replica Database 
    Restore-SqlDatabase -Database $DBName -BackupFile $LoadDatabaseBackupFile -ServerInstance $SecondaryServer -NoRecovery -ReplaceDatabase 
    Restore-SqlDatabase -Database $DBName -BackupFile $LogBackupFile -ServerInstance $SecondaryServer -RestoreAction 'Log' -NoRecovery  -ReplaceDatabase
    
    # Remove connections to database for Restore
    $srv = New-Object Microsoft.SqlServer.Management.Smo.Server $TertiaryServer
    $srv.KillAllProcesses($dbname)
    
    # Restore Tertiary Replica Database 
    Restore-SqlDatabase -Database $DBName -BackupFile $LoadDatabaseBackupFile -ServerInstance $TertiaryServer -NoRecovery -ReplaceDatabase
    Restore-SqlDatabase -Database $DBName -BackupFile $LogBackupFile -ServerInstance $TertiaryServer -RestoreAction 'Log' -NoRecovery  -ReplaceDatabase

Then add the database back to the Availability Group

    Add-SqlAvailabilityDatabase -Path $MyAgPrimaryPath -Database $DBName 
    Add-SqlAvailabilityDatabase -Path $MyAgSecondaryPath -Database $DBName 
    Add-SqlAvailabilityDatabase -Path $MyAgTertiaryPath -Database $DBName 

Finally test the status of the Availability Group

    $srv = New-Object Microsoft.SqlServer.Management.Smo.Server $PrimaryServer
    $AG = $srv.AvailabilityGroups[$AGName]
    $AG.DatabaseReplicaStates|ft -AutoSize

I also like to add some output to show the progress of the script. This can be logged using Out-File or displayed on the screen using Out-Host.

    $EndDate = Get-Date
    $Time = $EndDate - $StartDate
    Write-Host "
    ##########################################
    Results of Script to refresh $DBName on
    $PrimaryServer , $SecondaryServer , $TertiaryServer
    on AG $AGName
    Time Script anded at $EndDate and took
    $Time
    " -ForegroundColor Green


Here are the results of my script

[![image](https://blog.robsewell.com/assets/uploads/2014/09/image_thumb1.png)](https://blog.robsewell.com/assets/uploads/2014/09/image1.png)

Here is the script

    <#
    
        .NOTES 
        Name: Availability Group Refresh
        Author: Rob Sewell https://blog.robsewell.com
        
        .DESCRIPTION 
            Refreshes an Availbaility group database from a backup
    
            YOU WILL NEED TO RESOLVE ORPHANED USERS IF REQUIRED
    #> 
    
    ## http://msdn.microsoft.com/en-gb/library/hh213078.aspx#PowerShellProcedure?WT.mc_id=DP-MVP-5002693
    # http://msdn.microsoft.com/en-us/library/hh213326(v=sql.110).aspx?WT.mc_id=DP-MVP-5002693
    cls
    
    # To Load SQL Server Management Objects into PowerShell
        [System.Reflection.Assembly]::LoadWithPartialName(‘Microsoft.SqlServer.SMO’)  | out-null
        [System.Reflection.Assembly]::LoadWithPartialName(‘Microsoft.SqlServer.SMOExtended’)  | out-null
    
    $LoadServer = "SQL2012Ser2012" # The Load Server 
    
    $Date = Get-Date -Format ddMMyy
    $PrimaryServer = "SQL2012SER08AG1" # The Primary Availability Group Server
    $SecondaryServer = "SQL2012SER08AG2" # The Secondary Availability Group Server
    $TertiaryServer = "SQL2012SER08AG3" # The Tertiary Availability Group Server
    $AGName = "AG_THEBEARD1" # Availability Group Name
    $DBName = "TestDatabase" # Database Name
    
    $LoadDatabaseBackupFile = "\\sql2012ser2012\Backups\GoldenBackup\LoadTestDatabase" + $Date + ".bak" # Load database Backup location - Needs access permissions granted
    $DatabaseBackupFile = "\\sql2012ser2012\Backups\GoldenBackup\TestDatabase" + $Date + ".bak" # database Backup location - Needs access permissions granted
    $LogBackupFile = "\\sql2012ser2012\Backups\GoldenBackup\TestDatabase" + $Date + ".trn" # database Backup location - Needs access permissions granted
    
    # Path to Availability Database Objects
    $MyAgPrimaryPath = "SQLSERVER:\SQL\$PrimaryServer\DEFAULT\AvailabilityGroups\$AGName"
    $MyAgSecondaryPath = "SQLSERVER:\SQL\$SecondaryServer\DEFAULT\AvailabilityGroups\$AGName"
    $MyAgTertiaryPath = "SQLSERVER:\SQL\$TertiaryServer\DEFAULT\AvailabilityGroups\$AGName"
    
    $StartDate = Get-Date
    Write-Host "
    ##########################################
    Results of Script to refresh $DBName on
    $PrimaryServer , $SecondaryServer , $TertiaryServer
    on AG $AGName
    Time Script Started $StartDate
    
    " -ForegroundColor Green
    
    
    cd c:
    
    # Remove old backups
    If(Test-Path $LoadDatabaseBackupFile){Remove-Item -Path $LoadDatabaseBackupFile -Force}
    If(Test-Path $DatabaseBackupFile){Remove-Item -Path $DatabaseBackupFile}
    If(Test-Path $LogBackupFile ) {Remove-Item -Path $LogBackupFile }
    
    Write-Host "Backup Files removed" -ForegroundColor Green
    
    # Remove Secondary Replica Database from Availability Group to enable restore
    cd SQLSERVER:\SQL\$SecondaryServer\DEFAULT
    Remove-SqlAvailabilityDatabase -Path SQLSERVER:\SQL\$SecondaryServer\DEFAULT\AvailabilityGroups\$AGName\AvailabilityDatabases\$DBName 
    
    Write-Host "Secondary Removed from Availability Group" -ForegroundColor Green
    
    # Remove Tertiary Replica Database from Availability Group to enable restore
    cd SQLSERVER:\SQL\$TertiaryServer\DEFAULT
    Remove-SqlAvailabilityDatabase -Path SQLSERVER:\SQL\$TertiaryServer\DEFAULT\AvailabilityGroups\$AGName\AvailabilityDatabases\$DBName
    
    Write-Host "Tertiary removed from Availability Group" -ForegroundColor Green
    
    
    # Remove Primary Replica Database from Availability Group to enable restore
    cd SQLSERVER:\SQL\$PrimaryServer\DEFAULT
    Remove-SqlAvailabilityDatabase -Path SQLSERVER:\SQL\$PrimaryServer\DEFAULT\AvailabilityGroups\$AGName\AvailabilityDatabases\$DBName
    
    Write-Host "Primary removed from Availability Group" -ForegroundColor Green
    
    # Backup Load Database
    Backup-SqlDatabase -Database $DBName -BackupFile $LoadDatabaseBackupFile -ServerInstance $LoadServer
    
    Write-Host "Load Database Backed up" -ForegroundColor Green
    
    # Remove connections to database for Restore
    $srv = New-Object Microsoft.SqlServer.Management.Smo.Server $PrimaryServer
    $srv.KillAllProcesses($dbname)
    
    # Restore Primary Replica Database from Load Database
    Restore-SqlDatabase -Database $DBName -BackupFile $LoadDatabaseBackupFile  -ServerInstance $PrimaryServer -ReplaceDatabase
    
    Write-Host "Primary Database Restored" -ForegroundColor Green
    
    # Backup Primary Database
    # Backup-SqlDatabase -Database $DBName -BackupFile $DatabaseBackupFile -ServerInstance $PrimaryServer
    Backup-SqlDatabase -Database $DBName -BackupFile $LogBackupFile -ServerInstance $PrimaryServer -BackupAction 'Log'
    
    
    Write-Host "Primary Database Backed Up" -ForegroundColor Green
    
    # Remove connections to database for Restore
    $srv = New-Object Microsoft.SqlServer.Management.Smo.Server $SecondaryServer
    $srv.KillAllProcesses($dbname)
    
    # Restore Secondary Replica Database 
    Restore-SqlDatabase -Database $DBName -BackupFile $LoadDatabaseBackupFile  -ServerInstance $SecondaryServer -NoRecovery -ReplaceDatabase 
    Restore-SqlDatabase -Database $DBName -BackupFile $LogBackupFile -ServerInstance $SecondaryServer -RestoreAction 'Log' -NoRecovery  -ReplaceDatabase
    
    Write-Host "Secondary Database Restored" -ForegroundColor Green
    
    # Remove connections to database for Restore
    $srv = New-Object Microsoft.SqlServer.Management.Smo.Server $TertiaryServer
    $srv.KillAllProcesses($dbname)
    
    # Restore Tertiary Replica Database 
    Restore-SqlDatabase -Database $DBName -BackupFile $LoadDatabaseBackupFile  -ServerInstance $TertiaryServer -NoRecovery -ReplaceDatabase
    Restore-SqlDatabase -Database $DBName -BackupFile $LogBackupFile -ServerInstance $TertiaryServer -RestoreAction 'Log' -NoRecovery  -ReplaceDatabase
    
    Write-Host "Tertiary Database Restored" -ForegroundColor Green
    
    # Add database back into Availability Group
    cd SQLSERVER:\SQL\$PrimaryServer
    Add-SqlAvailabilityDatabase -Path $MyAgPrimaryPath -Database $DBName 
    Add-SqlAvailabilityDatabase -Path $MyAgSecondaryPath -Database $DBName 
    Add-SqlAvailabilityDatabase -Path $MyAgTertiaryPath -Database $DBName 
    
    Write-Host "Database Added to Availability Group " -ForegroundColor Green
    
    # Check Availability Group Status
     $srv = New-Object Microsoft.SqlServer.Management.Smo.Server $PrimaryServer
        $AG = $srv.AvailabilityGroups[$AGName]
        $AG.DatabaseReplicaStates|ft -AutoSize
    
        $EndDate = Get-Date
        $Time = $EndDate - $StartDate
    Write-Host "
    ##########################################
    Results of Script to refresh $DBName on
    $PrimaryServer , $SecondaryServer , $TertiaryServer
    on AG $AGName
    Time Script ended at $EndDate and took
    $Time
    
    " -ForegroundColor Green

