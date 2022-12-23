---
title: "Invalid Template Deployment with my Bicep"
date: "2021-05-21" 
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
 - Error


header:
  teaser: /assets/uploads/2021/Bicep/xavier-von-erlach-ooR1jY2yFr4-unsplash.jpg
---

# An Error

Did I tear my bicep? No but I got an error. Whilst trying to deploy a network with Bicep using Azure DevOps I received the error

> Error: Code=InvalidTemplateDeployment; Message=The template deployment 'deploy_bicep003_20210505094331' is not valid according to the validation procedure. The tracking id is '4bdec1fe-915d-4735-a1c1-7b56fbba0dc2'. See inner errors for details.

Unfortunately that was all that I had. I had to find the inner error for details

# Try the deployment log on the Resource Group

As I know that the Bicep deployments are logged in Azure under the Resource Groups deployment I looked there first but there were no entries (obviously Rob, there had been no deployment)

So I navigated to the home page of the Azure Portal and searched for Activity log.

[![activitylog](https://blog.robsewell.com/assets/uploads/2021/Bicep/activitylog.png)](https://blog.robsewell.com/assets/uploads/2021/Bicep/activitylog.png)

I searched for the name of the deployment `deploy_bicep003_20210505094331` and saw  

[![activitylogsearch](https://blog.robsewell.com/assets/uploads/2021/Bicep/activitylogsearch.png)](https://blog.robsewell.com/assets/uploads/2021/Bicep/activitylogsearch.png)

clicking on the link showed me this with the relevant information hidden in the JSON

[![activitylogdetails](https://blog.robsewell.com/assets/uploads/2021/Bicep/activitylogdetails.png)](https://blog.robsewell.com/assets/uploads/2021/Bicep/activitylogdetails.png)

> Resource name {'name':'subnet1','addressPrefix':'10.0.0.0/24'}.name is invalid.

Bingo.

I had made a mistake in my resource definition for the subnets. I had used

````
subnets:  [for item in subnets:{
  name: '${item}.name'
  properties: {
    addressPrefix: '${item}.addressPrefix'
  }
}]
````

where I should have used

````
subnets:  [for item in subnets:{
  name: '${item.name}'
  properties: {
    addressPrefix: '${item.addressPrefix}'
  }
}]
````

Every day is a learning day.
