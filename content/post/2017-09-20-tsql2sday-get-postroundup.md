---
title: "#TSQL2sDay – Get-PostRoundup"
slug: "TSQL2sDay – Get-PostRoundup"
date: "2017-09-20"
categories:
  - Blog

tags:
  - TSql2sDay
  - automate
  - automation
  - backup
  - backups
  - databases
  - dbareports
  - dbatools
  - documentation
  - Excel
  - GitHub
  - permissions
  - pester
  - PowerShell
  - restore
  - roles
  - script
  - smo
  - sql
  - sqlserver

---
<P>First an apology, this round up is late!</P>
<P>The reason for that is an error in the PowerShell testing module Pester (That’s not completely true as you shall see!!)</P>
<P>I spoke in Stuttgart at the PowerShell Saturday last weekend and had intended to write this blog post whilst travelling, unfortunately I found a major error in Pester (again not strictly true but it makes a good story!!)</P>
<P>I explained it with this slide in my presentation</P>
<P><IFRAME height=367 src="https://onedrive.live.com/embed?cid=C802DF42025D5E1F&amp;resid=C802DF42025D5E1F%21589314&amp;authkey=AACWwXARKGuShag&amp;em=2&amp;wdAr=1.7777777777777776" frameBorder=0 width=610>This is an embedded <a target="_blank" href="https://office.com">Microsoft Office</a> presentation, powered by <a target="_blank" href="https://office.com/webapps">Office Online</a>.</IFRAME></P>
<P>Yep, I forgot to pack my NUC with my VMs on it and had to re-write all my demos!!</P>
<P>But anyway, on to the TSQL2sDay posts</P>
<BLOCKQUOTE class=twitter-tweet data-width="550">
<P lang=en dir=ltr>Ah <A href="https://twitter.com/hashtag/tsql2sday?src=hash">#tsql2sday</A> – It seems you have gone a little bit posh! <A href="https://t.co/bPqu4p1w7D">pic.twitter.com/bPqu4p1w7D</A></P>
<P>— Rob Sewell (@sqldbawithbeard) <A href="https://twitter.com/sqldbawithbeard/status/907596923095470080">September 12, 2017</A></P></BLOCKQUOTE>
<P>
<SCRIPT charset=utf-8 src="//platform.twitter.com/widgets.js" async></SCRIPT>
</P>
<P>What a response. You wonderful people. I salute you with a Rimmer salute</P>
<P><IFRAME class=giphy-embed height=360 src="https://giphy.com/embed/XnIbGoLjzK9A4" frameBorder=0 width=480 allowfullscreen="allowfullscreen"></IFRAME></P>
<P>There are 34 TSQL2sDay posts about dbatools, about starting with PowerShell, If you should learn PowerShell, SSAS, SSRS, Log Shipping, backups, restores, Pester, Default settings, best practices, migrations, Warnings in Agent Jobs, sqlpackage, VLFs, CMS, Disabling Named Pipes, Orphaned users, AG Status, AG Agent Jobs, logging, classes, auditing, copying files, ETL and more.</P>
<P>I am really pleased to see so many first timers to the TSQL2sDay blog monthly blog party. Please don’t let this be your only TSQL2sDay post. Come back next month and write a post on that topic.</P>
<P>Here they are below in the media of tweets, so that you can also go and follow these wonderful people who are so willing to share their knowledge. Say thank you to them, ask them questions, interact.</P>
<P>Learn, Share, Network</P>
<BLOCKQUOTE class=twitter-tweet data-width="550">
<P lang=en dir=ltr>An utterly awesome intro post to PowerShell by the fantastic <A href="https://twitter.com/rob_farley">@rob_farley</A> <BR>Thank you Sir. <BR>bookmark this &amp; send it to your friends<A href="https://twitter.com/hashtag/Tsql2sday?src=hash">#Tsql2sday</A> <A href="https://t.co/fwUnxZCauY">https://t.co/fwUnxZCauY</A></P>
<P>— Rob Sewell (@sqldbawithbeard) <A href="https://twitter.com/sqldbawithbeard/status/907505315243085825">September 12, 2017</A></P></BLOCKQUOTE>
<P>
<SCRIPT charset=utf-8 src="//platform.twitter.com/widgets.js" async></SCRIPT>
</P>
<BLOCKQUOTE class=twitter-tweet data-width="550">
<P lang=en dir=ltr>It's <A href="https://twitter.com/cl">@cl</A> the awesome <A href="https://twitter.com/psdbatools">@psdbatools</A> founder showing how the community module performs a migration and tests it WITH EVERY COMMIT!! <A href="https://twitter.com/hashtag/tsql2sday?src=hash">#tsql2sday</A> <A href="https://t.co/PUI4XijyoE">https://t.co/PUI4XijyoE</A></P>
<P>— Rob Sewell (@sqldbawithbeard) <A href="https://twitter.com/sqldbawithbeard/status/907624558001360896">September 12, 2017</A></P></BLOCKQUOTE>
<P>
<SCRIPT charset=utf-8 src="//platform.twitter.com/widgets.js" async></SCRIPT>
</P>
<BLOCKQUOTE class=twitter-tweet data-width="550">
<P lang=en dir=ltr>Take a look at how Shane imports Death,The Police, The Witches and A monkey … err ape into SQL Server <A href="https://twitter.com/hashtag/tsql2sday?src=hash">#tsql2sday</A> <A href="https://t.co/ZnwDLv2mwW">https://t.co/ZnwDLv2mwW</A></P>
<P>— Rob Sewell (@sqldbawithbeard) <A href="https://twitter.com/sqldbawithbeard/status/907579469296279552">September 12, 2017</A></P></BLOCKQUOTE>
<P>
<SCRIPT charset=utf-8 src="//platform.twitter.com/widgets.js" async></SCRIPT>
</P>
<BLOCKQUOTE class=twitter-tweet data-width="550">
<P lang=en dir=ltr>🙂 another 1st time <A href="https://twitter.com/hashtag/tsql2sday?src=hash">#tsql2sday</A> blogger – Craig posts about using the SSRS module <A href="https://t.co/Sf8EJEnr7M">https://t.co/Sf8EJEnr7M</A></P>
<P>— Rob Sewell (@sqldbawithbeard) <A href="https://twitter.com/sqldbawithbeard/status/907593076692209664">September 12, 2017</A></P></BLOCKQUOTE>
<P>
<SCRIPT charset=utf-8 src="//platform.twitter.com/widgets.js" async></SCRIPT>
</P>
<BLOCKQUOTE class=twitter-tweet data-width="550">
<P lang=en dir=ltr>Storm the castle! (you'll have to read the post)<A href="https://twitter.com/SQLSoldier">@SQLSoldier</A> via <A href="https://twitter.com/SQLBestPractice">@SQLBestPractice</A> shows how to ease the pain of AG Agent Jobs <A href="https://twitter.com/hashtag/tsql2sday?src=hash">#tsql2sday</A> <A href="https://t.co/zciKnk6OH4">https://t.co/zciKnk6OH4</A></P>
<P>— Rob Sewell (@sqldbawithbeard) <A href="https://twitter.com/sqldbawithbeard/status/907626370490097666">September 12, 2017</A></P></BLOCKQUOTE>
<P>
<SCRIPT charset=utf-8 src="//platform.twitter.com/widgets.js" async></SCRIPT>
</P>
<BLOCKQUOTE class=twitter-tweet data-width="550">
<P lang=en dir=ltr><A href="https://twitter.com/hashtag/Tsql2sday?src=hash">#Tsql2sday</A> – Deleting SSAS Cube Partitions Using PowerShell and AMO – bzzzt! <A href="https://t.co/xfKbXYWBi7">https://t.co/xfKbXYWBi7</A> via <A href="https://twitter.com/bzzzt_io">@bzzzt_io</A></P>
<P>— Rob Sewell (@sqldbawithbeard) <A href="https://twitter.com/sqldbawithbeard/status/907507644029718528">September 12, 2017</A></P></BLOCKQUOTE>
<P>
<SCRIPT charset=utf-8 src="//platform.twitter.com/widgets.js" async></SCRIPT>
</P>
<BLOCKQUOTE class=twitter-tweet data-width="550">
<P lang=en dir=ltr>Do I Need to Master PowerShell? via <A href="https://twitter.com/Kendra_Little">@Kendra_Little</A> for <A href="https://twitter.com/hashtag/tsql2sday?src=hash">#tsql2sday</A> <A href="https://t.co/BGjuV7IUnj">https://t.co/BGjuV7IUnj</A></P>
<P>— Rob Sewell (@sqldbawithbeard) <A href="https://twitter.com/sqldbawithbeard/status/908789530710482945">September 15, 2017</A></P></BLOCKQUOTE>
<P>
<SCRIPT charset=utf-8 src="//platform.twitter.com/widgets.js" async></SCRIPT>
</P>
<BLOCKQUOTE class=twitter-tweet data-width="550">
<P lang=en dir=ltr><A href="https://twitter.com/hashtag/tsql2sday?src=hash">#tsql2sday</A> Warning Handling in dbatools Automation Tasks <A href="https://t.co/6h7gRSIUlC">https://t.co/6h7gRSIUlC</A> via <A href="https://twitter.com/nocentino">@nocentino</A></P>
<P>— Rob Sewell (@sqldbawithbeard) <A href="https://twitter.com/sqldbawithbeard/status/907508493225283584">September 12, 2017</A></P></BLOCKQUOTE>
<P>
<SCRIPT charset=utf-8 src="//platform.twitter.com/widgets.js" async></SCRIPT>
</P>
<BLOCKQUOTE class=twitter-tweet data-width="550">
<P lang=en dir=ltr>Automate Migrations–T-SQL Tuesday&nbsp;#94 <A href="https://t.co/1GZm2AluHe">https://t.co/1GZm2AluHe</A></P>
<P>— way0utwest (@way0utwest) <A href="https://twitter.com/way0utwest/status/907576613939896321">September 12, 2017</A></P></BLOCKQUOTE>
<P>
<SCRIPT charset=utf-8 src="//platform.twitter.com/widgets.js" async></SCRIPT>
</P>
<BLOCKQUOTE class=twitter-tweet data-width="550">
<P lang=en dir=ltr><A href="https://twitter.com/hashtag/TSQL2sDay?src=hash">#TSQL2sDay</A> – Starting Out with&nbsp;PowerShell <A href="https://t.co/cOhfMC129O">https://t.co/cOhfMC129O</A> <A href="https://t.co/74fw40lmm6">pic.twitter.com/74fw40lmm6</A></P>
<P>— Rob Sewell (@sqldbawithbeard) <A href="https://twitter.com/sqldbawithbeard/status/907510988966166528">September 12, 2017</A></P></BLOCKQUOTE>
<P>
<SCRIPT charset=utf-8 src="//platform.twitter.com/widgets.js" async></SCRIPT>
</P>
<BLOCKQUOTE class=twitter-tweet data-width="550">
<P lang=en dir=ltr>Another <A href="https://twitter.com/hashtag/tsql2sday?src=hash">#tsql2sday</A> 1sttimer <A href="https://twitter.com/danblank000">@danblank000</A> shows how he solved an infuriating problem with PowerShell <A href="https://t.co/DUEU2PRZpp">https://t.co/DUEU2PRZpp</A></P>
<P>— Rob Sewell (@sqldbawithbeard) <A href="https://twitter.com/sqldbawithbeard/status/907521780914561024">September 12, 2017</A></P></BLOCKQUOTE>
<P>
<SCRIPT charset=utf-8 src="//platform.twitter.com/widgets.js" async></SCRIPT>
</P>
<BLOCKQUOTE class=twitter-tweet data-width="550">
<P lang=en dir=ltr>Kenneth shows how to turn on and off Azure VMs with PowerShell <A href="https://t.co/gzqHafoRJo">https://t.co/gzqHafoRJo</A></P>
<P>— Rob Sewell (@sqldbawithbeard) <A href="https://twitter.com/sqldbawithbeard/status/908669511494197254">September 15, 2017</A></P></BLOCKQUOTE>
<P>
<SCRIPT charset=utf-8 src="//platform.twitter.com/widgets.js" async></SCRIPT>
</P>
<BLOCKQUOTE class=twitter-tweet data-width="550">
<P lang=en dir=ltr>Setting up Logshipping ias a whole lot easier now 🙂 <A href="https://twitter.com/hashtag/tsql2sday?src=hash">#tsql2sday</A> <A href="https://t.co/gc2ISCWTVK">https://t.co/gc2ISCWTVK</A></P>
<P>— Rob Sewell (@sqldbawithbeard) <A href="https://twitter.com/sqldbawithbeard/status/907547322896265217">September 12, 2017</A></P></BLOCKQUOTE>
<P>
<SCRIPT charset=utf-8 src="//platform.twitter.com/widgets.js" async></SCRIPT>
</P>
<BLOCKQUOTE class=twitter-tweet data-width="550">
<P lang=en dir=ltr>Martin writes about a script he wrote for backup testing for <A href="https://twitter.com/hashtag/tsql2sday?src=hash">#tsql2sday</A> – The comparison vs assignment is a very good point for beginners <A href="https://t.co/5JOxEaD3wF">https://t.co/5JOxEaD3wF</A></P>
<P>— Rob Sewell (@sqldbawithbeard) <A href="https://twitter.com/sqldbawithbeard/status/907548660443082752">September 12, 2017</A></P></BLOCKQUOTE>
<P>
<SCRIPT charset=utf-8 src="//platform.twitter.com/widgets.js" async></SCRIPT>
</P>
<BLOCKQUOTE class=twitter-tweet data-width="550">
<P lang=en dir=ltr>Yet another <A href="https://twitter.com/hashtag/tsql2sday?src=hash">#tsql2sday</A> 1sttimer – Claudio writes about best practices adn how to test them with dbatools and Pester <A href="https://t.co/kpL5zHnng7">https://t.co/kpL5zHnng7</A></P>
<P>— Rob Sewell (@sqldbawithbeard) <A href="https://twitter.com/sqldbawithbeard/status/907549042477027328">September 12, 2017</A></P></BLOCKQUOTE>
<P>
<SCRIPT charset=utf-8 src="//platform.twitter.com/widgets.js" async></SCRIPT>
</P>
<BLOCKQUOTE class=twitter-tweet data-width="550">
<P lang=en dir=ltr>Daniel (another <A href="https://twitter.com/hashtag/tsql2sday?src=hash">#tsql2sday</A> 1sttimer) – blogs about installing dbatools in Visual Studio to exclude tables from Scaffold-DbContext <A href="https://t.co/5c69uy2TWN">https://t.co/5c69uy2TWN</A></P>
<P>— Rob Sewell (@sqldbawithbeard) <A href="https://twitter.com/sqldbawithbeard/status/907551696083148801">September 12, 2017</A></P></BLOCKQUOTE>
<P>
<SCRIPT charset=utf-8 src="//platform.twitter.com/widgets.js" async></SCRIPT>
</P>
<BLOCKQUOTE class=twitter-tweet data-width="550">
<P lang=en dir=ltr>Chris shares some of the many things he has done with PowerShell <A href="https://twitter.com/hashtag/tsql2sday?src=hash">#tsql2sday</A> <A href="https://t.co/VpS5BBEzeL">https://t.co/VpS5BBEzeL</A></P>
<P>— Rob Sewell (@sqldbawithbeard) <A href="https://twitter.com/sqldbawithbeard/status/907577991559041027">September 12, 2017</A></P></BLOCKQUOTE>
<P>
<SCRIPT charset=utf-8 src="//platform.twitter.com/widgets.js" async></SCRIPT>
</P>
<BLOCKQUOTE class=twitter-tweet data-width="550">
<P lang=en dir=ltr>Garry shows how to find commands in dbatools <BR>AND<BR>How to get all the VLF information for an estate into a csv <A href="https://twitter.com/hashtag/tsql2sday?src=hash">#tsql2sday</A> <A href="https://t.co/6fdH9bQ9dI">https://t.co/6fdH9bQ9dI</A></P>
<P>— Rob Sewell (@sqldbawithbeard) <A href="https://twitter.com/sqldbawithbeard/status/907580675167047686">September 12, 2017</A></P></BLOCKQUOTE>
<P>
<SCRIPT charset=utf-8 src="//platform.twitter.com/widgets.js" async></SCRIPT>
</P>
<BLOCKQUOTE class=twitter-tweet data-width="550">
<P lang=en dir=ltr>Mark shows how to use CMS with PowerShell <A href="https://twitter.com/hashtag/tsql2sday?src=hash">#tsql2sday</A> <A href="https://t.co/LYQWoE2flV">https://t.co/LYQWoE2flV</A></P>
<P>— Rob Sewell (@sqldbawithbeard) <A href="https://twitter.com/sqldbawithbeard/status/907581223358418944">September 12, 2017</A></P></BLOCKQUOTE>
<P>
<SCRIPT charset=utf-8 src="//platform.twitter.com/widgets.js" async></SCRIPT>
</P>
<BLOCKQUOTE class=twitter-tweet data-width="550">
<P lang=en dir=ltr>Raul shares his scripts to automate the creation of VMs <A href="https://twitter.com/hashtag/tsql2sday?src=hash">#tsql2sday</A> <A href="https://t.co/duvH4SNPO0">https://t.co/duvH4SNPO0</A></P>
<P>— Rob Sewell (@sqldbawithbeard) <A href="https://twitter.com/sqldbawithbeard/status/907590786417614853">September 12, 2017</A></P></BLOCKQUOTE>
<P>
<SCRIPT charset=utf-8 src="//platform.twitter.com/widgets.js" async></SCRIPT>
</P>
<BLOCKQUOTE class=twitter-tweet data-width="550">
<P lang=en dir=ltr>CK shares one of my favorite dbatools commands Test-DbaLastBackup <A href="https://twitter.com/hashtag/tsql2sday?src=hash">#tsql2sday</A> <A href="https://t.co/ohP1sQzR5D">https://t.co/ohP1sQzR5D</A></P>
<P>— Rob Sewell (@sqldbawithbeard) <A href="https://twitter.com/sqldbawithbeard/status/907591033118248960">September 12, 2017</A></P></BLOCKQUOTE>
<P>
<SCRIPT charset=utf-8 src="//platform.twitter.com/widgets.js" async></SCRIPT>
</P>
<BLOCKQUOTE class=twitter-tweet data-width="550">
<P lang=en dir=ltr>Deborah shows how she creates dynamic parameters in PowerShell <A href="https://twitter.com/hashtag/tsql2sday?src=hash">#tsql2sday</A> <A href="https://t.co/kRZJfCfl5y">https://t.co/kRZJfCfl5y</A></P>
<P>— Rob Sewell (@sqldbawithbeard) <A href="https://twitter.com/sqldbawithbeard/status/907592243887968256">September 12, 2017</A></P></BLOCKQUOTE>
<P>
<SCRIPT charset=utf-8 src="//platform.twitter.com/widgets.js" async></SCRIPT>
</P>
<BLOCKQUOTE class=twitter-tweet data-width="550">
<P lang=en dir=ltr><A href="https://twitter.com/hashtag/tsql2sday?src=hash">#tsql2sday</A> post: a <A href="https://twitter.com/hashtag/sqlserver?src=hash">#sqlserver</A> DBA uses <A href="https://twitter.com/hashtag/powershell?src=hash">#powershell</A> <A href="https://twitter.com/cl">@cl</A> <A href="https://twitter.com/sqldbawithbeard">@sqldbawithbeard</A> <A href="https://twitter.com/psdbatools">@psdbatools</A> <A href="https://twitter.com/LaerteSQLDBA">@LaerteSQLDBA</A> <A href="https://twitter.com/SQLvariant">@SQLvariant</A> <A href="https://t.co/TYMSfDH9lf">https://t.co/TYMSfDH9lf</A></P>
<P>— Klaas Vandenberghe (@PowerDBAKlaas) <A href="https://twitter.com/PowerDBAKlaas/status/907553247522684929">September 12, 2017</A></P></BLOCKQUOTE>
<P>
<SCRIPT charset=utf-8 src="//platform.twitter.com/widgets.js" async></SCRIPT>
</P>
<BLOCKQUOTE class=twitter-tweet data-width="550">
<P lang=en dir=ltr>🙂 another 1st time <A href="https://twitter.com/hashtag/tsql2sday?src=hash">#tsql2sday</A> blogger – Craig posts about using the SSRS module <A href="https://t.co/Sf8EJEnr7M">https://t.co/Sf8EJEnr7M</A></P>
<P>— Rob Sewell (@sqldbawithbeard) <A href="https://twitter.com/sqldbawithbeard/status/907593076692209664">September 12, 2017</A></P></BLOCKQUOTE>
<P>
<SCRIPT charset=utf-8 src="//platform.twitter.com/widgets.js" async></SCRIPT>
</P>
<BLOCKQUOTE class=twitter-tweet data-width="550">
<P lang=en dir=ltr>Taiob shows how to easily get information about your SQL Instances that are in CMS with dbatools <A href="https://twitter.com/hashtag/tsql2sday?src=hash">#tsql2sday</A> <A href="https://t.co/17Z7yPeNlW">https://t.co/17Z7yPeNlW</A></P>
<P>— Rob Sewell (@sqldbawithbeard) <A href="https://twitter.com/sqldbawithbeard/status/907604427397312513">September 12, 2017</A></P></BLOCKQUOTE>
<P>
<SCRIPT charset=utf-8 src="//platform.twitter.com/widgets.js" async></SCRIPT>
</P>
<BLOCKQUOTE class=twitter-tweet data-width="550">
<P lang=en dir=ltr>Brian shows how to disable named pipes across many instances with PowerShell – Simple easy security fix 🙂 <A href="https://twitter.com/hashtag/tsql2sday?src=hash">#tsql2sday</A> <A href="https://t.co/wjC6nZnzn3">https://t.co/wjC6nZnzn3</A></P>
<P>— Rob Sewell (@sqldbawithbeard) <A href="https://twitter.com/sqldbawithbeard/status/907622032086650880">September 12, 2017</A></P></BLOCKQUOTE>
<P>
<SCRIPT charset=utf-8 src="//platform.twitter.com/widgets.js" async></SCRIPT>
</P>
<BLOCKQUOTE class=twitter-tweet data-width="550">
<P lang=en dir=ltr>T-SQL Tuesday #94 – Embrace the Shell of Power! Get into Powershell with dbatools<A href="https://t.co/UtUnmQeUI0">https://t.co/UtUnmQeUI0</A><A href="https://twitter.com/hashtag/tsql2sday?src=hash">#tsql2sday</A> <A href="https://twitter.com/hashtag/SQLServer?src=hash">#SQLServer</A> <A href="https://twitter.com/psdbatools">@psdbatools</A></P>
<P>— Jeff Mlakar (@jmlakar) <A href="https://twitter.com/jmlakar/status/907594007185948674">September 12, 2017</A></P></BLOCKQUOTE>
<P>
<SCRIPT charset=utf-8 src="//platform.twitter.com/widgets.js" async></SCRIPT>
</P>
<BLOCKQUOTE class=twitter-tweet data-width="550">
<P lang=en dir=ltr>Bjoern refreshes his dev environment adn fixes his orphaned logins with dbatools and SQL Agent <A href="https://twitter.com/hashtag/tsql2sday?src=hash">#tsql2sday</A> <A href="https://t.co/EVgLGOeMFT">https://t.co/EVgLGOeMFT</A></P>
<P>— Rob Sewell (@sqldbawithbeard) <A href="https://twitter.com/sqldbawithbeard/status/907623402931879937">September 12, 2017</A></P></BLOCKQUOTE>
<P>
<SCRIPT charset=utf-8 src="//platform.twitter.com/widgets.js" async></SCRIPT>
</P>
<BLOCKQUOTE class=twitter-tweet data-width="550">
<P lang=en dir=ltr>Tracy shows how to check the status of AGs with PowerShell and SQL after patching <A href="https://twitter.com/hashtag/tsql2sday?src=hash">#tsql2sday</A> <A href="https://t.co/AZ6nFMFSrD">https://t.co/AZ6nFMFSrD</A></P>
<P>— Rob Sewell (@sqldbawithbeard) <A href="https://twitter.com/sqldbawithbeard/status/907625388532256769">September 12, 2017</A></P></BLOCKQUOTE>
<P>
<SCRIPT charset=utf-8 src="//platform.twitter.com/widgets.js" async></SCRIPT>
</P>
<BLOCKQUOTE class=twitter-tweet data-width="550">
<P lang=en dir=ltr>Storm the castle! (you'll have to read the post)<A href="https://twitter.com/SQLSoldier">@SQLSoldier</A> via <A href="https://twitter.com/SQLBestPractice">@SQLBestPractice</A> shows how to ease the pain of AG Agent Jobs <A href="https://twitter.com/hashtag/tsql2sday?src=hash">#tsql2sday</A> <A href="https://t.co/zciKnk6OH4">https://t.co/zciKnk6OH4</A></P>
<P>— Rob Sewell (@sqldbawithbeard) <A href="https://twitter.com/sqldbawithbeard/status/907626370490097666">September 12, 2017</A></P></BLOCKQUOTE>
<P>
<SCRIPT charset=utf-8 src="//platform.twitter.com/widgets.js" async></SCRIPT>
</P>
<P>Volker wrote about testing best practices with dbatools</P>
<BLOCKQUOTE class=twitter-tweet data-width="550">
<P lang=en dir=ltr>TSQL2sday #94 – SQL Server Best Practices Test with PowerShell dbatools&nbsp;<A href="https://twitter.com/hashtag/tsql2sday?src=hash">#tsql2sday</A> <A href="https://t.co/Og9Ygxy2iu">https://t.co/Og9Ygxy2iu</A> <A href="https://t.co/ls5SLcFrHG">pic.twitter.com/ls5SLcFrHG</A></P>
<P>— Volker Bachmann (@VolkerBachmann) <A href="https://twitter.com/VolkerBachmann/status/907664676150022144">September 12, 2017</A></P></BLOCKQUOTE>
<P>
<SCRIPT charset=utf-8 src="//platform.twitter.com/widgets.js" async></SCRIPT>
</P>
<P>Dave explains why PowerShell is so useful to him in his ETL processes</P>
<BLOCKQUOTE class=twitter-tweet data-width="550">
<P lang=en dir=ltr>[blog] using PowerShell to replace SSIS as an ETL tool <A href="https://t.co/kWFQrQpmcL">https://t.co/kWFQrQpmcL</A> <A href="https://twitter.com/hashtag/TSQL2sDay?src=hash">#TSQL2sDay</A> <A href="https://twitter.com/hashtag/sqlblog?src=hash">#sqlblog</A></P>
<P>— Dave Green (@d_a_green) <A href="https://twitter.com/d_a_green/status/907701284492509184">September 12, 2017</A></P></BLOCKQUOTE>
<P>
<SCRIPT charset=utf-8 src="//platform.twitter.com/widgets.js" async></SCRIPT>
</P>
<P>Steve writes about the time he has saved using PowerShell to automate restores and audit SQL Server instances</P>
<BLOCKQUOTE class=twitter-tweet data-width="550">
<P lang=en dir=ltr>TSQL2sday #94–SQL Server and PowerShell <A href="https://twitter.com/hashtag/tsql2sday?src=hash">#tsql2sday</A><A href="https://t.co/C0LfzsE7ui">https://t.co/C0LfzsE7ui</A></P>
<P>— Steve Thompson (@Steve_TSQL) <A href="https://twitter.com/Steve_TSQL/status/907713842943115264">September 12, 2017</A></P></BLOCKQUOTE>
<P>
<SCRIPT charset=utf-8 src="//platform.twitter.com/widgets.js" async></SCRIPT>
</P>
<P>Nate talks about copying large files like SQL Server backups using BITS with PowerShell</P>
<BLOCKQUOTE class=twitter-tweet data-width="550">
<P lang=en dir=ltr>My <A href="https://twitter.com/hashtag/tsql2sday?src=hash">#tsql2sday</A> entry, because we all know the UTC deadline is a myth =P <A href="https://t.co/9zGvfCOBpg">https://t.co/9zGvfCOBpg</A> <A href="https://twitter.com/hashtag/sqlblogs?src=hash">#sqlblogs</A> <A href="https://twitter.com/hashtag/sqlfamily?src=hash">#sqlfamily</A> <A href="https://twitter.com/natethedba">@natethedba</A></P>
<P>— Nate Johnson (@NJohnson9402) <A href="https://twitter.com/NJohnson9402/status/907792116180508672">September 13, 2017</A></P></BLOCKQUOTE>
<P>
<SCRIPT charset=utf-8 src="//platform.twitter.com/widgets.js" async></SCRIPT>
</P>
<P>Warren talks about his experience as a beginner, the amount of things he automates and his DBReboot module</P>
<BLOCKQUOTE class=twitter-tweet data-width="550">
<P lang=en dir=ltr>new <A href="https://twitter.com/hashtag/sqlblog?src=hash">#sqlblog</A> from yesterday's <A href="https://twitter.com/hashtag/tsql2sday?src=hash">#tsql2sday</A> #94 – lets get all posh. what i'm working on with powershell. <A href="https://t.co/7AlmuWoMev">https://t.co/7AlmuWoMev</A></P>
<P>— Warren Estes (@warren2600) <A href="https://twitter.com/warren2600/status/908003205832957959">September 13, 2017</A></P></BLOCKQUOTE>
<P>
<SCRIPT charset=utf-8 src="//platform.twitter.com/widgets.js" async></SCRIPT>
</P>
<P>THANK YOU every single one and apologies if I have missed anyone!</P>
<P>&nbsp;</P>
<P>&nbsp;</P>

