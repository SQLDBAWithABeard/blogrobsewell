---
title: "Converting SQL Agent Job Duration to TimeSpan using PowerShell"
date: "2016-09-12"
categories:
  - Blog

tags:
  - backups
  - databases
  - dbareports
  - documentation
  - powershell
  - script
  - smo
  - sql

image: assets/uploads/2016/09/timespan.png
---
When you look in msdb for the SQL Agent Job duration you will find that it is an int.

[![sysjobshistoiry](/assets/uploads/2016/09/sysjobshistoiry.png)](/assets/uploads/2016/09/sysjobshistoiry.png)

This is also the same when you look at `Get-SQLAgentJobHistory `from the sqlserver module. (You can get this by [downloading the latest SSMS release from here](https://msdn.microsoft.com/en-us/library/mt238290.aspx))

[![agentjobhistoryproperties](/assets/uploads/2016/09/agentjobhistoryproperties.png)](/assets/uploads/2016/09/agentjobhistoryproperties.png)

This means that when you look at the various duration of the Agent Jobs you get something like this

[![duration.PNG](/assets/uploads/2016/09/duration1.png)](/assets/uploads/2016/09/duration1.png)

The first job took 15 hours 41 minutes  53 seconds, the second 1 minute 25 seconds, the third 21 seconds. This makes it quite tricky to calculate the duration in a suitable datatype. In T-SQL people use scripts like the following from [MSSQLTips.com](https://www.mssqltips.com/sqlservertip/2850/querying-sql-server-agent-job-history-data/)
```
((run_duration/10000*3600 + (run_duration/100)%100*60 + run_duration%100 + 31 ) / 60)  as 'RunDurationMinutes'
```
I needed more information than the number of minutes so I have this which will convert the Run Duration to a timespan
```
$FormattedDuration = @{Name = 'FormattedDuration' ; Expression = {[timespan]$_.RunDuration.ToString().PadLeft(6,'0').insert(4,':').insert(2,':')}}
```
[![formatted.PNG](/assets/uploads/2016/09/formatted.png)](/assets/uploads/2016/09/formatted.png)

So how did I get to there?

First I tried to just convert it. In PowerShell you can define a datatype in square brackets and PowerShell will try to convert it

[![timespan](/assets/uploads/2016/09/timespan.png)](/assets/uploads/2016/09/timespan.png)

It did its best but it converted it to ticks! So we need to convince PowerShell that this is a proper timespan. First we need to convert the run duration to a standard length, you can use the PadLeft method of a string to do this which will ensure that a string has a length and precede the current string with a value you choose until the string is that length.

Lets have a length of 6 and preceding zeros PadLeft(6,’0′)

[![padlefterror](/assets/uploads/2016/09/padlefterror.png)](/assets/uploads/2016/09/padlefterror.png)

But this works only if it is a string!! Remember red text is useful, it will often contain the information you need to resolve your error. Luckily there is a method to turn an int to a string. I am using the foreach method to demonstrate

[![padleft-with-string](/assets/uploads/2016/09/padleft-with-string.png)](/assets/uploads/2016/09/padleft-with-string.png)

Now every string is 6 characters long starting with zeros. So all that is left is to format this with colons to separate the hours and minutes and the minutes and seconds. We can do this with the insert method. You can find out the methods using Get-Member or its alias gm

[![methods.PNG](/assets/uploads/2016/09/methods.png)](/assets/uploads/2016/09/methods.png)

So the insert method takes an int for the startindex and a string value to enter

[![insert](/assets/uploads/2016/09/insert.png)](/assets/uploads/2016/09/insert.png)

There we go now we have some proper formatted timespans however they are still strings. We can then convert them using [timespan] Now we can format the results within the select by using an expression as shown below

[![select](/assets/uploads/2016/09/select.png)](/assets/uploads/2016/09/select.png)

and as you can see it is a timespan now

[![timespan property.PNG](/assets/uploads/2016/09/timespan-property.png)](/assets/uploads/2016/09/timespan-property.png)

On a slight side note. I needed the durations for Agent Jobs with a certain name within the last 6 days.

[![getting-agent-jobs](/assets/uploads/2016/09/getting-agent-jobs1.png)](/assets/uploads/2016/09/getting-agent-jobs1.png)

I did this by passing an array of servers (which I got from my [dbareports](https://dbareports.io) database) to `Get-SQLAgentJobHistory`. I then used the Where method to filter for JobName and the Job Outcome step of the history. I compared the RunDate property  to `Get-Date` (today) adding -6 days using the `AddDays` method 🙂

Hopefully this will be of use to people and also I have it recorded for the next time I need to do it 🙂
