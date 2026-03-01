---
title: "MicrosoftFabricMgmt: Error Handling - Retry Logic and Long Running Operations"
date: "2026-03-05"
slug: "microsoftfabricmgmt-error-handling"
categories:
  - Blog
  - Microsoft Fabric
  - PowerShell
tags:
  - PowerShell
  - Microsoft Fabric
  - MicrosoftFabricMgmt
  - Automation
  - Error Handling
image: assets/uploads/2026/03/microsoftfabricmgmt-error-handling.png
---

## Introduction

REST APIs fail. Networks are unreliable. Cloud services have rate limits. If your automation script does not account for this, it will eventually break at the worst possible moment. This is not pessimism — it is production experience.

MicrosoftFabricMgmt has a lot of error handling built in, so you do not have to write it all yourself. Today I want to show you what the module handles automatically, and how to add your own handling on top for the scenarios you care about.

## Built-In Retry Logic

The module includes automatic retry with exponential backoff for transient failures. When an API call returns a `429 Too Many Requests`, `503 Service Unavailable`, or `504 Gateway Timeout`, the module:

1. Checks the `Retry-After` response header (if present) and waits that long
2. Falls back to exponential backoff if no `Retry-After` header is provided
3. Retries up to the configured number of attempts

You can see and adjust these settings:

```powershell
# View current retry configuration
Get-PSFConfig -Module MicrosoftFabricMgmt -Name Api.*

# Increase retry attempts for unreliable networks
Set-PSFConfig -Module MicrosoftFabricMgmt -Name Api.RetryMaxAttempts -Value 5

# Adjust the backoff multiplier
Set-PSFConfig -Module MicrosoftFabricMgmt -Name Api.RetryBackoffMultiplier -Value 2.5
```

This means a typical API call that hits a rate limit does not blow up your script. It waits, retries, and most of the time succeeds. You get the result you asked for, just slightly later than you would have otherwise.

## Long Running Operations

Some Fabric operations do not complete instantly. Creating a Lakehouse, deploying a Notebook, or running a refresh can take seconds to minutes. The Fabric API handles these as Long Running Operations (LROs) — the initial API call returns an operation ID, and you poll for completion.

MicrosoftFabricMgmt handles this transparently for the common create and modify operations. But for cases where you need to track an operation explicitly, you can use `Get-FabricLongRunningOperation`:

```powershell
# Check the status of a running operation
$operation = Get-FabricLongRunningOperation -OperationId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

while ($operation.Status -eq 'Running') {
    Start-Sleep -Seconds 5
    $operation = Get-FabricLongRunningOperation -OperationId $operation.Id
    Write-PSFMessage -Level Verbose -Message "Operation status: $($operation.Status)"
}

if ($operation.Status -eq 'Succeeded') {
    Write-Host "Operation completed successfully"
} else {
    Write-Error "Operation failed: $($operation.Error.Message)"
}
```

In practice, you rarely need to write this loop yourself — the module waits for LROs to complete by default for most create operations. But it is good to know the function is there when you need direct control.

## Writing Your Own Error Handling

For operations where you want to catch specific failures and take action, use standard PowerShell `try/catch`:

```powershell
try {
    $workspace = New-FabricWorkspace -WorkspaceName "ProductionWorkspace"
    Write-PSFMessage -Level Host -Message "Created workspace: $($workspace.displayName)"
}
catch {
    Write-PSFMessage -Level Error -Message "Failed to create workspace" -ErrorRecord $_

    # Decide what to do: stop the script, skip this step, send an alert...
    throw
}
```

The `-ErrorRecord $_` parameter on `Write-PSFMessage` is important — it captures the full exception details in the structured log. When you review the logs later, you get the stack trace and error details alongside your message, not just a string. We covered PSFramework logging in [yesterday's post](https://blog.robsewell.com/blog/microsoftfabricmgmt-psframework-logging/).

## Descriptive Error Messages

One thing I genuinely appreciate about the module is that errors reference names, not GUIDs. If a workspace operation fails, the error message tells you which workspace by display name, not by `f9e8d7c6-b5a4-9876-5432-1fedcba98765`. This sounds minor but it saves real time when debugging at 9 AM after a failed overnight job.

## Checking for Existing Resources

A common pattern in idempotent scripts is checking whether something already exists before trying to create it:

```powershell
# Create workspace only if it does not exist
$existing = Get-FabricWorkspace -WorkspaceName "MyWorkspace" -ErrorAction SilentlyContinue

if (-not $existing) {
    $workspace = New-FabricWorkspace -WorkspaceName "MyWorkspace"
    Write-PSFMessage -Level Host -Message "Created: $($workspace.displayName)"
} else {
    Write-PSFMessage -Level Verbose -Message "Already exists: $($existing.displayName)"
    $workspace = $existing
}
```

`-ErrorAction SilentlyContinue` suppresses the error if the workspace is not found and returns `$null` instead. This makes the "check before create" pattern clean and readable.

## Putting It All Together

Here is a complete pattern for resilient Fabric automation:

```powershell
Import-Module MicrosoftFabricMgmt

# Configure persistent logging
Set-PSFLoggingProvider -Name logfile -Enabled $true `
    -FilePath "C:\Logs\FabricJob-%Date%.log"

# Increase retry attempts for production environments
Set-PSFConfig -Module MicrosoftFabricMgmt -Name Api.RetryMaxAttempts -Value 5

# Authenticate (using stored secret)
Set-FabricApiHeaders -TenantId (Get-Secret -Name FabricTenantId -AsPlainText)

try {
    $ws = Get-FabricWorkspace -WorkspaceName "DataPlatform-prod" -ErrorAction Stop
    Write-PSFMessage -Level Host -Message "Working with workspace: $($ws.displayName)"

    # ... rest of your work here ...
}
catch {
    Write-PSFMessage -Level Error -Message "Script failed" -ErrorRecord $_
    # Could send an alert here, trigger a rollback, or just log and exit cleanly
}
finally {
    Wait-PSFMessage  # Ensure all log messages are flushed to disk
}
```

## Tomorrow

Tomorrow we start looking at the resources themselves — the things that live inside workspaces. We begin with Lakehouses. See you then.
