---
title: "PowerShell Pester – The script failed due to call depth overflow."
categories:
  - Blog

tags:
  - error
  - pester
header:
  teaser: /assets/uploads/2016/01/pester-success_thumb1.jpg
---
This error caught me out. I am putting this post here firstly to remind me if I do it again and also to help others who may hit the same issue.

I also have been looking at [Pester](https://github.com/pester/Pester) which is a framework for running unit tests within PowerShell

You will find some good blog posts about starting with Pester here

So I created a function script file `Create-HyperVFromBase.ps1` and a tests script file `Create-HyperVFromBase.tests.ps1` as shown.

[![pester scripts](/assets/uploads/2016/01/pester-scripts_thumb.jpg)](/assets/uploads/2016/01/pester-scripts_thumb.jpg)

The tests contained this code
```
 $here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. {'$here\$sut'}
Describe "Create Hyper V from Base Tests" {
    Context "Parameter Values,Validations and Errors" {
        It exists {
        test-path function:\create-hypervmfrombase | should be $true
        } 
}
}
```
When I ran the test I got the following error

[![pester error1](/assets/uploads/2016/01/pester-error1_thumb1.jpg)](/assets/uploads/2016/01/pester-error1_thumb1.jpg)

or

[![pester error2](/assets/uploads/2016/01/pester-error2_thumb1.jpg)](/assets/uploads/2016/01/pester-error2_thumb1.jpg)

[Googling pester “The script failed due to call depth overflow.”](https://www.google.co.uk/search?q=pester+The+script+failed+due+to+call+depth+overflow.&ie=&oe=#q=pester+%22The+script+failed+due+to+call+depth+overflow.%22) returned only 7 results but the [Reddit link](https://www.reddit.com/r/PowerShell/comments/3kkbgm/confused_about_pester/) contained the information I needed

> `.Replace() `is case sensitive. It didn’t remove the .tests. keyword from your file name. So it calls your test script again and repeats the same mistake over and over.

and so I renamed the tests script file to `Create-HyperVFromBase.Tests.ps1` With a Capital T! and bingo

[![pester success](/assets/uploads/2016/01/pester-success_thumb1.jpg)](/assets/uploads/2016/01/pester-success_thumb1.jpg)

Don’t forget to name your Pester Tests scripts with a capital T when loading the script in this way and remember that `Replace()` is case sensitive.
```
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"
```