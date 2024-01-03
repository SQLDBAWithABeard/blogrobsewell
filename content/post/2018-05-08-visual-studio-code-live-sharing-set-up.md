---
title: "Visual Studio Code Live Sharing Set-Up"
date: "2018-05-08" 
categories:
  - Blog
  - PowerShell
  - dbachecks
  - dbatools
  - VS Code

tags:
  - sqlgrillen
  - Data Grillen
  - Live Share


image: assets/uploads/2018/05/07-sign-in.png

---
There was an [announcement on the Visual Studio Code blog](https://code.visualstudio.com/blogs/2018/05/07/live-share-public-preview) about the public preview of Live Share. This enables you to easily collaborate on code by securely sharing your coding session.

It is remarkably easy to set up 🙂

Installation
------------

Open Visual Studio Code, open the Extensions side bar (CTRL + SHIFT + X)

[![01 - open extensions](assets/uploads/2018/05/01-open-extensions.png)](assets/uploads/2018/05/01-open-extensions.png)

Search for Live Share

[![02 - search.png](assets/uploads/2018/05/02-search.png)](assets/uploads/2018/05/02-search.png)

Click Install and then reload when it has done

[![03 - reload.png](assets/uploads/2018/05/03-reload.png)](assets/uploads/2018/05/03-reload.png)

You will notice in the bottom bar it will say finishing the installation and if you open the terminal (CTRL + ‘) and click on Output and change the drop down on the right to Visual Studio Live Share you can see what it is doing

[![04 - finishing installation.png](assets/uploads/2018/05/04-finishing-installation.png)](assets/uploads/2018/05/04-finishing-installation.png)

It is installing the dependancies as shown below

> [Client I] Installing dependencies for Live Share…
> 
> [Client I] Downloading package ‘.NET Core Runtime 2.0.5 for win7-x86’
> 
> [Client I] Download complete.
> 
> [Client I] Downloading package ‘OmniSharp for Windows (.NET 4.6)’
> 
> [Client I] Download complete.
> 
> [Client I] Installing package ‘.NET Core Runtime 2.0.5 for win7-x86’
> 
> [Client V] Extracted packed files
> 
> [Client I] Validated extracted files.
> 
> [Client I] Moved and validated extracted files.
> 
> [Client I] Finished installing.
> 
> [Client I] Installing package ‘OmniSharp for Windows (.NET 4.6)’
> 
> [Client V] Extracted packed files
> 
> [Client I] Validated extracted files.
> 
> [Client I] Finished installing.
> 
> [Client I] No workspace id found.

Incidentally, this will also show the location of the log file

You will see in the bottom bar it will now say sign in

[![06 - sign in.png](assets/uploads/2018/05/06-sign-in.png)](assets/uploads/2018/05/06-sign-in.png)

Clicking that will open a browser and give you a choice of accounts to sign in with, your GitHub or your Microsoft ID

[![07 - sign in.png](assets/uploads/2018/05/07-sign-in.png)](assets/uploads/2018/05/07-sign-in.png)

Choose the one that you want to use and do your 2FA.

[![08 - 2FA.png](assets/uploads/2018/05/08-2FA.png)](assets/uploads/2018/05/08-2FA.png)

You do have 2FA on your Microsoft and GitHub (and all the other services)? If not go and set it up now – [here for Microsoft](https://account.live.com/proofs/manage/additional?mkt=en-US&refd=account.microsoft.com&refp=security) and [here for GitHub ](https://github.com/settings/security)

Once you have signed in you will get this notification which you can close

[![09 - close this notification.png](assets/uploads/2018/05/09-close-this-notification.png)](assets/uploads/2018/05/09-close-this-notification.png)

The icon in the bottom will change and show your account name and if you click it it will open the menu

[![09 - sharing menu.png](assets/uploads/2018/05/09-sharing-menu.png)](assets/uploads/2018/05/09-sharing-menu.png)

Sharing
-------

To share your session you click on the Share icon in the bottom bar or the Start collaboration session in the menu above. The first time you do this there will be a pop-up as shown

[![05 - firewall popup.png](assets/uploads/2018/05/05-firewall-popup.png)](assets/uploads/2018/05/05-firewall-popup.png)

You can decide which way you (or your organisation) want to share. I chose to accept the firewall exception.

[![10 - invite link.png](assets/uploads/2018/05/10-invite-link.png)](assets/uploads/2018/05/10-invite-link.png)

The invite link is in your clipboard ready to share with your friends and colleagues (other open source contributors ??)

They can either open the link in a browser

[![11 - join via browser.png](assets/uploads/2018/05/11-join-via-browser.png)](assets/uploads/2018/05/11-join-via-browser.png)

or by using the Join Collaboration Session in the menu in VS Code

[![12 - Join via VS COde.png](assets/uploads/2018/05/12-Join-via-VS-COde.png)](assets/uploads/2018/05/12-Join-via-VS-COde.png)

Once they do the sharer will get a notification

[![13 - notification of sharing.png](assets/uploads/2018/05/13-notification-of-sharing.png)](assets/uploads/2018/05/13-notification-of-sharing.png)

and the person who has joined will have the same workspace opened in their Visual Studio Code

[![14 -shared workspace.png](assets/uploads/2018/05/14-shared-workspace.png)](assets/uploads/2018/05/14-shared-workspace.png)

You can then collaborate on your code and share the session. In the video below the left hand side is running in my jump box in Azure and the right hand side on my laptop and you can see that if you highlight code in one side it is shown in the other and if you alter it in one side it is changed in the other. I also saved that file in the joined session rather than from the session that initialised the sharing and it then saved in both sessions 🙂
<DIV id=v-Mhp7Gr09-1 class=video-player><IFRAME height=180 src="https://videopress.com/embed/Mhp7Gr09?hd=1&amp;loop=0&amp;autoPlay=0&amp;permalink=1" frameBorder=0 width=630 allowfullscreen></IFRAME>
<SCRIPT src="https://s0.wp.com/wp-content/plugins/video/assets/js/next/videopress-iframe.js"></SCRIPT>
</DIV>

So that shows how easy it is to install and to use. You can dive deeper [using the documentation](https://docs.microsoft.com/en-us/visualstudio/liveshare/).

Happy Collaborating 🙂


















