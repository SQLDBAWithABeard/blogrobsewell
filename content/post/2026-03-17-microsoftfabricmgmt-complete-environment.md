---
title: "MicrosoftFabricMgmt: Building a Complete Fabric Environment with PowerShell"
date: "2026-03-17"
slug: "microsoftfabricmgmt-complete-environment"
categories:
  - Blog
  - Microsoft Fabric
  - PowerShell
tags:
  - PowerShell
  - Microsoft Fabric
  - MicrosoftFabricMgmt
  - Automation
  - DevOps
image: assets/uploads/2026/03/microsoftfabricmgmt-complete-environment.png
---

## Introduction

Over the past few weeks we have worked through the MicrosoftFabricMgmt module piece by piece — workspaces, Lakehouses, Warehouses, Notebooks, RBAC, Real-Time Intelligence, the Admin API, auditing. Today I want to bring it all together into a single, practical script that provisions a complete Fabric environment from scratch.

This is the kind of script I use when setting up a new project. It is repeatable, idempotent (safe to run multiple times), fully logged, and handles errors gracefully.

## What We Are Building

For a "DataPlatform" project, we will create:
- Three workspaces (dev, test, prod) all assigned to a shared capacity
- A three-layer Lakehouse structure in each workspace (Raw, Curated, Presentation)
- A Warehouse in each workspace for analytical queries
- Role assignments for the data engineering team (Members in dev/test, Viewers in prod)

## The Script

```powershell
#requires -Module MicrosoftFabricMgmt

[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$ProjectName  = "DataPlatform",
    [string]$CapacityName = "Shared Fabric Capacity",
    [string]$TeamGroupId  = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
)

# ── Logging ───────────────────────────────────────────────────────────────────
Set-PSFLoggingProvider -Name logfile -Enabled $true `
    -FilePath "C:\Logs\FabricProvisioning-%Date%.log"

$fn = $MyInvocation.MyCommand.Name
Write-PSFMessage -Level Host -Message "Starting: $ProjectName environment provisioning" `
    -FunctionName $fn

# ── Authentication ─────────────────────────────────────────────────────────────
try {
    Set-FabricApiHeaders -TenantId (Get-Secret -Name FabricTenantId -AsPlainText)
    Write-PSFMessage -Level Verbose -Message "Authenticated" -FunctionName $fn
}
catch {
    Write-PSFMessage -Level Error -Message "Authentication failed" `
        -ErrorRecord $_ -FunctionName $fn
    throw
}

# ── Resolve Capacity ───────────────────────────────────────────────────────────
$capacity = Get-FabricCapacity -CapacityName $CapacityName
if (-not $capacity) {
    throw "Capacity '$CapacityName' not found"
}

# ── Environment Loop ───────────────────────────────────────────────────────────
foreach ($env in @("dev", "test", "prod")) {

    $wsName = "$ProjectName-$env"
    Write-PSFMessage -Level Host -Message "── $wsName ──" -FunctionName $fn

    # Create or retrieve workspace (idempotent)
    $ws = Get-FabricWorkspace -WorkspaceName $wsName -ErrorAction SilentlyContinue
    if (-not $ws) {
        $ws = New-FabricWorkspace `
            -WorkspaceName $wsName `
            -WorkspaceDescription "$ProjectName $env environment"
        Write-PSFMessage -Level Host -Message "Created workspace: $wsName" -FunctionName $fn
    } else {
        Write-PSFMessage -Level Verbose -Message "Workspace exists: $wsName" -FunctionName $fn
    }

    # Assign capacity
    Assign-FabricWorkspaceCapacity -WorkspaceId $ws.id -CapacityId $capacity.id

    # Create Lakehouses (idempotent)
    foreach ($lhName in @("Raw", "Curated", "Presentation")) {
        $existing = Get-FabricLakehouse -WorkspaceId $ws.id -LakehouseName $lhName `
            -ErrorAction SilentlyContinue
        if (-not $existing) {
            New-FabricLakehouse -WorkspaceId $ws.id -LakehouseName $lhName | Out-Null
            Write-PSFMessage -Level Host -Message "Created Lakehouse: $lhName" -FunctionName $fn
        }
    }

    # Create Warehouse (idempotent)
    $existingWh = Get-FabricWarehouse -WorkspaceId $ws.id -WarehouseName "Analytics" `
        -ErrorAction SilentlyContinue
    if (-not $existingWh) {
        New-FabricWarehouse -WorkspaceId $ws.id -WarehouseName "Analytics" | Out-Null
        Write-PSFMessage -Level Host -Message "Created Warehouse: Analytics" -FunctionName $fn
    }

    # Assign team role
    $role = if ($env -eq "prod") { "Viewer" } else { "Member" }
    try {
        Add-FabricWorkspaceRoleAssignment `
            -WorkspaceId $ws.id `
            -PrincipalId $TeamGroupId `
            -PrincipalType "Group" `
            -Role $role
        Write-PSFMessage -Level Host `
            -Message "Assigned team as $role in $wsName" -FunctionName $fn
    }
    catch {
        Write-PSFMessage -Level Warning `
            -Message "Role assignment skipped for $wsName (may already exist)" `
            -FunctionName $fn
    }
}

Write-PSFMessage -Level Host `
    -Message "Provisioning complete for $ProjectName" -FunctionName $fn
Wait-PSFMessage
```

## What This Script Demonstrates

This draws on almost every post in the series:

- **Authentication** → [Getting Started](https://blog.robsewell.com/blog/microsoftfabricmgmt-getting-started/)
- **PSFramework logging** → [Structured Logging](https://blog.robsewell.com/blog/microsoftfabricmgmt-psframework-logging/)
- **Error handling patterns** → [Error Handling](https://blog.robsewell.com/blog/microsoftfabricmgmt-error-handling/)
- **Workspace management** → [Workspaces](https://blog.robsewell.com/blog/microsoftfabricmgmt-workspaces/)
- **Lakehouse creation** → [Lakehouses](https://blog.robsewell.com/blog/microsoftfabricmgmt-lakehouses/)
- **Warehouse creation** → [Warehouses and SQL Databases](https://blog.robsewell.com/blog/microsoftfabricmgmt-warehouses-and-sql-databases/)
- **Role assignments** → [RBAC](https://blog.robsewell.com/blog/microsoftfabricmgmt-rbac/)

The idempotency pattern (check before create) means you can run this script multiple times safely — it will create what is missing and skip what already exists.

## Tomorrow

Tomorrow we cover the final operational topic before we wrap up the series: Service Principals and Managed Identity — how to run automation like this without interactive authentication. See you then.
