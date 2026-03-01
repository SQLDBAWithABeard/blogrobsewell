---
title: "MicrosoftFabricMgmt: Auditing - Activity Logs and Compliance"
date: "2026-03-16"
slug: "microsoftfabricmgmt-auditing"
categories:
  - Blog
  - Microsoft Fabric
  - PowerShell
tags:
  - PowerShell
  - Microsoft Fabric
  - MicrosoftFabricMgmt
  - Automation
  - Auditing
  - Compliance
  - Governance
image: assets/uploads/2026/03/microsoftfabricmgmt-auditing.png
---

## Introduction

Knowing what is in your Fabric tenant is important. Knowing what happened in your Fabric tenant — who did what, when, to which resource — is essential for governance and compliance. Microsoft Fabric's activity log captures user and admin actions across the tenant, and MicrosoftFabricMgmt gives you PowerShell access to it.

Like the [Admin API we covered on Friday](https://blog.robsewell.com/blog/microsoftfabricmgmt-the-admin-api/), audit log access requires Fabric Admin permissions.

## Getting Activity Events

The core cmdlet is `Get-FabricActivityEvent`. It retrieves activity log entries for a specified time window:

```powershell
# Get all activity for the last 24 hours
$startDate = (Get-Date).AddDays(-1).ToString("yyyy-MM-ddTHH:mm:ss")
$endDate = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")

Get-FabricActivityEvent -StartDateTime $startDate -EndDateTime $endDate
```

The activity log API returns events in pages. The cmdlet handles pagination automatically, so you get all events in the time window without managing continuation tokens yourself.

> **Note**: The activity log has a retention period. Check the [Microsoft Fabric documentation](https://learn.microsoft.com/en-us/fabric/admin/track-user-activities?WT.mc_id=DP-MVP-5002693) for the current retention window.

## Filtering Activity Events

```powershell
# Get only ViewReport events (who viewed which reports)
Get-FabricActivityEvent -StartDateTime $startDate -EndDateTime $endDate |
    Where-Object { $_.activity -eq "ViewReport" }

# Get all events for a specific user
Get-FabricActivityEvent -StartDateTime $startDate -EndDateTime $endDate |
    Where-Object { $_.userId -eq "user@yourdomain.com" }

# Get all workspace creation events
Get-FabricActivityEvent -StartDateTime $startDate -EndDateTime $endDate |
    Where-Object { $_.activity -eq "CreateWorkspace" }

# Get all deletion events
Get-FabricActivityEvent -StartDateTime $startDate -EndDateTime $endDate |
    Where-Object { $_.activity -like "*Delete*" }
```

## Daily Audit Export

For compliance, you typically want to export audit logs on a regular schedule. Here is a pattern for exporting the previous day's events:

```powershell
Import-Module MicrosoftFabricMgmt

Set-PSFLoggingProvider -Name logfile -Enabled $true `
    -FilePath "C:\AuditLogs\FabricAuditExport-%Date%.log"

Set-FabricApiHeaders -TenantId (Get-Secret -Name FabricTenantId -AsPlainText)

$yesterday = (Get-Date).AddDays(-1).Date
$startDate = $yesterday.ToString("yyyy-MM-ddTHH:mm:ss")
$endDate = $yesterday.AddDays(1).AddSeconds(-1).ToString("yyyy-MM-ddTHH:mm:ss")

Write-PSFMessage -Level Host `
    -Message "Exporting audit events for $($yesterday.ToString('yyyy-MM-dd'))"

try {
    $events = Get-FabricActivityEvent -StartDateTime $startDate -EndDateTime $endDate

    $exportPath = "C:\AuditLogs\FabricActivity_$($yesterday.ToString('yyyyMMdd')).csv"

    $events |
        Select-Object creationTime, userId, activity, itemName, workspaceName, capacityName |
        Export-Csv -Path $exportPath -NoTypeInformation

    Write-PSFMessage -Level Host `
        -Message "Exported $($events.Count) events to $exportPath"
}
catch {
    Write-PSFMessage -Level Error -Message "Audit export failed" -ErrorRecord $_
}
finally {
    Wait-PSFMessage
}
```

## Summarising Activity

For a quick operational view:

```powershell
$events = Get-FabricActivityEvent -StartDateTime $startDate -EndDateTime $endDate

# Most active users
$events |
    Group-Object userId |
    Sort-Object Count -Descending |
    Select-Object -First 10 Name, Count

# Most common operations
$events |
    Group-Object activity |
    Sort-Object Count -Descending |
    Select-Object Name, Count

# Activity by workspace
$events |
    Where-Object { $_.workspaceName } |
    Group-Object workspaceName |
    Sort-Object Count -Descending |
    Select-Object Name, Count
```

## Connecting Audit Logs to FUAM

If you set up the [Fabric Unified Admin Monitoring (FUAM)](https://blog.robsewell.com/blog/fuam-fabric-unified-admin-monitoring/) solution we covered at the start of this series, you will find that FUAM ingests and visualises these same activity events in a pre-built Power BI dashboard. For routine monitoring, FUAM is the better tool. For custom extracts, compliance exports, or integration with external SIEM systems, PowerShell automation like this gives you full flexibility.

## Tomorrow

Tomorrow we bring everything together — a complete environment provisioning script that draws on everything in this series. See you then.
