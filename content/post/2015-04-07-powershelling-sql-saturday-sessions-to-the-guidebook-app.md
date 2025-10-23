---
title: "PowerShelling SQL Saturday Sessions to the Guidebook app"
date: "2015-04-07"

categories:
  - PowerShell
  - Community
  - Automation
tags:
  - automate
  - Excel
  - PowerShell
  - SQL Community
  - Community
  - SQL PASS
  - SQL Saturday Exeter
  - XML
---

Following on from my [previous pos](http://sqldbawithabeard.com/2015/03/21/parsing-xml-child-nodes-and-converting-to-datetime-with-PowerShell/ "Parsing XML Child Nodes and Converting to DateTime with PowerShell")t about parsing XML where I used the information from [Steve Jones blog post](https://voiceofthedba.wordpress.com/2015/01/26/downloading-sql-saturday-data/) to get information from the [SQL Saturday web site](https://www.sqlsaturday.com/) I thought that this information and script may be useful for others performing the same task.

1. Edit - This post was written prior to the updates to the SQL Saturday website over the weekend. When it can back up the script worked perfectly but the website is unavailable at the moment again so I will check and update as needed once it is back.

    We are looking at using [the Guidebook app](https://guidebook.com/) to provide an app for our attendees with all the session details for [SQL Saturday Exeter](https://www.sqlsaturday.com/372)

    The Guidebook admin website requires the data for the sessions in a certain format. You can choose CSV or XLS.

    In the admin portal you can download the template

    [![down](https://sqldbawithabeard.com/wp-content/uploads/2015/03/down.jpg?w=300)](https://sqldbawithabeard.com/wp-content/uploads/2015/03/down.jpg)

    which gives an Excel file like this


[![-excel](https://sqldbawithabeard.com/wp-content/uploads/2015/03/excel.jpg?w=300)](https://sqldbawithabeard.com/wp-content/uploads/2015/03/excel.jpg)

 

So now all we need to do is to fill it with data.

I have an Excel Object Snippet which I use to create new Excel Objects when using PowerShell to manipulate Excel. Here it is for you. Once you have run the code you will be able to press CTRL + J and be able to choose the New Excel Object Snippet any time.
```
$snippet = @{
Title = "New Excel Object";
Description = "Creates a New Excel Object";
Text = @"
# Create a .com object for Excel
\`$xl = new-object -comobject excel.application
\`$xl.Visible = \`$true # Set this to False when you run in production
\`$wb = \`$xl.Workbooks.Add() # Add a workbook

\`$ws = \`$wb.Worksheets.Item(1) # Add a worksheet

\`$cells=\`$ws.Cells
<#
Do Some Stuff

perhaps

\`$cells.item(\`$row,\`$col)="Server"
\`$cells.item(\`$row,\`$col).font.size=16
\`$Cells.item(\`$row,\`$col).Columnwidth = 10
\`$col++
#>

\`$wb.Saveas("C:\temp\Test\`$filename.xlsx")
\`$xl.quit()
"@
}
New-IseSnippet @snippet
```
I needed to change this to open the existing file by using

`$wb = $xl.Workbooks.Open($GuideBookPath)`

In the more help tab of the Excel workbook it says

> <table style="height:111px;" width="565"><tbody><tr><td width="956">2.     Make sure that your dates are in the following format: MM/DD/YYYY (i.e. 4/21/2011).  If the dates are in any other format, such as “April 21, 2011” or “3-Mar-2012”, Gears will not be able to import the data and you will receive an error message.</td></tr><tr><td width="956">3.     Make sure that your times are in the following format: HH:MM AM/PM (i.e. 2:30 PM, or 11:15 AM). If the times are in any other format, such as “3:00 p.m.” or “3:00:00 PM”, Gears will not be able to import the data and you will receive an error message.</td></tr></tbody></table>

So we need to do some manipulation of the data we gather. As before I selected the information from the XML as follows
```
$Speaker = @{Name="Speaker"; Expression = {$_.speakers.speaker.name}}
$Room = @{Name="Room"; Expression = {$_.location.name}}
$startTime = @{Name="StartTime"; Expression = {[datetime]($_.StartTime)}}
$Endtime = @{Name ="EndTime"; Expression = {[datetime]($_.EndTime)}}
$Talks = $Sessions.event|Where-Object {$_.title -ne 'Coffee Break' -and $_.title -ne 'Room Change' -and $_.title -ne 'Lunch Break' -and $_.title -ne 'Raffle and Cream Tea'}| select $Speaker,$Room,$Starttime,$Endtime,Title,Description |Sort-Object StartTime
```
I then looped through the $Talks array and wrote each line to Excel like this
```
foreach ($Talk in $Talks)
{
$Date = $Talk.StartTime.ToString('MM/dd/yyyy') ## to put the info in the right format
$Start = $talk.StartTime.ToString('hh:mm tt') ## to put the info in the right format
$End = $Talk.Endtime.ToString('hh:mm tt') ## to put the info in the right format
$Title = $Talk.Title
$Description = $Talk.Description
$Room = $Talk.Room
$col = 2
$cells.item($row,$col) = $Title
$col ++
$cells.item($row,$col) = $Date
$col ++
$cells.item($row,$col) = $Start
$col ++
$cells.item($row,$col) = $End
$col ++
$cells.item($row,$col) = $Room
$col ++
$col ++
$cells.item($row,$col) = $Description
$row++
}
```
I know that I converted the String to DateTime and then back to a String again but that was the easiest (quickest) way to obtain the correct format for the Excel file

Then to finish save the file and quit Excel
```
$wb.Save()
$xl.quit()
```
Then you upload the file in the Guidebook admin area [![import](https://sqldbawithabeard.com/wp-content/uploads/2015/03/import.jpg?w=300)](https://sqldbawithabeard.com/wp-content/uploads/2015/03/import.jpg)

wait for the email confirmation and all your sessions are available in the guidebook

[![sched](https://sqldbawithabeard.com/wp-content/uploads/2015/03/sched.jpg?w=300)](https://sqldbawithabeard.com/wp-content/uploads/2015/03/sched.jpg)

I hope that is useful to others. The full script is below
```
## From http://www.sqlservercentral.com/blogs/steve_jones/2015/01/26/downloading-sql-saturday-data/

$i = 372
$baseURL = “http://www.sqlsaturday.com/eventxml.aspx?sat=”
$DestinationFile = “E:\SQLSatData\SQLSat” + $i + “.xml”
$GuideBookPath = 'C:\temp\Guidebook_Schedule_Template.xls'
$sourceURL = $baseURL + $i

$doc = New-Object System.Xml.XmlDocument
$doc.Load($sourceURL)
$doc.Save($DestinationFile)

$Sessions = $doc.GuidebookXML.events
$Speaker = @{Name="Speaker"; Expression = {$_.speakers.speaker.name}}
$Room = @{Name="Room"; Expression = {$_.location.name}}
$startTime = @{Name="StartTime"; Expression = {[datetime]($_.StartTime)}}
$Endtime = @{Name ="EndTime"; Expression = {[datetime]($_.EndTime)}}

$Talks = $Sessions.event|Where-Object {$_.title -ne 'Coffee Break' -and $_.title -ne 'Room Change' -and $_.title -ne 'Lunch Break' -and $_.title -ne 'Raffle and Cream Tea'}| select $Speaker,$Room,$Starttime,$Endtime,Title,Description |Sort-Object StartTime

# Create a .com object for Excel
$xl = new-object -comobject excel.application
$xl.Visible = $true # Set this to False when you run in production
$wb = $xl.Workbooks.Open($GuideBookPath)
$ws = $wb.Worksheets.item(1)

$cells=$ws.Cells

$cells.item(2,1) = '' # To clear that entry
$cells.item(3,1) = '' # To clear that entry

$col = 2
$row = 2

foreach ($Talk in $Talks)
{
$Date = $Talk.StartTime.ToString('MM/dd/yyyy') ## to put the info in the right format
$Start = $talk.StartTime.ToString('hh:mm tt') ## to put the info in the right format
$End = $Talk.Endtime.ToString('hh:mm tt') ## to put the info in the right format
$Title = $Talk.Title
$Description = $Talk.Description
$Room = $Talk.Room
$col = 2
$cells.item($row,$col) = $Title
$col ++
$cells.item($row,$col) = $Date
$col ++
$cells.item($row,$col) = $Start
$col ++
$cells.item($row,$col) = $End
$col ++
$cells.item($row,$col) = $Room
$col ++
$col ++
$cells.item($row,$col) = $Description
$row++
}

$wb.Save()
$xl.quit()
```
