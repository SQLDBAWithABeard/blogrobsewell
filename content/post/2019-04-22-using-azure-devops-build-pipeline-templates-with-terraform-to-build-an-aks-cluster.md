---
title: "Using Azure DevOps Build Pipeline Templates with Terraform to build an AKS cluster"
date: "2019-04-22" 
categories:
  - azure
  - Blog

tags:
  - aks
  - automation
  - azure
  - kubernetes
  - terraform
  - pipeline
  - templates
  - AKS
  - Azure DevOps

header:
  teaser: /assets/uploads/2019/04/image-151.png

---
In the last few posts I have moved from [building an Azure SQL DB with Terraform using VS Code](https://blog.robsewell.com/building-azure-sql-db-with-terraform-with-visual-studio-code/) to [automating the build process for the Azure SQL DB using Azure DevOps Build Pipelines](https://blog.robsewell.com/building-azure-sql-db-with-terraform-using-azure-devops/) to [using Task Groups in Azure DevOps to reuse the same Build Process and build an Azure Linux SQL VM and Network Security Group](https://blog.robsewell.com/using-the-same-azure-devops-build-steps-for-terraform-with-different-pipelines-with-task-groups/). This evolution is fantastic but Task Groups can only be used in the same Azure DevOps repository. It would be brilliant if I could use Configuration as Code for the Azure Build Pipeline and store that in a separate source control repository which can be used from any Azure DevOps Project.

Luckily, you can 😉 You can use [Azure DevOps Job Templates](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/templates?view=azure-devops?WT.mc_id=DP-MVP-5002693) to achieve this. There is a limitation at present, you can only use them for Build Pipelines and not Release Pipelines.

The aim of this little blog series was to have a single Build Pipeline stored as code which I can use to build any infrastructure that I want with Terraform in Azure and be able to use it anywhere

Creating a Build Pipeline Template
----------------------------------

I created a [GitHub repository](https://github.com/SQLDBAWithABeard/Presentations-BuildTemplates) to hold my Build Templates, feel free to use them as a base for your own but please don’t try and use the repo for your own builds.

The easiest way to create a Build Template is to already have a Build Pipeline. This cannot be done from a Task Group but I still have the Build Pipeline from my [automating the build process for the Azure SQL DB using Azure DevOps Build Pipelines](https://blog.robsewell.com/building-azure-sql-db-with-terraform-using-azure-devops/) blog post.

![](https://blog.robsewell.com/assets/uploads/2019/04/image-132.png)

There is a View YAML button. I can click this to view the YAML definition of the Build Pipeline

![](https://blog.robsewell.com/assets/uploads/2019/04/image-133.png)

I copy that and paste it into a new file in my BuildTemplates repository. (I have replaced my Azure Subscription information in the public repository)

     jobs:
    - job: Build
      pool:
        name: Hosted VS2017
        demands: azureps
      steps:
      - task: AzureCLI@1
        displayName: 'Azure CLI to deploy azure storage for backend'
        inputs:
          azureSubscription: 'PUTYOURAZURESUBNAMEHERE'
          scriptLocation: inlineScript
          inlineScript: |
            # the following script will create Azure resource group, Storage account and a Storage container which will be used to store terraform state
            call az group create --location $(location) --name $(TerraformStorageRG)
            
            call az storage account create --name $(TerraformStorageAccount) --resource-group $(TerraformStorageRG) --location $(location) --sku Standard_LRS
            
            call az storage container create --name terraform --account-name $(TerraformStorageAccount)
    
      - task: AzurePowerShell@3
        displayName: 'Azure PowerShell script to get the storage key'
        inputs:
          azureSubscription: 'PUTYOURAZURESUBNAMEHERE'
          ScriptType: InlineScript
          Inline: |
            # Using this script we will fetch storage key which is required in terraform file to authenticate backend stoarge account
          
            $key=(Get-AzureRmStorageAccountKey -ResourceGroupName $(TerraformStorageRG) -AccountName $(TerraformStorageAccount)).Value[0]
          
            Write-Host "##vso[task.setvariable variable=TerraformStorageKey]$key"
          azurePowerShellVersion: LatestVersion
    
      - task: qetza.replacetokens.replacetokens-task.replacetokens@3
        displayName: 'Replace tokens in terraform file'
        inputs:
          rootDirectory: Build
          targetFiles: |
            **/*.tf
            **/*.tfvars
          tokenPrefix: '__'
          tokenSuffix: '__'
    
      - powershell: |
          Get-ChildItem .\Build -Recurse
        
          Get-Content .\Build\*.tf 
          Get-Content .\Build\*.tfvars 
        
          Get-ChildItem Env: | select Name
        displayName: 'Check values in files'
        enabled: false
    
      - task: petergroenewegen.PeterGroenewegen-Xpirit-Vsts-Release-Terraform.Xpirit-Vsts-Release-Terraform.Terraform@2
        displayName: 'Initialise Terraform'
        inputs:
          TemplatePath: Build
          Arguments: 'init -backend-config="0-backend-config.tfvars"'
          InstallTerraform: true
          UseAzureSub: true
          ConnectedServiceNameARM: 'PUTYOURAZURESUBNAMEHERE'
    
      - task: petergroenewegen.PeterGroenewegen-Xpirit-Vsts-Release-Terraform.Xpirit-Vsts-Release-Terraform.Terraform@2
        displayName: 'Plan Terraform execution'
        inputs:
          TemplatePath: Build
          Arguments: plan
          InstallTerraform: true
          UseAzureSub: true
          ConnectedServiceNameARM: 'PUTYOURAZURESUBNAMEHERE'
    
      - task: petergroenewegen.PeterGroenewegen-Xpirit-Vsts-Release-Terraform.Xpirit-Vsts-Release-Terraform.Terraform@2
        displayName: 'Apply Terraform'
        inputs:
          TemplatePath: Build
          Arguments: 'apply -auto-approve'
          InstallTerraform: true
          UseAzureSub: true
          ConnectedServiceNameARM: 'PUTYOURAZURESUBNAMEHERE'



Now I can use this yaml as configuration as code for my Build Pipeline 🙂 It can be used from any Azure DevOps project. Once you start looking at the code and the [documentation for the yaml](https://docs.microsoft.com/en-gb/azure/devops/pipelines/yaml-schema?view=azure-devops&tabs=schema?WT.mc_id=DP-MVP-5002693) schema you can begin to write your pipelines as YAML, but sometimes it is easier to just create build pipeline or even just a job step in the browser and click the view yaml button!

Create an AKS Cluster with a SQL 2019 container using Terraform and Build templates
-----------------------------------------------------------------------------------

I have a [GitHub Repository with the Terraform code to build a simple AKS cluster](https://github.com/SQLDBAWithABeard/Presentations-AKS). This could not have been achieved without [Richard Cheney’s article](https://azurecitadel.com/automation/terraform/lab8/) I am not going to explain how it all works for this blog post or some of the negatives of doing it this way. Instead lets build an Azure DevOps Build Pipeline to build it with Terraform using Configuration as Code (the yaml file)

![](https://blog.robsewell.com/assets/uploads/2019/04/image-134.png)

I am going to create a new Azure DevOps Build Pipeline and as in the previous posts connect it to the [GitHub Repository holding the Terraform code](https://github.com/SQLDBAWithABeard/Presentations-AKS).

This time I am going to choose the Configuration as code template

![](https://blog.robsewell.com/assets/uploads/2019/04/image-135.png)

I am going to give it a name and it will show me that it needs the path to the yaml file containing the build definition in the current repository.

![](https://blog.robsewell.com/assets/uploads/2019/04/image-136.png)

Clicking the 3 ellipses will pop-up a file chooser and I pick the build.yaml file

![](https://blog.robsewell.com/assets/uploads/2019/04/image-137.png)

The build.yaml file looks like this. The name is the USER/Repository Name and the endpoint is the name of the endpoint for the GitHub service connection in Azure DevOps. The template value is the name of the build yaml file @ the name given for the repository value.

     resources:
      repositories:
        - repository: templates
          type: GitHub 
          name: SQLDBAWithABeard/Presentations-BuildTemplates-Private
          endpoint: SQLDBAWithABeardGitHub
    
    jobs:
    - template: AzureTerraform.yaml@templates  # Template reference

You can find (and change) your GitHub service connection name by clicking on the cog bottom left in Azure DevOps and clicking service connections

![](https://blog.robsewell.com/assets/uploads/2019/04/image-140.png)

I still need to create my variables for my Terraform template (perhaps I can now just leave those in my code?) For the AKS Cluster build right now I have to add presentation, location, ResourceGroupName, AgentPoolName, ServiceName, VMSize, agent_count

![](https://blog.robsewell.com/assets/uploads/2019/04/image-139.png)

Then I click save and queue and the job starts running

![](https://blog.robsewell.com/assets/uploads/2019/04/image-141.png)

If I want to edit the pipeline it looks a little different

![](https://blog.robsewell.com/assets/uploads/2019/04/image-152.png)

The variables and triggers can be found under the 3 ellipses on the top right

![](https://blog.robsewell.com/assets/uploads/2019/04/image-153.png)

It also defaults the trigger to automatic deployment.

It takes a bit longer to build

![](https://blog.robsewell.com/assets/uploads/2019/04/image-142.png)

and when I get the Terraform code wrong and the build fails, I can just alter the code, commit it, push and a new build will start and the Terraform will work out what is built and what needs to be built!

but eventually the job finishes successfully

![](https://blog.robsewell.com/assets/uploads/2019/04/image-143.png)

and the resources are built

![](https://blog.robsewell.com/assets/uploads/2019/04/image-144.png)

and in Visual Studio Code with the [Kubernetes extension](https://marketplace.visualstudio.com/items?itemName=ms-kubernetes-tools.vscode-kubernetes-tools) installed I can connect to the cluster by clicking the 3 ellipses and Add Existing Cluster

![](https://blog.robsewell.com/assets/uploads/2019/04/image-145.png)

I choose Azure Kubernetes Services and click next

![](https://blog.robsewell.com/assets/uploads/2019/04/image-146.png)

Choose my subscription and then add the cluster

![](https://blog.robsewell.com/assets/uploads/2019/04/image-147.png)

and then I can explore my cluster

![](https://blog.robsewell.com/assets/uploads/2019/04/image-148.png)

I can also see the dashboard by right clicking on the cluster name and Open Dashboard

![](https://blog.robsewell.com/assets/uploads/2019/04/image-150.png)

Right clicking on the service name and choosing describe

![](https://blog.robsewell.com/assets/uploads/2019/04/image-149.png)

shows the external IP address, which I can put into Azure Data Studio and connect to my container

![](https://blog.robsewell.com/assets/uploads/2019/04/image-151.png)

So I now I can source control my Build Job Steps and hold them in a central repository. I can make use of them in any project. This gives me much more control and saves me from repeating myself repeating myself. The disadvantage is that there is no handy warning when I change the underlying Build Repository that I will be affecting other Build Pipelines and there is no easy method to see which Build Pipelines are dependent on the build yaml file

Happy Automating
