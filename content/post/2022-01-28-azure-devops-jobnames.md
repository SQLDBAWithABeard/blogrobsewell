---
title: "Azure DevOps Pipeline Template Job Names and single quotes"
date: "2022-01-28" 
categories:
  - Blog
  - Azure DevOps
  - IaC

tags:
 - Blog
 - Azure DevOps
 - Error
 - pipeline


header:
  teaser: /assets/uploads/2021/Bicep/xavier-von-erlach-ooR1jY2yFr4-unsplash.jpg
---

# The job name Deploy_Function_App appears more than once

This was the error I was notified about in a Azure DevOps pipeline when they tried to run it. The error message continued to say that Job Names must be unique within a pipeline.

## Set Up

There is a centralised repository of Azure DevOps Pipeline Template Jobs that call the Bicep modules with the required values in the same repo to deploy Azure Infrastructure.  
  
The error was received in the pipeline that was created to make use of these template jobs and deploy a whole projects worth of infrastructure.  
  
It looked like this  
  
[![unique](https://blog.robsewell.com/assets/uploads/2022/01/uniquenames.png)](https://blog.robsewell.com/assets/uploads/2022/01/bemoreuniquenames.png)

When I looked at the template job it had

````
jobs:
  - job: Deploy_Function_App
    ${{ if eq(parameters['dependsOnLogAnalytics'], true) }}:
      dependsOn: 
      - Deploy_Resource_Group
      - Deploy_Log_Analytics

    ${{ if eq(parameters['dependsOnLogAnalytics'], false) }}:
      dependsOn: 
      - Deploy_Resource_Group
    pool:
      vmImage: windows-latest
````

## So you fixed it?

I can see that the job name will always be `Deploy_Function_App` so I just need to paramatarise it. For this example, I am going to say it was a parameter called suffix, and the code looked like this

````
jobs:
  - job: Deploy_Function_App${{ parameters.suffix }}'
    ${{ if eq(parameters['dependsOnLogAnalytics'], true) }}:
      dependsOn: 
      - Deploy_Resource_Group
      - Deploy_Log_Analytics

    ${{ if eq(parameters['dependsOnLogAnalytics'], false) }}:
      dependsOn: 
      - Deploy_Resource_Group
    pool:
      vmImage: windows-latest
````

A quick Pull Request, which was approved and then pushed and I said "Hey, all fixed, try again". This is the response I got - It failed again

[![unique](https://blog.robsewell.com/assets/uploads/2022/01/uniquenames.png)](https://blog.robsewell.com/assets/uploads/2022/01/bemoreuniquenames.png)  
  
Job Deploy_Function_App_speechtotext' has an invalid name. Valid names may only contain alphanumeric characters and '_' and may not start with a number.  

I had to look at it for a few minutes before I spotted the error! The job name sure looks like it only has alphanumeric characters and my YAML is perfectly valid so the string must be properly quoted. I mean it must be properly quoted otherwise it would fail right?
  
Wrong  
  
````
  - job: Deploy_Function_App${{ parameters.suffix }}'
````

There is only one single quote here which we did not notice!  

Altering it to this worked.
````
  - job: 'Deploy_Function_App${{ parameters.suffix }}'
````

Hopefully that might help someone. (No doubt I will find this in a search in a few months time when I do it again!!)

Happy automating
