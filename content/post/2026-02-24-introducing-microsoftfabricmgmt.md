---
title: "Introducing MicrosoftFabricMgmt: Managing Microsoft Fabric with PowerShell"
date: "2026-02-24"
categories:
  - Blog
  - Microsoft Fabric
  - PowerShell
tags:
  - PowerShell
  - Microsoft Fabric
  - MicrosoftFabricMgmt
  - Automation
  - PSFramework
image: assets/uploads/2026/02/microsoftfabricmgmt-intro.png
---

## Introduction

If you have been following this blog for a while, you will know that I am a huge fan of using PowerShell to manage and automate things. SQL Server, [dbatools](https://dbatools.io), [dbachecks](https://github.com/dataplat/dbachecks/) — automating the boring stuff so we can spend time on the interesting stuff.

This week I have been introducing the [Microsoft fabric-toolbox](https://github.com/microsoft/fabric-toolbox) — covering [the toolbox itself](https://blog.robsewell.com/blog/microsoft-fabric/powershell/fabric-toolbox-introduction/), [FUAM](https://blog.robsewell.com/blog/microsoft-fabric/powershell/fabric-toolbox-fuam/), and [FCA](https://blog.robsewell.com/blog/microsoft-fabric/powershell/fabric-toolbox-fca/). All excellent tools. But there is one item in the toolbox that I have been personally involved in building, and it is the one I am most excited to write about.

Today I am kicking off a series of posts about **MicrosoftFabricMgmt** — an enterprise-grade PowerShell module that gives you comprehensive, scriptable control over the entire Microsoft Fabric REST API. It is hosted as part of the fabric-toolbox on GitHub.

## Who Built It?

This module is a community and Microsoft collaboration. It was started by the talented Tiago Balabuch and in the last few weeks Jess Pomfret [B](https://jesspomfret.com) [S](https://bsky.app/profile/jpomfret.co.uk) [L](https://www.linkedin.com/in/jpomfret) and myself have made major improvements to the module, and we are really proud of it and excited about how it has turned out.

## What Does It Do?

In short: a lot.

- **295+ cmdlets** covering 48 different Microsoft Fabric resource types
- **Lakehouses, Warehouses, Notebooks, Pipelines, Eventstreams, KQL Databases, ML Models, and much more**
- **Three authentication methods**: User Principal (interactive), Service Principal (automation), and Managed Identity (Azure-hosted workloads)
- **Intelligent output formatting** — no more squinting at GUIDs. The module automatically resolves Capacity IDs and Workspace IDs to human-readable names, with smart caching so it stays fast
[![Get-FabricLakehouse output showing intelligent formatting](../assets/uploads/2026/02/get-fabriclakehouse.png)](../assets/uploads/2026/02/get-fabriclakehouse.png)
- **Full PowerShell pipeline support** — Just like the header image, you can now pipe workspaces to get their lakehouses, pipe to get their SQL Endpoints, pipe to ge the SQL Endpoints connection string all in one line of code. The PowerShell way :-)
- **Enterprise-grade resilience** — built-in retry logic with exponential backoff, automatic rate limit handling, and Long Running Operation support
- **PSFramework integration** — consistent, configurable caching, logging, and configuration management throughout the module

## What is New?

The current release represents a major step forward from earlier versions.

You can see the full list of changes in the [changelog](https://github.com/microsoft/fabric-toolbox/blob/main/tools/MicrosoftFabricMgmt/output/CHANGELOG.md#104---2026-02-16]

Here are some highlights:

- **All logging migrated to PSFramework** — use `Get-PSFMessage` to inspect what the module is doing, and `Set-PSFLoggingProvider` to write logs to a file, a database, or even Azure Application Insights
- **Automatic name resolution with intelligent caching** — GUIDs become names, and the results are cached across sessions for near-instant performance on subsequent calls. A subject for a later post, but this is one of my favourite features and such an improvement over the previous version and the CLI or direct API calls, and it makes the output so much more user-friendly.
- **All endpoints verified** against the official [Microsoft Fabric REST API specifications](https://github.com/microsoft/fabric-rest-api-specs)

## The Series

Over the next few weeks I am going to take you from installing the module for the first time all the way through to managing your entire Fabric tenant, handling errors gracefully, and even contributing back to the project. We will start with installation and authentication, move through the intelligent output system, explore workspaces and the PowerShell pipeline, dig into PSFramework logging and error handling, cover the major resource types, take a tour of Real-Time Intelligence, spend time with the powerful Admin API, and finish with a complete end-to-end deployment script and a guide to contributing.

## Getting the Module

You can install **MicrosoftFabricMgmt** right now from the [PowerShell Gallery](https://www.powershellgallery.com/packages/MicrosoftFabricMgmt?WT.mc_id=DP-MVP-5002693):

```powershell
Install-PsResource -Name MicrosoftFabricMgmt
```

Requires **PowerShell 7** or later. The source code lives at [github.com/microsoft/fabric-toolbox](https://github.com/microsoft/fabric-toolbox/tree/main/tools/MicrosoftFabricMgmt), and that is also where you can raise issues and submit pull requests.

## See You Tomorrow

The first thing we need to do is get the module installed and prove it works. That is tomorrow's post — installation, dependencies, and your first connection to Microsoft Fabric. See you then.
