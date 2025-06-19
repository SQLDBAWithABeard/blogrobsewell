---
title: "Pester for Presentations – Ensuring it goes ok"
date: "2017-05-16"
categories:
  - Blog

tags:
  - pester
  - PowerShell
  - presentations

---
Whilst I was at [PSCONFEU](http://psconf.eu) I presented a session on writing pester tests instead of using checklists.
{{< youtube uvT57pt8 >}}

You can see it here.

During the talk I showed the pester test that I use to make sure that everything is ready for my presentation. A couple of people have asked me about this and wanted to know more so I thought that I would blog about it.

Some have said that I might be being a little OCD about it 😉 I agree that it could seem like that but there is nothing worse than having things go wrong during your presentation. It makes your heart beat faster and removes the emphasis from the presentation that you give.

When it is things that you as a presenter could have been able to foresee, like a VM not being started or a database not being restored to the pre-demo state or being logged in as the wrong user then it is much worse.

I use Pester to ensure that my environment for my presentation is as I expect and in fact, in Hanover when I ran through my Pester test for my NUC environment I found that one of my SQL Servers had decided to be in a different time zone and therefore the SQL Service would not authenticate and start. I was able to quickly remove the references to that server and save myself from a sea of red during my demos.

For those that don’t know, [Pester is a PowerShell module for Test Driven Development](https://github.com/pester/Pester).

> Pester provides a framework for running unit tests to execute and validate PowerShell commands from within PowerShell. Pester consists of a simple set of functions that expose a testing domain-specific language (DSL) for isolating, running, evaluating and reporting the results of PowerShell commands.

If you have PowerShell version 5 then you will have Pester already installed, although you should update it to the latest version. If not, you can get [Pester from the PowerShell Gallery](https://www.powershellgallery.com/packages/Pester/)—follow the instructions on that page to install it. [This is a good post to start learning about Pester](https://www.simple-talk.com/sysadmin/powershell/practical-powershell-unit-testing-getting-started/).

What can you test? Everything. Well, specifically everything that you can write a PowerShell command to check. So when I am setting up for my presentation I check the following things. I add new things to my tests as I think of them or as I observe things that may break my presentations. Most recently that was ensuring that my Visual Studio Code session was running under the correct user. I did that like this:

```powershell
Describe "Presentation Test" {
    Context "VSCode" {
        It "Should be using the right username" {
            whoami | Should Be 'TheBeard\Rob'
       }
    }
}