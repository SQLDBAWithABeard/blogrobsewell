---
title: "PowerShell Function – Validating a Parameter Depending On A Previous Parameter’s Value"
date: "2017-04-26" 
categories:
  - Blog

tags:
  - dbatools
  - error
  - help
  - parameters
  - PowerShell

---
<P>I was chatting on the <A href="https://sqlps.io/slack" rel="noopener noreferrer" target=_blank>SQL Community Slack</A>&nbsp;with my friend Sander Stad <A href="http://www.sqlstad.nl/" rel="noopener noreferrer" target=_blank>b</A> | <A href="https://twitter.com/sqlstad" rel="noopener noreferrer" target=_blank>t</A>&nbsp;about some functions he is writing for the amazing PowerShell SQL Server Community module <A href="https://dbatools.io" rel="noopener noreferrer" target=_blank>dbatools</A>. He was asking my opinion as to how to enable user choice or options for Agent Schedules and I said that he should validate the input of the parameters. He said that was difficult as if the parameter was Weekly the frequency values required would be different from if the parameter was Daily or Monthly. That’s ok, I said, you can still validate the parameter.</P>
<P>You can read more about Parameters either online <A href="https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.core/about/about_parameters" rel="noopener noreferrer" target=_blank>here </A>or <A href="https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.core/about/about_functions_advanced_parameters" rel="noopener noreferrer" target=_blank>here</A> or by running</P><PRE class="lang:ps decode:true">Get-Help&nbsp;About_Parameters
Get-Help About_Functions_Parameters</PRE>
<P>You can also find more help&nbsp;information with</P><PRE class="lang:ps decode:true">Get-Help About_*Parameters*
</PRE>
<P><IMG class="alignnone size-full wp-image-5397" alt="01 more help.PNG" src="https://blog.robsewell.com/assets/uploads/2017/04/01-more-help.png?resize=630%2C119&amp;ssl=1" width=630 height=119 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/04/01-more-help.png?fit=630%2C119&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/04/01-more-help.png?fit=300%2C57&amp;ssl=1" data-image-description="" data-image-title="01 more help" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1157,219" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/04/01-more-help.png?fit=1157%2C219&amp;ssl=1" data-permalink="https://blog.robsewell.com/powershell-function-validating-a-parameter-depending-on-a-previous-parameter/01-more-help/#main" data-attachment-id="5397"></P>
<P>This is not a post about using Parameters, <A href="https://www.google.co.uk/search?q=powershell+about+paramters&amp;ie=&amp;oe=#safe=strict&amp;q=powershell+parameters&amp;spf=370" rel="noopener noreferrer" target=_blank>google for those </A>but this is what I showed him.</P>
<P>Lets create a simple function that accepts 2 parameters Word and Number</P><PRE class="lang:ps decode:true"> function Test-validation
{
    Param
    (
         [string]$Word,
         [int]$Number
    )
Return "$Word and $Number"
} </PRE>
<P>We can run it with any parameters</P>
<P><IMG class="alignnone size-full wp-image-5405" alt="02 any parameters" src="https://blog.robsewell.com/assets/uploads/2017/04/02-any-parameters.png?resize=524%2C40&amp;ssl=1" width=524 height=40 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/04/02-any-parameters.png?fit=524%2C40&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/04/02-any-parameters.png?fit=300%2C23&amp;ssl=1" data-image-description="" data-image-title="02 any parameters" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="524,40" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/04/02-any-parameters.png?fit=524%2C40&amp;ssl=1" data-permalink="https://blog.robsewell.com/powershell-function-validating-a-parameter-depending-on-a-previous-parameter/02-any-parameters/#main" data-attachment-id="5405"></P>
<P>If we wanted to restrict the Word parameter to only accept Sun, Moon or Earth we can use the <A href="https://msdn.microsoft.com/en-us/library/ms714434(v=vs.85).aspx" rel="noopener noreferrer" target=_blank>ValidateSetAttribute</A>&nbsp;as follows</P>
<DIV>
<DIV><PRE class="lang:ps decode:true"> function Test-validation
{
&nbsp;&nbsp;&nbsp; Param
&nbsp;&nbsp;&nbsp; (
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [ValidateSet("sun", "moon", "earth")]
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [string]$Word,
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [int]$Number
&nbsp;&nbsp;&nbsp; )
Return "$Word and $Number"
}</PRE></DIV></DIV>
<DIV></DIV>
<P>Now if we try and set a value for the $Word parameter that isn’t sun moon or earth then we get an error</P>
<P><IMG class="alignnone size-full wp-image-5415" alt="03 parameter error.PNG" src="https://blog.robsewell.com/assets/uploads/2017/04/03-parameter-error.png?resize=630%2C75&amp;ssl=1" width=630 height=75 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/04/03-parameter-error.png?fit=630%2C75&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/04/03-parameter-error.png?fit=300%2C35&amp;ssl=1" data-image-description="" data-image-title="03 parameter error" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1192,141" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/04/03-parameter-error.png?fit=1192%2C141&amp;ssl=1" data-permalink="https://blog.robsewell.com/powershell-function-validating-a-parameter-depending-on-a-previous-parameter/03-parameter-error/#main" data-attachment-id="5415"></P>
<P>and it tells us that the reason for the error is that TheBeard! does not belong to the set sun, moon, earth.</P>
<P>But what Sander wanted was to validate the value of the second parameter depending on the value of the first one. So lets say we wanted</P>
<UL>
<LI>If word is sun, number must be 1 or 2 
<LI>If word is moon, number must be 3 or 4 
<LI>If word is earth, number must be 5 or 6 </LI></UL>
<P>We can use the <A href="https://msdn.microsoft.com/en-us/library/system.management.automation.validatescriptattribute(v=vs.85).aspx" rel="noopener noreferrer" target=_blank>ValidateScriptAttribute</A>&nbsp; to do this. This requires a script block which returns True or False. You can access the current parameter with $_ so we can use a script block like this</P><PRE class="lang:ps decode:true">{
    if($Word -eq 'Sun'){$_ -eq 1 -or $_ -eq 2}
    elseif($Word -eq 'Moon'){$_ -eq 3 -or $_ -eq 4}
    elseif($Word -eq 'earth'){$_ -eq 5 -or $_ -eq 6}
}</PRE>
<P>The function now looks like</P>
<DIV>
<DIV><PRE class="lang:ps decode:true">function Test-validation
{
&nbsp;&nbsp;&nbsp; Param
&nbsp;&nbsp;&nbsp; (
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [ValidateSet("sun", "moon", "earth")]
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [string]$Word,
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [ValidateScript({
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if($Word -eq 'Sun'){$_ -eq 1 -or $_ -eq 2}
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; elseif($Word -eq 'Moon'){$_ -eq 3 -or $_ -eq 4}
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; elseif($Word -eq 'earth'){$_ -eq 5 -or $_ -eq 6}
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; })]
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [int]$Number
&nbsp;&nbsp;&nbsp; )
Return "$Word and $Number"
}</PRE></DIV></DIV>
<DIV></DIV>
<P>It will still fail if we use the wrong “Word” in the same way but now if we enter earth and 7 we get this</P>
<P><IMG class="alignnone size-full wp-image-5437" alt="04 parameter error.PNG" src="https://blog.robsewell.com/assets/uploads/2017/04/04-parameter-error.png?resize=630%2C113&amp;ssl=1" width=630 height=113 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/04/04-parameter-error.png?fit=630%2C113&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/04/04-parameter-error.png?fit=300%2C54&amp;ssl=1" data-image-description="" data-image-title="04 parameter error" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1200,215" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/04/04-parameter-error.png?fit=1200%2C215&amp;ssl=1" data-permalink="https://blog.robsewell.com/powershell-function-validating-a-parameter-depending-on-a-previous-parameter/04-parameter-error/#main" data-attachment-id="5437"></P>
<P>But if we enter sun and 1 or moon and 3 or earth and 5 all is well</P>
<P><IMG class="alignnone size-full wp-image-5443" alt="05 working" src="https://blog.robsewell.com/assets/uploads/2017/04/05-working.png?resize=309%2C137&amp;ssl=1" width=309 height=137 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/04/05-working.png?fit=309%2C137&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/04/05-working.png?fit=300%2C133&amp;ssl=1" data-image-description="" data-image-title="05 working" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="309,137" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/04/05-working.png?fit=309%2C137&amp;ssl=1" data-permalink="https://blog.robsewell.com/powershell-function-validating-a-parameter-depending-on-a-previous-parameter/05-working/#main" data-attachment-id="5443"></P>
<DIV></DIV>
<P>I would add one more thing. We should always write PowerShell functions that are easy for our users to self-help. Of course, this means write good help for the function. here is a great place to start from June Blender</P>
<P><A href="https://github.com/juneb/PowerShellHelpDeepDive/blob/master/HowToWriteGreatHelpExamples.md" rel="noopener noreferrer" target=_blank><IMG class="alignnone size-full wp-image-5447" alt="06 June.PNG" src="https://blog.robsewell.com/assets/uploads/2017/04/06-june.png?resize=630%2C505&amp;ssl=1" width=630 height=505 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/04/06-june.png?fit=630%2C505&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/04/06-june.png?fit=300%2C241&amp;ssl=1" data-image-description="" data-image-title="06 June" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="808,648" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/04/06-june.png?fit=808%2C648&amp;ssl=1" data-permalink="https://blog.robsewell.com/powershell-function-validating-a-parameter-depending-on-a-previous-parameter/06-june/#main" data-attachment-id="5447"></A></P>
<P>In this example, the error message</P>
<BLOCKQUOTE>
<DIV>Test-validation : Cannot validate argument on parameter ‘number’. The ”<BR>if($word -eq ‘Sun’){$_ -eq 1 -or $_ -eq 2}<BR>elseif($word -eq ‘Moon’){$_ -eq 3 -or $_ -eq 4}<BR>elseif($word -eq ‘earth’){$_ -eq 5 -or $_ -eq 6}<BR>” validation script for the argument with value “7” did not return a result of True. Determine why the validation script failed, and then try the<BR>command again.<BR>At line:1 char:39<BR>+ Test-validation -Word “earth” -number 007<BR>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ~~~<BR>+ CategoryInfo&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; : InvalidData: (:) [Test-validation], ParameterBindingValidationException<BR>+ FullyQualifiedErrorId : ParameterArgumentValidationError,Test-validation</DIV></BLOCKQUOTE>
<P>is not obvious to a none-coder so we could make it easier. As we are passing in a script block we can just add a comment like this. I added a spare line above and below to make it stand out a little more</P>
<DIV>
<DIV>
<DIV><PRE class="lang:ps decode:true">function Test-validation
{
&nbsp;&nbsp;&nbsp; Param
&nbsp;&nbsp;&nbsp; (
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [ValidateSet("sun", "moon", "earth")]
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [string]$Word,
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [ValidateScript({
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; #
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; # Sun Accepts 1 or 2
            # Moon Accepts 3 or 4
            # Earth Accepts 5 or 6
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; #
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if($Word -eq 'Sun'){$_ -eq 1 -or $_ -eq 2}
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; elseif($Word -eq 'Moon'){$_ -eq 3 -or $_ -eq 4}
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; elseif($Word -eq 'earth'){$_ -eq 5 -or $_ -eq 6}
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; })]
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [int]$Number
&nbsp;&nbsp;&nbsp; )
Return "$Word and $Number"
}</PRE></DIV></DIV>
<P>Now if you enter the wrong parameter you get this</P></DIV>
<P><IMG class="alignnone size-full wp-image-5457" alt="07 more help.PNG" src="https://blog.robsewell.com/assets/uploads/2017/04/07-more-help.png?resize=630%2C156&amp;ssl=1" width=630 height=156 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/04/07-more-help.png?fit=630%2C156&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/04/07-more-help.png?fit=300%2C75&amp;ssl=1" data-image-description="" data-image-title="07 more help" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1208,300" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/04/07-more-help.png?fit=1208%2C300&amp;ssl=1" data-permalink="https://blog.robsewell.com/powershell-function-validating-a-parameter-depending-on-a-previous-parameter/07-more-help/#main" data-attachment-id="5457"></P>
<DIV></DIV>
<P>which I think makes it a little more obvious</P>
<DIV></DIV>
<DIV></DIV>
<DIV></DIV>
<DIV></DIV>
<P>&nbsp;</P>

