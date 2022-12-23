---
title: "Parsing XML Child Nodes and Converting to DateTime with PowerShell"
date: "2015-03-21"
categories: 
  - Community
  - PowerShell
  - SQL Saturday Exeter
  - SQL Server
tags: 
  - PowerShell
  - SQL Saturday Exeter
  - Event Organising
---

As part of my organiser role for SQLSaturday Exeter ([Training Day Information here](http://sqlsatexeter.azurewebsites.net) and [Saturday Information here](https://www.sqlsaturday.com/372/)) I needed to get some schedule information to input into a database.

I had read [Steve Jones blog posts on Downloading SQL Saturday Data](https://voiceofthedba.wordpress.com/2015/01/26/downloading-sql-saturday-data/) and followed the steps there to download the data from the SQL Saturday website for our event.

A typical session is held in the XML like this
```
<event>
    <importID>27608</importID>
    <speakers>
        <speaker>
            <id>27608</id>
            <name>William Durkin</name>
        </speaker>
    </speakers>
    <track>Track 2</track>
    <location>
        <name>Buccaneer's Refuge </name>
    </location>
    <title>Stories from the Trenches: Upgrading SQL with Minimal Downtime</title>
    <description>SQL Server has come a long way in the last few years, with Microsoft investing heavily in High Availability features. This session will show you how to use these features to enable you to safely upgrade a SQL Server, while ensuring you have a return path if things should go wrong. You will leave the session knowing what features you can use to upgrade either the OS, Hardware or SQL Server version while keeping your maintenance window to a minimum. The session will apply to Standard Edition as well as Enterprise Edition, so doesn't only apply to 'High Rollers'!</description>
    <startTime>4/25/2015 3:20:00 PM</startTime>
    <endTime>4/25/2015 4:10:00 PM</endTime>
</event>
```
 

I needed to output the following details - Speaker Name , Room , Start time,Duration and Title

To accomplish this I examined the node for Williams session
```
$i = 372
$baseURL = “http://www.sqlsaturday.com/eventxml.aspx?sat=”
$DestinationFile = “E:\SQLSatData\SQLSat” + $i + “.xml”
$sourceURL = $baseURL + $i

$doc = New-Object System.Xml.XmlDocument
$doc.Load($sourceURL)
$doc.Save($DestinationFile)

$Sessions = $doc.GuidebookXML.events

$Sessions.event[39]
```
I then established that to get the speakers name I had to obtain the value from the child node which I accomplished as follows
```
$Speaker = @{Name="Speaker"; Expression = {$_.speakers.speaker.name}}
$Sessions.event[39]|select $Speaker #To check that it worked
```
This is an easy way to obtain sub(or child) properties within a select in PowerShell and I would recommend that you practice and understand that syntax of @{Name=""; Expression = {} } which will enable you to perform all kinds of manipulation on those objects. You are not just limited to obtaining child properties but can perform calculations as well

I did the same thing to get the room and the start time
```
$Room = @{Name="Room"; Expression = {$_.location.name}}
$StartTime = @{Name="StartTime"; Expression = {$_.StartTime}}
$Sessions.event[39]|select $Speaker,$Room,$StartTime #To check that it worked
```
I then needed duration and thought that I could use
```
$Duration = @{Name ="Duration"; Expression = {($_.EndTime) - ($_.StartTime)}}
$Sessions.event[39]|select $duration
```
However that just gave me a blank result so to troubleshoot I ran

`$Sessions.event[39].endtime - $sessions.event[39].startTime`

Which errored with the (obvious when I thought about it) message

> Cannot convert value "4/25/2015 4:10:00 PM" to type "System.Int32". Error: "Input string was not in a correct format." At line:1 char:1 + $Sessions.event[39].endtime - $sessions.event[39].startTime + ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ + CategoryInfo : InvalidArgument: (:) [], RuntimeException + FullyQualifiedErrorId : InvalidCastFromStringToInteger

The value was stored as a string

Running

`$Sessions.event[39].endtime |Get-Member`

showed me that there was a method called ToDateTime but there is an easier way. By defining the datatype of an object PowerShell will convert it for you so the resulting code looks like this
```
$Sessions = $doc.GuidebookXML.events
$Speaker = @{Name="Speaker"; Expression = {$_.speakers.speaker.name}}
$Room = @{Name="Room"; Expression = {$_.location.name}}
$Duration = @{Name ="Duration"; Expression = {[datetime]($_.EndTime) - [datetime]($_.StartTime)}}
$startTime = @{Name="StartTime"; Expression = {[datetime]($_.StartTime)}}
$Sessions.event|select $Speaker,$Room,$Starttime,$Duration,Title |Format-Table -AutoSize -Wrap
```
and the resulting entry is finally as I required it. I believe that this will use the regional settings from the installation on the machine that you are using but I have not verified that. If anyone in a different region would like to run this code and check that that is the case I will update the post accordingly

[![zzCapture](https://sqldbawithabeard.com/wp-content/uploads/2015/03/zzcapture.jpg?w=300)](https://sqldbawithabeard.com/wp-content/uploads/2015/03/zzcapture.jpg)

Hopefully you have learnt from this how you can extend select from the pipeline and how defining the datatype can be beneficial. Any questions please comment below
