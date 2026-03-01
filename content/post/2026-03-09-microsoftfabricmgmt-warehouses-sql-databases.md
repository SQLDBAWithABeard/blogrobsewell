---
title: "MicrosoftFabricMgmt: Warehouses and SQL Databases"
date: "2026-03-09"
slug: "microsoftfabricmgmt-warehouses-and-sql-databases"
categories:
  - Blog
  - Microsoft Fabric
  - PowerShell
tags:
  - PowerShell
  - Microsoft Fabric
  - MicrosoftFabricMgmt
  - Automation
  - Warehouse
  - SQL Database
image: assets/uploads/2026/03/microsoftfabricmgmt-warehouses.png
---

## Introduction

Microsoft Fabric has two SQL-queryable storage options beyond the Lakehouse: the **Fabric Warehouse** (a fully managed cloud data warehouse) and the **Fabric SQL Database** (a transactional database with familiar SQL Server semantics). Both are first-class Fabric items, and MicrosoftFabricMgmt can manage both.

Last week we covered [Lakehouses](https://blog.robsewell.com/blog/microsoftfabricmgmt-lakehouses/). Today we look at the other two members of the storage family.

## Fabric Warehouses

A Fabric Warehouse is a cloud-scale data warehouse built on top of OneLake. It supports full T-SQL and is designed for analytical workloads — reporting, BI, and data transformation at scale.

### Getting Warehouses

```powershell
# All Warehouses in a workspace
Get-FabricWarehouse -WorkspaceId $workspace.id

# A specific Warehouse by name
Get-FabricWarehouse -WorkspaceId $workspace.id -WarehouseName "Sales DW"

# All Warehouses across all workspaces
Get-FabricWorkspace | Get-FabricWarehouse
```

### Creating a Warehouse

```powershell
$warehouse = New-FabricWarehouse `
    -WorkspaceId $workspace.id `
    -WarehouseName "SalesDW" `
    -WarehouseDescription "Sales analytics data warehouse"

Write-Host "Created Warehouse: $($warehouse.displayName) ($($warehouse.id))"
```

### Removing a Warehouse

```powershell
Remove-FabricWarehouse `
    -WorkspaceId $workspace.id `
    -WarehouseId $warehouse.id `
    -Confirm:$false
```

## Fabric SQL Databases

The Fabric SQL Database is a transactional database — SQL Server semantics, row-level storage, and OLTP patterns. It is well-suited for applications that need a relational database without managing infrastructure.

### Getting SQL Databases

```powershell
# All SQL Databases in a workspace
Get-FabricSQLDatabase -WorkspaceId $workspace.id

# A specific SQL Database by name
Get-FabricSQLDatabase -WorkspaceId $workspace.id -SQLDatabaseName "AppData"

# All SQL Databases across all workspaces
Get-FabricWorkspace | Get-FabricSQLDatabase
```

### Creating a SQL Database

```powershell
$sqlDb = New-FabricSQLDatabase `
    -WorkspaceId $workspace.id `
    -SQLDatabaseName "ApplicationDB" `
    -SQLDatabaseDescription "Application transactional database"

Write-Host "Created SQL Database: $($sqlDb.displayName) ($($sqlDb.id))"
```

### Removing a SQL Database

```powershell
Remove-FabricSQLDatabase `
    -WorkspaceId $workspace.id `
    -SQLDatabaseId $sqlDb.id `
    -Confirm:$false
```

## Warehouse vs SQL Database vs Lakehouse

| Need | Reach For |
|------|-----------|
| Analytical queries, BI, reporting at scale | **Warehouse** |
| Transactional workloads, OLTP, application data | **SQL Database** |
| Big data storage, Spark processing, Delta tables | **Lakehouse** |
| SQL access to Lakehouse data without duplication | **Lakehouse SQL endpoint** |

In practice, a well-designed Fabric environment often uses all three. The Lakehouse holds raw and curated data. The Warehouse serves as the analytical layer for Power BI. The SQL Database backs any application that needs row-level transactional storage.

## A Combined Provisioning Script

```powershell
$ws = Get-FabricWorkspace -WorkspaceName "DataPlatform-prod"

# Create the Lakehouse for raw data
$lh = New-FabricLakehouse -WorkspaceId $ws.id -LakehouseName "Raw"

# Create the Warehouse for analytics
$wh = New-FabricWarehouse -WorkspaceId $ws.id -WarehouseName "Analytics"

# Create the SQL Database for application data
$db = New-FabricSQLDatabase -WorkspaceId $ws.id -SQLDatabaseName "AppData"

Write-PSFMessage -Level Host -Message @"
Created in $($ws.displayName):
  Lakehouse:    $($lh.displayName)
  Warehouse:    $($wh.displayName)
  SQL Database: $($db.displayName)
"@
```

## Tomorrow

Tomorrow we look at Notebooks and Data Pipelines — the compute and orchestration layer of your Fabric environment. Fair warning: there are two kinds of "pipeline" at play, and I will explain why that is less confusing than it sounds. See you then.
