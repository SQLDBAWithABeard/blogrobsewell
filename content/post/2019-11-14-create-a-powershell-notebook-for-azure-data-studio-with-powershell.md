---
title: "Create a PowerShell Notebook for Azure Data Studio with PowerShell"
date: "2019-11-14" 
categories:
  - Blog
  - Jupyter Notebooks
  - Azure Data Studio
  - PowerShell
  - dbatools

tags:
  - adsnotebook
  - dbatools
  - Jupyter Notebooks
  - Azure Data Studio
  - PowerShell

---
The latest update to the ADSNotebook PowerShell module [I blogged about here](https://blog.robsewell.com/create-azure-data-studio-sql-notebooks-with-powershell/) now enables the creation of PowerShell notebooks with PowerShell.

You can install the module with

    Install-Module ADSNotebook

or if you have already installed it you can use

    Update-Module ADSNotebook

In the latest release, there is an extra parameter for `New-AdsWorkBook` of `-Type` which will accept either SQL or PowerShell

Create a PowerShell Notebook with PowerShell Rob
------------------------------------------------

OK!

Here is some code to create a PowerShell Notebook. First we will create some cells using `New-AdsWorkBookCell` including all the markdown to add images and links. You can find my notebooks which explain how to write the markdown for your notebooks in my [GitHub Presentations Repository](https://github.com/SQLDBAWithABeard/Presentations/tree/master/2019/PASS%20Summit/SQL%20Notebooks%20in%20Azure%20Data%20Studio%20for%20the%20DBA)

<PRE class=wp-block-code><CODE>$introCelltext = "# Welcome to my Auto Generated PowerShell Notebook

## dbatools
![image](https://user-images.githubusercontent.com/6729780/68845538-7afcd200-06c3-11ea-952e-e4fe72a68fc8.png)  

dbatools is an open-source PowerShell Module for administering SQL Servers.
You can read more about dbatools and find the documentation at [dbatools.io](dbatools.io)
"
$SecondCelltext = "### Installation
You can install dbatools from the PowerShell Gallery using `Install-Module dbatools`
"

$thirdcelltext = "Install-Module dbatools"

$fourthCelltext = "### Getting Help
You should always use `Get-Help` to fins out how to use dbatools (and any PowerShell) commands"

$fifthcelltext = "Get-Help Get-DbaDatabase"
$sixthCelltext = "Try a command now. get the name, owner and collation of the user databases on the local instance"
$seventhCellText = "Get-DbaDatabase -SqlInstance localhost -ExcludeSystem | Select Name, Owner, Collation"

$Intro = New-ADSWorkBookCell -Type Text -Text $introCelltext
$second = New-ADSWorkBookCell -Type Text -Text $SecondCelltext
$third = New-ADSWorkBookCell -Type Code -Text $thirdcelltext
$fourth = New-ADSWorkBookCell -Type Text -Text $fourthCelltext
$fifth = New-ADSWorkBookCell -Type Code -Text $fifthcelltext
$sixth = New-ADSWorkBookCell -Type Text -Text $sixthCelltext
$seventh = New-ADSWorkBookCell -Type Code -Text $seventhCellText</CODE></PRE>
Then we will create a new workbook using those cells

<PRE class=wp-block-code><CODE>$path = 'C:\temp\dbatools.ipynb'
New-ADSWorkBook -Path $path -cells $Intro,$second,$third,$fourth,$fifth,$sixth,$Seventh -Type PowerShell</CODE></PRE>
Then, when that code is run we can open the Notebook and ta-da

[![](https://blog.robsewell.com/assets/uploads/2019/11/image-33.png?fit=630%2C505&ssl=1)](https://blog.robsewell.com/assets/uploads/2019/11/image-33.png?ssl=1)

And it is super quick to run as well

UPDATE – Tyler Leonhardt [t](https://twitter.com/TylerLeonhardt) from the PowerShell team asked

![](https://blog.robsewell.com/assets/uploads/2019/11/image-36.png?resize=597%2C284&ssl=1)

Challenge accepted, with extra meta, here is the PowerShell to create a PowerShell Notebook which will create a PowerShell Notebook!!
<SCRIPT src="https://gist.github.com/SQLDBAWithABeard/bb0ecef8245f764151e018d09d38f9c5.js"></SCRIPT>
<FIGURE class="wp-block-video wp-block-embed is-type-video is-provider-videopress">
<DIV class=wp-block-embed__wrapper><IFRAME title=2019-11-14_15-50-46-mp4 height=474 src="https://videopress.com/embed/5zyfyR2P?preloadContent=metadata&amp;hd=0" frameBorder=0 width=630 allowfullscreen></IFRAME>
<SCRIPT src="https://v0.wordpress.com/js/next/videopress-iframe.js?m=1435166243"></SCRIPT>
</DIV></FIGURE>

