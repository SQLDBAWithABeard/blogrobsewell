---
title: "My current VS Code Extensions and using a workspace file"
date: "2019-11-01" 
categories:
  - Blog
  - dbatools
  - PowerShell
  - SQL Server
  - Visual Studio Code
  
tags:
  - dbatoolsmol
  - extensions
  - PowerShell
  - Visual Studio Code
  - workspace

header:
  teaser: /assets/uploads/2019/11/image-26.png

---
I have been asked a couple of times recently what my Visual Studio Code extensions are at the moment so I thought I would write a quick post and also look at workspaces and how you can enable and disable extensions within them

Listing Extensions
------------------

From the command line you can list your extensions using

    code --list-extensions
    code-insiders --list-extensions

My list looks like this

[![](https://blog.robsewell.com/assets/uploads/2019/11/image.png )](https://blog.robsewell.com/assets/uploads/2019/11/image.png?ssl=1)

You can also see them in the view on the left of default Visual Studio Code and open them with CTRL + SHIFT + X (unless like me you have Snagit installed and it has taken that shortcut

![](https://blog.robsewell.com/assets/uploads/2019/11/image-31.png )

Installing Extensions
---------------------

You can install extensions by opening the Extensions view in Visual Studio Code and searching for the extension. The list I have below has the precise names for each extension which you can use to search

![](https://blog.robsewell.com/assets/uploads/2019/11/image-24.png )

You can also install extensions from the command-line with

    code --install-extension <extensionid>
    code-insiders --install-extension <extensionid>

My Extensions
-------------

I am going to list these in alphabetical order by display name for ease (my ease that is!)

![](https://blog.robsewell.com/assets/uploads/2019/11/image-1.png )

Because Chrissy LeMaire and I are writing [dbatools in a Month of Lunches](https://beard.media/book) using AsciiDoc, it makes sense to have an extension enabling previewing and syntax, you can find it [here](https://marketplace.visualstudio.com/items?itemName=stayfool.vscode-asciidoc)

![](https://blog.robsewell.com/assets/uploads/2019/11/image-2.png )

For interacting with Azure I use the Azure Account Extension – ms-vscode.azure-account

![](https://blog.robsewell.com/assets/uploads/2019/11/image-3.png )

I use Azure CLI so I make use of the functionality of the Azure CLI Tools extension ms-vscode.azurecli

![](https://blog.robsewell.com/assets/uploads/2019/11/image-4.png )

For interacting with Azure Repos I use the ms-vsts.team extension

![](https://blog.robsewell.com/assets/uploads/2019/11/image-5.png )

When creating ARM templates, this extension is very useful msazurermtools.azurerm-vscode-tools

![](https://blog.robsewell.com/assets/uploads/2019/11/image-6.png )

I have a few theme extensions, this one is for fun in demos 😉 beardedbear.beardedtheme

![](https://blog.robsewell.com/assets/uploads/2019/11/image-7.png )

The blackboard theme is my default one gerane.theme-blackboard

![](https://blog.robsewell.com/assets/uploads/2019/11/image-8.png )

Chasing closing brackets is much easier with the Bracket Pair Colorizer, I use the beta version coenraads.bracket-pair-colorizer-2

![](https://blog.robsewell.com/assets/uploads/2019/11/image-10.png )

I am rubbish at spelling and typing so I use this to help point out the issues! streetsidesoftware.code-spell-checker

![](https://blog.robsewell.com/assets/uploads/2019/11/image-11.png )

Using the Docker extension adds another view to Visual Studio Code to ease working with containers ms-azuretools.vscode-docker

![](https://blog.robsewell.com/assets/uploads/2019/11/image-12.png )

As an open-source project maintainer it is good to be able to work with GitHub pull requests without leaving Visual Studio Code github.vscode-pull-request-github_Preview_

![](https://blog.robsewell.com/assets/uploads/2019/11/image-13.png )

GitLens is absolutely invaluable when working with source control. It has so many features. This is an absolute must eamodio.gitlens

![](https://blog.robsewell.com/assets/uploads/2019/11/image-14.png )

Working with Kubernetes? This extension adds another view for interacting with your cluster ms-kubernetes-tools.vscode-kubernetes-tools

![](https://blog.robsewell.com/assets/uploads/2019/11/image-15.png )

Visual Studio Live Share enables you to collaborate in real-time in Visual Studio Code with your colleagues or friends. I blogged about this [here](https://blog.robsewell.com/visual-studio-code-live-sharing-set-up/) ms-vsliveshare.vsliveshare

![](https://blog.robsewell.com/assets/uploads/2019/11/image-16.png )

I love writing markdown and this linter assists me to ensure that my markdown is correct davidanson.vscode-markdownlint

![](https://blog.robsewell.com/assets/uploads/2019/11/image-17.png )

The Material Icon Theme ensures that there are pretty icons in my editor! pkief.material-icon-theme

![](https://blog.robsewell.com/assets/uploads/2019/11/image-18.png )

I have both the PowerShell extension ms-vscode.powershell and the PowerShell preview extension ms-vscode.powershell-preview installed but only one can be enabled at a time

![](https://blog.robsewell.com/assets/uploads/2019/11/image-19.png )

This suite of extensions enables easy remote development so that you can develop your PowerShell scripts, for example, inside a ubuntu container running PowerShell 7 or inside Windows Subsystem for LInux ms-vscode-remote.vscode-remote-extensionpack_Preview_

![](https://blog.robsewell.com/assets/uploads/2019/11/image-20.png )

Writing for cross-platform means looking out for line endings and this extension will display them and any whitespace in your editor medo64.render-crlf

![](https://blog.robsewell.com/assets/uploads/2019/11/image-21.png )

An absolutely essential extension which enables me to backup all of my Visual Studio Code settings, shortcuts, extensions into a GitHub gist and keep all of my machines feeling the same. shan.code-settings-sync

![](https://blog.robsewell.com/assets/uploads/2019/11/image-22.png )

For working with SQL Server within Visual Studio Code and having a view for my instances as well as a linter and intellisense I use ms-mssql.mssql

![](https://blog.robsewell.com/assets/uploads/2019/11/image-23.png )

Yaml files and spaces! I no longer get so confused with this extension to help me 🙂 redhat.vscode-yaml

Workspaces
----------

Now that is a lot of extensions and I dont need all of them everytime. I use workspaces to help with this. I will create a workspace file for the project I am working on.

I open or create the folders I will be working on and then click File and Save Workspace As and save the file in the root of the folder.

![](https://blog.robsewell.com/assets/uploads/2019/11/image-25.png )

Now, the next time I want to open the workspace, I can open the workspace file or if I open the folder Visual Studio Code will helpfully prompt me

![](https://blog.robsewell.com/assets/uploads/2019/11/image-26.png )

Now I can have all of my settings retained for that workspace

![](https://blog.robsewell.com/assets/uploads/2019/11/image-27.png )

For this folder, I am ensuring that the PowerShell extension uses the PSScriptAnalyzer Settings file that I have created so that it will show if the code is compatible with the versions of PowerShell I have chosen. I can define settings for a workspace in the settings file, which you can open using CTRL and ,

![](https://blog.robsewell.com/assets/uploads/2019/11/image-28.png )

But I can also enable or disable extensions for a workspace

![](https://blog.robsewell.com/assets/uploads/2019/11/image-29.png )

So everytime I open this workspace I am only loading the extensions I want

![](https://blog.robsewell.com/assets/uploads/2019/11/image-30.png )
