---
title: "Odd Error with Contained Database Users - look out for your 3rd party vendors"
date: "2025-04-23"
categories:
  - Blog
  - Community
tags:
  - SQL Server
  - Contained Databases
  - Error
  - Permissions
  - Contained User

image: assets/uploads/2025/mentor.png
---
## Introduction

A contained user can create a Windows login as its own account, although as it cannot grant connect permissions it is then is unable to connect at all.

So if your vendor application is running as a contained user and during an upgrade it tries to create a login for itself, it will succeed in the creation but then be unable to connect to the SQL Server instance and the upgrade will fail.......... Sad Trombone.

## Go back to the beginning Rob

So this is an odd thing which [Kristian](https://www.linkedin.com/in/krleth/) asked me about and I thought I would bring to the wider world.

It started with a question.

"Can a contained database user create a LOGIN?"

I said No.

Kristian said - Look at this. They had caught a 3rd party vendor running `CREATE LOGIN` statements which had errored. Fortunately, they had used contained databases for the vendor database and the connecting user because they wanted to reduce the surface area that it was able to affect.

## Always check your sources

So first I tested and I found that I could replicate. I ran it on

`Microsoft SQL Server 2022 (RTM-CU17) (KB5048038) - 16.0.4175.1 (X64)   Dec 13 2024 09:01:53   Copyright (C) 2022 Microsoft Corporation  Developer Edition (64-bit) on Windows Server 2022 Datacenter 10.0 <X64> (Build 20348: ) (Hypervisor)`

Because its what I had available. The person who reported it was running version `16.0.4155.4`

I created a contained database.

```sql
— Running as sysadmin

EXEC sp_configure 'contained database authentication', 1;
RECONFIGURE;

CREATE DATABASE [containedbeard]
CONTAINMENT = PARTIAL
```
Then a contained user `jessandrob\testuser` as a Windows User (Yes, I used [Jess Pomfret [B](https://jesspomfret.com) and mine test environment :-) ). I then connected as the contained user and tried to create a SQL login.

```sql
USE containedbeard
GO
CREATE USER [jessandrob\testuser]

--- Connected as jessandrob\testuser the contained database user

CREATE LOGIN IwillFail WITH PASSWORD='whocares!!0'
```

As expected this fails with

>Msg 15247, Level 16, State 1, Line 5
>User does not have permission to perform this action.


Which is as expected. The same thing also happens if you try to create a windows login for a different account

```sql
CREATE LOGIN [JESSANDROB\testuser1] FROM WINDOWS
```
>Msg 15247, Level 16, State 1, Line 5
>User does not have permission to perform this action.

However, if you try to create a login as the same Windows user

```sql
CREATE LOGIN [JESSANDROB\testuser] FROM WINDOWS
```

The Login gets created.

## YAY!!! Oh wait... NAY!!!

Lets take a closer look at the login with some [dbatools](dbatools.io).

```powershell

PS > Get-DbaLogin -SqlInstance sql1 -Login JESSANDROB\testuser

ComputerName       : sql1
InstanceName       : MSSQLSERVER
SqlInstance        : sql1
Name               : JESSANDROB\testuser
LoginType          : WindowsUser
CreateDate         : 2/11/2025 8:17:24 PM
LastLogin          : 2/11/2025 8:17:24 PM
HasAccess          : False
IsLocked           :
IsDisabled         : False
MustChangePassword :
```
Notice the `HasAccess` property is set to `False`. This means that the login cannot connect to the SQL Server instance.

This is because the contained user does not have the `CONNECT SQL` permission on the server. The login is created, but it cannot be used to connect to the SQL Server instance.

>`(Get-DbaLogin -SqlInstance sql1 -Login JESSANDROB\testuser|Remove-DbaLogin -Force` will easily remove the annoying login btw )

The person who got in touch found this confusing. As did I.

If yopu look in the [documentation](https://learn.microsoft.com/en-us/sql/relational-databases/security/contained-database-users-making-your-database-portable?view=sql-server-ver16) it states:

>      The activity of the contained database user is limited to the authenticating database. The database user account must be independently created in each database that the user needs. To change databases, SQL Database users must create a new connection. Contained database users in SQL Server can change databases if an identical user is present in another database.

But nowhere does it say that a contained user can create a login for itself.
So it is a bit of a gotcha. I think the documentation should be updated to clarify this.

