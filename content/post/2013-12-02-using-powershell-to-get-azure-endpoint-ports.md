---
title: "Using PowerShell to get Azure Endpoint Ports"
categories:
  - azure
  - Blog

tags:
  - azure
  - endpoint
  - PowerShell
  - SQL Server
  - SSMS

---
A quick blog today. I was reading [this blog post about How to read the SQL Error Log](http://www.mssqltips.com/sqlservertip/3076/how-to-read-the-sql-server-database-transaction-log/) and I thought I would try some of the examples. I started my Azure VM using [the steps in my previous post](https://blog.robsewell.com/?p=534)

I ran

    Get-AzureVM -ServiceName TheBestBeard -Name Fade2black


and then

     Get-AzureVM -ServiceName TheBestBeard -Name Fade2black|Get-AzureEndpoint |Format-Table -AutoSize

and bingo I had my SQL Port to put in SSMS and can go and play some more with SQL
