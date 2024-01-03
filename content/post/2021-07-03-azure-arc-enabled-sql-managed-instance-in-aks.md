---
title: "How to deploy an Azure Arc Enabled SQL Managed Instance in AKS"
date: "2021-07-03" 
categories:
  - Blog
  - Bicep
  - Automation

tags:
 - IaC
 - Azure
 - SQL Server
 - Azure Arc Enabled Data Services
 - Managed Instance
 - kibana
 - grafana
 - Log Analytics
 - AKS


image: https://raw.githubusercontent.com/SQLDBAWithABeard/Beard-Aks-AEDS/main/images/connecteddc.png
---

# Want to play before GA ?

Azure SQL enabled by Azure Arc will be generally available at the end of the month following the announcement [here](https://azure.microsoft.com/en-us/blog/bring-cloud-experiences-to-data-workloads-anywhere-with-azure-sql-enabled-by-azure-arc?WT.mc_id=DP-MVP-5002693)

You can read more about [Azure Arc-enabled Data Services ](https://azure.microsoft.com/en-us/services/azure-arc/hybrid-data-services?WT.mc_id=DP-MVP-5002693)

I have been playing with it for a few months, mainly in a Kubernetes cluster running on my NUCs in my office but Azure Arc is available in so many places, all the public clouds, your own data center (or NUCs in your office :-) ) so if you want to try it out and you do not want to build your own Kubernetes cluster then you can use [AKS](https://azure.microsoft.com/en-gb/services/kubernetes-service?WT.mc_id=DP-MVP-5002693) in Azure.

# How can I do that ?

One way is to use the [Azure Arc Jumpstart website](https://azurearcjumpstart.io/azure_arc_jumpstart/azure_arc_data?WT.mc_id=DP-MVP-5002693) which has many templates for many scenarios.

I like playing with [Bicep](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview?WT.mc_id=DP-MVP-5002693) which is a domain-specific language or DSL for deploying Azure resources.

I have [created a repository on GitHub ](https://github.com/SQLDBAWithABeard/Beard-Aks-AEDS) which you can use to create your own AKS cluster with an Azure Arc Enabled directly connected Data Controller and SQL Managed Instance either 1 node replica or 3 node replica.

There is even the code to create an Azure Virtual Machine and install the required tooling if you need it.

All of the details and instructions are in the read me file so feel free to go and make use of it and you can have a resource group that looks like this

![portal](https://raw.githubusercontent.com/SQLDBAWithABeard/Beard-Aks-AEDS/main/images/portalresources.png)

Just dont forget to delete the Resource Group once you have finished!!

You can create it any time you like with the code :-)

Happy Azure Arc SQL Managed Instance playing!
