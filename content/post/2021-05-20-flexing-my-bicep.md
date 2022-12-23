---
title: "Flexing My Bicep - Deploy an Azure SQL Database -Intro to Azure Bicep IaC"
date: "2021-05-20" 
categories:
  - Blog
  - Bicep
  - IaC

tags:
 - Blog
 - Bicep
 - Azure
 - SQL Server
 - VS Code


header:
  teaser: /assets/uploads/2021/Bicep/xavier-von-erlach-ooR1jY2yFr4-unsplash.jpg
---

# Starting working out?

It is important to keep a healthy body and mind, especially when my life is so sedentary these days. Getting exercise is good for both. This blog post has nothing to do with exercise though (apart from maybe exercising the mind)

# Project Bicep

[Bicep](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/bicep-overview?WT.mc_id=DP-MVP-5002693) is a language for declaring and deploying Azure Resources. Like [Terraform](https://www.terraform.io/) it enables you to define your infrastructure as code.

## WHy use Bicep instead?

I really like being able to control infrastructure with code. I have used [Terraform to deploy infrastructure](https://blog.robsewell.com/tags/#terraform) and almost exclusively on Azure. I have created and altered many environments for clients over the past couple of years using Terraform. I have also used ARM templates but found them confusing and unwieldly to use. 

## Existing State

Terraform will deploy the required changes to your infrastructure by comparing the existing state which is stored in a state file with the expected state which is created by running the plan command. If someone alters the Azure resource via the portal, Azure CLI or Azure PowerShell all kinds of mayhem can occur normally failure in deployment and time spent troubleshooting. It is possible to use the [`import` command in Terraform](https://www.terraform.io/docs/cli/commands/import.html) to get the existing resource state into the state file so that the comparison is performed against the existing state of the resource but this requires a lot of manual intervention.

Bicep deploys the changes by comparing the existing state of the Azure resources with the expected state in the code. This, for me, is a super benefit and reduces the complications of those type of errors.

## Latest API support

Terraform resources have a lag between features or properties from Azure being made available and those features or properties being incorporated into the Terraform resource. This has lead to me requiring my deployments to have additional Azure CLI, Azure PowerShell or worse both steps to achieve what I need.

Bicep immediately supports all preview and GA versions for Azure Services, I don't have to wait and all the things I can do are available to me.

## Authoring

I love [Visual Studio Code](https://code.visualstudio.com) and there is a [super extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep&WT.mc_id=devops-13338-abewan) that makes authoring a joy.

## What If Support

I have written before about the [importance of WhatIf for PowerShell functions and how to implement it](https://blog.robsewell.com/blog/powershell/how-to-write-a-powershell-function-to-use-confirm-verbose-and-whatif/) and Bicep has [What If for deployments](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/template-deploy-what-if?tabs=azure-powershell?WT.mc_id=DP-MVP-5002693) so that you can validate that the code you have written will perform the tasks that you expect.

## Deployments recorded in Azure

The changes that I make with Bicep are recorded in Azure and I can find them in the deployments for the Resource Group

## Cost

Bicep is free :-)

# Deploy an Azure SQL Database Rob

OK, let's see an example. I would like to deploy an Azure SQL Database into a Resource Group. I will need an Azure SQL Server resource and an Azure SQL Database resource. The [Azure Templates site](https://docs.microsoft.com/en-us/azure/templates/?WT.mc_id=DP-MVP-5002693) has the examples that I need. The [Azure SQL Server page](https://docs.microsoft.com/en-us/azure/templates/microsoft.sql/servers?tabs=bicep?WT.mc_id=DP-MVP-5002693) shows the Bicep code I need and the explanations of the expected values.

````
resource symbolicname 'Microsoft.Sql/servers@2020-11-01-preview' = {
  name: 'string'
  location: 'string'
  tags: {}
  identity: {
    type: 'string'
  }
  properties: {
    administratorLogin: 'string'
    administratorLoginPassword: 'string'
    version: 'string'
    minimalTlsVersion: 'string'
    publicNetworkAccess: 'string'
    encryptionIdentityId: 'string'
    keyId: 'string'
    administrators: {
      administratorType: 'ActiveDirectory'
      principalType: 'string'
      login: 'string'
      sid: 'string'
      tenantId: 'string'
      azureADOnlyAuthentication: bool
    }
  }
}
````
I create a file with a `.bicep` extension in VS Code

[![bicepfile](https://blog.robsewell.com/assets/uploads/2021/Bicep/bicepfile.png)](https://blog.robsewell.com/assets/uploads/2021/Bicep/bicepfile.png)

and add only the required values. (NOTE - this is just an example and I would never recommend that you would put the password for anything in a file in plain text, we will cover how to handle secrets later. )

````
resource sql 'Microsoft.Sql/servers@2020-11-01-preview' = {
  name: 'beardsqlrand01'
  location: 'northeurope'
  properties: {
    administratorLogin: 'sysadmin'
    administratorLoginPassword: 'dbatools.IO' // DON'T DO THIS - EVER
    version: '12.0'
  }
}
````
## Validate the deployment with WhatIf

I created an empty Resource Group for my test

````
New-AzResourceGroup -Name 'BicepTest' -Location 'northeurope'
````

Next, I am going to check that the code that I have written will perform the actions that I expect. I am hoping to get

- An Azure SQL Instance called beardsqlrand01
- In the location North Europe
- With an admin login and password as stated in the file (NO Don't ever do this in Production)

I do this using the Azure PowerShell command `New-AzResourceGroupDeployment` and give it the Resource Group Name and the path to the file

````
# Validate the deployment with Whatif
$DeploymentConfig = @{
    ResourceGroupName = 'BicepTest' 
    TemplateFile = '.\SimpleSqlDatabase\SqlInstance.bicep' 
    WhatIf   = $true
}
New-AzResourceGroupDeployment @DeploymentConfig
````

The first thing this does is check the status of the resources in the resource group

[![whatif](https://blog.robsewell.com/assets/uploads/2021/Bicep/whatif.png)](https://blog.robsewell.com/assets/uploads/2021/Bicep/whatif.png)

then it provides a list of what it will do. In this example there is only one resource.

[![whatifresult](https://blog.robsewell.com/assets/uploads/2021/Bicep/whatifresult.png)](https://blog.robsewell.com/assets/uploads/2021/Bicep/whatifresult.png)

This tells us that there will be a creation of 1 resource and that the values are as I expect them. As I am happy with that I can then deploy the infrastructure by changing the `WhatIf` value to false

````
# Deploy the changes
$DeploymentConfig = @{
    ResourceGroupName = 'BicepTest' 
    TemplateFile = '.\SimpleSqlDatabase\SqlInstance.bicep' 
    WhatIf   = $false
}
New-AzResourceGroupDeployment @DeploymentConfig
````

# Deployment can be seen in the Azure Portal

If I look in the Azure Portal, I can see the deployment is happening.

[![portaldeploying](https://blog.robsewell.com/assets/uploads/2021/Bicep/portaldeploying.png)](https://blog.robsewell.com/assets/uploads/2021/Bicep/portaldeploying.png)

Once it has finished I get an output on the screen

[![deploymentresult](https://blog.robsewell.com/assets/uploads/2021/Bicep/deploymentresult.png)](https://blog.robsewell.com/assets/uploads/2021/Bicep/deploymentresult.png)

and when I look in the portal at the deployment

[![portaldeploymentresult](https://blog.robsewell.com/assets/uploads/2021/Bicep/portaldeploymentresult.png)](https://blog.robsewell.com/assets/uploads/2021/Bicep/portaldeploymentresult.png)

and my resource has been created

[![portalsqlresource](https://blog.robsewell.com/assets/uploads/2021/Bicep/portalsqlresource.png)](https://blog.robsewell.com/assets/uploads/2021/Bicep/portalsqlresource.png)

## Add a database

I have my Azure SQL Instance, next I need a database. I look up [the resource information](https://docs.microsoft.com/en-us/azure/templates/microsoft.sql/servers/databases?tabs=bicep?WT.mc_id=DP-MVP-5002693) and add the required information to my bicep file.

````
resource sql 'Microsoft.Sql/servers@2020-11-01-preview' = {
  name: 'beardsqlrand01'
  location: 'northeurope'
  properties: {
    administratorLogin: 'sysadmin'
    administratorLoginPassword: 'dbatools.IO' // DON'T DO THIS - EVER
    version: '12.0'
    publicNetworkAccess: 'Disabled'
  }

 resource bearddatabase 'databases@2020-11-01-preview' = {
   name: 'BicepDatabase'
   location: 'northeurope'
   sku: {
     name: 'Basic'
   }
   properties: {}
 }
}
````

This is a super simple example. The database resource is defined within the SQL Instance resource with a name and a SKU.

We validate it in exactly the same way as before. This time we will see that we can incrementally add or change resources to our deployment and validate what will happen.

````
# Validate the deployment with Whatif
$DeploymentConfig = @{
    ResourceGroupName = 'BicepTest' 
    TemplateFile = '.\SimpleSqlDatabase\SqlInstance.bicep' 
    WhatIf   = $true
}
New-AzResourceGroupDeployment @DeploymentConfig
````

This time the result looks a little different as we already have a resource in the Resource Group.

[![whatifdatabase](https://blog.robsewell.com/assets/uploads/2021/Bicep/whatifdatabase.png)](https://blog.robsewell.com/assets/uploads/2021/Bicep/whatifdatabase.png)

At the top it gives you three types of changes

- Create
- NoChange
- Ignore

It shows at the bottom that the changes are

> Resource changes: 1 to create, 1 no change, 1 to ignore.

This tells you that it will create the Azure SQL Database, it will not change the Azure SQL Server and there is no change to the master database. 

I am happy with that validation, so I deploy the changes, again using the same code as before.

````
# Deploy the changes
$DeploymentConfig = @{
    ResourceGroupName = 'BicepTest' 
    TemplateFile = '.\SimpleSqlDatabase\SqlInstance.bicep' 
    WhatIf   = $false
}
New-AzResourceGroupDeployment @DeploymentConfig
````

If I look in the portal I can see the deployment

[![databasedeployment](https://blog.robsewell.com/assets/uploads/2021/Bicep/databasedeployment.png)](https://blog.robsewell.com/assets/uploads/2021/Bicep/databasedeployment.png)

and once it has completed I can see the database in the Portal

[![databasedeployed](https://blog.robsewell.com/assets/uploads/2021/Bicep/databasedeployed.png)](https://blog.robsewell.com/assets/uploads/2021/Bicep/databasedeployed.png)

Thats all there is to Bicep.

- Find the resource information in the docs
- Define your deployment in code
- Validate your deployment with WhatIf
- Deploy your changes

# Remove the Resource Group

Now that my test has finished I will remove the Resource Group. If you are following along, this is how to do that

````
Remove-AzResourceGroup -Name BicepTest -Force
````

# All of the code

I have added all of the code for this blog post to my GitHub here https://github.com/SQLDBAWithABeard/BeardBicep/tree/main/SimpleSqlDatabase so that you can follow along.

# Next steps

Now that you have an introduction to Bicep and can see how useful and powerful it can be, we will expand on this in the following blog posts.
