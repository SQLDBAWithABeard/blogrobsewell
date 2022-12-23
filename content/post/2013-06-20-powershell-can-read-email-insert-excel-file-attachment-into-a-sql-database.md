---
title: "Powershell can read email & insert excel file attachment into a SQL Database"
categories:
  - Blog

tags:
  - Excel
  - outlook
  - PowerShell

---
So at our SQL SouthWest User Group session last week we had sessions from Jonathan [@fatherjack](https://twitter.com/fatherjack) and Annette [@Mrsfatherjack](https://twitter.com/Mrsfatherjack)  on SSRS and SSIS respectively. During Annettes SSIS session a question was asked about reading email attachments and then loading them into a database. No-one had an answer using SSIS but I said it could be done with Powershell . So I have written the following script.

What it does is open an Outlook com object, search for an email with a certain subject and save it in the temp folder and then import it into a SQL database. This needs to be done on a machine with Outlook and Excel installed. It is possible to process the email using EWS in an Exchange environment and other people have written scripts to do so.

It uses two functions Out-Datatable from [http://gallery.technet.microsoft.com/scriptcenter/4208a159-a52e-4b99-83d4-8048468d29dd](http://gallery.technet.microsoft.com/scriptcenter/4208a159-a52e-4b99-83d4-8048468d29dd)

and Write-Datatable from

[http://gallery.technet.microsoft.com/scriptcenter/2fdeaf8d-b164-411c-9483-99413d6053ae](http://gallery.technet.microsoft.com/scriptcenter/2fdeaf8d-b164-411c-9483-99413d6053ae)

The first takes the output from parsing the Excel File and converts it into a datatable object which can then be piped to the second which uses the BulkCopy method. Alternatively if you require it you could add each row of the excel file to an array and then use Invoke-SQLCmd to insert the data row by row.

    while($row1 -le
    $lastusedrange) {
    $Col1 = $ws.Cells.Item($row1,1).Value2
    $Col2 = $ws.Cells.Item($row1,2).Value2 
    $Col3 = $ws.Cells.Item($row1,3).Value2
    $query = "INSERT INTO Database.Schema.Table
         (Column1
         ,Column2
         ,Column3 )
         VALUES
         ('$Col1'
         ,'$Col2'
         ,'$Col3')
    GO
    "
    $dt = invoke-sqlcmd -query $query -ServerInstance $Server -database $database
    ## For Testing Write-Host $query

  

    #############################################################################################
    #
    # NAME: ExcelEmailAttachmentToDatabase.ps1
    # AUTHOR: Rob Sewell http://newsqldbawiththebeard.wordpress.com
    # DATE:15/06/2013
    #
    # COMMENTS: This script will read your email using outlook com object and save Excel Attachment 
    # and import it into a database
    # REQUIRES: It uses two functions Out-Datatable from 
    # http://gallery.technet.microsoft.com/scriptcenter/4208a159-a52e-4b99-83d4-8048468d29dd 
    # and Write-Datatable from
    # http://gallery.technet.microsoft.com/scriptcenter/2fdeaf8d-b164-411c-9483-99413d6053ae 
    #
    # ------------------------------------------------------------------------
    
    # Create Outlook Object
    Add-type-assembly "Microsoft.Office.Interop.Outlook"|out-null
    
    $olFolders = "Microsoft.Office.Interop.Outlook.olDefaultFolders" -as [type]
    $outlook = new-object -comobject outlook.application
    $namespace = $outlook.GetNameSpace("MAPI")
    
    # Set Folder to Inbox
    $folder = $namespace.getDefaultFolder($olFolders::olFolderInBox)
    # CHeck Email For Subject and set to variable 
    $Email = $folder.items | Where-Object Subject -Contains $Subject
    
    $Attachments = $Email.Attachments
    $filepath = $env:TEMP
    $filename = "TestFilename.xlsx"
    $Subject = "This is a Test"
    $server = 'test server'
    $Database = 'Test Database'
    $Table = 'tbl_DataloadTest'
    
    foreach ($Attachment in $Attachments) {
        $attachName = $Attachment.filename
        If
        ($attachName.Contains("xlsx")) {
    
            $Attachment.saveasfile((Join-Path $filepath $filename)) 
        }  
    }
    
    # Create an Excel Object
    
    $xl = New-Object -comobject Excel.Application
    &lt;# 
    ##For testing 
    $xl.visible = $true
    #&gt;
    # Open the File
    $wb = $xl.WorkBooks.Open("$filepath\$filename")
    $ws = $wb.Worksheets.Item(1)
    
    # If your data does not start at A1 you may need
    $column1 = 1
    $row1 = 2
    $lastusedrange = $ws.UsedRange.Rows.Count
    
    $dt = @()
    while ($row1 -le $lastusedrange) {
        $Col1 = $ws.Cells.Item($row1, 1).Value2
        $Col2 = $ws.Cells.Item($row1, 2).Value2
        $Col3 = $ws.Cells.Item($row1, 3).Value2
    
        $newrow = ($Col1, $col2, $col3)
        $dt += $newrow
    
        # Move to next row
        $row1 = $row1 + 1
    }
    $xl.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($xl)
    
    $Input = $dt|Out-DataTable
    Write-DataTable -ServerInstance $server -Database $Database -TableName $Table -Data $Input


Visit your own User Group – You can find them here[http://www.sqlpass.org/](http://www.sqlpass.org/)

If you are in the South West UK then come and join our group. Free training and conversation with like minded people once a month and pizza too what could be better!!

