---
title: "PowerShell Function – Validating a Parameter Depending On A Previous Parameter’s Value"
date: "2017-04-26"
categories:
  - Blog

tags:
  - dbatools
  - error
  - help
  - parameters
  - PowerShell
header:
  teaser: assets/uploads/2017/04/01-more-help.png
---
I was chatting on the [SQL Community Slack](https://sqlps.io/slack) with my friend Sander Stad [b](http://www.sqlstad.nl/) | [t](https://twitter.com/sqlstad) about some functions he is writing for the amazing PowerShell SQL Server Community module [dbatools](https://dbatools.io). He was asking my opinion as to how to enable user choice or options for Agent Schedules and I said that he should validate the input of the parameters. He said that was difficult as if the parameter was Weekly the frequency values required would be different from if the parameter was Daily or Monthly. That’s ok, I said, you can still validate the parameter.

You can read more about Parameters either online [here](https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.core/about/about_parameters) or [here](https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.core/about/about_functions_advanced_parameters) or by running
```
Get-Help About_Parameters
Get-Help About_Functions_Parameters
```
You can also find more help information with

`Get-Help About_*Parameters*`

[![01 more help.PNG](/assets/uploads/2017/04/01-more-help.png)](/assets/uploads/2017/04/01-more-help.png)

This is not a post about using Parameters, [google for those](https://www.google.co.uk/search?q=powershell+about+paramters&ie=&oe=#safe=strict&q=powershell+parameters&spf=370) but this is what I showed him.

Lets create a simple function that accepts 2 parameters Word and Number
```
 function Test-validation
{
    Param
    (
         [string]$Word,
         [int]$Number
    )
Return "$Word and $Number"
} 
```
We can run it with any parameters

[![02 any parameters](/assets/uploads/2017/04/02-any-parameters.png)](/assets/uploads/2017/04/02-any-parameters.png)

If we wanted to restrict the Word parameter to only accept Sun, Moon or Earth we can use the [ValidateSetAttribute](https://msdn.microsoft.com/en-us/library/ms714434(v=vs.85).aspx) as follows
```
 function Test-validation
{
    Param
    (
        [ValidateSet("sun", "moon", "earth")]
        [string]$Word,
        [int]$Number
    )
Return "$Word and $Number"
}
```
Now if we try and set a value for the $Word parameter that isn’t sun moon or earth then we get an error

[![03 parameter error.PNG](/assets/uploads/2017/04/03-parameter-error.png)](/assets/uploads/2017/04/03-parameter-error.png)

and it tells us that the reason for the error is that TheBeard! does not belong to the set sun, moon, earth.

But what Sander wanted was to validate the value of the second parameter depending on the value of the first one. So lets say we wanted

*   If word is sun, number must be 1 or 2
*   If word is moon, number must be 3 or 4
*   If word is earth, number must be 5 or 6

We can use the [ValidateScriptAttribute](https://msdn.microsoft.com/en-us/library/system.management.automation.validatescriptattribute(v=vs.85).aspx)  to do this. This requires a script block which returns True or False. You can access the current parameter with `$_` so we can use a script block like this
```
{
    if($Word -eq 'Sun'){$_ -eq 1 -or $_ -eq 2}
    elseif($Word -eq 'Moon'){$_ -eq 3 -or $_ -eq 4}
    elseif($Word -eq 'earth'){$_ -eq 5 -or $_ -eq 6}
}
```
The function now looks like
```
function Test-validation
{
    Param
    (
        [ValidateSet("sun", "moon", "earth")]
        [string]$Word,
        [ValidateScript({
            if($Word -eq 'Sun'){$_ -eq 1 -or $_ -eq 2}
            elseif($Word -eq 'Moon'){$_ -eq 3 -or $_ -eq 4}
            elseif($Word -eq 'earth'){$_ -eq 5 -or $_ -eq 6}
        })]
        [int]$Number
    )
Return "$Word and $Number"
}
```
It will still fail if we use the wrong “Word” in the same way but now if we enter earth and 7 we get this

[![04 parameter error.PNG](/assets/uploads/2017/04/04-parameter-error.png)](/assets/uploads/2017/04/04-parameter-error.png)

But if we enter sun and 1 or moon and 3 or earth and 5 all is well

[![05 working](/assets/uploads/2017/04/05-working.png)](/assets/uploads/2017/04/05-working.png)

I would add one more thing. We should always write PowerShell functions that are easy for our users to self-help. Of course, this means write good help for the function. here is a great place to start from June Blender

[![06 June.PNG](/assets/uploads/2017/04/06-june.png)](/assets/uploads/2017/04/06-june.png)

In this example, the error message

> Test-validation : Cannot validate argument on parameter ‘number’. The ”  
> if($word -eq ‘Sun’){$_ -eq 1 -or $_ -eq 2}  
> elseif($word -eq ‘Moon’){$_ -eq 3 -or $_ -eq 4}  
> elseif($word -eq ‘earth’){$_ -eq 5 -or $_ -eq 6}  
> ” validation script for the argument with value “7” did not return a result of True. Determine why the validation script failed, and then try the  
> command again.  
> At line:1 char:39  
> + Test-validation -Word “earth” -number 007  
> +                                       ~~~  
> + CategoryInfo          : InvalidData: (:) [Test-validation], ParameterBindingValidationException  
> + FullyQualifiedErrorId : ParameterArgumentValidationError,Test-validation

is not obvious to a none-coder so we could make it easier. As we are passing in a script block we can just add a comment like this. I added a spare line above and below to make it stand out a little more
```
function Test-validation
{
    Param
    (
        [ValidateSet("sun", "moon", "earth")]
        [string]$Word,
        [ValidateScript({
            #
            # Sun Accepts 1 or 2
            # Moon Accepts 3 or 4
            # Earth Accepts 5 or 6
            #
            if($Word -eq 'Sun'){$_ -eq 1 -or $_ -eq 2}
            elseif($Word -eq 'Moon'){$_ -eq 3 -or $_ -eq 4}
            elseif($Word -eq 'earth'){$_ -eq 5 -or $_ -eq 6}
        })]
        [int]$Number
    )
Return "$Word and $Number"
}
```
Now if you enter the wrong parameter you get this

[![07 more help.PNG](/assets/uploads/2017/04/07-more-help.png)](/assets/uploads/2017/04/07-more-help.png)

which I think makes it a little more obvious

