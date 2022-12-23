---
title: "Testing the Identity Column usage in SQL Server with PowerShell and dbatools"
date: "2017-04-07" 
categories:
  - Blog

tags:
  - automate
  - automation
  - databases
  - dbatools
  - identity

---
<P>SQL Server uses identity columns to auto generate values, normally keys. When you create an identity column, it has a data type and that data type has a maximum number of values.</P>
<UL>
<LI>BigInt 9,223,372,036,854,775,808 
<LI>Int 2,147,483,647 
<LI>SmallInt 32,767 
<LI>tinyint 255 </LI></UL>
<P>What happens when you try to insert a value in an identity column that is greater than the maximum value? You get an error and a failed transaction. Lets do that</P>
<P>Using AdventureWorks, I know (I’ll show how in a minute) that the HumanResources.Shift column is a tinyint. So the highest value for the ShiftID column is 255.</P>
<P>If we run</P><PRE class="theme:classic lang:tsql decode:true">USE AdventureWorks2014;
GO
INSERT INTO [HumanResources].[Shift]
([Name]
,[StartTime]
,[EndTime]
,[ModifiedDate])
VALUES
( 'Made Up SHift ' + CAST(NEWID() AS nvarchar(MAX))
,DATEADD(hour,-4, GetDate())
,'07:00:00.0000000'
,GetDate())
WAITFOR DELAY '00:00:00.050';
GO 252</PRE>
<DIV></DIV>
<DIV>Adding a number after GO says run this that many times, so we have added 252 rows to the existing 3 rows.</DIV>
<DIV></DIV>
<DIV><IMG class="alignnone size-full wp-image-4621" alt="01 - maxx value.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/01-maxx-value.png?resize=630%2C259&amp;ssl=1" width=630 height=259 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/01-maxx-value.png?fit=630%2C259&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/01-maxx-value.png?fit=300%2C123&amp;ssl=1" data-image-description="" data-image-title="01 – maxx value" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1032,424" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/01-maxx-value.png?fit=1032%2C424&amp;ssl=1" data-permalink="https://blog.robsewell.com/testing-the-identity-column-usage-in-sql-server-with-powershell-and-dbatools/01-maxx-value/#main" data-attachment-id="4621"></DIV>
<P>&nbsp;</P>
<P>So what happens if we try to add another row?</P><PRE class="theme:classic lang:tsql decode:true">USE AdventureWorks2014;
GO
INSERT INTO [HumanResources].[Shift]
([Name]
,[StartTime]
,[EndTime]
,[ModifiedDate])
VALUES
( 'Made Up SHift ' + CAST(NEWID() AS nvarchar(MAX))
,DATEADD(hour,-4, GetDate())
,'07:00:00.0000000'
,GetDate())
GO</PRE>
<DIV></DIV>
<DIV><IMG class="alignnone size-full wp-image-4626" alt="02- error.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/02-error1.png?resize=630%2C402&amp;ssl=1" width=630 height=402 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/02-error1.png?fit=630%2C402&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/02-error1.png?fit=300%2C191&amp;ssl=1" data-image-description="" data-image-title="02- error" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1317,840" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/02-error1.png?fit=1317%2C840&amp;ssl=1" data-permalink="https://blog.robsewell.com/testing-the-identity-column-usage-in-sql-server-with-powershell-and-dbatools/02-error-2/#main" data-attachment-id="4626"></DIV>
<DIV></DIV>
<DIV>We get an error</DIV>
<DIV></DIV>
<BLOCKQUOTE>
<DIV>Msg 8115, Level 16, State 1, Line 4<BR>Arithmetic overflow error converting IDENTITY to data type tinyint.<BR>Arithmetic overflow occurred.</DIV></BLOCKQUOTE>
<DIV>If that is a table that is important to your system, a logging table or worse, an order table then there is quickly going to be phone calls, visits to your desks, arm waving etc until you get it resolved. Lets clean up our mess</DIV>
<DIV></DIV>
<DIV>
<DIV><PRE class="theme:classic lang:tsql decode:true">USE AdventureWorks2014
GO
DELETE FROM HumanResources.Shift
WHERE ShiftId &amp;gt; 3
GO
DBCC CHECKIDENT ('HumanResources.Shift', RESEED, 3)
GO</PRE></DIV></DIV>
<DIV></DIV>
<DIV>It would be very useful to be able to quickly see what the current values of the identity columns are and how close they are to being full so that we can plan for and be able to take action before we end up with shouty smart suits at our desk. If we could do it with just one line of code that would be even easier.</DIV>
<DIV></DIV>
<DIV>Step forward <A href="https://dbatools.io" target=_blank>dbatools</A>.&nbsp; This PowerShell&nbsp;module is a community based project written by excellent, brilliant people in their own time and available to you free. To find out more and how to use and install it visit <A href="https://dbatools.io" target=_blank><SPAN style="COLOR: #0066cc">https://dbatools.io</SPAN></A></DIV>
<DIV></DIV>
<DIV>There is a command called <A href="https://dbatools.io/functions/test-dbaidentityusage/" target=_blank>Test-DbaIdentityUsage</A> This command was created by Brandon Abshire. You can find Brandon blogging at <A href="https://netnerds.net/author/brandon"><SPAN style="COLOR: #012456">netnerds.net</SPAN></A>. Thank you Brandon</DIV>
<DIV></DIV>
<DIV>As always with a new PowerShell command you should always start with Get-Help</DIV>
<DIV></DIV>
<DIV><PRE class="lang:ps decode:true">Get-Help Test-DbaIdentityUsage -ShowWindow</PRE></DIV>
<DIV></DIV>
<DIV><IMG class="alignnone size-full wp-image-4646" alt="03 - get help.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/03-get-help.png?resize=630%2C434&amp;ssl=1" width=630 height=434 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/03-get-help.png?fit=630%2C434&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/03-get-help.png?fit=300%2C207&amp;ssl=1" data-image-description="" data-image-title="03 – get help" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1863,1284" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/03-get-help.png?fit=1863%2C1284&amp;ssl=1" data-permalink="https://blog.robsewell.com/testing-the-identity-column-usage-in-sql-server-with-powershell-and-dbatools/03-get-help/#main" data-attachment-id="4646"></DIV>
<DIV></DIV>
<P>&nbsp;</P>
<P>The command has a few parameters</P>
<UL>
<LI>SqlInstance – One or many Instances 
<LI>SqlCredential – for SQL Authentication 
<LI>Databases – to filter for databases ( This is a dynamic parameter and doesn’t show in the Help) 
<LI>Threshold – define a minimum percentage for how full the identity column is 
<LI>NoSystemDB – to ignore the system databases </LI></UL>
<P>So we can run the command against one instance</P><PRE class="lang:ps decode:true">Test-DbaIdentityUsage -SqlInstance sql2014ser12r2</PRE>
<P>&nbsp;</P>
<P><IMG class="alignnone size-full wp-image-4657" alt="04 - one server.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/04-one-server.png?resize=630%2C347&amp;ssl=1" width=630 height=347 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/04-one-server.png?fit=630%2C347&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/04-one-server.png?fit=300%2C165&amp;ssl=1" data-image-description="" data-image-title="04 – one server" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1255,691" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/04-one-server.png?fit=1255%2C691&amp;ssl=1" data-permalink="https://blog.robsewell.com/testing-the-identity-column-usage-in-sql-server-with-powershell-and-dbatools/04-one-server/#main" data-attachment-id="4657"></P>
<P>This returns an object for each identity column in each database on the instance. The object has the following properties</P>
<P>ComputerName&nbsp;&nbsp; : SQL2014SER12R2<BR>InstanceName&nbsp;&nbsp; : MSSQLSERVER<BR>SqlInstance&nbsp;&nbsp;&nbsp; : SQL2014SER12R2<BR>Database&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; : AdventureWorks2014<BR>Schema&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; : HumanResources<BR>Table&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; : Shift<BR>Column&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; : ShiftID<BR>SeedValue&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; : 1<BR>IncrementValue : 1<BR>LastValue&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; : 3<BR>MaxNumberRows&nbsp; : 254<BR>NumberOfUses&nbsp;&nbsp; : 3<BR>PercentUsed&nbsp;&nbsp;&nbsp; : 1.18</P>
<P>We can use the objects returned from this command in a number of ways, this is one of the beauties of PowerShell that we can interact with numerous systems. I have blogged about some simple ways of&nbsp;<A href="https://blog.robsewell.com/taking-dbatools-test-dbalastbackup-a-little-further/">doing this here</A> but your only limit is your imagination.</P>
<P>I love to use <A href="https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.utility/out-gridview" target=_blank>Out-GridView </A>as it enables quick and easy sorting of the returned data</P>
<P><IMG class="alignnone size-full wp-image-4667" alt="06 - ogv filter.gif" src="https://blog.robsewell.com/assets/uploads/2017/03/06-ogv-filter.gif?resize=630%2C274&amp;ssl=1" width=630 height=274 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/06-ogv-filter.gif?fit=630%2C274&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/06-ogv-filter.gif?fit=300%2C131&amp;ssl=1" data-image-description="" data-image-title="06 – ogv filter" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="2600,1132" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/06-ogv-filter.gif?fit=2600%2C1132&amp;ssl=1" data-permalink="https://blog.robsewell.com/testing-the-identity-column-usage-in-sql-server-with-powershell-and-dbatools/06-ogv-filter/#main" data-attachment-id="4667"></P>
<P>The databases parameter is dynamic so it will prefill the names of the databases on the instance. This is what it looks like in <A href="https://code.visualstudio.com/" target=_blank>VS Code</A></P>
<P><IMG class="alignnone size-full wp-image-4672" alt="07 vscode tab.gif" src="https://blog.robsewell.com/assets/uploads/2017/03/07-vscode-tab.gif?resize=630%2C245&amp;ssl=1" width=630 height=245 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/07-vscode-tab.gif?fit=630%2C245&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/07-vscode-tab.gif?fit=300%2C117&amp;ssl=1" data-image-description="" data-image-title="07 vscode tab" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="2908,1132" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/07-vscode-tab.gif?fit=2908%2C1132&amp;ssl=1" data-permalink="https://blog.robsewell.com/testing-the-identity-column-usage-in-sql-server-with-powershell-and-dbatools/07-vscode-tab/#main" data-attachment-id="4672"></P>
<P>&nbsp;</P>
<P>and in ISE</P>
<P><IMG class="alignnone size-full wp-image-4673" alt="08 ise tab.gif" src="https://blog.robsewell.com/assets/uploads/2017/03/08-ise-tab.gif?resize=630%2C266&amp;ssl=1" width=630 height=266 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/08-ise-tab.gif?fit=630%2C266&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/08-ise-tab.gif?fit=300%2C127&amp;ssl=1" data-image-description="" data-image-title="08 ise tab" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="2908,1230" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/08-ise-tab.gif?fit=2908%2C1230&amp;ssl=1" data-permalink="https://blog.robsewell.com/testing-the-identity-column-usage-in-sql-server-with-powershell-and-dbatools/08-ise-tab/#main" data-attachment-id="4673"></P>
<P>&nbsp;</P>
<P>We can use the threshold parameter to only show results for the identity columns whose value is above a percent of the max value for the column. Lets fill the ShiftId column to above 90% and show this</P><PRE class="theme:classic lang:tsql decode:true">USE AdventureWorks2014;
GO
INSERT INTO [HumanResources].[Shift]
([Name]
 ,[StartTime]
,[EndTime]
,[ModifiedDate])
VALUES
( 'Made Up SHift ' + CAST(NEWID() AS nvarchar(MAX))
,DATEADD(hour,-4, GetDate())
,'07:00:00.0000000'
,GetDAte())
WAITFOR DELAY '00:00:00.050';
GO 230</PRE>
<P>and now run</P><PRE class="lang:ps decode:true">Test-DbaIdentityUsage -SqlInstance sql2014ser12r2&amp;nbsp; -Threshold 90</PRE>
<P><IMG class="alignnone size-full wp-image-4685" alt="08 - threshold.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/08-threshold.png?resize=630%2C318&amp;ssl=1" width=630 height=318 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/08-threshold.png?fit=630%2C318&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/08-threshold.png?fit=300%2C151&amp;ssl=1" data-image-description="" data-image-title="08 – threshold" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1559,787" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/08-threshold.png?fit=1559%2C787&amp;ssl=1" data-permalink="https://blog.robsewell.com/testing-the-identity-column-usage-in-sql-server-with-powershell-and-dbatools/08-threshold/#main" data-attachment-id="4685"></P>
<P>Don’t forget to use the cleanup script. You can pass a whole array of SQL instances to the command. We can pass an array of SQL servers to this command as well and check multiple servers at the same time. In this example, I am querying my Hyper-V server for all VMs with SQL in the name,except for my broken SQL2008 box ,that are running.&nbsp;Just to get some results I will set the threshold to 1</P>
<DIV>
<DIV><PRE class="lang:ps decode:true">$SQLServers = (Get-VM -ComputerName beardnuc | Where-Object {$_.Name -like '*SQL*' -and $_.Name -ne 'SQL2008Ser2008' -and $_.State -eq 'Running'}).Name
Test-DbaIdentityUsage -SqlInstance $SQLServers -Threshold 1 | Out-GridView</PRE></DIV></DIV>
<DIV></DIV>
<DIV><IMG class="alignnone size-full wp-image-4702" alt="10 ogv thredshold.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/10-ogv-thredshold.png?resize=630%2C183&amp;ssl=1" width=630 height=183 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/10-ogv-thredshold.png?fit=630%2C183&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/10-ogv-thredshold.png?fit=300%2C87&amp;ssl=1" data-image-description="" data-image-title="10 ogv thredshold" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="2998,872" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/10-ogv-thredshold.png?fit=2998%2C872&amp;ssl=1" data-permalink="https://blog.robsewell.com/testing-the-identity-column-usage-in-sql-server-with-powershell-and-dbatools/10-ogv-thredshold/#main" data-attachment-id="4702"></DIV>
<DIV></DIV>
<DIV>As you can see this function does not support SQL instances lower than SQL 2008 and you will get warnings for availability group databases</DIV>
<DIV></DIV>
<DIV>It’s quick too, finishing in less than 2 seconds in my lab of 10 SQL Servers and 125 databases. The WarningAction SilentlyContinue supresses the yellow warnings</DIV>
<DIV></DIV>
<DIV><IMG class="alignnone size-full wp-image-4707" alt="11 - measure command.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/11-measure-command.png?resize=630%2C193&amp;ssl=1" width=630 height=193 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/11-measure-command.png?fit=630%2C193&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/11-measure-command.png?fit=300%2C92&amp;ssl=1" data-image-description="" data-image-title="11 – measure command" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="2141,655" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/11-measure-command.png?fit=2141%2C655&amp;ssl=1" data-permalink="https://blog.robsewell.com/testing-the-identity-column-usage-in-sql-server-with-powershell-and-dbatools/11-measure-command/#main" data-attachment-id="4707"></DIV>
<DIV>This is ideal for using <A href="https://dbatools.io" target=_blank>Pester</A> to test.</DIV>
<DIV></DIV>
<DIV><PRE class="lang:ps decode:true"> Describe "Testing how full the Identity columns are" {
$SQLServers = (Get-VM -ComputerName beardnuc | Where-Object {$_.Name -like '*SQL*' -and $_.Name -ne 'SQL2008Ser2008' -and $_.State -eq 'Running'}).Name
$testCases= @()
$SQLServers.ForEach{$testCases += @{Name = $_}}
It "&lt;Name&gt; databases all have identity columns less than 90% full" -TestCases $testCases {
Param($Name)
(Test-DbaIdentityUsage -SqlInstance $Name -Threshold 90 -WarningAction SilentlyContinue).PercentUsed | Should Be
}
}</PRE></DIV>
<DIV></DIV>
<DIV><IMG class="alignnone size-full wp-image-4715" alt="12 pester test.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/12-pester-test.png?resize=630%2C216&amp;ssl=1" width=630 height=216 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/12-pester-test.png?fit=630%2C216&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/12-pester-test.png?fit=300%2C103&amp;ssl=1" data-image-description="" data-image-title="12 pester test" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="2579,885" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/12-pester-test.png?fit=2579%2C885&amp;ssl=1" data-permalink="https://blog.robsewell.com/testing-the-identity-column-usage-in-sql-server-with-powershell-and-dbatools/12-pester-test/#main" data-attachment-id="4715"></DIV>
<DIV></DIV>
<DIV>An excellent quick test but it doesn’t show us which databases have failed. We can iterate through our servers and databases like this</DIV>
<DIV></DIV>
<DIV><PRE class="lang:ps decode:true">Describe&nbsp;"Testing&nbsp;how&nbsp;full&nbsp;the&nbsp;Identity&nbsp;columns&nbsp;are"&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;$SQLServers&nbsp;=&nbsp;(Get-VM&nbsp;-ComputerName&nbsp;beardnuc&nbsp;|&nbsp;Where-Object&nbsp;{$_.Name&nbsp;-like&nbsp;'*SQL*'&nbsp;-and&nbsp;$_.Name&nbsp;-ne&nbsp;'SQL2008Ser2008'&nbsp;-and&nbsp;$_.State&nbsp;-eq&nbsp;'Running'}).Name
&nbsp;&nbsp;&nbsp;&nbsp;foreach($SQLServer&nbsp;in&nbsp;$SQLServers)
&nbsp;&nbsp;&nbsp;&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Context&nbsp;"Testing&nbsp;$SQLServer"&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$dbs&nbsp;=&nbsp;(Connect-DbaSqlServer&nbsp;-SqlServer&nbsp;$SQLServer).Databases.Name
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;foreach($db&nbsp;in&nbsp;$dbs)
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;It&nbsp;"$db&nbsp;on&nbsp;$SQLServer&nbsp;identity&nbsp;columns&nbsp;are&nbsp;less&nbsp;than&nbsp;90%&nbsp;full"&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(Test-DbaIdentityUsage&nbsp;-SqlInstance&nbsp;$SQLServer&nbsp;-Databases&nbsp;$db&nbsp;-Threshold&nbsp;90&nbsp;-WarningAction&nbsp;SilentlyContinue).PercentUsed&nbsp;|&nbsp;Should&nbsp;Be
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}
&nbsp;&nbsp;&nbsp;&nbsp;}
}</PRE></DIV>
<DIV></DIV>
<DIV>This is using the Connect-DbaSqlServer to create a SMO object and then gathering the databases on the server into a variable and iterating through them</DIV>
<DIV></DIV>
<DIV>It looks like this when it is running</DIV>
<DIV></DIV>
<DIV><IMG class="alignnone size-full wp-image-4722" alt="13 - pester test.png" src="https://blog.robsewell.com/assets/uploads/2017/03/13-pester-test.png?resize=630%2C300&amp;ssl=1" width=630 height=300 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/13-pester-test.png?fit=630%2C300&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/13-pester-test.png?fit=300%2C143&amp;ssl=1" data-image-description="" data-image-title="13 – pester test" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="2974,1416" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/13-pester-test.png?fit=2974%2C1416&amp;ssl=1" data-permalink="https://blog.robsewell.com/testing-the-identity-column-usage-in-sql-server-with-powershell-and-dbatools/13-pester-test/#main" data-attachment-id="4722"></DIV>
<DIV></DIV>
<DIV>and at the end gives you a little overview of the number of tests that have failed</DIV>
<DIV></DIV>
<DIV><IMG class="alignnone size-full wp-image-4724" alt="14 end of pester test.png" src="https://blog.robsewell.com/assets/uploads/2017/03/14-end-of-pester-test.png?resize=630%2C300&amp;ssl=1" width=630 height=300 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/14-end-of-pester-test.png?fit=630%2C300&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/14-end-of-pester-test.png?fit=300%2C143&amp;ssl=1" data-image-description="" data-image-title="14 end of pester test" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="2974,1416" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/14-end-of-pester-test.png?fit=2974%2C1416&amp;ssl=1" data-permalink="https://blog.robsewell.com/testing-the-identity-column-usage-in-sql-server-with-powershell-and-dbatools/14-end-of-pester-test/#main" data-attachment-id="4724"></DIV>
<DIV></DIV>
<DIV>In a <A href="https://blog.robsewell.com/using-pester-with-dbatools-test-dbalastbackup/" target=_blank>previous post</A> I showed how you can output these results to XML or even make a HTML page showing the output</DIV>
<DIV></DIV>
<DIV>But perhaps that isn’t granular enough for you and you want a test for each column. This is how you could do that</DIV>
<DIV></DIV>
<DIV>
<DIV>
<DIV><PRE class="lang:ps decode:true">$SQLServers&nbsp;=&nbsp;(Get-VM&nbsp;-ComputerName&nbsp;beardnuc&nbsp;|&nbsp;Where-Object&nbsp;{$_.Name&nbsp;-like&nbsp;'*SQL*'&nbsp;-and&nbsp;$_.Name&nbsp;-ne&nbsp;'SQL2008Ser2008'&nbsp;-and&nbsp;$_.State&nbsp;-eq&nbsp;'Running'}).Name
foreach($SQLServer&nbsp;in&nbsp;$SQLServers)
{
&nbsp;&nbsp;&nbsp;&nbsp;Describe&nbsp;"$SQLServer&nbsp;-&nbsp;Testing&nbsp;how&nbsp;full&nbsp;the&nbsp;Identity&nbsp;columns&nbsp;are"&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$dbs&nbsp;=&nbsp;(Connect-DbaSqlServer&nbsp;-SqlServer&nbsp;$SQLServer).Databases.Name
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;foreach($db&nbsp;in&nbsp;$dbs)
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Context&nbsp;"Testing&nbsp;$db"&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$Tests&nbsp;=&nbsp;Test-DbaIdentityUsage&nbsp;-SqlInstance&nbsp;$SQLServer&nbsp;-Databases&nbsp;$db&nbsp;-WarningAction&nbsp;SilentlyContinue
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;foreach($test&nbsp;in&nbsp;$tests)
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;It&nbsp;"$($test.Column)&nbsp;identity&nbsp;column&nbsp;in&nbsp;$($Test.Table)&nbsp;is&nbsp;less&nbsp;than&nbsp;90%&nbsp;full"&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$Test.PercentUsed&nbsp;|&nbsp;Should&nbsp;BeLessThan&nbsp;90
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}
&nbsp;&nbsp;&nbsp;&nbsp;}
}</PRE></DIV></DIV></DIV>
<DIV></DIV>
<DIV>Which looks like this, a test for each identity column in each database in each server in your environment</DIV>
<DIV></DIV>
<DIV><IMG class="alignnone size-full wp-image-4733" alt="15 every pester teest.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/15-every-pester-teest.png?resize=630%2C351&amp;ssl=1" width=630 height=351 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/15-every-pester-teest.png?fit=630%2C351&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/15-every-pester-teest.png?fit=300%2C167&amp;ssl=1" data-image-description="" data-image-title="15 every pester teest" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1972,1100" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/15-every-pester-teest.png?fit=1972%2C1100&amp;ssl=1" data-permalink="https://blog.robsewell.com/testing-the-identity-column-usage-in-sql-server-with-powershell-and-dbatools/15-every-pester-teest/#main" data-attachment-id="4733"></DIV>
<P>&nbsp;</P>
<P>The other question that we have to answer these days is – Does it work with SQL on Linux? We will have to pass a SQL authentication credential and this time I will use Format-Table for the output</P><PRE class="lang:ps decode:true">&nbsp;Test-DbaIdentityUsage -SqlInstance LinuxvNextCTP14 -SqlCredential (Get-Credential) | Format-Table</PRE>
<P><IMG class="alignnone size-full wp-image-4737" alt="16 - on Linux.PNG" src="https://blog.robsewell.com/assets/uploads/2017/03/16-on-linux.png?resize=630%2C243&amp;ssl=1" width=630 height=243 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/16-on-linux.png?fit=630%2C243&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/16-on-linux.png?fit=300%2C116&amp;ssl=1" data-image-description="" data-image-title="16 – on Linux" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="2848,1099" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/16-on-linux.png?fit=2848%2C1099&amp;ssl=1" data-permalink="https://blog.robsewell.com/testing-the-identity-column-usage-in-sql-server-with-powershell-and-dbatools/16-on-linux/#main" data-attachment-id="4737"></P>
<P>Happy Automating!</P>
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
<P>&nbsp;</P>

