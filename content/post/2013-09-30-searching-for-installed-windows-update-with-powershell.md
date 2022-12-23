---
title: "Searching for Installed Windows Update With PowerShell"
date: "2013-09-30" 
categories:
  - Blog

tags:
  - automate
  - PowerShell

---
[Yesterdays Post Show-WindowsUpdatesLocal](https://blog.robsewell.com/?p=480) does enable you to search for an installed update as follows

    Show-WindowsUpdatesLocal|Where-Object {$_.HotFixID -eq ‘KB2855336’} |Select Date, HotfixID, Result,Title|Format-Table –AutoSize

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image108.png)](https://blog.robsewell.com/assets/uploads/2013/09/image108.png)

I thought I would be able to do it quicker especially if I was searching a server with a lot of updates so I thought I would create a function to answer the  question Is this update installed on that server

It is very similar to [Show-WindowsUpdatesLocal](https://blog.robsewell.com/?p=480) but does not include the Title or Description on the grounds that if you are searching for it you should know those!!

It also only adds the output to the collection if the KB is in the HotFixID property as shown below

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image109.png)](https://blog.robsewell.com/assets/uploads/2013/09/image109.png)

If we use [Measure-Command](http://blogs.msdn.com/b/rob/archive/2013/04/19/measuring-how-long-commands-take-in-windows.aspx) to compare the two we can see

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image110.png)](https://blog.robsewell.com/assets/uploads/2013/09/image110.png)

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image111.png)](https://blog.robsewell.com/assets/uploads/2013/09/image111.png)

From 3.89 seconds on my poor overworked machine to 1.79 seconds 🙂

You can find the code here

    #############################################################    ########
    #
    # NAME: Search-WindowsUpdatesLocal.ps1
    # AUTHOR: Rob Sewell https://blog.robsewell.com
    # DATE:22/09/2013
    #
    # COMMENTS: Load function to show search for windows updates     by KB locally
    #
    # USAGE: Search-WindowsUpdatesLocal KB2792100|Format-Table     -AutoSize -Wrap
    #    
    
    Function Search-WindowsUpdatesLocal ([String] $Search) {
        $Search = $Search + "\d*" 
        $Searcher = New-Object -comobject Microsoft.Update.    Searcher
        $History = $Searcher.GetTotalHistoryCount()
        $Updates = $Searcher.QueryHistory(1, $History)
        # Define a new array to gather output
        $OutputCollection = @()
        Foreach ($update in $Updates) {
            $Result = $null
            Switch ($update.ResultCode) {
                0 { $Result = 'NotStarted'}
                1 { $Result = 'InProgress' }
                2 { $Result = 'Succeeded' }
                3 { $Result = 'SucceededWithErrors' }
                4 { $Result = 'Failed' }
                5 { $Result = 'Aborted' }
                default { $Result = $_ }
            }
            $string = $update.title
            $SearchAnswer = $string | Select-String -Pattern     $Search | Select-Object { $_.Matches } 
            $output = New-Object -TypeName PSobject
            $output | add-member NoteProperty “Date” -value     $Update.Date
            $output | add-member NoteProperty “HotFixID” -value     $SearchAnswer.‘ $_.Matches ‘.Value
            $output | Add-Member NoteProperty "Result" -Value     $Result
            if ($output.HotFixID) {
                $OutputCollection += $output
            }
        }
        $OutputCollection
    }
