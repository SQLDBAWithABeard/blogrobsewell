---
title: "Using PowerShell to find a database amongst hundreds"
categories:
  - Blog

tags:
  - automate
  - databases
  - PowerShell
  - box-of-tricks

---
<P>As you know, I love PowerShell!</P>
<P>I have developed a series of functions over time which save me time and effort whilst still enabling me to provide a good service to my customers. I also have a very simple GUI which I have set up for my colleagues to enable them to easily answer simple questions quickly and easily which I will blog about later. I call it my <A href="https://blog.robsewell.com/tags/#box-of-tricks" rel=noopener target=_blank>PowerShell Box of Tricks</A></P>
<P>I am going to write a short post about each one over the next few weeks as I write my presentation on the same subject which I will be presenting to SQL User Groups.</P>
<P>Todays question which I often get asked is <STRONG>Which server is that database on?</STRONG></P>
<P>It isn’t always asked like that. Sometimes it is a developer asking where the database for their UAT/SAT/FAT/Dev environment is. Sometimes it is a manager who requires the information for some documentation or report. I wrote it because whilst I am good, I am not good enough to remember the server location for many hundreds of databases and also because I wanted to enable a new starter to be as self sufficient as possible</P>
<P>When I first wrote this I thought it would be a case of simply using `$databaseName.Contains($DatabaseNameSearch)` but this did not work for MiXed case searches or DatAbaSe names so I had to convert both the search and the database name to lower case first</P>

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image34.png)](https://blog.robsewell.com/assets/uploads/2013/09/image34.png)

I create an empty hash table and then populate it with the results

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image35.png)](https://blog.robsewell.com/assets/uploads/2013/09/image35.png)

Set a results variable to the names from the hash table and count the number of records

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image36.png)](https://blog.robsewell.com/assets/uploads/2013/09/image36.png)

and call it like this

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image37.png)](https://blog.robsewell.com/assets/uploads/2013/09/image37.png)

Note that the search uses the contains method so no need for wildcards

Results come out like this

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image38.png)](https://blog.robsewell.com/assets/uploads/2013/09/image38.png)

<P>You can find the code here</P>

    #############################################################################    ################
    #
    # NAME: Find-Database.ps1
    # AUTHOR: Rob Sewell http://newsqldbawiththebeard.wordpress.com
    # DATE:22/07/2013
    #
    # COMMENTS: Load function for finding a database
    # USAGE: Find-Database DBName
    ##################################
    
    
    Function Find-Database ([string]$Search) {
    
        [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.    SMO') | out-null
    
        # Pull a list of servers from a local text file
    
        $servers = Get-Content 'sqlservers.txt'
    
        #Create an empty Hash Table
        $ht = @{}
        $b = 0
    
        #Convert Search to Lower Case
        $DatabaseNameSearch = $search.ToLower()  
    
    				Write-Output "#################################"
    				Write-Output "Searching for $DatabaseNameSearch "  
    				Write-Output "#################################"  
    
                                     
    
        #loop through each server and check database name against input
                        
        foreach ($server in $servers) {
    
            if (Test-Connection $Server -Count 1 -Quiet) {
                $srv = New-Object ('Microsoft.SqlServer.Management.Smo.Server')     $server
        
                foreach ($database in $srv.Databases) {
                    $databaseName = $database.Name.ToLower()
    
                    if ($databaseName.Contains($DatabaseNameSearch)) {
    
                        $DatabaseNameResult = $database.name
                        $Key = "$Server -- $DatabaseNameResult"
                        $ht.add($Key , $b)
                        $b = $b + 1
                    }
                }        
            }
        }
    
        $Results = $ht.GetEnumerator() | Sort-Object Name|Select Name
        $Resultscount = $ht.Count
    
        if ($Resultscount -gt 0) {
    
            Write-Output "###############   I Found It!!  #################"
            foreach ($R in $Results) {
                Write-Output $R.Name 
            }
        }
        Else {
            Write-Output "############    I am really sorry. I cannot find"      $DatabaseNameSearch  "Anywhere  ##################### "
        }             
    }
