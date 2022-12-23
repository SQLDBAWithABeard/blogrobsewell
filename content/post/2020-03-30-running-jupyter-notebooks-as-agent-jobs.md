---
title: "Running Jupyter Notebooks as Agent Jobs"
categories:
  - Blog
  - Jupyter Notebooks
  - Azure Data Studio
  - PowerShell

tags:
  - adsnotebook
  - automation
  - Jupyter Notebooks
  - SQL Agent Jobs
  - Azure Data Studio
  - PowerShell

header:
  teaser: /assets/uploads/2020/03/image-22.png

---
[Azure Data Studio](https://docs.microsoft.com/en-us/sql/azure-data-studio/download-azure-data-studio?view=sql-server-ver15?WT.mc_id=DP-MVP-5002693) is a great tool for connecting with your data platform whether it is in Azure or on your hardware. [Jupyter Notebooks](https://blog.robsewell.com/?s=notebooks) are fantastic, you can have words, pictures, code and code results all saved in one document.

I have created a repository in my GitHub [https://beard.media/Notebooks](https://beard.media/Notebooks) where I have stored a number of Jupyter notebooks both for Azure Data Studio and the [new .NET interactive](https://blog.robsewell.com/new-net-notebooks-are-here-powershell-7-notebooks-are-here/) notebooks.

Another thing that you can do with notebooks is run them as Agent Jobs and save the results of the run.

### Notebooks running T-SQL

This works easily for T-SQL notebooks. I am going to [use this one](https://github.com/SQLDBAWithABeard/JupyterNotebooks/blob/master/notebooks/NotDotNet/Audit/AUDIT%20-%20T-SQL%20Gather%20Permissions%20Notebook%20Template.ipynb) that I created that uses T-SQL to gather permissions using old code that was in a share somewhere. We can run the notebook and get the permissions and save the notebook and the results will be available for all time (unless you delete the notebook!)

[![](https://blog.robsewell.com/assets/uploads/2020/03/image.png?fit=630%2C327&ssl=1)](https://blog.robsewell.com/assets/uploads/2020/03/image.png?ssl=1)

### SQL Agent Extension in Azure Data Studio

In Azure Data Studio, if you press CTRL + SHIFT + X it will open the Extensions tab

[![](https://blog.robsewell.com/assets/uploads/2020/03/image-1.png?resize=188%2C300&ssl=1)](https://blog.robsewell.com/assets/uploads/2020/03/image-1.png?ssl=1)

You can add extra functionality to Azure Data Studio. Search in the top bar for Agent and press the install button to install the extension. You can connect to and instance in the connections tab (CTRL + SHIFT + D) and right click on it and click Manage. This will open up the server dashboard (why isn’t it instance dashboard?)

[![](https://blog.robsewell.com/assets/uploads/2020/03/image-2.png?fit=630%2C297&ssl=1)](https://blog.robsewell.com/7e393013-e088-4dfb-93e4-5e4961931999)

and you will also have the SQL Agent dashboard available

[![](https://blog.robsewell.com/assets/uploads/2020/03/image-3.png?fit=630%2C353&ssl=1)](https://blog.robsewell.com/assets/uploads/2020/03/image-3.png?ssl=1)

Its pretty neat, it has green and red bars against the jobs showing success or failure and the larger the bar the longer the run time. On the left you will see a book. Click that

[![](https://blog.robsewell.com/assets/uploads/2020/03/image-4.png?fit=630%2C295&ssl=1)](https://blog.robsewell.com/assets/uploads/2020/03/image-4.png?ssl=1)

### Notebooks in Agent Jobs

You can create an Agent Job to run a notebook. As a notebook is just a json file, it can be stored in a database table. This interface will create two tables one to store the templates and one for the results. Click New Notebook Job

[![](https://blog.robsewell.com/assets/uploads/2020/03/image-5.png?fit=630%2C989&ssl=1)](https://blog.robsewell.com/assets/uploads/2020/03/image-5.png?ssl=1)

Then navigate to the notebook and select it.

[![](https://blog.robsewell.com/assets/uploads/2020/03/image-6.png?fit=630%2C379&ssl=1)](https://blog.robsewell.com/d312799d-0cf7-4e9f-86ac-11c7f6e4977b)

Choose a database for the storage of the template and the results and one for the execution context.

[![](https://blog.robsewell.com/assets/uploads/2020/03/image-7.png?fit=630%2C991&ssl=1)](https://blog.robsewell.com/a70ffec6-6ed9-43f5-8b4b-b3eed86abecd)

The name of the job will be the file name of the notebook. You can change this but there is a bug where you can only enter one character at a time in the name before it changes focus so beware!

[![](https://blog.robsewell.com/assets/uploads/2020/03/image-8.png?fit=630%2C157&ssl=1)](https://blog.robsewell.com/03d25ab1-ccd9-4c8b-a880-1f6bf1641b42)

Once the job is created, you will see two tables in the storage database notebooks.nb\_materialized and notebooks.nb\_template

[![](https://blog.robsewell.com/assets/uploads/2020/03/image-9.png?fit=630%2C790&ssl=1)](https://blog.robsewell.com/assets/uploads/2020/03/image-9.png?ssl=1)

The materialised table is empty right now

[![](https://blog.robsewell.com/assets/uploads/2020/03/image-10.png?fit=630%2C405&ssl=1)](https://blog.robsewell.com/assets/uploads/2020/03/image-10.png?ssl=1)

but the template table has a row for the job which includes the notebook in json format.

[![](https://blog.robsewell.com/assets/uploads/2020/03/image-11.png?fit=630%2C218&ssl=1)](https://blog.robsewell.com/6b019c65-cd07-4295-9b8e-609456829574)

If you click on the jobs in the Notebook Jobs window in the SQL Agent extension, you can see more information about the job run

[![](https://blog.robsewell.com/assets/uploads/2020/03/image-12.png?fit=630%2C321&ssl=1)](https://blog.robsewell.com/5f93224f-b2a6-4c9c-9e71-a5f3668dcab9)

You can also run the job from here. It doesn’t have to be run from here, it is just a normal agent job which you can run or schedule in any normal manner. Running it from here gives a pop-up

[![](https://blog.robsewell.com/assets/uploads/2020/03/image-13.png?fit=630%2C106&ssl=1)](https://blog.robsewell.com/assets/uploads/2020/03/image-13.png?ssl=1)

You have to refresh to see when the job is finished and it will be red if the job failed, green if it succeeded or orange if some cells failed like this!

[![](https://blog.robsewell.com/assets/uploads/2020/03/image-14.png?fit=630%2C270&ssl=1)](https://blog.robsewell.com/assets/uploads/2020/03/image-14.png?ssl=1)

But this is the good bit. Clicking on that icon will open the notebook that was created by that agent job run. Lets see what we get

[![](https://blog.robsewell.com/assets/uploads/2020/03/image-15.png?fit=630%2C339&ssl=1)](https://blog.robsewell.com/f5376e7e-4150-471c-b018-f7ae440427b1)

You can see that we have the results of the queries that we wrote in the notebook alongside the documentation (or maybe explanation of the expected results)  
If we scroll down a little (and change the theme colour so that you can see the error)

![](https://blog.robsewell.com/assets/uploads/2020/03/image-18.png?fit=630%2C135&ssl=1)

Msg , Level , State , Line 
Duplicate column names are not permitted in SQL PowerShell. To repeat a column, use a column alias for the duplicate column in the format Column\_Name AS New\_Name.

We have got an error from running the code via SQL PowerShell which is how the job is run. This error is also inserted into the notebooks.nb_template table

[![](https://blog.robsewell.com/assets/uploads/2020/03/image-21.png?fit=630%2C246&ssl=1)](https://blog.robsewell.com/391f8b82-204d-4331-9084-2eefa33a5bc8)

I edited the notebook locally to remove that block of code

[![](https://blog.robsewell.com/assets/uploads/2020/03/image-19.png?fit=630%2C283&ssl=1)](https://blog.robsewell.com/51b34091-962f-4e8b-bc3c-b4b33866ef93)

Then edited the job and selected the updated notebook

[![](https://blog.robsewell.com/assets/uploads/2020/03/image-20.png?fit=630%2C338&ssl=1)](https://blog.robsewell.com/063630fc-98a5-4c82-b6ad-e814bc33324e)

and re-ran the job and got a green tick.

[![](https://blog.robsewell.com/assets/uploads/2020/03/image-22.png?fit=630%2C279&ssl=1)](https://blog.robsewell.com/5ad81496-c6c8-4ddf-8384-d0087f71dd38)

Now I can open the notebook from the latest run, but notice that from this view I can also open the previous notebook.

If I look in the nb\_template table, the last\_run\_notebook\_error has cleared

[![](https://blog.robsewell.com/assets/uploads/2020/03/image-23.png?fit=630%2C450&ssl=1)](https://blog.robsewell.com/assets/uploads/2020/03/image-23.png?ssl=1)

and if I look in the nb materialized table I can see two rows, one for each job run. The error from the first run is also stored in this table. The notebook column has the json for the notebook if you wish to access it in a different manner.

[![](https://blog.robsewell.com/assets/uploads/2020/03/image-24.png?fit=630%2C267&ssl=1)](https://blog.robsewell.com/25685dd2-78d6-40cd-8dc8-18e0149feb86)

Tomorrow, we will see what the job steps look like and how to make this run on an instance which does not and cannot have the required PowerShell.

Spoiler Alert – May contain dbatools 🙂