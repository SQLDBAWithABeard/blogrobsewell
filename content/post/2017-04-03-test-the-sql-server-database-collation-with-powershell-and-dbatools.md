---
title: "Test the SQL Server database collation with PowerShell and dbatools"
date: "2017-04-03" 
categories:
  - Blog

tags:
  - automate
  - automation
  - collation
  - dbatools
  - pester
  - PowerShell

---
<P>If your server collation is different to your database collation then you may find that you get an error similar to this</P>
<BLOCKQUOTE>
<P><I>Cannot resolve the collation conflict between “SQL_Latin1_General_CP1_CI_AS” and “Latin1_General_CI_AS” in the equal to operation.</I></P></BLOCKQUOTE>
<P>when your queries&nbsp;use the&nbsp;tempdb</P>
<P>It would be useful to be able to quickly test if that may be the case and with the <A href="https:%5C%5Cdbatools.io" target=_blank>dbatools module </A>you can. There is a <A href="https://dbatools.io/functions/test-dbadatabasecollation/" target=_blank>Test-DbaDatabaseCollation</A>&nbsp;command which will do just that. <A href="https://dbatools.io/getting-started/" target=_blank>This page</A>&nbsp;will show you how to install dbatools if you have not already got it</P>
<P>As always you should start with Get-Help when looking at a PowerShell command</P><PRE class="lang:ps decode:true">Get-Help TestDbaDatabaseCollation -ShowWindow</PRE>
<P>&nbsp;</P>
<P><IMG class="alignnone size-full wp-image-4312" alt="01 - Get Help.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/01-get-help.png?resize=630%2C596&amp;ssl=1" width=630 height=596 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/01-get-help.png?fit=630%2C596&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/01-get-help.png?fit=300%2C284&amp;ssl=1" data-image-description="" data-image-title="01 – Get Help" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="906,857" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/01-get-help.png?fit=906%2C857&amp;ssl=1" data-permalink="https://blog.robsewell.com/test-the-sql-server-database-collation-with-powershell-and-dbatools/01-get-help/#main" data-attachment-id="4312"></P>
<P>There are only 3 parameters Sqlserver, Credential and detailed</P>
<P>Lets start with SQLServer</P><PRE class="lang:ps decode:true">Test-DbaDatabaseCollation -SqlServer SQLvNextN2</PRE>
<P>this gives a quick and simple output showing the server name, database name and an IsEqual property</P>
<P><IMG class="alignnone size-full wp-image-4320" alt="02 - test server" src="https://blog.robsewell.com/assets/uploads/2017/03/02-test-server.png?resize=551%2C190&amp;ssl=1" width=551 height=190 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/02-test-server.png?fit=551%2C190&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/02-test-server.png?fit=300%2C103&amp;ssl=1" data-image-description="" data-image-title="02 – test server" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="551,190" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/02-test-server.png?fit=551%2C190&amp;ssl=1" data-permalink="https://blog.robsewell.com/test-the-sql-server-database-collation-with-powershell-and-dbatools/02-test-server/#main" data-attachment-id="4320"></P>
<P>So in this example we can see that the WideWorldImporters database does not have the same collation as the server. If we only wanted to see information about databases with a collation that does not match the server then we could use</P><PRE class="lang:ps decode:true">(Test-DbaDatabaseCollation -SqlServer SQLvNextN2).Where{$_.IsEqual -eq $false}</PRE>
<P><IMG class="alignnone size-full wp-image-4329" alt="03 - equals false" src="https://blog.robsewell.com/assets/uploads/2017/03/03-equals-false.png?resize=630%2C88&amp;ssl=1" width=630 height=88 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/03-equals-false.png?fit=630%2C88&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/03-equals-false.png?fit=300%2C42&amp;ssl=1" data-image-description="" data-image-title="03 – equals false" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="782,109" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/03-equals-false.png?fit=782%2C109&amp;ssl=1" data-permalink="https://blog.robsewell.com/test-the-sql-server-database-collation-with-powershell-and-dbatools/03-equals-false/#main" data-attachment-id="4329"></P>
<P>That doesn’t give us any further information though. There is the detailed parameter as well. Lets see what that does</P><PRE class="lang:ps decode:true">&nbsp;Test-DbaDatabaseCollation -SqlServer SQLvNextN2 -Detailed</PRE>
<P><IMG class="alignnone size-full wp-image-4335" alt="04 - detailed.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/04-detailed.png?resize=625%2C665&amp;ssl=1" width=625 height=665 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/04-detailed.png?fit=625%2C665&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/04-detailed.png?fit=282%2C300&amp;ssl=1" data-image-description="" data-image-title="04 – detailed" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="625,665" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/04-detailed.png?fit=625%2C665&amp;ssl=1" data-permalink="https://blog.robsewell.com/test-the-sql-server-database-collation-with-powershell-and-dbatools/04-detailed/#main" data-attachment-id="4335"></P>
<P>This time we get the server name, server collation, database name , database collation and the IsEqual property. This is a collection of objects so we are not bound be just seeing them on the screen we can use them as <A href="https://blog.robsewell.com/taking-dbatools-test-dbalastbackup-a-little-further/">I blogged about here</A></P>
<P>For example</P>
<DIV>
<DIV><PRE class="lang:ps decode:true">&nbsp;## Output to a file
Test-DbaDatabaseCollation -SqlServer SQLvNextN2 -Detailed |Out-File C:\Temp\CollationCheck.txt
## Output to CSV
Test-DbaDatabaseCollation -SqlServer SQLvNextN2 -Detailed |Export-Csv&nbsp; C:\temp\CollationCheck.csv -NoTypeInformation
&lt;## Output to JSON
Test-DbaDatabaseCollation -SqlServer SQLvNextN2 -Detailed | ConvertTo-Json | Out-file c:\temp\CollationCheck.json
## Look at the files
notepad C:\temp\CollationCheck.json
notepad C:\temp\CollationCheck.csv
notepad C:\temp\CollationCheck.txt
</PRE></DIV></DIV>
<DIV></DIV>
<P>Of course, you will probably want to test more than one server at a time. Lets pass an array of servers and see what happens</P>
<DIV></DIV>
<DIV>
<DIV>
<DIV><PRE class="lang:ps decode:true">$SQLServers = (Get-VM -ComputerName beardnuc | Where-Object {$_.Name -like '*SQL*' -and $_.Name -ne 'SQL2008Ser2008' -and $_.State -eq 'Running'}).Name
# Test Db collation
Test-DbaDatabaseCollation -SqlServer $SQLServers -Detailed&nbsp;
</PRE></DIV></DIV></DIV>
<DIV></DIV>
<DIV><IMG class="alignnone size-full wp-image-4346" alt="05 - servers.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/05-servers.png?resize=630%2C307&amp;ssl=1" width=630 height=307 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/05-servers.png?fit=630%2C307&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/05-servers.png?fit=300%2C146&amp;ssl=1" data-image-description="" data-image-title="05 – servers" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1261,615" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/05-servers.png?fit=1261%2C615&amp;ssl=1" data-permalink="https://blog.robsewell.com/test-the-sql-server-database-collation-with-powershell-and-dbatools/05-servers/#main" data-attachment-id="4346"></DIV>
<DIV></DIV>
<P>In this example, I am querying my Hyper-V server for all VMs with SQL in the name,except for my broken SQL2008 box ,that are running. I love PowerShell’s Out-GridView command for many reasons. The ability to&nbsp;sort by columns quickly and simply is one of them. Lets add that to the code and sort by the IsEquals column</P>
<DIV>
<DIV><PRE class="lang:ps decode:true">$SQLServers = (Get-VM -ComputerName beardnuc | Where-Object {$_.Name -like '*SQL*' -and $_.Name -ne 'SQL2008Ser2008' -and $_.State -eq 'Running'}).Name
# Test Db collation
Test-DbaDatabaseCollation -SqlServer $SQLServers -Detailed | Out-GridView
</PRE></DIV></DIV>
<DIV><IMG class="alignnone size-full wp-image-4354" alt="06 - servers ogv.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/06-servers-ogv.png?resize=630%2C316&amp;ssl=1" width=630 height=316 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/06-servers-ogv.png?fit=630%2C316&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/06-servers-ogv.png?fit=300%2C150&amp;ssl=1" data-image-description="" data-image-title="06 – servers ogv" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1259,631" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/06-servers-ogv.png?fit=1259%2C631&amp;ssl=1" data-permalink="https://blog.robsewell.com/test-the-sql-server-database-collation-with-powershell-and-dbatools/06-servers-ogv/#main" data-attachment-id="4354"></DIV>
<DIV></DIV>
<P>Excellent, that works a treat. How about Linux? Does this work if SQL is running on Linux? We will have to use the credential parameter as we need SQL Authentication. this time I have used the <A href="https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.utility/format-table" target=_blank>Format-Table </A>command to format the output.</P>
<DIV>
<DIV>
<DIV><PRE class="lang:ps decode:true">$cred = Get-Credential
Test-DbaDatabaseCollation -SqlServer LinuxvNextCTP14 -Credential $cred -Detailed | Format-Table -AutoSize
</PRE></DIV>
<DIV></DIV></DIV></DIV>
<DIV><IMG class="alignnone size-full wp-image-4363" alt="07 - Linux.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/07-linux.png?resize=630%2C339&amp;ssl=1" width=630 height=339 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/07-linux.png?fit=630%2C339&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/07-linux.png?fit=300%2C161&amp;ssl=1" data-image-description="" data-image-title="07 – Linux" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="843,453" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/07-linux.png?fit=843%2C453&amp;ssl=1" data-permalink="https://blog.robsewell.com/test-the-sql-server-database-collation-with-powershell-and-dbatools/07-linux/#main" data-attachment-id="4363"></DIV>
<DIV></DIV>
<P>Lets add some <A href="https://github.com/pester" target=_blank>Pester</A> tests. If we want to test a list of servers and see if any of their databases have an incorrect collation we can simply test if the IsEquals flag contains a false.</P>
<DIV></DIV>
<P>We can do this using TestCases. Test cases allow Pester to loop through a collection of ‘things’ The testcases parameter takes an array of hashtables. This all sounds very complicated to those unclear about PowerShell but here some code to do it.</P>
<DIV></DIV>
<DIV>
<DIV>
<DIV><PRE class="lang:ps decode:true">$SQLServers = (Get-VM -ComputerName beardnuc | Where-Object {$_.Name -like '*SQL*' -and $_.Name -ne 'SQL2008Ser2008' -and $_.State -eq 'Running'}).Name
$testCases= @()
$SQLServers.ForEach{$testCases += @{Name = $_}}
</PRE></DIV></DIV></DIV>
<DIV></DIV>
<P>The first line&nbsp;gathers the list of SQL Servers from the Hyper-V as before. You can get this from a text file, csv, Active Directory, CMS, registered servers list. The second line initiates the TestCases array and the third line iterates through the list of servers and adds a hashtable to the TestCases array</P>
<DIV></DIV>
<P>To make use of the test cases we have to use the -TestCases parameter in our It block of our Pester Test and add a param() so that the test knows where to get the values from. To add the value from the test cases into the title of the test we need to reference it inside &lt;&gt;</P>
<DIV></DIV>
<P>If you want to learn more about Pester. I highly recommend <A href="https://leanpub.com/the-pester-book" target=_blank>The Pester Book</A> by Don Jones and Adam Bertram</P>
<DIV></DIV>
<P>Here is the code</P>
<DIV><PRE class="lang:ps decode:true">Describe "Testing Database Collation" {
&nbsp;&nbsp;&nbsp; $SQLServers = (Get-VM -ComputerName beardnuc | Where-Object {$_.Name -like '*SQL*' -and $_.Name -ne 'SQL2008Ser2008' -and $_.State -eq 'Running'}).Name
&nbsp;&nbsp;&nbsp; $testCases= @()
&nbsp;&nbsp;&nbsp; $SQLServers.ForEach{$testCases += @{Name = $_}}
&nbsp;&nbsp;&nbsp; It "&lt;Name&gt; databases have the right collation" -TestCases $testCases {
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Param($Name)
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; $Collation = Test-DbaDatabaseCollation -SqlServer $Name
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; $Collation.IsEqual -contains $false | Should Be $false
&nbsp;&nbsp;&nbsp; }
}
</PRE></DIV>
<P>If we save that as a PowerShell file, we can call it with Invoke-Pester</P>
<DIV></DIV>
<P><IMG class="alignnone size-full wp-image-4389" alt="08 - Servers Pester.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/08-servers-pester.png?resize=591%2C721&amp;ssl=1" width=591 height=721 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/08-servers-pester.png?fit=591%2C721&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/08-servers-pester.png?fit=246%2C300&amp;ssl=1" data-image-description="" data-image-title="08 – Servers Pester" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="591,721" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/08-servers-pester.png?fit=591%2C721&amp;ssl=1" data-permalink="https://blog.robsewell.com/test-the-sql-server-database-collation-with-powershell-and-dbatools/08-servers-pester/#main" data-attachment-id="4389"></P>
<P>which shows which servers do not have databases with the correct collation. This may be all that is required but what about if you want to check each database on each server with Pester?</P>
<P>I could not see a way to do this with TestCases so I reverted to PowerShell. Pester is just PowerShell code after all.</P>
<DIV>
<DIV><PRE class="lang:ps decode:true">Describe "Testing Database Collation" {
&nbsp;&nbsp;&nbsp; $SQLServers = (Get-VM -ComputerName beardnuc | Where-Object {$_.Name -like '*SQL*' -and $_.Name -ne 'SQL2008Ser2008' -and $_.State -eq 'Running'}).Name
&nbsp;&nbsp;&nbsp; foreach($Server in $SQLServers)
&nbsp;&nbsp;&nbsp; {
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; $CollationTests = Test-DbaDatabaseCollation -SqlServer $Server
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; foreach($CollationTest in $CollationTests)
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; {
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; It "$($Collationtest.Server) database $($CollationTest.Database) should have the correct collation" {
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; $CollationTest.IsEqual | Should Be $true
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }
&nbsp;&nbsp;&nbsp; }
}
</PRE></DIV></DIV>
<DIV></DIV>
<P>In this example, we again gather the names of our SQL servers and then iterate through them. Then set the results&nbsp;of the Test-DBADatabaseCollation to a variable and iterate through each of the results and test the IsEquals property. We can save that as a file and call it with Invoke-Pester and this time it looks like</P>
<DIV></DIV>
<DIV><IMG class="alignnone size-full wp-image-4403" alt="09 - Individual databases.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/09-individual-databases.png?resize=630%2C435&amp;ssl=1" width=630 height=435 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/09-individual-databases.png?fit=630%2C435&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/09-individual-databases.png?fit=300%2C207&amp;ssl=1" data-image-description="" data-image-title="09 – Individual databases" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="705,487" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/09-individual-databases.png?fit=705%2C487&amp;ssl=1" data-permalink="https://blog.robsewell.com/test-the-sql-server-database-collation-with-powershell-and-dbatools/09-individual-databases/#main" data-attachment-id="4403"></DIV>
<DIV></DIV>
<P>Excellent we can quickly and easily see which database on which server doesnot have a matching collation. We cant see in the results&nbsp;of the Pester test what collation it should be though. Lets do that as well.</P>
<P>This time we need to use the Detailed parameter and test that the ServerCollation matches the DatabaseCollation. This will enable Pester to display that information to us. Here is the code</P>
<DIV>
<DIV>
<DIV><PRE class="lang:ps decode:true">Describe "Testing Database Collation" {
&nbsp;&nbsp;&nbsp; $SQLServers = (Get-VM -ComputerName beardnuc | Where-Object {$_.Name -like '*SQL*' -and $_.Name -ne 'SQL2008Ser2008' -and $_.State -eq 'Running'}).Name
&nbsp;&nbsp;&nbsp; foreach($Server in $SQLServers)
&nbsp;&nbsp;&nbsp; {
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; $CollationTests = Test-DbaDatabaseCollation -SqlServer $Server -Detailed
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; foreach($CollationTest in $CollationTests)
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; {
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; It "$($Collationtest.Server) database $($CollationTest.Database) should have the correct collation of $($CollationTest.ServerCollation)" {
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; $CollationTest.DatabaseCollation | Should Be $CollationTest.ServerCollation
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }
&nbsp;&nbsp;&nbsp; }
}
</PRE></DIV></DIV></DIV>
<DIV></DIV>
<DIV>and if we save that as a file and call it with invoke-Pester (you can just run the code using PowerShell as well) it looks like this</DIV>
<DIV></DIV>
<DIV><IMG class="alignnone size-full wp-image-4415" alt="10 - full test.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/10-full-test.png?resize=630%2C360&amp;ssl=1" width=630 height=360 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/10-full-test.png?fit=630%2C360&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/10-full-test.png?fit=300%2C171&amp;ssl=1" data-image-description="" data-image-title="10 – full test" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="853,487" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/10-full-test.png?fit=853%2C487&amp;ssl=1" data-permalink="https://blog.robsewell.com/test-the-sql-server-database-collation-with-powershell-and-dbatools/10-full-test/#main" data-attachment-id="4415"></DIV>
<DIV></DIV>
<P>Now&nbsp;Pester shows us what collation it is expecting and what the collation of the database is as well when it fails the test. (I love the little arrow showing where the difference is!)</P>
<P>Hopefully this post has shown you how you can use <A href="https://dbatools.io/functions/test-dbadatabasecollation/" target=_blank><SPAN style="COLOR: #0066cc">Test-DbaDatabaseCollation</SPAN></A>&nbsp;from the <A href="https:%5C%5Cdbatools.io" target=_blank><SPAN style="COLOR: #0066cc">dbatools module </SPAN></A>to test your servers and combine that with Pester. If you have any questions about the dbatools module go and ask in the dbatools channel in the <A href="https://dbatools.io/slack" target=_blank>SQL Community Slack channel</A></P>
<DIV></DIV>
<DIV></DIV>
<DIV></DIV>

