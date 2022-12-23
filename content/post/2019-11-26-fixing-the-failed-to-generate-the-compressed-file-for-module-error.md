---
title: "Fixing the Failed to generate the compressed file for module dotnet.exe error when deploying to the PowerShell Gallery using Azure DevOps"
date: "2019-11-26" 
categories:
  - dbachecks
  - Blog
  - Jupyter Notebooks
  - Azure Data Studio
  - PowerShell

tags:
  - adsnotebook
  - dbachecks
  - GitHub 
  - PowerShell
  - Jupyter Notebooks
  - Azure Data Studio


image: /assets/uploads/2019/11/image-40.png

---

# Fixing the Failed to generate the compressed file for module C:\Program Files\dotnet\dotnet.exe error when deploying to the PowerShell Gallery using Azure DevOps
The PowerShell module for validating your SQL Server estate [dbachecks](http://beard.media/dbachecks) is deployed via [Azure DevOps, you can see how it is working (or not) via this link](https://dev.azure.com/sqlcollaborative/dbachecks/_release?_a=releases&view=mine&definitionId=2)

Grrr Automation for the Lose!
-----------------------------

Until recently, this had worked successfully. In the last few weeks I have been receiving errors

    Exception : Microsoft.PowerShell.Commands.WriteErrorException: Failed to generate the compressed file for module 'C:\Program Files\dotnet\dotnet.exe failed to pack: error
    C:\Program Files\dotnet\sdk\3.0.100\Sdks\NuGet.Build.Tasks.Pack\build\NuGet.Build.Tasks.Pack.targets(198,5): error : 
    2 Index was outside the bounds of the array. 
     [C:\Users\VssAdministrator\AppData\Local\Temp\cbc14ba6-5832-46fd-be89-04bb552a83ac\Temp.csproj]
    '.
    At C:\Program Files\WindowsPowerShell\Modules\PowerShellGet\2.2.1\PSModule.psm1:10944 char:17
    20       Publish-PSArtifactUtility @PublishPSArtifactUtility_Param ...
                  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: (:) [Write-Error], WriteErrorException
    2019-11-25T22:44:46.8459493Z     + FullyQualifiedErrorId : FailedToCreateCompressedModule,Publish-PSArtifactUtility

You can see these errors in the [release pipeline logs here](https://dev.azure.com/sqlcollaborative/dbachecks/_apps/hub/ms.vss-releaseManagement-web.cd-release-progress?_a=release-environment-logs&releaseId=127&environmentId=127)

Confusion
---------

This was very frustrating as it was stopping the continuous delivery to the PowerShell Gallery. It was even more confusing as I was successfully deploying the [ADSNotebook module](http://beard.media/ADSNotebook) to the gallery using the same method as [you can see here](https://dev.azure.com/sqlcollaborative/ADSSQLNotebook/_build/results?buildId=541).

Raise an Issue on GitHub
------------------------

I went and looked at the [PowerShellGet GitHub repository](https://github.com/PowerShell/PowerShellGet/) and opened an [issue](https://github.com/PowerShell/PowerShellGet/issues/554) I also found [another issue regarding Required Modules](https://github.com/PowerShell/PowerShellGet/issues/551)

But this doesn't help to get dbachecks released.

Just Try to Make it Work
------------------------

I asked the wonderful folk in the [PowerShell Slack channel](http://powershell.slack.com) – Through the magic of automation, you can also interact with them via the powershellhelp channel in the [SQL Server Slack](http://beard.media/sqlslack) as well but there were no answers that could assist.

So I had to go searching for an answer. PowerShellGet uses [nuget](https://www.nuget.org/) for package management. I found that if I downloaded an earlier version and placed it in my user profile (in the right location) I could publish the module.

I found this out by removing the nuget.exe from anywhere useful on the machine and trying to publish the module. The error message says

    NuGet.exe upgrade is required to continue
    This version of PowerShellGet requires minimum version '4.1.0' of NuGet.exe to publish an item to the NuGet-based repositories. NuGet.exe must be available in 
    'C:\ProgramData\Microsoft\Windows\PowerShell\PowerShellGet\' or 'C:\Users\BeardyMcBeardFace\AppData\Local\Microsoft\Windows\PowerShell\PowerShellGet\', or under 
    one of the paths specified in PATH environment variable value. NuGet.exe can be downloaded from https://aka.ms/psget-nugetexe. For more information, see 
    https://aka.ms/installing-powershellget . Do you want PowerShellGet to upgrade to the latest version of NuGet.exe now?

If I said yes then I got the latest version and the error continued.

However, on my laptop I can go to the [nuget downloads page](https://www.nuget.org/downloads) and download an earlier version and place it in one of those paths then I could publish the module.

Can I Automate it?
------------------

I would rather not have to deploy manually though, and as I use hosted agents my access to the operating system is limited so I wondered if I could place the nuget.exe in the user profile and it would get used or if it would look for the the latest one. Turns out it uses the one in the user profile 🙂

So now I have this code as a step in my Azure DevOps Release pipeline before calling `Publish-Module` and we have automated the releases again.

<SCRIPT src="https://gist.github.com/SQLDBAWithABeard/5d36cd1401f1496f9b09ee3354a4d3d9.js"></SCRIPT>

and now deployments to the PowerShell Gallery are just triggered by the build and the pipeline is green again 🙂

[![](https://blog.robsewell.com/assets/uploads/2019/11/image-40.png)](https://dev.azure.com/sqlcollaborative/dbachecks/_releaseProgress?_a=release-environment-logs&releaseId=129&environmentId=129)

test
