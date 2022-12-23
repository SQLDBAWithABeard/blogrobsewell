---
title: "Setting the default file type for a new file in VS Code"
date: "2017-04-24" 
categories:
  - Blog

tags:
  - defaults
  - keymap
  - PowerShell
  - settings
  - VS Code

---
Just a short post today. When you open a new file in VS Code (Using CTRL + N) it opens by default as a plain text file.

To change the language for the file use CTRL +K, M.

That’s CTRL and K together and then M afterwards separately.

then you can choose the language for the file. It looks like this

![01 - Change language](https://blog.robsewell.com/assets/uploads/2017/04/01-change-language.gif)

However, if you just want your new file to open as a particular language every time you can change this in the settings.

Click File –> Preferences –> Settings

or by clicking CTRL + ,

![02 - Open Preferences.PNG](https://blog.robsewell.com/assets/uploads/2017/04/02-open-preferences.png)

This opens the settings.json file. Search in the bar for default and scroll down until you see file

![03 - File defaults.PNG](https://blog.robsewell.com/assets/uploads/2017/04/03-file-defaults.png)

If you hover over the setting that you want to change, you will see a little pencil. Click on that and then Copy to Settings which will copy it to your user settings in the right hand pane.

NOTE – You will need to enter powershell and not PowerShell. For other languages, click on the language in the bottom bar and look at the value in the brackets next to the language name

![04 - langauge.PNG](https://blog.robsewell.com/assets/uploads/2017/04/04-langauge.png)

Once you have entered the new settings save the file (CTRL + S) and then any new file you open will be using the language you have chosen

It looks like this

![05 - Change settings.gif](https://blog.robsewell.com/assets/uploads/2017/04/05-change-settings.gif)

and now every new file that you open will be opened as a PowerShell file (or whichever language you choose)

You will still be able to change the language with CTRL K, m

Just to be clear, because people sometimes get this wrong. That’s CTRL and K, let go and then M. You will know you are doing correctly when you see

> (CTRL + K) was pressed waiting for second key of chord……

![06 - waiting for key](https://blog.robsewell.com/assets/uploads/2017/04/06-waiting-for-key.png)

If you get it wrong and Press CTRL + K + M then you will open the Extensions search for keymaps.

![07 - incorrect.PNG](https://blog.robsewell.com/assets/uploads/2017/04/07-incorrect.png)

This is a brilliant feature enabling you to copy key mappings for the programmes you use all the time and save you from learning the Code key mappings. You can find the keymaps in the [Extensions Marketplace](https://marketplace.visualstudio.com/search?target=vscode&category=Keymaps&sortBy=Relevance) as well as by pressing CTRL + K + M
