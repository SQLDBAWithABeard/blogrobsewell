---
title: "Installing and upgrading default scripts automation - part one - Introduction"
date: "2015-06-08"

categories:
  - PowerShell
  - SQL Server
tags:
  - SQL Agent Jobs
  - Auto Script Install
  - automate
  - automation
  - documentation
  - permissions
  - PowerShell
  - script
  - SQL Server
---

First I must say thank you to all of the wonderful people who have put time and effort into providing free tools and scripts to enable not only myself but all SQL DBAs to ease their work. For this series I especially thank

- Brent Ozar - [w](http://www.brentozar.com/)|[t](https://twitter.com/BrentO)
- Ola Hallengren - [w](https://ola.hallengren.com/)
- Adam Mechanic - [b](http://sqlblog.com/blogs/adam_machanic/)|[t](https://twitter.com/adammachanic)
- Jared Zagelbaum - [b](https://jaredzagelbaum.wordpress.com/)|[t](https://twitter.com/JaredZagelbaum)

The aim of this series is to share the methodology and the scripts that I have used to resolve this issue.

How can I automate the deployment and update of backup, integrity ,index maintenance and troubleshooting scripts as well as other default required scripts to all of the instances under my control and easily target any instances by OS version, SQL version, Environment, System or any other configuration of my choosing

This is Part 1 - Introduction I will link to the further posts here as I write them

So the scenario that lead to this series is a varied estate of SQL servers and instances where I wanted an automated method of deploying the scripts and being able to target different servers. It needed to be easy to maintain, easy to use and easy to alter. I wanted to be able to update all of the scripts easily when required. I also wanted to automate the install of new instances and ensure that I could ensure that all required scripts were installed and documented.

The method of doing this that I chose is just that - Its the way that I chose, whether it will work for you and your estate I don't know but I hope you will find it of benefit. Of course you must test it first. Ensure that you understand what is happening, what it is doing and that that is what you want it to do. If you implement this methodology of installing scripts you will easily be able to start by targeting your Development Server and then gradually rolling it out to any other environments' whilst always making sure that you test, monitor and validate prior to moving to the next.

I decided that I needed to have a DBA Database to start with. The role of the DBA Database is to be the single source of truth for the instances that are under my control, a source for the location of the scripts that I need to deploy and a place to hold the information that I gather from the servers. It is from this database that I will be able to target the instances as required and set the flags to update the scripts as and when I need to

[![agentjob](https://sqldbawithabeard.com/wp-content/uploads/2015/06/agentjob1.png?w=300)](https://sqldbawithabeard.com/wp-content/uploads/2015/06/agentjob1.png)

On that instance I also chose to put the SQL Agent Job that will deploy all of the scripts. This is an important point. The account that you use to run that job whether it is the Agent Service Account or a proxy account will need to have privileges on every instance that you target. It will need to be able to run every script that you wish to target your servers. The privileges it requires are defined by the scripts that you want to run. How that is set up is unique to your environment and your system. I will only say that all errors are logged to the log files and will enable you to resolve these issues. You should always use the principle of least privilege required to get the job done. Domain and Sys Admin are not really the best answer here :-)

I also created 2 further Agent Jobs to gather Windows and SQL Information from the servers. These jobs target all the instances and servers in the DBA Database and gather information centrally about Windows and SQL configurations making it easy to provide that information to any other teams that require it. I am always looking for methods to reduce the workload on DBAs and enabling people (using the correct permissions) to gather the information that they require by self-service is very beneficial

Documentation and logging about the scripts are provided by the log files stored as text files to troubleshoot the script and also documented in the Change log table in a DBA database on each instance which I blogged about [previously here](http://sqldbawithabeard.com/2014/12/08/making-a-change-log-easier-with-PowerShell/)

The last thing was the script which needed to be modular and easy to add to and amend.

Throughout this series of blog posts I will share and expand on the methods I used to do this. If you have any questions at any point please feel free to ask either by commenting on the post or by contacting me using the methods on my About Me page
