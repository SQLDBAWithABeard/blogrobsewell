---
title: "Using Plaster To Create a New PowerShell Module"
date: "2017-11-09" 
categories:
  - Blog

tags:
  - automation
  - cd
  - ci
  - module
  - plaster

---
<P>Chrissy, CK and I presented a pre-con at PASS Summit in Seattle last week</P>
<P><IMG class="alignnone size-full wp-image-8286" alt=20171031_083328.jpg src="https://blog.robsewell.com/assets/uploads/2017/11/20171031_083328.jpg?resize=630%2C473&amp;ssl=1" width=630 height=473 sizes="(max-width: 630px) 100vw, 630px" data-recalc-dims="1" srcset="https://blog.robsewell.com/assets/uploads/2017/11/20171031_083328.jpg?w=3264&amp;ssl=1 3264w,https://blog.robsewell.com/assets/uploads/2017/11/20171031_083328.jpg?resize=300%2C225&amp;ssl=1 300w,https://blog.robsewell.com/assets/uploads/2017/11/20171031_083328.jpg?resize=768%2C576&amp;ssl=1 768w,https://blog.robsewell.com/assets/uploads/2017/11/20171031_083328.jpg?resize=1024%2C768&amp;ssl=1 1024w,https://blog.robsewell.com/assets/uploads/2017/11/20171031_083328.jpg?w=1260&amp;ssl=1 1260w,https://blog.robsewell.com/assets/uploads/2017/11/20171031_083328.jpg?w=1890&amp;ssl=1 1890w" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/11/20171031_083328.jpg?fit=630%2C473&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/11/20171031_083328.jpg?fit=300%2C225&amp;ssl=1" data-image-description="" data-image-title="20171031_083328" data-image-meta='{"aperture":"1.7","credit":"","camera":"SM-G955F","caption":"","created_timestamp":"1509438807","copyright":"","focal_length":"2.95","iso":"125","shutter_speed":"0.02","title":"","orientation":"1"}' data-comments-opened="1" data-orig-size="3264,2448" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/11/20171031_083328.jpg?fit=3264%2C2448&amp;ssl=1" data-permalink="https://blog.robsewell.com/20171031_083328/" data-attachment-id="8286"></P>
<P>Tracey Boggiano <A href="https://twitter.com/TracyBoggiano" rel="noopener noreferrer" target=_blank>T</A> | <A href="http://databasesuperhero.com/" rel="noopener noreferrer" target=_blank>B</A>&nbsp;came along to our pre-con and afterwards we were talking about creating PowerShell modules. In her <A href="http://tracyboggiano.com/archive/2017/09/dba-powershell-module/" rel="noopener noreferrer" target=_blank>blog post</A>&nbsp;she explains how she creates modules by copying the code from another module (<A href="https://dbatools.io" rel="noopener noreferrer" target=_blank>dbatools</A> in this case!) and altering it to fit her needs. This is an absolutely perfect way to do things, in our pre-con we mentioned that there is no use in re-inventing the wheel, if someone else has already written the code then make use of it.</P>
<P>I suggested however that she used the PowerShell module Plaster to do this. We didnt have enough time to really talk about Plaster, so Tracy, this is for you (and I am looking forward to your blog about using it to 😉 )</P>
<H2>What is Plaster?</H2>
<BLOCKQUOTE>
<P><A href="https://github.com/PowerShell/Plaster" rel="noopener noreferrer" target=_blank>Plaster</A>&nbsp;is a template-based file and project generator written in PowerShell. Its purpose is to streamline the creation of PowerShell module projects, Pester tests, DSC configurations, and more. File generation is performed using crafted templates which allow the user to fill in details and choose from options to get their desired output.</P></BLOCKQUOTE>
<H2>How Do I Get Plaster?</H2>
<P>The best way to get Plaster is also the best way to get any PowerShell module, from the <A href="https://powershellgallery.com" rel="noopener noreferrer" target=_blank>PowerShell Gallery</A></P>
<P>You can just run</P><PRE class="lang:ps decode:true">Install-Module Plaster</PRE>
<P>If you get a prompt about the repository not being trusted, don’t worry you can say yes.</P>
<P>Following&nbsp;<A href="https://blogs.msdn.microsoft.com/powershell/2008/09/30/powershells-security-guiding-principles/">PowerShell’s Security Guiding Principles</A>, Microsoft doesn’t trust its own repository by default. The advice as always is never trust anything from the internet even if a bearded fellow from the UK recommends it!!</P>
<P>The PowerShell Gallery is a centralised repository where anyone can upload code to share and whilst&nbsp;<A href="https://blogs.msdn.microsoft.com/powershell/2015/08/06/powershell-gallery-new-security-scan/">all uploads are analyzed</A>&nbsp;for viruses and malicious code by Microsoft, user discretion is always advised. If you do not want to be prompted every time that you install a module then you can run</P><PRE class="lang:ps decode:true">Set-PSRepository -Name PSGallery -InstallationPolicy Trusted</PRE>
<P>if you and/or your organisation think that that is the correct way forward.</P>
<H2>What Can We Do With Plaster?</H2>
<P>Now that we have installed the module we can get to the nitty gritty. You can (and should) use Plaster to automate the creation of your module structure. If you are going to something more than once then automate it!</P>
<P>I created a <A href="https://github.com/SQLDBAWithABeard/PlasterTemplate" rel="noopener noreferrer" target=_blank>repository for my Plaster Template</A>&nbsp;You are welcome to take it and modify it for your own needs. I created a folder structure and some default files that I always want to have in my module folder</P>
<P><IMG class="alignnone size-full wp-image-8335" alt="module framework.png" src="https://blog.robsewell.com/assets/uploads/2017/11/module-framework.png?resize=630%2C349&amp;ssl=1" width=630 height=349 sizes="(max-width: 630px) 100vw, 630px" data-recalc-dims="1" srcset="https://blog.robsewell.com/assets/uploads/2017/11/module-framework.png?w=1807&amp;ssl=1 1807w,https://blog.robsewell.com/assets/uploads/2017/11/module-framework.png?resize=300%2C166&amp;ssl=1 300w,https://blog.robsewell.com/assets/uploads/2017/11/module-framework.png?resize=768%2C425&amp;ssl=1 768w,https://blog.robsewell.com/assets/uploads/2017/11/module-framework.png?resize=1024%2C567&amp;ssl=1 1024w,https://blog.robsewell.com/assets/uploads/2017/11/module-framework.png?w=1260&amp;ssl=1 1260w" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/11/module-framework.png?fit=630%2C349&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/11/module-framework.png?fit=300%2C166&amp;ssl=1" data-image-description="" data-image-title="module framework" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1807,1001" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/11/module-framework.png?fit=1807%2C1001&amp;ssl=1" data-permalink="https://blog.robsewell.com/module-framework/" data-attachment-id="8335"></P>
<P>So in my template I have created all of the folders to organise the files in the way that I want to for my modules. I have also included the license file and some markdown documents for readme, contributing and installation. If we look in the tests folder</P>
<P><IMG class="alignnone size-full wp-image-8339" alt="tests folder.png" src="https://blog.robsewell.com/assets/uploads/2017/11/tests-folder.png?resize=630%2C175&amp;ssl=1" width=630 height=175 sizes="(max-width: 630px) 100vw, 630px" data-recalc-dims="1" srcset="https://blog.robsewell.com/assets/uploads/2017/11/tests-folder.png?w=1808&amp;ssl=1 1808w,https://blog.robsewell.com/assets/uploads/2017/11/tests-folder.png?resize=300%2C83&amp;ssl=1 300w,https://blog.robsewell.com/assets/uploads/2017/11/tests-folder.png?resize=768%2C214&amp;ssl=1 768w,https://blog.robsewell.com/assets/uploads/2017/11/tests-folder.png?resize=1024%2C285&amp;ssl=1 1024w,https://blog.robsewell.com/assets/uploads/2017/11/tests-folder.png?w=1260&amp;ssl=1 1260w" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/11/tests-folder.png?fit=630%2C175&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/11/tests-folder.png?fit=300%2C83&amp;ssl=1" data-image-description="" data-image-title="tests folder" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1808,503" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/11/tests-folder.png?fit=1808%2C503&amp;ssl=1" data-permalink="https://blog.robsewell.com/tests-folder/" data-attachment-id="8339"></P>
<P>There are some default test files included as well.</P>
<P>But Plaster is more than just a file and folder template repository, if we look in the installation markdown file,&nbsp; it looks like this</P>
<DIV><PRE class="lang:batch decode:true"># Installing &lt;%= $PLASTER_PARAM_ModuleName %&gt;
# You can install &lt;%= $PLASTER_PARAM_ModuleName %&gt; from the Powershell Gallery using
Find-Module &lt;%= $PLASTER_PARAM_ModuleName %&gt; | Install-Module
Import-Module &lt;%= $PLASTER_PARAM_ModuleName %&gt;</PRE></DIV>
<DIV>We can paramatarise the content of our files. This will create a very simple markdown showing how to find and install the module from the PowerShell Gallery which saves us from having to type the same thing again and again. Lets see how to do that</DIV>
<H2>The Manifest XML file</H2>
<P>The magic happens in the <A href="https://github.com/SQLDBAWithABeard/PlasterTemplate/blob/master/PlasterManifest.xml" rel="noopener noreferrer" target=_blank>manifest file</A> You can create one with the New-PlasterManifest command in the template directory – Thank you to Mustafa for notifying that the manifest file creation now requires an extra parameter of TemplateType</P>
<DIV><PRE class="lang:ps decode:true">$manifestProperties = @{
Path = "PlasterManifest.xml"
Title = "Full Module Template"
TemplateName = 'FullModuleTemplate'
TemplateVersion = '0.0.1'
TemplateType = 'Item'
Author = 'Rob Sewell'
}
New-Item -Path FullModuleTemplate -ItemType Directory
New-PlasterManifest @manifestProperties</PRE></DIV>
<DIV>This will create a PlasterManifest.xml file that looks like this</DIV>
<DIV><PRE class="lang:yaml decode:true">&lt;?xml version="1.0" encoding="utf-8"?&gt;
&lt;plasterManifest
schemaVersion="1.1"
templateType="Project" xmlns="http://www.microsoft.com/schemas/PowerShell/Plaster/v1"&gt;
&lt;metadata&gt;
&lt;name&gt;FullModuleTemplate&lt;/name&gt;
&lt;id&gt;220fba73-bf86-49e3-9ec5-c4bc2719d196&lt;/id&gt;
&lt;version&gt;0.0.1&lt;/version&gt;
&lt;title&gt;FullModuleTemplate&lt;/title&gt;
&lt;description&gt;My PLaster Template for PowerShell Modules&lt;/description&gt;
&lt;author&gt;Rob Sewell&lt;/author&gt;
&lt;tags&gt;&lt;/tags&gt;
&lt;/metadata&gt;
&lt;parameters&gt;&lt;/parameters&gt;
&lt;content&gt;&lt;/content&gt;
&lt;/plasterManifest&gt;</PRE></DIV>
<DIV>You can see that the parameters and content tags are empty. This is where we will define the parameters which will replace the tokens in our files and the details for how to create our module folder.</DIV>
<H2>Plaster Parameters</H2>
<DIV>At present my parameters tag looks like this</DIV>
<DIV><PRE class="lang:batch decode:true">&lt;parameters&gt;
&lt;parameter name="FullName" type="text" prompt="Module author's name" /&gt;
&lt;parameter name="ModuleName" type="text" prompt="Name of your module" /&gt;
&lt;parameter name="ModuleDesc" type="text" prompt="Brief description on this module" /&gt;
&lt;parameter name="Version" type="text" prompt="Initial module version" default="0.0.1" /&gt;
&lt;parameter name="GitHubUserName" type="text" prompt="GitHub username" default="${PLASTER_PARAM_FullName}"/&gt;
&lt;parameter name="GitHubRepo" type="text" prompt="Github repo name for this module" default="${PLASTER_PARAM_ModuleName}"/&gt;
&lt;/parameters&gt;</PRE></DIV>
<DIV>So we can set up various parameters with their names and data types defined and a prompt and if we want a default value.</DIV>
<DIV></DIV>
<DIV>We can then use</DIV>
<DIV><PRE class="lang:batch decode:true">&lt;%= $PLASTER_PARAM_WHATEVERTHEPAREMETERNAMEIS %&gt;</PRE></DIV>
<DIV>in our files to make use of the parameters.</DIV>
<H2>Plaster Content</H2>
<P>The other part of the manifest file to create is the content. This tells Plaster what to do when it runs.</P>
<P>Mine is split into 3 parts</P>
<DIV><PRE class="lang:batch decode:true">&lt;message&gt;
Creating folder structure
&lt;/message&gt;
&lt;file source='' destination='docs'/&gt;
&lt;file source='' destination='functions'/&gt;
&lt;file source='' destination='internal'/&gt;
&lt;file source='' destination='tests'/&gt;</PRE></DIV>
<DIV>We can provide messages to the user with the message tag. I create the folders using the filesource tag</DIV>
<DIV>
<DIV><PRE class="lang:batch decode:true">&lt;message&gt;
Deploying common files
&lt;/message&gt;
&lt;file source='appveyor.yml' destination=''/&gt;
&lt;file source='contributing.md' destination=''/&gt;
&lt;file source='LICENSE.txt' destination=''/&gt;
&lt;templateFile source='install.md' destination=''/&gt;
&lt;templateFile source='readme.md' destination=''/&gt;
&lt;templateFile source='tests\Project.Tests.ps1' destination=''/&gt;
&lt;templateFile source='tests\Help.Tests.ps1' destination=''/&gt;
&lt;templateFile source='tests\Feature.Tests.ps1' destination=''/&gt;
&lt;templateFile source='tests\Regression.Tests.ps1' destination=''/&gt;
&lt;templateFile source='tests\Unit.Tests.ps1' destination=''/&gt;
&lt;templateFile source='tests\Help.Exceptions.ps1' destination=''/&gt;
&lt;templateFile source='docs\ReleaseNotes.txt' destination=''/&gt;
&lt;file source='module.psm1' destination='${PLASTER_PARAM_ModuleName}.psm1'/&gt;</PRE></DIV>
<DIV>This part creates all of the required files. You can see that the static files (those which do not require any sort of parameterisation for the contents use the same <EM>file source</EM> tag as the folders with the source defined. The files that have content which is parameterised use a tag of <EM>templateFile Source </EM>telling Plaster to look inside there for the tokens to be replaced.</DIV></DIV>
<DIV></DIV>
<DIV>The last part of the content creates the module manifest.</DIV>
<DIV><PRE class="lang:batch decode:true">&lt;message&gt;
Creating Module Manifest
&lt;/message&gt;
&lt;newModuleManifest
destination='${PLASTER_PARAM_ModuleName}.psd1'
moduleVersion='$PLASTER_PARAM_Version'
rootModule='${PLASTER_PARAM_ModuleName}.psm1'
author='$PLASTER_PARAM_FullName'
description='$PLASTER_PARAM_ModuleDesc'
encoding='UTF8-NoBOM'/&gt;</PRE></DIV>
<DIV>which I have filled in with the parameters for each of the values.</DIV>
<H2>Creating a new module at the command line</H2>
<P>Now you can easily create a module with all of the required folders and files that you want by creating a directory and running</P><PRE class="lang:ps decode:true">Invoke-Plaster -TemplatePath TEMPLATEDIRECTORY -DestinationPath DESTINATIONDIRECTORY</PRE>
<P>which looks like this</P>
<DIV id=v-POKfevRI-1 class=video-player><IFRAME height=310 src="https://videopress.com/embed/POKfevRI?hd=1&amp;loop=0&amp;autoPlay=0&amp;permalink=1" frameBorder=0 width=630 allowfullscreen></IFRAME>
<SCRIPT src="https://s0.wp.com/wp-content/plugins/video/assets/js/next/videopress-iframe.js"></SCRIPT>
</DIV>
<P>Its that easy 🙂</P>
<H2>Create a module without prompts</H2>
<DIV>You can also create a module without needing to answer prompts. We can prefill them in our parameter splat</DIV>
<DIV><PRE class="lang:ps decode:true ">$plaster = @{
TemplatePath ="GIT:\PlasterTemplate"
DestinationPath = "GIT:\NewModule"
FullName = "Rob Sewell"
ModuleName = "NewModule"
ModuleDesc = "Here is a module description"
Version = "0.9.0"
GitHubUserName = "SQLDBAWithABeard"
GitHubRepo = "NewModule"
}
If (!(Test-Path $plaster.DestinationPath)) {
New-Item-ItemType Directory -Path $plaster.DestinationPath
}
Invoke-Plaster @plaster</PRE></DIV>
<DIV>Which will look like this</DIV>
<DIV></DIV>
<DIV>
<DIV id=v-FsgbWrMM-1 class=video-player><IFRAME height=334 src="https://videopress.com/embed/FsgbWrMM?hd=1&amp;loop=0&amp;autoPlay=0&amp;permalink=1" frameBorder=0 width=630 allowfullscreen></IFRAME>
<SCRIPT src="https://s0.wp.com/wp-content/plugins/video/assets/js/next/videopress-iframe.js"></SCRIPT>
</DIV></DIV>
<H2>Make Your Own</H2>
<DIV>Hopefully this have given you enough information and shown you how easy it is to automate creating the framework for your new PowerShell modules and parameterising them. Let me know how you get on and share your examples</DIV>
<DIV></DIV>
<H2>Further Reading</H2>
<P><A href="https://kevinmarquette.github.io/2017-05-12-Powershell-Plaster-adventures-in/" rel="noopener noreferrer" target=_blank>Kevin Marquettes blog post</A>&nbsp;is an excellent and detailed post on using Plaster which you should also read for reference as well as <A href="http://overpoweredshell.com/Working-with-Plaster/" rel="noopener noreferrer" target=_blank>David Christians post</A>&nbsp;which has some great content on adding user choice to the parameters enabling one plaster template to fulfill multiple requirements.</P>

