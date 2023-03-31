---
title: "Making Start-Demo work with multi-line commands without a backtick"
categories:
  - Blog

tags:
  - powershell
  - presentations
  - psconfeu
  - speaking
header:
  teaser: assets/uploads/2016/08/start-demo2.png
---
I love to speak about PowerShell. I really enjoy giving presentations and when I saw Start-Demo being used at the PowerShell Conference in Hanover I started to make use of it in my presentations.

`Start-Demo` was written in 2007 by a fella who knows PowerShell pretty well 🙂  [https://blogs.msdn.microsoft.com/powershell/2007/03/03/start-demo-help-doing-demos-using-powershell/](https://blogs.msdn.microsoft.com/powershell/2007/03/03/start-demo-help-doing-demos-using-powershell/)

It was then updated in 2012 by Max Trinidad [http://www.maxtblog.com/2012/02/powershell-start-demo-now-allows-multi-lines-onliners/](http://www.maxtblog.com/2012/02/powershell-start-demo-now-allows-multi-lines-onliners/)

This enabled support for multi-line code using backticks at the end of each line. This works well but I dislike having to use the backticks in foreach loops, it confuses people who think that they need to be included and to my mind looks a bit messy

[![start-demo](/assets/uploads/2016/08/start-demo.png)](/assets/uploads/2016/08/start-demo.png)

This didn’t bother me enough to look at the code but I did mention it to my friend Luke [t](https:%5C%5Ctwitter.com%5Clduddridge) | [g](https://github.com/ChocolateMonkey) who decided to use it as a challenge for his Friday lunch-time codeathon and updated the function so that it works without needing a backtick

[![start-demo2](/assets/uploads/2016/08/start-demo2.png)](/assets/uploads/2016/08/start-demo2.png)

It also works with nested loops

[![start-demo3](/assets/uploads/2016/08/start-demo3.png)](/assets/uploads/2016/08/start-demo3.png)

just a little improvement but one I think that works well and looks good

You can find it at

[https://github.com/SQLDBAWithABeard/Presentations/blob/master/Start-Demo.ps1](https://github.com/SQLDBAWithABeard/Presentations/blob/master/Start-Demo.ps1)

and a little demo showing what it can and cant do

[https://github.com/SQLDBAWithABeard/Presentations/blob/master/start-demotest.ps1](https://github.com/SQLDBAWithABeard/Presentations/blob/master/start-demotest.ps1)

Load the `Start-Demo.ps1` file and then run

`Start-Demo PATHTO\start-demotest.ps1`

Enjoy!
