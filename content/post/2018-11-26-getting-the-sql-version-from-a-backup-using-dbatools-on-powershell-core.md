---
title: "Getting the SQL Version from a backup using dbatools ………. on PowerShell Core"
categories:
  - Blog

tags:
  - backups
  - dbatools
  - PowerShell

---
Following an upgrade to SQL Server the backup share had a number of backups, some from the old version and some from the newer version. I was asked if I had a script to be able to get the SQL Version from the backup file from all of the files in the backup share.

With [dbatools](http://dbatools,io) this was easy to accomplish with [Read-DbaBackuoHeader](https://docs.dbatools.io/#Read-DbaBackupHeader)
```
$backupshare = "$share\\keep"
$Instance = "SQL0\\Mirror"

$information = foreach ($BackupFile in (Get-ChildItem $backupshare)) {
    $FileName = @{Name = 'FileName'; Expression = {$BackupFile.Name}}
    Read-DbaBackupHeader -SqlInstance $Instance -Path $BackupFile.FullName | Select-Object  $FileName, DatabaseName , CompatibilityLevel, SqlVersion
}
$information | Format-Table
```
![read-dbabackupheader.PNG](https://blog.robsewell.com/assets/uploads/2018/11/read-dbabackupheader.png)

You can get more information about the backup using `Read-DbaBackupHeader` and as it is PowerShell it is easy to put this information into any format that you wish, maybe into a database with [`Write-DbaDataTable`](https://docs.dbatools.io/#Write-DbaDataTable)

> So I looked at [https://t.co/MUw7Dw7CRv](https://t.co/MUw7Dw7CRv)
> 
> I saw the words " Support for PS Core on Windows 🎉"
> 
> I updated the module to 0.9.522 and ran a command and
> 
> BOOOOOOOOOOOOOOOOOOM
> 
> Good work fine [@psdbatools](https://twitter.com/psdbatools?ref_src=twsrc%5Etfw) contirbutors and [@cl](https://twitter.com/cl?ref_src=twsrc%5Etfw) [pic.twitter.com/fzpSIju1Gx](https://t.co/fzpSIju1Gx)
> 
> — Rob Sewell (@sqldbawithbeard) [November 23, 2018](https://twitter.com/sqldbawithbeard/status/1065955800823332864?ref_src=twsrc%5Etfw)

Support for PowerShell Core in dbatools is coming along very nicely. Following some hard work by the dbatools team and some PowerShell Community members like [Mathias Jessen](https://twitter.com/IISResetMe) it is now possible to run a large number of dbatools commands in PowerShell Core running on Windows. There is still a little bit of work to do to get it working on Linux and Mac but I hear the team are working hard on that.

So the code example you see above was running on Windows 10 using PowerShell 6.1.1 the current latest stable release. This is excellent news and congratulations to all those working hard to make this work

![dbatoolscore.PNG](https://blog.robsewell.com/assets/uploads/2018/11/dbatoolscore.png)

If you want to try PowerShell Core, you can follow the instructions

*   [Here for Windows](https://docs.microsoft.com/en-gb/powershell/scripting/setup/installing-powershell-core-on-windows?view=powershell-6)
*   [Here for Linux](https://docs.microsoft.com/en-gb/powershell/scripting/setup/installing-powershell-core-on-linux?view=powershell-6)
*   [Or here for MacOs](https://docs.microsoft.com/en-gb/powershell/scripting/setup/installing-powershell-core-on-macos?view=powershell-6)

Happy Automating!

