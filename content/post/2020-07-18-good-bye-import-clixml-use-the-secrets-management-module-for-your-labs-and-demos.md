---
title: "Good Bye Import-CliXML – Use the Secrets Management module for your labs and demos"
categories:
  - Blog
  - Jupyter Notebooks
  - Azure Data Studio
  - PowerShell
  - dbatools

tags:
  - adsnotebook
  - dbatools
  - docker
  - jaap
  - psconfeu
  - Secret Management
  - Import-CliXml
  - Jupyter Notebooks
  - Jaap Brasser
  - Joel Bennett
  - Microsoft
  - PowerShell

header:
  teaser: /assets/uploads/2020/07/image-1.png
---
Don’t want to read all this? There are two dotnet interactive notebooks here with the relevant information for you to use.  
  
[https://beard.media/dotnetnotebooks](https://beard.media/dotnetnotebooks)

Jaap is awesome
---------------

![](https://pbs.twimg.com/media/DBbP9lHXYAAopb3?format=jpg&name=4096x4096)

I have to start here. For the longest time, whenever anyone has asked me how I store my credentials for use in my demos and labs I have always referred them to Jaap Brassers [t](https://twitter.com/Jaap_Brasser) blog post

[https://www.jaapbrasser.com/quickly-and-securely-storing-your-credentials-powershell/](https://www.jaapbrasser.com/quickly-and-securely-storing-your-credentials-powershell/)

Joel is also awesome!
---------------------

When people wanted a method of storing credentials that didn't involve files on disk I would suggest Joel Bennett’s [t](https://twitter.com/jaykul) module BetterCredentials which uses the Windows Credential Manager  
  
[https://www.powershellgallery.com/packages/BetterCredentials/4.5](https://www.powershellgallery.com/packages/BetterCredentials/4.5)

Microsoft? Also awesome!
------------------------

In February, Microsoft released the SecretManagement module for preview.

[https://devblogs.microsoft.com/powershell/secrets-management-development-release/](https://devblogs.microsoft.com/powershell/secrets-management-development-release?WT.mc_id=DP-MVP-5002693)

Sydney [t](https://twitter.com/sydneysmithreal) gave a presentation at the European PowerShell Conference which you can watch on Youtube.

Good Bye Import-CliXML
----------------------

So now I say, it is time to stop using Import-Clixml for storing secrets and use the Microsoft.PowerShell.SecretsManagement module instead for storing your secrets.

Notebooks are as good as blog posts
-----------------------------------

I love notebooks and to show some people who had asked about storing secrets, I have created some. So, because I am efficient lazy I have embedded them here for you to see. You can find them in my Jupyter Notebook repository  
  
[https://beard.media/dotnetnotebooks](https://beard.media/dotnetnotebooks)  
  
in the Secrets folder

![](https://blog.robsewell.com/assets/uploads/2020/07/image-1.png?resize=630%2C349&ssl=1)

Installing and using the Secrets Management Module
--------------------------------------------------

These notebooks may not display on a mobile device unfortunately
<SCRIPT src="https://gist.github.com/SQLDBAWithABeard/43921494f40dc1461d59445eb44a73ff.js"></SCRIPT>

Using the Secret Management Module in your scripts
--------------------------------------------------

Here is a simple example of using the module to provide the credential for a docker container and then to dbatools to query the container

These notebooks may not display on a mobile device unfortunately
<SCRIPT src="https://gist.github.com/SQLDBAWithABeard/68d34d9ccd58bb6a0da1a7287ffe38a1.js"></SCRIPT>


