---
title: 'SQLBits Agenda and PowerShell, displaying and searching'

date: "2023-01-10"
categories:
  - Blog
  - PowerShell
  - SQLBits
  - Community
  - Speaking
  - Conference
  - SQLBits

tags:
  - SQLBits
  - Community
  - Speaking
  - Conference
  - Sesssionize
  - API
  - Sampler



image: assets/uploads/2023/dragonsqlbitslogo.png
---
# What is SQLBits?

[SQLBits](https://sqlbits.com) is the largest data platform conference in Europe. It has been running every year since 2007 in a different city in the UK providing sessions into all things data platform. I have frequently [written about SQLBits](https://blog.robsewell.com/tags/#sqlbits), it is a conference close to my heart and has had a significant impact on my life, my career and my circle of friends.

## Where and when?
This year it is in Newport, Wales at the International Convention Centre Wales (ICC) Tuesday 14th to Saturday 18th of March, 2023

[You can register to attend here](https://events.sqlbits.com/2023/begin)

## What is there at SQLBits?

Tuesday and Wednesday are training days with all day sessions provided by subject matter experts including Microsoft Product Group members, Microsoft Valued Professionals, Microsoft Certified Trainers, and other experts. There are 30 options covering all areas of the Data Platform and none-technical sessions as well.

You can see the [training day agenda here](https://events.sqlbits.com/2023/training-days)

Thursday and Friday have 50 minute, 20 minute and 5 minute sessions with a wide range of topics and levels.

Saturday is the **FREE to attend** day. It also has 50 minute, 20 minute and 5 minute sessions with a wide range of topics and levels.

There are about 250 sessions on Thursday, Friday and Saturday

You can see the [general session agenda here](https://events.sqlbits.com/2023/agenda)

## What else is there outside of technical stuff?

Oh My!!

The biggest benefit is the people, for networking, for answering questions, building relationships with Microsoft product group or local Microsoft, meeting companies who are sponsoring, finding your new job or your new team members, learning and sharing with your peers.

There is also a pub quiz on Thursday evening, the Friday night costume party, the community zone.

# How do I find the sessions?

With so many sessions, its hard to find the ones that you want or to get a good overview in the format that you want. So I built a PowerShell module to get that information for you easily in any format you like. (Editor - thats a fib, he built it so that he could write Pester to ensure that speakers were not scheduled when they were not available)

# The SQLBitsPS module

You can find the SQLBitsPS PowerShell module on the [PowerShell Gallery](https://www.powershellgallery.com/packages/SQLBitsPS)

[![image](https://user-images.githubusercontent.com/6729780/211528862-5226d25a-5642-44a3-9c14-f88bfa334aa2.png)](https://user-images.githubusercontent.com/6729780/211528862-5226d25a-5642-44a3-9c14-f88bfa334aa2.png)

As with all PowerShell modules from the Gallery, you can install it by running

`Install-Module SQLBitsPS`

I find that a lot of people like to use the `ShowWindow` parameter to have the help in another searchable window.

`Get-Help Get-SQLBitsSchedule -ShowWindow`
[![image](https://user-images.githubusercontent.com/6729780/211530034-596f0fc9-ec1d-43fc-bd7a-ff1cf01c7c15.png)](https://user-images.githubusercontent.com/6729780/211530034-596f0fc9-ec1d-43fc-bd7a-ff1cf01c7c15.png)

## Use the help

to find out how to use any PowerShell command you should use Get-Help and this module is no different. The help for the commands is built in and can be accessed with

`Get-Help Get-SQLBitsSchedule`

## Getting the schedule

You can just run  `Get-SQLBitsSchedule` and by default it will get the schedule and if you have the `ImportExcel` module available it will write an Excel Workbook with each days agenda on a different sheet and colour code the service sessions like Registration, lunch and coffee breaks

[![image](https://user-images.githubusercontent.com/6729780/211530884-1d2b2752-a729-499d-8334-1e4404199002.png)](https://user-images.githubusercontent.com/6729780/211530884-1d2b2752-a729-499d-8334-1e4404199002.png)

To save you having to click to open Excel I have added a `Show` parameter which will open it for you!

[![image](https://user-images.githubusercontent.com/6729780/211531837-2396cfd5-b843-4fd8-8a90-d1e1a06e654f.png)](https://user-images.githubusercontent.com/6729780/211531837-2396cfd5-b843-4fd8-8a90-d1e1a06e654f.png)

## I would like a csv instead

The `output` parameter gives you a number of options for the format of the output. If you do not have the `ImportExcel` module it will default to `-output csv` which you can also combine with the `Show` parameter

`Get-SQLBitsSchedule -output csv -show`

[![image](https://user-images.githubusercontent.com/6729780/211532406-bc928085-ab6f-4d8c-b42e-edc53ce027ca.png)](https://user-images.githubusercontent.com/6729780/211532406-bc928085-ab6f-4d8c-b42e-edc53ce027ca.png)

## I would like a html page instead

It's not awesome but you can also create an HTML page. This may be useful if you wish to print the agenda yourself so that you have a hard copy.

`Get-SQLBitsSchedule -output html -show`

[![image](https://user-images.githubusercontent.com/6729780/211533198-9bd8c53f-71b1-4426-bc1f-d7a8e874a86a.png)](https://user-images.githubusercontent.com/6729780/211533198-9bd8c53f-71b1-4426-bc1f-d7a8e874a86a.png)

## Let me decide what format I want

You can also output a `[pscustomobject]` which you may use to PowerShell to your hearts content!!

`Get-SQLBitsSchedule -output object |Format-Table`

[![image](https://user-images.githubusercontent.com/6729780/211533959-ee9f2fb5-e4be-45f2-9142-581833ee214f.png)](https://user-images.githubusercontent.com/6729780/211533959-ee9f2fb5-e4be-45f2-9142-581833ee214f.png)

Maybe you would like to see the sessions that are on Friday at 16:50

`Get-SQLBitsSchedule -output object |Where-Object {$_.Day -eq 'Friday' -and $_.StartTime -eq '16:50'} `

[![image](https://user-images.githubusercontent.com/6729780/211534901-f75cfc82-71bc-456e-bb2c-306dd753cf9b.png)](https://user-images.githubusercontent.com/6729780/211534901-f75cfc82-71bc-456e-bb2c-306dd753cf9b.png)

They look amazing, I recommend Mladen Prajdic session. That one blew me away at Data Grillen and I may very well attend that again.

## I can't do anything fancy, just let me search

If all you want is to search for your favourite speaker then you can use the `search` parameter which will perform a wildcard search.

`Get-SQLBitsSchedule -search Cathrine -output object`

[![image](https://user-images.githubusercontent.com/6729780/211536336-0202aec6-56f1-4f72-aa5b-4cc15de8f848.png)](https://user-images.githubusercontent.com/6729780/211536336-0202aec6-56f1-4f72-aa5b-4cc15de8f848.png)

`Get-SQLBitsSchedule -search Monica -output object`

[![image](https://user-images.githubusercontent.com/6729780/211535867-93496665-3423-4809-a1b3-561d56315594.png)](https://user-images.githubusercontent.com/6729780/211535867-93496665-3423-4809-a1b3-561d56315594.png)

You can also use it search for topics

`Get-SQLBitsSchedule -search 'Mental Health'  -output object`

[![image](https://user-images.githubusercontent.com/6729780/211536684-5b9a56e3-a487-40f4-aad7-f3656654c21a.png)](https://user-images.githubusercontent.com/6729780/211536684-5b9a56e3-a487-40f4-aad7-f3656654c21a.png)

and even to search for wisdom!!

`Get-SQLBitsSchedule -search wisdom  -output object `

[![image](https://user-images.githubusercontent.com/6729780/211537382-2a0ae647-cdc1-4ccc-82ba-87efe7fb857e.png)](https://user-images.githubusercontent.com/6729780/211537382-2a0ae647-cdc1-4ccc-82ba-87efe7fb857e.png)

# I want to make it better

Awesome, thank you.

This is all open-source and you can find it on GitHub at

[https://github.com/SQLDBAWithABeard/SQLBitsPS](https://github.com/SQLDBAWithABeard/SQLBitsPS)

There are some brief instructions here

[https://github.com/SQLDBAWithABeard/SQLBitsPS/blob/main/DevelopingREADME.md](https://github.com/SQLDBAWithABeard/SQLBitsPS/blob/main/DevelopingREADME.md)

# Join us

[SQLBits](https://sqlbits.com) is the largest data platform conference in Europe. It has been running every year since 2007 in a different city in the UK providing sessions into all things data platform.

## Where and when?
This year it is in Newport, Wales at the International Convention Centre Wales (ICC) Tuesday 14th to Saturday 18th of March, 2023

[You can register to attend here](https://events.sqlbits.com/2023/begin)











