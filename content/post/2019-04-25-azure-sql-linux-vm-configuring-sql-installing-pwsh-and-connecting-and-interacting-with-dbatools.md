---
title: "Azure SQL Linux VM – configuring SQL, installing pwsh and connecting and interacting with dbatools"
categories:
  - Azure
  - Blog
  - dbatools
  - PowerShell
  - SQL Server

tags:
  - azure
  - dbatools
  - linux
  - pwsh
  - Terraform
  - PowerShell

header:
  teaser: /assets/uploads/2019/04/image-125.png

---
In my posts about using Azure Devops to build Azure resources with Terraform, [I built a Linux SQL VM.](https://blog.robsewell.com/using-the-same-azure-devops-build-steps-for-terraform-with-different-pipelines-with-task-groups/) I used the [Terraform in this GitHub](https://github.com/SQLDBAWithABeard/Presentations-AzureSQLVM) repository and created this

![](https://blog.robsewell.com/assets/uploads/2019/04/image-114.png)

Connecting with MobaXterm
-------------------------

I had set the Network security rules to accept connections only from my static IP using variables in the Build Pipeline. I use [MobaXterm](https://mobaxterm.mobatek.net/) as my SSH client. Its a free download. I click on sessions

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-120.png)

Choose a SSH session and fill in the remote host address from the portal

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-121.png)

fill in the password and

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-122.png)

Configuring SQL
---------------

The next task is to configure the SQL installation. Following the instructions on the [Microsoft docs site](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/sql/provision-sql-server-linux-virtual-machine?WT.mc_id=DP-MVP-5002693) I run

    sudo systemctl stop mssql-server
    sudo /opt/mssql/bin/mssql-conf set-sa-password
enter the sa password and

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-123.png)

Now to start SQL

    sudo systemctl start mssql-server

Installing pwsh
---------------

Installing PowerShell Core (pwsh) is easy with snap

   sudo snap install powershell --classic

A couple of minutes of downloads and install

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-124.png)

and pwsh is ready for use

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-125.png)

Installing dbatools
-------------------

To install [dbatools](http://dbatools.io) from the [Powershell Gallery](https://www.powershellgallery.com/packages/dbatools) simply run

   Install-Module dbatools -Scope CurrentUser

This will prompt you to allow installing from an untrusted repository

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-126.png)

and dbatools is ready to go

    #Set a credential
    $cred = Get-Credential
    # Show the databases on the local instance
    Get-DbaDatabase -SqlInstance localhost -SqlCredential $cred


[![](https://blog.robsewell.com/assets/uploads/2019/04/image-127.png)

Connecting with Azure Data Studio
---------------------------------

I can also connect with Azure Data Studio

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-128.png)

and connect

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-129.png)

Just a quick little post explaining what I did 🙂

Happy Linuxing!