---
title: "When you REALLY want to see your Azure DevOps Secret Variable Values"
date: "2021-08-10" 
categories:
  - Blog
  - Azure DevOps
  - IaC

tags:
 - Blog
 - Azure
 - Azure DevOps
 - Error
 - Secrets
 


image: https://blog.robsewell.com/assets/uploads/2021/michael-dziedzic-1bjsASjhfkE-unsplash.jpg
---

# I REALLY needed to see the values

The problem was that I had code in an Azure DevOps PowerShell task which was using a Service Principal to do some things in Azure and it was failing.  

The pipeline had some things a little like this, it got a number of values from a key vault, set them to variables and used them in a custom function  

````
$somevalue = (Get-AzKeyVaultSecret -vaultName $KeyVaultName -name 'AGeneratedName').SecretValue
$somecredential = New-Object System.Management.Automation.PSCredential ('dummy', $somevalue )
$something = $somecredential.GetNetworkCredential().Password

Do-SomethingSpecial -MyThing $something
````

I was getting an error saying "forbidden - *** does not have access" or similar  

Thing is, I knew that `$something` did have access as I could run the same code from my workstation and it did the logging in for `$something` so the error must be in the values that I was passing into the function. (there were more values than this but that is not important)  

All I needed to do was to see what values had been passed to the function and I could resolve this little issue. But these were secret variables. Helpfully kept out of the logs by Azure DevOps hence the *** so what to do?

I thought - I know what I will do, I will write the Parameter values from the function out as Verbose, call the function with `-Verbose` and then delete the run to clear up the logs.  

I added  

`Write-Verbose ($PSBoundParameters | Out-String)`  

to my function, called it with verbose in the pipeline and got

> Name       Value  
> - -         - -  
> MyThing       ***   

Awesome.

Write it to a file and read it back. This is a tactic that you can read about that works but it puts the secrets on disk on the agent and I did not want to do that.

I thought I would be even cleverer and this time I added to my function  

````
$WhatsMyThing = $MyThing + '-1'
Write-Verbose "My thing is $WhatsMyThing"
````  

Thats bound to work.  

My how I laughed when in the logs I had

> My Thing is  ***-1  

Right. I thought.

This IS IT.

I WILL SHOW YOU AZURE DEVOPS

I added to my function 

````
$WhatsMyThing =[Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($$MyThing ))
Write-Verbose "My thing is $WhatsMyThing"
````

This converted the value of MyThing into a base64 encoded value which I could see in the logs.

> My Thing is VGhlIEJlYXJkIGlzIExhdWdoaW5nIGF0IHlvdS4gWW91IHRoaW5rIEkgd291bGQgcHV0IHNvbWV0aGluZyByZWFsIGluIGhlcmU/IEdvb2QgdHJ5Lg==  

and then I could decode it on my workstation with

`[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('ValueFromLogs'))`

and learn that despite two people looking at the values we couldnt tell the difference between AGeneratedName and AnotherGeneratedName and they were the wrong way around!!!!  

But at least I know now a good way to get those secret values.  

If you do this, dont forget to delete the pipeline run from Azure DevOps so that the encoded value is not left in the logs for anyone to read.  


Every day is a learning day.
