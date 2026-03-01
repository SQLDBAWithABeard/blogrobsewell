---
title: "MicrosoftFabricMgmt: The Admin API - Tenant-Wide Visibility"
date: "2026-03-13"
slug: "microsoftfabricmgmt-the-admin-api"
categories:
  - Blog
  - Microsoft Fabric
  - PowerShell
tags:
  - PowerShell
  - Microsoft Fabric
  - MicrosoftFabricMgmt
  - Automation
  - Admin
  - Governance
image: assets/uploads/2026/03/microsoftfabricmgmt-admin.png
---

## Introduction

Everything we have covered so far uses the standard Fabric REST API — you see what you have access to as a workspace member. The Admin API is different. As a Fabric Administrator, it gives you a tenant-wide view of every workspace and every item in your organisation, regardless of whether you are a member of those workspaces.

This is powerful and comes with responsibility. Admin API access should be restricted to the people who genuinely need tenant-wide visibility — typically platform teams, governance teams, and your Fabric capacity administrators.

## Prerequisites

To use the admin cmdlets, you need the **Fabric Administrator** role in Microsoft Entra ID. Without it, these cmdlets will return permission errors.

## Getting All Workspaces (Tenant-Wide)

As a Fabric Admin, you can retrieve every workspace in the tenant:

```powershell
# All workspaces in the tenant
Get-FabricAdminWorkspace

# Filter by capacity
Get-FabricAdminWorkspace | Where-Object { $_.capacityId -eq $targetCapacityId }

# Workspaces with no capacity assigned
Get-FabricAdminWorkspace | Where-Object { -not $_.capacityId }
```

Compare this to `Get-FabricWorkspace`, which returns only the workspaces you are a member of. `Get-FabricAdminWorkspace` returns everything — including workspaces you have never been invited to.

## Getting All Items (Tenant-Wide)

```powershell
# All items of a specific type across the entire tenant
Get-FabricAdminItem -Type Lakehouse

# All Notebooks in the tenant
Get-FabricAdminItem -Type Notebook

# All items in a specific workspace
Get-FabricAdminItem -WorkspaceId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

The `-Type` parameter accepts Fabric item type names: `Lakehouse`, `Warehouse`, `SQLDatabase`, `Notebook`, `DataPipeline`, `Eventhouse`, `Eventstream`, `KQLDatabase`, `Report`, `SemanticModel`, and more.

## Tenant-Wide Inventory

One of the most useful things you can do with admin access is generate a complete picture of what exists in your tenant:

```powershell
$itemTypes = @('Lakehouse', 'Warehouse', 'SQLDatabase', 'Notebook', 'DataPipeline',
               'Eventhouse', 'Eventstream', 'SemanticModel', 'Report')

$inventory = foreach ($type in $itemTypes) {
    $items = Get-FabricAdminItem -Type $type
    [PSCustomObject]@{
        ItemType = $type
        Count    = ($items | Measure-Object).Count
    }
}

$inventory | Sort-Object Count -Descending | Format-Table -AutoSize
```

I run something like this monthly. It gives you a quick health check on what is in the tenant and catches unexpected growth (or unexpected deletion).

## Finding Orphaned Workspaces

An orphaned workspace is one where all Admins have left the organisation. These are surprisingly common in large tenants:

```powershell
Get-FabricAdminWorkspace | Where-Object {
    $roles = Get-FabricWorkspaceRoleAssignment -WorkspaceId $_.id
    ($roles | Where-Object { $_.role -eq "Admin" }).Count -eq 0
}
```

This returns any workspace with no Admin assigned. From here you can decide whether to assign a new Admin, archive the workspace, or investigate further.

## On Monday

That wraps up the week. On Monday we look at auditing — the activity log that records who did what in your Fabric tenant, and how to use it for compliance reporting. See you then.
