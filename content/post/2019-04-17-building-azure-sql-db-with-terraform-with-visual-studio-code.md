---
title: "Building Azure SQL Db with Terraform with Visual Studio Code"
date: "2019-04-17" 
categories:
  - Blog

tags:
  - Terraform
  - Azure
  - Azure SQL Database
  - Visual Studio Code
  - IaaC


image: assets/uploads/2019/04/image-42.png

---
I have been using [Terraform](https://www.terraform.io/) for the last week or so to create some infrastructure and decided to bring that knowledge back to a problem that I and others suffer from – building environments for presentations, all for the sake of doing some learning.

What is Terraform?
------------------

According to the website

>   
> HashiCorp Terraform enables you to safely and predictably create, change, and improve infrastructure. It is an open source tool that codifies APIs into declarative configuration files that can be shared amongst team members, treated as code, edited, reviewed, and versioned
> 
>   
> [https://www.terraform.io/](https://www.terraform.io/)

This means that I can define my infrastructure as code. If I can do that then I can reliably do the same thing again and again, at work to create environments that have the same configuration or outside of work to repeatedly build the environment I need.

Building an Azure SQL Database with Terraform
---------------------------------------------

To understand how to build a thing the best place to start is the documentation [https://www.terraform.io/docs](https://www.terraform.io/docs) . For an [Azure SQL Db in the docs](https://www.terraform.io/docs/providers/azurerm/r/sql_database.html) you will find a block of code that looks like this

     resource "azurerm_resource_group" "test" {
      name     = "acceptanceTestResourceGroup1"
      location = "West US"
    }
    
    resource "azurerm_sql_server" "test" {
      name                         = "mysqlserver"
      resource_group_name          = "${azurerm_resource_group.test.name}"
      location                     = "West US"
      version                      = "12.0"
      administrator_login          = "4dm1n157r470r"
      administrator_login_password = "4-v3ry-53cr37-p455w0rd"
    }
    
    resource "azurerm_sql_database" "test" {
      name                = "mysqldatabase"
      resource_group_name = "${azurerm_resource_group.test.name}"
      location            = "West US"
      server_name         = "${azurerm_sql_server.test.name}"
    
      tags = {
        environment = "production"
      }
    }

If you read the code, you can see that there are key value pairs defining information about the resource that is being created. Anything inside a ${} is a dynamic reference. So

   resource_group_name          = "${azurerm_resource_group.test.name}"
refers to the name property in the azure\_resource\_group block called test (or the name of the resource group 🙂 )

Infrastructure As Code
----------------------

So I can put that code into a file (name it main.tf) and alter it with the values and “run Terraform” and what I want will be created. Lets take it a step further though because I want to be able to reuse this code. Instead of hard-coding all of the values I am going to use variables. I can do this by creating another file called variables.tf which looks like

     variable "presentation" {
        description = "The name of the presentation - used for     tagging Azure resources so I know what they belong to"
        default = "dataindevon"
    }
    
    variable "ResourceGroupName" {
      description = "The Resource Group Name"
      default     = "beardrules"
    }
    
    variable "location" {
      description = "The Azure Region in which the resources in     this example should exist"
      default     = "uksouth"
    }
    
    variable "SqlServerName" {
      description = "The name of the Azure SQL Server to be     created or to have the database on - needs to be unique,     lowercase between 3 and 24 characters including the prefix"
      default     = "jeremy"
    }
    variable "SQLServerAdminUser" {
      description = "The name of the Azure SQL Server Admin user     for the Azure SQL Database"
      default     = "Beard"
    }
    variable "SQLServerAdminPassword" {
      description = "The Azure SQL Database users password"
      default     = "JonathanlovesR3ge%"
    }
    
    variable "SqlDatabaseName" {
      description = "The name of the Azure SQL database on - needs     to be unique, lowercase between 3 and 24 characters     including the prefix"
      default     = "jsdb"
    }
    
    variable "Edition" {
      description = "The Edition of the Database - Basic,     Standard, Premium, or DataWarehouse"
      default     = "Standard"
    }
    
    variable "ServiceObjective" {
      description = "The Service Tier S0, S1, S2, S3, P1, P2, P4,     P6, P11 and ElasticPool"
      default     = "S0"
    }


and my main.tf then looks like this.

    provider "azurerm" {
        version = "=1.24.0"
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
      resource_group_name          = "${azurerm_resource_group.    presentation.name}"
      location                     = "${var.location}"
      version                      = "12.0"
      administrator_login          = "${var.SQLServerAdminUser}"
      administrator_login_password = "${var.SQLServerAdminPassword}    "
        tags = {
        environment = "${var.presentation}"
      }
    }
    
    resource "azurerm_sql_database" "presentation" {
      name                = "${var.SqlDatabaseName}"
      resource_group_name = "${azurerm_sql_server.presentation.    resource_group_name}"
      location            = "${var.location}"
      server_name         = "${azurerm_sql_server.presentation.    name}"
      edition                          = "${var.Edition}"
      requested_service_objective_name = "${var.ServiceObjective}"
    
      tags = {
        environment = "${var.presentation}"
      }
    }

You can find these files in my [GitHub Repository](https://github.com/SQLDBAWithABeard/Presentations-AzureSQLDB/tree/master/Manual) here.

Alright – deploy something
--------------------------

To deploy the code that I have written I need to download Terraform from [https://www.terraform.io/downloads.html](https://www.terraform.io/downloads.html) and then extract the exe to a folder in my PATH. (I chose C:\\Windows). Then in Visual Studio Code I installed two extensions The [Terraform Extension by Mikael Olenfalk](https://marketplace.visualstudio.com/items?itemName=mauve.terraform) which enables syntax highlighting and auto-completion for the tf files and the [Azure Terraform](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azureterraform) extension. You will need also need [Node.js from here](https://nodejs.org/en/).

With those in place I navigated to the directory holding my files in Visual Studio Code and pressed F1 and started typing azure terraform and chose Azure Terraform Init

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-39.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-39.png?ssl=1)

I was then prompted to use Cloud Shell and a browser opened to login. Once I had logged in I waited until I saw this

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-40.png)](blob:https://blog.robsewell.com/787b935b-930a-45c4-ac43-18a18193e01f)

I press F1 again and this time choose Azure Terraform plan. This is going to show me what Terraform is going to do if it applies this configuration.

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-41.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-41.png?ssl=1)

You can see the what is going to be created. It is going to create 3 things

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-42.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-42.png?ssl=1)

Once you have checked that the plan is what you want, press F1 again and choose Azure Terraform Apply

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-43.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-43.png?ssl=1)

You are then asked to confirm that this is what you want. Only “yes” will be accepted. Then you will see the infrastructure being created

![](https://blog.robsewell.com/assets/uploads/2019/04/image-44.png)

and a minute later

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-45.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-45.png?ssl=1)

and Jeremy exists in the beardrules resource group

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-49.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-49.png?ssl=1)

Then once I have finished with using the sqlinstance. I can press F1 again and choose Azure Terraform Destroy. Again there is a confirmation required.

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-47.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-47.png?ssl=1)

and you will see the progress for 46 seconds

![](https://blog.robsewell.com/assets/uploads/2019/04/image-50.png)

and all of the resources have gone.

Thats a good start. This enables me to create resources quickly and easily and keep the configuration for them safely in source control and easy to use.

[In my next post I will create an Azure DevOps pipeline to deploy an AZure SQL Db withTerraform](https://blog.robsewell.com/building-azure-sql-db-with-terraform-using-azure-devops/).

[The post after will show how to use Azure DevOps Task Groups to use the same build steps in multiple pipelines and build an Azure Linux SQL Server VM](https://blog.robsewell.com/using-the-same-azure-devops-build-steps-for-terraform-with-different-pipelines-with-task-groups/)

[The post after that will show how to use Azure DevOps templates to use the same build steps across many projects and build pipelines and will build a simple AKS cluster](https://blog.robsewell.com/using-azure-devops-build-pipeline-templates-with-terraform-to-build-an-aks-cluster/)
