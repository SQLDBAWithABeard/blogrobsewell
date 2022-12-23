---
title: "PowerShell in SQL Notebooks in Azure Data Studio"
date: "2019-07-17" 
categories:
  - Blog
  - Jupyter Notebooks
  - Azure Data Studio
  - PowerShell
  - dbachecks
  - dbatools

tags:
  - dbachecks
  - dbatools
  - dbatoolsmol
  - markdown
  - PowerShell
  - Jupyter Notebooks
  - Azure Data Studio
  - SQL Notebooks
  - Glenn Berry
  - Diagnostic Notebooks


image: assets/uploads/2019/07/image-4.png

---
I have done a lot of writing in the last few months but you see no blog posts! My wonderful friend Chrissy and I are writing “dbatools in a Month of Lunches” to be published by Manning. That has taken up a lot of my writing mojo. We have hit a little break whilst we have some reviews done ready for the [MEAP](https://www.manning.com/meap-program) (For everyone who asks, the answer is the unfulfilling ‘soon’) so it’s time for a blog post!

SQL Notebooks are cool
----------------------

I have had a lot of fun with SQL Notebooks recently. I have presented a session about them at a couple of events this month [DataGrillen](http://datagrillen.com) and SQL Saturday Cork. Here is a little snippet

> [#dbatools](https://twitter.com/hashtag/dbatools?src=hash&ref_src=twsrc%5Etfw) in PowerShell in [@AzureDataStudio](https://twitter.com/AzureDataStudio?ref_src=twsrc%5Etfw) SQL Notebooks for creating the containers and restoring the [#dbachecks](https://twitter.com/hashtag/dbachecks?src=hash&ref_src=twsrc%5Etfw) historical database for running queries in 🙂  
> Getting ready for presentation for [#DataGrillen](https://twitter.com/hashtag/DataGrillen?src=hash&ref_src=twsrc%5Etfw) [pic.twitter.com/wiQ41bblQV](https://t.co/wiQ41bblQV)
> 
> — Rob Sewell (@sqldbawithbeard) [May 21, 2019](https://twitter.com/sqldbawithbeard/status/1130871277449875456?ref_src=twsrc%5Etfw)

Yes, you can run PowerShell in a SQL Notebook in Azure Data Studio just by clicking a link in the markdown cell. This opens up a lot of excellent possibilities.

I have had several discussions about how SQL Notebooks can be used by SQL DBAs within their normal everyday roles. (Mainly because I don’t really understand what the sorcerers of data science do with notebooks!). I have helped clients to look at some of their processes and use SQL Notebooks to help with them. Creating Disaster Recovery or Change Run-books or Incident Response Templates or using them for product demonstrations. Of course, I needed to use PowerShell in that 🙂

I have really enjoyed working out how to run PowerShell in the markdown in a SQL Notebook in Azure Data Studio and I think [Anthony the kubernetes magician](http://www.centinosystems.com/blog/author/aencentinosystems-com/) did too!

> I think [@sqldbawithbeard](https://twitter.com/sqldbawithbeard?ref_src=twsrc%5Etfw) is an actual wizard! You should see the things he can do with [@AzureDataStudio](https://twitter.com/AzureDataStudio?ref_src=twsrc%5Etfw) [#DataGrillen](https://twitter.com/hashtag/DataGrillen?src=hash&ref_src=twsrc%5Etfw) [pic.twitter.com/KMeZR3CrPK](https://t.co/KMeZR3CrPK)
> 
> — Anthony E. Nocentino (@nocentino) [June 20, 2019](https://twitter.com/nocentino/status/1141709511700467712?ref_src=twsrc%5Etfw)

OK enough magic puns lets talk about PowerShell in SQL Notebooks. You can read about [how to create a SQL Notebook and run T-SQL queries here](https://blog.robsewell.com/whats-a-sql-notebook-in-azure-data-studio/), (you no longer need the Insider Edition by the way)

PowerShell in Markdown!
-----------------------

First, before I go any further, I must say this. I was at the European PowerShell Conference when I was working this out and creating my sessions and I said the words

> “Cool, I can click a link and run PowerShell, this is neat”
> 
> A Beardy fellow in Hannover

This stopped some red team friends of mine in their tracks and they said “Show me”. One of them was rubbing their hands with glee! You can imagine the sort of wicked, devious things that they were immediately considering doing.

![](https://blog.robsewell.com/assets/uploads/2019/07/image-3.png)

Yes, it’s funny but also it carries a serious warning. Without understanding what it is doing, please don’t enable PowerShell to be run in a SQL Notebook that someone sent you in an email or you find on a GitHub. In the same way as you don’t open the word document attachment which will get a thousand million trillion europounddollars into your bank account or run code you copy from the internet on production without understanding what it does, this could be a very dangerous thing to do.

With that warning out of the way, there are loads of really useful and fantastic use cases for this. SQL Notebooks make great run-books or incident response recorders and PowerShell is an obvious tool for this. (If only we could save the PowerShell output in a SQL Notebook, this would be even better)

How on earth did you work this out?
-----------------------------------

Someone asked me how I worked it out. I didn’t! It began with Vicky Harp PM lead for the SQL Tools team at Microsoft

> Did you know you can add markdown links to open a terminal and paste in a command in [@AzureDataStudio](https://twitter.com/AzureDataStudio?ref_src=twsrc%5Etfw) notebooks? [pic.twitter.com/YHX9pIVQco](https://t.co/YHX9pIVQco)
> 
> — Vicky Harp (@vickyharp) [May 14, 2019](https://twitter.com/vickyharp/status/1128359827128950784?ref_src=twsrc%5Etfw)

I then went and looked at [Kevin Cunnane](https://twitter.com/kevcunnane)‘s notebook. Kevin is a member of the tools team working on Azure Data Studio. With SQL Notebooks, you can double click the markdown cell and see the code that is behind it. To understand how it is working, lets deviate a little.

Keyboard Shortcuts
------------------

IF you click the cog at the bottom left of Azure Data Studio and choose Keyboard Shortcuts

![](https://blog.robsewell.com/assets/uploads/2019/07/image.png)

you can make Azure Data Studio (and Visual Studio Code) work exactly how you want it to. Typing in the top box will find a command and you can then set the shortcuts that you want to use to save yourself time.

![](https://i1.wp.com/user-images.githubusercontent.com/6729780/59566321-84233d80-9056-11e9-9643-e9e15e85a2f0.png?w=630&ssl=1)](https://i1.wp.com/user-images.githubusercontent.com/6729780/59566321-84233d80-9056-11e9-9643-e9e15e85a2f0.png?ssl=1)

This also enables you to see the command that is called when you use a keyboard shortcut. For example, you can see that for the focus terminal command it says `workbench.action.terminal.focus`.

It turns out that you can call this as a link in a Markdown document using HTML with `<a href="">` and adding `command:` prior to the command text. When the link is clicked the command will run. Cool 🙂

For this to be able to work (you read the warning above?) you need to set the Notebook to be trusted by clicking this button.

![](https://i0.wp.com/user-images.githubusercontent.com/6729780/59566360-365b0500-9057-11e9-87fb-1f8cbbb6e9e2.png?w=630&ssl=1)](https://i0.wp.com/user-images.githubusercontent.com/6729780/59566360-365b0500-9057-11e9-87fb-1f8cbbb6e9e2.png?ssl=1)

This will allow any command to be run. Of course, people with beards will helpfully advise when this is required for a [SQL Notebook](https://github.com/SQLDBAWithABeard/Presentations/blob/master/2019/Berlin%20SQL%20User%20Group/05%20-Working%20with%20dbachecks%20Validation%20Results.ipynb). (Safe to say people attempting nefarious actions will try the same with your users)

![](https://blog.robsewell.com/assets/uploads/2019/07/image-1.png)

Now that we know how to run an Azure Data Studio command using a link in a markdown cell the next step is to run a PowerShell command. I headed to the [Visual Studio Code documentation](https://code.visualstudio.com/docs/editor/integrated-terminal) and found

> Send text from a keybinding  
> The `workbench.action.terminal.sendSequence` command can be used to send a specific sequence of text to the terminal, including escape sequence

That’s the command we need, however, we still need to craft the command so that it will work as a link. It needs to be converted into a URL.

I started by using this website [https://www.url-encode-decode.com/](https://www.url-encode-decode.com/) to do this. This is **how you can check the code in other peoples notebook, use the decode capability.**

Encoding `Set-Location C:\dbachecks` gives `Set-Location+C%3A%5Cdbacheck``

![](https://i0.wp.com/user-images.githubusercontent.com/6729780/59567164-e5044300-9061-11e9-802b-7b28c3aee345.png?w=630&ssl=1)

So I can just put that code into the href link and bingo!

If only it was that easy!!

Some Replacing is required
--------------------------

The + needs to be replaced with a space or `%20`

You also need to double the `\` and replace the `%3A` with a `:`  
The `"` needs to be replaced with `\u022`, the `'` with `\u027`, the curly braces won’t work unless you remove the `%0D%0A`. Got all that? Good!

Once you have written your PowerShell, encoded it, performed the replacements, you add `\u000D` at the end of the code to pass an enter to run the code and then place all of that into a link like this

`<a href="command:workbench.action.terminal.sendSequence?%7B%22text%22%3A%22 PLACE THE ENCODED CODE HERE %22%7D">Link Text</a>`

This means that if you want to add the PowerShell code to set a location and then list the files and folders in that location to a Markdown cell using PowerShell like this

    Set-Location C:\dbachecks
    Get-ChildItem

You would end up with a link like this

`` `<a href="command:workbench.action.terminal.sendSequence?%7B%22text%22%3A%22 Set-Location C:%5C%5Cdbachecks \u000D Get-ChildItem \u000D %22%7D">Set Location and list files</a` ``>

Doing something more than once?
-------------------------------

I don’t want to remember that all of the time so I wrote a PowerShell function. You can find it on GitHub [https://github.com/SQLDBAWithABeard/Functions/blob/master/Convert-ADSPowerShellForMarkdown.ps1](https://github.com/SQLDBAWithABeard/Functions/blob/master/Convert-ADSPowerShellForMarkdown.ps1)

This will take a PowerShell command and turn it into a link that will work in an Azure Data Studio markdown. It’s not magic, it’s PowerShell. There is a –`ToClipboard` parameter which will copy the code to the clipboard ready for you to paste into the cell (On Windows machines only)

Giants
------

There are many uses for this but here’s one I think is cool.

The link below will go to a notebook, which will show how you the giants upon whose shoulders I stand  
  
[Glenn Berry](https://twitter.com/GlennAlanBerry),  
[Chrissy LeMaire](https://twitter.com/cl),  
[André](https://twitter.com/AndreKamman) [Kamman](https://twitter.com/AndreKamman),  
[Gianluca Sartori](https://twitter.com/spaghettidba)  
  
have enabled me to create a SQL Notebook with a link which will run some PowerShell to create a SQL Notebook which will have all of the Diagnostic Queries in it.

You could possibly use something like it for your incident response SQL Notebook.

It’s also cool that GitHub renders the notebook in a browser (You can’t run PowerShell or T-SQL from there though, you need Azure Data Studio!)

[https://github.com/SQLDBAWithABeard/Presentations/blob/master/2019/Berlin%20SQL%20User%20Group/04%20-%20Glenn%20Berry%20Notebook.ipynb](https://github.com/SQLDBAWithABeard/Presentations/blob/master/2019/Berlin%20SQL%20User%20Group/04%20-%20Glenn%20Berry%20Notebook.ipynb)

![](https://blog.robsewell.com/assets/uploads/2019/07/image-4.png)
