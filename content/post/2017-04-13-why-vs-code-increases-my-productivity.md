---
title: "Why VS Code Increases my Productivity"
date: "2017-04-13"
categories:
  - Blog

tags:
  - dbatools
   - GitHub
  - markdown
  - PowerShell
  - productivity
  - sql

---
Last week I was showing a co-worker some PowerShell code and he asked what the editor was that I was using. [Visual Studio Code](https://code.visualstudio.com/) I said. Why do you use that? What does it do? This is what I showed him
### Runs on any Operating System
Code (as I shall refer to it) is free lightweight open source editor which runs on all the main operating systems. So you have the same experience in Linux as on Windows. So there is less to learn
### Extensions
You can add new languages, themes, debuggers and tools from the extensions gallery to reduce the number of programmes you have open and the need to switch between programmesYou can add extensions using CTRL + SHIFT  + X and searching in the bar ![01 - Extensions](https://blog.robsewell.com/assets/uploads/2017/04/01-extensions.png?resize=630%2C335&ssl=1) or by going to the [Extensions gallery](https://marketplace.visualstudio.com/VSCode) searching for the extensions and copying the installation command [02 - extensions gallery.PNG](https://blog.robsewell.com/assets/uploads/2017/04/02-extensions-gallery.png)
### Debugging
There is a rich de-bugging experience built in![03 - debugging.PNG](https://blog.robsewell.com/assets/uploads/2017/04/03-debugging.png?resize=630%2C410&ssl=1) You can learn about debugging from the [official docs](https://code.visualstudio.com/docs/editor/debugging) and Keith Hill wrote a blog post on Hey Scripting Guys about [debugging PowerShell](https://blogs.technet.microsoft.com/heyscriptingguy/2017/02/06/debugging-powershell-script-in-visual-studio-code-part-1/)
### Intellisense
An absolute must to make life simpler. Code has intellisense for PowerShell and T-SQL which I use the most but also for many more languages . Read more [here](https://code.visualstudio.com/docs/editor/intellisense)
### Git integration
I love the Git integration, makes it so easy to work with GitHub for me. I can see diffs, commit, undo commits nice and simply. Just open the root folder of the repository and its there
![04 - git](https://blog.robsewell.com/assets/uploads/2017/04/04-git.png?resize=630%2C336&ssl=1) This page will [give you a good start](https://code.visualstudio.com/docs/editor/versioncontrol) on using git with Code
### No distractions
With full screen mode (F11) or Zen mode (CTRL +K, Z) I can concentrate on coding and not worry about distractions
### Stay in one programme and do it all
I have a Markdown document, a PowerShell script and a T-SQL script all in one Git repository and I can work on all of them and version control in one place. The screencast below also shows some of the new capabilities available in the [insiders version](https://code.visualstudio.com/insiders) I managed to leave the screen recording dialogue open as well, apologies and the mistake was deliberate!

 {{< youtube DMoTXQh9hwc >}}

I used the [GitLens](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens) and [SQL beautify](https://marketplace.visualstudio.com/items?itemName=sensourceinc.vscode-sql-beautify) extensions as well as the [dbatools module](https://dbatools.io) in that demo That’s why I am using Code more and more these days, hope it helps Happy Automating!