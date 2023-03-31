---
title: "Enabling Cortana for dbareports PowerBi"
categories:
  - Blog

tags:
  - cortana
  - dbareports
  - dbatools
header: 
  teaser: assets/uploads/2016/11/cortana-search-2.png
---
Last week at the Birmingham user group I gave a presentation about PowerShell and SQL Server

[![saved-image-from-tweetium-8](/assets/uploads/2016/11/saved-image-from-tweetium-8.jpg)](/assets/uploads/2016/11/saved-image-from-tweetium-8.jpg)

It was a very packed session as I crammed in the [new sqlserver module](https://blogs.technet.microsoft.com/dataplatforminsider/2016/06/30/sql-powershell-july-2016-update/), [dbatools](https://dbatools.io) and [dbareports](https://dbareports.io) 🙂 On reflection I think this is a bit too much for a one hour session but at the end of the session I demo’d live Cortana using the dbareports dataset and returning a Cortana PowerBi page.

As always it took a couple of goes to get it right but when it goes correctly it is fantastic. I call it a salary increasing opportunity! Someone afterwards asked me how it was done so I thought that was worth a blog post

There is a video below but the steps are quite straightforward.

Add Cortana Specific Pages
--------------------------

Whilst you can just enable Cortana to access your dataset, as shown later in this post, which enables Cortana to search available datasets and return an appropriate visualisation it is better to provide specific pages for Cortana to use and display. You can do this in PowerBi Desktop

Start by adding a new page in your report by clicking on the plus button

[![add page.PNG](/assets/uploads/2016/11/add-page.png)](/assets/uploads/2016/11/add-page.png)

and then change the size of the report page by clicking on the paintbrush icon in the visualisation page.

[![page-size](/assets/uploads/2016/11/page-size.png)](/assets/uploads/2016/11/page-size.png)

This creates a page that is optimised for Cortana to display and also will be the first place that Cortana will look to answer the question

> Power BI first looks for answers in [Answer Pages](https://powerbi.microsoft.com/en-us/documentation/powerbi-service-cortana-desktop-entity-cards/) and then searches your datasets and reports for other answers and displays them in the form of visualizations. The highest-scoring results display first as _best matches_, followed by links to other possible answers and applications. Best matches come from Power BI Answer Pages or Power BI reports.

Rename the page so that it contains the words or phrase you expect to be in the question such as “Servers By Version” You will help Cortana and PowerBi to get your results better if you use some of the column names in your dataset

Then it is just another report page and you can add visualisations just like any other page

[![cortana page.PNG](/assets/uploads/2016/11/cortana-page.png)](/assets/uploads/2016/11/cortana-page.png)

Make Cortana work for you and your users
----------------------------------------

If your users are likely to use a number of different words in their questions you can assist Cortana to find the right answer by adding alternate names. So maybe if your page is sales by store you might add shop, building, results, amount, orders. This is also useful when Cortana doesn’t understand the correct words as you will notice in the screenshot below I have added “service” for “servers” and “buy” for “by” to help get the right answer. You can add these alternate words by clicking the paintbrush under visualisations and then Page Information

[![cortana-additional](/assets/uploads/2016/11/cortana-additional.png)](/assets/uploads/2016/11/cortana-additional.png)

Publish your PBIX file to PowerBi.com
-------------------------------------

To publish your PowerBi report to [PowerBi.com](https://powerbi.com) either via the Publish button in [PowerBi desktop](http://go.microsoft.com/fwlink/?LinkID=521662)

[![publish](/assets/uploads/2016/11/publish.png)](/assets/uploads/2016/11/publish.png)

or by using the [PowerBiPS module](https://github.com/DevScope/powerbi-powershell-modules)
```
 Install-Module -Name PowerBIPS  
 #Grab the token, will require a sign in  
 $authToken = Get-PBIAuthToken –Verbose  
 Import-PBIFile –authToken $authToken –filePath “Path to PBIX file” –verbose
```
Enable Cortana
--------------

In your browser log into [https://powerbi.com](https://powerbi.com) and then click on the cog and then settings

[![powerbicom.PNG](/assets/uploads/2016/11/powerbicom.png)](/assets/uploads/2016/11/powerbicom.png)

then click on Datasets

[![settings](/assets/uploads/2016/11/settings.png)](/assets/uploads/2016/11/settings.png)

Then choose the dataset – in this case dbareports SQL Information sample and click the tick box to Allow Cortana to access the this dataset and then click apply

[![dataset settings.PNG](/assets/uploads/2016/11/dataset-settings.png)](/assets/uploads/2016/11/dataset-settings.png)

Use Cortana against your PowerBi data
-------------------------------------

You can type into the Cortana search box and it will offer the opportunity for you to choose your PowerBi data

[![cortana-search](/assets/uploads/2016/11/cortana-search.png)](/assets/uploads/2016/11/cortana-search.png)

but it is so much better when you let it find the answer 🙂

[![cortana-search-1](/assets/uploads/2016/11/cortana-search-11.png)](/assets/uploads/2016/11/cortana-search-11.png)

and if you want to go to the PowerBi report there is a handy link at the bottom of the Cortana page

[![cortana-search-2](/assets/uploads/2016/11/cortana-search-2.png)](/assets/uploads/2016/11/cortana-search-2.png)

I absolutely love this, I was so pleased when I got it to work and the response when I show people is always one of wonder for both techies and none-techies alike

The conditions for Cortana to work
----------------------------------

You will need to have added your work or school Microsoft ID to the computer or phone that you want to use Cortana on and that account must be able to access the dataset either because it is the dataset owner or because a dashboard using that dataset has been shared with that account.

**[From this page on PowerBi.com](https://powerbi.microsoft.com/en-us/documentation/powerbi-service-cortana-enable/)**

> When a new dataset or custom Cortana Answer Page is added to Power BI and enabled for Cortana it can take up to 30 minutes for results to begin appearing in Cortana. Logging in and out of Windows 10, or otherwise restarting the Cortana process in Windows 10, will allow new content to appear immediately.

It’s not perfect!
-----------------

When you start using Cortana to query your data you will find that at times it is very frustrating. My wife was in fits of giggles listening to me trying to record the video below as Cortana refused to understand that I was saying “servers” and repeatedly searched Bing for “service” Whilst you can negate the effect by using the alternate names for the Q and A settings it is still a bit hit and miss at times.

It is amazing
-------------

There is something about giving people the ability to just talk to their device in a meeting and for example with dbareports ask

> Which clients are in Bolton

or

> When was the last backup for client The Eagles

and get the information they require and a link to the report in PowerBi.com. I am certain that the suits will be absolutely delighted at being able to show off in that way which is why I call it a salary increasing opportunity 🙂

We would love YOU to come and join us at the SQL Community Collaborative
------------------------------------------------------------------------

Help us make `dbatools`, `dbareports` and `Invoke-SQLCmd2` even better. You can join in by forking the repos in GitHub and writing your code and then performing a PR but we would much rather that you came and discussed new requests in our Trello boards, raised issues in GitHub and generally discussed the modules in the SQL Server Community Slack `#dbatools` `#dbareports`. We are also looking for assistance with our wiki pages, Pester tests and appveyor integration for our builds and any comments people want to make

[SQL Server Collaborative GitHub Organisation holding the modules.](https://github.com/sqlcollaborative/) Go here to raise issues, fork the repositories or download the code

[dbatools Trello for discussion about new cmdlets](https://dbatools.io/trello)

[SQL Server Community Slack](https://dbatools.io/slack) where you can find #dbatools and #dbareports as well as over 1100 people discussing all aspects of the Data Platform, events, jobs, presenting

COME AND JOIN US






















