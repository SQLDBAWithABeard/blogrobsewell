---
title: "Whats a SQL Notebook in Azure Data Studio?"
date: "2019-03-13" 
categories:
  - dbatools
  - dbachecks
  - Blog
  - Jupyter Notebooks
  - Azure Data Studio
  - PowerShell

tags:
  - dbachecks
  - dbatools
  - GitHub 
  - Notebooks
  - Jupyter Notebooks
  - Azure Data Studio


image: /assets/uploads/2019/03/image-7.png
---
[Azure Data Studio](https://docs.microsoft.com/en-us/sql/azure-data-studio/download?view=sql-server-2017?WT.mc_id=DP-MVP-5002693) is a cross-platform database tool for data professionals using the Microsoft family of on-premises and cloud data platforms on Windows, MacOS, and Linux.

Recently Vicky Harp tweeted

> We're getting very close to release of SQL Notebooks in [@AzureDataStudio](https://twitter.com/AzureDataStudio?ref_src=twsrc%5Etfw)! You can give the feature an early spin today with the insider build. [pic.twitter.com/SEZp7ZdxCp](https://t.co/SEZp7ZdxCp)
> 
> — Vicky Harp (@vickyharp) [March 8, 2019](https://twitter.com/vickyharp/status/1104127412944551936?ref_src=twsrc%5Etfw)

By the way, you can watch a recording from SQLBits of Vicky’s session

> If you missed [#sqlbits](https://twitter.com/hashtag/sqlbits?src=hash&ref_src=twsrc%5Etfw), you will definitely want to watch this demo by [@vickyharp](https://twitter.com/vickyharp?ref_src=twsrc%5Etfw) and [@MGoCODE](https://twitter.com/MGoCODE?ref_src=twsrc%5Etfw) about [@AzureDataStudio](https://twitter.com/AzureDataStudio?ref_src=twsrc%5Etfw). Learn the latest about our cross-platform tool, including a new feature, SQL Notebooks [#SQLServer](https://twitter.com/hashtag/SQLServer?src=hash&ref_src=twsrc%5Etfw) [https://t.co/diubYwQckn](https://t.co/diubYwQckn)
> 
> — Azure Data Studio (@AzureDataStudio) [March 7, 2019](https://twitter.com/AzureDataStudio/status/1103806327065722880?ref_src=twsrc%5Etfw)

So in the interest of learning about something new I decided to give it a try.

Install The Insiders Edition
----------------------------
Unlike [Visual Studio Code](https://code.visualstudio.com/) which has a link to the insiders download on the front page, you will have to [visit the GitHub repository for the links to download the insiders release of Azure Data Studio](https://github.com/Microsoft/azuredatastudio#azure-data-studio). Scroll down and you will see

Try out the latest insiders build from `master`:

*   [Windows User Installer – **Insiders build**](https://azuredatastudio-update.azurewebsites.net/latest/win32-x64-user/insider)
*   [Windows System Installer – **Insiders build**](https://azuredatastudio-update.azurewebsites.net/latest/win32-x64/insider)
*   [Windows ZIP – **Insiders build**](https://azuredatastudio-update.azurewebsites.net/latest/win32-x64-archive/insider)
*   [macOS ZIP – **Insiders build**](https://azuredatastudio-update.azurewebsites.net/latest/darwin/insider)
*   [Linux TAR.GZ – **Insiders build**](https://azuredatastudio-update.azurewebsites.net/latest/linux-x64/insider)

See the [change log](https://github.com/Microsoft/azuredatastudio/blob/master/CHANGELOG.md) for additional details of what’s in this release.
Once you have installed you can connect to an instance, right click and choose New Notebook or you can use File – New Notebook
![](https://blog.robsewell.com/assets/uploads/2019/03/image.png)

Incidentally, I use the [docker-compose file here](https://github.com/SQLDBAWithABeard/DockerStuff/tree/master/dbatools-2-instances-AG) to create the containers and I map `C:\MSSQL\BACKUP\KEEP` on my local machine (where my backups are) to `/var/opt/mssql/backups` on the containers on lines 10 and 17 of the docker-compose so change as required . If you want to follow along then put the ValidationResults.bak in the folder on your local machine.  
The `Create-Ag.ps1` shows the code and creates an AG with [dbatools.](http://dbatools.io) But I digress!

Install Notebook Dependencies
-----------------------------
Once you click New Notebook you will get a prompt to install the dependencies.

![](https://blog.robsewell.com/assets/uploads/2019/03/image-1.png)

It will show its output

![](https://blog.robsewell.com/assets/uploads/2019/03/image-2.png)

and take a few minutes to run

![](https://blog.robsewell.com/assets/uploads/2019/03/image-3.png)

It took all but 11 minutes on my machine

![](https://blog.robsewell.com/assets/uploads/2019/03/image-4.png)

Create a Notebook
-----------------
OK, so now that we have the dependencies installed we can create a notebook. I decided to use the ValidationResults database that [I use for my dbachecks demos and describe here](https://blog.robsewell.com/dbachecks-save-the-results-to-a-database-for-historical-reporting/). I need to restore it from my local folder that I have mapped as a volume to my container. Of course, I use dbatools for this 🙂

    # U: sqladmin P: dbatools.IO
    $cred = Get-Credential
    $restoreDbaDatabaseSplat = @{
        SqlInstance = $sqlinstance1
        SqlCredential = $cred
        UseDestinationDefaultDirectories = $true
        Path = '/var/opt/mssql/backups/ValidationResults.bak'
    }
    Restore-DbaDatabase @restoreDbaDatabaseSplat

I had already got a connection saved to the instance in Azure Data Studio, you may need to create a new one using the new connection icon at the top left and filling in the details. The password is in the code above.

![](https://blog.robsewell.com/assets/uploads/2019/03/image-5.png)

Now I can start with my notebook. I am faced with this

![](https://blog.robsewell.com/assets/uploads/2019/03/image-6.png)

I click on text and provide an intro

![](https://blog.robsewell.com/assets/uploads/2019/03/image-7.png)

Once I had written that and clicked out, I couldn’t see what to do straight away!

![](https://blog.robsewell.com/assets/uploads/2019/03/image-8.png)

Then I saw the code and text buttons at the top 🙂 Right, lets get on with it 🙂 I hit the code button and paste in the T-SQL to reset the dates in the database to simulate dbachecks having been run this morning.

![](https://blog.robsewell.com/assets/uploads/2019/03/image-9.png)
There’s a run cell button on the right and when I press it><FIGURE class=wp-block-video><VIDEO src="https://blog.robsewell.com/wp-content/uploads/2019/03/Notebook-run-query.mp4" controls></VIDEO></FIGURE>
Cool 🙂

If the SQL query has results then they are shown as well

![](https://blog.robsewell.com/assets/uploads/2019/03/image-10.png)

![](https://blog.robsewell.com/assets/uploads/2019/03/image-11.png)

This is fun and I can see plenty of uses for it. Go and have a play with SQL notebooks 🙂

Source Control
--------------

I used CTRL K, CTRL O to open a folder and saved my notebook in my local Presentations folder which is source controlled. When I opened the explorer CTRL + SHIFT + E I can see that the folder and the file are colour coded green and have a U next to them marking them as Untracked. I can also see that the source control icon has a 1 for the number of files with changes and in the bottom left that I am in the master branch.

![](https://blog.robsewell.com/assets/uploads/2019/03/image-12.png)

If I click on the source control icon (or CTRL + SHIFT + G) I can see the files with the changes and can enter a commit message

![](https://blog.robsewell.com/assets/uploads/2019/03/image-13.png)

I then press CTRL + ENTER to commit my change and get this pop-up

![](https://blog.robsewell.com/assets/uploads/2019/03/image-14.png)

As I only have one file and it has all the changes for this commit I click yes. If I had changed more than one file and only wanted to commit a single one at a time I would hover my mouse over the file and click the + to stage my change.

![](https://blog.robsewell.com/assets/uploads/2019/03/image-15.png)

If I make a further change to the notebook and save it, I can see that the source control provider recognises the change but this time the folder the file is in and the file are colour coded brown with an M to show that they have been modified.

![](https://blog.robsewell.com/assets/uploads/2019/03/image-16.png)

Unlike Visual Studio Code, when you then click on the source control icon and click on the change it does not show the differences in the notebook although this works with SQL files.

![](https://blog.robsewell.com/assets/uploads/2019/03/image-17.png)

When I have made all my changes and committed them with good commit messages

![](https://i2.wp.com/imgs.xkcd.com/comics/git_commit.png?w=630&ssl=1)

I can see that there are 3 local changes ready to be pushed to by remote repository (GitHub in this case) and 0 remote commits in this branch by looking at the bottom left

![](https://blog.robsewell.com/assets/uploads/2019/03/image-18.png)

I can click on the “roundy roundy” icon (I don't know its proper name 😊) and synchronise my changes. This comes with a pop-up

![](https://blog.robsewell.com/assets/uploads/2019/03/image-19.png)

Personally I never press OK, Don’t Show Again because I like the double check and to think “Is this really what I want to do right now”. Once I press OK my changes will be synched with the remote repository. Explaining this means that you can find the notebook I have used in my [Presentations GitHub Repository](https://github.com/SQLDBAWithABeard/Presentations/tree/master/Notebooks) which means that you can run the Notebook too using the [docker-compose file here](https://github.com/SQLDBAWithABeard/DockerStuff/tree/master/dbatools-2-instances-AG) and the instructions further up in the post.
