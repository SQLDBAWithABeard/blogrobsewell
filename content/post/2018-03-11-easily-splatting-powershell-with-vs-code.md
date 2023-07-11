---
title: "Easily Splatting PowerShell with VS Code"
date: "2018-03-11"
categories:
  - Blog

tags:
  - dbatools
  - PowerShell
  - splat
  - splatting


image: assets/uploads/2022/dbachecks.jpg

---
So I always like to show splatting PowerShell commands when I am presenting sessions or workshops and realised that I had not really blogged about it. (This blog is for [@dbafromthecold](https://twitter.com/dbafromthecold) who asked me to 🙂 )

What is Splatting?
------------------

Well you will know that when you call a PowerShell function you can use intellisense to get the parameters and sometimes the parameter values as well. This can leave you with a command that looks like this on the screen

    Start-DbaMigration -Source $Source -Destination $Destination -BackupRestore -NetworkShare $Share -WithReplace -ReuseSourceFolderStructure -IncludeSupportDbs -NoAgentServer -NoAudits -NoResourceGovernor -NoSaRename -NoBackupDevices

It goes on and on and on and while it is easy to type once, it is not so easy to see which values have been chosen. It is also not so easy to change the values.

By Splatting the parameters it makes it much easier to read and also to alter. So instead of the above you can have

```
$startDbaMigrationSplat = @{
Source = $Source
NetworkShare = $Share
NoAgentServer = $true
NoResourceGovernor = $true
WithReplace = $true
ReuseSourceFolderStructure = $true
Destination = $Destination
NoAudits = $true
BackupRestore = $true
NoSaRename = $true
IncludeSupportDbs = $true
NoBackupDevices = $true
}
Start-DbaMigration @startDbaMigrationSplat
```
This is much easier on the eye, but if you dont know what the parameters are (and are too lazy to use [Get-Help](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/get-help?view=powershell-6) – Hint You should always use [Get-Help](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/get-help?view=powershell-6) ) or like the convenience and efficiency of using the intellisense, this might feel like a backward step that slows your productivity in the cause of easy on the eye code.

Enter [EditorServicesCommandSuite](https://github.com/SeeminglyScience/EditorServicesCommandSuite) by SeeminglyScience for VS Code. Amongst the things it makes available to you is easy splatting and people are always impressed when I show it

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">Best thing i learned at <a href="https://twitter.com/hashtag/SqlSatIceland?src=hash&amp;ref_src=twsrc%5Etfw">#SqlSatIceland</a>... <a href="https://twitter.com/hashtag/PowerShell?src=hash&amp;ref_src=twsrc%5Etfw">#PowerShell</a> &quot;splatting&quot;<br>Byebye lines of code i no longer need!<br>Thanks <a href="https://twitter.com/sqldbawithbeard?ref_src=twsrc%5Etfw">@sqldbawithbeard</a> <a href="https://twitter.com/cl?ref_src=twsrc%5Etfw">@cl</a> <a href="https://twitter.com/dbachecks?ref_src=twsrc%5Etfw">@dbachecks</a> <a href="https://t.co/a3PCkAeaV5">pic.twitter.com/a3PCkAeaV5</a></p>&mdash; Jan Mulkens (@JanMulkens) <a href="https://twitter.com/JanMulkens/status/972518661679452161?ref_src=twsrc%5Etfw">March 10, 2018</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

You can install it from the PowerShell Gallery like all good modules using

    Install-Module EditorServicesCommandSuite -Scope CurrentUser

and then add it to your VSCode PowerShell profile usually found at `C:\Users\USERNAME\Documents\WindowsPowerShell\Microsoft.VSCode_profile.ps1`

```
\# Place this in your VSCode profile
Import-Module EditorServicesCommandSuite
Import-EditorCommand -Module EditorServicesCommandSuite
```

and now creating a splat is as easy as this.

Write the command, leave the cursor on a parameter, hit F1 – Choose PowerShell : Show Additional Commands (or use a keyboard shortcut) type splat press enter. Done 🙂

<DIV id=v-pfRz040C-1 class=video-player><IFRAME height=362 src="https://videopress.com/embed/pfRz040C?hd=1&amp;loop=0&amp;autoPlay=0&amp;permalink=1" frameBorder=0 width=630 allowfullscreen></IFRAME>
<SCRIPT src="https://s0.wp.com/wp-content/plugins/video/assets/js/next/videopress-iframe.js"></SCRIPT>
</DIV></DIV>

So very easy 🙂

Happy Splatting 🙂


