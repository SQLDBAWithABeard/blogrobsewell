---
title: "Pester for Presentations – Ensuring it goes ok"
categories:
  - Blog

tags:
  - pester
  - PowerShell
  - presentations

---
<P>Whilst I was at&nbsp;<A href="http://psconf.eu" rel="noopener noreferrer" target=_blank>PSCONFEU</A>&nbsp;I presented a session on writing pester tests instead of using checklists.&nbsp;<A href="https://www.youtube.com/watch?v=Qy-uvT57pt8" rel="noopener noreferrer" target=_blank>You can see it here</A></P>
<P>During the talk I showed the pester test that I use to make sure that everything is ready for my presentation. A couple of people have asked me about this and wanted to know more so I thought that I would blog about it.</P>
<P>Some have said that I might be being a little OCD about it 😉 I agree that it could seem like that but there is nothing worse than having things go wrong during your presentation. It makes your heart beat faster and removes the emphasis from the presentation that you give.</P>
<P>When it is things that you as a presenter could have been able to foresee, like a VM not being started or a database not being restored to the pre-demo state or being logged in as the wrong user then it is much worse</P>
<P>I use Pester to ensure that my environment for my presentation is as I expect and in fact, in Hanover when I ran through my Pester test for my NUC environment I found that one of my SQL Servers had decided to be in a different time zone and therefore the SQL Service would not authenticate and start. I was able to quickly remove the references to that server and save myself from a sea of&nbsp;red during my demos</P>
<P>For those that don’t know.&nbsp;<A href="https://github.com/pester/Pester" rel="noopener noreferrer" target=_blank>Pester is a PowerShell module&nbsp;for Test Driven Development</A></P>
<BLOCKQUOTE>
<P>Pester provides a framework for&nbsp;running unit tests to execute and validate PowerShell commands from within PowerShell. Pester consists of a simple set of functions that expose a testing domain-specific language (DSL) for isolating, running, evaluating and reporting the results of PowerShell commands</P></BLOCKQUOTE>
<P>If you have PowerShell version 5 then you will have Pester already installed although you should update it to the latest version. If not you can get <A href="https://www.powershellgallery.com/packages/Pester/" rel="noopener noreferrer" target=_blank>Pester from the&nbsp;PowerShell Gallery</A>&nbsp;follow the instructions on that page to install it. <A href="https://www.simple-talk.com/sysadmin/powershell/practical-powershell-unit-testing-getting-started/" rel="noopener noreferrer" target=_blank>This is a good post to&nbsp;start learning about Pester</A></P>
<P>What can you test? Everything. Well, specifically everything that you can write a PowerShell command to check. So when I am setting up for my presentation I check the following things. I add new things to my tests as I think of them or as I observe things that may break my presentations. Most recently that was ensuring that my Visual Studio Code session was running under the correct user. I did that like this</P><PRE class="lang:ps decode:true">Describe "Presentation Test" {
    Context "VSCode" {
        It "Should be using the right username" {
            whoami | Should Be 'TheBeard\Rob'
       }
    }
}</PRE>
<P><IMG class="alignnone size-full wp-image-5729" alt="01 - username.PNG" src="https://blog.robsewell.com/assets/uploads/2017/05/01-username.png?resize=630%2C343&amp;ssl=1" width=630 height=343 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/05/01-username.png?fit=630%2C343&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/05/01-username.png?fit=300%2C163&amp;ssl=1" data-image-description="" data-image-title="01 – username" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1295,705" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/05/01-username.png?fit=1295%2C705&amp;ssl=1" data-permalink="https://blog.robsewell.com/pester-for-presentations-ensuring-it-goes-ok/01-username/#main" data-attachment-id="5729"></P>
<P>I think about the things that are important to me for my presentation.&nbsp; I want to ensure that I only have one VS Code window open to avoid that situation where I am clicking through windows looking for the correct window. I can do that using&nbsp;<A href="https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.management/get-process" rel="noopener noreferrer" target=_blank>Get-Process</A></P><PRE class="lang:ps decode:true">It "Should have Code Insiders Open" {
(Get-Process 'Code - Insiders' -ErrorAction SilentlyContinue)| Should Not BeNullOrEmpty
}
        It "Should have One VS Code Process" {
            (Get-Process 'Code - Insiders' -ErrorAction SilentlyContinue).Count | Should Be 1
        }

</PRE>
<P>I use -ErrorAction SilentlyContinue so that I don’t get a sea of red when I run the tests. Next I want to check my PowerPoint is ready for my presentation</P>
<P>[code langauge=”PowerShell”]<BR>It "Should have PowerPoint Open" {<BR>(Get-Process POWERPNT -ErrorAction SilentlyContinue).Count | Should Not BeNullOrEmpty<BR>}<BR>It "Should have One PowerPoint Open" {<BR>(Get-Process POWERPNT -ErrorAction SilentlyContinue).Count | Should Be 1<BR>}<BR>It "Should have the correct PowerPoint Presentation Open" {<BR>(Get-Process POWERPNT -ErrorAction SilentlyContinue).MainWindowTitle| Should Be ‘dbatools – SQL Server and PowerShell together – PowerPoint’<BR>}</P>
<P>Again I use Get-Process. I check if PowerPoint is open, if there is one PowerPoint open and I use the MainWindowTitle property to check that it is the right PowerPoint presentation after nearly starting a presentation for SqlServer module with the dbatools slides!</P>
<P>I don’t want any distractions when I am presenting. I have the sort of friends who will notice if I get notifications for twitter popping up on my screen and repeatedly send tweets to make people laugh. (I admit, I’m one of those friends – I do this too!)</P>
<P><IMG class="alignnone size-full wp-image-5733" alt="02 - Friends!!.PNG" src="https://blog.robsewell.com/assets/uploads/2017/05/02-friends.png?resize=630%2C283&amp;ssl=1" width=630 height=283 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/05/02-friends.png?fit=630%2C283&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/05/02-friends.png?fit=300%2C135&amp;ssl=1" data-image-description="" data-image-title="02 – Friends!!" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1671,750" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/05/02-friends.png?fit=1671%2C750&amp;ssl=1" data-permalink="https://blog.robsewell.com/pester-for-presentations-ensuring-it-goes-ok/02-friends/#main" data-attachment-id="5733"></P>
<P>Now I cannot get a test for quiet hours working. You can apparently use a Registry key, which of course you can check with PowerShell but I was unable to get it working. I haven’t looked at testing for <A href="http://www.thewindowsclub.com/presentation-settings-in-windows-7" rel="noopener noreferrer" target=_blank>Presentation Mode </A>&nbsp;but I test that those programmes are shut down, again using Get-Process</P><PRE class="lang:ps decode:true">        It "Mail Should be closed" {
            (Get-Process HxMail -ErrorAction SilentlyContinue).Count | Should Be 0
        }
        It "Tweetium should be closed" {
            (Get-Process WWAHost -ErrorAction SilentlyContinue).Count | Should Be 0
        }
        It "Slack should be closed" {
            (Get-Process slack* -ErrorAction SilentlyContinue).Count | Should BE 0
        }</PRE>
<P>I am generally presenting with SQL Server so I need to make sure that SQL Server is running. I do this with <A href="https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.management/get-service" rel="noopener noreferrer" target=_blank>Get-Service</A></P><PRE class="lang:ps decode:true">Context "Local SQL" {
        It "DBEngine is running" {
            (Get-Service mssqlserver).Status | Should Be Running
        }
        It "SQL Server Agent is running" {
            (Get-Service sqlserveragent).Status | Should Be Running
        }
        It "DAVE DBEngine is running" {
            (Get-Service mssql*Dave).Status | Should Be Running
        }
        It "DAVE Agent is running" {
            (Get-Service sqlagent*dave).Status | Should Be Running
        }
    }</PRE>
<P>In this example I am testing that the SQL Service and the Agent service are running on both of my local instances.</P>
<P>I use a NUC running Hyper-V to enable me to show a number of SQL Servers running in a domain environment so I need to be able to test those too. I set the values of the servers I need into a variable and check that the VM is running and that they respond to ping</P><PRE class="lang:ps decode:true"> Context "VM State" {
        $NUCServers = 'BeardDC1','BeardDC2','LinuxvNextCTP14','SQL2005Ser2003','SQL2012Ser08AG3','SQL2012Ser08AG1','SQL2012Ser08AG2','SQL2014Ser12R2','SQL2016N1','SQL2016N2','SQL2016N3','SQLVnextN1','SQL2008Ser12R2'
        $NUCVMs = Get-VM -ComputerName beardnuc | Where-Object {$_.Name -in $NUCServers}
            foreach($VM in $NUCVms)
                {
                $VMName = $VM.Name
                  It "$VMName Should be Running"{
                    $VM.State | Should Be 'Running'
                  }
			    }
    }
Context "THEBEARD_Domain" {
            $NUCServers = 'BeardDC1','BeardDC2','LinuxvNextCTP14','SQL2005Ser2003','SQL2012Ser08AG3','SQL2012Ser08AG1','SQL2012Ser08AG2','SQL2014Ser12R2','SQL2016N1','SQL2016N2','SQL2016N3','SQLVnextN1','SQL2008Ser12R2'
            foreach($VM in $NUCServers)
                {
                                 It "$VM Should respond to ping" {
				(Test-Connection -ComputerName $VM -Count 1 -Quiet -ErrorAction SilentlyContinue) | Should be $True
				}
                }
    }</PRE>
<P>I also need to check if the SQL Service and the Agent Service is running on each server</P><PRE class="lang:ps decode:true">  Context "SQL State" {
        $SQLServers = (Get-VM -ComputerName beardnuc | Where-Object {$_.Name -like '*SQL*'  -and $_.State -eq 'Running'}).Name
        foreach($Server in $SQLServers)
        {
          $DBEngine = Get-service -ComputerName $Server -Name MSSQLSERVER
           It "$Server  DBEngine should be running" {
                $DBEngine.Status | Should Be 'Running'
            }
           It "$Server DBEngine Should be Auto Start" {
            $DBEngine.StartType | Should be 'Automatic'
           }
              $Agent= Get-service -ComputerName $Server -Name SQLSERVERAGENT
              It "$Server Agent should be running" {
                  $Agent.Status | Should Be 'Running'
           }
           It "$Server Agent Should be Auto Start" {
            $Agent.StartType | Should be 'Automatic'
           }
        }
        It "Linux SQL Server should be accepting connections" {
            $cred = Import-Clixml C:\temp\sa.xml
            {Connect-DbaSqlServer -SqlServer LinuxvnextCTP14 -Credential $cred -ConnectTimeout 60} | Should Not Throw
        }

    }
}</PRE>
<P>I check that the Linux SQL Server is available by storing the credential using <A href="https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.utility/export-clixml" rel="noopener noreferrer" target=_blank>Export-CliXML</A> &nbsp;and then use that credential with <A href="https://dbatools.io/functions/connect-dbasqlserver/" rel="noopener noreferrer" target=_blank>Connect-DbaSqlServer</A> from dbatools</P>
<P>Using a NUC means I sometimes have fun with networking so I have a couple of tests for that too. Testing for the correct DNS Servers and gateways</P><PRE class="lang:ps decode:true">    It "Should have DNS Servers for correct interface" {
        (Get-DnsClientServerAddress -InterfaceAlias 'Ethernet 3').Serveraddresses | Should Be @('10.0.0.1','10.0.0.2')
    }
    It "Should have correct gateway for alias"{
        (Get-NetIPConfiguration -InterfaceAlias 'Ethernet 3').Ipv4DefaultGateway.NextHop | Should Be '10.0.0.10'
    }</PRE>
<P>All of those are generic tests that have evolved over time and are run for every presentation but when I have specific things you require for a single presentation I test for those too.</P>
<P>For Example, later this week Cláudio Silva and I are presenting on <A href="https://dbatools.io" rel="noopener noreferrer" target=_blank>dbatools</A> at <A href="https://tugait.pt" rel="noopener noreferrer" target=_blank>TUGAIT</A> &nbsp;We are showing the <A href="https://dbatools.io/functions/test-dbamaxmemory" rel="noopener noreferrer" target=_blank>Test-DbaMaxMemory</A> &nbsp;, Get-DbaMaxMemory and <A href="https://dbatools.io/functions/set-dbamaxmemory/" rel="noopener noreferrer" target=_blank>Set-DbaMaxMemory</A> commands so we need to ensure that the Max Memory for some servers is (In) Correctly set. I use <A href="https://dbatools.io/functions/Connect-DbaSQLServer/" rel="noopener noreferrer" target=_blank>Connect-DbaSqlServer</A> to create an SMO Server object and test that</P><PRE class="lang:ps decode:true">    It "Max Memory on SQl2012SerAG1 2 and 3 should be 2147483647" {
        (Connect-DbaSqlServer SQL2012Ser08AG1).Configuration.MaxServerMemory.RunValue | Should Be 2147483647
        (Connect-DbaSqlServer SQL2012Ser08AG2).Configuration.MaxServerMemory.RunValue | Should Be 2147483647
        (Connect-DbaSqlServer SQL2012Ser08AG3).Configuration.MaxServerMemory.RunValue | Should Be 2147483647
    }</PRE>
<P>We are also showing the <A href="https://dbatools.io/functions/Test-DbaIdentityUsage" rel="noopener noreferrer" target=_blank>Test-DbaIdentityUsage</A> command so a column needs to be pre-prepared in AdventureWorks2014 to be able to show the error</P><PRE class="lang:ps decode:true">    It "ShiftID LastValue Should be 255" {
        $a = Test-DbaIdentityUsage -SqlInstance ROB-XPS -Databases AdventureWorks2014 -NoSystemDb
        $a.Where{$_.Column -eq 'ShiftID'}.LastValue | should Be 255
    }</PRE>
<P>To ensure that we have orphaned files available for the <A href="https://dbatools.io/functions/Find-DbaOrphanedFile" rel="noopener noreferrer" target=_blank>Find-DbaOrphanedFile</A> command I use this</P><PRE class="lang:ps decode:true">    It "has Orphaned Files ready"{
        (Find-DbaOrphanedFile -SqlServer SQL2016N2).Count | Should Be 30
    }</PRE>
<P>There are any number of things that you may want to test to ensure that, as best as possible, the demo gods are not going to come and bite you in the middle of your presentation.</P>
<UL>
<LI>Files or Folders exist (or dont exist) 
<LI>Databases, Agent Jobs, Alerts 
<LI>Operators, Logins 
<LI>SSIS packages, SSRS Reports 
<LI>PowerBi files 
<LI>Azure connectivity 
<LI>Azure components </LI></UL>
<P>The list is endless, just look at what you require for your presentation.</P>
<P>Anything you can check with PowerShell you can test with Pester so build up your Pester presentation tests and reduce the reliance on the demo gods! I’ll still leave this here just to be safe!!</P>
<P><IMG class="alignnone size-full wp-image-5756" alt="pray to the demo gods.jpg" src="https://blog.robsewell.com/assets/uploads/2017/05/pray-to-the-demo-gods.jpg?resize=400%2C400&amp;ssl=1" width=400 height=400 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/05/pray-to-the-demo-gods.jpg?fit=400%2C400&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/05/pray-to-the-demo-gods.jpg?fit=300%2C300&amp;ssl=1" data-image-description="" data-image-title="pray to the demo gods" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="400,400" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/05/pray-to-the-demo-gods.jpg?fit=400%2C400&amp;ssl=1" data-permalink="https://blog.robsewell.com/pester-for-presentations-ensuring-it-goes-ok/pray-to-the-demo-gods/#main" data-attachment-id="5756"></P>

