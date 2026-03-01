---
title: "MicrosoftFabricMgmt: Lakehouses - Working with Fabric's Data Foundation"
date: "2026-03-06"
slug: "microsoftfabricmgmt-lakehouses"
categories:
  - Blog
  - Microsoft Fabric
  - PowerShell
tags:
  - PowerShell
  - Microsoft Fabric
  - MicrosoftFabricMgmt
  - Automation
  - Lakehouse
image: assets/uploads/2026/03/microsoftfabricmgmt-lakehouses.png
---

## Introduction

The Lakehouse is one of the foundational items in Microsoft Fabric. It is where your data lives — a unified storage layer that combines the flexibility of a data lake with the structure of a data warehouse, built on top of OneLake. If you are managing a Fabric environment at any scale, you will be creating, managing, and occasionally removing Lakehouses regularly.

MicrosoftFabricMgmt makes this straightforward. We covered [error handling and retry logic](https://blog.robsewell.com/blog/microsoftfabricmgmt-error-handling/) earlier this week — today we put those patterns to work with real resources.

## Getting Lakehouses

With a workspace in hand, getting Lakehouses is simple:

```powershell
# All Lakehouses in a workspace
Get-FabricLakehouse -WorkspaceId $workspace.id

# A specific Lakehouse by name
Get-FabricLakehouse -WorkspaceId $workspace.id -LakehouseName "Sales Data"
```

Thanks to the intelligent output formatting we discussed [earlier in the series](https://blog.robsewell.com/blog/microsoftfabricmgmt-goodbye-guids/), the results show Capacity Name, Workspace Name, and Lakehouse Name in a readable table — no GUID hunting required.

## Getting Lakehouses Across All Workspaces

This is where the pipeline really earns its keep:

```powershell
# All Lakehouses across every workspace you have access to
Get-FabricWorkspace | Get-FabricLakehouse
```

One line. No loops. No manual workspace ID management. This is exactly the kind of idiomatic PowerShell automation the module is designed for.

## Creating a Lakehouse

```powershell
$workspace = Get-FabricWorkspace -WorkspaceName "Analytics Dev"

$lakehouse = New-FabricLakehouse `
    -WorkspaceId $workspace.id `
    -LakehouseName "SalesData"

Write-Host "Created Lakehouse: $($lakehouse.displayName) ($($lakehouse.id))"
```

The module waits for the Lakehouse creation to complete before returning — Fabric creates Lakehouses asynchronously under the hood, but the cmdlet handles the polling for you.

## Creating Lakehouses with Schema Enabled

If you want to use managed table schemas in your Lakehouse, you can enable it at creation:

```powershell
$lakehouse = New-FabricLakehouse `
    -WorkspaceId $workspace.id `
    -LakehouseName "StructuredData" `
    -EnableSchemas
```

Schema support allows you to organise tables into named schemas — for example, a `raw` schema for ingested data and a `curated` schema for cleaned, transformed data. Much nicer than a flat list of tables.

## Removing a Lakehouse

```powershell
Remove-FabricLakehouse -WorkspaceId $workspace.id -LakehouseId $lakehouse.id
```

As with all Remove cmdlets, this asks for confirmation by default. Skip it in automation:

```powershell
Remove-FabricLakehouse `
    -WorkspaceId $workspace.id `
    -LakehouseId $lakehouse.id `
    -Confirm:$false
```

## A Practical Pattern: Dev/Test/Prod Lakehouses

Here is a pattern I use when setting up a standard data platform environment:

```powershell
$capacityId = (Get-FabricCapacity -CapacityName "My Fabric Capacity").id
$projectName = "SalesAnalytics"

foreach ($env in @("dev", "test", "prod")) {
    # Create workspace
    $ws = New-FabricWorkspace `
        -WorkspaceName "$projectName-$env" `
        -WorkspaceDescription "$projectName $env environment"

    Assign-FabricWorkspaceCapacity -WorkspaceId $ws.id -CapacityId $capacityId

    # Create standard Lakehouses
    foreach ($lhName in @("Raw", "Curated", "Presentation")) {
        $lh = New-FabricLakehouse `
            -WorkspaceId $ws.id `
            -LakehouseName $lhName

        Write-PSFMessage -Level Host `
            -Message "Created: $($ws.displayName) / $($lh.displayName)"
    }
}
```

Nine Lakehouses across three workspaces, all with consistent naming, all with proper logging. That is the PowerShell way.

## Inventory and Reporting

```powershell
# Count Lakehouses per workspace
Get-FabricWorkspace |
    ForEach-Object {
        [PSCustomObject]@{
            Workspace  = $_.displayName
            Lakehouses = (Get-FabricLakehouse -WorkspaceId $_.id | Measure-Object).Count
        }
    } |
    Sort-Object Lakehouses -Descending

# Export all Lakehouses to CSV
Get-FabricWorkspace |
    Get-FabricLakehouse |
    Select-Object displayName, id, workspaceId |
    Export-Csv -Path "Lakehouses_$(Get-Date -Format yyyyMMdd).csv" -NoTypeInformation
```

## On Monday

On Monday we look at Warehouses and SQL Databases — two different SQL-queryable storage options in Fabric, and when to reach for each one. See you then.
