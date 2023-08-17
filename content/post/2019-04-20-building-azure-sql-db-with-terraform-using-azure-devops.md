---
title: "Building Azure SQL Db with Terraform using Azure DevOps"
date: "2019-04-20"
categories:
  - Azure
  - Blog
  - Azure DevOps
  - IaC

tags:
  - terraform
  - Azure SQL Database
  - Azure DevOps
  - automation


image: assets/uploads/2019/04/image-49.png
---
In [my last post](https://blog.robsewell.com/building-azure-sql-db-with-terraform-with-visual-studio-code/) I showed how to create a Resource Group and an Azure SQL Database with Terraform using Visual Studio Code to deploy.

Of course, I haven't stopped there, who wants to manually run code to create things. There was a lot of install this and set up that. I would rather give the code to a build system and get it to run it. I can then even set it to automatically deploy new infrastructure when I commit some code to alter the configuration.

This scenario though is to build environments for presentations. Last time I created an Azure SQL DB and tagged it with DataInDevon (By the way you can get tickets for [Data In Devon here](http://dataindevon.co.uk) – It is in Exeter on April 26th and 27th)

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-49.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-49.png?ssl=1)

If I want to create the same environment but give it tags for a different event (This way I know when I can delete resources in Azure!) or name it differently, I can use Azure DevOps and alter the variables. I could just alter the code and commit the change and trigger a build or I could create variables and enable them to be set at the time the job is run. I use the former in “work” situations and the second for my presentations environment.

I have created a project in [Azure DevOps](https://azure.microsoft.com/en-gb/services/devops/?WT.mc_id=DP-MVP-5002693) for my Presentation Builds. I will be using GitHub to share the code that I have used. Once I clicked on pipelines, this is the page I saw

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-51.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-51.png?ssl=1)

Clicking new pipeline, Azure DevOps asked me where my code was

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-52.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-52.png?ssl=1)

I chose GitHub, authorised and chose the repository.

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-53.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-53.png?ssl=1)

I then chose Empty Job on the next page. See the Configuration as code choice? We will come back to that later and our infrastructure as code will be deployed with a configuration as code 🙂

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-54.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-54.png?ssl=1)

The next page allows us to give the build a good name and choose the Agent Pool that we want to use. Azure DevOps gives 7 different hosted agents running Linux, Mac, Windows or you can download an agent and run it on your own cpus. We will use the default agent for this process.

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-55.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-55.png?ssl=1)

Clicking on Agent Job 1 enables me to change the name of the Agent Job. I could also choose a different type of Agent for different jobs within the same pipeline. This would be useful for testing different OS’s for example but for right now I shall just name it properly.

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-65.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-65.png?ssl=1)

State
-----

First we need somewhere to store the state of our build so that if we re-run it the Terraform plan step will be able to work out what it needs to do. (This is not absolutely required just for building my presentation environments and this might not be the best way to achieve this but for right now this is what I do and it works.)

I click on the + and search for Azure CLI.

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-58.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-58.png?ssl=1)

and click on the Add button which gives me some boxes to fill in.

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-59.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-59.png?ssl=1)

I choose my Azure subscription from the first drop down and choose Inline Script from the second

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-60.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-60.png?ssl=1)

Inside the script block I put the following code

    # the following script will create Azure resource group, Storage account and a Storage container which will be used to store terraform state
    call az group create --location $(location) --name $(TerraformStorageRG)

    call az storage account create --name $(TerraformStorageAccount) --resource-group $(TerraformStorageRG) --location $(location) --sku Standard_LRS

    call az storage container create --name terraform --account-name $(TerraformStorageAccount)

This will create a Resource Group, a storage account and a container and use some variables to provide the values, we will come back to the variables later.

Access Key
----------

The next thing that we need to do is to to enable the job to be able to access the storage account. We don’t want to store that key anywhere but we can use our Azure DevOps variables and some PowerShell to gather the access key and write it to the variable when the job is running . To create the variables I clicked on the variables tab

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-66.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-66.png?ssl=1)

and then added the variables with the following names TerraformStorageRG, TerraformStorageAccount and location from the previous task and TerraformStorageKey for the next task.

![](https://blog.robsewell.com/assets/uploads/2019/04/image-62.png)

With those created, I go back to Tasks and add an Azure PowerShell task

![](https://blog.robsewell.com/assets/uploads/2019/04/image-63.png)

I then add this code to get the access key and overwrite the variable.

    # Using this script we will fetch storage key which is required in terraform file to authenticate backend storage account

    $key=(Get-AzureRmStorageAccountKey -ResourceGroupName $(TerraformStorageRG) -AccountName $(TerraformStorageAccount)).Value[0]

    Write-Host "##vso[task.setvariable variable=TerraformStorageKey]$key"

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-67.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-67.png?ssl=1)

Infrastructure as Code
----------------------

In [my GitHub repository](https://github.com/SQLDBAWithABeard/Presentations-AzureSQLDB) I now have the following folders

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-64.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-64.png?ssl=1)

The manual folders hold the code [from the last blog post](https://blog.robsewell.com/building-azure-sql-db-with-terraform-with-visual-studio-code/). In the Build folder, the main.tf file is identical and looks like this.

    provider "azurerm" {
        version = "=1.24.0"
    }

    terraform {
      backend "azurerm" {
        key = "terraform.tfstate"
      }
    }

    resource "azurerm_resource_group" "presentation" {
      name     = "${var.ResourceGroupName}"
      location = "${var.location}"
        tags = {
        environment = "${var.presentation}"
      }
    }

    resource "azurerm_sql_server" "presentation" {
      name                         = "${var.SqlServerName}"
      resource_group_name          = "${azurerm_resource_group.presentation.name}"
      location                     = "${var.location}"
      version                      = "12.0"
      administrator_login          = "__SQLServerAdminUser__"
      administrator_login_password = "__SQLServerAdminPassword__"
        tags = {
        environment = "${var.presentation}"
      }
    }

    resource "azurerm_sql_database" "presentation" {
      name                = "${var.SqlDatabaseName}"
      resource_group_name = "${azurerm_sql_server.presentation.resource_group_name}"
      location            = "${var.location}"
      server_name         = "${azurerm_sql_server.presentation.name}"
      edition                          = "${var.Edition}"
      requested_service_objective_name = "${var.ServiceObjective}"

      tags = {
        environment = "${var.presentation}"
      }
    }

The variables.tf folder looks like this.

    variable "presentation" {
        description = "The name of the presentation - used for tagging Azure resources so I know what they belong to"
        default = "__Presentation__"
    }

    variable "ResourceGroupName" {
      description = "The Prefix used for all resources in this example"
      default     = "__ResourceGroupName__"
    }

    variable "location" {
      description = "The Azure Region in which the resources in this example should exist"
      default     = "__location__"
    }

    variable "SqlServerName" {
      description = "The name of the Azure SQL Server to be created or to have the database on - needs to be unique, lowercase between 3 and 24 characters including the prefix"
      default     = "__SqlServerName__"
    }

    variable "SQLServerAdminUser" {
      description = "The name of the Azure SQL Server Admin user for the Azure SQL Database"
      default     = "__SQLServerAdminUser__"
    }
    variable "SQLServerAdminPassword" {
      description = "The Azure SQL Database users password"
      default     = "__SQLServerAdminPassword__"
    }
    variable "SqlDatabaseName" {
      description = "The name of the Azure SQL database on - needs to be unique, lowercase between 3 and 24 characters including the prefix"
      default     = "__SqlDatabaseName__"
    }


    variable "Edition" {
      description = "The Edition of the Database - Basic, Standard, Premium, or DataWarehouse"
      default     = "__Edition__"
    }

    variable "ServiceObjective" {
      description = "The Service Tier S0, S1, S2, S3, P1, P2, P4, P6, P11 and ElasticPool"
      default     = "__ServiceObjective__"
    }

It is exactly the same except that the values have been replaced by the value name prefixed and suffixed with __. This will enable me to replace the values with the variables in my Azure DevOps Build job.

The backend-config.tf file will store the details of the state that will be created by the first step and use the access key that has been retrieved in the second step.

    resource_group_name = "__TerraformStorageRG__"

    storage_account_name = "__TerraformStorageAccount__"

    container_name = "terraform"

    access_key = "__TerraformStorageKey__"

I need to add the following variables to my Azure DevOps Build – Presentation, ResourceGroupName, SqlServerName, SQLServerAdminUser, SQLServerAdminPassword, SqlDatabaseName, Edition, ServiceObjective . Personally I would advise setting the password or any other sensitive values to sensitive by clicking the padlock for that variable. This will stop the value being written to the log as well as hiding it behind *’s

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-69.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-69.png?ssl=1)

Because I have tagged the variables with Settable at queue time , I can set the values whenever I run a build, so if I am at a different event I can change the name.

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-70.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-70.png?ssl=1)

But the build job hasn’t been set up yet. First we need to replace the values in the variables file.

Replace the Tokens
------------------

I installed the [Replace Tokens Task](https://marketplace.visualstudio.com/items?itemName=qetza.replacetokens) from the marketplace and added that to the build.

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-72.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-72.png?ssl=1)

I am going to use a standard naming convention for my infrastructure code files so I add Build to the Root Directory. You can also click the ellipses and navigate to a folder in your repo. In the Target Files I add *”*_/*_.tf” and “**_/*_.tfvars” which will search all of the folders (**) and only work on files with a .tf or .tfvars extension (/*.tfvars) The next step is to make sure that the replacement prefix and suffix are correct. It is hidden under Advanced

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-74.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-74.png?ssl=1)

Because I often forget this step and to aid in troubleshooting I add another step to read the contents of the files and place them in the logs. I do this by adding a PowerShell step which uses

    Get-ChildItem .\Build -Recurse

    Get-Content .\Build\*.tf
    Get-Content .\Build\*.tfvars

Under control options there is a check box to enable or disable the steps so once I know that everything is ok with the build I will disable this step. The output in the log of a build will look like this showing the actual values in the files. This is really useful for finding spaces :-).

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-76.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-76.png?ssl=1)

Running the Terraform in Azure DevOps
-------------------------------------

With everything set up we can now run the Terraform. I installed the [Terraform task](https://marketplace.visualstudio.com/items?itemName=petergroenewegen.PeterGroenewegen-Xpirit-Vsts-Release-Terraform) from the marketplace and added a task. We are going to follow the same process as the last blog post, init, plan, apply but this time we are going to automate it 🙂

First we will initialise

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-130.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-130.png?ssl=1)

I put Build in the Terraform Template path. The Terraform arguments are

    init -backend-config="0-backend-config.tfvars"

which will tell the Terraform to use the backend-config.tfvars file for the state. It is important to tick the Install terraform checkbox to ensure that terraform is available on the agent and to add the Azure Subscription (or Service Endpoint in a corporate environment

After the Initialise, I add the Terraform task again add Build to the target path and this time the argument is plan

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-78.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-78.png?ssl=1)

Again, tick the install terraform checkbox and also the Use Azure Service Endpoint and choose the Azure Subscription.

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-131.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-131.png?ssl=1)

We also need to tell the Terraform where to find the tfstate file by specifying the variables for the resource group and storage account and the container

Finally, add another Terraform task for the apply remembering to tick the install Terraform and Use Azure checkboxes

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-79.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-79.png?ssl=1)

The arguments are

    apply -auto-approve

This will negate the requirement for the “Only “yes” will be accepted to approve” [from the manual steps post](https://blog.robsewell.com/building-azure-sql-db-with-terraform-with-visual-studio-code/)!

Build a Thing
-------------

Now we can build the environment – Clicking Save and Queue

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-80.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-80.png?ssl=1)

opens this dialogue

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-81.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-81.png?ssl=1)

where the variables can be filled in.

The build will be queued and clicking on the build number will open the logs

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-82.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-82.png?ssl=1)

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-83.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-83.png?ssl=1)

6 minutes later the job has finished

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-84.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-84.png?ssl=1)

and the resources have been created.

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-85.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-85.png?ssl=1)

If I want to look in the logs of the job I can click on one of the steps and take a look. This is the apply step

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-87.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-87.png?ssl=1)

Do it Again For Another Presentation
------------------------------------

So that is good, I can create my environment as I want it. Once my presentation has finished I can delete the Resource Groups. When I need to do the presentation again, I can queue another build and change the variables

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-88.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-88.png?ssl=1)

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-89.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-89.png?ssl=1)

The job will run

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-90.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-90.png?ssl=1)

and the new resource group will be created

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-91.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-91.png?ssl=1)

all ready for my next presentation 🙂

This is brilliant, I can set up the same solution for different repositories for different presentations (infrastructure) and recreate the above steps.

[The next post will show how to use Azure DevOps Task Groups to use the same build steps in multiple pipelines and build an Azure Linux SQL Server VM](https://blog.robsewell.com/using-the-same-azure-devops-build-steps-for-terraform-with-different-pipelines-with-task-groups/)

[The post after that will show how to use Azure DevOps templates to use the same build steps across many projects and build pipelines and will build a simple AKS cluster](https://blog.robsewell.com/using-azure-devops-build-pipeline-templates-with-terraform-to-build-an-aks-cluster/)

[The first post showed how to build an Azure SQL Database with Terraform using VS Code](https://blog.robsewell.com/building-azure-sql-db-with-terraform-with-visual-studio-code/)
