---
title: "MicrosoftFabricMgmt: The PowerShell Pipeline - Idiomatic Automation"
date: "2026-03-02"
slug: "microsoftfabricmgmt-pipeline"
categories:
  - Blog
  - Microsoft Fabric
  - PowerShell
tags:
  - PowerShell
  - Microsoft Fabric
  - MicrosoftFabricMgmt
  - Automation
  - Pipeline
image: assets/uploads/2026/02/microsoftfabricmgmt-pipeline.png
---

## Introduction

Last week I showed you [how to work with workspaces](https://blog.robsewell.com/blog/microsoftfabricmgmt-workspaces/) — creating, updating, removing, assigning capacities. But we were doing each operation in isolation. Today I want to show you what happens when you connect those operations together using the PowerShell pipeline.

This is one of my favourite aspects of how Jess Pomfret [B](https://jesspomfret.com) [S](https://bsky.app/profile/jpomfret.co.uk) [L](https://www.linkedin.com/in/jpomfret) and I designed the module. Every cmdlet that makes sense in a pipeline is built to work in one.

## How It Works Under the Hood

The magic is `ValueFromPipelineByPropertyName` combined with parameter aliases. Most cmdlets that accept a `WorkspaceId` parameter declare it like this:

```powershell
[Parameter(ValueFromPipelineByPropertyName = $true)]
[Alias('id')]
[string]$WorkspaceId
```

That `Alias('id')` is the key. When `Get-FabricWorkspace` returns workspace objects, each one has an `id` property. PowerShell sees that the downstream cmdlet has a `WorkspaceId` parameter with an alias of `id`, and wires them together automatically.

No `ForEach-Object`. No `$_.id`. Just a pipe.

## Basic Pipeline Examples

Get all Lakehouses across all workspaces:

```powershell
Get-FabricWorkspace | Get-FabricLakehouse
```

Get all Notebooks across all workspaces:

```powershell
Get-FabricWorkspace | Get-FabricNotebook
```

Get all role assignments across all workspaces:

```powershell
Get-FabricWorkspace | Get-FabricWorkspaceRoleAssignment
```

These are genuine one-liners that do real work. Compare that to manually calling the REST API for each workspace in a loop.

## Filtering and Acting

The real power comes when you combine the pipeline with filtering. Remove all Lakehouses in development workspaces:

```powershell
Get-FabricWorkspace |
    Where-Object { $_.displayName -like "*-dev" } |
    Get-FabricLakehouse |
    Remove-FabricLakehouse -Confirm:$false
```

Get all Notebooks in a specific workspace and export their details:

```powershell
Get-FabricWorkspace -WorkspaceName "Analytics Platform" |
    Get-FabricNotebook |
    Select-Object displayName, id, @{N='WorkspaceId';E={$_.workspaceId}} |
    Export-Csv -Path "Notebooks_$(Get-Date -Format yyyyMMdd).csv" -NoTypeInformation
```

## Tenant-Wide Inventory

Here is a pattern I use regularly — generating a complete inventory of items across all workspaces:

```powershell
$inventory = Get-FabricWorkspace | ForEach-Object {
    $ws = $_
    @(
        Get-FabricLakehouse -WorkspaceId $ws.id |
            Select-Object @{N='Workspace';E={$ws.displayName}},
                          @{N='ItemName';E={$_.displayName}},
                          @{N='ItemType';E={'Lakehouse'}},
                          id
        Get-FabricWarehouse -WorkspaceId $ws.id |
            Select-Object @{N='Workspace';E={$ws.displayName}},
                          @{N='ItemName';E={$_.displayName}},
                          @{N='ItemType';E={'Warehouse'}},
                          id
    )
}

$inventory | Export-Csv -Path "FabricInventory_$(Get-Date -Format yyyyMMdd).csv" -NoTypeInformation
```

## Counting and Grouping

Because `Get-FabricWorkspace` returns a proper collection, standard PowerShell aggregation works:

```powershell
# Count items per workspace
Get-FabricWorkspace | ForEach-Object {
    [PSCustomObject]@{
        Workspace  = $_.displayName
        Lakehouses = (Get-FabricLakehouse -WorkspaceId $_.id | Measure-Object).Count
        Notebooks  = (Get-FabricNotebook -WorkspaceId $_.id | Measure-Object).Count
    }
} | Sort-Object Workspace

# Count workspaces per capacity
Get-FabricWorkspace |
    Group-Object { Resolve-FabricCapacityName -CapacityId $_.capacityId } |
    Select-Object Name, Count |
    Sort-Object Count -Descending
```

## Why This Matters

Pipeline support transforms a collection of individual cmdlets into a composable automation toolkit. You are not just managing one workspace or one Lakehouse — you are managing your entire Fabric estate with readable, maintainable PowerShell.

Tomorrow we look at help and discovery — with over 295 cmdlets in the module, knowing how to find what you need quickly is a skill in itself. See you then.
