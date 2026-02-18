---
title: "FUAM - Fabric Unified Admin Monitoring"
date: "2026-02-20"
categories:
  - Blog
  - Microsoft Fabric
  - PowerShell
tags:
  - Microsoft Fabric
  - fabric-toolbox
  - FUAM
  - Monitoring
  - Admin
  - Governance
image: https://raw.githubusercontent.com/microsoft/fabric-toolbox/refs/heads/main/monitoring/fabric-unified-admin-monitoring/media/general/fuam_cover_flow.png
---

## Introduction

Yesterday I [introduced fabric-toolbox](https://blog.robsewell.com/blog/microsoft-fabric/powershell/fabric-toolbox-introduction/) — Microsoft's community-driven repository of Fabric accelerators. Today we look at one of its flagship solutions: **FUAM, the Fabric Unified Admin Monitoring** solution.

When you are responsible for a Microsoft Fabric tenant, it will not be very long before you are facing many questions.

Questions like:

- how is my capacity being used?
- Which workspaces are consuming the most resources?
- What are my users actually doing?

It does this using Fabric's own native capabilities — no external infrastructure required and stores all that data in a Lakehouse that you can retain for as long as you like.

## What Is FUAM?

FUAM is a monitoring solution for Microsoft Fabric administrators. It gives you a holistic, near real-time view of your Fabric platform across three main dimensions:

- **Capacity utilisation** — how much of your Fabric capacity is being consumed, by whom, and at what times
- **Workspace and item inventory** — what exists in your tenant, across all workspaces
- **User activity** — who is doing what, when, across your Fabric environment

The key thing about FUAM is that it is built entirely with Fabric's own capabilities. The data collection, storage, and visualisation all happen inside Fabric itself — using Notebooks (PySpark) for data collection, a Lakehouse for storage, and Power BI reports for visualisation. There is no external database, no external compute, no Azure infrastructure outside of Fabric to manage. Yes, it does consume CUs to run the data collection notebooks and the SQL endpoint for the reports, but that is all part of your Fabric capacity.

[![The fuam core report](https://raw.githubusercontent.com/microsoft/fabric-toolbox/refs/heads/main/monitoring/fabric-unified-admin-monitoring/media/general/fuam_core_1.png)](![link](https://raw.githubusercontent.com/microsoft/fabric-toolbox/refs/heads/main/monitoring/fabric-unified-admin-monitoring/media/general/fuam_core_1.png))

## Where to Find It

FUAM lives in the fabric-toolbox repository at [github.com/microsoft/fabric-toolbox/tree/main/monitoring/fabric-unified-admin-monitoring](https://github.com/microsoft/fabric-toolbox/tree/main/monitoring/fabric-unified-admin-monitoring).

The README is comprehensive and walks you through the prerequisites, deployment steps, and what each dashboard component shows.

## What You Get

Once deployed, FUAM provides dashboards covering:

**Capacity Monitoring**
- CU (Capacity Unit) utilisation over time — smoothed and burst views
- Which operations and workspaces are driving consumption
- Throttling alerts — when you are approaching or hitting capacity limits
- SKU efficiency analysis
- No deletion of data older than 14 days like the Capacity Metrics App. This is more useful than you might think, because it allows you to do things like correlate CU consumption with specific reports or activities that you know happened at a certain time, and it allows you to build up a picture of usage patterns over time.

**Workspace and Item Inventory**
- All workspaces in your tenant with their assigned capacities
- Item counts by type and workspace
- Orphaned workspaces (no capacity assigned, or no active users)

**User Activity**
- Active users over time
- Operations by user and by operation type
- Peak usage times

**Capacity Health**
- Overload periods
- Autoscale trigger history (if you use autoscale)
- Recommendations for right-sizing

## How It Works

FUAM collects data using the Fabric REST APIs and the Microsoft 365 audit log, ingests it into a Lakehouse, and transforms it using PySpark notebooks. Power BI reports connect to the Lakehouse's SQL endpoint to provide the dashboards.

The data collection notebooks are designed to be scheduled — typically running every 15-30 minutes for near real-time capacity data, and daily for inventory and activity data.

## Deployment Overview

Deployment involves:

1. Creating a dedicated workspace for FUAM in your Fabric tenant
2. Running the setup notebook from the repository, which creates the Lakehouse, tables, and report
3. Configuring authentication (FUAM uses a Service Principal to call the Fabric Admin APIs)
4. Scheduling the data collection notebooks using Fabric's built-in job scheduler

The full step-by-step is in the FUAM README. The Azure portal permissions (granting the Service Principal Fabric Admin access) are the step that tends to catch people out — make sure you follow those carefully.

## Best of all

You can use it to save time, energy and CUs by using it to feed many other solutions that you may build over time.

For example, last week I used it to identify the details of over 40 thousand reports and semantic models to gather information about the RLS on them and I could do it without overloading the Admin API because FUAM had already gathered the data.

You can also build queries on top of the FUAM Lakehouse to enable other teams to help themselves to the data they need without having to give them direct access to the Admin API or run their own data collection.

Trying to build your own Fabric monitoring solutions from scratch is a significant amount of work — API pagination, schema management, Power BI data modelling, refresh scheduling. FUAM does all of that for you, and it is maintained by the CAT team and community, so it improves over time.

If you are managing a Fabric tenant of any real size, FUAM is worth the deployment effort. A few hours of setup buys you ongoing visibility that would otherwise take weeks to build yourself.

## Tomorrow

Tomorrow we look at FCA — Fabric Cost Analysis — which takes a FinOps approach to understanding what your Fabric capacity is actually costing you. See you then.
