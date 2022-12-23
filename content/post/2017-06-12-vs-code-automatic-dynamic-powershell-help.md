---
title: "VS Code – Automatic Dynamic PowerShell Help"
date: "2017-06-12" 
categories:
  - Blog

tags:
  - dbatools
  - help
  - PowerShell

---
<P><A href="https://code.visualstudio.com/" rel=noopener target=_blank>VS Code</A> is my coding tool of choice. I love that one lightweight editor <A href="https://blog.robsewell.com/why-vs-code-increases-my-productivity/" rel=noopener target=_blank>can do so much</A> and as PowerShell is usually the language that I write in I really love the <A href="https://github.com/PowerShell/vscode-powershell/blob/master/CHANGELOG.md?wt.mc_id=DX_883151" rel=noopener target=_blank>PowerShell extension</A></P>
<H2>Help</H2>
<P>When you write a PowerShell function that is going to be used by someone other than you, you don’t want to be the guy or gal that has to support it indefinitely. You should write good help to enable your users to simply type</P><PRE class="lang:ps decode:true">Get-Help NAMEOFCOMMAND</PRE>
<P>and get all of the help that they need to use the command</P>
<P>If we look at one of my favourite <A href="https://dbatools.io/" rel=noopener target=_blank>dbatools </A>commands <A href="https://dbatools.io/functions/get-dbalastgoodcheckdb/" rel=noopener target=_blank>Get-DbaLastGoodCheckDB</A> we can see this in action.</P><PRE class="lang:ps decode:true">Get-Help Get-DbaLastGoodCheckDb -full</PRE>
<P>This returns</P>
<BLOCKQUOTE>
<P>NAME<BR>Get-DbaLastGoodCheckDb</P>
<P>SYNOPSIS<BR>Get date/time for last known good DBCC CHECKDB</P>
<P>SYNTAX<BR>Get-DbaLastGoodCheckDb [-SqlInstance] [[-SqlCredential] ] [-Silent] []</P>
<P>DESCRIPTION<BR>Retrieves and compares the date/time for the last known good DBCC CHECKDB, as well as the creation date/time for the database.</P>
<P>This function supports SQL Server 2005+</P>
<P>Please note that this script uses the DBCC DBINFO() WITH TABLERESULTS. DBCC DBINFO has several known weak points, such as:<BR>– DBCC DBINFO is an undocumented feature/command.<BR>– The LastKnowGood timestamp is updated when a DBCC CHECKFILEGROUP is performed.<BR>– The LastKnowGood timestamp is updated when a DBCC CHECKDB WITH PHYSICAL_ONLY is performed.<BR>– The LastKnowGood timestamp does not get updated when a database in READ_ONLY.</P>
<P>An empty ($null) LastGoodCheckDb result indicates that a good DBCC CHECKDB has never been performed.</P>
<P>SQL Server 2008R2 has a “bug” that causes each databases to possess two dbi_dbccLastKnownGood fields, instead of the normal one.<BR>This script will only displaythis function to only display the newest timestamp. If -Verbose is specified, the function will announce every time<BR>more than one dbi_dbccLastKnownGood fields is encountered.</P>
<P>PARAMETERS<BR>-SqlInstance<BR>The SQL Server that you’re connecting to.</P>
<P>Required? true<BR>Position? 1<BR>Default value<BR>Accept pipeline input? true (ByValue)<BR>Accept wildcard characters? false</P>
<P>-SqlCredential Credential object used to connect to the SQL Server as a different user</P>
<P>Required? false<BR>Position? 2<BR>Default value<BR>Accept pipeline input? false<BR>Accept wildcard characters? false</P>
<P>-Silent []<BR>Use this switch to disable any kind of verbose messages</P>
<P>Required? false<BR>Position? named<BR>Default value False<BR>Accept pipeline input? false<BR>Accept wildcard characters? false<BR>This cmdlet supports the common parameters: Verbose, Debug,<BR>ErrorAction, ErrorVariable, WarningAction, WarningVariable,<BR>OutBuffer, PipelineVariable, and OutVariable. For more information, see<BR>about_CommonParameters (<A href="http://go.microsoft.com/fwlink/?LinkID=113216" rel=nofollow>http://go.microsoft.com/fwlink/?LinkID=113216</A>).</P>
<P>INPUTS</P>
<P>OUTPUTS</P>
<P>NOTES</P>
<P>Copyright (C) 2016 Jakob Bindslet (jakob@bindslet.dk)</P>
<P>This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by<BR>the Free Software Foundation, either version 3 of the License, or (at your option) any later version.</P>
<P>This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of<BR>MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.</P>
<P>You should have received a copy of the GNU General Public License along with this program. If not, see .</P>
<P>————————– EXAMPLE 1 ————————–</P>
<P>PS C:\&gt;Get-DbaLastGoodCheckDb -SqlInstance ServerA\sql987</P>
<P>Returns a custom object displaying Server, Database, DatabaseCreated, LastGoodCheckDb, DaysSinceDbCreated, DaysSinceLastGoodCheckDb, Status and<BR>DataPurityEnabled</P>
<P>————————– EXAMPLE 2 ————————–</P>
<P>PS C:\&gt;Get-DbaLastGoodCheckDb -SqlInstance ServerA\sql987 -SqlCredential (Get-Credential sqladmin) | Format-Table -AutoSize</P>
<P>Returns a formatted table displaying Server, Database, DatabaseCreated, LastGoodCheckDb, DaysSinceDbCreated, DaysSinceLastGoodCheckDb, Status<BR>and DataPurityEnabled.<BR>Authenticates with SQL Server using alternative credentials.</P>
<P>RELATED LINKS<BR>DBCC CHECKDB:<BR><A href="https://msdn.microsoft.com/en-us/library/ms176064.aspx" rel=nofollow>https://msdn.microsoft.com/en-us/library/ms176064.aspx</A><BR><A href="http://www.sqlcopilot.com/dbcc-checkdb.html" rel=nofollow>http://www.sqlcopilot.com/dbcc-checkdb.html</A><BR>Data Purity:<BR><A href="http://www.sqlskills.com/blogs/paul/checkdb-from-every-angle-how-to-tell-if-data-purity-checks-will-be-run/" rel=nofollow>http://www.sqlskills.com/blogs/paul/checkdb-from-every-angle-how-to-tell-if-data-purity-checks-will-be-run/</A><BR><A href="https://www.mssqltips.com/sqlservertip/1988/ensure-sql-server-data-purity-checks-are-performed/" rel=nofollow>https://www.mssqltips.com/sqlservertip/1988/ensure-sql-server-data-purity-checks-are-performed/</A></P></BLOCKQUOTE>
<P>So anyone who needs to use the command can see what it is, a full description, what each parameter is for, some examples and some links to more information</P>
<P>So what I used to do was put a snippet of code like this at the top of my function and then fill in the blanks</P><PRE class="lang:ps decode:true">&lt;#
.SYNOPSIS
Short description
.DESCRIPTION
Long description
.EXAMPLE
An example
.PARAMETER
Parameter Help
.NOTES
General notes
.LINK
Link to more information
#&gt;</PRE>
<P>The latest release of the PowerShell extension for VS Code has made that process so much simpler 🙂 Thank you David and Keith</P>
<P>Now you can simply type ## (edited May 2018 you can configure this to &lt;# in the user settings) and your help will be dynamically created. You will still have to fill in some of the blanks but it is a lot easier.</P>
<P>Here it is in action in its simplest form</P>
<P><IMG class="alignnone size-full wp-image-5796" alt="Pester - Simple.gif" src="https://blog.robsewell.com/assets/uploads/2017/06/pester-simple.gif?resize=630%2C384&amp;ssl=1" width=630 height=384 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/06/pester-simple.gif?fit=630%2C384&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/06/pester-simple.gif?fit=300%2C183&amp;ssl=1" data-image-description="" data-image-title="Pester – Simple" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1002,610" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/06/pester-simple.gif?fit=1002%2C610&amp;ssl=1" data-permalink="https://blog.robsewell.com/vs-code-automatic-dynamic-powershell-help/pester-simple/#main" data-attachment-id="5796"></P>
<P>But it gets better than that. When you add parameters to your function code they are added to the help as well. Also, all you have to do is to tab between the different entries in the help to move between them</P>
<P><IMG class="alignnone size-full wp-image-5807" alt="02 - detailed.gif" src="https://blog.robsewell.com/assets/uploads/2017/06/02-detailed.gif?resize=630%2C488&amp;ssl=1" width=630 height=488 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/06/02-detailed.gif?fit=630%2C488&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/06/02-detailed.gif?fit=300%2C233&amp;ssl=1" data-image-description="" data-image-title="02 – detailed" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1000,775" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/06/02-detailed.gif?fit=1000%2C775&amp;ssl=1" data-permalink="https://blog.robsewell.com/vs-code-automatic-dynamic-powershell-help/02-detailed/#main" data-attachment-id="5807"></P>
<P>Now when we run</P><PRE class="lang:ps decode:true">Get-Help Invoke-AmazingThings -Full</PRE>
<P>We get this</P>
<P><IMG class="alignnone size-full wp-image-5805" alt="03 help.PNG" src="https://blog.robsewell.com/assets/uploads/2017/06/03-help.png?resize=630%2C797&amp;ssl=1" width=630 height=797 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/06/03-help.png?fit=630%2C797&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/06/03-help.png?fit=237%2C300&amp;ssl=1" data-image-description="" data-image-title="03 help" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="775,981" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/06/03-help.png?fit=775%2C981&amp;ssl=1" data-permalink="https://blog.robsewell.com/vs-code-automatic-dynamic-powershell-help/03-help/#main" data-attachment-id="5805"></P>
<P>Nice and easy and a great feature added to the VS Code PowerShell extension</P>
<P><IMG class="alignnone size-full wp-image-5810" alt="Write Good Help.png" src="https://blog.robsewell.com/assets/uploads/2017/06/write-good-help.png?w=500&amp;ssl=1" data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/06/write-good-help.png?fit=500%2C851&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/06/write-good-help.png?fit=176%2C300&amp;ssl=1" data-image-description="" data-image-title="Write Good Help" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="500,851" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/06/write-good-help.png?fit=500%2C851&amp;ssl=1" data-permalink="https://blog.robsewell.com/vs-code-automatic-dynamic-powershell-help/write-good-help/#main" data-attachment-id="5810"></P>

