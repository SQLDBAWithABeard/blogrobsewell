---
title: "PowerShell Notebooks in Azure Data Studio"
date: "2019-10-17" 
categories:
  - Blog
  - Jupyter Notebooks
  - Azure Data Studio
  - PowerShell
  - dbatools

tags:
  - dbatools
  - insiders
  - PowerShell
  - Jupyter Notebooks
  - Azure Data Studio
  - Notebooks


image: assets/uploads/2019/10/image-8.png

---
The latest release of the [insiders edition of Azure Data Studio](https://github.com/microsoft/azuredatastudio#try-out-the-latest-insiders-build-from-master) brings the first edition of PowerShell Notebooks!

You can download the latest insiders edition from the link above, it can be installed alongside the stable release.

To access many of the commands available use F1 to open the command palette (like many of my tips this also works in Visual Studio Code). You can then start typing to get the command that you want.

 ![](https://blog.robsewell.com/assets/uploads/2019/10/image-8.png )

You can then hit enter with the command that you want highlighted, use the mouse or use the shortcut which is displayed to the right.

In a new notebook, you can click the drop down next to kernel and now you can see that PowerShell is available

 ![](https://blog.robsewell.com/assets/uploads/2019/10/image-9.png )

When you choose the PowerShell kernel, you will get a prompt asking you to configure the Python installation

 ![](https://blog.robsewell.com/assets/uploads/2019/10/image-10.png )

If you have Python already installed you can browse to the location that it is installed or you can install Python. In the bottom pane you will be able to see the progress of the installation.

 ![](https://blog.robsewell.com/assets/uploads/2019/10/image-11.png )

When it has completed, you will see

 ![](https://blog.robsewell.com/assets/uploads/2019/10/image-12.png )

You may also get a prompt asking if you would like to upgrade some packages

 ![](https://blog.robsewell.com/assets/uploads/2019/10/image-13.png )

Again this will be displayed in the tasks pane

 ![](https://blog.robsewell.com/assets/uploads/2019/10/image-14.png )

**Adding PowerShell**
---------------------

  
To add PowerShell Code to the notebook click the Code button at the top of the file

![](https://blog.robsewell.com/assets/uploads/2019/10/image-15.png )

or the one you can find by highlighting above or below a block

![](https://blog.robsewell.com/assets/uploads/2019/10/image-16.png )

I did not have intellisense, but you can easily write your code in Azure Data Studio or Visual Studio Code and paste it in the block.  
  
Interestingly Shawn Melton ( [t](https://twitter.com/wsmelton) ) did

> Curious, you state "There is not any intellisense, but you can easily write your code in Azure Data Studio or Visual Studio Code and paste it in the block"…  
>   
> It works flawlessly for me on Windows. [pic.twitter.com/Lx6fGH9F5L](https://t.co/Lx6fGH9F5L)
> 
> — Shawn Melton (@wsmelton) [October 17, 2019](https://twitter.com/wsmelton/status/1184819132598013952?ref_src=twsrc%5Etfw)

This was because he had the PowerShell extension installed and I did not (I know !!)  
If you find you dont have intellisense then install the PowerShell extension!

 ![](https://blog.robsewell.com/assets/uploads/2019/10/image-17.png )

Clicking the play button (which is only visible when you hover the mouse over it) will run the code

<FIGURE class=wp-block-video><VIDEO src="https://blog.robsewell.com/wp-content/uploads/2019/10/2019-10-17_12-08-43.mp4" controls></VIDEO></FIGURE>

You can clear the results from every code block using the clear results button at the top

![](https://blog.robsewell.com/assets/uploads/2019/10/image-18.png )

Otherwise, you can save the results with the Notebook by saving it. This is the part that is missing from running PowerShell in the Markdown blocks in a [SQL Notebook as I described here](https://blog.robsewell.com/powershell-in-sql-notebooks-in-azure-data-studio/)

 ![](https://blog.robsewell.com/assets/uploads/2019/10/image-19.png )

I am looking forward to how this develops. You can find my sample PowerShell notebook (with the code results) [here](https://github.com/SQLDBAWithABeard/Presentations/blob/master/Notebooks/powershell.ipynb)

