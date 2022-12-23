---
title: "Handling Missing Instances when Looping with Pester"
categories:
  - Blog

tags:
  - dbatools
  - pester
  - PowerShell
  - sqlserver

---
In my previous posts about [writing your first Pester Test](https://blog.robsewell.com/write-your-first-pester-test-today/) and [looping through instances](https://blog.robsewell.com/2-ways-to-loop-through-collections-in-pester/) I described how you can start to validate that your SQL Server is how YOU want it to be.

Unavailable machines
--------------------

Once you begin to have a number of tests for a number of instances you want to be able to handle any machines that are not available cleanly otherwise you might end up with something like this.

![01 - error.png](https://blog.robsewell.com/assets/uploads/2017/11/01-error.png)

In this (made up) example we loop through 3 instances and try to check the DNS Server entry is correct but for one of them we get a massive error and if we had created a large number of tests for each machine we would have a large number of massive errors.

Empty Collection
----------------

If we don’t successfully create our collection we might have an empty collection which will give us a different issue. No tests

![02 - no tests.png](https://blog.robsewell.com/assets/uploads/2017/11/02-no-tests.png)

If this was in amongst a whole number of tests we would not have tested anything in this Describe block and might be thinking that our tests were OK because we had no failures of our tests. We would be wrong!

Dealing with Empty Collections
------------------------------

One way of dealing with empty collections is to test that they have more than 0 members
```
if ($instances.count -gt 0) {
    $instances.ForEach{
        ## Tests in here
    }
}
else {Write-Warning "Uh-Oh - The Beard is Sad! - The collection is empty. Did you set `$Instances correctly?"}
```
Notice the backtick ` before the $ to escape it in the Write-Warning. An empty collection now looks like

![03 - uh-oh.png](https://blog.robsewell.com/assets/uploads/2017/11/03-uh-oh.png)

Which is much better and provides useful information to the user

Dealing with Unavailable Machines
---------------------------------

If we want to make sure we dont clutter up our test results with a whole load of failures when a machine is unavailable we can use similar logic.

First we could check if it is responding to a ping (assuming that ICMP is allowed by the firewall and switches) using

`Test-Connection -ComputerName $computer -Count 1 -Quiet -ErrorAction SilentlyContinue`

This will just try one ping and do it quietly only returning True or False and if there are any errors it shouldn’t mention it

In the example above I am using PSRemoting and we should make sure that that is working too. So whilst I could use

`Test-WSMan -ComputerName $computer`

this only checks if a WSMAN connection is possible and not other factors that could be affecting the ability to run remote sessions. Having been caught by this before I have always used [this function from Lee Holmes](http://www.leeholmes.com/blog/2009/11/20/testing-for-powershell-remoting-test-psremoting/) (Thank you Lee) and thus can use
```
$instances.ForEach{
    $computer = $_.Split('\\')\[0\]# To get the computername if there is an instance name
    # Check if machine responds to ping
    if (!(Test-Connection-ComputerName $computer-Count 1-Quiet -ErrorAction SilentlyContinue))
    {Write-Warning "Uh-Oh - $Computer is not responding to a ping - aborting the tests for this machine"; Return}
    # Check if PSremoting is possible for this machine
    # Requires Test-PSRemoting by Lee Holmes http://www.leeholmes.com/blog/2009/11/20/testing-for-powershell-remoting-test-psremoting/
    if (!(Test-PsRemoting$computer))
    {Write-Warning "Uh-Oh - $Computer is not able to use PSRemoting - aborting the tests for this machine"; Return}
    Describe "Testing Instance $($_)" {
        ## Put tests in here
    }
```
which provides a result like this

![04 - better handling.png](https://blog.robsewell.com/assets/uploads/2017/11/04-better-handling.png)

Which is much better I think 🙂

Let dbatools do the error handling for you
------------------------------------------

If your tests are only using the dbatools module then there is built in error handling that you can use. By default dbatools returns useful messages rather than the exceptions from PowerShell (You can enable the exceptions using the -EnableExceptions parameter if you want/need to) so if we run our example from the previous post it will look like

![05 - dbatools handling.png](https://blog.robsewell.com/assets/uploads/2017/11/05-dbatools-handling.png)

which is fine for a single command but we don’t really want to waste time and resources repeatedly trying to connect to an instance if we know it is not available if we are running multiple commands against each instance.

dbatools at the beginning of the loop
-------------------------------------

We can use [`Test-DbaConnection`](https://dbatools.io/functions/test-dbaconnection/)to perform a check at the beginning of the loop as we discussed in the [previous post](https://blog.robsewell.com/2-ways-to-loop-through-collections-in-pester/)
```
$instances.ForEach{
    if (!((Test-DbaConnection-SqlInstance $_ -WarningAction SilentlyContinue).ConnectSuccess))
    {Write-Warning "Uh-Oh - we cannot connect to $_ - aborting the tests for this instance"; Return}
```
Notice that we have used `-WarningAction SilentlyContinue` to hide the warnings from the command this tiime. Our test now looks like

![06 - dbatools test-dbaconnection.png](https://blog.robsewell.com/assets/uploads/2017/11/06-dbatools-test-dbaconnection.png)

`Test-DbaConnection` performs a number of tests so you can check for ping SQL version, domain name and remoting if you want to exclude tests on those basis

Round Up
--------

In this post we have covered some methods of ensuring that your Pester Tests return what you expect. You don’t want empty collections of SQL Instances making you think you have no failed tests when you have not actually run any tests.

You can do this by checking how many instances are in the collection

You also dont want to keep running tests against a machine or instance that is not responding or available.

You can do this by checking a ping with `Test-Connection` or if remoting is required by using the `Test-PSRemoting` function from Lee Holmes

If you want to use dbatools exclusively you can use `Test-DbaConnection`

Here is a framework to put your tests inside. You will need to provide the values for the $Instances and place your tests inside the Describe Block
```
if ($instances.count -gt 0) {
    $instances.ForEach{
        $TestConnection = Test-DbaConnection-SqlInstance $_ -WarningAction SilentlyContinue
        # Check if machine responds to ping
        if (!($TestConnection.IsPingable))
        {Write-Warning "Uh-Oh - The Beard is Sad! - - $_ is not responding to a ping - aborting the tests for this instance"; Return}
        # Check if we have remote access to the machine
        if (!($TestConnection.PsRemotingAccessible))
        {Write-Warning "Uh-Oh - The Beard is Sad! - - $_ is not able to use PSRemoting - aborting the tests for this instance"; Return}
        # Check if we have SQL connection to the Instance
        if (!($TestConnection.ConnectSuccess))
        {Write-Warning "Uh-Oh - The Beard is Sad! - - we cannot connect to SQL on $_ - aborting the tests for this instance"; Return}
        Describe "Testing Instance $($_)" {
            ## Now put your tests in here - seperate them with context blocks if you want to
            Context "Networks" { }
        }
    }
}
else
## If the collection is empty
{
    Write-Warning "Uh-Oh - The Beard is Sad! - The collection is empty. Did you set `$Instances correctly?"
}
```

