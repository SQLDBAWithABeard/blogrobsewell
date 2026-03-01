---
title: "MicrosoftFabricMgmt: Service Principals and Managed Identity - Production Authentication"
date: "2026-03-18"
slug: "microsoftfabricmgmt-service-principals"
categories:
  - Blog
  - Microsoft Fabric
  - PowerShell
tags:
  - PowerShell
  - Microsoft Fabric
  - MicrosoftFabricMgmt
  - Automation
  - Service Principal
  - Managed Identity
  - Authentication
  - Security
image: assets/uploads/2026/03/microsoftfabricmgmt-service-principals.png
---

## Introduction

In the [Getting Started post](https://blog.robsewell.com/blog/microsoftfabricmgmt-getting-started/) we used interactive authentication — a browser prompt, a user login, a token stored in memory. That is fine for exploring the module and running one-off scripts. It is not fine for automation.

Scheduled tasks cannot click a browser prompt. CI/CD pipelines do not have a user session. If your automation runs unattended, you need non-interactive authentication. MicrosoftFabricMgmt supports two options: **Service Principals** and **Managed Identity**.

## Service Principals

A Service Principal is an identity in Microsoft Entra ID that represents an application rather than a user. You create it, grant it permissions, and authenticate as it without any interactive login.

### Creating a Service Principal

You can create one in the [Azure portal](https://portal.azure.com/?WT.mc_id=DP-MVP-5002693) under Entra ID → App Registrations → New registration, or with PowerShell:

```powershell
# Create the Service Principal
$sp = New-AzADServicePrincipal -DisplayName "FabricAutomation"

Write-Host "Application (Client) ID: $($sp.AppId)"
Write-Host "Object ID: $($sp.Id)"

# Create a client secret
$secret = New-AzADAppCredential -ObjectId $sp.Id -EndDate (Get-Date).AddYears(1)
Write-Host "Secret Value: $($secret.SecretText)"  # Save this — shown only once
```

### Granting Fabric Permissions

The Service Principal needs to be added to the Fabric workspaces it will manage:

```powershell
Add-FabricWorkspaceRoleAssignment `
    -WorkspaceId $workspace.id `
    -PrincipalId $sp.Id `
    -PrincipalType "ServicePrincipal" `
    -Role "Admin"
```

### Authenticating as a Service Principal

```powershell
Set-FabricApiHeaders `
    -TenantId  "your-tenant-id" `
    -AppId     "your-application-client-id" `
    -AppSecret "your-client-secret"
```

### Storing Secrets Securely

**Never hardcode secrets in scripts.** Use [Microsoft.PowerShell.SecretManagement](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.secretmanagement/?WT.mc_id=DP-MVP-5002693):

```powershell
# Store once, interactively
Set-Secret -Name FabricSP_AppId     -Secret "your-application-client-id"
Set-Secret -Name FabricSP_AppSecret -Secret "your-client-secret"
Set-Secret -Name FabricTenantId     -Secret "your-tenant-id"

# Use in automation scripts
Set-FabricApiHeaders `
    -TenantId  (Get-Secret -Name FabricTenantId     -AsPlainText) `
    -AppId     (Get-Secret -Name FabricSP_AppId     -AsPlainText) `
    -AppSecret (Get-Secret -Name FabricSP_AppSecret -AsPlainText)
```

In CI/CD pipelines, store these as pipeline secrets and inject them as environment variables.

## Managed Identity

If your automation runs on Azure infrastructure — an Azure VM, Azure Functions, Azure Automation — you can use Managed Identity instead. There are **no credentials to manage**. Azure handles token issuance transparently.

```powershell
# Authenticate using the host's Managed Identity
Set-FabricApiHeaders `
    -TenantId "your-tenant-id" `
    -UseManagedIdentity
```

No App ID, no secret, no certificate. The underlying Azure infrastructure handles authentication using the VM or function's assigned identity.

> You still need to grant the Managed Identity permissions in Fabric — add it to workspace role assignments just as you would a Service Principal.

## Choosing the Right Option

| Scenario | Recommended Auth |
|----------|-----------------|
| Interactive exploration | User Principal (interactive browser) |
| Scheduled tasks on-premises | Service Principal with stored secret |
| Automation on Azure VMs / Azure Functions | Managed Identity |
| GitHub Actions / Azure DevOps pipelines | Service Principal with pipeline secrets |
| Azure Automation runbooks | Managed Identity (if same tenant) |

## Example: Service Principal in Azure DevOps

```yaml
# azure-pipelines.yml (excerpt)
- task: PowerShell@2
  displayName: 'Provision Fabric Environment'
  env:
    FABRIC_TENANT_ID:  $(FabricTenantId)
    FABRIC_APP_ID:     $(FabricAppId)
    FABRIC_APP_SECRET: $(FabricAppSecret)
  inputs:
    script: |
      Import-Module MicrosoftFabricMgmt
      Set-FabricApiHeaders `
          -TenantId  $env:FABRIC_TENANT_ID `
          -AppId     $env:FABRIC_APP_ID `
          -AppSecret $env:FABRIC_APP_SECRET
      # ... provisioning script here ...
```

## Tomorrow — Wrapping Up

Tomorrow is the final post in this series. We talk about contributing to MicrosoftFabricMgmt — how to get involved, and how to help make the module even better. See you then.
