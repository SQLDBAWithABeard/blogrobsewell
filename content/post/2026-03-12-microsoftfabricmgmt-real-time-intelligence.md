---
title: "MicrosoftFabricMgmt: Real-Time Intelligence - Eventhouses and Eventstreams"
date: "2026-03-12"
slug: "microsoftfabricmgmt-real-time-intelligence"
categories:
  - Blog
  - Microsoft Fabric
  - PowerShell
tags:
  - PowerShell
  - Microsoft Fabric
  - MicrosoftFabricMgmt
  - Automation
  - Real-Time Intelligence
  - Eventhouse
  - Eventstream
image: assets/uploads/2026/03/microsoftfabricmgmt-rti.png
---

## Introduction

Real-Time Intelligence (RTI) is Microsoft Fabric's answer to streaming data workloads. If you are ingesting telemetry, IoT data, clickstreams, or any high-velocity data that needs querying with low latency, this is the part of Fabric you want. MicrosoftFabricMgmt supports the full set of RTI resources: Eventhouses, KQL Databases, KQL Dashboards, KQL Querysets, and Eventstreams.

## Eventhouses

An Eventhouse is the container for Real-Time Intelligence data. Think of it as the workspace-level home for your KQL databases — you create an Eventhouse first, then create KQL Databases inside it.

### Getting Eventhouses

```powershell
# All Eventhouses in a workspace
Get-FabricEventhouse -WorkspaceId $workspace.id

# A specific Eventhouse by name
Get-FabricEventhouse -WorkspaceId $workspace.id -EventhouseName "TelemetryStore"

# All Eventhouses across all workspaces
Get-FabricWorkspace | Get-FabricEventhouse
```

### Creating an Eventhouse

```powershell
$eventhouse = New-FabricEventhouse `
    -WorkspaceId $workspace.id `
    -EventhouseName "TelemetryStore" `
    -EventhouseDescription "Real-time telemetry data store"

Write-Host "Created Eventhouse: $($eventhouse.displayName)"
```

### Removing an Eventhouse

```powershell
Remove-FabricEventhouse `
    -WorkspaceId $workspace.id `
    -EventhouseId $eventhouse.id `
    -Confirm:$false
```

## KQL Databases

KQL Databases live inside Eventhouses. They are where you actually store and query data using the Kusto Query Language.

```powershell
# All KQL Databases in a workspace
Get-FabricKQLDatabase -WorkspaceId $workspace.id

# Create a KQL Database
$kqlDb = New-FabricKQLDatabase `
    -WorkspaceId $workspace.id `
    -KQLDatabaseName "TelemetryDB" `
    -ParentEventhouseItemId $eventhouse.id

Write-Host "Created KQL Database: $($kqlDb.displayName)"
```

## Eventstreams

An Eventstream is an event ingestion pipeline — it connects event sources (Event Hubs, IoT Hub, Kafka, etc.) to destinations (Eventhouse, Lakehouse, Data Activator). MicrosoftFabricMgmt lets you create and manage Eventstreams as Fabric items.

```powershell
# All Eventstreams in a workspace
Get-FabricEventstream -WorkspaceId $workspace.id

# A specific Eventstream by name
Get-FabricEventstream -WorkspaceId $workspace.id -EventstreamName "IoTIngestion"

# Create an Eventstream
$eventstream = New-FabricEventstream `
    -WorkspaceId $workspace.id `
    -EventstreamName "IoTIngestion" `
    -EventstreamDescription "IoT device event ingestion"

# Remove an Eventstream
Remove-FabricEventstream `
    -WorkspaceId $workspace.id `
    -EventstreamId $eventstream.id `
    -Confirm:$false
```

## RTI Inventory

For a governance view of your real-time infrastructure:

```powershell
$report = Get-FabricWorkspace | ForEach-Object {
    $ws = $_
    [PSCustomObject]@{
        Workspace    = $ws.displayName
        Eventhouses  = (Get-FabricEventhouse -WorkspaceId $ws.id | Measure-Object).Count
        KQLDatabases = (Get-FabricKQLDatabase -WorkspaceId $ws.id | Measure-Object).Count
        Eventstreams = (Get-FabricEventstream -WorkspaceId $ws.id | Measure-Object).Count
    }
} | Where-Object { $_.Eventhouses -gt 0 -or $_.Eventstreams -gt 0 }

$report | Sort-Object Workspace | Format-Table -AutoSize
```

This quickly shows you which workspaces have real-time workloads — useful for capacity planning and governance.

## Tomorrow

Tomorrow we look at the Admin API — how to get a tenant-wide view of workspaces and items that goes beyond what you see as a workspace member. See you then.
