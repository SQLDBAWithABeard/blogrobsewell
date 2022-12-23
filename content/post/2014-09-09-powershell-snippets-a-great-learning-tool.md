---
title: "PowerShell Snippets A Great Learning Tool"
date: "2014-09-09" 
categories:
  - Blog

tags:
  - PowerShell
  - snippet
  - snippets
  - SMO
  - data table


image: assets/uploads/2014/09/image9.png

---
When I talk to people about Powershell they often ask how can they easily learn the syntax. Here’s a good tip

Open PowerShell ISE and press CTRL + J

[![image](https://blog.robsewell.com/assets/uploads/2014/09/image_thumb9.png)](https://blog.robsewell.com/assets/uploads/2014/09/image9.png)

You will find a number of snippets that will enable you to write your scripts easily.  Johnathan Medd PowerShell MVP has written a good post about snippets on the [Hey, Scripting Guy! blog](http://blogs.technet.com/b/heyscriptingguy/archive/2014/01/25/using-powershell-ise-snippets-to-remember-tricky-syntax.aspx) so I will not repeat that but suggest that you go and read that post. It will show you how quickly and easily you will be able to write more complex Powershell scripts as you do not have to learn the syntax but can use the snippets to insert all the code samples you require.

Not only are there default snippets for you to use but you can create your own snippets. However there isn’t a snippet for creating a new snippet so here is the code to do that

    $snippet1 = @{
     Title = 'New-Snippet'
     Description = 'Create a New Snippet'
     Text = @"
    `$snippet = @{
     Title = `'Put Title Here`'
     Description = `'Description Here`'
     Text = @`"
     Code in Here 
    `"@
    }
    New-IseSnippet @snippet
    "@
    }
    New-IseSnippet @snippet1 –Force

I frequently use the SQL Server SMO Object in my code so I created this snippet

     $snippet = @{
     Title = 'SMO-Server'
     Description = 'Creates a SQL Server SMO Object'
     Text = @"
     `$srv = New-Object Microsoft.SqlServer.Management.Smo.Server `$Server
    "@
    }
    New-IseSnippet @snippet

I also use Data Tables a lot so I created a snippet for that too

     $snippet = @{
     Title = 'New-DataTable'
     Description = 'Creates a Data Table Object'
     Text = @"
     # Create Table Object
     `$table = New-Object system.Data.DataTable `$TableName
     
     # Create Columns
     `$col1 = New-Object system.Data.DataColumn NAME1,([string])
     `$col2 = New-Object system.Data.DataColumn NAME2,([decimal])
     
     #Add the Columns to the table
     `$table.columns.add(`$col1)
     `$table.columns.add(`$col2)
     
     # Create a new Row
     `$row = `$table.NewRow() 
     
     # Add values to new row
     `$row.Name1 = 'VALUE'
     `$row.NAME2 = 'VALUE'
     
     #Add new row to table
     `$table.Rows.Add($row)
    "@
     }
     New-IseSnippet @snippet
Denniver Reining has created a [Snippet Manager](http://bytecookie.wordpress.com/snippet-manager/) which you can use to further expand your snippets usage and it is free as well.

If you have further examples of useful snippets please feel free to post them in the comments below

Edit 16/12/2014

I am proud that this article was nominated for the Tribal Awards. Please go and vote for your winners in all the categories

[http://www.sqlservercentral.com/articles/Awards/119953/](http://www.sqlservercentral.com/articles/Awards/119953/)

Personally in the article category I will be voting for

[Gail Shaw’s SQL Server Howlers](https://www.simple-talk.com/sql/database-administration/gail-shaws-sql-server-howlers/)
