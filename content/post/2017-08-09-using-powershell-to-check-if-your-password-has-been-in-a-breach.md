---
title: "Using PowerShell to check if your password has been in a breach"
categories:
  - Blog

tags:
  - passwords
  - PowerShell
  - pwned

---
<P>We know that we need to keep our credentials secure. We know that we should not re-use our passwords across different services. Hopefully, by now, most readers of this blog are aware of <A href="https://twitter.com/troyhunt" rel=noopener target=_blank>Troy Hunts</A> excellent free service&nbsp;<A href="https://haveibeenpwned.com/" rel=noopener target=_blank>https://haveibeenpwned.com/</A> which will notify you if your email has been found in a breach. If not, go and sign up now.</P>
<P>Recently <A href="https://www.troyhunt.com/introducing-306-million-freely-downloadable-pwned-passwords/" rel=noopener target=_blank>Troy announced on his blog</A></P>
<BLOCKQUOTE>
<P>This blog post introduces a new service I call “Pwned Passwords”, gives you guidance on how to use it and ultimately, provides you with 306 million passwords you can download for free and use to protect your own systems.</P></BLOCKQUOTE>
<P>So I thought I would write a quick PowerShell script to make use of it and place it on the <A href="https://www.powershellgallery.com/packages/Get-PwnedPassword/1.0/DisplayScript" rel=noopener target=_blank>PowerShell Gallery</A></P>
<P>You can install it using</P><PRE class="toolbar:2 nums:false lang:ps decode:true">Install-Script -Name Get-PwnedPassword</PRE>
<P>You will be asked if you want to add ‘C:\Program Files\WindowsPowerShell\Scripts’ to your PATH environment variable if this is the first script you have installed</P>
<P>Then load it into your session with a period and a space.</P><PRE class="toolbar:2 nums:false lang:ps decode:true ">. Get-PwnedPassword.ps1</PRE>
<P>and check some old passwords. Take notice of the screen shot below in which Troy states that you should not send your password currently in use to any third party sites including this one.</P><PRE class="toolbar:2 nums:false lang:ps decode:true">Get-PwnedPassword</PRE>
<P>There was a game on Twitter which involved finding ‘interesting’ passwords that people have used! Search for it, it’s nsfw by the way!</P>
<P><IMG class="alignnone size-full wp-image-7479" alt=passwords.png src="https://blog.robsewell.com/assets/uploads/2017/08/passwords.png?resize=630%2C172&amp;ssl=1" width=630 height=172 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/08/passwords.png?fit=630%2C172&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/08/passwords.png?fit=300%2C82&amp;ssl=1" data-image-description="" data-image-title="passwords" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1932,527" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/08/passwords.png?fit=1932%2C527&amp;ssl=1" data-permalink="https://blog.robsewell.com/using-powershell-to-check-if-your-password-has-been-in-a-breach/passwords/#main" data-attachment-id="7479"></P>
<P>UPDATE</P>
<P>After posting this <A href="https://twitter.com/Jawz_84" rel=noopener target=_blank>Jos</A> made a comment</P>
<BLOCKQUOTE class=twitter-tweet data-width="550">
<P lang=en dir=ltr>Nice feature! Then maybe add some Read-Host -AsSecureString 🙂 <A href="https://t.co/Ivi3JonPL8">https://t.co/Ivi3JonPL8</A></P>
<P>— Jos Koelewijn (@Jawz_84) <A href="https://twitter.com/Jawz_84/status/895222168539320320">August 9, 2017</A></P></BLOCKQUOTE>
<P>
<SCRIPT charset=utf-8 src="//platform.twitter.com/widgets.js" async></SCRIPT>
</P>
<P>and <A href="https://twitter.com/IISResetMe" rel=noopener target=_blank>Mathias</A> added</P>
<BLOCKQUOTE class=twitter-tweet data-width="550">
<P lang=en dir=ltr>Not so much for in-memory protection, but for shielding against shoulder-surfers 🙂</P>
<P>— Mathias Jessen (@IISResetMe) <A href="https://twitter.com/IISResetMe/status/895224562748710912">August 9, 2017</A></P></BLOCKQUOTE>
<P>
<SCRIPT charset=utf-8 src="//platform.twitter.com/widgets.js" async></SCRIPT>
</P>
<P>Which is a good point. You don’t want you co-workers or friends seeing your Passwords over the shoulder. So I have updated the script to prompt for a Password and convert it to secure string and added a hash parameter as the API also allows you to pass the SHA1 hash of a password.</P>
<P><IMG class="alignnone size-full wp-image-7497" alt=passwords2.png src="https://blog.robsewell.com/assets/uploads/2017/08/passwords2.png?resize=630%2C149&amp;ssl=1" width=630 height=149 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/08/passwords2.png?fit=630%2C149&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/08/passwords2.png?fit=300%2C71&amp;ssl=1" data-image-description="" data-image-title="passwords2" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1921,454" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/08/passwords2.png?fit=1921%2C454&amp;ssl=1" data-permalink="https://blog.robsewell.com/using-powershell-to-check-if-your-password-has-been-in-a-breach/passwords2/#main" data-attachment-id="7497"></P>
<P>Which is a bit better I think. Thank you guys.</P>
<P>UPDATE 2 – This actually broke the script meaning that every password came back as pwned as I was not decoding the securestring correctly. I have fixed this with version 1.2 which you can get if you have already installed the script by running</P><PRE class="toolbar:2 nums:false lang:ps decode:true">Update-Script Get-PwnedPassword</PRE>
<P>Thanks to Henkie and Russell for letting me know</P>
<P>There is also a good use case for us technical folk to assist our none-technical friends with their password usage. You can visit this page</P>
<P><A href="https://haveibeenpwned.com/Passwords" rel=noopener target=_blank>https://haveibeenpwned.com/Passwords</A></P>
<P>and get them to put their old password in the box (look at the screenshot for advice on current passwords) and see if their password has been used in a breach or not and use this as a means to have a discussion about password managers</P>
<P><A href="https://haveibeenpwned.com/Passwords" rel=noopener target=_blank><IMG class="alignnone size-full wp-image-7488" alt=pwnedpasswords.png src="https://blog.robsewell.com/assets/uploads/2017/08/pwnedpasswords.png?resize=630%2C280&amp;ssl=1" width=630 height=280 data-recalc-dims="1" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/08/pwnedpasswords.png?fit=630%2C280&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/08/pwnedpasswords.png?fit=300%2C133&amp;ssl=1" data-image-description="" data-image-title="pwnedpasswords" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1468,653" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/08/pwnedpasswords.png?fit=1468%2C653&amp;ssl=1" data-permalink="https://blog.robsewell.com/using-powershell-to-check-if-your-password-has-been-in-a-breach/pwnedpasswords/#main" data-attachment-id="7488"></A></P>
<P>&nbsp;</P>

