---
title: "Training Day Speakers List"
date: "2022-07-10"
categories:
  - Blog
  - Community

tags:
 - Blog
 - Community
 - Automation
 - speaking
 - pre-con
 - training day
 - GitHub Actions


image: assets/uploads/2022/magnify.jpg
---

How do data platform events find Training Day/Pre-Con speakers?

[So we built a thing for speakers to add themselves and for events to find them](https://callfordataspeakers.com/precon)

I think event organisers know who the _big names_ are and the topics that they can deliver for full day training sessions or pre-cons as they are also known. Finding other speakers and finding speakers who can deliver on different topics is a little more difficult.

# Hey New Speakers

With all the _*waves hand at world for the last 2 years_ going on, there are a number of new speakers who have taken advantage of virtual events like [New Stars Of Data](https://www.newstarsofdata.com/), [DatiVerse](https://datagrillen.com/dativerse/) and other events that have helped to promote and support new speakers. This is truly awesome and I love seeing the pool of speakers growing and all the new voices enriching our learning.

There are undoubtedly speakers who have content and can provide full day seesions that events and attendees will gladly have if only the organisers knew about the content and/or the speakers knew about the events.

# Events want your content

This came up on social media and after a quick conversation with Daniel Hutmacher ([Twitter](https://twitter.com/dhmacher) [Blog](https://sqlsunday.com/)) we decided to create a resource page that can be found on [Call For Data Speakers](https://callfordataspeakers.com).

Call For Data Speakers enables speakers to sign up to receive an email when a new event is announced. It also enables events to sign up, so that speakers can be notified when there is a call for speakers. So this seemed to be the obvious place to hold a list of speakers that event organisers can contact and show the topics that they can present full day or training day sessions on.

# YES even you. Please join.

I have created some automation that will make adding (and removing) yourself from this list easy to do. You can just go straight to [the repo](https://github.com/dataplat/DataSpeakers) and follow the instructions if you dont want to read any more here.

I see this as a resource for everybody, famouse or not, new or old. I absolutely want **you to add yourself**, if you have content that can be used to provide a full day of training. Please don't let imposter syndrome get in the way. Right now, all you are doing is listing your idea for people to see. Hopefully soon event organisers will get in touch and say hey I see you present on ... please would you submit to our event for a training day.

Event organisers - You **do need to reach out to speakers**. By adding some effort into finding speakers your event will be more rounded and of interest and benefit to a wider numebr of attendees and sponsors. I am talking about pre-con speakers here bu the same applies to general sessions.

# How do I do it?

This process is all automated and driven by GitHub Issues.

## To add yourself as a speaker

Open the [Issues Page](https://github.com/dataplat/DataSpeakers/issues) and click new issue.


![open a new issue](https://raw.githubusercontent.com/dataplat/DataSpeakers/main/images/newissue.png)

Click the get started button next to Add Speaker.

![empty issue](https://raw.githubusercontent.com/dataplat/DataSpeakers/main/images/emptyissue.png)

Fill in the details, the title can be anything that you like -

- Your full name
- topics you can provide training days or pre-cons for (dbatools, Index Tuning, DevOps for example) Add as many as you like.
    **Just topics** not session titles or descriptions, those will be in your sessionize profile then this resource does not need updating so frequently. It is after all just a "Here I am, come find me" resource.
- regions that you would be willing to present training days or pre-cons in (these match the regions on callfordataspeakers.com)
- Your sessionize profile URl which will show the event organisers the precise sessions that you have and also your contact details/methods

![new speaker info](https://raw.githubusercontent.com/dataplat/DataSpeakers/main/images/filledinsessions.png)

Thats it, then press Submit new issue and the automation will do its thing

# What does it look like?

A GitHub Action will run and [the web-page](https://callfordataspeakers.com/precon) will be updated.

You can then search for topics, regions, click on any topic to see all the speakers that are happy to present on that topic.

Click on a speaker and you will be directed to their Sessionize profile page.

Here is a quick look at the demo page after I had some test data in there!

![PreConSpeakers](assets/uploads/2022/07/callfordataprecons.png)

# What else can I do?

Please promote this resource. It will have no benefit if speakers do not add themselves and event organisers do not know about it.

I would be really happy if you can keep this in mind if you are organising a data platform event, let any speakers know that this exists so that they can add themselves, share it on social media.

Many Thanks.
