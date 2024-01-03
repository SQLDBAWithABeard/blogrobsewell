---
title: "Running SQL Queries with Visual Studio Code"
date: "2017-01-05" 
categories:
  - Blog
  - Developing
  - VS Code

tags:
  - sql server


---
Reading this blog post by [Shawn Melton Introduction of Visual Studio Code for DBAs](http://www.sqlshack.com/introduction-visual-studio-code-dbas/) reminded me that whilst I use Visual Studio Code (which I shall refer to as Code from here on) for writing PowerShell and Markdown and love how easily it interacts with Github I hadn’t tried T-SQL. If you are new to Code (or if you are not) go and read Shawns blog post but here are the steps I took to running T-SQL code using Code

To download Code go to this link [https://code.visualstudio.com/download](https://code.visualstudio.com/download) and choose your operating system. Code works on Windows, Linux and Mac

![00-code-download](https://blog.robsewell.com/assets/uploads/2017/01/00-code-download.png)

Once you have downloaded and installed hit CTRL SHIFT and P which will open up the command palette

![01-ctrlshiftp](https://blog.robsewell.com/assets/uploads/2017/01/01-ctrlshiftp.png)

Once you start typing the results will filter so type ext and then select Extensions : Install Extension

![02-extensions](https://blog.robsewell.com/assets/uploads/2017/01/02-extensions.png)

Which will open the Extensions tab ( You could have achieved the same end result just by clicking this icon)

![03-install-extensions](https://blog.robsewell.com/assets/uploads/2017/01/03-install-extensions.png)

But then you would not have learned about the command palette 🙂

So, with the extensions tab open, search for mssql and then click install

![04-search-mssql](https://blog.robsewell.com/assets/uploads/2017/01/04-search-mssql.png)

Once it has installed the button will change to Reload so click it

![05-reload](https://blog.robsewell.com/assets/uploads/2017/01/05-reload.png)

And you will be prompted to Reload the window

![06-reload-prompt](https://blog.robsewell.com/assets/uploads/2017/01/06-reload-prompt.png)

Accept the prompt and then open a new file (CTRL N) and then change the language for the file.

You can do this by clicking CTRL K and then M (Not CTRL K CTRL M) or click the language button

![07-choose-langauga](https://blog.robsewell.com/assets/uploads/2017/01/07-choose-langauga.png)

And then choose SQL

![08-choose-sql](https://blog.robsewell.com/assets/uploads/2017/01/08-choose-sql.png)

This will start a download so make sure you are connected (and allowed to connect to the internet)

![09-start-download](https://blog.robsewell.com/assets/uploads/2017/01/09-start-download.png)

Once it has finished it will show this

![10-finished-downloading](https://blog.robsewell.com/assets/uploads/2017/01/10-finished-downloading.png)

And offer you the chance to read the release notes

![11-release-notes](https://blog.robsewell.com/assets/uploads/2017/01/11-release-notes.png)

Which you can get for any extension anytime by finding the extension in the extensions tab and clicking on it. This has links to tutorials as well as information about the release

![12-release-notes](https://blog.robsewell.com/assets/uploads/2017/01/12-release-notes.png)

The mssql extension enables Intellisence for T-SQL when you open a .sql file or when you change the language to SQL as shown above for a new file

![13-intellisense](https://blog.robsewell.com/assets/uploads/2017/01/13-intellisense.png)

Write your T-SQL Query and press CTRL SHIFT and E or Right Click and choose Execute Query. This will ask you to choose a Connection Profile (and display any existing profiles)

![14-execute](https://blog.robsewell.com/assets/uploads/2017/01/14-execute.png)

Choose Create Connection Profile and answer the prompts

![15-enter-servername](https://blog.robsewell.com/assets/uploads/2017/01/15-enter-servername.png)

The query will then run

![16-query-runs](https://blog.robsewell.com/assets/uploads/2017/01/16-query-runs.png)

You can then output the results to csv or json if you wish

![17-results](https://blog.robsewell.com/assets/uploads/2017/01/17-results.png)

You can find a video showing this whole process with some typos and an error here

[Using SQL with VS Code](https://youtu.be/_qTNKohFzPE)
