---
title: "Launching Azure VM After Starting With PowerShell"
date: "2013-10-26" 
categories:
  - azure
  - Blog

tags:
  - automate
  - azure
  - PowerShell

---
So this morning I decided I was going to run through this blog post on understanding query plans [http://sqlmag.com/t-sql/understanding-query-plans](http://sqlmag.com/t-sql/understanding-query-plans). I logged into my Azure Portal to check my balance and clicked start on the machine and then immediately clicked connect.

D’oh

[![image](https://blog.robsewell.com/assets/uploads/2013/10/image3.png)](https://blog.robsewell.com/assets/uploads/2013/10/image3.png)

Of course the RDP session wouldn’t open as the machine was not up so I went and made a coffee. Whilst doing that I thought of a way of doing it with PowerShell

[![image](https://blog.robsewell.com/assets/uploads/2013/10/image.png)](https://blog.robsewell.com/assets/uploads/2013/10/image.png)

A little Do Until loop on the PowerState Property 🙂

[![image](https://blog.robsewell.com/assets/uploads/2013/10/image1.png)](https://blog.robsewell.com/assets/uploads/2013/10/image1.png)

Of course if I was doing it all though PowerShell I would have done this

[![image](https://blog.robsewell.com/assets/uploads/2013/10/image2.png)](https://blog.robsewell.com/assets/uploads/2013/10/image2.png)

