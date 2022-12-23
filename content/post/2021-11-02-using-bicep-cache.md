---
title: "Deploying a Bicep Module from a private repository without a connection to the repository"
date: "2021-11-02" 
categories:
  - Blog
  - Bicep
  - IaC

tags:
 - Blog
 - Bicep
 - Azure
 - Bicep Module Repository
 - Cache



image: assets/uploads/2021/Bicep/xavier-von-erlach-ooR1jY2yFr4-unsplash.jpg
---

# Using a private module repository

From Bicep version 0.4.1008 you can save and version your Bicep modules in repositories. [You can read more about how to do it here](https://msftplayground.com/2021/11/using-private-repositories-for-bicep-modules/). This is really useful for reusing modules and modularising large corporate infrastructure environments.
  
You can control how a single resource (think of a storage account) is deployed across your environment and ensure that all requirements are followed (the storage account must have public access disabled, must have private endpoints and must have the one production network allowed). This is really useful and since it has been available we have used this to deploy infrastructure.

# So whats the problem ?

When you need to use a module from the repository, you refer to the repository when you define the module path.
  
`module storage 'br:bearddemoacr.azurecr.io/bicep/storage/storagev2:0.0.2' = {`  
  
This says I want to deploy something we will call `storage` and you can find the definition called `bicep/storage/storagev2` in a Bicep Repository (`br`) at `bearddemoacr.azurecr.io` and we will use the tag `0.0.2`. The rest of the properties will then be written.

On the client that you use to do the deployment, Bicep will `restore` the required information from the Bicep Repository and use that to perform the deployments. By default, it uses the path `~/.bicep` on Linux/Mac and `$HOME\.bicep` on Windows.

If you take a look in that directory, you will see the files that have been restored for use.

![cachecontents]({{ "/assets/uploads/2021/Bicep/cachecontents.png" | relative_url }})

But this relies on the client that is performing the deployment having connectivity and being able to authenticate to the Azure Container Registry (ACR) that is holding the Bicep Modules.

# Why would the client not have access?

There are a number of situations where the deployment client (a workstation, a devops pipeline agent) may not have access to the ACR. The development and testing of the Bicep Modules may take place in a development Azure subscription which has no connectivity to the production Azure subscription. The production environment may be in Azure Government Cloud or it may be in a customers Azure subscription and opening a connection to an ACR in another subscription in another network may be prohibitively complicated and time consuming due to the process required to gain approvals and perform the actions to open the required paths or (more likely) is simply not allowed.

# BICEP_CACHE_DIRECTORY environment variable to the rescue

There is an environment variable called BICEP_CACHE_DIRECTORY that defines the path that is used to hold the restored bicep artifacts. This means that we can do two things to enable us to continue to use a Bicep Repository with all of the benefits but still be able to deploy the infrastructure.

# Cache the files

Firstly, as part of the build process we can set the `BICEP_CACHE_DIRECTORY` path and perform a `bicep restore` on the Bicep Resource file. This will restore all of the referenced modules to the path. We can then package this directory with our deployment bicep file and transfer them to the deployment environment.

# Deploy the Bicep

Then when we extract the package we can set the `BICEP_CACHE_DIRECTORY` to the directory holding the cached files and deploy our bicep as we would normally. Even though the files reference the Bicep Repository by name, the deployment will use the cache. I even tested it by deleting the images from the Bicep Repository completely (after I had run `bicep restore` of course) and I was able to deploy from the cache without issue.

Hopefully, this wil help someone somewhere as the `BICEP_CACHE_DIRECTORY` variable is not wildly known or documented.

Happy automating



