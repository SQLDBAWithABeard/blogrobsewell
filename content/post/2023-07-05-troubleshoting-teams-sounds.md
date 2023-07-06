---
title: 'Troubleshooting Teams sounds'

date: "2023-07-05"
categories:
  - Blog
  - Troubleshooting
  - Office

tags:
  - Microsoft Teams
  - Sound
  - Microphone
  - Speaker
  - Hyper-V
  - Remote Working

image: assets/uploads/2023/teams-live-captions.png
---
# Remote Working

We have spent a lot of time remote working and I was recently reminded about this troubleshooting tip that I use frequently.

When working with remote clients I am often required to be able to give access to the machine to the client to be able to install the VPN client and log into their domain. I use a Hyper-V machine on my home office desktop PC and use that.

Of course, all sound hardware is attached to my host PC and sometimes getting that to work with Teams running inside the Hyper-V can be challenging. Sometimes, I have muted the hardware either in Windows or on the device itself.

The end result is that either I can't hear people in the meeting or tey can't hear me.

But sometimes that is due to there being nobody speaking in the meeting or the issue being at the other end.

# See what Teams is hearing

This is one method that I use to try to narrow down where the issue is. Use live captions to see what Teams is "hearing". I like to use live captions, especially when working with teams of people for whom English is a second language as it is often better at cutting through the accent than I am and it also gives me a chance to read back to ensure that I have understood hte sentence correctly.

You can turn on Live Captions by clicking the 3 dots (hamburger menu) in the meeting and then `Language and speech` and `Turn on live captions` It will ask you which language the meeting is in and you are done. Now you will be able to see if other people are speaking and also if Teams is "hearing" you and troubleshoot accordingly.

[![teams live captions](assets/uploads/2023/teams-live-captions.png)](assets/uploads/2023/teams-live-captions.png)