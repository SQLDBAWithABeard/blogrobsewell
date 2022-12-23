---
title: "Show Windows Updates Locally With PowerShell"
date: "2013-09-29" 
categories:
  - Blog

tags:
  - automation
  - PowerShell
  - Windows Updates

---
I wanted to be able to quickly show the Windows Updates on a server. This came about during a discussion about auditing.

Of course, there is no point in re-inventing the wheel so I had a quick Google and  found a couple of posts on from  [Hey Scripting Guy](http://blogs.technet.com/b/heyscriptingguy/archive/2009/03/09/how-can-i-list-all-updates-that-have-been-added-to-a-computer.aspx) blog and one from [Tim Minter](http://blogs.technet.com/b/tmintner/archive/2006/07/07/440729.aspx). Neither quite did what I wanted so I modified them as follows.

We start by creating a Update object and find the total number of updates and setting them to a variable `$History` which we pass to the `QueryHistory` Method. This enables us to show all the updates

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image100.png)](https://blog.robsewell.com/assets/uploads/2013/09/image100.png)

Passing this to `Get-Member` shows

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image101.png)](https://blog.robsewell.com/assets/uploads/2013/09/image101.png)

which doesn’t show the KB so I read a bit more and found [Tom Arbuthnot’s Blog Post](http://lyncdup.com/2013/09/list-all-microsoftwindows-updates-with-powershell-sorted-by-kbhotfixid-get-microsoftupdate/?utm_source=rss&utm_medium=rss&utm_campaign=list-all-microsoftwindows-updates-with-powershell-sorted-by-kbhotfixid-get-microsoftupdate&utm_source=feedburner&utm_medium=feed&utm_campaign=Feed%3A+LyncdUp+%28Lync%27d+Up%29)

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image102.png)](https://blog.robsewell.com/assets/uploads/2013/09/image102.png)

this transforms the `ResultCode` Property to something meaningful and places the KB in its own column.

I have created a function called `Show-WindowsUpdatesLocal` It’s Local because doing it for a remote server takes a different approach but I will show that another day.

This means you can call the function and use the results however you like

    Show-WindowsUpdatesLocal

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image103.png)](https://blog.robsewell.com/assets/uploads/2013/09/image103.png)

    Show-WindowsUpdatesLocal| Select Date, HotfixID, Result|Format-Table -AutoSize

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image104.png)](https://blog.robsewell.com/assets/uploads/2013/09/image104.png)

    Show-WindowsUpdatesLocal|Where-Object {$_.Result -eq ‘Failed’} |Select Date, HotfixID, Result,Title|Format-Table -AutoSize

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image105.png)](https://blog.robsewell.com/assets/uploads/2013/09/image105.png)

Output to file 

    Show-WindowsUpdatesLocal|Format-Table -AutoSize|Out-File c:\temp\updates.txt

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image106.png)](https://blog.robsewell.com/assets/uploads/2013/09/image106.png)

Output to CSV 

    Show-WindowsUpdatesLocal|Export-Csv c:\temp\updates.csv

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image107.png)](https://blog.robsewell.com/assets/uploads/2013/09/image107.png)

You can get the code here

    #############################################################    #########
    #
    # NAME: Show-WindowsUpdatesLocal.ps1
    # AUTHOR: Rob Sewell https://blog.robsewell.com
    # DATE:22/09/2013
    #
    # COMMENTS: Load function to show all windows updates locally
    #
    # USAGE:  Show-WindowsUpdatesLocal
    #         Show-WindowsUpdatesLocal| Select Date, HotfixID,     Result|Format-Table -AutoSize
    #         Show-WindowsUpdatesLocal|Where-Object {$_.Result     -eq 'Failed'} |Select Date, HotfixID, Result,Title|    Format-Table -AutoSize
    #         Show-WindowsUpdatesLocal|Format-Table -AutoSize|    Out-File c:\temp\updates.txt
    #         Show-WindowsUpdatesLocal|Export-Csv     c:\temp\updates.csv
    #        
    
    Function Show-WindowsUpdatesLocal {
        $Searcher = New-Object -ComObject Microsoft.Update.    Searcher
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
            $Regex = “KB\d*”
            $KB = $string | Select-String -Pattern $regex |     Select-Object { $_.Matches }
            $output = New-Object -TypeName PSobject
            $output | add-member NoteProperty “Date” -value     $Update.Date
            $output | add-member NoteProperty “HotFixID” -value     $KB.‘ $_.Matches ‘.Value
            $output | Add-Member NoteProperty "Result" -Value     $Result
            $output | add-member NoteProperty “Title” -value     $string
            $output | add-member NoteProperty “Description”     -value $update.Description
            $OutputCollection += $output
        }
        $OutputCollection
    }
