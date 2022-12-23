---
title: "Using Pester with Get-DbaLastGoodCheckDb from dbatools"
date: "2017-04-06" 
categories:
  - Blog

tags:
  - automate
  - automation
  - databases
  - dbatools
  - PowerShell

---
<P>In <A href="https://blog.robsewell.com/getting-sqlservers-last-known-good-dbcc-checkdb-with-powershell-and-dbatools/" target=_blank>my last post </A>I showed <A href="https://dbatools.io/functions/get-dbalastgoodcheckdb/" target=_blank><SPAN style="COLOR: #0066cc">Get-DbaLastGoodCheckDb</SPAN></A>&nbsp; from <A href="https://dbatools.io" target=_blank>dbatools.</A> This module is a community based project written by excellent, brilliant people in their own time and available to you free. To find out more and how to use and install it visit <A href="https://dbatools.io" target=_blank><SPAN style="COLOR: #0066cc">https://dbatools.io</SPAN></A></P>
<P>In a similar fashion to my post about <A href="https://blog.robsewell.com/using-pester-with-dbatools-test-dbalastbackup/" target=_blank>using Pester with Test-DBALastBackup</A>&nbsp;I thought I would write some <A href="https://github.com/pester" target=_blank>Pester </A>tests for Get-DbaLastGoodCheckDb as well</P>
<BLOCKQUOTE>
<P>Pester provides a framework for <STRONG>running unit tests to execute and validate PowerShell commands from within PowerShell</STRONG>. Pester consists of a simple set of functions that expose a testing domain-specific language (DSL) for isolating, running, evaluating and reporting the results of PowerShell commands.</P></BLOCKQUOTE>
<P>First we will use Test Cases again to quickly test a number of instances and see if any servers have a database which does not have a successful DBCC Checkdb. We will need to use the -Detailed parameter of Get-DbaLastGoddCheckDb so that we can access the status property. I have filled the $SQLServers variable with the names of my SQLServers in my lab that are running and are not my broken SQL2008 box.</P>
<P>The status property will contain one of three statements</P>
<UL>
<LI>Ok (This means that a successful test was run in the last 7 days 
<LI>New database, not checked yet 
<LI>CheckDb should be performed </LI></UL>
<P>We want to make sure that none of the results from the command have the second two statements. We can do this by adding two checks in the test and if either fails then the test will fail.</P><PRE class="lang:ps decode:true"> Describe "Testing Last Known Good DBCC" {
$SQLServers = (Get-VM -ComputerName beardnuc | Where-Object {$_.Name -like '*SQL*' -and $_.Name -ne 'SQL2008Ser2008' -and $_.State -eq 'Running'}).Name
$testCases= @()
$SQLServers.ForEach{$testCases += @{Name = $_}}
It "&lt;Name&gt; databases have all had a successful CheckDB within the last 7 days" -TestCases $testCases {
Param($Name)
$DBCC = Get-DbaLastGoodCheckDb -SqlServer $Name -Detailed
$DBCC.Status -contains 'New database, not checked yet'| Should Be $false
$DBCC.Status -contains 'CheckDb should be performed'| Should Be $false
}
}</PRE>
<P>We can save this as a .ps1 file (or we can add it to an existing Pester test file and call it will Invoke-Pester or just run it in PowerShell</P>
<P><IMG class="alignnone size-full wp-image-4559" alt="05 - dbcc pester" src="https://blog.robsewell.com/assets/uploads/2017/03/05-dbcc-pester1.png?resize=630%2C337&amp;ssl=1" width=630 height=337 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/05-dbcc-pester1.png?fit=630%2C337&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/05-dbcc-pester1.png?fit=300%2C160&amp;ssl=1" data-image-description="" data-image-title="05 – dbcc pester" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="771,412" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/05-dbcc-pester1.png?fit=771%2C412&amp;ssl=1" data-permalink="https://blog.robsewell.com/using-pester-with-get-dbalastgoodcheckdb-from-dbatools/05-dbcc-pester-2/#main" data-attachment-id="4559"></P>
<P>As you can see you will still get the same warning for the availability group databases and we can see that SQL2012Ser08AG1 has a database whose status is CheckDB should be performed and SQL2012Ser08AGN2 has a database with a status of New database, not checked yet</P>
<P>That’s good, but what if we run our DBCC Checkdbs at a different frequency and want to test that? We can also test if the databases have had a successful DBCC CheckDb&nbsp;using the&nbsp;LastGoodCheckDb&nbsp;property which will not contain a Null if there was a successful DBCC CheckDb. As Pester is PowerShell we can use</P><PRE class="lang:ps decode:true">($DBCC.LastGoodCheckDb -contains $null)</PRE>
<P>and we can use <A href="https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.utility/measure-object" target=_blank>Measure-Object</A> to get the maximum value of the DaysSinceLastGoodCheckdb property like this</P>
<DIV>
<DIV><PRE class="lang:ps decode:true">($DBCC | Measure-Object -Property&nbsp; DaysSinceLastGoodCheckdb -Maximum).Maximum</PRE></DIV></DIV>
<DIV></DIV>
<DIV>If we put those together and want to test for a successful DBCC Check DB in the last 3 days we have a test that looks like</DIV>
<DIV></DIV>
<DIV>
<DIV>
<DIV><PRE class="lang:ps decode:true">Describe "Testing Last Known Good DBCC" {
$SQLServers = (Get-VM -ComputerName beardnuc | Where-Object {$_.Name -like '*SQL*' -and $_.Name -ne 'SQL2008Ser2008' -and $_.State -eq 'Running'}).Name
$testCases= @()
$SQLServers.ForEach{$testCases += @{Name = $_}}
It "&lt;Name&gt; databases have all had a successful CheckDB" -TestCases $testCases {
Param($Name)
$DBCC = Get-DbaLastGoodCheckDb -SqlServer $Name -Detailed
($DBCC.LastGoodCheckDb -contains $null) | Should Be $false
}
It "&lt;Name&gt; databases have all had a CheckDB run in the last 3 days" -TestCases $testCases {
Param($Name)
$DBCC = Get-DbaLastGoodCheckDb -SqlServer $Name -Detailed
($DBCC | Measure-Object -Property&nbsp; DaysSinceLastGoodCheckdb -Maximum).Maximum | Should BeLessThan 3
}
}</PRE></DIV></DIV></DIV>
<DIV></DIV>
<DIV>and when we call it with invoke-Pester it looks like</DIV>
<DIV></DIV>
<DIV><IMG class="alignnone size-full wp-image-4579" alt="06 - dbcc pester.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/06-dbcc-pester.png?resize=630%2C151&amp;ssl=1" width=630 height=151 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/06-dbcc-pester.png?fit=630%2C151&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/06-dbcc-pester.png?fit=300%2C72&amp;ssl=1" data-image-description="" data-image-title="06 – dbcc pester" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="665,159" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/06-dbcc-pester.png?fit=665%2C159&amp;ssl=1" data-permalink="https://blog.robsewell.com/using-pester-with-get-dbalastgoodcheckdb-from-dbatools/06-dbcc-pester/#main" data-attachment-id="4579"></DIV>
<DIV></DIV>
<DIV>
<DIV>That’s good but it is only at an instance level. If we want our Pester Test to show results per database we can do that like this</DIV></DIV>
<DIV></DIV>
<DIV><PRE class="lang:ps decode:true">Describe "Testing Last Known Good DBCC" {
$SQLServers = (Get-VM -ComputerName beardnuc | Where-Object {$_.Name -like '*SQL*' -and $_.Name -ne 'SQL2008Ser2008' -and $_.State -eq 'Running'}).Name
foreach($Server in $SQLServers)
{
$DBCCTests = Get-DbaLastGoodCheckDb -SqlServer $Server -Detailed
foreach($DBCCTest in $DBCCTests)
{
It "$($DBCCTest.Server) database $($DBCCTest.Database) had a successful CheckDB"{
$DBCCTest.Status | Should Be 'Ok'
}
It "$($DBCCTest.Server) database $($DBCCTest.Database) had a CheckDB run in the last 3 days" {
$DBCCTest.DaysSinceLastGoodCheckdb | Should BeLessThan 3
}
It "$($DBCCTest.Server) database $($DBCCTest.Database) has Data Purity Enabled" {
$DBCCTest.DataPurityEnabled| Should Be $true
}
}
}
}</PRE></DIV>
<DIV></DIV>
<DIV>We gather the SQL instances into an array in the same way and this time we loop through each one, put the results of Get-DbaLastGoodCheckDb for that instance&nbsp;into a variable and then iterate through each result and check that the status is Ok, the DaysSinceLastGoodCheckDb is less than 3 and the DataPurityEnabled is true and we have</DIV>
<DIV></DIV>
<DIV><IMG class="alignnone size-full wp-image-4590" alt="07 - dbcc pester.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/07-dbcc-pester.png?resize=630%2C554&amp;ssl=1" width=630 height=554 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/07-dbcc-pester.png?fit=630%2C554&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/07-dbcc-pester.png?fit=300%2C264&amp;ssl=1" data-image-description="" data-image-title="07 – dbcc pester" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="698,614" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/07-dbcc-pester.png?fit=698%2C614&amp;ssl=1" data-permalink="https://blog.robsewell.com/using-pester-with-get-dbalastgoodcheckdb-from-dbatools/07-dbcc-pester/#main" data-attachment-id="4590"></DIV>
<P>&nbsp;</P>
<P>You can look at <A href="https://blog.robsewell.com/tag/pester/" target=_blank>my previous posts on using Pester </A>to see examples of creating XML files or HTML reports from the results of the tests.</P>
<P>Hopefully, as you have read this you have also thought of other ways that you can use Pester to validate the state of your environment. I would love to know how and what you do.</P>
<DIV>Happy Automating</DIV>
<DIV></DIV>
<DIV></DIV>
<DIV></DIV>
<DIV>
<P>NOTE – The major 1.0 release of dbatools due in the summer 2017 may have breaking changes which will stop the above code from working. There are also new commands coming which may replace this command. This blog post was written using dbatools version 0.8.942 You can check your version using</P><PRE class="lang:ps decode:true"> Get-Module dbatools</PRE>
<P>and update it using an Administrator PowerShell session with</P><PRE class="lang:ps decode:true"> Update-Module dbatools</PRE>
<P>You may find that you get no output from Update-Module as you have the latest version. If&nbsp;you have not installed the&nbsp;module from the PowerShell Gallery using</P><PRE class="lang:ps decode:true">Install-Module dbatools</PRE>
<P>Then you can use</P><PRE class="lang:ps decode:true">Update-dbatools</PRE></DIV>
<DIV></DIV>
<P>&nbsp;</P>
<P>&nbsp;</P>

