---
title: "Generating T-SQL Randomly with Powershell"
date: "2014-11-05" 
categories:
  - Blog

tags:
  - learning
  - PowerShell
  - script
  - snippet
  - sql
  - automation

---
I have a lab on my laptop running various servers so that I can problem solve and learn and recently I wanted to add several months of data into a database. I had created a stored procedure to take some parameters perform some logic and insert the data.

To execute the stored procedure in T-SQL I simply run this

    EXECUTE [dbo].[usp_Insert_DriveSpace] 'Server1','C','2014-11-05','100','25'

which uses the server name, drive letter, date, capacity and free space to add the data

In my wisdom I decided to create some data that was more ‘real-life’ I was interested in storing drive space data and will be learning how to write reports on it. To do this I had pre-populated some tables in the database with 10 Server Names each with 5 drives so I needed 10\*5\*90 or 4500 statements

I wanted to populate this with about 3 months of data as if it had been gathered every day. I read [this post](http://smehrozalam.wordpress.com/2009/06/09/t-sql-using-common-table-expressions-cte-to-generate-sequences/) about using CTEs to create sequences and I am sure it can be done this way but I don’t have the T-SQL skills to do so. If someone can (or has) done that please let me know as I am trying to improve my T-SQL skills and would be interested in how to approach and solve this problem with T-SQL

I solved it with Powershell in this way.

Created an array of Servers and an array of Drives to enable me to iterate though each.

    $Servers = 'Server1','Server2','Server3','Server4','Server5','Server6','Server7','Server8','Server9','Server10'
    $Drives = 'C','D','E','F','G'

Set the drive capacity for each drive. To make my life slightly easier I standardised my ‘servers’

    $CDriveCapacity = 100
    $DDriveCapacity = 50
    $EDriveCapacity = 200
    $FDriveCapacity = 200
    $GDriveCapacity = 500

I needed to create a date. You can use `Get-Date` to get todays date and to get dates or times in the future or the past you can use the `AddDays()` function. You can also add ticks, milliseconds, seconds, minutes, hours, months or years

    (Get-Date).AddDays(1)

I then needed to format the date. This is slightly confusing. If you just use `Get-Date` to get the current date (time) then you can use the `format` or `uformat` switch to format the output

    Get-Date -Format yyyyMMdd
    Get-Date -UFormat %Y%m%d

However this does not work once you have used the AddDays() method. You have to use the ToString() method

    $Date = (Get-Date).AddDays(-7).ToString('yyyy-MM-dd')

To replicate gathering data each day I decided to use a while loop. I set $x to –95 and pressed CTRL and J to bring up Snippets and typed w and picked the while loop. You can find out more about snippets in [my previous post](https://blog.robsewell.com/powershell-snippets-a-great-learning-tool/) I started at –95 so that all the identity keys incremented in a real-life manner oldest to newest.

    $x = -98
    while ($x -le 0)
    {
        $Date = (get-date).AddDays($x).ToString('yyyy-MM-dd')
    
        foreach($Server in $Servers)
        {
            foreach ($Drive in $Drives)
            {
I could then use the while loop to generate data for each day and loop through each server and each drive and generate the T-SQL but I wanted more!

I wanted to generate some random numbers for the free space available for each drive. I used the [Get-Random cmdlet](http://technet.microsoft.com/en-us/library/hh849905.aspx) If you are going to use it make sure you read [this post](http://www.vtesseract.com/post/15440295910/a-get-random-gotcha-powershell-how-i-was-robbed) to make sure that you don’t get caught by the gotcha. I decided to set the free space for my OS,Data and Log Files to somewhere between 70 and 3 Gb free as in this imaginary scenario these drives are carefully monitored and the data and log file sizes under the control of a careful DBA but still able to go below thresholds.

    if($Drive -eq 'C')
                {
                $Free = Get-Random -Maximum 70 -Minimum 3

I set the TempDB drive to have either 4,7 or 11 Gb free so that i can try to colour code my reports depending on values and if one field only has three values it makes it simpler to verify.

I set the Backup Drive to somewhere between 50 and 0 so that I will hit 0 sometimes!!

Here is the full script. It generated 4500 T-SQL statements in just under 16 seconds

    $Servers = 'Server1','Server2','Server3','Server4','Server5','Server6','Server7','Server8','Server9','Server10'
    $Drives = 'C','D','E','F','G'
    $CDriveCapacity = 100
    $DDriveCapacity = 50
    $EDriveCapacity = 200
    $FDriveCapacity = 200
    $GDriveCapacity = 500
    
    $x = -98
    while ($x -le 0)
    {
        $Date = (get-date).AddDays($x).ToString('yyyy-MM-dd')
    
        foreach($Server in $Servers)
        {
            foreach ($Drive in $Drives)
            {
                if($Drive -eq 'C')
                {
                $Free = Get-Random -Maximum 70 -Minimum 3
                Write-Host &quot;EXECUTE \[dbo\].\[usp\_Insert\_DriveSpace\] '$Server','$Drive','$Date','$CDriveCapacity','$Free'&quot;
                }
                elseif($Drive -eq 'D')
                {
                $Free = Get-Random -InputObject 4,7,11
                Write-Host &quot;EXECUTE \[dbo\].\[usp\_Insert\_DriveSpace\] '$Server','$Drive','$Date','$DDriveCapacity','$Free'&quot;
                }
                elseif($Drive -eq 'E')
                {
                $Free = Get-Random -Maximum 70 -Minimum 3
                Write-Host &quot;EXECUTE \[dbo\].\[usp\_Insert\_DriveSpace\] '$Server','$Drive','$Date','$EDriveCapacity','$Free'&quot;
                }
                elseif($Drive -eq 'F')
                {
                $Free = Get-Random -Maximum 70 -Minimum 3
                Write-Host &quot;EXECUTE \[dbo\].\[usp\_Insert\_DriveSpace\] '$Server','$Drive','$Date','$FDriveCapacity','$Free'&quot;
                }
                elseif($Drive -eq 'G')
                {
                $Free = Get-Random -Maximum 50 -Minimum 0
                Write-Host &quot;EXECUTE \[dbo\].\[usp\_Insert\_DriveSpace\] '$Server','$Drive','$Date','$GDriveCapacity','$Free'&quot;
                }
            }
        }
        $X++
    }

Once it had run I simply copied the output into SSMS and was on my way
