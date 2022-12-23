---
title: "Dynamically Creating Azure Data Studio Notebooks with PowerShell for an Incident Response Index Notebook"
date: "2019-11-21" 
categories:
  - Blog
  - Jupyter Notebooks
  - Azure Data Studio
  - PowerShell

tags:
  - PowerShell
  - Jupyter Notebooks
  - automation
  - automate
  - Incident Response
  - Azure Data Studio
  - Notebooks
  - Azure Dev Ops

header:
  teaser: /assets/uploads/2019/11/image-39.png
---
Now that [Azure Data Studio](https://aka.ms/azuredatastudio) has [PowerShell Notebooks](https://docs.microsoft.com/en-us/sql/azure-data-studio/release-notes-azure-data-studio?view=sql-server-ver15?WT.mc_id=DP-MVP-5002693) and there is a [PowerShell Module for creating notebooks](https://blog.robsewell.com/create-a-powershell-notebook-for-azure-data-studio-with-powershell/). I have been asked, more than once, what is the point? What is the use case? How does this help. I hope that this post will spark some ideas of one particular use-case.

I showed my silly example PowerShell code to create a PowerShell Notebook that created a PowerShell Notebook to my good friend Nick.<FIGURE class="wp-block-video wp-block-embed is-type-video is-provider-videopress">
<DIV class=wp-block-embed__wrapper><IFRAME title=2019-11-14_15-50-46-mp4 height=502 src="https://videopress.com/embed/5zyfyR2P?preloadContent=metadata&amp;hd=0" frameBorder=0 width=630 allowfullscreen></IFRAME>
<SCRIPT src="https://v0.wordpress.com/js/next/videopress-iframe.js?m=1435166243"></SCRIPT>
</DIV></FIGURE>
Nick is a fantastic, clever DBA who isn’t active on social media, which is a great shame as if he had time to share some of his fantastic work we would all benefit. He looked at that code and less than an hour later, came back to me with this code and idea which I have replicated here with his permission.

Thanks Nick.

The Use Case
------------

The use case that Nick has is that he is converting some troubleshooting runbooks from their original locations (you know the sort of places – Sharepoint Docs, OneNote Notebooks, Shared Folders, the desktop of the Bastion Host) into a single repository of Azure Data Studio SQL or PowerShell Notebooks.

The idea is to have a single entry point into the troubleshooting steps and for the on-call DBA to create a Notebook from a template for the issue at hand which could be attached to an incident in the incident management solution. I suppose you could call it an Index Notebook.

Work Flow
---------

When the DBA (or another team) opens this Notebook, they can choose the task that they are going to perform and click the link which will

*   copy the Notebook to the local machine
*   Rename the Notebook with the username and date
*   Open it ready for the work.

Once the work has been completed, the DBA can then attach the Notebook to the task or incident that has been created or use it in the Wash-Up/ Post Incident meeting.

This ensures that the original template notebook stays intact and unchanged and it is easy (which is always good when you are called out at 3am!) to create a uniquely named notebook .

Azure DevOps
------------

Nick has placed this code into the deploy step in Azure DevOps which will deploy the template Notebooks from source control into the common folder and then this code will dynamically create the index Notebook each time there is a release.

Whilst the initial use case is incident response, this could easily be adapted for Notebooks used for Common Tasks or Run Books.

Notebooks
---------

There are a number of Notebooks for different issue stored in directories. For this post, I have used the Notebooks from Microsoft that explain SQL 2019 features and troubleshooting which you can find in their GitHub repositories by [following this link](https://github.com/microsoft/sql-server-samples/tree/master/samples/features/sql2019notebooks)

The Azure DevOps deploys the Notebooks to a directory which then looks something like this

![](https://blog.robsewell.com/assets/uploads/2019/11/image-38.png?resize=494%2C195&ssl=1)

Some directories of Notebooks in a directory

Create an Index Notebook
------------------------

Here is the code to create an index Notebook
<SCRIPT src="https://gist.github.com/SQLDBAWithABeard/e2c0a410d5ec749bcda6fd2da9f83703.js"></SCRIPT>

This creates a Notebook in the root of the folder. It also uses the new `-Collapse` parameter in `New-AdsNoteBookCell` that creates the code blocks with the code collapsed so that it looks neater. The index Notebook looks like this in the root of the folder

[![](https://blog.robsewell.com/assets/uploads/2019/11/image-39.png?resize=630%2C680&ssl=1)](https://blog.robsewell.com/assets/uploads/2019/11/image-39.png?ssl=1)

Three O’Clock in the Morning
----------------------------

It’s 3am and I have been called out. I can open up the Index Notebook, find the set of queries I want to run and click the run button.

A new workbook opens up, named with my name and the time and I can get to work 🙂 I think it’s neat.
<P>Here’s a video</P><FIGURE class="wp-block-video wp-block-embed is-type-video is-provider-videopress">
<DIV class=wp-block-embed__wrapper><IFRAME title=using-an-index-notebook-mp4 height=332 src="https://videopress.com/embed/bxs91KsT?preloadContent=metadata&amp;hd=0" frameBorder=0 width=630 allowfullscreen></IFRAME>
<SCRIPT src="https://v0.wordpress.com/js/next/videopress-iframe.js?m=1435166243"></SCRIPT>
</DIV></FIGURE>
Thanks Nick.

Maybe you can find him at SQL Bits next year. Did you know that SQL Bits 2020 was announced?  
  
Check out [https://sqlbits.com](https://sqlbits.com) for more details

