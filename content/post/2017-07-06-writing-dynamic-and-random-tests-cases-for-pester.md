---
title: "Writing Dynamic and Random Tests Cases for Pester"
categories:
  - Blog

tags:
  - GitHub 
  - pester
  - PowerShell
  - sqldiagapi

---
<P>I have written a module <A href="https://github.com/SQLDBAWithABeard/SQLDiagAPI" rel=noopener target=_blank>SQLDiagAPI</A> for consuming the <A href="https://ecsapi.portal.azure-api.net/" rel=noopener target=_blank>SQL Server Diagnostics API</A> with PowerShell. I blogged about how I used Pester to <A href="https://blog.robsewell.com/creating-a-powershell-module-and-tdd-for-get-sqldiagrecommendations/" rel=noopener target=_blank>develop one of the functions .</A> Whilst writing <A href="https://blog.robsewell.com/using-get-sqldiagfix-to-get-information-from-the-sql-server-diagnostic-api-with-powershell/" rel=noopener target=_blank>Get-SQLDiagFix</A> I wrote some Pester Tests to make sure that the output from the code was as expected.</P>
<H2>Pester</H2>
<P>For those that don’t know.<A href="https://github.com/pester/Pester" rel=noopener target=_blank> Pester is a PowerShell module for Test Driven Development</A></P>
<BLOCKQUOTE>
<P>Pester provides a framework for&nbsp;running unit tests to execute and validate PowerShell commands from within PowerShell. Pester consists of a simple set of functions that expose a testing domain-specific language (DSL) for isolating, running, evaluating and reporting the results of PowerShell commands</P></BLOCKQUOTE>
<P>If you have PowerShell version 5 then you will have Pester already installed although you should update it to the latest version. If not you can get <A href="https://www.powershellgallery.com/packages/Pester/" rel=noopener target=_blank>Pester from the PowerShell Gallery</A>&nbsp;follow the instructions on that page to install it. <A href="https://www.simple-talk.com/sysadmin/powershell/practical-powershell-unit-testing-getting-started/https://www.simple-talk.com/sysadmin/powershell/practical-powhttps://www.simple-talk.com/sysadmin/powershell/practical-powershell-unit-testing-getting-started/ershell-unit-testing-getting-started/" rel=noopener target=_blank>This is a good post to start learning about Pester</A></P>
<H2>The Command Get-SQLDiagFix</H2>
<P>Get-SQLDiagFix&nbsp; returns the Product Name, Feature Name/Area, KB Number, Title and URL for the Fixes in the Cumulative Updates returned from the SQL Server Diagnostics Recommendations API. One Fix looks like this</P>
<P><A href="https://blog.robsewell.com/assets/uploads/2017/07/07-get-sqldiagfix-result.png?ssl=1" rel=noopener target=_blank><IMG class="alignnone size-full wp-image-7074" alt="07 - Get-SQLDiagFix result.png" src="https://blog.robsewell.com/assets/uploads/2017/07/07-get-sqldiagfix-result.png?resize=630%2C99&amp;ssl=1" width=630 height=99 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/07/07-get-sqldiagfix-result.png?fit=630%2C99&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/07/07-get-sqldiagfix-result.png?fit=300%2C47&amp;ssl=1" data-image-description="" data-image-title="07 – Get-SQLDiagFix result" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1348,212" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/07/07-get-sqldiagfix-result.png?fit=1348%2C212&amp;ssl=1" data-permalink="https://blog.robsewell.com/writing-dynamic-and-random-tests-cases-for-pester/07-get-sqldiagfix-result/#main" data-attachment-id="7074"></A></P>
<P>This is how I wrote the Pester tests for that command</P>
<H2>Mocking the results</H2>
<P>In my describe block for each function I mock <A href="https://blog.robsewell.com/powershell-module-for-the-sql-server-diagnostics-api-1st-command-get-sqldiagrecommendations/" rel=noopener target=_blank>Get-SQLDiagRecommendations.</A> This is the command that each of the current available commands in the module use to get the recommendations from the <A href="https://ecsapi.portal.azure-api.net/docs/services/594965d5e4951210cc7dd2c5/operations/594965d5e4951208204beb59" rel=noopener target=_blank>SQL Server Diagnostic Recommendations API</A>. I did this by creating a json file from the API and saving it in a json folder inside the tests folder</P>
<P><A href="https://blog.robsewell.com/assets/uploads/2017/07/01-json-folder.png?ssl=1" rel=noopener target=_blank><IMG class="alignnone size-full wp-image-6857" alt="01 - JSON folder.png" src="https://blog.robsewell.com/assets/uploads/2017/07/01-json-folder.png?resize=630%2C869&amp;ssl=1" width=630 height=869 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/07/01-json-folder.png?fit=630%2C869&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/07/01-json-folder.png?fit=218%2C300&amp;ssl=1" data-image-description="" data-image-title="01 – JSON folder" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="866,1194" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/07/01-json-folder.png?fit=866%2C1194&amp;ssl=1" data-permalink="https://blog.robsewell.com/writing-dynamic-and-random-tests-cases-for-pester/01-json-folder/#main" data-attachment-id="6857"></A></P>
<P>I can then mock Get-SQLDiagRecommendations inside a BeforeAll code block using</P><PRE class="lang:ps decode:true">Describe "Get-SQLDiagFix" -Tags Build , Unit, Fix {
BeforeAll {
    $Recommendations = (Get-Content $PSScriptRoot\json\recommendations.JSON) -join "`n" | ConvertFrom-Json
    Mock Get-SQLDiagRecommendations {$Recommendations}
}</PRE>
<DIV></DIV>
<DIV>This means that every time the code in the test calls Get-SQLDiagRecommendations it will not use the internet to connect to the API and return an object. Instead it will return the $Recommendations object which is loaded from a file on the file system. I am not, therefore, depending on any external factors and I have a known set of data for my test results.</DIV>
<DIV></DIV>
<DIV>I also have a set of mocks in my Output Context code block</DIV>
<DIV></DIV>
<DIV><PRE class="lang:ps decode:true">Context "Output" {
BeforeAll {
    $Fixes = (Get-Content $PSScriptRoot\json\fix.JSON) -join "`n" | ConvertFrom-Json
    $Products = Get-SQLDiagProduct
    $Features = Get-SQLDiagFeature
}</PRE></DIV>
<DIV></DIV>
<P>The fixes.json is a file which was created from the recommendations.json and only contains the properties returned by GetSQLDiagFix which is what we are testing here. I can set variables for Products and Features using the commands from the module as these will call Get-SQLDiagRecommendations which we have already mocked.</P>
<H2>Test All of the Fixes</H2>
<P>I can now test that the code I have written for Get-SQLDiagFix returns the correct data without any parameters using this test with <A href="https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.utility/compare-object" rel=noopener target=_blank>Compare-Object</A>.</P><PRE class="lang:ps decode:true">It "returns all of the fixes with no parameter" {
    Compare-Object (Get-SQLDiagFix) $Fixes | Should BeNullOrEmpty
}</PRE>
<DIV></DIV>
<DIV>If there is no difference between the object returned from Get-SQLDiagFix and the $fixes object which uses the json file then the code is working as expected and the test will pass.</DIV>
<DIV></DIV>
<H2>Test Cases</H2>
<DIV></DIV>
<DIV>
<P>I learned about test cases from <A href="http://mikefrobbins.com/2016/12/09/loop-through-a-collection-of-items-with-the-pester-testcases-parameter-instead-of-using-a-foreach-loop/" rel=noopener target=_blank>Mike Robbins blog post</A>. Test cases enable you to provide a hash table of options and loop through the same test for each of them. Here is an example</P></DIV>
<P>There are the following products in the Recommendation API</P>
<UL>
<LI>SQL Server 2012 SP3 
<LI>SQL Server 2016 SP1 
<LI>SQL Server 2016 RTM 
<LI>SQL Server 2014 SP1 
<LI>SQL Server 2014 SP2 </LI></UL>
<DIV></DIV>
<DIV>and I want to run a test for each product to check that the fixes returned from Get-SQLDiagFix for that product match the $fixes object filtered by Product for those products. Here is the code</DIV>
<DIV></DIV>
<DIV><PRE class="lang:ps decode:true">$TestCases = @{ ProductName = 'SQL Server 2012 SP3'},
@{ ProductName = 'SQL Server 2016 SP1'},
@{ ProductName = 'SQL Server 2016 RTM'},
@{ ProductName ='SQL Server 2014 SP1'},
@{ ProductName = 'SQL Server 2014 SP2'}
It "Returns the correct results with a single product parameter &amp;amp;amp;amp;amp;lt;ProductName&amp;amp;amp;amp;amp;gt;" -TestCases $TestCases {
    param($productname)
    $results = $fixes.Where{$_.Product -in $ProductName}
    Compare-Object (Get-SQLDiagFix -Product $productname) $results | Should BeNullOrEmpty
}</PRE></DIV>
<DIV></DIV>
<DIV>You can click on the image below to see a larger, more readable version.</DIV>
<DIV></DIV>
<DIV><A href="https://blog.robsewell.com/assets/uploads/2017/07/02-test-cases.png?ssl=1" rel=noopener target=_blank><IMG class="alignnone size-full wp-image-6898" alt="02 Test Cases.png" src="https://blog.robsewell.com/assets/uploads/2017/07/02-test-cases.png?resize=630%2C142&amp;ssl=1" width=630 height=142 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/07/02-test-cases.png?fit=630%2C142&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/07/02-test-cases.png?fit=300%2C68&amp;ssl=1" data-image-description="" data-image-title="02 Test Cases" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="2615,589" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/07/02-test-cases.png?fit=2615%2C589&amp;ssl=1" data-permalink="https://blog.robsewell.com/writing-dynamic-and-random-tests-cases-for-pester/02-test-cases/#main" data-attachment-id="6898"></A></DIV>
<DIV></DIV>
<P>The $TestCases variable holds an array of hashtables, one for each product with a Name that matches the parameter that I use in the test and a value of the product name.</P>
<P>I wrote one test, one It code block.&nbsp; I refer to the product in the title inside &lt;&gt; using the same name as the name in the hashtable. The test (It) needs a parameter of -TestCases with a value (in this example) of the $TestCases variable we have just defined. It also needs a param block with a parameter that matches the Name value from the hashtables.</P>
<P>The expected test results are placed in a $results variable by filtering the $Fixes variable (defined in the BeforeAll code block above) by the parameter $Productname</P>
<P>The test will then run for each of the test cases in the $TestCases variable comparing the results of Get-SQLDiagFix -Product $Productname with the expected results from the $fixes variable</P>
<P>Here are the test results</P>
<H2><A href="https://blog.robsewell.com/assets/uploads/2017/07/03-product-test-results.png?ssl=1" rel=noopener target=_blank><IMG class="alignnone size-full wp-image-6917" alt="03 - product test results.png" src="https://blog.robsewell.com/assets/uploads/2017/07/03-product-test-results.png?resize=630%2C105&amp;ssl=1" width=630 height=105 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/07/03-product-test-results.png?fit=630%2C105&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/07/03-product-test-results.png?fit=300%2C50&amp;ssl=1" data-image-description="" data-image-title="03 – product test results" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1819,303" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/07/03-product-test-results.png?fit=1819%2C303&amp;ssl=1" data-permalink="https://blog.robsewell.com/writing-dynamic-and-random-tests-cases-for-pester/03-product-test-results/#main" data-attachment-id="6917"></A></H2>
<H2>Multiple Products in Test Cases</H2>
<P>I also want to test that Get-SQLDiagFix will work for multiple Products. I need to create TestCases for those too. I do that in exactly the same way</P><PRE class="lang:ps decode:true">$TestCases = @{ ProductName = 'SQL Server 2012 SP3', 'SQL Server 2016 SP1'},
@{ ProductName = 'SQL Server 2012 SP3', 'SQL Server 2016 SP1', 'SQL Server 2016 RTM'},
@{ ProductName = 'SQL Server 2012 SP3', 'SQL Server 2016 SP1', 'SQL Server 2016 RTM', 'SQL Server 2014 SP1'},
@{ ProductName = 'SQL Server 2012 SP3', 'SQL Server 2016 SP1', 'SQL Server 2016 RTM', 'SQL Server 2014 SP1', 'SQL Server 2014 SP2'}
    It "Returns the correct results with multiple product parameter &lt;ProductName&gt;" -TestCases $TestCases {
        param($productname)
        $results = $fixes.Where{$_.Product -in $ProductName}
        Compare-Object (Get-SQLDiagFix -Product $productname) $results | Should BeNullOrEmpty
}</PRE>
<DIV>Which looks like this when the tests run</DIV>
<DIV><A href="https://blog.robsewell.com/assets/uploads/2017/07/04-mulitple-product-test-results.png?ssl=1" rel=noopener target=_blank><IMG class="alignnone size-full wp-image-6932" alt="04 - mulitple product test results.png" src="https://blog.robsewell.com/assets/uploads/2017/07/04-mulitple-product-test-results.png?resize=630%2C56&amp;ssl=1" width=630 height=56 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/07/04-mulitple-product-test-results.png?fit=630%2C56&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/07/04-mulitple-product-test-results.png?fit=300%2C26&amp;ssl=1" data-image-description="" data-image-title="04 – mulitple product test results" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="3023,267" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/07/04-mulitple-product-test-results.png?fit=3023%2C267&amp;ssl=1" data-permalink="https://blog.robsewell.com/writing-dynamic-and-random-tests-cases-for-pester/04-mulitple-product-test-results/#main" data-attachment-id="6932"></A></DIV>
<H2>Single Feature Dynamic Test Cases</H2>
<P>Get-SQLDiagFix can also filter the fixes by feature area. The features are returned from Get-SQLDiagFeature. This means that I can create a test for each of the features by using the $features variable which was defined in the BeforeAll block as</P><PRE class="lang:ps decode:true">$Features = Get-SQLDiagFeature</PRE>
<P>Then I can dynamically create test cases using</P><PRE class="lang:ps decode:true">$TestCases = @()
$Features | Foreach-Object {$TestCases += @{Feature = $_}}
It "Returns the correct results with a single feature &lt;Feature&gt;" -TestCases $TestCases {
    param($Feature)
    $results = $fixes.Where{$_.Feature -in $Feature}
    Compare-Object (Get-SQLDiagFix -Feature $Feature) $results | Should BeNullOrEmpty
}</PRE>
<P>and the results look like</P>
<P><A href="https://blog.robsewell.com/assets/uploads/2017/07/05-single-feature-test-results.png?ssl=1" rel=noopener target=_blank><IMG class="alignnone size-full wp-image-6946" alt="05 - single feature test results.png" src="https://blog.robsewell.com/assets/uploads/2017/07/05-single-feature-test-results.png?resize=630%2C299&amp;ssl=1" width=630 height=299 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/07/05-single-feature-test-results.png?fit=630%2C299&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/07/05-single-feature-test-results.png?fit=300%2C142&amp;ssl=1" data-image-description="" data-image-title="05 – single feature test results" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1719,815" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/07/05-single-feature-test-results.png?fit=1719%2C815&amp;ssl=1" data-permalink="https://blog.robsewell.com/writing-dynamic-and-random-tests-cases-for-pester/05-single-feature-test-results/#main" data-attachment-id="6946"></A></P>
<H2>Random Dynamic Multiple Feature Test Cases</H2>
<P>I also need to test that Get-SQLDiagFix returns the correct results for multiple features and whilst I could create those by hand like the products example above why not let PowerShell do that for me?</P>
<P>I created 10 test cases. Each one has a random number of features between 2 and the number of features.&nbsp; I can then write one test to make use of those test cases. This is how I do that</P><PRE class="lang:ps decode:true">## Generate 10 TestCases of a random number of Features
$TestCases = @()
$x = 10
While ($x -gt 0) {
    ## We are testing multiples so we need at least 2
    $Number = Get-Random -Maximum $Features.Count -Minimum 2
    $Test = @()
    While ($Number -gt 0) {
        $Test += Get-Random $Features
        $Number --
    }
## Need unique values
$Test = $test | Select-Object -Unique
$TestCases += @{Feature = $Test}
$X --
}
It "Returns the correct results with multiple features &lt;Feature&gt;" -TestCases $TestCases {
 param($Feature)
 $results = $fixes.Where{$_.Feature -in $Feature}
 Compare-Object (Get-SQLDiagFix -Feature $Feature) $results | Should BeNullOrEmpty
 }</PRE>
<P>Now there are 10 tests each with a random number of features and the results look like this. Each time the test is run it will use a different set of features for each of the 10 tests but I will know that I am testing that the code will return the correct results for multiple features</P>
<H2><A href="https://blog.robsewell.com/assets/uploads/2017/07/06-multiple-features.png?ssl=1" rel=noopener target=_blank><IMG class="alignnone size-full wp-image-6978" alt="06 - multiple features.png" src="https://blog.robsewell.com/assets/uploads/2017/07/06-multiple-features.png?resize=630%2C64&amp;ssl=1" width=630 height=64 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/07/06-multiple-features.png?fit=630%2C64&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/07/06-multiple-features.png?fit=300%2C31&amp;ssl=1" data-image-description="" data-image-title="06 – multiple features" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="2918,298" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/07/06-multiple-features.png?fit=2918%2C298&amp;ssl=1" data-permalink="https://blog.robsewell.com/writing-dynamic-and-random-tests-cases-for-pester/06-multiple-features/#main" data-attachment-id="6978"></A></H2>
<H2>Two Sets of Test Cases?</H2>
<P>It is also possible for Get-SQLDiagFix to have one or more products and one or more features passed as parameters, which obviously also need to be tested to ensure the code is returning the correct results. As Pester is just PowerShell we can use normal PowerShell code. This means that I can test for a single product and a single feature using a foreach loop and Test Cases like this</P><PRE class="lang:ps decode:true">foreach ($Product in $Products) {
    $TestCases = @()
    $Features = Get-SQLDiagFeature -Product $Product
    $Features | Foreach-Object {$TestCases += @{Feature = $_}}
    It "Returns the correct results for a single product parameter $Product with a single feature &lt;Feature&gt;" -TestCases $TestCases {
        param($Feature)
        $results = $fixes.Where{$_.Product -eq $product -and $_.Feature -in $Feature}
        Compare-Object (Get-SQLDiagFix -Product $Product -Feature $Feature) $results | Should BeNullOrEmpty
    }
}</PRE>
<P>To test for a single product and multiple features I use this code</P><PRE class="lang:ps decode:true"> foreach ($Product in $Products) {
    ## Generate 10 TestCases of a random number of Features
    $TestCases = @()
    $x = 10
    While ($x -gt 0) {
        ## We are testing multiples so we need at least 2
        $Number = Get-Random -Maximum $Features.Count -Minimum 2
        $Test = @()
        While ($Number -gt 0) {
            $Test += Get-Random $Features
            $Number --
        }
        ## Need unique values
        $Test = $test | Select-Object -Unique
        $TestCases += @{Feature = $Test}
        $X --
    }
    It "Returns the correct results for a single product parameter $Product with a multiple features &lt;Feature&gt;" -TestCases $TestCases {
        param($Feature)
        $Test = (Get-SQLDiagFix -Product $Product -Feature $Feature)
        ## If there are no results Compare-Object bombs out even though it is correct
        ## This is a risky fix for that
        if ($Test) {
        $results = $fixes.Where{$_.Product -eq $product -and $_.Feature -in $Feature}
        Compare-Object $test $results | Should BeNullOrEmpty
        }
    }
 } </PRE>
<P>Because it is dynamically creating the values for the two parameters, I have to check that there are some results to test on line 23 as Compare-Object will throw an error if the object to be compared is empty. I need to do this because it is possible for the test to pick products and features in a combination that there are no fixes in the results.</P>
<P>The reason I have commented it as a risky fix is because if someone changes the code and Get-SQLDiagFix does not return any results then the test would not run and therefore there would be no information <STRONG>from this test&nbsp;</STRONG>that the code had a bug. However, in this suite of tests there are many tests that would fail in that scenario but be careful in your own usage.</P>
<P>I test for multiple products with a single feature and multiple products with multiple features like this</P><PRE class="lang:ps decode:true"> $Products = @('SQL Server 2012 SP3', 'SQL Server 2016 SP1'),
 @('SQL Server 2012 SP3', 'SQL Server 2016 SP1', 'SQL Server 2016 RTM'),
 @('SQL Server 2012 SP3', 'SQL Server 2016 SP1', 'SQL Server 2016 RTM', 'SQL Server 2014 SP1'),
 @('SQL Server 2012 SP3', 'SQL Server 2016 SP1', 'SQL Server 2016 RTM', 'SQL Server 2014 SP1', 'SQL Server 2014 SP2')
 foreach ($Product in $Products) {
     $TestCases = @()
     $Features = Get-SQLDiagFeature -Product $Product
     $Features | Foreach-Object {$TestCases += @{Feature = $_}}
     It "Returns the correct results for multiple products parameter $Product with a single feature &lt;Feature&gt;" -TestCases $TestCases {
         param($Feature)
         $results = $fixes.Where{$_.Product -in $product -and $_.Feature -in $Feature}
         Compare-Object (Get-SQLDiagFix -Product $Product -Feature $Feature) $results | Should BeNullOrEmpty
     }
}
 $Products = @('SQL Server 2012 SP3', 'SQL Server 2016 SP1'),
 @('SQL Server 2012 SP3', 'SQL Server 2016 SP1', 'SQL Server 2016 RTM'),
 @('SQL Server 2012 SP3', 'SQL Server 2016 SP1', 'SQL Server 2016 RTM', 'SQL Server 2014 SP1'),
 @('SQL Server 2012 SP3', 'SQL Server 2016 SP1', 'SQL Server 2016 RTM', 'SQL Server 2014 SP1', 'SQL Server 2014 SP2')
 foreach ($Product in $Products) {
     ## Generate 10 TestCases of a random number of Features
     $TestCases = @()
     $x = 10
     While ($x -gt 0) {
         ## We are testing multiples so we need at least 2
         $Number = Get-Random -Maximum $Features.Count -Minimum 2
         $Test = @()
         While ($Number -gt 0) {
             $Test += Get-Random $Features
             $Number --
         }
     ## Need unique values
     $Test = $test | Select-Object -Unique
     $TestCases += @{Feature = $Test}
     $X --
 }
 It "Returns the correct results for multiple products parameter $Product with a multiple feature &lt;Feature&gt;" -TestCases $TestCases {
     param($Feature)
     $Test = (Get-SQLDiagFix -Product $Product -Feature $Feature)
     ## Annoyingly if there are no results Compare-Object bombs out even though it is correct
     ## This is a risky fix for that
     if ($Test) {
         $results = $fixes.Where{$_.Product -in $product -and $_.Feature -in $Feature}
         Compare-Object $test $results | Should BeNullOrEmpty
        }
    }
 } </PRE>
<P>You can see all of the unit tests for the SQLDiagAPI module <A href="https://github.com/SQLDBAWithABeard/SQLDiagAPI/blob/master/tests/Unit.Tests.ps1" rel=noopener target=_blank>in my GitHub repository</A></P>
<P>The module is <A href="https://www.powershellgallery.com/packages/SQLDiagAPI/" rel=noopener target=_blank>available on the PowerShell Gallery</A> which means that you can install it using</P><PRE class="lang:ps decode:true">Install-Module SQLDiagAPI</PRE>

