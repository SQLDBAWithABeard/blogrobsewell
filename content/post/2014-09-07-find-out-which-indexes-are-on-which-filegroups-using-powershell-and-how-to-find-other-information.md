---
title: "Find Out Which Indexes are on which Filegroups using PowerShell And How To Find Other Information"
date: "2014-09-07" 
categories:
  - Blog

tags:
  - databases
  - html
  - PowerShell
  - report
  - script
  - indexes
  - file groups


image: /assets/uploads/2014/09/image8.png

---
A short post today to pass on a script I wrote to fulfil a requirement I had.

Which indexes are on which filegroups. I found a blog post showing how to [do it with T-SQL](http://basitaalishan.com/2013/03/03/list-all-objects-and-indexes-per-filegroup-partition/) but as is my wont I decided to see how easy it would be with PowerShell. I also thought that it would make a good post to show how I approach this sort of challenge.

I generally start by creating a [SQL Server SMO Object](http://msdn.microsoft.com/en-GB/library/microsoft.sqlserver.management.smo.aspx?WT.mc_id=DP-MVP-5002693) You can use the [SMO Object Model Diagram](http://msdn.microsoft.com/en-us/library/ms162209(v=sql.110).aspx?WT.mc_id=DP-MVP-5002693) or Get-Member to work out what you need. As we are talking indexes and filegroups I will also create a Database object

    $Server = "SQL2012Ser2012"
    $DBName = "AdventureWorks2012"
    $srv = New-Object Microsoft.SqlServer.Management.Smo.Server $Server
    $DB = $srv.Databases[$DBName]

Then by piping the database object to Get-Member I can see the properties

[![image](https://blog.robsewell.com/assets/uploads/2014/09/image_thumb2.png?resize=630%2C273&ssl=1 "image")](https://blog.robsewell.com/assets/uploads/2014/09/image2.png)

Lets take a look at the table object in the same way

[![image](https://blog.robsewell.com/assets/uploads/2014/09/image_thumb3.png)](https://blog.robsewell.com/assets/uploads/2014/09/image3.png)

I can see the indexes object so I pipe that to Get-Member as well

[![image](https://blog.robsewell.com/assets/uploads/2014/09/image_thumb4.png)](https://blog.robsewell.com/assets/uploads/2014/09/image4.png)

Now I have enough to information to create the report. I will select the Name, Table, Type and Space Used of the Indexes and format them nicely

    $Server = "SQL2012Ser2012"
    $DBName = "AdventureWorks2012"
    $srv = New-Object Microsoft.SqlServer.Management.Smo.Server $Server
    $DB = $srv.Databases[$DBName]
    $db.tables.Indexes|select Name,Parent,Filegroup,IndexType,SpaceUsed|Format-Table –AutoSize

and here are the results

[![image](https://blog.robsewell.com/assets/uploads/2014/09/image_thumb5.png)](https://blog.robsewell.com/assets/uploads/2014/09/image5.png)

However, you may want the results to be displayed in a different manner, maybe CSV,HTML or text file and you can do this as follows

    $db.tables.Indexes|select Name,Parent,Filegroup,IndexType,SpaceUsed|ConvertTo-Csv c:\temp\filegroups.csv
    Invoke-Item c:\temp\filegroups.csv

[![image](https://blog.robsewell.com/assets/uploads/2014/09/image_thumb6.png)](https://blog.robsewell.com/assets/uploads/2014/09/image6.png)

    $db.tables.Indexes|select Name,Parent,Filegroup,IndexType,SpaceUsed| Out-File c:\temp\filegroups.txt
    Invoke-Item c:\temp\filegroups.txt


[![image](https://blog.robsewell.com/assets/uploads/2014/09/image_thumb7.png)](https://blog.robsewell.com/assets/uploads/2014/09/image7.png)


    $db.tables.Indexes|select Name,Parent,Filegroup,IndexType,SpaceUsed|ConvertTo-Html |Out-File c:\temp\filegroups.html
    Invoke-Item c:\temp\filegroups.html

[![image](https://blog.robsewell.com/assets/uploads/2014/09/image_thumb8.png)](https://blog.robsewell.com/assets/uploads/2014/09/image8.png)

Hopefully this has shown you how easy it can be to use PowerShell to get all of the information that you need from your SQL Server and how to approach getting that information as well as several ways to display it
