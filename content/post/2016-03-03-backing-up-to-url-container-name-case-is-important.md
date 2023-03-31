---
title: "Backing up to URL container name – case is important"
date: "2016-03-03"
categories:
  - azure
  - Blog

tags:
  - automate
  - azure
  - backup
  - backups
  - databases

---
If you use [SQL Backup to URL](https://msdn.microsoft.com/en-us/library/dn435916.aspx) to backup your databases to Azure blob storage remember that for the container name case is important

So
```
BACKUP LOG [DatabaseName]
TO URL = N'https://storageaccountname.blob.core.windows.net/containername/databasename_log_dmmyyhhss.trn'
WITH CHECKSUM, NO_COMPRESSION, CREDENTIAL = N'credential'
```
will work but
```
BACKUP LOG [DatabaseName]
TO URL = N'https://storageaccountname.blob.core.windows.net/CONTAINERNAME/databasename_log_dmmyyhhss.trn'
WITH CHECKSUM, NO_COMPRESSION, CREDENTIAL = N'credential'
```
will give an (400) Bad Request Error which may not be easy to diagnose

>Msg 3271, Level 16, State 1, Line 1
A nonrecoverable I/O error occurred on file "https://storageacccountname.blob.core.windows.net/CONTAINERNAME/databasename_log_dmmyyhhss.trn':" Backup to URL received an exception from the remote endpoint. 
Exception Message: The remote server returned an error: (400) Bad Request..
Msg 3013, Level 16, State 1, Line 1
BACKUP LOG is terminating abnormally.

If you are using Ola Hallengrens jobs to perform your backup then your job step will look like this
```
sqlcmd -E -S $(ESCAPE_SQUOTE(SRVR)) -d DBA-Admin -Q "EXECUTE [dbo].[DatabaseBackup] @Databases = 'USER_DATABASES',&nbsp; @URL = 'https://storageaccountname.blob.core.windows.net/containername', @Credential = 'credential', @BackupType = 'LOG', @ChangeBackupType = 'Y', @Verify = 'Y', @CheckSum = 'Y', @LogToTable = 'Y'" -b
```
Note the `@ChangeBackupType = ‘Y’` parameter which is not created by default but I think is very useful. If you have just created a database and take log backups every 15 minutes but differential (or full) every night the log backup will fail until a full backup has been taken. This parameter will check if a log backup is possible and if not take a full backup meaning that you still can keep to your RTO/RPO requirements even for newly created databases

