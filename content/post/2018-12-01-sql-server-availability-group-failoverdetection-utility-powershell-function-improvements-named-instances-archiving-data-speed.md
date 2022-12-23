---
title: "SQL Server Availability Group FailoverDetection Utility PowerShell Function Improvements – Named Instances, Archiving Data, Speed"
categories:
  - Blog

tags:
  - dbatools
  - GitHub 
  - PowerShell

---
In [my last post I wrote about a new function](https://blog.robsewell.com/gathering-all-the-logs-and-running-the-availability-group-failover-detection-utility-with-powershell/) for gathering the data and running the [FailoverDetection utility](https://blogs.msdn.microsoft.com/sql_server_team/failover-detection-utility-availability-group-failover-analysis-made-easy/) by the [Tiger Team](https://twitter.com/mssqltiger) to analyse availability group failovers. I have updated it following some comments and using it for a day.

### Don’t forget the named instances Rob!

Michael Karpenko wrote a comment pointing out that I had not supported named instances, which was correct as it had not been written for that. Thank you Michael 🙂 I have updated the code to deal with named instances.

### Confusing results

I also realised as we started testing the code that if you had run the code once and then ran it again against a different availability group the tool does not clear out the data folder that it uses so you can get confusing results.

In the image below I had looked at the default instance and then a MIRROR named instance. As you can see the results json on the left shows the default instance SQLClusterAG while the one on the right shows both the SQLClusterAG and the MirrrAG instance results.

[![duplicate results.png](https://blog.robsewell.com/assets/uploads/2018/11/duplicate-results.png)](https://blog.robsewell.com/assets/uploads/2018/11/duplicate-results.png)

This is not so useful if you don’t notice this at first with the expanded json!! Now you may in this situation want to see the combined results from all of the availability groups on one cluster. You could gather all of the data from each instance and then add it to the data folder easily enough.

By cleaning out the data folder before running the utility the results are as expected.

![duplicate results fixed.png](https://blog.robsewell.com/assets/uploads/2018/11/duplicate-results-fixed.png)

### Archive the data for historical analysis

One of the production DBAs pointed out that having gathered the information, it would be useful to hold it for better analysis of repeated issues. I have added an archiving step so that when the tools runs, if there is already data in the data gathering folder, it will copy that to an archive folder and name it with the date and time that the cluster log was created as this is a good estimation of when the analysis was performed. If an archive folder location is not provided it will create an archive folder in the data folder. This is not an ideal solution though, as the utility will copy all of the files and folders from there to its own location so it is better to define an archive folder in the parameters.

### Get-Eventlog is sloooooooooooow

I was running the tools and noticed it sat running the system event log task for a long long time. I ran some tests using a variation of the [dbatools prompt.](http://dbatools.io/prompt)

This will show in the prompt how long it took to run the previous statement .

[![speed.png](https://blog.robsewell.com/assets/uploads/2018/11/speed.png)](https://blog.robsewell.com/assets/uploads/2018/11/speed.png)

In the image above (which you can click to get a larger version as with all images on this blog) you can see that it took 18ms to set the date variable, FOUR MINUTES and FORTY THREE seconds to get the system log in the last 2 days using Get-EventLog and 29.1 seconds using Get-WinEvent and a FilterHashtable.

### Getting the function

This function requires PowerShell version 5 and the [dbatools](http://dbatools.io) module.

You can get the function from [my GitHub Functions Repository here (at the moment – will be adding to dbatools see below)](https://github.com/SQLDBAWithABeard/Functions/blob/master/Invoke-SqlFailOverDetection.ps1)

Load the function by either running the code or if you have it saved as a file dot-sourcing it.

. .\\Invoke-SqlFailOverDetection.ps1

There are two .’s with a space in between and then a \ without a space. so Dot Space Dot Whack path to file.

The next thing you should do is what you should always do with a new PowerShell function, look at the help.

Get-Help Invoke-SqlFailOverDetection -Detailed

You will find plenty of examples to get you going and explanations of all of the parameters and more info [on my previous post.](https://blog.robsewell.com/gathering-all-the-logs-and-running-the-availability-group-failover-detection-utility-with-powershell/)

Happy Automating!

