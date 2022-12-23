---
title: "Adding a Folder of Scripts to GitHub with Azure Data Studio"
date: "2019-04-07" 
categories:
  - Blog

tags:
  - GitHub
  - Azure Data Studio
  - Source Control

teaser:
   assets/uploads/2019/04/image-37.png

---
In my last post I showed how to [add a folder of scripts to GitHub](https://blog.robsewell.com/10501/) using Visual Studio Code.

You can do it with Azure Data Studio as well. It’s exactly the same steps!

The blog post could end here but read on for some screen shots 😉

Follow the previous post for details of setting up a new GitHub account

Create a repository in GitHub

![](https://blog.robsewell.com/assets/uploads/2019/04/image-27.png)

  

Open the folder in Azure Data Studio with CTRL K CTRL O (Or File –> Open Folder)

![](https://blog.robsewell.com/assets/uploads/2019/04/image-28.png)

Click on the Source Control icon or CTRL + SHIFT + G and then Initialize Repository

![](https://blog.robsewell.com/assets/uploads/2019/04/image-29.png)

Choose the folder

![](https://blog.robsewell.com/assets/uploads/2019/04/image-30.png)

Write a commit message

![](https://blog.robsewell.com/assets/uploads/2019/04/image-31.png)

Say yes to the prompt. Press CTRL + ‘ to open the terminal

![](https://blog.robsewell.com/assets/uploads/2019/04/image-32.png)

Navigate to the scripts folder. (I have a PSDrive set up to my Git folder)

    Set-Location GIT:\\ADS-Scripts\

and copy the code from the GitHub page after “…or push an existing repository from the command line”

![](https://blog.robsewell.com/assets/uploads/2019/04/image-33.png)

and run it

![](https://blog.robsewell.com/assets/uploads/2019/04/image-34.png)

and there are your scripts in GitHub

![](https://blog.robsewell.com/assets/uploads/2019/04/image-35.png)

Make some changes to a script and it will go muddy brown

![](https://blog.robsewell.com/assets/uploads/2019/04/image-36.png)

and then write a commit message. If you click on the file name in the source control tab then you can see the changes that have been made, that are not currently tracked

![](https://blog.robsewell.com/assets/uploads/2019/04/image-37.png)

Commit the change with CTRL + ENTER and then click the roundy-roundy icon (seriously anyone know its name ?) click yes on the prompt and your changes are in GitHub as well 🙂

![](https://blog.robsewell.com/assets/uploads/2019/04/image-38.png)

Realistically, you can use the previous post to do this with Azure Data Studio as it is built on top of Visual Studio Code but I thought it was worth showing the steps in Azure Data Studio.

Happy Source Controlling
