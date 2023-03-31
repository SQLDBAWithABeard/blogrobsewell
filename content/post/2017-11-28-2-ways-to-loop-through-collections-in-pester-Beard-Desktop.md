---
title: "2 Ways to Loop through collections in Pester"
date: "2017-11-28"
categories:
  - Blog
  - SQLBits

tags:
  - connection
  - dbatools
  - pester
  - PowerShell
  - sqlserver
  - test
  - testcases
  - SQLBits
---
In my last post I showed you [how to write your first Pester test](https://blog.robsewell.com/write-your-first-pester-test-today/) to validate something. Here’s a recap

*   Decide the information you wish to test
*   Understand how to get it with PowerShell
*   Understand what makes it pass and what makes it fail
*   Write a Pester Test

You probably have more than one instance that you want to test, so how do you loop through a collection of instances? There are a couple of ways.

Getting the Latest Version of the Module
----------------------------------------

Steve Jones wrote about getting the latest version of Pester and the correct way to do it. You can [find the important information here](https://voiceofthedba.com/2017/11/27/installing-pester/)

Test Cases
----------

The first way is to use the Test Case parameter of the It command (the test) which I have written about when [using TDD for Pester here](https://blog.robsewell.com/writing-dynamic-and-random-tests-cases-for-pester/)

Lets write a test first to check if we can successfully connect to a SQL Instance. Running

`Find-DbaCommand connection`

shows us that the [`Test-DbaConnection`](https://dbatools.io/functions/test-dbaconnection/) command is the one that we want from the [dbatools module](http://dbatools.io). We should always run Get-Help to understand how to use any PowerShell command. This shows us that the results will look like this

![01 - gethelp test-dbaconnection](https://blog.robsewell.com/assets/uploads/2017/11/01-gethelp-test-dbaconnection.png)

So there is a ConnectSuccess result which returns True or false. Our test can look like this for a single instance
```
Describe 'Testing connection to ROB-XPS' {
    It "Connects successfully to ROB-XPS" {
        (Test-DbaConnection-SqlInstance ROB-XPS).ConnectSuccess | Should Be $True
    }
}
```
which gives us some test results that look like this

![successful test.png](https://blog.robsewell.com/assets/uploads/2017/11/successful-test.png)

which is fine for one instance but we want to check many.

We need to gather the instances into a $Instances variable. In my examples I have hard coded a list of SQL Instances but you can, and probably should, use a more dynamic method, maybe the results of a query to a configuration database. Then we can fill our TestCases variable which can be done like this
```
$Instances = 'ROB-XPS','ROB-XPS\DAVE','ROB-XPS\BOLTON','ROB-XPS\SQL2016'
# Create an empty array
$TestCases = @()
# Fill the Testcases with the values and a Name of Instance
$Instances.ForEach{$TestCases += @{Instance = $_}}
```
Then we can write our test like this
```
# Get a list of SQL Servers
# Use whichever method suits your situation
# Maybe from a configuration database
# I'm just using a hard-coded list for example
$Instances = 'ROB-XPS','ROB-XPS\DAVE','ROB-XPS\BOLTON','ROB-XPS\SQL2016'

# Create an empty array
$TestCases = @()

# Fill the Testcases with the values and a Name of Instance
$Instances.ForEach{$TestCases += @{Instance = $_}}
Describe 'Testing connection to SQL Instances' {
    # Put the TestCases 'Name' in <> and add the TestCases parameter
    It "Connects successfully to <Instance>" -TestCases $TestCases {
        # Add a Parameter to the test with the same name as the TestCases Name
        Param($Instance)
        # Write the test using the TestCases Name
        (Test-DbaConnection -SqlInstance $Instance).ConnectSuccess | Should Be $True
    }
}
```
Within the title of the test we refer to the instance inside <> and add the parameter TestCases with a value of the $TestCases variable. We also need to add a Param() to the test with the same name and then use that variable in the test.

This looks like this

![Testcases test.png](https://blog.robsewell.com/assets/uploads/2017/11/Testcases-test.png)

Pester is PowerShell
--------------------

The problem with  Test Cases is that we can only easily loop through one collection, but as Pester is just PowerShell we can simply use ForEach if we wanted to loop through multiple ones, like instances and then databases.

I like to use the ForEach method as it is slightly quicker than other methods. It will only work with PowerShell version 4 and above. Below that version you need to pipe the collection to For-EachObject.

Lets write a test to see if our databases have trustworthy set on. We can do this using the Trustworthy property returned from [`Get-DbaDatabase`](https://dbatools.io/functions/Get-DbaDatabase/)

We loop through our Instances using the ForEach method and create a Context for each Instance to make the test results easier to read. We then place the call to `Get-DbaDatabase `inside braces and loop through those and check the Trustworthy property
```
# Get a list of SQL Servers
# Use whichever method suits your situation
# Maybe from a configuration database
# I'm just using a hard-coded list for example
$Instances = 'ROB-XPS','ROB-XPS\DAVE','ROB-XPS\BOLTON','ROB-XPS\SQL2016'
Describe 'Testing user databases' {
    # Loop through the instances
    $Instances.ForEach{
        # Create a Context for each Instance.
        Context "Testing User Databases on $($_)" {
            # Loop through the User databases on the instance
            (Get-DbaDatabase -SqlInstance $_ -ExcludeAllSystemDb).ForEach{
                # Refer to the database name and Instance name inside a $()
                It "Database $($_.Name) on Instance $($_.Parent.Name) should not have TRUSTWORTHY ON" {
                    $_.Trustworthy | Should Be $false
                }
            }
        }
    }
}
```
and it looks like this

![testdatabasetrustworthy.png](https://blog.robsewell.com/assets/uploads/2017/11/testdatabasetrustworthy.png)
------------------------------------------------------------------------------------------------------------------------------------

So there you have two different ways to loop through collections in your Pester tests. Hopefully this can help you to write some good tests to validate your environment.

Happy Pestering

Spend a Whole Day With Chrissy & I at SQLBits
---------------------------------------------

If you would like to spend a whole day with Chrissy LeMaire and I at [SQLBits](http://sqlbits.com) in London in February – we have a pre-con on the Thursday

You can find out more about the pre-con [sqlps.io/bitsprecon](http://sqlps.io/bitsprecon)

and you can register at [sqlps.io/bitsreg](http://sqlps.io/bitsreg)

