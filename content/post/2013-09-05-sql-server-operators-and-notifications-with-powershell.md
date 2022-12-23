---
title: "SQL Server Operators and Notifications with Powershell – Strange Enumerate issue fixed by @napalmgram"
date: "2013-09-05" 
categories:
  - Blog

tags:
  - napalmgram
  - automate
  - automation
  - databases
  - document
  - documentation
  - notifications
  - operators
  - PowerShell
  - box-of-tricks

---
<P>Alerting of issues across the SQL Server estate is important and recently I needed to audit the operators and the notifications that they were receiving.</P>
<P>I created a SQL Server Object</P>

![alt](https://blog.robsewell.com/assets/uploads/2013/09/2013-09-04_125056.jpg)

<P>One of the important things to remember when investigating SMO is the Get-Member cmdlet. This will show all methods and properties of the object</P>

    $server | Get-Member

<P>gave me the JobServer Property</P>

    $Server.JobServer|gm


<P>includes the Operator Property</P>

    $Server.JobServer.Operators | gm

![alt](https://blog.robsewell.com/assets/uploads/2013/09/2013-09-04_125717.jpg)

<P>has the&nbsp;EnumJobNotifications and&nbsp;EnumNotifications methods</P>
<P>So it was easy to loop through each server in the servers.txt file and enumerate the notifications for each Operator</P>

![alt](https://blog.robsewell.com/assets/uploads/2013/09/2013-09-04_130052.jpg)

<P>and create a simple report</P>
<P>However this does not work as it does not perform the second enumerate. Try it yourself, switch round the&nbsp;EnumJobNotifications and&nbsp;EnumNotifications methods in that script and see what happens.</P>
<P>So I ended up with two functions</P>

![alt](https://blog.robsewell.com/assets/uploads/2013/09/2013-09-04_174005.jpg)

![alt](https://blog.robsewell.com/assets/uploads/2013/09/2013-09-04_173953.jpg)

<P>and I thought I could do this</P>

![alt](https://i0.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/2013-09-04_174056.jpg)

<P>But that doesnt work</P>
<P>So I tried this</P>

![alt](https://i0.wp.com/sqldbawithabeard.com/wp-content/uploads/2013/09/2013-09-04_174112.jpg)

<P>and that doesnt work either</P>
<P>Now the reports are coming out showing the correct number of lines but not displaying them. I spent a period of time on my Azure boxes trying to work a way around this. I set the outputs to both enums to a variable and noted that they are different type of objects.</P>

![alt](https://blog.robsewell.com/assets/uploads/2013/09/2013-09-05_113931.jpg)

<P>Job Notifications are System.Object and Alert Notifications are System.Array</P>
<P>I tried to enumerate through each member of the array and display them but got too tired to finish but I had contacted my friend Stuart Moore <A href="http://twitter.com/napalmgram" rel=noopener target=_blank>Twitter</A> | <A href="http://stuart-moore.com/" rel=noopener target=_blank>Blog</A>&nbsp;who had a look and resolved it by simply piping the Enumerates to Format-Table. Thank you Stuart.</P>
<P>So the final script is as follows</P>

![alt](https://blog.robsewell.com/assets/uploads/2013/09/2013-09-05_114601.jpg)

<P>and the script is</P>

    #############################################################################    ################
    #
    # NAME: Show-SQLServerOperators.ps1
    # AUTHOR: Rob Sewell https://blog.robsewell.com
    # DATE:03/09/2013
    #
    # COMMENTS: Load function for Enumerating Operators and Notifications
    # ————————————————————————
    
    Function Show-SQLServerOperators ($SQLServer) {
        Write-Output "############### $SQLServer ##########################"
        Write-Output     "#####################################################`n"     
    
        $server = new-object "Microsoft.SqlServer.Management.Smo.Server"     $SQLServer
            
            
        foreach ($Operator in $server.JobServer.Operators) {
            $Operator = New-Object ("$SMO.Agent.Operator") ($server.JobServer,     $Operator)
    
            $OpName = $Operator.Name
            Write-Output "Operator $OpName"
            Write-Output "`n###### Job Notifications   ######"
            $Operator.EnumJobNotifications()| Select JobName | Format-Table
            Write-Output     "#####################################################`n"  
            Write-Output "`n###### Alert Notifications  #######"
            $Operator.EnumNotifications() | Select AlertName | Format-Table
            Write-Output     "#####################################################`n"  
                     
        }
     
    }        
