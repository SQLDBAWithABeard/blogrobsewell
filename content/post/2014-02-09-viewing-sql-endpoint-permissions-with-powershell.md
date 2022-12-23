---
title: "Viewing SQL Endpoint Permissions with PowerShell"
categories:
  - Blog

tags:
  - PowerShell

header:
  teaser: /assets/uploads/2014/02/ps1.jpg

---
A quick and simple post today as I have been very busy. I needed to list the users with permissions on mirroring endpoints today so I wrote this script and figured it was worth sharing.

It’s a simple script which takes a server name from a Read-Host prompt. Displays the available endpoints and asks which one you want and shows you the permissions


    $Server = Read-Host "Please Enter the Server"
    $Endpoints = $srv.Endpoints |select Name -ExpandProperty Name
    $EndpointName = Read-Host "Please Enter the Endpoint Name `n Available Names are `n $Endpoints"
    $srv = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $server
    $Endpoint = $srv.Endpoints[$EndpointName]
    $Endpoint.enumObjectPermissions()

and heres a screenshot of the results

[![image](https://blog.robsewell.com/assets/uploads/2014/02/ps1.jpg)](https://blog.robsewell.com/assets/uploads/2014/02/ps1.jpg)

If you want to do it with T-SQL

    select s.name as grantee,
    e.name as endpoint,
    p.permission_name as permission,
    p.state_desc as state_desc
    from sys.server_permissions p
    join sys.server_principals s on s.principal_id = p.grantee_principal_id
    join sys.endpoints e on p.major_id = e.endpoint_id
    where p.type='CO'

[![image](https://blog.robsewell.com/assets/uploads/2014/02/image_thumb9.png)](https://blog.robsewell.com/assets/uploads/2014/02/image13.png)