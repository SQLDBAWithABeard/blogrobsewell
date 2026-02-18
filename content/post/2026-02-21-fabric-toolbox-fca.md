---
title: "FCA - Fabric Cost Analysis for FinOps"
date: "2026-02-21"
categories:
  - Blog
  - Microsoft Fabric
  - PowerShell
tags:
  - Microsoft Fabric
  - fabric-toolbox
  - FCA
  - FinOps
  - Cost Management
  - Governance
image: assets/uploads/2026/02/fabric-toolbox-fca.png
---

## Introduction

This week we have been looking at the [fabric-toolbox](https://blog.robsewell.com/blog/microsoft-fabric/powershell/fabric-toolbox-introduction/) ecosystem. Yesterday we covered [FUAM](https://blog.robsewell.com/blog/microsoft-fabric/powershell/fabric-toolbox-fuam/) — the operational monitoring solution. Today we look at another monitoring tool in the collection: **FCA, the Fabric Cost Analysis** solution.

Where FUAM answers "how is my Fabric capacity being used?", FCA answers "what is it costing us, and who is spending what?"

## What Is FCA?

FCA is a FinOps solution for Microsoft Fabric. It brings cost data from Azure Cost Management into Fabric and breaks it down in ways that are meaningful for Fabric administrators and business stakeholders:

- Cost by Fabric capacity
- Cost by workspace
- Cost by SKU and billing meter
- Cost trends over time
- Showback and chargeback breakdowns

The "FinOps" framing is intentional. FCA is designed around the FinOps framework's principle of making cloud costs visible and understandable to the teams that generate them — not just the finance department.

## Where to Find It

FCA lives at [github.com/microsoft/fabric-toolbox/tree/main/monitoring/fabric-cost-analysis](https://github.com/microsoft/fabric-toolbox/tree/main/monitoring/fabric-cost-analysis).

As with FUAM, the README is the place to start.

## The FOCUS Standard

One of the interesting technical choices in FCA is that it uses cost data in the **FOCUS format** — the Flexible Open Cost and Usage Specification. FOCUS is an emerging open standard for cloud cost data, backed by the FinOps Foundation and increasingly supported by major cloud providers including Microsoft.

Azure Cost Management can export cost data in FOCUS format, and FCA is built to consume it. The practical benefit is that FOCUS normalises cost data in a consistent way that makes analysis easier — categories, meters, and service names are standardised rather than being provider-specific strings.

If you are building any kind of multi-cloud cost analysis or want your Fabric costs to integrate cleanly with broader FinOps tooling, FOCUS is worth understanding.

## What You Get

Once deployed, FCA provides Power BI reports covering:

**Cost Overview**
- Total Fabric spend for a selected period
- Cost breakdown by capacity, workspace, and meter type
- Month-over-month and day-over-day cost trends

**Capacity Costs**
- Cost per capacity over time
- Which capacities are driving spend
- SKU cost analysis (F2 vs F4 vs F64, etc.)

**Workspace Costs**
- Estimated cost attribution per workspace (based on capacity utilisation share)
- Workspaces with the highest relative spend

**Showback Reports**
- Team or department cost attribution reports
- Designed to be shared with workspace owners and business stakeholders

## How It Works

FCA imports cost export files from Azure Cost Management (in FOCUS format) into a Fabric Lakehouse, transforms the data using PySpark notebooks, and surfaces the results through Power BI reports.

The data collection is typically run daily or weekly — cost data in Azure is available with a day or two of delay, so real-time is not the focus here. Instead, FCA is about trend analysis and retrospective cost review.

## Deployment Overview

1. Configure Azure Cost Management to export cost data in FOCUS format to a storage location your Fabric can access
2. Create a dedicated workspace for FCA in your Fabric tenant
3. Run the setup notebooks from the repository
4. Schedule the data ingestion notebooks
5. Configure the Power BI reports

The Azure Cost Management export configuration is the step that tends to catch people out — make sure you are exporting at the subscription or management group scope that covers your Fabric capacity billing.

## Showback vs Chargeback

FCA supports both patterns:

**Showback**: You tell each team what their Fabric usage costs, for awareness and accountability. No money actually moves — it is informational.

**Chargeback**: You actually bill internal teams for their Fabric usage. This requires integrating FCA's output with your internal billing processes.

Most organisations start with showback and move to chargeback once they have confidence in the cost attribution model. FCA supports both without requiring different configurations.

## On Monday

On Monday we start the main event — a two-week deep dive into the MicrosoftFabricMgmt PowerShell module. 295+ cmdlets, 48 resource types, PSFramework logging, intelligent output formatting, pipeline support, and more. See you then.
