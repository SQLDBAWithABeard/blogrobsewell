---
title: "Refreshing A SQL Mirrored Database Using Powershell"
date: "2014-08-25" 
categories:
  - Blog
  - dbatools
  - PowerShell
  - SQL Server

tags:
  - automation
  - mirroring
  - PowerShell
  - dbatools

---
SQL mirroring is a means of providing high availability for your SQL database. It is available in Standard Edition and although the feature is deprecated it is still widely utilised. [You can read more about it on MSDN here](http://msdn.microsoft.com/en-gb/library/ms189852.aspx?WT.mc_id=DP-MVP-5002693) and [Jes Borland wrote a useful post answering many questions here](http://www.brentozar.com/archive/2013/07/database-mirroring-faq/)

There are situations where you may need to refresh these databases. Disaster Recovery is an obvious one but also during development to provide testing or development environments to test your High Availability implementations, run through disaster scenarios, create run books or ensure that the code changes still work with mirroring. There are other scenarios but this post covers the automation of restoring a mirrored database from a backup.

I have mentioned before and no doubt I shall again, [John Sansom wrote a great post about automation](http://www.johnsansom.com/the-best-database-administrators-automate-everything/) and I am a strong follower of that principle.

To refresh a SQL mirror the following steps are required, there are some gotchas that you need to be aware of which I will discuss later

- remove mirroring  
- restore principle database from backup  
- perform a transaction log backup of the principle database  
- restore both backups on the mirror server with no recovery  
- recreate mirroring  
- resolve orphaned users  
- check mirroring status

Regular blog followers will know that I prefer to use Powershell when I can (and where it is relevant to do so) and so I have used Powershell to automate all of the steps above

The script requires some variables to be set up at the beginning. You can easily change this and make the script into a function and call it if you desire, but for this post I shall consider the script as a standalone. The reasoning for this is that I imagine that it will be placed into a run book or stored for use in a repository for specific use and therefore reduces any pre-requisites for using it.

Set variables as follows, the last three variables set the types for the backup action type and device type and do not need to be altered.

    \# Set up some variables
    
    $PrincipalServer = '' # Enter Principal Server Name
    $MirrorServer = '' # Enter Mirror Server Name
    $DBName = '' # Enter Database Name
    $FileShare = '' # Enter FileShare with trailing slash
    $LocationReplace = $FileShare + $DBName + 'Refresh.bak'
    $LocationTran = $FileShare + $DBName + 'formirroring.trn'
    
    $PrincipalEndPoint = 'TCP://SERVERNAME:5022' # Change as required
    $MirrorEndpoint = 'TCP://SERVERNAME:5022' # Change as required
    $WitnessEndpoint = 'TCP://SERVERNAME:5022' # Change as required
    
    $Full = [Microsoft.SQLServer.Management.SMO.BackupActionType]::Database
    $Tran = [Microsoft.SQLServer.Management.SMO.BackupActionType]::Log
    $File = [Microsoft.SqlServer.Management.Smo.DeviceType]::File 


After some error checking the first thing is to create server and database SMO objects

    \# Create Server objects $Principal = New-Object Microsoft.SQLServer.Management.SMO.Server $PrincipalServer $Mirror = New-Object Microsoft.SQLServer.Management.Smo.    server $MirrorServer
    #Create Database Objects
    $DatabaseMirror = $Mirror.Databases[$DBName]
    $DatabasePrincipal = $Principal.Databases[$DBName] 

(Added Extra – Use New-ISESnippet to create a SMO Server Snippet and use CTRL + J to find it

    New-IseSnippet -Title SMO-Server -Description "Create A SQL Server SMO Object" -Text "`$srv = New-Object Microsoft.SqlServer.Management.Smo.Server `$server"

#### Remove Mirroring

Before we can restore the database we need to remove mirroring

    $DatabasePrincipal.ChangeMirroringState([Microsoft.SqlServer.Management.Smo.MirroringOption]::Off)

#### restore principle database from backup

Once mirroring has been removed we can restore the database. [Stuart Moore’s Great Series](http://stuart-moore.com/category/31-days-of-sql-server-backup-and-restore-with-powershell/) provides all the code you need to backup and restore databases with Powershell. There is however a bug which can catch you out. Here’s the code

    $restore = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Restore|Out-Null
    $restoredevice = New-Object -TypeName Microsoft.SQLServer.Management.Smo.BackupDeviceItem($LocationReplace,$File)|Out-Null
    $restore.Database = $DBName
    $restore.ReplaceDatabase = $True
    $restore.Devices.add($restoredevice)
    #Perform Restore
    $restore.sqlrestore($PrincipalServer)
    $restore.Devices.Remove($restoredevice)

The bug is as follows, if your restore is going to take longer than 10 minutes and you are using an earlier version of SQL than SQL 2012 SP1 CU8 then you will find that the restore fails after 10 minutes. This is the default timeout. You may try to set the

    $srv.ConnectionContext.StatementTimeout

Value to a larger value or 0 and this will work after SQL 2012 SP1 CU8 but prior to that you will still face the same error. The simple workaround is to use [Invoke-SQLCmd2](http://gallery.technet.microsoft.com/scriptcenter/7985b7ef-ed89-4dfd-b02a-433cc4e30894) and to script the restore as follows

    #Set up Restore using refresh backup
    
    $restore = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Restore
    $restoredevice = New-Object -TypeName Microsoft.SQLServer.Management.Smo.BackupDeviceItem($LocationReplace,$File)|Out-Null
    $restore.Database = $DBName
    $restore.ReplaceDatabase = $True
    $restore.Devices.add($restoredevice)
    #Perform Restore
    $restore.sqlrestore($PrincipalServer) # if query time &amp;lt; 600 seconds
    # $query = $restore.Script($PrincipalServer) # if using Invoke-SQLCMD2
    $restore.Devices.Remove($restoredevice)


#### perform a transaction backup of the principle database

We need to have a full and transaction log backup to set up mirroring. Again you may need to use the script method if your backup will take longer than 600 seconds.

    #Setup Trans Backup
    $Backup = New-Object Microsoft.SqlServer.Management.Smo.Backup|Out-Null
    $Full = [Microsoft.SQLServer.Management.SMO.BackupActionType]::Database
    $Tran = [Microsoft.SQLServer.Management.SMO.BackupActionType]::Log
    $File = [Microsoft.SqlServer.Management.Smo.DeviceType]::File
    $Backup.Action = $Tran
    $Backup.BackupSetDescription = “Log Backup of “ + $DBName
    $Backup.Database = $DBName
    $BackupDevice = New-Object –TypeName Microsoft.SQLServer.Management.Smo.BackupDeviceItem($LocationTran,$File)|Out-Null
    $Backup.Devices.Add($BackupDevice)
    # Perform Backup
    $Backup.SqlBackup($PrincipalServer)
    # $query = $Backup.Script($PrincipalServer) # if query time &amp;lt; 600 seconds
    $Backup.Devices.Remove($BackupDevice)
    
    # Invoke-Sqlcmd2 –ServerInstance $PrincipalServer –Database master –Query $query –ConnectionTimeout 0 # comment out if not used


#### Restore both backups on the mirror server with no recovery

To complete the mirroring set up we need to restore the backups onto the mirror server with no recovery as follows

    #Set up Restore of Full Backup on Mirror Server
    $restore = New-Object -TypeName Microsoft.SqlServe r.Management.Smo.Restore|Out-Null
    $restoredevice = New-Object -TypeName Microsoft.SQLServer.Management.Smo.BackupDeviceItem($LocationReplace,$File)|Out-Null
    $restore.Database = $DBName
    $restore.ReplaceDatabase = $True
    $restore.NoRecovery = $true
    $restore.Devices.add($restoredevice)
    $restore.sqlrestore($MirrorServer) # if query time &amp;lt; 600 seconds
    # $query = $restore.Script($MirrorServer) # if using Invoke-SQLCMD2
    $restore.Devices.Remove($restoredevice)
    
    # Invoke-Sqlcmd2 -ServerInstance $MirrorServer -Database master -Query $query -ConnectionTimeout 0 # comment out if not used
    
    # Set up Restore of Log Backup on Mirror Server
    $restore = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Restore|Out-Null
    $restoredevice = New-Object -TypeName Microsoft.SQLServer.Management.Smo.BackupDeviceItem($LocationTran,$File)|Out-Null
    $restore.Database = $DBName
    $restore.ReplaceDatabase = $True
    $restore.NoRecovery = $true
    $restore.Devices.add($restoredevice)
    $restore.sqlrestore($MirrorServer)
    $restore.Devices.Remove($restoredevice)

#### Recreate mirroring

You recreate mirroring in the same way as you would if you were using T-SQL simply add the principal endpoint to the mirror, and the mirror and witness endpoints to the principal

    #Recreate Mirroring
    $DatabaseMirror.MirroringPartner = $PrincipalEndPoint
    $DatabaseMirror.Alter()
    $DatabasePrincipal.MirroringPartner = $MirrorEndpoint
    $DatabasePrincipal.MirroringWitness = $WitnessEndpoint
    $DatabasePrincipal.Alter()


#### Resolve orphaned users

You will need to resolve any users and permissions on your destination servers. I do not know a way to do this with PowerShell and would be interested if anyone has found a way to replace the password or the SID on a user object, please contact me if you know.

Many people do this with the [sp\_rev\_logins stored procedure](http://support.microsoft.com/kb/918992) which will create the T-SQL for recreating the logins. However, Powershell cannot read the outputs of the message window where the script prints the script. If you know that your logins are staying static then run sp\_rev\_logins and store the output in a sql file and call it with Invoke-SQLCmd2

    $SQL = ‘’ #Path to File
    Invoke-Sqlcmd2 –ServerInstance $Server –Database master –InputFile $SQL

The other option is to [set up a SSIS package following this blog post](http://dbadiaries.com/how-to-transfer-logins-to-another-sql-server-or-instance) and call it from Powershell as follows

**2020 Edit ** - You should use [dbatools](dbatools.io) to do this

    Invoke-Command –ComputerName $Server –scriptblock {DTExec.exe /File “PATHTOPackage.dtsx”}

This requires [Powershell Remoting](http://technet.microsoft.com/en-us/magazine/ff700227.aspx) to have been set up on the server which may or may not be available to you in your environment.

IMPORTANT NOTE – The script does not include any methods for resolving orphaned users so you will need to test and then add your own solution to the script.

#### check mirroring status

Lastly you want to check that the script has run successfully and that mirroring is synchronised (I am from the UK!!) To do this I check that time and file used for the last database backup [using this script](http://www.mssqltips.com/sqlservertip/1860/identify-when-a-sql-server-database-was-restored-the-source-and-backup-date/)

    #Check that correct file and backup date used
    
    $query = "SELECT TOP 1 [rs].[destination_database_name] as 'database',
    [rs].[restore_date] as 'restoredate',
    [bs].[backup_finish_date] as 'backuptime',
    [bmf].[physical_device_name] as 'Filename'
    FROM msdb..restorehistory rs
    INNER JOIN msdb..backupset bs
    ON [rs].[backup_set_id] = [bs].[backup_set_id]
    INNER JOIN msdb..backupmediafamily bmf
    ON [bs].[media_set_id] = [bmf].[media_set_id]
    ORDER BY [rs].[restore_date] DESC"
    
    Invoke-Sqlcmd2 -ServerInstance $PrincipalServer -Database msdb -Query $query |Format-Table -AutoSize –Wrap

and that mirroring has synchronised using the following Powershell command

    $DatabasePrincipal | select Name, MirroringStatus, IsAccessible |Format-Table -AutoSize

Depending on your needs you may add some error checking using the results of the above scripts. As I said at the top of the post, you can turn this script into a function and call it at will or add it to an Agent Job for regular scheduling or just kept in a folder ready to be run when required. The choice is yours but all usual rules apply. Don’t believe anything you read on this blog post, don’t run any scripts on production, test before running any scripts, understand what the code is doing before you run it or I am not responsible if you break anything

Here is the script

    <# 
    .NOTES 
        Name: Refresh Mirrored Database
        Author: Rob Sewell  https://blog.robsewell.com
        Requires: Invoke-SQLCMD2 (included)
        Version History: 
                        1.2 22/08/2014 
    .SYNOPSIS 
        Refreshes a mirrored database
    .DESCRIPTION 
        This script will refresh a mirrored database, recreate mirroring and chekc status of mirroring. 
        Further details on the website
        Requires the variables at the top of the script to be filled in
        IMPORTANT - Orpahaned users are not resolved with this acript without additions. See blog post for options
    #>  
    # Load Invoke-SQLCMD2
    
    
    #Load the assemblies the script requires
    [void][reflection.assembly]::LoadWithPartialName( "Microsoft.SqlServer.Management.Common" );
    [void][reflection.assembly]::LoadWithPartialName( "Microsoft.SqlServer.SmoEnum" );
    [void][reflection.assembly]::LoadWithPartialName( "Microsoft.SqlServer.Smo" );
    [void][reflection.assembly]::LoadWithPartialName( "Microsoft.SqlServer.SmoExtended " );
    [void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") 
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")|Out-Null
    
    # Set up some variables
    
    $PrincipalServer = '' # Enter Principal Server Name
    $MirrorServer = '' # Enter Mirror Server Name
    $DBName = '' # Enter Database Name
    $FileShare = '' # Enter FileShare with trailing slash
    $LocationReplace = $FileShare + $DBName + 'Refresh.bak'
    $LocationFUll = $FileShare + $DBName + 'formirroring.bak'
    $LocationTran = $FileShare + $DBName + 'formirroring.trn'
    
    $PrincipalEndPoint = 'TCP://SERVERNAME:5022' # Change as required
    $MirrorEndpoint = 'TCP://SERVERNAME:5022' # Change as required
    $WitnessEndpoint = 'TCP://SERVERNAME:5022' # Change as required
    
    $Full = [Microsoft.SQLServer.Management.SMO.BackupActionType]::Database
    $Tran = [Microsoft.SQLServer.Management.SMO.BackupActionType]::Log
    $File = [Microsoft.SqlServer.Management.Smo.DeviceType]::File
    
    ###################### 
    <# 
    .SYNOPSIS 
    Runs a T-SQL script. 
    .DESCRIPTION 
    Runs a T-SQL script. Invoke-Sqlcmd2 only returns message output, such as the output of PRINT statements when -verbose parameter is specified 
    .INPUTS 
    None 
        You cannot pipe objects to Invoke-Sqlcmd2 
    .OUTPUTS 
       System.Data.DataTable 
    .EXAMPLE 
    Invoke-Sqlcmd2 -ServerInstance "MyComputer\MyInstance" -Query "SELECT login_time AS 'StartTime' FROM sysprocesses WHERE spid = 1" 
    This example connects to a named instance of the Database Engine on a computer and runs a basic T-SQL query. 
    StartTime 
    ----------- 
    2010-08-12 21:21:03.593 
    .EXAMPLE 
    Invoke-Sqlcmd2 -ServerInstance "MyComputer\MyInstance" -InputFile "C:\MyFolder\tsqlscript.sql" | Out-File -filePath "C:\MyFolder\tsqlscript.rpt" 
    This example reads a file containing T-SQL statements, runs the file, and writes the output to another file. 
    .EXAMPLE 
    Invoke-Sqlcmd2  -ServerInstance "MyComputer\MyInstance" -Query "PRINT 'hello world'" -Verbose 
    This example uses the PowerShell -Verbose parameter to return the message output of the PRINT command. 
    VERBOSE: hello world 
    .NOTES 
    Version History 
    v1.0   - Chad Miller - Initial release 
    v1.1   - Chad Miller - Fixed Issue with connection closing 
    v1.2   - Chad Miller - Added inputfile, SQL auth support, connectiontimeout and output message handling. Updated help documentation 
    v1.3   - Chad Miller - Added As parameter to control DataSet, DataTable or array of DataRow Output type 
    #> 
    function Invoke-Sqlcmd2 { 
        [CmdletBinding()] 
        param( 
            [Parameter(Position = 0, Mandatory = $true)] [string]$ServerInstance, 
            [Parameter(Position = 1, Mandatory = $false)] [string]$Database, 
            [Parameter(Position = 2, Mandatory = $false)] [string]$Query, 
            [Parameter(Position = 3, Mandatory = $false)] [string]$Username, 
            [Parameter(Position = 4, Mandatory = $false)] [string]$Password, 
            [Parameter(Position = 5, Mandatory = $false)] [Int32]$QueryTimeout = 600, 
            [Parameter(Position = 6, Mandatory = $false)] [Int32]$ConnectionTimeout = 15, 
            [Parameter(Position = 7, Mandatory = $false)] [ValidateScript( {test-path $_})] [string]$InputFile, 
            [Parameter(Position = 8, Mandatory = $false)] [ValidateSet("DataSet", "DataTable", "DataRow")] [string]$As = "DataRow" 
        ) 
     
        if ($InputFile) { 
            $filePath = $(resolve-path $InputFile).path 
            $Query = [System.IO.File]::ReadAllText("$filePath") 
        } 
     
        $conn = new-object System.Data.SqlClient.SQLConnection 
          
        if ($Username) 
        { $ConnectionString = "Server={0};Database={1};User ID={2};Password={3};Trusted_Connection=False;Connect Timeout={4}" -f $ServerInstance, $Database, $Username, $Password,     $ConnectionTimeout } 
        else 
        { $ConnectionString = "Server={0};Database={1};Integrated Security=True;Connect Timeout={2}" -f $ServerInstance, $Database, $ConnectionTimeout } 
     
        &amp;n bsp; $conn.ConnectionString = $ConnectionString 
         
        #Following EventHandler is used for PRINT and RAISERROR T-SQL statements. Executed when -Verbose parameter specified by caller 
        if ($PSBoundParameters.Verbose) { 
            $conn.FireInfoMessageEventOnUserErrors = $true 
            $handler = [System.Data.SqlClient.SqlInfoMessageEventHandler] {Write-Verbose "$($_)"} 
            $conn.add_InfoMessage($handler) 
        } 
         
        $conn.Open() 
        $cmd = new-object system.Data.SqlClient.SqlCommand($Query, $conn) 
        $cmd.CommandTimeout = $QueryTimeout 
        $ds = New-Object system.Data.DataSet 
        $da = New-Object system.Data.SqlClient.SqlDataAdapter($cmd) 
        [void]$da.fill($ds) 
        $conn.Close() 
        switch ($As) { 
            'DataSet' { Write-Output ($ds) } 
            'DataTable' { Write-Output ($ds.Tables) } 
            'DataRow' { Write-Output ($ds.Tables[0]) } 
        } 
     
    } #Invoke-Sqlcmd2
    
    # Check for existence of Backup file with correct name
    If (!(Test-Path $LocationReplace)) {
        Write-Output " There is no file called " 
        Write-Output $LocationReplace
        Write-Output "Please correct and re-run"
        break
    }
    
    # Remove Old Backups
    if (Test-Path $locationFull) {
        Remove-Item $LocationFUll -Force
    }
    
    if (Test-Path $locationTran) {
        Remove-Item $LocationTran -Force
    }
    
    # Create Server objects
    $Principal = New-Object Microsoft.SQLServer.Management.SMO.Server $PrincipalServer
    $Mirror = New-Object Microsoft.SQLServer.Management.Smo.server $MirrorServer
    
    #Create Database Objects
    $DatabaseMirror = $Mirror.Databases[$DBName]
    $DatabasePrincipal = $Principal.Databases[$DBName]
    
    # If database is on Mirror server fail it over to Principal
    if ($DatabasePrincipal.IsAccessible -eq $False) {
        $DatabaseMirror.ChangeMirroringState([Microsoft.SqlServer.Management.Smo.MirroringOption]::Failover) 
    }
    
    # remove mirroring
    
    $DatabasePrincipal.ChangeMirroringState([Microsoft.SqlServer.Management.Smo.MirroringOption]::Off)
    
    #Set up Restore using refresh backup
    
    $restore = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Restore
    $restoredevice = New-Object -TypeName Microsoft.SQLServer.Management.Smo.BackupDeviceItem($LocationReplace, $File)|Out-Null
    $restore.Database = $DBName
    $restore.ReplaceDatabase = $True
    $restore.Devices.add($restoredevice)
    #Perform Restore
    $restore.sqlrestore($PrincipalServer) # if query time< 600 seconds
    # $query = $restore.Script($PrincipalServer) # if using Invoke-SQLCMD2
    $restore.Devices.Remove($restoredevice)
    
    # Invoke-Sqlcmd2 -ServerInstance $PrincipalServer -Database master -Query $query -ConnectionTimeout 0 # comment out if not used
    
    # Set up Full Backup
    $Backup = New-Object Microsoft.SqlServer.Management.Smo.Backup
    $Backup.Action = $Full
    $Backup.BackupSetDescription = "Full Backup of " + $DBName
    $Backup.Database = $DatabasePrincipal.Name
    $BackupDevice = New-Object -TypeName Microsoft.SQLServer.Management.Smo.BackupDeviceItem($LocationFull, $File)
    $Backup.Devices.Add($BackupDevice)
    # Perform Backup
    $Backup.SqlBackup($PrincipalServer)
    # $query = $Backup.Script($PrincipalServer) # if query time< 600 seconds
    $Backup.Devices.Remove($BackupDevice)
    
    # Invoke-Sqlcmd2 -ServerInstance $PrincipalServer -Database master -Query $query -ConnectionTimeout 0 # comment out if not used
    
     
    #Setup Trans Backup
    $Backup = New-Object Microsoft.SqlServer.Management.Smo.Backup|Out-Null
    $Full = [Microsoft.SQLServer.Management.SMO.BackupActionType]::Database
    $Tran = [Microsoft.SQLServer.Management.SMO.BackupActionType]::Log
    $File = [Microsoft.SqlServer.Management.Smo.DeviceType]::File
    $Backup.Action = $Tran
    $Backup.BackupSetDescription = "Log Backup of " + $DBName
    $Backup.Database = $DBName
    $BackupDevice = New-Object -TypeName Microsoft.SQLServer.Management.Smo.BackupDeviceItem($LocationTran, $File)|Out-Null
    $Backup.Devices.Add($BackupDevice)
    # Perform Backup
    $Backup.SqlBackup($PrincipalServer)
    # $query = $Backup.Script($PrincipalServer) # if query time< 600 seconds
    $Backup.Devices.Remove($BackupDevice)
    
    # Invoke-Sqlcmd2 -ServerInstance $PrincipalServer -Database master -Query $query -ConnectionTimeout 0 # comment out if not used
    
    #Set up Restore of Full Backup on Mirror Server
    $restore = New-Object -TypeName Microsoft.SqlServe r.Management.Smo.Restore|Out-Null
    $restoredevice = New-Object -TypeName Microsoft.SQLServer.Management.Smo.BackupDeviceItem($LocationFUll, $File)|Out-Null
    $restore.Database = $DBName
    $restore.ReplaceDatabase = $True
    $restore.NoRecovery = $true
    $restore.Devices.add($restoredevice)
    $restore.sqlrestore($MirrorServer) # if query time< 600 seconds
    # $query = $restore.Script($MirrorServer) # if using Invoke-SQLCMD2
    $restore.Devices.Remove($restoredevice)
    
    # Invoke-Sqlcmd2 -ServerInstance $MirrorServer -Database master -Query $query -ConnectionTimeout 0 # comment out if not used
    
    
    # Set up Restore of Log Backup on Mirror Server
    $restore = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Restore|Out-Null
    $restoredevice = New-Object -TypeName Microsoft.SQLServer.Management.Smo.BackupDeviceItem($LocationTran, $File)|Out-Null
    $restore.Database = $DBName
    $restore.ReplaceDatabase = $True
    $restore.NoRecovery = $true
    $restore.Devices.add($restoredevice)
    $restore.sqlrestore($MirrorServer)
    $restore.Devices.Remove($restoredevice)
    
    #Recreate Mirroring
    $DatabaseMirror.MirroringPartner = $PrincipalEndPoint
    $DatabaseMirror.Alter()
    $DatabasePrincipal.MirroringPartner = $MirrorEndpoint
    $DatabasePrincipal.MirroringWitness = $WitnessEndpoint
    $DatabasePrincipal.Alter()
    
    # Resolve Orphaned Users if needed
    
    
    #Check that correct file and backup date used
    
    $query = "SELECT TOP 20 [rs].[destination_database_name] as 'database', 
    [rs].[restore_date] as 'restoredate', 
    [bs].[backup_finish_date] as 'backuptime', 
    [bmf].[physical_device_name] as 'Filename'
    FROM msdb..restorehistory rs
    INNER JOIN msdb..backupset bs
    ON [rs].[backup_set_id] = [bs].[backup_set_id]
    INNER JOIN msdb..backupmediafamily bmf 
    ON [bs].[media_set_id] = [bmf].[media_set_id] 
    ORDER BY [rs].[restore_date] DESC"
    
    Invoke-Sqlcmd2 -ServerInstance $PrincipalServer -Database msdb -Query $query |Format-Table -AutoSize -Wrap
    
    $DatabasePrincipal | select Name, MirroringStatus, IsAccessible |Format-Table -AutoSize

