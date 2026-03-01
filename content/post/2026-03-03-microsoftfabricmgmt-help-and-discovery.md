---
title: "MicrosoftFabricMgmt: Help and Discovery - Finding Your Way Around 295+ Cmdlets"
date: "2026-03-03"
slug: "microsoftfabricmgmt-help-and-discovery"
categories:
  - Blog
  - Microsoft Fabric
  - PowerShell
tags:
  - PowerShell
  - Microsoft Fabric
  - MicrosoftFabricMgmt
  - Automation
image: assets/uploads/2026/03/microsoftfabricmgmt-help.png
---

## Introduction

295 cmdlets is a lot of cmdlets. When I first looked at the full list I had a moment of "where do I even start?" — and I have been using PowerShell for a long time. The good news is that the same skills you use to navigate any well-built PowerShell module work perfectly here. `Get-Command`, `Get-Help`, and tab completion take you a long way.

## Finding Commands with Get-Command

The most direct way to explore what the module offers:

```powershell
# Every cmdlet in the module
Get-Command -Module MicrosoftFabricMgmt

# Just the Get cmdlets
Get-Command -Module MicrosoftFabricMgmt -Verb Get

# Everything related to Lakehouses
Get-Command -Module MicrosoftFabricMgmt -Noun *Lakehouse*

# Find by partial name when you are not sure of the exact noun
Get-Command -Module MicrosoftFabricMgmt -Name *Notebook*
```

That last pattern — using a wildcard on the noun — is what I reach for first when exploring a resource type I have not used yet. `*Notebook*` returns `Get-FabricNotebook`, `New-FabricNotebook`, `Update-FabricNotebook`, and `Remove-FabricNotebook`. You can immediately see the full CRUD surface for that resource.

## Reading the Help

Every cmdlet has full help built in:

```powershell
# Full help including all parameters and notes
Get-Help Get-FabricWorkspace -Full

# Just the examples — often all you need
Get-Help Get-FabricWorkspace -Examples

# List available parameters quickly
Get-Help Get-FabricWorkspace -Parameter *
```

The `-Examples` flag is the most useful for day-to-day work. The examples are practical and show common parameter combinations. When I am picking up a cmdlet I have not used before, I run the examples first to understand the expected usage.

## Tab Completion

Tab completion works throughout the module. After `Get-Fabric`, press Tab to cycle through all `Get-Fabric*` cmdlets. After specifying a cmdlet name, press Tab after a dash to see all available parameters.

```powershell
# Type this and press Tab to cycle through options
Get-Fabric<Tab>

# Type this and press Tab to see parameters
Get-FabricWorkspace -<Tab>
```

This is faster than remembering exact names, and it confirms that a parameter exists before you commit to it.

## The 48 Resource Types

MicrosoftFabricMgmt covers 48 different Fabric resource types. Here is a rough grouping:

**Storage**
- Lakehouse, Warehouse, SQLDatabase, SQLEndpoint

**Compute and Orchestration**
- Notebook, DataPipeline, Dataflow

**Real-Time Intelligence**
- Eventhouse, KQLDatabase, KQLDashboard, KQLQueryset, Eventstream

**Semantic Models and Reporting**
- SemanticModel, Report, PaginatedReport, Dashboard

**Workspace and Access**
- Workspace, WorkspaceRoleAssignment, Capacity

**Admin (tenant-wide)**
- AdminWorkspace, AdminItem, ActivityEvent

To find all cmdlets for any of these:

```powershell
Get-Command -Module MicrosoftFabricMgmt -Noun *Eventhouse*
```

## Quick Inventory of the Module

If you want to get a feel for the shape of the module at a glance:

```powershell
Get-Command -Module MicrosoftFabricMgmt |
    Group-Object Verb |
    Select-Object Name, Count |
    Sort-Object Count -Descending

# Count by resource type (noun without "Fabric" prefix)
Get-Command -Module MicrosoftFabricMgmt |
    Group-Object { $_.Noun -replace '^Fabric', '' } |
    Sort-Object Count -Descending |
    Select-Object -First 20 Name, Count
```

The verb breakdown is telling: Get, New, Remove, and Update are the most common — a clean, predictable CRUD pattern across resource types.

## Tomorrow

Tomorrow we look at logging — how MicrosoftFabricMgmt uses PSFramework to give you structured, queryable log messages that make it easy to understand exactly what your scripts have been doing. See you then.
