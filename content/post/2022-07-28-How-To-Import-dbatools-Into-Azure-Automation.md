---
title: "How to import dbatools from a zip file from the GitHub release into Azure Automation Modules without an error"
categories:
  - Blog
  - PowerShell
  - dbatools

tags:
  - automate
  - automation
  - dbatools
  - PowerShell
  - Azure Automation
  - Azure
  - pwsh

header:
  teaser: https://images.unsplash.com/photo-1614791962365-7590111b1b1c?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1469&q=80
---
There are a number of methods to import PowerShell modules into Azure automation [as described in the documentation here](https://docs.microsoft.com/en-us/azure/automation/shared-resources/modules?WT.mc_id=DP-MVP-5002693)

You may however miss an important piece of information hidden in that documentation if you are uploading a module from a GitHub release instead of via the [PowerShell Gallery](https://www.powershellgallery.com/?WT.mc_id=DP-MVP-5002693). The name that you refer to the module must match the module name and module folder name in the zip file.

# Method one - from Gallery

This is my preferred method for importing modules into Azure Automation accounts, the only bothersome part is remembering to do it twice, once for 5.1 and once for 7.1 as I am sure that if I forget that will be the one module that I will need!

## Find the module

Go to the Module page for the automation account and then Add module and browse the gallery and search for [dbatools](dbatools.io) (other modules are available!) and install it

![image](https://user-images.githubusercontent.com/6729780/181550108-e6096986-3392-4585-a57a-5c515c2890bf.png)

It will take a few moments to install but you will see it in the list with a green tick once it has imported.

![image](https://user-images.githubusercontent.com/6729780/181548887-0ec695e4-41b9-45b3-8ab3-a004968c2323.png)#

Then it is available in all of my PowerShell 7.1 runbooks in my automation account - Here I have just run `Get-DbaToolsConfig` in a test runbook to prove that the module has imported

![image](https://user-images.githubusercontent.com/6729780/181550937-7e89c7b3-31e8-4af1-b965-c82f2f63562f.png)

# Method two - using the zip file from a GitHub Release

Sometimes you may wish to not use the PowerShell Gallery to import the modules, maybe you have a custom module that you are not ready to upload to the gallery or maybe the module is just internally developed and not available on the [PowerShell Gallery](https://www.powershellgallery.com/?WT.mc_id=DP-MVP-5002693). In this scenario, you can still import hte module so that it can be used by your runbooks.

To demonstrate, I will remove the dbatools module from the Automation Account

![image](https://user-images.githubusercontent.com/6729780/181553061-9be2da4d-344d-4027-aa7f-902445cee12b.png)

and download the latest release from GitHub directly

[https://github.com/dataplat/dbatools/releases/tag/v1.1.118](https://github.com/dataplat/dbatools/releases/tag/v1.1.118)

If you are unable to use the PowerShell Gallery to get the latest dbatools release, I would always use the official signed release.

You can then upload the zip from the same Modules page using the Browse for file but here is the *important bit* You must update the name of the module. By default Azure will set the name to match the name of the zip file as that is what is expected and indeed mentioned in the [Microsoft documentation here ](https://docs.microsoft.com/en-us/azure/automation/shared-resources/modules#author-modules?WT.mc_id=DP-MVP-5002693)

![image](https://user-images.githubusercontent.com/6729780/181561112-6aecd5e3-efaa-4b2a-84d7-f7e521035d04.png)

and once it is imported successfully and I have a green tick

![image](https://user-images.githubusercontent.com/6729780/181564377-df8c707e-24ec-43eb-8d57-702fcb39400b.png)

I can run the test - Again I just ran `Get-DbaToolsConfig`

![image](https://user-images.githubusercontent.com/6729780/181569077-2b2e59e2-4bf1-46b6-851f-2e624cf9c43c.png)

This method will work with both PowerShell 5.1 and PowerShell 7.1, you will just have to upload the zip (and remember to rename the module entry) twice.

![image](https://user-images.githubusercontent.com/6729780/181571123-8acb8ff5-7b36-4b62-91f7-34b3df36a1d8.png)



![image](https://user-images.githubusercontent.com/6729780/181571518-909ecc6f-9270-45d2-a7b5-0de4406c88c4.png)

# When it goes wrong

If you do not rename the module correctly but leave it as the name of file `dbatools-signed` in this example

![image](https://user-images.githubusercontent.com/6729780/181571939-b881b4bc-4449-4569-b71a-66142436158a.png)
.

![image](https://user-images.githubusercontent.com/6729780/181572041-2fe18929-cc14-40ae-b654-62653206903f.png)


> Error importing the module dbatools-signed. Import failed with the following error:   
> Orchestrator.Shared.AsyncModuleImport.ModuleImportException: Cannot import the module of name dbatools-signed, as the module structure was invalid. at   
> Orchestrator.Activities.GetModuleMetadataAfterValidationActivity.ExecuteInternal(CodeActivityContext context, Byte[] moduleContent, String moduleName, ModuleLanguage moduleLanguage) at  
 > Orchestrator.Activities.GetModuleMetadataAfterValidationActivity.Execute(CodeActivityContext context) at  
 > System.Activities.CodeActivity.InternalExecute(ActivityInstance instance, ActivityExecutor executor, BookmarkManager bookmarkManager) at System.Activities.Runtime.ActivityExecutor.ExecuteActivityWorkItem.ExecuteBody(ActivityExecutor executor, BookmarkManager bookmarkManager, Location resultLocation)  

If you get that, just re-upload the zip file and use the correct name in the form.

Happy Automating
