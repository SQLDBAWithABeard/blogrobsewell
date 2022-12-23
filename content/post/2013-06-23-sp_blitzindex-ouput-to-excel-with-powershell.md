---
title: "sp_BlitzIndex™ ouput to Excel with Powershell"
categories:
  - Blog

tags:
  - automation
  - Excel
  - PowerShell

---
I am impressed with the output from [sp_BlitzIndex™](http://www.brentozar.com/blitzindex/) and today I tried to save it to an excel file so that I could pass it on to the developer of the service. When I opened it in Excel and imported it from the csv file it didn’t keep the T-SQL in one column due the commas which bothered me so I decided to use Powershell to output the format to Excel as follows

    #############################################################################################
    #
    # NAME: SPBlitzIndexToCSV.ps1
    # AUTHOR: Rob Sewell http://newsqldbawiththebeard.wordpress.com
    # DATE:22/06/2013
    #
    # COMMENTS: This script will take the output from spBlitzIndex™ and
    # export it to csv without splitting the tsql commands
    # ————————————————————————
    $Server = Read-Host "Please enter Server"
    $Database = Read-Host "Enter Database Name to run spBlitzIndex against"
    $filePath = "C:\temp\BlitzIndexResults"
    $Date = Get-Date -format ddMMYYYY
    $FileName = "Blitzindex_" + $Database + "_" + $Date + ".csv"$Query = "EXEC dbo.sp_BlitzIndex @database_name='$Database';"
    $Blitz = Invoke-SQLCMD -server $Server -database master -query $Query$Blitz|Export-Csv $FilePath
    $FileName

Please don’t ever trust anything you read on the internet and certainly don’t implement it on production servers without first both understanding what it will do and testing it thoroughly. This solution worked for me in my environment I hope it is of use to you in yours but I know nothing about your environment and you know little about mine

