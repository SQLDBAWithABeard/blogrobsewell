---
title: "MicrosoftFabricMgmt: Notebooks and Data Pipelines"
date: "2026-03-10"
slug: "microsoftfabricmgmt-notebooks-and-pipelines"
categories:
  - Blog
  - Microsoft Fabric
  - PowerShell
tags:
  - PowerShell
  - Microsoft Fabric
  - MicrosoftFabricMgmt
  - Automation
  - Notebooks
  - Data Pipelines
image: assets/uploads/2026/03/microsoftfabricmgmt-notebooks.png
---

## Introduction

Before we get into today's content, I need to address the naming situation. There are two completely different things called "pipeline" in this series:

1. **The PowerShell pipeline** — the `|` character that connects cmdlets together, which we covered [earlier](https://blog.robsewell.com/blog/microsoftfabricmgmt-pipeline/)
2. **The Fabric Data Pipeline** — an orchestration tool inside Microsoft Fabric, similar to Azure Data Factory

They share a name and nothing else. Today we are talking about option 2 — Fabric's Notebooks and Data Pipelines, which are the compute and orchestration layer of your Fabric environment.

## Notebooks

Fabric Notebooks are Spark-based notebooks where you write PySpark, Scala, SQL, or R to process data. They are the workhorses of data transformation in Fabric.

### Getting Notebooks

```powershell
# All Notebooks in a workspace
Get-FabricNotebook -WorkspaceId $workspace.id

# A specific Notebook by name
Get-FabricNotebook -WorkspaceId $workspace.id -NotebookName "ETL - Sales Data"

# All Notebooks across all workspaces
Get-FabricWorkspace | Get-FabricNotebook
```

### Creating a Notebook

```powershell
$notebook = New-FabricNotebook `
    -WorkspaceId $workspace.id `
    -NotebookName "ETL_SalesData" `
    -NotebookDescription "Sales data transformation notebook"

Write-Host "Created Notebook: $($notebook.displayName)"
```

### Removing a Notebook

```powershell
Remove-FabricNotebook `
    -WorkspaceId $workspace.id `
    -NotebookId $notebook.id `
    -Confirm:$false
```

### Cross-Workspace Notebook Inventory

```powershell
Get-FabricWorkspace |
    Get-FabricNotebook |
    Select-Object displayName, id, workspaceId |
    Sort-Object displayName |
    Export-Csv -Path "Notebooks_$(Get-Date -Format yyyyMMdd).csv" -NoTypeInformation

Write-Host "Export complete"
```

## Data Pipelines

Fabric Data Pipelines are orchestration tools — they coordinate the execution of activities (Copy Data, Notebook runs, stored procedures, etc.) in a defined sequence. If you have used Azure Data Factory, this will feel familiar.

### Getting Data Pipelines

```powershell
# All Data Pipelines in a workspace
Get-FabricDataPipeline -WorkspaceId $workspace.id

# A specific Data Pipeline by name
Get-FabricDataPipeline -WorkspaceId $workspace.id -DataPipelineName "Daily ETL"

# All Data Pipelines across all workspaces
Get-FabricWorkspace | Get-FabricDataPipeline
```

### Creating a Data Pipeline

```powershell
$pipeline = New-FabricDataPipeline `
    -WorkspaceId $workspace.id `
    -DataPipelineName "DailyETL" `
    -DataPipelineDescription "Daily data transformation pipeline"

Write-Host "Created Data Pipeline: $($pipeline.displayName)"
```

### Removing a Data Pipeline

```powershell
Remove-FabricDataPipeline `
    -WorkspaceId $workspace.id `
    -DataPipelineId $pipeline.id `
    -Confirm:$false
```

## Environment Inventory

A combined Notebook and Pipeline inventory is useful for governance:

```powershell
$report = Get-FabricWorkspace | ForEach-Object {
    $ws = $_
    $notebooks = Get-FabricNotebook -WorkspaceId $ws.id
    $pipelines = Get-FabricDataPipeline -WorkspaceId $ws.id

    [PSCustomObject]@{
        Workspace = $ws.displayName
        Notebooks = ($notebooks | Measure-Object).Count
        Pipelines = ($pipelines | Measure-Object).Count
    }
}

$report | Sort-Object Workspace | Format-Table -AutoSize
```

## Tomorrow

Tomorrow we look at RBAC — how to manage who has access to what in your Fabric workspaces. Roles, assignments, and some useful patterns for keeping your permissions consistent. See you then.
