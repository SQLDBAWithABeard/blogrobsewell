---
title: "How to write a PowerShell function to use Confirm, Verbose and WhatIf"
date: "2018-01-25" 
categories:
  - Blog
  - PowerShell

tags:
  - confirm
  - PowerShell
  - verbose

header:
  teaser: /assets/uploads/2018/01/03-confirm.png
---
In [my last blog post](https://blog.robsewell.com/how-to-run-a-powershell-script-file-with-verbose-confirm-or-whatif/) I showed how to run a script with the WhatIf parameter. This assumes that the commands within the script have been written to use the common parameters Confirm, Verbose and WhatIf.

Someone asked me how to make sure that any functions that they write will be able to do this.

it is very easy

When we define our function we are going to add `[cmdletbinding(SupportsShouldProcess)]` at the top

    function Set-FileContent {
    [cmdletbinding(SupportsShouldProcess)]
    Param()

and every time we perform an action that will change something we put that code inside a code block like this

    if ($PSCmdlet.ShouldProcess("The Item" , "The Change")) {
        # place code here
    }

and alter The Item and The Change as appropriate.

I have created a snippet for VS Code to make this quicker for me. To add it to your VS Code. Click the settings button bottom right, Click User Snippets, choose the powershell json and add the code below between the last two }’s (Don’t forget the comma)

    ,
		"IfShouldProcess": {
		"prefix": "IfShouldProcess",
		"body": [
			"if ($$PSCmdlet.ShouldProcess(\"The Item\" , \"The Change\")) {",
			"   # Place Code here",
			"}"
				],
			"description": "Shows all the colour indexes for the Excel colours"
	}

and save the powershell.json file

Then when you are writing your code you can simply type “ifs” and tab and the code will be generated for you

![](https://blog.robsewell.com/assets/uploads/2018/01/01-VS-Code-Snippet.gif)

As an example I shall create a function wrapped around Set-Content just so that you can see what happens.

    function Set-FileContent {
        [cmdletbinding(SupportsShouldProcess)]
        Param(
            [Parameter(Mandatory = $true)]
            [ValidateNotNullOrEmpty()]
            [string]$Content,
            [Parameter(Mandatory = $true)]
            [ValidateScript( {Test-Path $_ })]
            [string]$File
        )
        if ($PSCmdlet.ShouldProcess("$File" , "Adding $Content to     ")) {
            Set-Content -Path $File -Value $Content
        }
    }

I have done this before because if the file does not exist then `Set-Content` will create a new file for you, but with this function I can check if the file exists first with the ValidateScript before running the rest of the function.

As you can see I add variables from my PowerShell code into the “The Item” and “The Change”. If I need to add a property of an object I use `$($Item.Property)`.

So now, if I want to see what my new function would do if I ran it without actually making any changes I have -WhatIf added to my function automagically.

    Set-FileContent -File C:\temp\number1\TextFile.txt -Content "This is the New Content" -WhatIf

![](https://blog.robsewell.com/assets/uploads/2018/01/02-what-if.png)

If I want to confirm any action I take before it happens I have `-Confirm`

    Set-FileContent -File C:\temp\number1\TextFile.txt -Content "This is the New Content" -Confirm

![](https://blog.robsewell.com/assets/uploads/2018/01/03-confirm.png)

As you can see it also give the confirm prompts for the `Set-Content` command

You can also see the verbose messages with

    Set-FileContent -File C:\temp\number1\TextFile.txt -Content "This is the New Content" -Verbose

![](https://blog.robsewell.com/assets/uploads/2018/01/04-verbose.png)

So to summarise, it is really very simple to add Confirm, WhatIf and Verbose to your functions by placing  `[cmdletbinding(SupportsShouldProcess)]` at the top of the function and placing any code that makes a change inside

    if ($PSCmdlet.ShouldProcess("The Item" , "The Change")) {

with some values that explain what the code is doing to the The Item and The Change.

Bonus Number 1 – This has added support for other common parameters as well – Debug, ErrorAction, ErrorVariable, WarningAction, WarningVariable, OutBuffer, PipelineVariable, and OutVariable.

Bonus Number 2 – This has automatically been added to your Help

![](https://blog.robsewell.com/assets/uploads/2018/01/05-get-help.png)

Bonus Number 3 – This has reduced the amount of comments you need to write and improved other peoples understanding of what your code is supposed to do 🙂 People can read your code and read what you have entered for the IfShouldProcess and that will tell them what the code is supposed to do 🙂

Now you have seen how easy it is to write more professional PowerShell functions
