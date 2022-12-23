---
title: "Converting a Datarow to a JSON object with PowerShell"
date: "2017-12-18" 
categories:
  - Blog

tags:
  - datarow
  - datatable
  - dbatools
  - json
  - mock
  - pester

---
This is just a quick post. As is frequent with these they are as much for me to refer to in the future and also because the very act of writing it down will aid me in remembering. I encourage you to do the same. Share what you learn because it will help you as well as helping others.

Anyway, I was writing some Pester tests for a module that I was writing when I needed some sample data. I have [written before about using Json for this purpose](https://blog.robsewell.com/writing-dynamic-and-random-tests-cases-for-pester/) This function required some data from a database so I wrote the query to get the data and used [dbatools](https://dbatools.io) to run the query against the database using [Get-DbaDatabase](https://dbatools.io/functions/Get-DbaDatabase)

```
$db = Get-DbaDatabase -SqlInstance $Instance -Database $Database
$variable = $db.Query($Query)
```

Simple enough. I wanted to be able to Mock `$variable.` I wrapped the code above in a function, let’s call it `Run-Query`

```
function Run-Query {(Param $query)
$db = Get-DbaDatabase -SqlInstance $Instance -Database $Database
$variable = $db.Query($Query)
}
```
Which meant that I could easily separate it for mocking in my test. I ran the code and investigated the $variable variable to ensure it had what I wanted for my test and then decided to convert it into JSON using [ConvertTo-Json](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/convertto-json?view=powershell-5.1?WT.mc_id=DP-MVP-5002693)

Lets show what happens with an example using WideWorldImporters and a query I found on [Kendra Littles blogpost about deadlocks](https://littlekendra.com/2016/09/13/deadlock-code-for-the-wideworldimporters-sample-database/)

```
$query = @"
SELECT Top 10 CityName, StateProvinceName, sp.LatestRecordedPopulation, CountryName
FROM Application.Cities AS city
JOIN Application.StateProvinces AS sp on
city.StateProvinceID = sp.StateProvinceID
JOIN Application.Countries AS ctry on
sp.CountryID=ctry.CountryID
WHERE sp.StateProvinceName = N'Virginia'
ORDER BY CityName
"@
$db = Get-DbaDatabase -SqlInstance rob-xps -Database WideWorldImporters
$variable = $db.Query($Query)
```

If I investigate the `$variable` variable I get

![data results](https://blog.robsewell.com/assets/uploads/2017/12/data-results.png)

The results were just what I wanted so I thought I will just convert them to JSON and save them in a file and bingo I have some test data in a mock to ensure my code is doing what I expect. However, when I run

`$variable | ConvertTo-Json`

I get

![json error.png](https://blog.robsewell.com/assets/uploads/2017/12/json-error.png)

and thats just for one row!

The way to resolve this is to only select the data that we need. The easiest way to do this is to exclude the properties that we don’t need

`$variable | Select-Object * -ExcludeProperty ItemArray, Table, RowError, RowState, HasErrors | ConvertTo-Json`

which gave me what I needed and a good use case for -ExcludeProperty

![json fixed.png](https://blog.robsewell.com/assets/uploads/2017/12/json-fixed.png)
