---
title: "What does JS_InvalidFilePath error mean in Azure DevOps? "
date: "2021-11-04" 
categories:
  - Blog
  - Azure DevOps
  - IaC

tags:
 - Blog
 - Azure DevOps
 - Error
 - pipeline



image: assets/uploads/2021/Bicep/xavier-von-erlach-ooR1jY2yFr4-unsplash.jpg
---

# Can\'t find loc string for key: JS_InvalidFilePath

This was the error I received in my Azure DevOps pipeline when I tried to run it.

When I investigated further it said

````
##[debug]workingDirectory=/home/vsts/work/1/s
##[debug]check path : /home/vsts/work/1/s
##[warning]Can\'t find loc string for key: JS_InvalidFilePath
##[debug]Processed: ##vso[task.issue type=warning;]Can\'t find loc string for key: JS_InvalidFilePath
##[debug]task result: Failed
##[error]JS_InvalidFilePath /home/vsts/work/1/s
##[debug]Processed: ##vso[task.issue type=error;]JS_InvalidFilePath /home/vsts/work/1/s
##[debug]Processed: ##vso[task.complete result=Failed;]JS_InvalidFilePath /home/vsts/work/1/s
````

# What is going on?

I was trying to run a simple Azure PowerShell task and had defined it like this (I used VS Code with the Azure Pipelines extension and made use of the intellisense). I had defined it like this.

````
        - task: AzurePowerShell@5
          name: deploy
          displayName: Deploy from cache
          inputs:
            azureSubscription: 'azurePAYGconnection'
            Inline: |
              $date = Get-Date -Format yyyyMMddHHmmsss
              $deploymentname = 'deploy_testRg_{0}' -f $date # name of the deployment seen in the activity log
              $TemplateFile = 'BicepFiles\Deployments\TheTestResourceGroup.bicep'
              New-AzDeployment -Name $deploymentname -Location uksouth -TemplateFile $TemplateFile -Verbose # -WhatIf
            azurePowerShellVersion: 'LatestVersion'
          env:
            SYSTEM_ACCESSTOKEN: $(system.accesstoken)
            pwsh: true
          enabled: true
````

which gave me no errors, the YAML is correct (yes, I was suprised too!). The Azure Pipeline definition does not raise an error either in VS Code or in Azure DevOps.

# What was missing?

I had not put `ScriptType: 'InlineScript'` and this is what caused that odd error.

The correct definition was

````
        - task: AzurePowerShell@5
          name: deploy
          displayName: Deploy from cache
          inputs:
            azureSubscription: 'azurePAYGconnection'
            ScriptType: 'InlineScript'
            Inline: |
              $date = Get-Date -Format yyyyMMddHHmmsss
              $deploymentname = 'deploy_testRg_{0}' -f $date # name of the deployment seen in the activity log
              $TemplateFile = 'BicepFiles\Deployments\TheTestResourceGroup.bicep'
              New-AzDeployment -Name $deploymentname -Location uksouth -TemplateFile $TemplateFile -Verbose # -WhatIf
            azurePowerShellVersion: 'LatestVersion'
          env:
            SYSTEM_ACCESSTOKEN: $(system.accesstoken)
            pwsh: true
          enabled: true
````

Hopefully that might help someone. (No doubt I will find this in a search in a few months time when I do it again!!)

Happy automating
