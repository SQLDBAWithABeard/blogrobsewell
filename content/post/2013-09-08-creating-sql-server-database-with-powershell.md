---
title: "Creating SQL Server Database with PowerShell"
date: "2013-09-08" 
categories:
  - Blog

tags:
  - automate
  - automation
  - databases
  - error
  - PowerShell
  - box-of-tricks

---
This morning I have been setting up my Azure Servers in preparation for my presentation to the Cardiff SQL User Group this month.

I used my scripts from [My Post on Spinning Up Azure SQL Boxes](https://blog.robsewell.com/spinning-up-and-shutting-down-windows-azure-lab-with-powershell/) to create two servers and then I wanted to create some databases

I decided it was time to write a Create-Database function using a number of scripts that I have used to create individual databases.

## Errors

Whilst finalising the function I didn’t quite get it right sometimes and was faced with an error.

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image39.png)](https://blog.robsewell.com/assets/uploads/2013/09/image39.png)

Not the most useful of errors to troubleshoot. The issue could be anywhere in the script

You can view the last errors PowerShell has shown using $Errors. This gives you the last 500 errors but you can see the last error by using $Error\[0\] if you pipe it to Format-List you can get a more detailed error message so I added a try catch to the function which gave me an error message I could resolve.

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image40.png)](https://blog.robsewell.com/assets/uploads/2013/09/image40.png)

Much better. The problem was

> Cannot create file ‘C:\\Program Files\\Microsoft SQL Server\\MSSQL11.MSSQLSERVER\\MSSQL\\DATA\\.LDF’ because it already exists.

Mistyping a variable has caused this. Creating an empty file name variable which then threw the error the second(and third,fourth fifth) times I ran the script but this error pointed me to it.

## Creating Database

There are a vast number of variables you can set when creating a database. I decided to set File Sizes, File Growth Sizes, Max File Sizes and Recovery Model. I only set Server and Database Name as mandatory parameters and gave the other parameters default values

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image41.png)](https://i2.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image41.png)

We take the parameters for file sizes in MB and set them to KB

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image42.png)](https://blog.robsewell.com/assets/uploads/2013/09/image42.png)

Then set the default file locations. Create a database object, a Primary file group object and add the file group object to the database object

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image43.png)](https://blog.robsewell.com/assets/uploads/2013/09/image43.png)

Add a User File Group for User objects

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image44.png)](https://blog.robsewell.com/assets/uploads/2013/09/image44.png)

Create a database file on the primary file group using the variables set earlier

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image45.png)](https://blog.robsewell.com/assets/uploads/2013/09/image45.png)

Do the same for the user file and then create a Log File

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image46.png)](https://blog.robsewell.com/assets/uploads/2013/09/image46.png)

Set the Recovery Model and create the database and then set the user file group as the default

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image47.png)](https://blog.robsewell.com/assets/uploads/2013/09/image47.png)

Finally catch the errors

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image48.png)](https://blog.robsewell.com/assets/uploads/2013/09/image48.png)

It can then be called as follows 

    Create-Database SERVERNAME DATABASENAME

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image49.png)](https://blog.robsewell.com/assets/uploads/2013/09/image49.png)

or by setting all the parameters 

    Create-Database -Server Fade2black -DBName DatabaseTest -SysFileSize 10 -UserFileSize 15 -LogFileSize 20 -UserFileGrowth 7 -UserFileMaxSize 150 -LogFileGrowth 8 -LogFileMaxSize 250 -DBRecModel FULL

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image50.png)](https://i2.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/image50.png)

This means that I can easily and quickly set up several databases of different types and sizes

The script can be found here


    #############################################################################    ################
    #
    # NAME: Create-Database.ps1
    # AUTHOR: Rob Sewell https://blog.robsewell.com
    # DATE:08/09/2013
    #
    # COMMENTS: Load function for creating a database
    #           Only Server and DB Name are mandatory the rest will be set to     small defaults
    #
    # USAGE:  Create-Database -Server Fade2black -DBName Test35 -SysFileSize 10     -UserFileSize 15 -LogFileSize 20
    # -UserFileGrowth 7 -UserFileMaxSize 150 -LogFileGrowth 8 -LogFileMaxSize     250 -DBRecModel FULL
    # ————————————————————————
    
    
    Function Create-Database {
        Param(
            [Parameter(Mandatory = $true)]
            [String]$Server ,
            [Parameter(Mandatory = $true)]
            [String]$DBName,
            [Parameter(Mandatory = $false)]
            [int]$SysFileSize = 5,
            [Parameter(Mandatory = $false)]
            [int]$UserFileSize = 25,
            [Parameter(Mandatory = $false)]
            [int]$LogFileSize = 25,
            [Parameter(Mandatory = $false)]
            [int]$UserFileGrowth = 5,
            [Parameter(Mandatory = $false)]
            [int]$UserFileMaxSize = 100,
            [Parameter(Mandatory = $false)]
            [int]$LogFileGrowth = 5,
            [Parameter(Mandatory = $false)]
            $LogFileMaxSize = 100,
            [Parameter(Mandatory = $false)]
            [String]$DBRecModel = 'FULL'
        )
    
        try {
            # Set server object
            $srv = New-Object ('Microsoft.SqlServer.Management.SMO.Server')     $server
            $DB = $srv.Databases[$DBName]
        
            # Define the variables
            # Set the file sizes (sizes are in KB, so multiply here to MB)
            $SysFileSize = [double]($SysFileSize * 1024.0)
            $UserFileSize = [double] ($UserFileSize * 1024.0)
            $LogFileSize = [double] ($LogFileSize * 1024.0)
            $UserFileGrowth = [double] ($UserFileGrowth * 1024.0)
            $UserFileMaxSize = [double] ($UserFileMaxSize * 1024.0)
            $LogFileGrowth = [double] ($LogFileGrowth * 1024.0)
            $LogFileMaxSize = [double] ($LogFileMaxSize * 1024.0)
       
    
            Write-Output "Creating database: $DBName"
     
            # Set the Default File Locations
            $DefaultDataLoc = $srv.Settings.DefaultFile
            $DefaultLogLoc = $srv.Settings.DefaultLog
     
            # If these are not set, then use the location of the master db mdf/    ldf
            if ($DefaultDataLoc.Length -EQ 0) {$DefaultDataLoc = $srv.    Information.MasterDBPath}
            if ($DefaultLogLoc.Length -EQ 0) {$DefaultLogLoc = $srv.Information.    MasterDBLogPath}
     
            # new database object
            $DB = New-Object ('Microsoft.SqlServer.Management.SMO.Database')     ($srv, $DBName)
     
            # new filegroup object
            $PrimaryFG = New-Object ('Microsoft.SqlServer.Management.SMO.    FileGroup') ($DB, 'PRIMARY')
            # Add the filegroup object to the database object
            $DB.FileGroups.Add($PrimaryFG )
     
            # Best practice is to separate the system objects from the user     objects.
            # So create a seperate User File Group
            $UserFG = New-Object ('Microsoft.SqlServer.Management.SMO.    FileGroup') ($DB, 'UserFG')
            $DB.FileGroups.Add($UserFG)
     
            # Create the database files
            # First, create a data file on the primary filegroup.
            $SystemFileName = $DBName + "_System"
            $SysFile = New-Object ('Microsoft.SqlServer.Management.SMO.    DataFile') ($PrimaryFG , $SystemFileName)
            $PrimaryFG.Files.Add($SysFile)
            $SysFile.FileName = $DefaultDataLoc + $SystemFileName + ".MDF"
            $SysFile.Size = $SysFileSize
            $SysFile.GrowthType = "None"
            $SysFile.IsPrimaryFile = 'True'
     
            # Now create the data file for the user objects
            $UserFileName = $DBName + "_User"
            $UserFile = New-Object ('Microsoft.SqlServer.Management.SMO.    Datafile') ($UserFG, $UserFileName)
            $UserFG.Files.Add($UserFile)
            $UserFile.FileName = $DefaultDataLoc + $UserFileName + ".NDF"
            $UserFile.Size = $UserFileSize
            $UserFile.GrowthType = "KB"
            $UserFile.Growth = $UserFileGrowth
            $UserFile.MaxSize = $UserFileMaxSize
     
            # Create a log file for this database
            $LogFileName = $DBName + "_Log"
            $LogFile = New-Object ('Microsoft.SqlServer.Management.SMO.LogFile')     ($DB, $LogFileName)
            $DB.LogFiles.Add($LogFile)
            $LogFile.FileName = $DefaultLogLoc + $LogFileName + ".LDF"
            $LogFile.Size = $LogFileSize
            $LogFile.GrowthType = "KB"
            $LogFile.Growth = $LogFileGrowth
            $LogFile.MaxSize = $LogFileMaxSize
     
            #Set the Recovery Model
            $DB.RecoveryModel = $DBRecModel
            #Create the database
            $DB.Create()
     
            #Make the user filegroup the default
            $UserFG = $DB.FileGroups['UserFG']
            $UserFG.IsDefault = $true
            $UserFG.Alter()
            $DB.Alter()
    
            Write-Output " $DBName Created"
            Write-Output "System File"
            $SysFile| Select Name, FileName, Size, MaxSize, GrowthType|     Format-List
            Write-Output "User File"
            $UserFile| Select Name, FileName, Size, MaxSize, GrowthType, Growth|     Format-List
            Write-Output "LogFile"
            $LogFile| Select Name, FileName, Size, MaxSize, GrowthType, Growth|     Format-List
            Write-Output "Recovery Model"
            $DB.RecoveryModel
    
        }
        Catch {
            $error[0] | fl * -force
        }
    }
