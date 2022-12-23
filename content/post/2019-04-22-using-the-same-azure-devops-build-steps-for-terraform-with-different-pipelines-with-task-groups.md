---
title: "Using the same Azure DevOps build steps for Terraform with different Pipelines with Task Groups to build an Azure Linux SQL VM"
date: "2019-04-22" 
categories:
  - azure
  - Blog
  - DevOps

tags:
  - automation
  - terraform
  - Azure DevOps
  - DevOps
  - Azure SQL VM
  - Linux

header:
  teaser: /assets/uploads/2019/04/image-107.png

---
In my [last post](https://blog.robsewell.com/building-azure-sql-db-with-terraform-using-azure-devops/) I showed how to build an Azure DevOps Pipeline for a Terraform build of an Azure SQLDB. This will take the terraform code and build the required infrastructure.

The plan all along has been to enable me to build _different_ environments depending on the requirement. Obviously I can repeat the steps from the last post for a new repository containing a Terraform code for a different environment but

> If you are going to do something more than once Automate It
> 
> who first said this? Anyone know?  

The build steps for building the Terraform are the same each time (if I keep a standard folder and naming structure) so it would be much more beneficial if I could keep them in a single place and any alterations to the process only need to be made in the one place 🙂

Task Groups
-----------

Azure DevOps has task groups. On [the Microsoft Docs web-page](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/task-groups?view=azure-devops?WT.mc_id=DP-MVP-5002693) they are described as

>   
> A _task group_ allows you to encapsulate a sequence of tasks, already defined in a build or a release pipeline, into a single reusable task that can be added to a build or release pipeline, just like any other tas
> 
>   
> [https://docs.microsoft.com/en-us/azure/devops/pipelines/library/task-groups?view=azure-devops](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/task-groups?view=azure-devops?WT.mc_id=DP-MVP-5002693)

If you are doing this with a more complicated existing build pipeline it is important that [you read the Before You Create A Task Group on the docs pag](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/task-groups?view=azure-devops?WT.mc_id=DP-MVP-5002693)e. This will save you time when trying to understand why variables are not available (Another grey hair on my beard!)

Creating A Task Group
---------------------

Here’s the thing, creating a task group is so easy it should be the default way you create Azure DevOps Pipelines. Let me walk you through it

I will use the Build Pipeline from the previous post. Click edit from the build page

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-92.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-92.png?ssl=1)

Then CTRL and click to select all of the steps

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-93.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-93.png?ssl=1)

Right Click and theres a Create Task Group button to click !

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-94.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-94.png?ssl=1)

You can see that it has helpfully added the values for the parameters it requires for the location, Storage Account and the Resource Group.

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-95.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-95.png?ssl=1)

Remember the grey beard hair above? We need to change those values to use the variables that we will add to the Build Pipeline using

    $(VariableName)

Once you have done that click Create

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-96.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-96.png?ssl=1)

This will also alter the current Build Pipeline to use the Task Group. Now we have a Task Group that we can use in any build pipeline in this project.

Using the Task Group with a new Build Pipeline to build an Azure Linux SQL VM
-----------------------------------------------------------------------------

Lets re-use the build steps to create an Azure SQL Linux VM. First I created a [new GitHub Repository](https://github.com/SQLDBAWithABeard/Presentations-AzureSQLVM) for my Terraform code. Using the docs I created the Terraform to create a resource group, a Linux SQL VM, a virtual network, a subnet, a NIC for the VM, a public IP for the VM, a network security group with two rules, one for SQL and one for SSH. It will look like this

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-114.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-114.png?ssl=1)

The next step is to choose the repository

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-98.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-98.png?ssl=1)

again we are going to select Empty job (although the next post will be about the Configuration as Code 🙂

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-99.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-99.png?ssl=1)

[As before](https://blog.robsewell.com/building-azure-sql-db-with-terraform-using-azure-devops/) we will name the Build Pipeline and the Agent Job Step and click the + to add a new task. This time we will search for the Task Group name that we created

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-100.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-100.png?ssl=1)

I need to add in the variables from the variable.tf in the code and also for the Task Group

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-117.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-117.png?ssl=1)

and when I click save and queue

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-102.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-102.png?ssl=1)

It runs for less than 7 minutes

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-118.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-118.png?ssl=1)

and when I look in the Azure portal

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-119.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-119.png?ssl=1)

and I can connect in Azure Data Studio

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-129.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-129.png?ssl=1)

Altering The Task Group
-----------------------

You can find the Task Groups under Pipelines in your Azure DevOps project

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-97.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-97.png?ssl=1)

Click on the Task Group that you have created and then you can alter, edit it if required and click save

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-107.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-107.png?ssl=1)

This will warn you that any changes will affect all pipelines and task groups that are using this task group. To find out what will be affected click on references

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-108.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-108.png?ssl=1)

  

which will show you what will be affected.

[![](https://blog.robsewell.com/assets/uploads/2019/04/image-109.png)](https://blog.robsewell.com/assets/uploads/2019/04/image-109.png?ssl=1)

Now I can run the same build steps for any Build Pipeline and alter them all in a single place using Task Groups simplifying the administration of the Build Pipelines.

[The next post will show how to use Azure DevOps templates to use the same build steps across many projects and build pipelines and will build a simple AKS cluster](https://blog.robsewell.com/using-azure-devops-build-pipeline-templates-with-terraform-to-build-an-aks-cluster/)

[The first post showed how to build an Azure SQLDB with Terraform using VS Code](https://blog.robsewell.com/building-azure-sql-db-with-terraform-with-visual-studio-code/)

[The second post showed how to use Azure DevOps Task Groups to use the same build steps in multiple pipelines and build an Azure Linux SQL Server VM](https://blog.robsewell.com/using-the-same-azure-devops-build-steps-for-terraform-with-different-pipelines-with-task-groups/)

Happy Automating!
