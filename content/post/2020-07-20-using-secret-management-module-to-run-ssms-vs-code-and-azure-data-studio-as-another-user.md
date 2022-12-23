---
title: "Using Secret Management module to run SSMS, VS Code and Azure Data Studio as another user"
date: "2020-07-20" 
categories:
  - Blog
  - Jupyter Notebooks
  - Azure Data Studio
  - PowerShell
  - dbatools

tags:
  - adsnotebook
  - dbatools
  - PowerShell
  - ssms
  - Secret Management
  - Import-CliXml
  - Jupyter Notebooks
  - Microsoft
  - Azure Data Studio
  - VS Code



image: /assets/uploads/2020/07/runas.png

---
Following on from [my last post about the Secret Management module](https://blog.robsewell.com/blog/jupyter%20notebooks/azure%20data%20studio/powershell/dbatools/good-bye-import-clixml-use-the-secrets-management-module-for-your-labs-and-demos/). I was asked another question.  

> Can I use this to run applications as my admin account?
> 
> A user with a beard

It is good practice to not log into your work station with an account with admin privileges. In many shops, you will need to open applications that can do administration tasks with another set of account credentials.

Unfortunately, people being people, they will often store their admin account credentials in a less than ideal manner (OneNote, Notepad ++ etc) to make it easier for them, so that when they right click and run as a different user, they can copy and paste the password.

Use the Secret Management module
--------------------------------

Again, I decided to use a notebook to show this as it is a fantastic way to share code and results and because it means that anyone can try it out.

The notebook may not render on a mobile device.

<script src="https://gist.github.com/SQLDBAWithABeard/24806c29603aded310198dab5430b37a.js?file-secret_management_opening_programmes_with_other_credentials-ipynb"></script>

Using the notebook, I can quickly store my admin password safely and open and run the applications using the credential

![](https://blog.robsewell.com/assets/uploads/2020/07/runas.png)
