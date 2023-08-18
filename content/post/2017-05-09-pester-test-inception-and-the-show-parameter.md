---
title: "Pester Test Inception and the Show Parameter"
date: "2017-05-09"
categories:
  - Blog

tags:
  - pester
  - PowerShell

---
<P>My fantastic friend Andre Kamman [b](https://t.co/kFfwIJ3kDO) | [t](https://twitter.com/AndreKamman)  and I presented at [PSConfEu](http://psconf.eu) last week

![C_EDtK0XoAA1PL7 (2).jpg](https://blog.robsewell.com/assets/uploads/2017/05/c_edtk0xoaa1pl7-2.jpg)

and whilst we were there we were chatting about running Pester Tests. He wanted to know how he could run a Pester Test and not lose the failed tests as they scrolled past him. In his particular example we were talking about running hundreds of tests on thousands of databases on hundreds of servers

![01 - pesters.gif](https://blog.robsewell.com/assets/uploads/2017/05/01-pesters.gif)

I guess it looks something like that!!

I explained about the -Show parameter which allows you to filter the results that you see. Using Get-Help Invoke-Pester you can see this

>    -Show
> Customizes the output Pester writes to the screen. Available options are None, Default,
> Passed, Failed, Pending, Skipped, Inconclusive, Describe, Context, Summary, Header, All, Fails.
>
> The options can be combined to define presets.
> Common use cases are:
>
> None – to write no output to the screen.
> All – to write all available information (this is default option).
> Fails – to write everything except Passed (but including Describes etc.).
>
> A common setting is also Failed, Summary, to write only failed tests and test summary.
>
> This parameter does not affect the PassThru custom object or the XML output that
> is written when you use the Output parameters.
>
> Required?                    false
> Position?                    named
> Default value                All
> Accept pipeline input?       false
> Accept wildcard characters?  false

So there are numerous options available to you. Lets see what they look like

I will use a dummy test which creates 10 Context blocks and runs from 1 to 10 and checks if the number has a remainder when divided by 7

```
Describe "Only the 7s Shall Pass" {
    $Servers = 0..10
    foreach($Server in $servers)
    {
        Context "This is the context for $Server" {
        foreach($A in 1..10){
            It "Should Not Pass for the 7s" {
                $A % 7 | Should Not Be 0
                }
            }
        }
    }
}
```

Imagine it is 10 servers running 10 different tests

For the Show parameter All is the default, which is the output that you are used to

![02 - All.gif](https://blog.robsewell.com/assets/uploads/2017/05/02-all.gif?resize=630%2C478&ssl=1)

None does not write anything out. You could use this with -Passthru which will pass ALL of the test results to a variable and if you added -OutputFile and -OutputFormat then you can save ALL of the results to a file for consumption by another system. The -Show parameter only affects the output from the Invoke-Pester command to the host not the output to the files or the variable.

Header only returns the header from the test results and looks like this ( I have included the none so that you can see!)

![03 - none and header.PNG](https://blog.robsewell.com/assets/uploads/2017/05/03-none-and-header.png?resize=630%2C98&ssl=1)

Summary, as expected returns only the summary of the results

![04 - summary.PNG](https://blog.robsewell.com/assets/uploads/2017/05/04-summary.png?resize=630%2C92&ssl=1)

You can use more than one value for the Show parameter so if you chose Header, Summary, Describe you would get this

![05 - headerdesscribe sumnmary.PNG](https://blog.robsewell.com/assets/uploads/2017/05/05-headerdesscribe-sumnmary.png?resize=630%2C436&ssl=1)

You could use Failed to only show the failed tests which looks like this

![06 - failed.PNG](https://blog.robsewell.com/assets/uploads/2017/05/06-failed.png?resize=630%2C594&ssl=1)

but Andre explained that he also want to be able to see some progress whilst the test was running. If there were no failures then he would not se anything at all.

So Fails might be the answer (or Failed and Summary but that would not show the progress)

![07 - fails.PNG](https://blog.robsewell.com/assets/uploads/2017/05/07-fails.png?resize=630%2C445&ssl=1)

Fails shows the Header, Describe, Context  and also shows the Summary.

However we carried on talking. PSConfEU is a fantastic place to talk about PowerShell 🙂 and wondered what would happen if you invoked Pester from inside a Pester test. I was pretty sure that it would work as Pester is just PowerShell but I thought it would be fun to have a look and see how we could solve that requirement

So I created 3 “Internal Tests” these are the ones we don’t want to see the output for. I then wrote an overarching Pester test to call them. In that Pester test script I assigned the results of each test to a variable which. When you examine it you see

![08 - Pester Object.PNG](https://blog.robsewell.com/assets/uploads/2017/05/08-pester-object.png)

The custom object that is created shows the counts of all different results of the tests, the time it took and also the test result.

So I could create a Pester Test to check the Failed Count property of that Test result

`$InternalTest1.FailedCount | Should Be 0`

To make sure that we don’t lose the results of the tests we can output  them to a file like this

`$InternalTest1 = Invoke-Pester .\\Inside1.Tests.ps1 -Show None -PassThru -OutputFile C:\\temp\\Internal\_Test1\_Results.xml -OutputFormat NUnitXml`

So now we can run Invoke-Pester and point it at that file and it will show the progress and the final result on the screen.

![09 finale.PNG](https://blog.robsewell.com/assets/uploads/2017/05/09-finale.png?resize=630%2C422&ssl=1)

You could make use of this in different ways

*   Server 1
    *   Database1
    *   Database2
    *   Database3
    *   Database4
*   Server 2
    *   Database1
        Database2
        Database3
        Database4
*   Server 3
    *   Database1
        Database2
        Database3
        Database4

Or by Test Category

*   Backup
    *   Server1
    *   Server 2
    *   Server 3
    *   Server 4
*   Agent Jobs
    *   Server 1
    *   Server 2
    *   Server 3
    *   Server 4
*   Indexes
    *   Server 1
    *   Server 2
    *   Server 3
    *   Server 4

Your only limitation is your imagination.

As we have mentioned PSConfEU you really should check out the videos on the [youtube channel](https://www.youtube.com/channel/UCxgrI58XiKnDDByjhRJs5fg) All of the videos that were successfully recorded will be on there. You could start with this one and mark your diaries for April 16-20 2018

 {{< youtube G38tN7B46Fg >}}



