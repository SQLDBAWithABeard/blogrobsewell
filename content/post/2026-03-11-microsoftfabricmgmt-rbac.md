---
title: "MicrosoftFabricMgmt: RBAC - Managing Workspace Roles and Permissions"
date: "2026-03-11"
slug: "microsoftfabricmgmt-rbac"
categories:
  - Blog
  - Microsoft Fabric
  - PowerShell
tags:
  - PowerShell
  - Microsoft Fabric
  - MicrosoftFabricMgmt
  - Automation
  - RBAC
  - Permissions
image: assets/uploads/2026/03/microsoftfabricmgmt-rbac.png
---

## Introduction

Getting the data platform right is only half the job. Controlling who can see and touch what is the other half. Microsoft Fabric uses a role-based access control (RBAC) model at the workspace level, and MicrosoftFabricMgmt gives you PowerShell access to all of it.

## The Four Workspace Roles

Fabric workspaces have four built-in roles:

| Role | Can Do |
|------|--------|
| **Admin** | Everything — manage access, modify, delete, publish |
| **Member** | Add/remove Members and Contributors, create and publish content |
| **Contributor** | Create and edit content, cannot manage access |
| **Viewer** | Read-only access |

The principle of least privilege applies: give people the lowest role that lets them do their job. For your data engineering team in a dev workspace, Member makes sense. In prod, Viewer for most people, Admin only for those who need it.

## Getting Role Assignments

```powershell
# All role assignments for a workspace
Get-FabricWorkspaceRoleAssignment -WorkspaceId $workspace.id

# Role assignments across all workspaces (pipeline!)
Get-FabricWorkspace | Get-FabricWorkspaceRoleAssignment
```

That second example is one of my favourite things in the module — a tenant-wide permissions inventory in one line.

## Adding Role Assignments

```powershell
# Add a user as a Contributor
Add-FabricWorkspaceRoleAssignment `
    -WorkspaceId $workspace.id `
    -PrincipalId "user@yourdomain.com" `
    -PrincipalType "User" `
    -Role "Contributor"

# Add a security group as Members
Add-FabricWorkspaceRoleAssignment `
    -WorkspaceId $workspace.id `
    -PrincipalId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" `
    -PrincipalType "Group" `
    -Role "Member"

# Add a Service Principal as Admin (for automation)
Add-FabricWorkspaceRoleAssignment `
    -WorkspaceId $workspace.id `
    -PrincipalId $spObjectId `
    -PrincipalType "ServicePrincipal" `
    -Role "Admin"
```

## Removing Role Assignments

```powershell
Remove-FabricWorkspaceRoleAssignment `
    -WorkspaceId $workspace.id `
    -PrincipalId "user@yourdomain.com"
```

## Audit: Who Has Admin on Any Workspace?

This is the question every data platform team should be able to answer:

```powershell
#ONLY ON Workspaces the caller is an Admin on.
Get-FabricWorkspace |
    Get-FabricWorkspaceRoleAssignment |
    Where-Object { $_.role -eq "Admin" } |
    Select-Object workspaceName, principalDisplayName, principalType, role |
    Sort-Object workspaceName
```

I run something like this during access reviews. It takes a few seconds and gives you a complete picture. Compare that to clicking through dozens of workspace settings pages.

NOTE: You can only see role assignments for workspaces where you have admin access. You are going to need an excellent process to enable this or some additional scripting.

## Standardising Access for a Project

Here is a pattern for consistently assigning roles across a set of project workspaces:

```powershell
$teamGroupId  = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
$projectName  = "DataPlatform"

foreach ($env in @("dev", "test", "prod")) {
    $ws = Get-FabricWorkspace -WorkspaceName "$projectName-$env"
    $role = if ($env -eq "prod") { "Viewer" } else { "Member" }

    try {
        Add-FabricWorkspaceRoleAssignment `
            -WorkspaceId $ws.id `
            -PrincipalId $teamGroupId `
            -PrincipalType "Group" `
            -Role $role
        Write-PSFMessage -Level Host `
            -Message "Assigned team as $role in $($ws.displayName)"
    }
    catch {
        Write-PSFMessage -Level Warning `
            -Message "Could not assign role in $($ws.displayName) — may already exist"
    }
}
```

Engineers as Members in dev and test, Viewers in prod. Consistent, documented, and repeatable.

## Tomorrow

Tomorrow we move into Real-Time Intelligence — Eventhouses, KQL Databases, and Eventstreams. See you then.
