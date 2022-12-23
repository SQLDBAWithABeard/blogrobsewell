---
title: "dbatools with SQL on Docker and running SQL queries"
categories:
  - Blog

tags:
  - containers
  - dbatools
  - docker
  - linux
  - PowerShell

---
<P>I had a question from my good friend Andrew Pruski <A href="http://twitter.com/dbafromthecold" rel=noopener target=_blank>dbafromthecold on twitter</A> or SQL Container Man as I call him 🙂</P>
<BLOCKQUOTE>
<P>How do you guys run SQL Commands in dbatools</P></BLOCKQUOTE>
<P>I will answer that at the bottom of this post, but during our discussion Andrew said he wanted to show the version of the SQL running in the Docker Container.</P>
<P>Thats easy I said. Here’s how to do it</P>
<P>You need to have installed Docker first <A href="https://docs.docker.com/docker-for-windows/install/" rel=noopener target=_blank>see this page</A>&nbsp;You can switch to using Windows containers right-clicking on the icon in the taskbar and choosing the command. If you have not already, then pull the SQL 2017 SQL image using</P><PRE class="lang:ps decode:true ">docker pull microsoft/mssql-server-windows-developer:latest</PRE>
<P>This may take a while to download and extract the image but its worth it, you will be able to spin up new SQL instances in no time</P>
<P>You can create a new SQL Docker container like this</P>
<DIV><PRE class="lang:ps decode:true ">docker run -d -p 15789:1433 --env ACCEPT_EULA=Y --env sa_password=SQL2017Password01 --name SQL2017 microsoft/mssql-server-windows-developer:latest
</PRE>
<P>In only a few seconds you have a SQL 2017 instance up and running (Take a look at Andrews blog at <A href="https://dbafromthecold.com" rel=noopener target=_blank>dbafromthecold.com </A>for a great container series with much greater detail)</P>
<P>Now that we have our container we need to connect to it. We need to gather the IPAddress. We can do this using docker command <A href="https://docs.docker.com/engine/reference/commandline/inspect/" rel=noopener target=_blank>docker inspect</A>&nbsp;but I like to make things a little more programmatical. This works for my Windows 10 machine for Windows SQL Containers. There are some errors with other machines it appears but there is an alternative below</P>
<DIV><PRE class="lang:ps decode:true  ">$inspect = docker inspect SQL2017
&lt;#
IPAddress": matches the characters IPAddress": literally (case sensitive)
\s matches any whitespace character (equal to [\r\n\t\f\v ])
" matches the character " literally (case sensitive)
1st Capturing Group (\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3})
\d{1,3} matches a digit (equal to [0-9])
. matches any character (except for line terminators)
\d{1,3} matches a digit (equal to [0-9])
. matches any character (except for line terminators)
\d{1,3} matches a digit (equal to [0-9])
. matches any character (except for line terminators)
\d{1,3} matches a digit (equal to [0-9])
#&gt;
$IpAddress = [regex]::matches($inspect,"IPAddress`":\s`"(\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3})").groups[1].value
</PRE>
<P>Those two lines of code (and several lines of comments) puts the results of the docker inspect command into a variable and then uses regex to pull out the IP Address</P>
<P>If you are getting errors with that you can also use</P><PRE class="lang:ps decode:true ">$IPAddress =docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' containername</PRE>
<P>Thanks Andrew 🙂</P>
<P>Now we just need our credentials to connect to the instance</P>
<DIV><PRE class="lang:ps decode:true ">$cred = Get-Credential -UserName SA -Message "Enter SA Password Here"</PRE>
<P>and we can connect to our SQL container</P></DIV></DIV><PRE class="lang:ps decode:true ">$srv = Connect-DbaInstance -SqlInstance $IpAddress -Credential $cred</PRE>
<P>and get the version</P><PRE class="lang:ps decode:true ">$srv.Version</PRE>
<P><IMG class="alignnone wp-image-8425" alt="" src="https://blog.robsewell.com/assets/uploads/2017/11/srv.png?resize=630%2C113&amp;ssl=1" width=630 height=113 sizes="(max-width: 630px) 100vw, 630px" data-recalc-dims="1" srcset="https://blog.robsewell.com/assets/uploads/2017/11/srv.png?resize=300%2C54&amp;ssl=1 300w,https://blog.robsewell.com/assets/uploads/2017/11/srv.png?resize=768%2C139&amp;ssl=1 768w,https://blog.robsewell.com/assets/uploads/2017/11/srv.png?resize=1024%2C186&amp;ssl=1 1024w,https://blog.robsewell.com/assets/uploads/2017/11/srv.png?w=1852&amp;ssl=1 1852w,https://blog.robsewell.com/assets/uploads/2017/11/srv.png?w=1260&amp;ssl=1 1260w" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/11/srv.png?fit=630%2C114&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/11/srv.png?fit=300%2C54&amp;ssl=1" data-image-description="" data-image-title="srv" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1852,336" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/11/srv.png?fit=1852%2C336&amp;ssl=1" data-permalink="https://blog.robsewell.com/srv/" data-attachment-id="8425"></P>
<P>and many many other properties, just run</P><PRE class="lang:ps decode:true">$srv | Get-Member</PRE>
<P>to see them. At the bottom, you will see a ScriptMethod called Query, which means that you can do things like</P></DIV>
<DIV><PRE class="lang:ps decode:true ">$Query = @"
SELECT @@Version
"@

$srv.Query($Query)

$srv.Query($Query).column1</PRE>
<P>Which looks like</P>
<P><IMG class="alignnone wp-image-8420" alt="" src="https://blog.robsewell.com/assets/uploads/2017/11/query.png?resize=630%2C162&amp;ssl=1" width=630 height=162 sizes="(max-width: 630px) 100vw, 630px" data-recalc-dims="1" srcset="https://blog.robsewell.com/assets/uploads/2017/11/query.png?resize=300%2C77&amp;ssl=1 300w,https://blog.robsewell.com/assets/uploads/2017/11/query.png?resize=768%2C198&amp;ssl=1 768w,https://blog.robsewell.com/assets/uploads/2017/11/query.png?resize=1024%2C263&amp;ssl=1 1024w,https://blog.robsewell.com/assets/uploads/2017/11/query.png?w=1260&amp;ssl=1 1260w,https://blog.robsewell.com/assets/uploads/2017/11/query.png?w=1890&amp;ssl=1 1890w" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/11/query.png?fit=630%2C162&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/11/query.png?fit=300%2C77&amp;ssl=1" data-image-description="" data-image-title="query" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="2531,651" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/11/query.png?fit=2531%2C651&amp;ssl=1" data-permalink="https://blog.robsewell.com/query/" data-attachment-id="8420"></P></DIV>
<DIV>It’s slightly different with a Linux SQL container. Switch Docker to run Linux containers by right-clicking on the icon in the taskbar and choosing the command to switch.</DIV>
<DIV></DIV>
<DIV>If you haven’t already pull the Linux SQL image</DIV>
<DIV><PRE class="lang:ps decode:true">docker pull microsoft/mssql-server-linux:2017-latest</PRE>
<P>and then create a container</P>
<DIV><PRE class="lang:ps decode:true ">docker run -d -p 15789:1433 --env ACCEPT_EULA=Y --env SA_PASSWORD=SQL2017Password01 --name linuxcontainer microsoft/mssql-server-linux:2017-latest
</PRE>
<P>Now we just need to connect with localhost and the port number which we have specified already and we can connect again</P>
<DIV><PRE class="lang:ps decode:true ">$LinuxSQL = 'Localhost,15789'
$linuxsrv = Connect-DbaInstance -SqlInstance $LinuxSQL -Credential $cred
$linuxsrv.Version
$linuxsrv.HostDistribution
$linuxsrv.Query($query).column1</PRE>
<P><IMG class="alignnone wp-image-8421" alt="" src="https://blog.robsewell.com/assets/uploads/2017/11/linuxquery.png?resize=630%2C275&amp;ssl=1" width=630 height=275 sizes="(max-width: 630px) 100vw, 630px" data-recalc-dims="1" srcset="https://blog.robsewell.com/assets/uploads/2017/11/linuxquery.png?resize=300%2C131&amp;ssl=1 300w,https://blog.robsewell.com/assets/uploads/2017/11/linuxquery.png?resize=768%2C336&amp;ssl=1 768w,https://blog.robsewell.com/assets/uploads/2017/11/linuxquery.png?resize=1024%2C448&amp;ssl=1 1024w,https://blog.robsewell.com/assets/uploads/2017/11/linuxquery.png?w=1740&amp;ssl=1 1740w,https://blog.robsewell.com/assets/uploads/2017/11/linuxquery.png?w=1260&amp;ssl=1 1260w" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/11/linuxquery.png?fit=630%2C276&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/11/linuxquery.png?fit=300%2C131&amp;ssl=1" data-image-description="" data-image-title="linuxquery" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1740,762" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/11/linuxquery.png?fit=1740%2C762&amp;ssl=1" data-permalink="https://blog.robsewell.com/linuxquery/" data-attachment-id="8421"></P></DIV>
<P>Of course, this isn’t restricted just Connect-DbaInstance you can do this with any dbatools commands</P></DIV><PRE class="lang:ps decode:true ">Get-DbaDatabase -SqlInstance $LinuxSQL -SqlCredential $cred</PRE>
<P><IMG class="alignnone wp-image-8422" alt="" src="https://blog.robsewell.com/assets/uploads/2017/11/databases.png?resize=630%2C166&amp;ssl=1" width=630 height=166 sizes="(max-width: 630px) 100vw, 630px" data-recalc-dims="1" srcset="https://blog.robsewell.com/assets/uploads/2017/11/databases.png?resize=300%2C79&amp;ssl=1 300w,https://blog.robsewell.com/assets/uploads/2017/11/databases.png?resize=768%2C201&amp;ssl=1 768w,https://blog.robsewell.com/assets/uploads/2017/11/databases.png?resize=1024%2C268&amp;ssl=1 1024w,https://blog.robsewell.com/assets/uploads/2017/11/databases.png?w=1837&amp;ssl=1 1837w,https://blog.robsewell.com/assets/uploads/2017/11/databases.png?w=1260&amp;ssl=1 1260w" loading="lazy" data-large-file="https://blog.robsewell.com/assets/uploads/2017/11/databases.png?fit=630%2C165&amp;ssl=1" data-medium-file="https://blog.robsewell.com/assets/uploads/2017/11/databases.png?fit=300%2C79&amp;ssl=1" data-image-description="" data-image-title="databases" data-image-meta='{"aperture":"0","credit":"","camera":"","caption":"","created_timestamp":"0","copyright":"","focal_length":"0","iso":"0","shutter_speed":"0","title":"","orientation":"0"}' data-comments-opened="1" data-orig-size="1837,481" data-orig-file="https://blog.robsewell.com/assets/uploads/2017/11/databases.png?fit=1837%2C481&amp;ssl=1" data-permalink="https://blog.robsewell.com/databases/" data-attachment-id="8422"></P>
<P>Go and explore your Docker SQL conatiners with dbatools 🙂</P>
<P>You can get it using</P><PRE class="lang:ps decode:true">Install-Module dbatools</PRE>
<P>and find commands with</P><PRE class="lang:ps decode:true">Find-DbaCommand database</PRE>
<P>Don’t forget to use Get-Help with the name of the command to get information about how to use it</P><PRE class="lang:ps decode:true ">Get-Help Find-DbaCommand -detailed</PRE>
<P>Enjoy 🙂</P></DIV>
<DIV></DIV>

