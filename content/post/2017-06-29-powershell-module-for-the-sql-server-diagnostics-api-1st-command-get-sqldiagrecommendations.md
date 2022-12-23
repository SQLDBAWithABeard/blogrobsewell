---
title: "PowerShell Module for the SQL Server Diagnostics API – 1st Command Get-SQLDiagRecommendations"
date: "2017-06-29" 
categories:
  - Blog

tags:
  - api
  - GitHub 
  - PowerShell

---
<P>I saw this blog post about the <A href="https://blogs.msdn.microsoft.com/sql_server_team/sql-server-diagnostics-preview/" rel=noopener target=_blank>SQL Server Diagnostics add-on to SSMS and API</A> and thought I would write some PowerShell to work with it as all of the examples use other languages.</P>
<H2>SQL ServerDignostics API</H2>
<P>The <A href="https://ecsapi.portal.azure-api.net/docs/services/5942df13e495120e44bde7e3/operations/5942df16e4951208204beaf2" rel=noopener target=_blank>Diagnostic Analysis API</A> allows you to upload memory dumps to be able to debug and self-resolve memory dump issues from their SQL Server instances and receive recommended Knowledge Base (KB) article(s) from Microsoft, which may&nbsp;be applicable for the fix.</P>
<P>There is also the <A href="https://ecsapi.portal.azure-api.net/docs/services/594965d5e4951210cc7dd2c5" rel=noopener target=_blank>Recommendations API </A>to view the latest Cumulative Updates (CU) and the underlying hotfixes addressed in the CU which can be filtered by product version or by feature area (e.g. Always On, Backup/Restore, Column Store, etc).</P>
<P>I have written a <A href="https://github.com/SQLDBAWithABeard/SQLDiagAPI" rel=noopener target=_blank>module</A> to work with this API. It is not complete. It only has one command as of now but I can see lots of possibilities for improvement and further commands to interact with the API fully and enable SQL Server professionals to use PowerShell for this.</P>
<H2>Storing the API Key</H2>
<P>To use the API you need an API Key. An API Key is a secret token that identifies the application to the API and is used to control access. You can follow the instructions here <A href="https://ecsapi.portal.azure-api.net/" rel=noopener target=_blank>https://ecsapi.portal.azure-api.net/</A> to get one for the SQL Server Diagnostics API.</P>
<P><A href="https://blog.robsewell.com/assets/uploads/2017/06/01-apikey.png?ssl=1" rel=noopener target=_blank><IMG class="alignnone size-full wp-image-6331" alt="01 - APIKey" src="https://blog.robsewell.com/assets/uploads/2017/06/01-apikey.png?resize=630%2C157&amp;ssl=1" width=630 height=157 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/06/01-apikey.png?fit=630%2C157&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/06/01-apikey.png?fit=300%2C75&amp;ssl=1" data-image-description="" data-image-title="01 – APIKey" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1171,292" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/06/01-apikey.png?fit=1171%2C292&amp;ssl=1" data-permalink="https://blog.robsewell.com/creating-a-powershell-module-and-tdd-for-get-sqldiagrecommendations/01-apikey/#main" data-attachment-id="6331"></A></P>
<P>I will need to store the key to use it. I saved my API Key using the <A href="https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.utility/export-clixml" rel=noopener target=_blank>Export-CliXML</A> command as described by Jaap Brasser <A href="http://www.jaapbrasser.com/tag/export-clixml/" rel=noopener target=_blank>here .</A></P><PRE class="lang:ps decode:true"> Get-Credential | Export-CliXml -Path "${env:\userprofile}\SQLDiag.Cred" </PRE>
<P>You need to enter a username even though it is not used and then enter the API Key as the password. It is saved in the root of the user profile folder as hopefully user accounts will have access there in most shops.</P>
<P>The commands in the module will look for the API Key in that&nbsp;SQLDiag.Cred file by default but you can also just use the APIKey parameter</P>
<H2>Get-SQLDiagRecommendations</H2>
<P>The first function in the module is Get-SQLDiagRecommendations. All this function does is connect to the Recommendations API and return an object containing the information about the latest Cumulative Updates.</P>
<P>If you have already saved your API Key as described above you can use</P><PRE class="lang:ps decode:true"> Get-SQLDiagRecommendations </PRE>
<P>If you want to enter the API Key manually you would use</P><PRE class="lang:ps decode:true"> Get-SQLDiagRecommendations -APIKey XXXXXXXX</PRE>
<P>Either way it will return a PowerShell object containing all of the information which looks like this.</P>
<P><A href="https://blog.robsewell.com/assets/uploads/2017/06/07-get-sqlrecommendations.png?ssl=1" rel=noopener target=_blank><IMG class="alignnone size-full wp-image-6338" alt="07 - Get-SQLRecommendations" src="https://blog.robsewell.com/assets/uploads/2017/06/07-get-sqlrecommendations.png?resize=630%2C54&amp;ssl=1" width=630 height=54 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/06/07-get-sqlrecommendations.png?fit=630%2C54&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/06/07-get-sqlrecommendations.png?fit=300%2C26&amp;ssl=1" data-image-description="" data-image-title="07 – Get-SQLRecommendations" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1395,120" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/06/07-get-sqlrecommendations.png?fit=1395%2C120&amp;ssl=1" data-permalink="https://blog.robsewell.com/creating-a-powershell-module-and-tdd-for-get-sqldiagrecommendations/07-get-sqlrecommendations/#main" data-attachment-id="6338"></A></P>
<P>One of the beauties of PowerShell is that you can pass objects down a pipeline and use them in other commands. Also, your only limit is your imagination.</P>
<P>You want to export to CSV, HTML, Text file?<BR>Email, Import to database, store in Azure storage?<BR>Embed in Word, Excel&nbsp; on a SharePoint site?</P>
<P>All of this and much, much more is easily achievable with PowerShell.</P>
<P>In the future this command will feed other functions in the module that will display this information in a more useful fashion. I am thinking of commands like</P><PRE class="lang:ps decode:true">Get-SQLDiagRecommendations |
Get-SQLDiagLatestCU -Version SQL2012</PRE>
<P>or</P><PRE class="lang:ps decode:true">Get-SQLDiagRecommendations |
Get-SQLDiagKBArticle -Version SQL2012 -Feature BackupRestore</PRE>
<P>If you have any ideas please join in on <A href="https://github.com/SQLDBAWithABeard/SQLDiagAPI" rel=noopener target=_blank>GitHub</A></P>
<H2>JSON</H2>
<P>For now though you can use&nbsp;Get-SQLDiagRecommendations to output the results to JSON so that you can examine them or consume them.</P>
<P>If you use VS Code <A href="https://blog.robsewell.com/vscode-powershell-extension-1-4-0-new-command-out-currentfile/" rel=noopener target=_blank>follow the steps here</A> and you can export the results to the current file with</P><PRE class="lang:ps decode:true"> Get-SQLDiagRecommendations |ConvertTo-Json -Depth 7 |Out-CurrentFile </PRE>
<P>Which looks like this</P>
<P><A href="https://blog.robsewell.com/assets/uploads/2017/06/08-outcurrentfile.png?ssl=1" rel=noopener target=_blank><IMG class="alignnone size-full wp-image-6339" alt="08 - OutCurrentFile" src="https://blog.robsewell.com/assets/uploads/2017/06/08-outcurrentfile.png?resize=630%2C477&amp;ssl=1" width=630 height=477 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/06/08-outcurrentfile.png?fit=630%2C477&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/06/08-outcurrentfile.png?fit=300%2C227&amp;ssl=1" data-image-description="" data-image-title="08 – OutCurrentFile" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1256,950" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/06/08-outcurrentfile.png?fit=1256%2C950&amp;ssl=1" data-permalink="https://blog.robsewell.com/creating-a-powershell-module-and-tdd-for-get-sqldiagrecommendations/08-outcurrentfile/#main" data-attachment-id="6339"></A></P>
<P>It shows the entire JSON object containing all of the information about all of the latest CU’s for SQL Server 2012 and up and each of the KB Articles. I have minimised several of the nodes to try and show as much as possible for SQL Server 2012 SP3</P>
<P>If you do not use VS Code or you want to export straight to a file then you can</P><PRE class="lang:ps decode:true"> Get-SQLDiagRecommendations |ConvertTo-Json -Depth 7 |Out-File -Path PATHTOFILE </PRE>
<H2>Out-GridView</H2>
<P>I like Out-GridView so I quickly gathered the Product, Cumulative Update, Feature Type, KB Number and URL and outputted to Out-GridView like this</P><PRE class="lang:ps decode:true">$recommendations = Get-SQLDiagRecommendations
$KBs = foreach ($recommendation in $recommendations.Recommendations){
    $Product = $recommendation.Product
    $CU = $recommendation.Title
    $CreatedOn = $recommendation.CreatedOn
    foreach ($fix in $recommendation.Content.RelevantFixes){
        $feature = $fix.Title
        foreach ($Kb in $fix.KbArticles){
            [PSCustomObject]@{
                CreatedOn = $CreatedOn
                Product = $Product
                CU = $CU
                Feature = $feature
                KB = $Kb.Rel
                Link = $Kb.href
                }
           }
       }
   }
 $kbs | Ogv </PRE>
<P>As you can filter easily in Out-GridView I filtered by 2012 and this is what it looks like</P>
<H2><A href="https://blog.robsewell.com/assets/uploads/2017/06/09-out-gridview.png?ssl=1" rel=noopener target=_blank><IMG class="alignnone size-full wp-image-6340" alt="09 - Out-GridView" src="https://blog.robsewell.com/assets/uploads/2017/06/09-out-gridview.png?resize=630%2C140&amp;ssl=1" width=630 height=140 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/06/09-out-gridview.png?fit=630%2C140&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/06/09-out-gridview.png?fit=300%2C67&amp;ssl=1" data-image-description="" data-image-title="09 – Out-GridView" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1238,275" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/06/09-out-gridview.png?fit=1238%2C275&amp;ssl=1" data-permalink="https://blog.robsewell.com/creating-a-powershell-module-and-tdd-for-get-sqldiagrecommendations/09-out-gridview/#main" data-attachment-id="6340"></A></H2>
<P>This will enable you to quickly see any information that you require about the Cumulative Updates for SQL 2012, 2014 and 2016</P>
<H2>Github</H2>
<P>You can <A href="https://github.com/SQLDBAWithABeard/SQLDiagAPI" rel=noopener target=_blank>find the module on GitHub.&nbsp;</A>There are <A href="https://github.com/SQLDBAWithABeard/SQLDiagAPI/blob/master/install.md" rel=noopener target=_blank>instructions </A>and a <A href="https://github.com/SQLDBAWithABeard/SQLDiagAPI/blob/master/install.ps1" rel=noopener target=_blank>script </A>to install it easily.</P>
<P>Right now it has only got the one function to get the SQL recommendations but I will look at expanding that over the next few days and once it is more complete put it onto the <A href="https://www.powershellgallery.com/" rel=noopener target=_blank>PowerShell Gallery</A> and maybe move it into the <A href="https://github.com/sqlcollaborative" rel=noopener target=_blank>SQL Server Community GitHub Organisation</A>&nbsp; home of <SPAN style="COLOR: #0066cc"><A href="https://dbatools.io/" rel=noopener target=_blank>https://dbatools.io ,&nbsp;</A><A href="https://dbareports.io/" rel=noopener target=_blank>https://dbareports.io</A></SPAN>, Invoke-SQLCmd2 and the SSIS Reporting pack</P>
<H2>Contribute</H2>
<P>Of course I am happy to have others contribute to this, in fact I encourage it. Please fork and give PR’s and make this a useful module with more commands. There is the <A href="https://ecsapi.portal.azure-api.net/docs/services/5942df13e495120e44bde7e3/operations/5942df16e4951208204beaf2" rel=noopener target=_blank>Diagnostic Analysis API</A> as well to work with and I am very interested to see how we can make use of that with PowerShell</P>
<P>Tomorrow I have a post explaining the process I used to create the module and how I used Test Driven Development with Pester to write this function.</P>

