---
title: "PowerShell CMDLets added for SQL2016 Always Encrypted"
date: "2016-06-30"
categories: 
  - PowerShell
  - SQL Server
tags: 
  - SQL Agent Jobs
  - "always-encrypted"
  - automate
  - PowerShell
  - "PowerShell-vc"
  - "slack"
  - SQL
  - SQL Community
  - Community
  - SQL PASS
  - SQL Server
  - "sqlps"
  - "sqlserver"
  - "ssms"
  - "trello-board"
---

[The post on the SQLServer blog at TechNet by the SQL Server Tools Team today](https://blogs.technet.microsoft.com/dataplatforminsider/2016/06/30/sql-PowerShell-july-2016-update/) made me jump out of my seat.

> The July update for SSMS includes the first substantial improvement in SQL PowerShell in many years. We owe a lot of thanks for this effort to the great collaboration with our community. We have several new CMDLETs to share with you

In one release there are **twenty-five** new CMDLets for the new sqlserver module

> This means that if you have a PowerShell script doing _Import-Module SQLPS_, it will need to be changed to be _Import-Module SqlServer_ in order to take advantage of the new provider functionality and new CMDLETs. The new module will be installed to _“%Program Files\WindowsPowerShell\Modules\SqlServer_” and hence no update to $env:PSModulePath is required.

So SQLPS will still continue to work but will not be updated and will not contain the new CMDlets or the future new CMDlets.

## So what new things do we have?

> This month we introduce CMDLETs for the following areas:
> 
> - Always Encrypted
> - SQL Agent
> - SQL Error Logs

Chrissy LeMaire has written about the [new SQL Agent cmdlets](https://blog.netnerds.net/2016/06/the-sql-server-PowerShell-module-formerly-known-as-sqlps/)

Aaron Nelson has written about the [new Get-SqlErrorLog cmdlet](http://sqlvariant.com/2016/06/webinar-on-25-new-PowerShell-cmdlets-for-sql-server-and-more/)

Laerte Junior has written about [Invoke-SQLCmd](https://www.simple-talk.com/blogs/2016/06/30/invoke-sqlcmd-just-got-better/)

All four of us will be presenting a webinar on the new CMDlets via the [PowerShell Virtual Chapter](http://PowerShell.sqlpass.org/) Wed, Jul 06 2016 12:00 Eastern Daylight Time If you cant make it a recording will be made available on YouTube on the VC Channel [https://sqlps.io/video](https://sqlps.io/video)

## Always Encrypted CMDlets

That leaves the Always Encrypted CMDLets and there are 17 of those!

<table><tbody><tr><td width="0"><strong>Add-SqlColumnEncryptionKeyValue</strong></td><td width="0">Adds a new encrypted value for an existing column encryption key object in the database.</td></tr><tr><td width="0"><strong>Complete-SqlColumnMasterKeyRotation</strong></td><td width="0">Completes the rotation of a column master key.</td></tr><tr><td width="0"><strong>Get-SqlColumnEncryptionKey</strong></td><td width="0">Returns all column encryption key objects defined in the database, or returns one column encryption key object with the specified name.</td></tr><tr><td width="0"><strong>Get-SqlColumnMasterKey</strong></td><td width="0">Returns the column master key objects defined in the database, or returns one column master key object with the specified name.</td></tr><tr><td width="0"><strong>Invoke-SqlColumnMasterKeyRotation</strong></td><td width="0">Initiates the rotation of a column master key.</td></tr><tr><td width="0"><strong>New-SqlAzureKeyVaultColumnMasterKeySettings</strong></td><td width="0">Creates a SqlColumnMasterKeySettings object describing an asymmetric key stored in Azure Key Vault.</td></tr><tr><td width="0"><strong>New-SqlCngColumnMasterKeySettings</strong></td><td width="0">Creates a SqlColumnMasterKeySettings object describing an asymmetric key stored in a key store supporting the Cryptography Next Generation (CNG) API.</td></tr><tr><td width="0"><strong>New-SqlColumnEncryptionKey</strong></td><td width="0">Crates a new column encryption key object in the database.</td></tr><tr><td width="0"><strong>New-SqlColumnEncryptionKeyEncryptedValue</strong></td><td width="0">Produces an encrypted value of a column encryption key.</td></tr><tr><td width="0"><strong>New-SqlColumnEncryptionSettings</strong></td><td width="0">Creates a new SqlColumnEncryptionSettings object that encapsulates information about a single column’s encryption, including CEK and encryption type.</td></tr><tr><td width="0"><strong>New-SqlColumnMasterKey</strong></td><td width="0">Creates a new column master key object in the database.</td></tr><tr><td width="0"><strong>New-SqlCspColumnMasterKeySettings</strong></td><td width="0">Creates a SqlColumnMasterKeySettings object describing an asymmetric key stored in a key store with a Cryptography Service Provider (CSP) supporting Cryptography API (CAPI).</td></tr><tr><td width="0"><strong>Remove-SqlColumnEncryptionKey</strong></td><td width="0">Removes the column encryption key object from the database.</td></tr><tr><td width="0"><strong>Remove-SqlColumnEncryptionKeyValue</strong></td><td width="0">Removes an encrypted value from an existing column encryption key object in the database.</td></tr><tr><td width="0"><strong>Remove-SqlColumnMasterKey</strong></td><td width="0">Removes the column master key object from the database.</td></tr><tr><td width="0"><strong>Set-SqlColumnEncryption</strong></td><td width="0">Encrypts, decrypts or re-encrypts specified columns in the database.</td></tr><tr><td width="312"><strong> </strong></td><td width="312"></td></tr></tbody></table>

 

That seems to cover setting up Always Encrypted with PowerShell , removing it and getting information about it. When the new SSMS update is dropped you will be able to start using all of this new functionality.

Just remember Import-Module sqlserver

## CALL TO ACTION

Microsoft are engaging with the community to improve the tools we all use in our day to day work. There is are two Trello boards set up for **YOU** to use to contribute

[https://sqlps.io/vote](https://sqlps.io/vote)  for SQLPS  sqlserver PowerShell module

[https://sqlps.io/ssms](https://sqlps.io/ssms) for SSMS

Go and join them and upvote **YOUR** preferred choice of the next lot of CMDlets

![trellocount](images/trellocount.png)

 

We have also set up a SQL Community Slack for anyone in the community to discuss all things related to SQL including the Trello board items and already it seems a good place for people to get help with 150+ members in a few days. You can get an invite here [https://sqlps.io/slack](https://sqlps.io/slack)

Come and join us
