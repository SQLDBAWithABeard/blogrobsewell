---
title: "VS Code PowerShell Snippets"
categories:
  - Blog

tags:
  - automate
  - Excel
  - PowerShell
  - smo
  - snippet
  - snippets

---
<P>Just a quick post, as much as a reminder for me as anything, but also useful to those that attended my sessions last week where I talked about snippets in PowerShell ISE</P>
<P><A href="http://jdhitsolutions.com/blog/scripting/5488/adding-powershell-snippets-to-visual-studio-code/" target=_blank>Jeff Hicks wrote a post explaining how to create snippets in VS Code for PowerShell</A></P>
<P>I love using snippets so I went and converted my snippets list for ISE (<A href="https://github.com/SQLDBAWithABeard/Functions/blob/master/Snippets%20List.ps1" target=_blank>available on GitHub</A>) into the json required for VS Code (<A href="https://github.com/SQLDBAWithABeard/Functions/blob/master/powershell.json" target=_blank>available on GitHub</A>)</P>
<DIV>Here is an example of snippet</DIV>
<DIV>
<P>[code]"SMO-Server":&nbsp;{<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"prefix":&nbsp;"SMO-Server",<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"body":&nbsp;[<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"$$srv&nbsp;=&nbsp;New-Object&nbsp;Microsoft.SqlServer.Management.Smo.Server&nbsp;$$Server"<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;],<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"description":&nbsp;"Creates&nbsp;a&nbsp;SQL&nbsp;Server&nbsp;SMO&nbsp;Object"<BR>&nbsp;&nbsp;&nbsp;&nbsp;}, </P></DIV>
<P>I followed this process in this order</P>
<P>Click&nbsp;File&nbsp;–&gt;&nbsp;Preferences&nbsp;–&gt;&nbsp;User&nbsp;Snippets&nbsp;and&nbsp;type&nbsp;PowerShell or&nbsp;edit&nbsp;$env:\appdata\code\user\snippets\powershell.json</P>
<P>In&nbsp;order&nbsp;I&nbsp;converted&nbsp;the code in the existing&nbsp;snippets&nbsp;“Text” like&nbsp;this</P>
<DIV>
<DIV>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Replace&nbsp;`$&nbsp;with&nbsp;$$</DIV>
<DIV>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Replace&nbsp;\&nbsp;with&nbsp;\\</DIV>
<DIV>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Replace&nbsp;”&nbsp;with&nbsp;\”</DIV>
<DIV>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\r&nbsp;for&nbsp;new&nbsp;line</DIV>
<DIV>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\t&nbsp;for&nbsp;tab</DIV>
<DIV>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Each&nbsp;line&nbsp;in&nbsp;“”</DIV>
<DIV>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;,&nbsp;at&nbsp;the&nbsp;end&nbsp;of&nbsp;each&nbsp;line&nbsp;in&nbsp;the&nbsp;body&nbsp;&nbsp;&nbsp;except&nbsp;the&nbsp;last&nbsp;one</DIV>
<DIV>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Look&nbsp;out&nbsp;for&nbsp;red&nbsp;or&nbsp;green&nbsp;squiggles&nbsp;🙂</DIV>
<DIV></DIV>
<DIV>I then add</DIV>
<DIV></DIV></DIV>
<DIV>The name of the snippet, first before the : in “”</DIV>
<DIV>The prefix is what you type to get the snippet</DIV>
<DIV>The body is the code following the above Find and Replaces</DIV>
<DIV>The description is the description!!</DIV>
<DIV></DIV>
<DIV>
<DIV>and save and I have snippets in VS Code 🙂</DIV>
<DIV></DIV></DIV>
<DIV><IMG class="alignnone size-full wp-image-3770" alt=snippets.gif src="https://blog.robsewell.com/assets/uploads/2017/03/snippets.gif?resize=630%2C492&amp;ssl=1" width=630 height=492 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/03/snippets.gif?fit=630%2C492&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/03/snippets.gif?fit=300%2C234&amp;ssl=1" data-image-description="" data-image-title="snippets" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1149,898" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/03/snippets.gif?fit=1149%2C898&amp;ssl=1" data-permalink="https://blog.robsewell.com/vs-code-powershell-snippets/snippets/#main" data-attachment-id="3770"></DIV>
<DIV></DIV>
<DIV>That should help you to convert existing ISE snippets into VS Code PowerShell snippets and save you time and keystrokes 🙂</DIV>
<DIV></DIV>

