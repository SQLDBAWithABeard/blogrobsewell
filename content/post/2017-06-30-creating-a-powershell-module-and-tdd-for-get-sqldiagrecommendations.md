---
title: "Creating a PowerShell Module and TDD for Get-SQLDiagRecommendations"
date: "2017-06-30" 
categories:
  - Blog

tags:
  - api
  - dbatools
  - GitHub 
  - pester
  - plaster
  - PowerShell
  - tdd
  - test

---
<P>Yesterday I introduced the <A href="https://blog.robsewell.com/powershell-module-for-the-sql-server-diagnostics-api-1st-command-get-sqldiagrecommendations/" rel=noopener target=_blank>first command in the SQLDiagAPI module. </A>A module to consume the SQL Diagnostics API.</P>
<P>I have been asked a few times what the process is for creating a module, using Github and developing with Pester and whilst this is not a comprehensive how-to I hope it will give some food for thought when you decide to write a PowerShell module or start using Pester for code development. I also hope it will encourage you to give it a try and to blog about your experience.</P>
<P>This is my experience from nothing to a module with a function using Test Driven Development with Pester. There are some details missing in some places but if something doesn’t make sense then ask a question. If something is incorrect then point it out. I plan on never stopping learning!</P>
<P>There are many links to further reading and I urge you to not only read the posts linked but also to read further and deeper. That’s a generic point for anyone in the IT field and not specific to PowerShell. Never stop learning. Also, say thank you to those that have taken their time to write content that you find useful. They will really appreciate that.</P>
<H2>Github Repository</H2>
<P>I created a <A href="https://github.com/SQLDBAWithABeard/SQLDiagAPI" rel=noopener target=_blank>new repository</A> in Github and used Visual Studio Code to clone the repository by pressing F1 and typing clone – Choosing Git Clone and following the prompts. I started with this because I was always planning to share this code and because source controlling it is the best way to begin.</P>
<H2>Plaster Template</H2>
<P>When you create a module there are a number of files that you need and I have a number of generic tests that I add. I also have a structure that I create for the artifacts and a number of markdown documents that come with a GitHub Repository.&nbsp; Whilst you could write a PowerShell script to create all of those, there is no need as there is <A href="https://github.com/PowerShell/Plaster" rel=noopener target=_blank>Plaster</A> !&nbsp; <A href="https://github.com/PowerShell/Plaster" rel=noopener target=_blank>Plaster</A> is a PowerShell module that enables you to set up the default scaffolding for your PowerShell module structure and tokenise some files. This makes it much easier to have a default ‘scaffold’ for the module, a structure for the files and folders and create a new module simply.&nbsp;I used <A href="https://kevinmarquette.github.io/2017-05-12-Powershell-Plaster-adventures-in/" rel=noopener target=_blank>Kevin Marquettes post on Plaster</A>&nbsp; to create myself a template module. You can find my Plaster Template <A href="https://github.com/SQLDBAWithABeard/PlasterTemplate" rel=noopener target=_blank>here&nbsp;</A></P>
<P>You do not need to use Plaster at all but as with anything, if you find yourself repeating steps then it is time to automate it</P>
<P>With my Plaster Template created I could simply run</P><PRE class="lang:ps decode:true">$plaster = @{
TemplatePath = "GIT:\PlasterTemplate" #(Split-Path $manifestProperties.Path)
DestinationPath = "GIT:\SQLDiagAPI"
FullName = "Rob Sewell"
ModuleName = "SQLDiagAPI"
ModuleDesc = "This is a module to work with the SQL Server Diagnostics (Preview) API. See https://blogs.msdn.microsoft.com/sql_server_team/sql-server-diagnostics-preview/ for more details "
Version = "0.9.0"
GitHubUserName = "SQLDBAWithABeard"
GitHubRepo = "SQLDiagAPI"
}
If(!(Test-Path $plaster.DestinationPath))
{
New-Item -ItemType Directory -Path $plaster.DestinationPath
}
Invoke-Plaster @plaster -Verbose
</PRE>
<P>This created my module. It created this folder and file structure and included some default tests and markdown documents pre-populated.</P>
<P><IMG class="alignnone size-full wp-image-6330" alt="00 - module" src="https://blog.robsewell.com/assets/uploads/2017/06/00-module.png?resize=365%2C516&amp;ssl=1" width=365 height=516 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/06/00-module.png?fit=365%2C516&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/06/00-module.png?fit=212%2C300&amp;ssl=1" data-image-description="" data-image-title="00 – module" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="365,516" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/06/00-module.png?fit=365%2C516&amp;ssl=1" data-permalink="https://blog.robsewell.com/creating-a-powershell-module-and-tdd-for-get-sqldiagrecommendations/00-module/#main" data-attachment-id="6330"></P>
<H2>Pester</H2>
<P>For those that don’t know.<A href="https://github.com/pester/Pester" rel=noopener target=_blank> Pester is a PowerShell module for Test Driven Development</A></P>
<BLOCKQUOTE>
<P>Pester provides a framework for&nbsp;running unit tests to execute and validate PowerShell commands from within PowerShell. Pester consists of a simple set of functions that expose a testing domain-specific language (DSL) for isolating, running, evaluating and reporting the results of PowerShell commands</P></BLOCKQUOTE>
<P>If you have PowerShell version 5 then you will have Pester already installed although you should update it to the latest version. If not you can get <A href="https://www.powershellgallery.com/packages/Pester/" rel=noopener target=_blank>Pester from the PowerShell Gallery</A>&nbsp;follow the instructions on that page to install it. <A href="https://www.simple-talk.com/sysadmin/powershell/practical-powershell-unit-testing-getting-started/https://www.simple-talk.com/sysadmin/powershell/practical-powhttps://www.simple-talk.com/sysadmin/powershell/practical-powershell-unit-testing-getting-started/ershell-unit-testing-getting-started/" rel=noopener target=_blank>This is a good post to start learning about Pester</A></P>
<H2>API Key</H2>
<P>Now that I have the module I started to think about the commands. I decided to start with the recommendations API which is described as</P>
<BLOCKQUOTE>
<P>Customers will be able to keep their SQL Server instances up-to-date by easily reviewing the recommendations for their SQL Server instances. Customers can filter by product version or by feature area (e.g. Always On, Backup/Restore, Column Store, etc.) and view the latest Cumulative Updates (CU) and the underlying hotfixes addressed in the CU.</P></BLOCKQUOTE>
<P>To use the API you need an API Key. An API Key is a secret token that identifies the application to the API and is used to control access.You can follow the instructions here <A href="https://ecsapi.portal.azure-api.net/" rel=noopener target=_blank>https://ecsapi.portal.azure-api.net/</A> to get one for the SQL Server Diagnostics API.</P>
<P><IMG class="alignnone size-full wp-image-6331" alt="01 - APIKey" src="https://blog.robsewell.com/assets/uploads/2017/06/01-apikey.png?resize=630%2C157&amp;ssl=1" width=630 height=157 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/06/01-apikey.png?fit=630%2C157&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/06/01-apikey.png?fit=300%2C75&amp;ssl=1" data-image-description="" data-image-title="01 – APIKey" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1171,292" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/06/01-apikey.png?fit=1171%2C292&amp;ssl=1" data-permalink="https://blog.robsewell.com/creating-a-powershell-module-and-tdd-for-get-sqldiagrecommendations/01-apikey/#main" data-attachment-id="6331"></P>
<P>I will need to store the key to use it and if I am writing code that others will use consider how they can repeat the steps that I take. I decided to save my API Key using the <A href="https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.utility/export-clixml" rel=noopener target=_blank>Export-CliXML</A> command as described by Jaap Brasser <A href="http://www.jaapbrasser.com/tag/export-clixml/" rel=noopener target=_blank>here .</A></P><PRE class="lang:ps decode:true">Get-Credential | Export-CliXml -Path "${env:\userprofile}\SQLDiag.Cred"
</PRE>
<P>You need to enter a username even though it is not used and then enter the API Key as the password. It is saved in the root of the user profile folder as hopefully user accounts will have access there in most shops</P>
<H2>TDD</H2>
<P>I approached writing this module using Test Driven Development with Pester. This means that I have to write my tests before I write my code. There are many reasons for doing this which are outside the scope of this blog post. <A href="http://www.hurryupandwait.io/blog/why-tdd-for-powershell-or-why-pester-or-why-unit-test-scripting-language" rel=noopener target=_blank>This is a very good post to read more</A></P>
<P>The first function I wanted to write was to get the recommendations from the API. I decide to call it Get-SQLDiagRecommendations.</P>
<P>I decided that the first test should be to ensure that the API Key exists. Otherwise I would not be able to use it when calling the API. I already had an idea of how I would approach it by storing the API Key using Test-Path and writing a warning if the file did not exist.</P>
<H2>Mocking</H2>
<P>However this is not going to work if I have already saved the key to the file. The test needs to not be reliant on any thing external. I need to be able to test this functionality without actually checking my system. I will use Mock to do this. You can read more about <A href="https://github.com/pester/Pester/wiki/Mocking-with-Pester" rel=noopener target=_blank>mocking with Pester here.</A></P>
<P>I added this to my Pester test</P><PRE class="lang:ps decode:true">Context "Requirements" {
Mock Test-Path {$false}
Mock Write-Warning {"Warning"}
</PRE>
<P>This is what happens when you run this test. When there is a call to Test-Path in the code you have written, instead of actually running Test-Path it will return whatever is inside the curly braces, in this case false. For Write-Warning it will return a string of Warning.</P>
<P>This means that I can write a test like this</P><PRE class="lang:ps decode:true">It "Should throw a warning if there is no API Key XML File and the APIKey Parameter is not used"{
Get-SQLDiagRecommendations -ErrorAction SilentlyContinue | Should Be "Warning"
}
</PRE>
<P>So I know that when running my code in this test, Test-Path will return false, which will invoke Write-Warning in my code and in the test that will return “Warning” . So if I have written my code correctly the test will pass without actually running the real Test-Path and interacting with my system or running Write-Warning which makes it easier to test that warnings are thrown correctly.</P>
<P>The name of the test will also let me (and others) know in the future what I was trying to achieve. This means that if I (or someone else) changes the code and the test fails they can understand what was meant to happen. They can then either write a new test for the changed code if the requirements are now different or alter the code so that it passes the original test.</P>
<P>I use</P><PRE class="lang:ps decode:true">-ErrorAction SilentlyContinue</PRE>
<P>so that the only red text that I see on the screen is the results of the test and not any PowerShell errors.</P>
<H2>Asserting</H2>
<P>I can also check that I have successfully called my Mocks using <A href="https://github.com/pester/Pester/wiki/Assert-MockCalled" rel=noopener target=_blank>Assert-MockCalled</A>. This command will check that a command that has been mocked has been called successfully during the test in the scope of the Describe (or in this case Context) block of the tests</P><PRE class="lang:ps decode:true">It 'Checks the Mock was called for Test-Path' {
$assertMockParams = @{
'CommandName' = ' Test-Path'
'Times' = 1
'Exactly' = $true
}
Assert-MockCalled @assertMockParams
}
</PRE>
<P>I specify the command name, the number of times that I expect the mock to have been called and because I know that it will be exactly 1 time, I set exactly to $true. If I set exactly to false it would test that the mock was called at least the number of times specified. This is another test that I really have called the Mocks that I defined and the results are correct and dependant only on the code.</P>
<P>I set up the same test for Write-Warning.</P>
<H2>Failed Test</H2>
<P>I can now run my Pester tests using</P><PRE class="lang:ps decode:true">Invoke-Pester .\Tests
</PRE>
<P>and see that some failed.</P>
<P><IMG class="alignnone size-full wp-image-6332" alt="02 - Failed Pester tests" src="https://blog.robsewell.com/assets/uploads/2017/06/02-failed-pester-tests.png?resize=630%2C363&amp;ssl=1" width=630 height=363 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/06/02-failed-pester-tests.png?fit=630%2C363&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/06/02-failed-pester-tests.png?fit=300%2C173&amp;ssl=1" data-image-description="" data-image-title="02 – Failed Pester tests" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1110,640" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/06/02-failed-pester-tests.png?fit=1110%2C640&amp;ssl=1" data-permalink="https://blog.robsewell.com/creating-a-powershell-module-and-tdd-for-get-sqldiagrecommendations/02-failed-pester-tests/#main" data-attachment-id="6332"></P>
<P>Of course it failed I don’t have a function named Get-SQLDiagRecommendations</P>
<H2>So why run the test?</H2>
<P>I need to ensure that my test fails before I write the code to pass it. If I don’t do that I may mistakenly write a test that passes and therefore not be correctly testing my code.</P>
<P>You can also see that it has run all of the .Tests.ps1 files in the tests directory and has taken 42 seconds to run. The tests directory includes a number of Pester tests including checking that all of the scripts pass the <A href="https://github.com/PowerShell/PSScriptAnalyzer" rel=noopener target=_blank>Script Analyser rules </A>and that all of the functions have the correct help. (thank you June Blender for that test)</P>
<H2>Show</H2>
<P>I can reduce the output of the tests using the Show parameter of Invoke-Pester. I will often use Fails as this will show the describe and context titles and only the tests that fail. This will run much quicker as it will not need to output all of the passed tests to the screen</P>
<P><IMG class="alignnone size-full wp-image-6333" alt="03 - Pester show fails" src="https://blog.robsewell.com/assets/uploads/2017/06/03-pester-show-fails.png?resize=630%2C410&amp;ssl=1" width=630 height=410 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/06/03-pester-show-fails.png?fit=630%2C410&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/06/03-pester-show-fails.png?fit=300%2C195&amp;ssl=1" data-image-description="" data-image-title="03 – Pester show fails" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1041,678" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/06/03-pester-show-fails.png?fit=1041%2C678&amp;ssl=1" data-permalink="https://blog.robsewell.com/creating-a-powershell-module-and-tdd-for-get-sqldiagrecommendations/03-pester-show-fails/#main" data-attachment-id="6333"></P>
<P>Now the test is running in less than half of the time. You can filter the output in further ways using Show. You can run</P><PRE class="lang:ps decode:true">Get-Help Invoke-Pester</PRE>
<P>to see how else you can do this.</P>
<H2>Tags</H2>
<P>As I am going to be writing tests and then writing code to pass the tests repeatedly I don’t want to run all of these tests all of the time so I can use the Tags parameter of Invoke-Pester to only run a certain suite tests. In the <A href="https://github.com/SQLDBAWithABeard/SQLDiagAPI/blob/master/tests/Unit.Tests.ps1" rel=noopener target=_blank>Unit.Tests.ps1 </A>file the Describe block looks like this</P><PRE class="lang:ps decode:true">Describe "Get-SQLDiagRecommendations" -Tags Build , Unit{
Context "Requirements" {
</PRE>
<P>So I can run just the tests tagged Unit and skip all of the other tests. Combined with the Show Fails to reduce the output my Invoke-Pester code looks like this</P><PRE class="lang:ps decode:true">Invoke-Pester .\tests -Show Fails -Tag Unit
</PRE>
<P><IMG class="alignnone size-full wp-image-6334" alt="04 - Pester Tags" src="https://blog.robsewell.com/assets/uploads/2017/06/04-pester-tags.png?resize=630%2C491&amp;ssl=1" width=630 height=491 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/06/04-pester-tags.png?fit=630%2C491&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/06/04-pester-tags.png?fit=300%2C234&amp;ssl=1" data-image-description="" data-image-title="04 – Pester Tags" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="991,773" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/06/04-pester-tags.png?fit=991%2C773&amp;ssl=1" data-permalink="https://blog.robsewell.com/creating-a-powershell-module-and-tdd-for-get-sqldiagrecommendations/04-pester-tags/#main" data-attachment-id="6334"></P>
<P>Now I am only running the tests that I need for writing the code for the command the tests are running in under half a second 🙂 This is so much better when I am going to be running them repeatedly.</P>
<P>The other tests have different tags and I will show them running later in the post.</P>
<H2>Code</H2>
<P>Finally, we can write some code to pass our failing test</P><PRE class="lang:ps decode:true">function Get-SQLDiagRecommendations1 {
[cmdletbinding()]
Param([string]$ApiKey)
if (!$ApiKey) {
if (!(Test-Path "${env:\userprofile}\SQLDiag.Cred")) {
Write-Warning "You have not created an XML File to hold the API Key or provided the API Key as a parameter
You can export the key to an XML file using Get-Credential | Export-CliXml -Path `"`${env:\userprofile}\SQLDiag.Cred`"
You can get a key by following the steps here https://ecsapi.portal.azure-api.net/ "
    }
}
</PRE>
<P>Which would look like this if the file does not exist and the API Key parameter is not used</P>
<P><IMG class="alignnone size-full wp-image-6335" alt="05 - Warning" src="https://blog.robsewell.com/assets/uploads/2017/06/05-warning.png?resize=630%2C47&amp;ssl=1" width=630 height=47 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/06/05-warning.png?fit=630%2C47&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/06/05-warning.png?fit=300%2C23&amp;ssl=1" data-image-description="" data-image-title="05 – Warning" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1169,88" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/06/05-warning.png?fit=1169%2C88&amp;ssl=1" data-permalink="https://blog.robsewell.com/creating-a-powershell-module-and-tdd-for-get-sqldiagrecommendations/05-warning/#main" data-attachment-id="6335"></P>
<P>I like to provide users with a useful message that they can follow rather than a lot of red text that they need to decipher</P>
<P>And now our tests pass</P>
<P><IMG class="alignnone size-full wp-image-6337" alt="06 - Passing Tests" src="https://blog.robsewell.com/assets/uploads/2017/06/06-passing-tests.png?resize=630%2C322&amp;ssl=1" width=630 height=322 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/06/06-passing-tests.png?fit=630%2C322&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/06/06-passing-tests.png?fit=300%2C153&amp;ssl=1" data-image-description="" data-image-title="06 – Passing Tests" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="952,487" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/06/06-passing-tests.png?fit=952%2C487&amp;ssl=1" data-permalink="https://blog.robsewell.com/creating-a-powershell-module-and-tdd-for-get-sqldiagrecommendations/06-passing-tests/#main" data-attachment-id="6337"></P>
<P>If you look at <A href="https://ecsapi.portal.azure-api.net/docs/services/594965d5e4951210cc7dd2c5/operations/594965d5e4951208204beb59" rel=noopener target=_blank>the API documentation</A> the API requires a callerid as well as the APIKey. In <A href="https://ecsapi.portal.azure-api.net/codesample" rel=noopener target=_blank>the examples</A> it uses the value from<BR>HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Cryptography\MachineGUID</P>
<P>We can get that using <A href="https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.management/get-itemproperty" rel=noopener target=_blank>Get-ItemProperty</A> and without it we can’t call the API so I wrote tests like this.</P><PRE class="lang:ps decode:true">It "Returns a warning if unable to get Machine GUID" {
Mock Get-MachineGUID {} -Verifiable
Mock Write-Warning {"Warning"} -Verifiable
Get-SQLDiagRecommendations -APIKey dummykey | Should Be "Warning"
Assert-VerifiableMocks
}
</PRE>
<P>I am not saying this is the correct way to write your tests. I am showing that you can test multiple things in an It block and if any one of them fails the entire test fails.</P>
<P>I am mocking the internal function Get-MachineGuid and Write Warning just in the scope of this It Block and passing an APIKey parameter to Get-SQLDiagRecommendations so that we don’t hit the write-warnings we tested for above and then using <A href="https://msdn.microsoft.com/en-us/powershell/reference/6/pester/assert-verifiablemocks" rel=noopener target=_blank>Assert-VerifiableMocks</A>&nbsp; to verify that the mocks have been called. It does not verify how many times, just that all of the mocks in that block have been called</P>
<P>The test fails as expected and then I write the code to pass the test. This is the internal function to get the Machine GUID</P><PRE class="lang:ps decode:true">function Get-MachineGUID {
try {
(Get-ItemProperty registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Cryptography\ -Name MachineGuid).MachineGUID
}
catch{
Write-Warning "Failed to get Machine GUID from HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Cryptography\"
}
}
</PRE>
<P>&nbsp;</P>
<P>and this is the call to the internal function and warning message</P><PRE class="lang:ps decode:true">$MachineGUID = Get-MachineGUID
if($MachineGUID.length -eq 0)
{
Write-Warning "Failed to get Machine GUID from HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Cryptography\"
break
}
</PRE>
<H2>Rinse and repeat</H2>
<P>That is basically the process that I follow to write a function. I just write a test, write some code to fix it, write another test, write some code to fix it. I keep going until I have finished writing the code and all the test have passed.</P>
<H2>Best Practice Code</H2>
<P>Once that was done and my Unit test had passed I run</P><PRE class="lang:ps decode:true"> Invoke-Pester .\tests -Tag ScriptAnalyzer -Show Fails
</PRE>
<P>To check that the PowerShell code that I had written conformed to the <A href="https://github.com/PowerShell/PSScriptAnalyzer" rel=noopener target=_blank>Script Analyzer </A>rules. I added an exception to the Help.Exceptions.ps1 file to not run the rule for plural nouns as I think the command has to be called Get-SQLRecommendations with an S ! I have tagged the ScriptAnalyzer Tests with a tag so I can just run those tests.</P>
<H2>Help</H2>
<P>As that had all passed I could then run</P><PRE class="lang:ps decode:true">Invoke-Pester .\tests -Tag Help
</PRE>
<P>Which tests if I had the correct help for my functions. Of course that failed but I could use the nifty new feature in VS Codes PowerShell Extension to add the help scaffolding really easily <A href="https://blog.robsewell.com/vs-code-automatic-dynamic-powershell-help/" rel=noopener target=_blank>as I describe here</A></P>
<P>Then I could run all 563 of the Pester tests in the tests folder and be happy that everything was OK</P>
<P><IMG class="alignnone size-full wp-image-6373" alt="11 - All Pester passed.PNG" src="https://blog.robsewell.com/assets/uploads/2017/06/11-all-pester-passed.png?resize=630%2C403&amp;ssl=1" width=630 height=403 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/06/11-all-pester-passed.png?fit=630%2C403&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/06/11-all-pester-passed.png?fit=300%2C192&amp;ssl=1" data-image-description="" data-image-title="11 – All Pester passed" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="926,593" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/06/11-all-pester-passed.png?fit=926%2C593&amp;ssl=1" data-permalink="https://blog.robsewell.com/creating-a-powershell-module-and-tdd-for-get-sqldiagrecommendations/11-all-pester-passed/#main" data-attachment-id="6373"></P>
<P>By the end I had written the module, which you can <A href="https://github.com/SQLDBAWithABeard/SQLDiagAPI" rel=noopener target=_blank>find here </A></P>
<P>There are <A href="https://github.com/SQLDBAWithABeard/SQLDiagAPI/blob/master/install.md" rel=noopener target=_blank>instructions </A>and a <A href="https://github.com/SQLDBAWithABeard/SQLDiagAPI/blob/master/install.ps1" rel=noopener target=_blank>script </A>to install it easily.</P>
<P>Right now it has only got the one function to get the SQL recommendations but I will look at expanding that over the next few days and once it is more complete put it onto the <A href="https://www.powershellgallery.com/" rel=noopener target=_blank>PowerShell Gallery</A> and maybe move it into the <A href="https://github.com/sqlcollaborative" rel=noopener target=_blank>SQL Server Community GitHub Organisation</A>&nbsp; home of <A href="https://dbatools.io" rel=noopener target=_blank>https://dbatools.io ,&nbsp;</A><A href="https://dbareports.io" rel=noopener target=_blank>https://dbareports.io</A>, Invoke-SQLCmd2 and the SSIS Reporting pack</P>
<H2>Contribute</H2>
<P>Of course I am happy to have others contribute to this, in fact I encourage it. Please fork and give PR’s and make this a useful module with more commands. There is the <A href="https://ecsapi.portal.azure-api.net/docs/services/5942df13e495120e44bde7e3/operations/5942df16e4951208204beaf2" rel=noopener target=_blank>Diagnostic Analysis API</A> as well to work with which I am very interested to see how we can make use of that with PowerShell</P>
<P>As always, I highly recommend that if you want to know more about Pester <A href="https://leanpub.com/pesterbook" rel=noopener target=_blank>you head over here </A>and purchase this book by Adam</P>

