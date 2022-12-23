---
title: ".NET PowerShell Notebooks – Using Pester"
date: "2020-02-22" 
categories:
  - Blog
  - Jupyter Notebooks
  - Azure Data Studio
  - Pester

tags:
  - net
  - GitHub 
  - pester
  - dbastackexchange
  - PowerShell
  - Jupyter Notebooks
  - SQL Agent Jobs
  - Azure Data Studio
  - dotnet interactive



image: /assets/uploads/2020/02/image-16.png

---
[My last post](http://localhost:4001/blog/jupyter%20notebooks/azure%20data%20studio/powershell/pwsh/dbatools/dbachecks/new-net-notebooks-are-here-powershell-7-notebooks-are-here/) had a lot of information about the new .NET PowerShell notebooks including installation instructions.

.NET Notebooks are Jupyter Notebooks that use .NET core to enable C#, F# and PowerShell kernels.

Use Cases
---------

One of the main benefits that I see for Jupyter Notebooks for Ops folk is that the results of the query are saved with the notebook. This makes them fantastic for Incident resolution.

If you have an incident at 3am and you know that you will need that information in the wash up meeting the next day instead of copying and pasting results into a OneNote document or a text file, you can simply run the queries in a notebook and save it.

In the meeting, you can simply open the notebook and the results will be available for everyone to see.

Even better, if you have a template notebook for those scenarios and you can then compare them to previous occurrences.

Using Pester
------------

Using Pester to validate that an environment is as you expect it is a good resource for incident resolution, potentially enabling you to quickly establish an area to concentrate on for the issue. However, if you try to run Pester in a .NET Notebook you will receive an error
<PRE class=wp-block-preformatted>Describe: 
Line |
   3 | Describe "Checking Problem ...... by $($ENV:USERDOMAIN) $($ENV:UserName)" {

     | ^ The 'Describe' command was found in the module 'Pester', but the module could not be loaded. For more information, run 'Import-Module Pester'.</PRE>
<H2>Fixing it</H2>
<P>When you try to <CODE>Import-Module Pester</CODE> you get the following error</P><PRE class=wp-block-preformatted>Get-Command: C:\Users\mrrob\Documents\PowerShell\Modules\Pester\4.9.0\Pester.psm1
Line |
  94 |     $script:SafeCommands['Get-CimInstance'] = Get-Command -Name Get-CimInstance -Module CimCmdlets @safeCommandLookupParameters

     |                                               ^ The term 'Get-CimInstance' is not recognized as the name of a
     | cmdlet, function, script file, or operable program. Check the spelling of the name, or if a path was included,
     | verify that the path is correct and try again.
 Import-Module: The module to process 'Pester.psm1', listed in field 'ModuleToProcess/RootModule' of module manifest 'C:\Users\mrrob\Documents\PowerShell\Modules\Pester\4.9.0\Pester.psd1' was not processed because no valid module was found in any module directory. </PRE>
Thats odd, why is it failing there? Dongbo Wang from the PowerShell team explains [in the issue that I raised](https://github.com/dotnet/interactive/issues/136)

> Yes, it was the CimCmdlets module from the system32 module path that got imported (via the `WinCompat` feature added in PS7). This is because currently the PS kernel don’t ship all the built-in modules along with it …  
> The built-in modules are not published anywhere and are platform specific, it’s hard for an application that host powershell to ship them along. We have the issue [PowerShell/PowerShell#11783](https://github.com/PowerShell/PowerShell/issues/11783) to track this work.


[You can see all of this including all the results in this notebook that I have created and shared on GitHub and also below as a gist to embed in this blog post](https://github.com/SQLDBAWithABeard/Presentations/blob/master/Notebooks/DotNet%20Notebook/01-PesterWontRun.ipynb)

Sharing Code AND Results 🙂
---------------------------

  
Notebooks – A brilliant way of sharing what you did and the results that you got enabling others to follow along. You can do this with this Notebook. Download it and open it in your Jupyter Lab and you will be able to run it and see all of the errors and the fix on your machine.
<SCRIPT src="https://gist.github.com/SQLDBAWithABeard/6f911ae171528181d226a11e9a24ad05.js"></SCRIPT>


