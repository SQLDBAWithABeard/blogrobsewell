---
title: "MicrosoftFabricMgmt: Structured Logging with PSFramework"
date: "2026-03-04"
slug: "microsoftfabricmgmt-psframework-logging"
categories:
  - Blog
  - Microsoft Fabric
  - PowerShell
tags:
  - PowerShell
  - Microsoft Fabric
  - MicrosoftFabricMgmt
  - Automation
  - PSFramework
  - Logging
image: assets/uploads/2026/03/microsoftfabricmgmt-logging.png
---

## Introduction

If you have ever come back to a script the next morning and thought "what on earth happened last night?", you understand why logging matters. `Write-Host` and `Write-Verbose` are fine for interactive use, but in automation — scheduled tasks, CI/CD pipelines, long-running jobs — you need something more structured. Something you can query, filter, and persist across sessions.

MicrosoftFabricMgmt uses [PSFramework](https://psframework.org/) for all its internal logging, and that capability is available directly to you.

## How the Module Logs Internally

Every significant action inside MicrosoftFabricMgmt writes a structured log message using `Write-PSFMessage`. You do not need to configure anything to benefit from this — the messages are written automatically as cmdlets run.

The log levels used are:

| Level | Description |
|-------|-------------|
| `Debug` | Detailed internal state, usually not needed day-to-day |
| `Verbose` | What the cmdlet is doing step-by-step |
| `Host` | Summary output, always visible |
| `Warning` | Something unexpected happened but the cmdlet continued |
| `Error` | The cmdlet could not complete its work |

## Viewing the In-Memory Log

PSFramework keeps a rolling in-memory log of all messages from the current session. Access it with:

```powershell
Get-PSFMessage
```

This returns all log entries. You can filter by level, function name, or timestamp:

```powershell
# Show only errors and warnings
Get-PSFMessage | Where-Object { $_.Level -in 'Error', 'Warning' }

# Show messages from the last 5 minutes
Get-PSFMessage | Where-Object { $_.Timestamp -gt (Get-Date).AddMinutes(-5) }

# Show verbose messages from Fabric cmdlets
Get-PSFMessage -Level Verbose | Where-Object { $_.FunctionName -like '*Fabric*' }
```

This is invaluable after running a large automation script. Instead of hoping something printed to the console at the right moment, you can inspect exactly what happened.

## Setting Up File Logging

For persistent logging — which you absolutely want in production — configure a file-based logging provider:

```powershell
# Log to a daily rolling file
Set-PSFLoggingProvider -Name logfile -Enabled $true `
    -FilePath "C:\Logs\FabricAutomation-%Date%.log"

# Now all Write-PSFMessage calls go to the file automatically
Set-FabricApiHeaders -TenantId $tenantId
Get-FabricWorkspace
```

The `%Date%` placeholder creates a new file each day. PSFramework handles rotation, buffering, and file access safely — even in parallel runspaces.

## Using Write-PSFMessage in Your Own Scripts

You can use `Write-PSFMessage` in your own automation scripts alongside the module cmdlets. I do this for anything beyond a quick one-liner:

```powershell
Import-Module MicrosoftFabricMgmt

# Set up file logging for this script run
Set-PSFLoggingProvider -Name logfile -Enabled $true `
    -FilePath "C:\Logs\FabricProvisioning-%Date%.log"

$functionName = 'Invoke-FabricProvisioning'

Write-PSFMessage -Level Host -Message "Starting Fabric provisioning" `
    -FunctionName $functionName

$capacityId = (Get-FabricCapacity -CapacityName "My Fabric Capacity").id
Write-PSFMessage -Level Verbose -Message "Resolved capacity ID: $capacityId" `
    -FunctionName $functionName

foreach ($env in @("dev", "test", "prod")) {
    try {
        $ws = New-FabricWorkspace -WorkspaceName "DataPlatform-$env"
        Write-PSFMessage -Level Host -Message "Created workspace: $($ws.displayName)" `
            -FunctionName $functionName

        Assign-FabricWorkspaceCapacity -WorkspaceId $ws.id -CapacityId $capacityId
        Write-PSFMessage -Level Verbose `
            -Message "Assigned capacity to $($ws.displayName)" `
            -FunctionName $functionName
    }
    catch {
        Write-PSFMessage -Level Error `
            -Message "Failed to create workspace DataPlatform-$env" `
            -ErrorRecord $_ `
            -FunctionName $functionName
    }
}

Write-PSFMessage -Level Host -Message "Provisioning complete" -FunctionName $functionName

# Make sure all log messages are flushed to disk before the script exits
Wait-PSFMessage
```

The `-ErrorRecord $_` parameter is important — it attaches the full exception to the log entry, so you get the stack trace and error details alongside your message. When you review the logs later, you get the complete picture.

## Making Verbose Output Visible During Development

By default, `Write-PSFMessage -Level Verbose` messages are captured in the log but not shown on screen. To see them in real time (great for debugging):

```powershell
$VerbosePreference = 'Continue'
```

Or pass `-Verbose` to individual cmdlets. The module respects standard PowerShell preference variables throughout.

## Inspecting Module Configuration

PSFramework also powers the module's configuration system. You can see all the current settings:

```powershell
Get-PSFConfig -Module MicrosoftFabricMgmt
```

We looked at this in [the getting started post](https://blog.robsewell.com/blog/microsoftfabricmgmt-getting-started/). The retry settings, API timeout, and cache behaviour are all exposed here and can be adjusted with `Set-PSFConfig`.

## Why This Matters

When you are running Fabric automation in a scheduled task at 2 AM, you cannot be there to watch what happens. PSFramework logging means you can open the log file the next morning and see exactly what the script did, where it spent its time, and what (if anything) went wrong. That is the difference between automation you can trust and automation you cross your fingers about.

Tomorrow we look at the other half of resilient automation: error handling and retry logic. What happens when a Fabric API call fails? The module handles a lot of it for you. See you then.
