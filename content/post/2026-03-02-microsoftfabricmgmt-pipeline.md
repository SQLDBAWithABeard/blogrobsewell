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
image: assets/uploads/2026/03/pipingroles.png
---

## Introduction

Last week I showed you [how to work with workspaces](https://blog.robsewell.com/blog/microsoftfabricmgmt-workspaces/) — creating, updating, removing, assigning capacities. But we were doing each operation in isolation. Today I want to show you what happens when you connect those operations together using the PowerShell pipeline.

This is one of my favourite aspects of PowerShell and therefore it was imperative that Jess Pomfret [B](https://jesspomfret.com) [S](https://bsky.app/profile/jpomfret.co.uk) [L](https://www.linkedin.com/in/jpomfret) and I revamped the module to fully support pipeline operations. Every cmdlet that makes sense in a pipeline is built to work in one.

## How It Works

The PowerShell pipeline is a mechanism for passing output from one cmdlet to another, allowing for the chaining of commands. Unlike traditional command execution where output is displayed or stored as text, the pipeline in PowerShell passes objects directly. This object-based approach makes it possible to work with complex data types and leverage the rich set of properties and methods that objects offer.

## Basic Pipeline Examples

Get all Lakehouses across all workspaces:

```powershell
Get-FabricWorkspace | Get-FabricLakehouse
```

[![PowerShell terminal displaying a pipeline command Get-FabricWorkspace piped to Get-FabricLakehouse, with output showing three rows in a table format: Capacity Name column shows Trial-20260129T113746Z-4 repeated three times, Workspace Name column shows Strava and Data Roles, Item Name column shows Strava_Lakehouse, StagingLakehouseForDataflows_, and lakey, and Type column shows Lakehouse for all rows. The terminal has a dark theme with green text for the command prompt and white text for the table output, with pink accent highlighting the elapsed time 3.944s at the top](../assets/uploads/2026/03/pipelakehouse.png)](../assets/uploads/2026/03/pipelakehouse.png)

Get all Notebooks across all workspaces:

```powershell
Get-FabricWorkspace | Get-FabricNotebook
```

[![PowerShell terminal displaying a pipeline command Get-FabricWorkspace piped to Get-FabricNotebook, with output showing three rows in a table format: Capacity Name column shows Trial-20260129T113746Z-4 repeated three times, Workspace Name column shows Strava and Data Roles, Item Name column shows Strava_Notebook, StagingNotebookForDataflows_, and notey, and Type column shows Notebook for all rows. The terminal has a dark theme with green text for the command prompt and white text for the table output, with pink accent highlighting the elapsed time 3.944s at the top](../assets/uploads/2026/03/pipentotebooks.png)](../assets/uploads/2026/03/pipentotebooks.png)

How about something neater and super useful.

When the Teams message says "Hey, can you tell me who has access to that workspace?" you can now reply with a single command instead of going to the portal and clicking through multiple screens:


```powershell
Get-FabricWorkspace -WorkspaceName $WorkspaceName | Get-FabricWorkspaceRoleAssignment
```

[![PowerShell terminal showing the command Get-FabricWorkspace -WorkspaceName with a spn piped to Get-FabricWorkspaceRoleAssignment, displaying a table with six rows of output. Columns are Capacity Name showing Trial-20260129T1137 repeated, Workspace Name showing with a spn repeated, Principal showing BeardSqlAdmins, ForBooks, Jess Pomfret, John Morehouse, fabric free 4, and a-test-beard-fabric-sp, Type showing Group, Group, User, User, User, ServicePrincipal, and Role showing Contributor, Viewer, Admin, Admin, Admin, Admin. The terminal has a dark theme with green column headers and white text, with execution time of 483ms displayed at the top in pink](../assets/uploads/2026/03/pipingroles.png)](../assets/uploads/2026/03/pipingroles.png)

These are genuine one-liners that do real work. I love it. I have used this sort of flow for many years in SQL Server admin and Azure infrastructure management and it is fantastic to be able to build something the same for Microsoft Fabric.

## The additional beauty of Piping

Of course, piping commands is not just limited to the same module. You can pipe those results to any other functions that can accept that input which means you can easily export to CSV, JSON, HTML, Excel, Word, or even send an email with the results. The possibilities are endless as I have been saying for years — PowerShell is not just a scripting language, it is an automation platform. The pipeline is the heart of that platform.

```powershell
# Export all role assignments for a workspace to CSV
Get-FabricWorkspace -WorkspaceName 'with a spn' |Get-FabricWorkspaceRoleAssignment | Export-Csv -Path s:\roles.csv
-noTypeInformation
# Export all role assignments for a workspace to Excel
Get-FabricWorkspace -WorkspaceName 'with a spn' | Get-FabricWorkspaceRoleAssignment | Export-Excel -Path s:\roles.xlsx -AutoSize -TableName 'RoleAssignments'

```

## Counting and Grouping

You can also pipe to cmdlets that perform calculations or grouping.
```
# Count the number of role assignments for a workspace
Get-FabricWorkspace -WorkspaceName 'with a spn' |Get-FabricWorkspaceRoleAssignment | Group-Object Type,Role

Count the number of item types in each workspace
Get-FabricWorkspace -WorkspaceName 'with a spn' |Get-FabricItem|Group-Object Type
```

```powershell
# Count the number of item types in each workspace
Get-FabricWorkspace | Get-FabricItem | Group-Object Type
```

[![PowerShell terminal displaying a pipeline command Get-FabricWorkspace piped to Get-FabricItem piped to Group-Object Type, with output showing a grouped table format. The Count column displays numerical values, the Name column shows item types including Lakehouse, Notebook, and Dashboard, and a Group column lists the detailed objects. The terminal has a dark theme with green text for the command prompt and white text for the table output, with execution time of 1.234s displayed at the top in pink highlighting the efficiency of the grouped operation](../assets/uploads/2026/03/itemsgroup.png)](../assets/uploads/2026/03/itemsgroup.png)

[![PowerShell terminal displaying a pipeline command Get-FabricWorkspace piped to Get-FabricWorkspaceRoleAssignment piped to Group-Object Type,Role, with output showing a grouped table format. The Count column displays numerical values, the Name column shows role types including Contributor, Viewer, and Admin, and a Group column lists the detailed objects. The terminal has a dark theme with green text for the command prompt and white text for the table output, with execution time of 1.234s displayed at the top in pink highlighting the efficiency of the grouped operation](../assets/uploads/2026/03/rolesgroup.png)](../assets/uploads/2026/03/rolesgroup.png)

## Why This Matters

Pipeline support transforms a collection of individual cmdlets into a composable automation toolkit. You are not just managing one workspace or one Lakehouse — you are managing your entire Fabric estate with readable, maintainable PowerShell.

Tomorrow we look at help and discovery — with over 295 cmdlets in the module, knowing how to find what you need quickly is a skill in itself. See you then.
