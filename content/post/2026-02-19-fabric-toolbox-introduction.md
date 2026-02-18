---
title: "Introduction to fabric-toolbox - Microsoft Fabric's Community Accelerator Hub"
date: "2026-02-19"
categories:
  - Blog
  - Microsoft Fabric
  - PowerShell
tags:
  - Microsoft Fabric
  - fabric-toolbox
  - Open Source
  - Community
  - Automation
image: assets/uploads/2026/02/fabric-toolbox-introduction.png
---

## Introduction

Today I want to talk about [fabric-toolbox](https://github.com/microsoft/fabric-toolbox), the Microsoft-sponsored, community-driven repository of accelerators, tools, and utilities that exists specifically to help Fabric users get further, faster.

## What Is fabric-toolbox?

fabric-toolbox is a GitHub repository maintained under the Microsoft organisation, led by the Microsoft Customer Acceleration Team (CAT) for Fabric and community contributors. It's a community toolkit, a collection of solutions that go beyond the core product to solve real-world operational, governance, and automation problems.

The repository is organised into 5 categories:

- **Monitoring** — tools for understanding what is happening in your Fabric tenant
- **Accelerators** — end-to-end solutions for common scenarios
- **Tools** — utilities and PowerShell modules ;-) for managing Fabric programmatically
- **Scripts** — ready-to-use scripts for specific tasks
- **Samples** — end-to-end scenario demonstrations

Everything in it is open source. Contributions are welcome. Bugs are filed in GitHub Issues. A community is born and grows around it.

## What We Will Be Covering

Over the next few weeks I am going to write about four things from the fabric-toolbox ecosystem:

**1. FUAM — Fabric Unified Admin Monitoring** (tomorrow)

A monitoring solution built entirely with native Fabric capabilities — notebooks, Lakehouses, and Power BI dashboards — that gives Fabric administrators a holistic view of capacity usage, workspace health, and user activity. If you are responsible for a Fabric tenant, FUAM is worth knowing about.

**2. FCA — Fabric Cost Analysis** (Friday)

A FinOps solution that pulls cost data from Azure Cost Management and breaks it down by Fabric capacity, workspace, and SKU. If your organisation is asking "how much is Fabric actually costing us?", FCA helps you answer that properly.

**3. MicrosoftFabricMgmt — The PowerShell Module** (starting Monday the 24th)

This is the one I am most invested in, because Jess Pomfret [B](https://jesspomfret.com) [S](https://bsky.app/profile/jpomfret.co.uk) [L](https://www.linkedin.com/in/jpomfret) and I have been contributing to it heavily. It is a PowerShell module with over 295 cmdlets covering 48 Fabric resource types — workspaces, Lakehouses, Warehouses, Notebooks, Real-Time Intelligence, RBAC, the Admin API, and more. We will spend two weeks going through it in depth.

## 4 Will be no surprise.

## Why Does This Matter?

Microsoft Fabric is a big platform. There is so much to learn about it, and the product team is moving fast, adding new features and capabilities every month. The fabric-toolbox enables you to move quickly forward by giving you expertly written, community-vetted solutions to common problems. It is a place to find tools that save you time, to learn from real-world examples, and to contribute back to the community.

The monitoring tools (FUAM, FCA) give you visibility. The PowerShell module gives you control. Together they are a significant part of how serious Fabric teams manage their estates.

There is much much more to find there also.

## Getting Started

The main repository is at [github.com/microsoft/fabric-toolbox](https://github.com/microsoft/fabric-toolbox). Each tool has its own README with installation and usage instructions. I will cover each one in the posts that follow.

Tomorrow we start with FUAM. See you then.
