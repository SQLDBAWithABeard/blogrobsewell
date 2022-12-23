---
title: "The PowerShell Box Of Tricks GUI"
categories:
  - Blog

tags:
  - buttons
  - gui
  - PowerShell
  - automate
  - automation
  - SQL Server
  - box-of-tricks

header:
  teaser: /assets/uploads/2013/09/image86.png
  

---
When I started as a DBA at MyWork I faced a challenge. Many hundreds of databases, dozens of servers and no idea what was on where. It was remembering this situation when new team members were appointed that lead me to write the [Find-Database script](https://blog.robsewell.com/using-powershell-to-find-a-database-amongst-hundreds/) and I had written a simple GUI using `Read-Host` to enable the newbies to see the functions I had created

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image85.png)](https://blog.robsewell.com/assets/uploads/2013/09/image85.png)

Whilst writing this series of posts I decided that I would create a new GUI

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image86.png)](https://blog.robsewell.com/assets/uploads/2013/09/image86.png)

I wanted the choice to be made and then the form to close so I had to use a separate function for calling all the functions referenced in the form. This function takes an input `$x` and depending on the value runs a particular code block. Inside the code block I ask some questions using `Read-Host` to set the variables, load the function and run it as shown below for [Show-DriveSizes](https://blog.robsewell.com/checking-drive-sizes-with-powershell/)

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image87.png)](https://blog.robsewell.com/assets/uploads/2013/09/image87.png)

Then I set about creating the GUI. First we load the Forms Assembly, create a new Form object and add a title

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image88.png)](https://blog.robsewell.com/assets/uploads/2013/09/image88.png)

Then using the [details found here](http://www.alkanesolutions.co.uk/2013/04/19/embedding-base64-image-strings-inside-a-powershell-application/) I I converted the image to ASCI and use it as the background image and set the size of the Form

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image89.png)](https://blog.robsewell.com/assets/uploads/2013/09/image89.png)

I choose a default font for the form. Note there are many many properties that you can set for all of these objects so [use your best learning aid](http://google.com) and find the ones you need.

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image90.png)](https://blog.robsewell.com/assets/uploads/2013/09/image90.png)

I then create three labels. I will show one. I think the code is self-explanatory and you will be able to see what is going on. Don’t forget to the last line though! That adds it to the form, if you miss it you can spend a few minutes scratching your head wondering why it hasn’t appeared!!!

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image91.png)](https://blog.robsewell.com/assets/uploads/2013/09/image91.png)

We need a Text Box for the User to put their choice in. Again the code is fairly easy to understand

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image92.png)](https://blog.robsewell.com/assets/uploads/2013/09/image92.png)

The next bit of code enables the user to use Enter and Escape keys to Go or to Quit. Notice that both call the `Close()` method to close the Form and return to the PowerShell console

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image93.png)](https://blog.robsewell.com/assets/uploads/2013/09/image93.png)

Add a button for OK and one for quit

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image94.png)](https://blog.robsewell.com/assets/uploads/2013/09/image94.png)

and finally Activate the Form, Show it and run the function to call the correct function

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image95.png)](https://blog.robsewell.com/assets/uploads/2013/09/image95.png)

The `Return-Answer` function simply calls the `Return-Function` function. I am not sure if that is the best way of doing it but it works in the way i wanted it to

[![image](https://blog.robsewell.com/assets/uploads/2013/09/image96.png)](https://blog.robsewell.com/assets/uploads/2013/09/image96.png)