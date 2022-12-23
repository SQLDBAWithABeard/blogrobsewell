---
title: "How I Check Hundreds of SQL Agent Jobs in 60 Seconds with Powershell"
categories:
  - Blog

tags:
  - automate
  - automation
  - PowerShell
  - sql
  - Excel
  - SQL Agent Jobs
  - SQL Server


header:
  teaser: /assets/uploads/2014/03/033114_2017_howicheckhu6.png

---
## Editors Note
This is still all valid but nowadays you would be much better off using dbatools to gather the information and the ImportExcel module to add it to an Excel sheet :-)

# Original Post

Checking that your Agent Jobs have completed successfully is a vital part of any DBA’s responsibility. It is essential to ensure that all of the hard work you have put into setting up the jobs can be quickly and easily checked. In a large estate this can be very time consuming and if done manually prone to human error. I have repeatedly mentioned <A href="http://www.johnsansom.com/the-best-database-administrators-automate-everything/" rel=noopener target=_blank>John Sansoms Blog Post entitled “The Best DBAs Automate Everything” </A>and I follow that advice. Today I will share with you one fo the first scripts that I wrote.  
  
When I started as a DBA I was told that my first job every morning was to check the Agent Jobs and resolve any errors. This is still something I do first before anything else. (Except coffee, experience has taught me that you get your coffee before you log into your computer otherwise on the bad days you can miss out on coffee for many an hour) I have two scripts to do this. The first sends me an email if the number of failed jobs on a server is greater than zero. This helps me to quickly and simply identify where to start in the case of multiple failures and is also a backup to the second script.  
  
The second script runs on a different server and creates an excel worksheet and colour codes it. This makes it very simple to quickly scroll through the sheet and spot any red cells which designate failed jobs and also provides a nice easy to understand method to show management that on that specific day everything went well (or badly)  
  
As with any Powershell script which manipulates Office applications you first need to create an object and add the workbook and worksheet to it. I also set a filename date variable and a Date variable for the Sheet.  

[![howicheckhu1](https://blog.robsewell.com/assets/uploads/2014/03/033114_2017_howicheckhu1.png)](https://blog.robsewell.com/assets/uploads/2014/03/033114_2017_howicheckhu1.png)  

When you use Powershell to manipulate Excel you can access individual cells by identifying them by Row and Column. I use this to create a description for the work book as follows  

[![howicheckhu2](https://blog.robsewell.com/assets/uploads/2014/03/033114_2017_howicheckhu2.png)](https://blog.robsewell.com/assets/uploads/2014/03/033114_2017_howicheckhu2.png)  

There are lots of properties that you can play with within Excel. As with any Powershell the best way to find what you need is to use the `Get-Member` Cmdlet. If you run  

````
($cells.item(1,3)|Get-Member).Count
````

You will see that there are 185 Methods and Properties available to you (in Office 2013 on Windows 8.1)
The snippet above creates the following  

[![howicheckhu3](https://blog.robsewell.com/assets/uploads/2014/03/033114_2017_howicheckhu3.png)](https://blog.robsewell.com/assets/uploads/2014/03/033114_2017_howicheckhu3.png)  

As you can see we are going to colour code the Job Status according to the three available results Successful, Failed and Unknown. We are also going to colour code the date column to see when the job was last run, this will enable you to easily identify if the last time the job ran it was successful but last night it didn’t kick off for some reason.  
  
The next step is a fairly standard loop through available servers by picking them from a SQLServers text file, a list of the server names (ServerName\Instance if required) that you wish to check. You could also just create an array of server names or pick them from a table with `Invoke-SQLCmd` but which ever way you do it you need to be able to iterate through the array and then the `.Jobs` Collection in the `JobServer` Namespace as follows  

[![howicheckhu4](https://blog.robsewell.com/assets/uploads/2014/03/033114_2017_howicheckhu4.png)](https://blog.robsewell.com/assets/uploads/2014/03/033114_2017_howicheckhu4.png)  

What the script then does is to use the following properties of the `$Job` object and write the Excel File according to the logic in the description  
````
$Job.Name
$Job.IsEnabled
$Job.LastRunOutcome
$Job.LastRunDate  
````
To finish up save the workbook to a share available to all of the DBA Team and quit Excel. Notice that I use a double whammy to make sure Excel is really gone. First I quit the .com object and then I stop the process. I do this because I found that on my server quitting the .com object left the Excel process running and I ended up with dozens and dozens of them. If you have Excel open before you run this script either comment out the last line or save your work (You should save your work anyway regulary!)  

[![howicheckhu5](https://blog.robsewell.com/assets/uploads/2014/03/033114_2017_howicheckhu5.png)](https://blog.robsewell.com/assets/uploads/2014/03/033114_2017_howicheckhu5.png)  

As always I take no responsibility for your environment, that’s your Job! Don’t run this on Production unless you know what it is doing and are happy that you have first tested it somewhere safely away from any important systems. Make sure that you understand the correct time to run this job and have qualified the impact on the box it is running on.
Here is a screen shot of the finished Excel Sheet  

[![howicheckhu6](https://blog.robsewell.com/assets/uploads/2014/03/033114_2017_howicheckhu6.png)](https://blog.robsewell.com/assets/uploads/2014/03/033114_2017_howicheckhu6.png)  

As you can see the Data Transfer Job needs investigation! The reason I add to yellow rows above and below each servers list of jobs is to help me identify any server that is not responding as that will be easily recognised as two lots of yellow with nothing between them
I have considered improving this script by inputting the data into a database and running a report from that database but have not had the need to do so yet.  

Here is the script  

````
#############################################################################################
#
# NAME: Agent Job Status to Excel.ps1
# AUTHOR: Rob Sewell http://newsqldbawiththebeard.wordpress.com
# DATE:22/07/2013
#
# COMMENTS: Iterates through the sqlservers.txt file to populate
# Excel File with colour coded status
#
# WARNING - This will stop ALL Excel Processes. Read the Blog Post for more info
#
# ————————————————————————

# Get List of sql servers to check
$sqlservers = Get-Content ''; # from a file or a SQL query or whatever

# Create a .com object for Excel
$xl = new-object -comobject excel.application
$xl.Visible = $true # Set this to False when you run in production

$wb = $xl.Workbooks.Add()
$ws = $wb.Worksheets.Item(1)

$date = Get-Date -format f
$Filename = ( get-date ).ToString('ddMMMyyyHHmm')

$cells = $ws.Cells

# Create a description

$cells.item(1, 3).font.bold = $True
$cells.item(1, 3).font.size = 18
$cells.item(1, 3) = "Back Up Report $date"
$cells.item(5, 9) = "Last Job Run Older than 1 Day"
$cells.item(5, 8).Interior.ColorIndex = 43
$cells.item(4, 9) = "Last Job Run Older than 7 Days"
$cells.item(4, 8).Interior.ColorIndex = 53
$cells.item(7, 9) = "Successful Job"
$cells.item(7, 8).Interior.ColorIndex = 4
$cells.item(8, 9) = "Failed Job"
$cells.item(8, 8).Interior.ColorIndex = 3
$cells.item(9, 9) = "Job Status Unknown"
$cells.item(9, 8).Interior.ColorIndex = 15


#define some variables to control navigation
$row = 3
$col = 2

#insert column headings

$cells.item($row, $col) = "Server"
$cells.item($row, $col).font.size = 16
$Cells.item($row, $col).Columnwidth = 10
$col++
$cells.item($row, $col) = "Job Name"
$cells.item($row, $col).font.size = 16
$Cells.item($row, $col).Columnwidth = 40
$col++
$cells.item($row, $col) = "Enabled?"
$cells.item($row, $col).font.size = 16    
$Cells.item($row, $col).Columnwidth = 15
$col++    
$cells.item($row, $col) = "Outcome"
$cells.item($row, $col).font.size = 16
$Cells.item($row, $col).Columnwidth = 12
$col++
$cells.item($row, $col) = "Last Run Time"
$cells.item($row, $col).font.size = 16    
$Cells.item($row, $col).Columnwidth = 15
$col++

   
# Load SMO extension
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null;


# Loop through each sql server from sqlservers.txt
foreach ($sqlserver in $sqlservers) {
    # Create an SMO Server object
    $srv = New-Object "Microsoft.SqlServer.Management.Smo.Server" $sqlserver;
 
    # For each jobs on the server
    foreach ($job in $srv.JobServer.Jobs) {

        $jobName = $job.Name;
        $jobEnabled = $job.IsEnabled;
        $jobLastRunOutcome = $job.LastRunOutcome;
        $Time = $job.LastRunDate ;

        # Set Fill Colour for Job Enabled
        if ($jobEnabled -eq "FALSE")
        { $colourenabled = "2"}
        else {$colourenabled = "48" }         

        # Set  Fill Colour for Failed jobs
        if ($jobLastRunOutcome -eq "Failed") {
            $colour = "3" # RED
        }
            
        # Set Fill Colour for Uknown jobs
        Elseif ($jobLastRunOutcome -eq "Unknown")
        { $colour = "15"}       #GREY        

        else {$Colour = "4"}   # Success is Green    
        $row++
        $col = 2
        $cells.item($Row, $col) = $sqlserver
        $col++
        $cells.item($Row, $col) = $jobName
        $col++
        $cells.item($Row, $col) = $jobEnabled    
        #Set colour of cells for Disabled Jobs to Grey
    
        $cells.item($Row, $col).Interior.ColorIndex = $colourEnabled
        if ($colourenabled -eq "48") { 
            $cells.item($Row , 1 ).Interior.ColorIndex = 48
            $cells.item($Row , 2 ).Interior.ColorIndex = 48
            $cells.item($Row , 3 ).Interior.ColorIndex = 48
            $cells.item($Row , 4 ).Interior.ColorIndex = 48
            $cells.item($Row , 5 ).Interior.ColorIndex = 48
            $cells.item($Row , 6 ).Interior.ColorIndex = 48
            $cells.item($Row , 7 ).Interior.ColorIndex = 48
        } 
        $col++

        $cells.item($Row, $col) = "$jobLastRunOutcome"
        $cells.item($Row, $col).Interior.ColorIndex = $colour

        #Reset Disabled Jobs Fill Colour
        if ($colourenabled -eq "48") 
        {$cells.item($Row, $col).Interior.ColorIndex = 48}

        $col++

        $cells.item($Row, $col) = $Time 
    
        #Set teh Fill Colour for Time Cells

        If ($Time -lt ($(Get-Date).AddDays(-1)))
        { $cells.item($Row, $col).Interior.ColorIndex = 43}
        If ($Time -lt ($(Get-Date).AddDays(-7)))
        { $cells.item($Row, $col).Interior.ColorIndex = 53} 
              
    }
    $row++
    $row++

    # Add two Yellow Rows
    $ws.rows.item($Row).Interior.ColorIndex = 6
    $row++
    $ws.rows.item($Row).Interior.ColorIndex = 6
    $row++
}


$wb.Saveas("C:\temp\Test$filename.xlsx")
$xl.quit()
Stop-Process -Name EXCEL
````  

If you have any questions please get in touch

