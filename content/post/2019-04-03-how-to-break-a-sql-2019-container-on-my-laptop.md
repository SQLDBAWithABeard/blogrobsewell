---
title: "How to break a SQL 2019 container on my laptop"
date: "2019-04-03"
categories: 
  - SQL Server
tags: 
  - "containers"
  - "docker"
  - "error-logs"
  - "sql-error-log"
---

Just a very quick post today. At the weekend I blogged about [creating SQL 2019 containers with named volumes enabling](https://sqldbawithabeard.com/2019/03/26/persisting-databases-with-named-volumes-on-windows-with-docker-compose/) you to persist your data and yesterday about [creating a random workload using PowerShell](https://sqldbawithabeard.com/2019/04/02/generating-a-workload-against-adventureworks-with-PowerShell/) and a big T-SQL script.

The interesting thing about creating workload is that you can break things :-)

When I created a SQL 2019 container with the data files mapped to a directory on my laptops C Drive with a docker-compose like this

```
version: '3.7'

services:
    2019-CTP23:
        image: mcr.microsoft.com/mssql/server:2019-CTP2.3-ubuntu
        ports:  
          - "15591:1433"
          - "5022:5022"
        environment:
          SA_PASSWORD: "Password0!"
          ACCEPT_EULA: "Y"
        volumes: 
          - C:\MSSQL\BACKUP\KEEP:/var/opt/mssql/backups
          - C:\MSSQL\DockerFiles\datafiles:/var/opt/sqlserver
          - C:\MSSQL\DockerFiles\system:/var/opt/mssql
```

restore the AdventureWorks database to use the /var/opt/sqlserver directory and run a workload after a while the container stops and when you examine the logs you find

[![](https://i0.wp.com/sqldbawithabeard.com/wp-content/uploads/2019/04/D26g3dPXgAAso28.png?fit=630%2C214&ssl=1)](https://sqldbawithabeard.com/wp-content/uploads/2019/04/D26g3dPXgAAso28.png)

I had a whole load of these errors

```
2019-04-02 20:48:24.73 spid58      Error: 17053, Severity: 16, State: 1.
2019-04-02 20:48:24.73 spid58      FCB::MakePreviousWritesDurable: Operating system error (null) encountered.
2019-04-02 20:48:24.74 spid58      Error: 9001, Severity: 21, State: 1.
2019-04-02 20:48:24.74 spid58      The log for database 'AdventureWorks2014' is not available. Check the operating system error log for related error messages. Resolve any errors and restart the database.
2019-04-02 20:48:25.05 spid58      Error: 9001, Severity: 21, State: 16.
2019-04-02 20:48:25.05 spid58      The log for database 'AdventureWorks2014' is not available. Check the operating system error log for related error messages. Resolve any errors and restart the database.
2019-04-02 20:48:25.06 spid52      Error: 9001, Severity: 21, State: 16.
2019-04-02 20:48:25.06 spid52      The log for database 'AdventureWorks2014' is not available. Check the operating system error log for related error messages. Resolve any errors and restart the database.
```

Then some of these

```
019-04-02 20:55:16.26 spid53      Error: 17053, Severity: 16, State: 1.
2019-04-02 20:55:16.26 spid53      /var/opt/sqlserver/AdventureWorks2014_Data.mdf: Operating system error 31(A device attached to the system is not functioning.) encountered.
```

Then it went really bad

```
2019-04-02 20:55:16.35 spid53      Error: 3314, Severity: 21, State: 3.
2019-04-02 20:55:16.35 spid53      During undoing of a logged operation in database 'AdventureWorks2014' (page (0:0) if any), an error occurred at log record ID (65:6696:25). Typically, the specific failure is logged previously as an error in the operating system error log. Restore the database or file from
a backup, or repair the database.
2019-04-02 20:55:16.37 spid53      Database AdventureWorks2014 was shutdown due to error 3314 in routine 'XdesRMReadWrite::RollbackToLsn'. Restart for non-snapshot databases will be attempted after all connections to the database are aborted.
Restart packet created for dbid 5.
2019-04-02 20:55:16.41 spid53      Error during rollback. shutting down database (location: 1).
```

```
after that it tried to restart the database
```

```
2019-04-02 20:55:16.44 spid53      Error: 3314, Severity: 21, State: 3.
2019-04-02 20:55:16.44 spid53      During undoing of a logged operation in database 'AdventureWorks2014' (page (0:0) if any), an error occurred at log record ID (65:6696:25). Typically, the specific failure is logged previously as an error in the operating system error log. Restore the database or file from
a backup, or repair the database.
2019-04-02 20:55:16.49 spid53      Error: 3314, Severity: 21, State: 5.
2019-04-02 20:55:16.49 spid53      During undoing of a logged operation in database 'AdventureWorks2014' (page (0:0) if any), an error occurred at log record ID (65:6696:1). Typically, the specific failure
is logged previously as an error in the operating system error log. Restore the database or file from a backup, or repair the database.
Restart packet processing for dbid 5.
2019-04-02 20:55:17.04 spid52      [5]. Feature Status: PVS: 0. CTR: 0. ConcurrentPFSUpdate: 0.
2019-04-02 20:55:17.06 spid52      Starting up database 'AdventureWorks2014'.
```

But that caused

```
2019-04-02 20:55:17.90 spid76      Error: 9001, Severity: 21, State: 16.
2019-04-02 20:55:17.90 spid76      The log for database 'master' is not available. Check the operating
system error log for related error messages. Resolve any errors and restart the database.
```

Master eh? Now what will you do?

```
2019-04-02 20:55:25.55 spid52      29 transactions rolled forward in database 'AdventureWorks2014' (5:0). This is an informational message only. No user action is required.
2019-04-02 20:55:25.90 spid52      1 transactions rolled back in database 'AdventureWorks2014' (5:0). This is an informational message only. No user action is required.
2019-04-02 20:55:25.90 spid52      Recovery is writing a checkpoint in database 'AdventureWorks2014' (5). This is an informational message only. No user action is required.
2019-04-02 20:55:26.16 spid52      Recovery completed for database AdventureWorks2014 (database ID 5) in 7 second(s) (analysis 424 ms, redo 5305 ms, undo 284 ms.) This is an informational message only. No user action is required.
2019-04-02 20:55:26.21 spid52      Parallel redo is shutdown for database 'AdventureWorks2014' with worker pool size [1].
2019-04-02 20:55:26.27 spid52      CHECKDB for database 'AdventureWorks2014' finished without errors on 2018-03-24 00:38:39.313 (local time). This is an informational message only; no user action is required.
```

Interesting, then back to this.

```
2019-04-02 21:00:00.57 spid51      Error: 17053, Severity: 16, State: 1.
2019-04-02 21:00:00.57 spid51      FCB::MakePreviousWritesDurable: Operating system error (null) encountered.
2019-04-02 21:00:00.62 spid51      Error: 9001, Severity: 21, State: 1.
2019-04-02 21:00:00.62 spid51      The log for database 'AdventureWorks2014' is not available. Check the operating system error log for related error messages. Resolve any errors and restart the database.
2019-04-02 21:00:00.64 spid51      Error: 9001, Severity: 21, State: 16.
```

It did all that again before

```
This program has encountered a fatal error and cannot continue running at Tue Apr  2 21:04:08 2019
The following diagnostic information is available:

       Reason: 0x00000004
      Message: RETAIL ASSERT: Expression=(false) File=Thread.cpp Line=4643 Description=Timed out waiting for thread terminate/suspend/resume.
   Stacktrace: 000000006af30187 000000006af2836a 000000006ae4a4d1
               000000006ae48c55 000000006af6ab5e 000000006af6ac04
               00000002809528df
      Process: 7 - sqlservr
       Thread: 129 (application thread 0x1e8)
  Instance Id: 215cfcc9-8f69-4869-9a52-5aa44a415a83
     Crash Id: 53e98400-33f1-4786-98fd-484f0c8d9a7e
  Build stamp: 0e53295d0e1704ae5b221538dd6e2322cd46134e0cc32be49c887ca84cdb8c10
 Distribution: Ubuntu 16.04.6 LTS
   Processors: 2
 Total Memory: 4906205184 bytes
    Timestamp: Tue Apr  2 21:04:08 2019

Ubuntu 16.04.6 LTS
Capturing core dump and information to /var/opt/mssql/log...
/usr/bin/find: '/proc/7/task/516': No such file or directory
dmesg: read kernel buffer failed: Operation not permitted
No journal files were found.
No journal files were found.
Attempting to capture a dump with paldumper
WARNING: Capture attempt failure detected
Attempting to capture a filtered dump with paldumper
WARNING: Attempt to capture dump failed.  Reference /var/opt/mssql/log/core.sqlservr.7.temp/log/paldumper-debug.log for details
Attempting to capture a dump with gdb
WARNING: Unable to capture crash dump with GDB. You may need to
allow ptrace debugging, enable the CAP_SYS_PTRACE capability, or
run as root.
```

failing to capture it's dump!! Oops :-)

I had to recreate the containers without using the named volumes and then I could run my workload :-)

Nothing particularly useful about this blog post other than an interesting look at the error log when things go wrong :-)
