---
title: "Pester Test Inception and the Show Parameter"
date: "2017-05-09" 
categories:
  - Blog

tags:
  - pester
  - PowerShell

---
<P>My fantastic friend Andre Kamman <A href="https://t.co/kFfwIJ3kDO" rel="noopener noreferrer" target=_blank>b</A> | <A href="https://twitter.com/AndreKamman" rel="noopener noreferrer" target=_blank>t</A>&nbsp; and I presented at <A href="http://psconf.eu" rel="noopener noreferrer" target=_blank>PSConfEu</A> last week</P>
<P><IMG class="alignnone size-full wp-image-5601" alt="C_EDtK0XoAA1PL7 (2).jpg" src="https://blog.robsewell.com/assets/uploads/2017/05/c_edtk0xoaa1pl7-2.jpg?resize=630%2C472&amp;ssl=1" width=630 height=472 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/05/c_edtk0xoaa1pl7-2.jpg?fit=630%2C472&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/05/c_edtk0xoaa1pl7-2.jpg?fit=300%2C225&amp;ssl=1" data-image-description="" data-image-title="C_EDtK0XoAA1PL7 (2)" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"1494188283","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"1"}' data-comments-opened="1" data-orig-size="842,631" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/05/c_edtk0xoaa1pl7-2.jpg?fit=842%2C631&amp;ssl=1" data-permalink="https://blog.robsewell.com/pester-test-inception-and-the-show-parameter/c_edtk0xoaa1pl7-2/#main" data-attachment-id="5601"></P>
<P>and whilst we were there we were chatting about running Pester Tests. He wanted to know how he could run a Pester Test and not lose the failed tests as they scrolled past him. In his particular example we were talking about running hundreds of tests on thousands of databases on hundreds of servers</P>
<P><IMG class="alignnone size-full wp-image-5608" alt="01 - pesters.gif" src="https://blog.robsewell.com/assets/uploads/2017/05/01-pesters.gif?resize=630%2C455&amp;ssl=1" width=630 height=455 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/05/01-pesters.gif?fit=630%2C455&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/05/01-pesters.gif?fit=300%2C216&amp;ssl=1" data-image-description="" data-image-title="01 – pesters" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="826,596" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/05/01-pesters.gif?fit=826%2C596&amp;ssl=1" data-permalink="https://blog.robsewell.com/pester-test-inception-and-the-show-parameter/01-pesters/#main" data-attachment-id="5608"></P>
<P>I guess it looks something like that!!</P>
<P>I explained about the -Show parameter which allows you to filter the results that you see. Using Get-Help Invoke-Pester you can see this</P>
<BLOCKQUOTE>
<P>&nbsp;&nbsp; -Show<BR>Customizes the output Pester writes to the screen. Available options are None, Default,<BR>Passed, Failed, Pending, Skipped, Inconclusive, Describe, Context, Summary, Header, All, Fails.</P>
<P>The options can be combined to define presets.<BR>Common use cases are:</P>
<P>None – to write no output to the screen.<BR>All – to write all available information (this is default option).<BR>Fails – to write everything except Passed (but including Describes etc.).</P>
<P>A common setting is also Failed, Summary, to write only failed tests and test summary.</P>
<P>This parameter does not affect the PassThru custom object or the XML output that<BR>is written when you use the Output parameters.</P>
<P>Required?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; false<BR>Position?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; named<BR>Default value&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; All<BR>Accept pipeline input?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; false<BR>Accept wildcard characters?&nbsp; false</P></BLOCKQUOTE>
<P>So there are numerous options available to you. Lets see what they look like</P>
<P>I will use a dummy test which creates 10 Context blocks and runs from 1 to 10 and checks if the number has a remainder when divided by 7</P><PRE class="lang:ps decode:true">Describe "Only the 7s Shall Pass" {
    $Servers = 0..10
 &nbsp;&nbsp; foreach($Server in $servers)
 &nbsp;&nbsp; {
 &nbsp;&nbsp;  &nbsp;&nbsp; Context "This is the context for $Server" {
 &nbsp;&nbsp;  &nbsp;&nbsp; foreach($A in 1..10){
 &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;  &nbsp;&nbsp; It "Should Not Pass for the 7s" {
 &nbsp;&nbsp;  &nbsp;&nbsp;  &nbsp;&nbsp;  &nbsp;&nbsp; $A % 7 | Should Not Be 0
 &nbsp;&nbsp;  &nbsp;&nbsp;  &nbsp;&nbsp;  &nbsp;&nbsp; }
&nbsp;&nbsp;&nbsp;  &nbsp;&nbsp;  &nbsp;&nbsp; }
 &nbsp;&nbsp;  &nbsp;&nbsp; }
 &nbsp;&nbsp; }
}
</PRE>
<P>Imagine it is 10 servers running 10 different tests</P>
<P>For the Show parameter All is the default, which is the output that you are used to</P>
<P><IMG class="alignnone size-full wp-image-5620" alt="02 - All.gif" src="https://blog.robsewell.com/assets/uploads/2017/05/02-all.gif?resize=630%2C478&amp;ssl=1" width=630 height=478 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/05/02-all.gif?fit=630%2C478&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/05/02-all.gif?fit=300%2C228&amp;ssl=1" data-image-description="" data-image-title="02 – All" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="843,640" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/05/02-all.gif?fit=843%2C640&amp;ssl=1" data-permalink="https://blog.robsewell.com/pester-test-inception-and-the-show-parameter/02-all/#main" data-attachment-id="5620"></P>
<P>None does not write anything out. You could use this with -Passthru which will pass ALL of the test results to a variable and if you added -OutputFile and -OutputFormat then you can save ALL of the results to a file for consumption by another system. The -Show parameter only affects the output from the Invoke-Pester command to the host not the output to the files or the variable.</P>
<P>Header only returns the header from the test results and looks like this ( I have included the none so that you can see!)</P>
<P><IMG class="alignnone size-full wp-image-5616" alt="03 - none and header.PNG" src="https://blog.robsewell.com/assets/uploads/2017/05/03-none-and-header.png?resize=630%2C98&amp;ssl=1" width=630 height=98 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/05/03-none-and-header.png?fit=630%2C98&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/05/03-none-and-header.png?fit=300%2C47&amp;ssl=1" data-image-description="" data-image-title="03 – none and header" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="824,128" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/05/03-none-and-header.png?fit=824%2C128&amp;ssl=1" data-permalink="https://blog.robsewell.com/pester-test-inception-and-the-show-parameter/03-none-and-header/#main" data-attachment-id="5616"></P>
<P>Summary, as expected returns only the summary of the results</P>
<P><IMG class="alignnone size-full wp-image-5617" alt="04 - summary.PNG" src="https://blog.robsewell.com/assets/uploads/2017/05/04-summary.png?resize=630%2C92&amp;ssl=1" width=630 height=92 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/05/04-summary.png?fit=630%2C92&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/05/04-summary.png?fit=300%2C44&amp;ssl=1" data-image-description="" data-image-title="04 – summary" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="827,121" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/05/04-summary.png?fit=827%2C121&amp;ssl=1" data-permalink="https://blog.robsewell.com/pester-test-inception-and-the-show-parameter/04-summary/#main" data-attachment-id="5617"></P>
<P>You can use more than one value for the Show parameter so if you chose Header, Summary, Describe you would get this</P>
<P><IMG class="alignnone size-full wp-image-5618" alt="05 - headerdesscribe sumnmary.PNG" src="https://blog.robsewell.com/assets/uploads/2017/05/05-headerdesscribe-sumnmary.png?resize=630%2C436&amp;ssl=1" width=630 height=436 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/05/05-headerdesscribe-sumnmary.png?fit=630%2C436&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/05/05-headerdesscribe-sumnmary.png?fit=300%2C208&amp;ssl=1" data-image-description="" data-image-title="05 – headerdesscribe sumnmary" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1046,724" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/05/05-headerdesscribe-sumnmary.png?fit=1046%2C724&amp;ssl=1" data-permalink="https://blog.robsewell.com/pester-test-inception-and-the-show-parameter/05-headerdesscribe-sumnmary/#main" data-attachment-id="5618"></P>
<P>You could use Failed to only show the failed tests which looks like this</P>
<P><IMG class="alignnone size-full wp-image-5619" alt="06 - failed.PNG" src="https://blog.robsewell.com/assets/uploads/2017/05/06-failed.png?resize=630%2C594&amp;ssl=1" width=630 height=594 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/05/06-failed.png?fit=630%2C594&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/05/06-failed.png?fit=300%2C283&amp;ssl=1" data-image-description="" data-image-title="06 – failed" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="848,800" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/05/06-failed.png?fit=848%2C800&amp;ssl=1" data-permalink="https://blog.robsewell.com/pester-test-inception-and-the-show-parameter/06-failed/#main" data-attachment-id="5619"></P>
<P>but Andre explained that he also want to be able to see some progress whilst the test was running. If there were no failures then he would not se anything at all.</P>
<P>So Fails might be the answer (or Failed and Summary but that would not show the progress)</P>
<P><IMG class="alignnone size-full wp-image-5624" alt="07 - fails.PNG" src="https://blog.robsewell.com/assets/uploads/2017/05/07-fails.png?resize=630%2C445&amp;ssl=1" width=630 height=445 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/05/07-fails.png?fit=630%2C445&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/05/07-fails.png?fit=300%2C212&amp;ssl=1" data-image-description="" data-image-title="07 – fails" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="854,603" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/05/07-fails.png?fit=854%2C603&amp;ssl=1" data-permalink="https://blog.robsewell.com/pester-test-inception-and-the-show-parameter/07-fails/#main" data-attachment-id="5624"></P>
<P>Fails shows the Header, Describe, Context&nbsp; and also shows the Summary.</P>
<P>However we carried on talking. PSConfEU is a fantastic place to talk about PowerShell 🙂 and wondered what would happen if you invoked Pester from inside a Pester test. I was pretty sure that it would work as Pester is just PowerShell but I thought it would be fun to have a look and see how we could solve that requirement</P>
<P>So I created 3 “Internal Tests” these are the ones we don’t want to see the output for. I then wrote an overarching Pester test to call them. In that Pester test script I assigned the results of&nbsp;each&nbsp;test to a variable which. When you examine it you see</P>
<P><IMG class="alignnone size-full wp-image-5629" alt="08 - Pester Object.PNG" src="https://blog.robsewell.com/assets/uploads/2017/05/08-pester-object.png?resize=630%2C306&amp;ssl=1" width=630 height=306 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/05/08-pester-object.png?fit=630%2C306&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/05/08-pester-object.png?fit=300%2C146&amp;ssl=1" data-image-description="" data-image-title="08 – Pester Object" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1228,597" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/05/08-pester-object.png?fit=1228%2C597&amp;ssl=1" data-permalink="https://blog.robsewell.com/pester-test-inception-and-the-show-parameter/08-pester-object/#main" data-attachment-id="5629"></P>
<P>The custom object that is created shows the counts of all different results of the tests, the time it took and also the test result.</P>
<P>So I could create a Pester Test to check the Failed Count property of that Test result</P><PRE class="lang:ps decode:true">$InternalTest1.FailedCount | Should Be 0</PRE>
<P>To make sure that we don’t lose the results of the tests we can output&nbsp; them to a file like this</P><PRE class="lang:ps decode:true">$InternalTest1 = Invoke-Pester .\Inside1.Tests.ps1 -Show None -PassThru -OutputFile C:\temp\Internal_Test1_Results.xml -OutputFormat NUnitXml</PRE>
<P>So now we can run Invoke-Pester and point it at that file and it will show the progress and the final result on the screen.</P>
<P><IMG class="alignnone size-full wp-image-5666" alt="09 finale.PNG" src="https://blog.robsewell.com/assets/uploads/2017/05/09-finale.png?resize=630%2C422&amp;ssl=1" width=630 height=422 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/05/09-finale.png?fit=630%2C422&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/05/09-finale.png?fit=300%2C201&amp;ssl=1" data-image-description="" data-image-title="09 finale" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="787,527" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/05/09-finale.png?fit=787%2C527&amp;ssl=1" data-permalink="https://blog.robsewell.com/pester-test-inception-and-the-show-parameter/09-finale/#main" data-attachment-id="5666"></P>
<P>You could make use of this in different ways</P>
<UL>
<LI>Server 1 
<UL>
<LI>Database1 
<LI>Database2 
<LI>Database3 
<LI>Database4 </LI></UL>
<LI>Server 2 
<UL>
<LI>Database1<BR>Database2<BR>Database3<BR>Database4 </LI></UL>
<LI>Server 3 
<UL>
<LI>Database1<BR>Database2<BR>Database3<BR>Database4 </LI></UL></LI></UL>
<P>Or by Test Category</P>
<UL>
<LI>Backup 
<UL>
<LI>Server1 
<LI>Server 2 
<LI>Server 3 
<LI>Server 4 </LI></UL>
<LI>Agent Jobs 
<UL>
<LI>Server 1 
<LI>Server 2 
<LI>Server 3 
<LI>Server 4 </LI></UL>
<LI>Indexes 
<UL>
<LI>Server 1 
<LI>Server 2 
<LI>Server 3 
<LI>Server 4 </LI></UL></LI></UL>
<P>Your only limitation is your imagination.</P>
<P>As we have mentioned PSConfEU you really should check out the videos on the <A href="https://www.youtube.com/channel/UCxgrI58XiKnDDByjhRJs5fg" rel="noopener noreferrer" target=_blank>youtube channel</A> All of the videos that were successfully recorded will be on there. You could start with this one and mark your diaries for April 16-20 2018</P>
<P><SPAN class=embed-youtube style="TEXT-ALIGN: center; DISPLAY: block"><IFRAME class=youtube-player style="BORDER-LEFT-WIDTH: 0px; BORDER-RIGHT-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-TOP-WIDTH: 0px" height=355 src="https://www.youtube.com/embed/G38tN7B46Fg?version=3&amp;rel=1&amp;fs=1&amp;autohide=2&amp;showsearch=0&amp;showinfo=1&amp;iv_load_policy=1&amp;wmode=transparent" width=630 allowfullscreen="true"></IFRAME></SPAN></P>
<P>&nbsp;</P>
<P>&nbsp;</P>

