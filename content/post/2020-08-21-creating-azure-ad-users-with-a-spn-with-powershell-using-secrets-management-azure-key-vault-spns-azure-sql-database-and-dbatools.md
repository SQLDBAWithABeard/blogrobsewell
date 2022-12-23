---
title: "Creating Azure SQL Database AAD Contained Database Users with an SPN using PowerShell, Secrets Management, Azure Key Vault, and dbatools"
categories:
  - Blog
  - dbatools
  - Azure DevOps
  - SQL Server

tags:
  - automation
  - dbatools
  - PowerShell
  - Azure
  - Secret Management
  - Import-CliXml
  - SPN
  - Terraform
  - Azure SQL Database
  - Key Vault

header:
  teaser: /assets/uploads/2020/08/image-16.png

---
Following on from my posts about using Secret Management [Good bye Import-CliXml](https://blog.robsewell.com/good-bye-import-clixml-use-the-secrets-management-module-for-your-labs-and-demos/) and [running programmes as a different user](https://blog.robsewell.com/using-secret-management-module-to-run-ssms-vs-code-and-azure-data-studio-as-another-user/), I have another use case.

After creating Azure SQL Databases in an Elastic Pool using a process pretty similar to this one [I blogged about last year](https://blog.robsewell.com/building-azure-sql-db-with-terraform-using-azure-devops/), I needed to be able to programmatically create users and assign permissions.

I need a user to login with
---------------------------

When I created my Azure SQL Server with Terraform, I set the Azure Admin to be a SPN as you can see in the image from the portal and set it to have an identity using the documentation for [azurerm\_mssql\_server](https://www.terraform.io/docs/providers/azurerm/r/sql_server.html).

![](https://blog.robsewell.com/assets/uploads/2020/08/image-9.png)

![](https://blog.robsewell.com/assets/uploads/2020/08/image-18.png)
This allows this user to manage the access for the SQL Server as long as the SQL Server Azure AD identity has Directory Reader privileges. The SQL Server is called temp-beard-sqls and as you can see the identity is assigned to the role.

![](https://blog.robsewell.com/assets/uploads/2020/08/image-11.png)
The privileges required to do this for a single identity are quite high

![](https://blog.robsewell.com/assets/uploads/2020/08/image-12.png)

so now, you can assign an Azure Active Directory Group to that Role and allow less-privileged users to add the identity to this group . The documentation is [here](https://docs.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-service-principal?WT.mc_id=DP-MVP-5002693) and there is a tutorial [here](https://docs.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-service-principal-tutorial?WT.mc_id=DP-MVP-5002693) explaining the steps you need to take.

What is an Azure SPN?  
----------------------------------------

> An Azure service principal is an identity created for use with applications, hosted services, and automated tools to access Azure resources.

[https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli?toc=%2Fazure%2Fazure-resource-manager%2Ftoc.json&view=azure-cli-latest](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli?toc=%2Fazure%2Fazure-resource-manager%2Ftoc.json&view=azure-cli-latest?WT.mc_id=DP-MVP-5002693)

I created the SPN using Azure CLI straight from the Azure Portal by clicking this button

![](https://blog.robsewell.com/assets/uploads/2020/08/image-2.png)

and running

    az ad sp create-for-rbac --name ServicePrincipalName

This will quickly create a SPN for you and return the password

![](https://blog.robsewell.com/assets/uploads/2020/08/image-3.png)

Yes I have deleted this one

Add Azure Key Vault to Secret Management
----------------------------------------

In my previous posts, I have been using the Default Key Vault which is limited to your local machine and the user that is running the code. It would be better to use Azure Key Vault to store the details for the SPN so that it safely stored in the cloud and not on my machine and also so that anyone (or app) that has permissions to the vault can use it.

First you need to login to Azure in PowerShell (You will need to have the AZ* modules installed)

    Connect-AzAccount

Be aware, the login box can appear behind the VS Code or Azure Data Studio window!

Once connected, if you have several Azure subscriptions, you can list them with

    Get-AzSubscription

You can choose your subscription with

    $AzureSubscription = Set-AzContext -SubscriptionName "NAME OF SUBSCRIPTION"

For the Secret Management Module to manage the Azure Key Vault, you first need to register it.

Ensure that you have permissions to connect by following the details in the network security documentation [https://docs.microsoft.com/en-us/azure/key-vault/general/network-security](https://docs.microsoft.com/en-us/azure/key-vault/general/network-security?WT.mc_id=DP-MVP-5002693) and the secure access documentation [https://docs.microsoft.com/en-us/azure/key-vault/general/secure-your-key-vault](https://docs.microsoft.com/en-us/azure/key-vault/general/secure-your-key-vault?WT.mc_id=DP-MVP-5002693)

Then you can run `Register-SecretVault` . You need to provide the local name for the key vault, the module name `Az.KeyVault`, and a `VaultParameters` hashtable with the KeyVault name and the Azure Subscription ID. You can register other types of Key Vaults to the Secret Management module in this way and they will require different values for the `VaultParameters` parameter.

    $KeyVaultName = 'beard-key-vault'
    Register-SecretVault -Name BeardKeyVault -ModuleName Az.KeyVault -VaultParameters @{ AZKVaultName = $KeyVaultName; SubscriptionId = $AzureSubscription.Subscription.Id }

Adding the SPN details to the Azure Key Vault
---------------------------------------------

Using the values for AppID – (Note NOT the display name) and the values for the password from the Azure CLI output or by creating a new secret for the SPN with PowerShell or via the portal. You can use the following code to add the SPN details and the tenantid to the Azure Key Vault using the Secret Management module

    $ClientId = Read-Host "Enter ClientID" -AsSecureString
    $SecretFromPortal = Read-Host "Enter Client Secret" -AsSecureString 
    $tenantid = Read-Host "Enter TenantId" -AsSecureString 
    Set-Secret -Vault BeardKeyVault -Name service-principal-guid -Secret $ClientId
    Set-Secret -Vault BeardKeyVault -Name service-principal-secret -SecureStringSecret $SecretFromPortal
    Set-Secret -Vault BeardKeyVault -Name Tenant-Id -Secret $tenantid

You can also do this with the Az.KeyVault module by following the instructions [here](https://docs.microsoft.com/en-us/azure/key-vault/secrets/quick-create-powershell?WT.mc_id=DP-MVP-5002693)

You can see the secrets in the portal

![](https://blog.robsewell.com/assets/uploads/2020/08/image-6.png)

and also at the command line with the Secret Management module using

    Get-SecretInfo -Vault RegisteredNameOfVault

![](https://blog.robsewell.com/assets/uploads/2020/08/image-5.png)

Can my user connect?
--------------------

If I try to connect in Azure Data Studio to my Azure SQL Database with my AAD account to the temp-sql-db-beard database. It fails.  
  
By the way a great resource for troubleshooting the SQL error 18456 failure states can be found here [https://sqlblog.org/2020/07/28/troubleshooting-error-18456](https://sqlblog.org/2020/07/28/troubleshooting-error-18456)

![](https://blog.robsewell.com/assets/uploads/2020/08/image-13.png)

dbatools to the rescue 🙂
-------------------------

dbatools is an open source community collaboration PowerShell module for administrating SQL Server. You can find more about it at [dbatools.io](http://dbatools.io) and get the book that Chrissy and I are writing about dbatools at [dbatools.io\\book](http://dbatools.io%5Cbook)

You can connect to Azure SQL Database with an Azure SPN using the following code. It will get the secrets from the Azure Key Vault that have been set above and create a connection. Lets see if I can run a query as the SPN.

    $SqlInstance = 'temp-beard-sqls.database.windows.net'
    $databasename = 'master'
    $appid = Get-Secret -Vault BeardKeyVault -Name service-principal-guid  -AsPlainText
    $Clientsecret = Get-Secret -Vault BeardKeyVault -Name service-principal-secret
    $credential = New-Object System.Management.Automation.PSCredential ($appid,$Clientsecret)
    $tenantid = Get-Secret -Vault BeardKeyVault -Name Sewells-Tenant-Id -AsPlainText
    $AzureSQL = Connect-DbaInstance -SqlInstance $SqlInstance -Database $databasename  -SqlCredential $credential -Tenant $tenantid  -TrustServerCertificate 
    
    Invoke-DbaQuery -SqlInstance $AzureSql -Database master  -SqlCredential $credential -Query "Select SUSER_NAME() as 'username'" 
    

![](https://blog.robsewell.com/assets/uploads/2020/08/image-14.png)

Excellent 🙂

Add a user to the user database
-------------------------------

I can then add my user to the temp-sql-db-beard Database. I need to create a new connection to the user database as you cannot use the `USE [DatabaseName]` statement

    $Userdatabasename = 'temp-sql-db-beard'
    
    $AzureSQL = Connect-DbaInstance -SqlInstance $SqlInstance -Database $Userdatabasename -SqlCredential $credential -Tenant $tenantid  -TrustServerCertificate 
    

Whilst you can use dbatools to create new users in Azure SQL Database at present you cant create AAD users. You can run a T-SQL Script to do this though. This script will create a contained database user in the database. I have added the role membership also but this can also be done with [Add-DbaDbRoleMember](https://docs.dbatools.io/#Add-DbaDbRoleMember) from dbatools

    $Query = @"
    CREATE USER [rob@sewells-consulting.co.uk] FROM EXTERNAL PROVIDER
    ALTER ROLE db_datareader ADD MEMBER [rob@sewells-consulting.co.uk]
    "@
    Invoke-DbaQuery -SqlInstance $AzureSql -Database $Userdatabasename  -SqlCredential $credential -Query $Query

Lets check the users on the database with dbatools

    Get-DbaDbUser -SqlInstance $AzureSql -Database $Userdatabasename  |Out-GridView

![](https://blog.robsewell.com/assets/uploads/2020/08/image-15.png)

I have my user and it is of type External user. Lets see if I can connect

![](https://blog.robsewell.com/assets/uploads/2020/08/image-16.png)

Bingo 🙂  
  
Happy Automating

Because I dont like to see awesome people struggling with PowerShell

![](https://blog.robsewell.com/assets/uploads/2020/08/image-17.png)

Here is the same code using just the Az.KeyVault module

    $appid = (Get-AzKeyVaultSecret -vaultName "beard-key-vault" -name "service-principal-guid").SecretValueText
    $Clientsecret = (Get-AzKeyVaultSecret -vaultName "beard-key-vault" -name "service-principal-secret").SecretValue
    $credential = New-Object System.Management.Automation.PSCredential ($appid,$Clientsecret)
    $tenantid =  (Get-AzKeyVaultSecret -vaultName "beard-key-vault" -name "Sewells-Tenant-Id").SecretValueText
    $AzureSQL = Connect-DbaInstance -SqlInstance $SqlInstance -Database $databasename  -SqlCredential $credential -Tenant $tenantid  -TrustServerCertificate