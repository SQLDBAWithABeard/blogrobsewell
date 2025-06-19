---
title: "Pestering Fabric with PowerShell"
date: "2025-06-20"
categories:
  - Blog
  - Microsoft Fabric

tags:
  - PowerShell
  - Microsoft Fabric
  - Azure
  - Automation
  - FabricTools
  - Pester
  - Testing
image: assets/uploads/2025/06/exceloutput.png
---
## Introduction

Next week is the [PowerShell Conference Europe 2025](https://psconf.eu), and Jess Pomfret [B](https://jesspomfret.com) [S](https://bsky.app/profile/jpomfret.co.uk)and I will be presenting a session Microsoft Fabric for the PowerShell Pro

Of course we will be demonstrating [[FabricTools](https://www.powershellgallery.com/packages/FabricTools?WT.mc_id=DP-MVP-5002693), a PowerShell module that simplifies the management of Microsoft Fabric resources. You can find it on GitHub at [FabricTools](https://github.com/dataplat/FabricTools?WT.mc_id=DP-MVP-5002693). FabricTools provides functions to create, update, and delete Fabric Lakehouses and other resources. It has been developed and is maintained by members of the community.

## Pester Testing

This post is not about validating our PowerShell code using Pester but rather about validating the Fabric resources we create using PowerShell. Pester is a testing framework for PowerShell that allows you to write tests for your PowerShell code. You can find blog posts I have written about that [here](https://blog.robsewell.com/tags/pester/). It is widely used in the PowerShell community to ensure that code works as expected.

However, I always say that

> If you can *get* it with PowerShell then you can *test* it with Pester.

