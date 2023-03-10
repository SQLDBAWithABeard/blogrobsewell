---
title: "Create Azure Data Studio SQL Notebooks with PowerShell"
date: "2019-11-07" 
categories:
  - Blog
  - Jupyter Notebooks
  - Azure Data Studio
  - PowerShell

tags:
  - adsnotebook
  - PowerShell
  - Jupyter Notebooks
  - Azure Data Studio
  - 

---
At PASS Summit today I gave a presentation about SQL Notebooks in Azure Data Studio for the DBA. I demo’d the [PowerShell module ADSNotebook](https://www.powershellgallery.com/packages/ADSNotebook).

![](https://blog.robsewell.com/assets/uploads/2019/11/image-32.png)

[which you can also find on GitHub](https://github.com/sqlcollaborative/ADSNotebook) (where I will be glad to take PR’s to improve it 🙂 )

This module has 3 functions

This module contains only 3 commands at present

*   Convert-ADSPowerShellForMarkdown

This will create the markdown link for embedding PowerShell code in a Text Cell for a SQL Notebook as described [in this blog post](https://blog.robsewell.com/powershell-in-sql-notebooks-in-azure-data-studio/)

*   New-ADSWorkBookCell

This command will create a workbook text cell or a code cell for adding to the New-ADSWorkBook command

*   New-ADSWorkBook

This will create a new SQL Notebook using the cell objects created by New-ADSWorkBookCell

Usage
-----

Convert-ADSPowerShellForMarkdown

    Convert-ADSPowerShellForMarkdown -InputText "Get-ChildItem" -LinkText 'This will list the files' -ToClipBoard
    
    Converts the PowerShell so that it works with MarkDown and sets it to the clipboard for pasting into a workbook cell

New-ADSWorkBookCell

    $introCelltext = "# Welcome to my Auto Generated Notebook
    
    ## Automation
    Using this we can automate the creation of notebooks for our use
    "
    $Intro = New-ADSWorkBookCell -Type Text -Text $introCelltext
    
    Creates an Azure Data Studio Text cell and sets it to a variable for passing to  New-AdsWorkBook

New-ADSWorkBook

    $introCelltext = "# Welcome to my Auto     Generated Notebook
    
    ## Automation
    Using this we can automate the creation of notebooks for our use
    "
    $SecondCelltext = "## Running code
    The next cell will have some code in it for running
    
    ## Server Principals
    Below is the code to run against your     instance to find the server principals that are enabled"
    
    $thirdcelltext = "SELECT Name
    FROM sys.server_principals
    WHERE is_disabled = 0"
    $Intro = New-ADSWorkBookCell -Type Text -Text $introCelltext
    $second = New-ADSWorkBookCell -Type Text  -Text $SecondCelltext
    $third = New-ADSWorkBookCell -Type Code -Text $thirdcelltext
    
    $path = 'C:\temp\AutoGenerated.ipynb'
    New-ADSWorkBook -Path $path -cells $Intro,$second,$third
    
    Creates 3 cells with New-AdsWorkBookCells to add to the workbook,
    two text ones and a code one, then creates a SQL Notebook with
    those cells and saves it as     C:\temp\AutoGenerated.ipynb

Installation
============

You can install this Module from the PowerShell Gallery using

`Install-Module ADSNotebook`

Compatability
=============

This module has been tested on Windows PowerShell 5.1, PowerShell Core 6 and PowerShell 7 on Windows 10 and Ubuntu

Demo
----

<iframe width="650" height="250" src="https://blog.robsewell.com/wp-content/uploads/2019/11/New-ADSNoteBook.mp4" frameborder="0" allowfullscreen></iframe> 
