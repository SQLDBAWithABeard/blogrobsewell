---
title: "VS Code – Terminal crashes when formatting script"
date: "2018-02-10" 
categories:
  - Blog

tags:
  - GitHub 
  - module
  - PowerShell
  - PSScriptAnalyzer

header:
  teaser: /assets/uploads/2018/02/formatting.gif

---
I love VS Code. I love being able to press ALT + SHIFT + F and format my code.

[![formatting.gif](https://blog.robsewell.com/assets/uploads/2018/02/formatting.gif)](https://blog.robsewell.com/assets/uploads/2018/02/formatting.gif)


The Problem
-----------

[![format error.png](https://blog.robsewell.com/assets/uploads/2018/02/format-error.png)](https://blog.robsewell.com/assets/uploads/2018/02/format-error.png)

I could reproduce it will. This was very frustrating.

Turning on Verbose Logging
--------------------------

To turn on verbose logging for the PowerShell Editor Services go the Cog in the bottom left, click it and then click User Settings.

Search for powershell.developer.editorServicesLogLevel

[![powershell.developer.editorServicesLogLevel.png](https://blog.robsewell.com/assets/uploads/2018/02/powershell.developer.editorServicesLogLevel.png)](https://blog.robsewell.com/assets/uploads/2018/02/powershell.developer.editorServicesLogLevel.png)

If you hover over the left hand channel a pencil will appear, click it and then click replace in settings

[![edit settings.png](https://blog.robsewell.com/assets/uploads/2018/02/edit-settings.png)](https://blog.robsewell.com/assets/uploads/2018/02/edit-settings.png)

This will put the entry in the right hand side where you can change the value. Set it to Verbose and save

[![user settigns.png](https://blog.robsewell.com/assets/uploads/2018/02/user-settigns.png)](https://blog.robsewell.com/assets/uploads/2018/02/user-settigns.png)

a prompt will come up asking if you want to restart PowerShell

[![start a new session.png](https://blog.robsewell.com/assets/uploads/2018/02/start-a-new-session.png)](https://blog.robsewell.com/assets/uploads/2018/02/start-a-new-session.png)

When you restart PowerShell, if you click on  Output and choose PowerShell Extension Logs you will see the path to the log file

[![logfilepath.png](https://blog.robsewell.com/assets/uploads/2018/02/logfilepath.png)](https://blog.robsewell.com/assets/uploads/2018/02/logfilepath.png)
-----------------------------------------------------------------------------------------------------------

Reproduce the error
-------------------

I then reproduced the error and opened the log file this is what I got

> 10/02/2018 09:11:19 \[ERROR\] – Method “OnListenTaskCompleted” at line 391 of C:\\projects\\powershelleditorservices\\src\\PowerShellEditorServices.Protocol\\MessageProtocol\\ProtocolEndpoint.cs
> 
> ProtocolEndpoint message loop terminated due to unhandled exception:
> 
> System.AggregateException: One or more errors occurred. —> System.Management.Automation.CommandNotFoundException: The term ‘Invoke-Formatter’ is not recognized as the name of a cmdlet, function, script file, or operable program. Check the spelling of the name, or if a path was included, verify that the path is correct and try again.  
> at System.Management.Automation.Runspaces.PipelineBase.Invoke(IEnumerable input)  
> at System.Management.Automation.PowerShell.Worker.ConstructPipelineAndDoWork(Runspace rs, Boolean performSyncInvoke)  
> at System.Management.Automation.PowerShell.Worker.CreateRunspaceIfNeededAndDoWork(Runspace rsToUse, Boolean isSync)  
> at System.Management.Automation.PowerShell.CoreInvokeHelper\[TInput,TOutput\](PSDataCollection\`1 input, PSDataCollection\`1 output, PSInvocationSettings settings)  
> at System.Management.Automation.PowerShell.CoreInvoke\[TInput,TOutput\](PSDataCollection\`1 input, PSDataCollection\`1 output, PSInvocationSettings settings)  
> at System.Management.Automation.PowerShell.Invoke(IEnumerable input, PSInvocationSettings settings)  
> at Microsoft.PowerShell.EditorServices.AnalysisService.InvokePowerShell(String command, IDictionary`2 paramArgMap)  
> at System.Threading.Tasks.Task`1.InnerInvoke()  
> at System.Threading.Tasks.Task.Execute()  
> — End of stack trace from previous location where exception was thrown —  
> at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()  
> at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)  
> at Microsoft.PowerShell.EditorServices.AnalysisService.<InvokePowerShellAsync>d__31.MoveNext()  
> — End of stack trace from previous location where exception was thrown —  
> at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()  
> at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)  
> at Microsoft.PowerShell.EditorServices.AnalysisService.<Format>d__22.MoveNext()  
> — End of stack trace from previous location where exception was thrown —  
> at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()

Open an issue on GitHub
-----------------------

I couldnt quickly see what was happening so [I opened an issue](https://github.com/PowerShell/vscode-powershell/issues/1193) on the [vscode-powershell repo](https://github.com/PowerShell/vscode-powershell) by going to issues and clicking new issue and following the instructions

[![new issue.png](https://blog.robsewell.com/assets/uploads/2018/02/new-issue.png)](https://blog.robsewell.com/assets/uploads/2018/02/new-issue.png)

The Resolution
--------------

Keith Hill [b](https://rkeithhill.wordpress.com/) | [t](https://twitter.com/r_keith_hill) pointed me to the resolution. Thank you Keith.

Further up in the log file there is a line where the editor services is loading the PSScriptAnalyzer module and it should have the Invoke-Formatter command exported, but mine was not. It loaded the PsScriptAnalyzer module  from my users module directory

> 10/02/2018 09:11:01 \[NORMAL\] – Method “FindPSScriptAnalyzerModule” at line 354 of C:\\projects\\powershelleditorservices\\src\\PowerShellEditorServices\\Analysis\\AnalysisService.cs
> 
> PSScriptAnalyzer found at C:\\Users\\XXXX\\Documents\\WindowsPowerShell\\Modules\\PSScriptAnalyzer\\1.10.0\\PSScriptAnalyzer.psd1
> 
> 10/02/2018 09:11:01 \[VERBOSE\] – Method “EnumeratePSScriptAnalyzerCmdlets” at line 389 of C:\\projects\\powershelleditorservices\\src\\PowerShellEditorServices\\Analysis\\AnalysisService.cs
> 
> The following cmdlets are available in the imported PSScriptAnalyzer module:  
> Get-ScriptAnalyzerRule  
> Invoke-ScriptAnalyzer

I ran

$Env:PSModulePath.Split(';')

to see the module paths

[![module path.png](https://blog.robsewell.com/assets/uploads/2018/02/module-path.png)](https://blog.robsewell.com/assets/uploads/2018/02/module-path.png)

and looked in the .vscode-insiders\\extensions\\ms-vscode.powershell-1.5.1\\modules directory. There was no PsScriptAnalyzer folder

[![no module.png](https://blog.robsewell.com/assets/uploads/2018/02/no-module.png)](https://blog.robsewell.com/assets/uploads/2018/02/no-module.png)

So I copied the PSScriptAnalyzer folder from the normal VS Code PowerShell Extension module folder into that folder and restarted PowerShell and I had my formatting back again 🙂

I then reset the logging mode in my user settings back to Normal

Thank you Keith
















