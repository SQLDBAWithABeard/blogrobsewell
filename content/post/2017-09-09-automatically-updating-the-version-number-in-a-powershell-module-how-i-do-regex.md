---
title: "Automatically updating the version number in a PowerShell Module – How I do regex"
categories:
  - Blog

tags:
  - module
  - PowerShell
  - psdayuk

---
<P>I am presenting Continuous Delivery for your PowerShell Module to the PowerShell Gallery at <A href="https://psday.uk" rel=noopener target=_blank>PSDayUK</A> in London. Go and register if you will be close to London on Friday 22nd September.</P>
<P>In 45 minutes we will</P>
<P>– Use Plaster to create our module framework<BR>– Use GitHub for Version Control<BR>– Use Pester to develop our module with TDD<BR>– Use VSTS to Build, Test (with Pester) and Release our changes to the PowerShell Gallery</P>
<P>45 minutes will not give me much time to dive deep into what is done but I will release all of my code on GitHub.</P>
<P>One of the things I needed to accomplish was to update the version number in the module manifest file. I did this with some regex and this is how I achieved it.</P>
<P>I went to <A href="https://regex101.com/" rel=noopener target=_blank>regex101.com</A> and pasted in the contents of a module file into the test string box and start to work out what I need. I need the value after ModuleVersion = ‘ so I started like this</P>
<P><IMG class="alignnone size-full wp-image-7834" alt="01 - regex101.png" src="https://blog.robsewell.com/assets/uploads/2017/09/01-regex101.png?resize=630%2C205&amp;ssl=1" width=630 height=205 sizes="(max-width: 630px) 100vw, 630px" data-recalc-dims="1" srcset="https://blog.robsewell.com/assets/uploads/2017/09/01-regex101.png?w=3144&amp;ssl=1 3144w,https://blog.robsewell.com/assets/uploads/2017/09/01-regex101.png?resize=300%2C98&amp;ssl=1 300w,https://blog.robsewell.com/assets/uploads/2017/09/01-regex101.png?resize=768%2C250&amp;ssl=1 768w,https://blog.robsewell.com/assets/uploads/2017/09/01-regex101.png?resize=1024%2C333&amp;ssl=1 1024w,https://blog.robsewell.com/assets/uploads/2017/09/01-regex101.png?w=1260&amp;ssl=1 1260w,https://blog.robsewell.com/assets/uploads/2017/09/01-regex101.png?w=1890&amp;ssl=1 1890w" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/09/01-regex101.png?fit=630%2C205&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/09/01-regex101.png?fit=300%2C98&amp;ssl=1" data-image-description="" data-image-title="01 – regex101" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="3144,1022" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/09/01-regex101.png?fit=3144%2C1022&amp;ssl=1" data-permalink="https://blog.robsewell.com/01-regex101/" data-attachment-id="7834"></P>
<P>Under the quick reference it has some explanations which will help you. Keep going until you have the correct value in the match information. In the image below you can see that it has a Group 1 in green which matches the value I want (0.9.13). There is also an explanation of how it has got there. This is what I shall use in the PowerShell script</P>
<P><IMG class="alignnone size-full wp-image-7837" alt="01 - regex.png" src="https://blog.robsewell.com/assets/uploads/2017/09/01-regex.png?resize=630%2C200&amp;ssl=1" width=630 height=200 sizes="(max-width: 630px) 100vw, 630px" data-recalc-dims="1" srcset="https://blog.robsewell.com/assets/uploads/2017/09/01-regex.png?w=3155&amp;ssl=1 3155w,https://blog.robsewell.com/assets/uploads/2017/09/01-regex.png?resize=300%2C95&amp;ssl=1 300w,https://blog.robsewell.com/assets/uploads/2017/09/01-regex.png?resize=768%2C244&amp;ssl=1 768w,https://blog.robsewell.com/assets/uploads/2017/09/01-regex.png?resize=1024%2C326&amp;ssl=1 1024w,https://blog.robsewell.com/assets/uploads/2017/09/01-regex.png?w=1260&amp;ssl=1 1260w,https://blog.robsewell.com/assets/uploads/2017/09/01-regex.png?w=1890&amp;ssl=1 1890w" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/09/01-regex.png?fit=630%2C201&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/09/01-regex.png?fit=300%2C95&amp;ssl=1" data-image-description="" data-image-title="01 – regex" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="3155,1003" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/09/01-regex.png?fit=3155%2C1003&amp;ssl=1" data-permalink="https://blog.robsewell.com/01-regex/" data-attachment-id="7837"></P>
<P>Now we can go to PowerShell. First get the contents of the file</P><PRE class="lang:ps decode:true "># get the contents of the module manifest file
try {
    $file = (Get-Content .\BeardAnalysis.psd1)
}
catch {
    Write-Error "Failed to Get-Content"
}</PRE>
<P>Then we use [regex]::matches() to get our value as shown below. I always like to write in the comments what the regex is doing so that I (or others) know what was intended. We also set the value to a type of Version. I reference the group 1 value that I saw in the website.</P><PRE class="wrap:false lang:ps decode:true"># Use RegEx to get the Version Number and set it as a version datatype
# \s* - between 0 and many whitespace
# ModuleVersion - literal
# \s - 1 whitespace
# = - literal
# \s - 1 whitespace
# ' - literal
# () - capture Group
# \d* - between 0 and many digits
# ' - literal
# \s* between 0 and many whitespace

[version]$Version = [regex]::matches($file, "\s*ModuleVersion\s=\s'(\d*.\d*.\d*)'\s*").groups[1].value</PRE>
<P>Next we need to add one to the version number</P><PRE class="wrap:false lang:ps decode:true"># Add one to the build of the version number
[version]$NewVersion = "{0}.{1}.{2}" -f $Version.Major, $Version.Minor, ($Version.Build + 1)
</PRE>
<P>and then replace the value in the file, notice the Get-Content has braces around it</P><PRE class="wrap:false lang:ps decode:true "># Replace Old Version Number with New Version number in the file
try {
    (Get-Content .\BeardAnalysis.psd1) -replace $version, $NewVersion | Out-File .\BeardAnalysis.psd1
    Write-Output "Updated Module Version from $Version to $NewVersion"
}
catch {
$_
    Write-Error "failed to set file"
}
</PRE>
<P>That’s how I do it and the process I use when I need regex!</P>
<P>Here is the full script</P><PRE title="Update Module Manifest File version number" class="wrap:false lang:ps decode:true "># get the contents of the module manifest file
try {
    $file = (Get-Content .\BeardAnalysis.psd1)
}
catch {
    Write-Error "Failed to Get-Content"
}

# Use RegEx to get the Version Number and set it as a version datatype
# \s* - between 0 and many whitespace
# ModuleVersion - literal
# \s - 1 whitespace
# = - literal
# \s - 1 whitespace
# ' - literal
# () - capture Group
# \d* - between 0 and many digits
# ' - literal
# \s* between 0 and many whitespace

[version]$Version = [regex]::matches($file, "\s*ModuleVersion\s=\s'(\d*.\d*.\d*)'\s*").groups[1].value
Write-Output "Old Version - $Version"

# Add one to the build of the version number
[version]$NewVersion = "{0}.{1}.{2}" -f $Version.Major, $Version.Minor, ($Version.Build + 1)
Write-Output "New Version - $NewVersion"

# Replace Old Version Number with New Version number in the file
try {
    (Get-Content .\BeardAnalysis.psd1) -replace $version, $NewVersion | Out-File .\BeardAnalysis.psd1
    Write-Output "Updated Module Version from $Version to $NewVersion"
}
catch {
$_
    Write-Error "failed to set file"
}
</PRE>
<P>&nbsp;</P>
<H2>An easier way</H2>
<P>My fabulous friend and MVP <A class="ProfileHeaderCard-nameLink u-textInheritColor js-nav" href="https://twitter.com/ravikanth">Ravikanth Chaganti</A> has told me of a better way using&nbsp;<A href="https://docs.microsoft.com/en-gb/powershell/module/Microsoft.PowerShell.Utility/Import-PowerShellDataFile?view=powershell-5.1" rel=noopener target=_blank>Import-PowerShellDataFile</A></P>
<P>This command is available on PowerShell v5 and above. There is no need to use regex now 🙂 You can just get the manifest as an object and then use the <A href="https://docs.microsoft.com/en-us/powershell/module/powershellget/update-modulemanifest?view=powershell-5.1" rel=noopener target=_blank>Update-ModuleManifest</A> to update the file</P><PRE class="wrap:false lang:ps decode:true ">$manifest = Import-PowerShellDataFile .\BeardAnalysis.psd1 
[version]$version = $Manifest.ModuleVersion
# Add one to the build of the version number
[version]$NewVersion = "{0}.{1}.{2}" -f $Version.Major, $Version.Minor, ($Version.Build + 1) 
# Update the manifest file
Update-ModuleManifest -Path .\BeardAnalysis.psd1 -ModuleVersion $NewVersion</PRE>
<P>&nbsp;</P>
<P>&nbsp;</P>
<P>&nbsp;</P>
<P>&nbsp;</P>
<P>&nbsp;</P>
<P>&nbsp;</P>
<P>&nbsp;</P>
<P>&nbsp;</P>
<P>&nbsp;</P>

