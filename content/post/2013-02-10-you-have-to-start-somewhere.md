---
title: "You Have To Start Somewhere"
date: "2013-02-10" 
categories:
  - Blog
tags:
  - The Start
  - automate
  - automation
  - blogging
  - oracle
  - PowerShell
  - sql dba
  - SQL Server
  - SQLBrit


image: assets/uploads/2013/02/medium_33194896_thumb.jpg
---

![medium_33194896]({{ "/assets/uploads/2013/02/medium_33194896_thumb.jpg" | relative_url }})

The hardest part is looking at the blank page and beginning to type. It’s much easier to go and play with the settings of the site, to look at plugins and other cool things. The only other blog I have written was [http://wombatsdojogle.wordpress.com](http://wombatsdojogle.wordpress.com). This was a little easer as there was always ‘something’ that needed to be written about. Whether it was training or route planning or every day on the road I had material and an obvious thing to write.

This is a little harder for me so I will begin as follows

During different careers working in secure units, working for a small family firm doing everything from delivery driving to office work and working for myself selling things via eBay and at car boot sales I have always been interested in computers. I was (still am) the fella who could fix and sort things out. Towards the end I was getting paid for it too. I helped small businesses and individuals, I set up systems, reinstalled operating systems, dealt with viruses. You know the sort of thing. When things dried up and circumstances changed meaning I could spend some time away from home I got a job at an arts university. In a small team my responsibilities ranged from password resets and printer installs to rolling out new PCs and laptops and helping to merge active directory domains. I loved it. The travel too and from work was a pain at times but the job was grand though the pay wasn’t!!

I joined MyWork in a service desk role. Not your typical log and flog sort of place but a 24/7 team responsible for the first answering of the phone to a significant amount of second line fixing and routine IT tasks invaluable to the running of MyWork. A couple of years later after many suggestions of jobs I should apply for and plenty of encouragement from colleagues I applied for and got the position of Oracle DBA. That didn’t work out quite as expected and two months later I was asked to move to be a SQL DBA. That was 18 months ago and I am astonished by how much I have learnt so far and still slightly daunted by the sheer amount there still is to learn.

The reason I was asked to move is that responsibility for the SQL estate had moved to the team and the one SQL DBA was struggling with the sheer amount of work required. He had joined only a few months earlier and found that best practice and SQL had not been applied particularly well and with more than 700 databases to support he couldn’t keep up.

He and I began to make changes. Permissions for developers were removed – no more sysadmins for developers on live systems. Backups were run 7 days a week and checked every day. Service accounts were set up to run the various SQL services per server. Documentation was begun. All the good things that should be done were started to be done.

There were arguments and outbursts. Developers took time to understand that we were doing things for the best of MyWork and not to annoy them or stop them working. We got things wrong for sure. We didn’t communicate well with colleagues in other teams at times but we had the backing of our line management.

Then my colleague left to go to pastures new. I had been a SQL DBA for exactly 6 months and I was on my own. Then my line manager left so I had to look after the general maintenance of the Oracle estate as well. There are also some Ingres databases critical to MyWork and they were my responsibility as well.

For a few months I somehow managed to keep everything going without making any major booboos. It was a struggle. I was fighting my lack of knowledge, the sheer amount of work and running much too hard on caffeine and nicotine. At the end of last year some salvation arrived. First an Oracle DBA joined then a team lead (also an Oracle DBA) and another SQL DBA. Not the many years experienced SQL DBA I had hoped for who could advise me and teach me but I sure am glad he’s here.

In the last few weeks I am beginning to see the benefit of this. No longer on call all the time. Not as much fire fighting. Able to plan my day instead of walking in and dealing with whoever or whatever was shouting loudest. I was finally able to go to the local SQL User Group for the first time last month.

[http://sqlsouthwest.co.uk/](http://sqlsouthwest.co.uk/)

and meet up with some fabulous people.

I decided to start to write a blog about my experience. I hope it will show me how far I have come, how much I have learnt and the way I have done it. It may be of use to people and hopefully it will increase my interaction with the rest of the SQL community who are without doubt the most interactive and helpful group of people mainly without egos.

I have an idea of my next post. It will be about resolving the challenge and time spent checking and resolving backups.

The idea for it started with reading a blog post by John Samson [http://www.johnsansom.com](http://www.johnsansom.com) who can be found on twitter [@SQLBrit](https://twitter.com/SqlBrit)

The blog post is one of the most read on his blog and is titled

### [The Best Database Administrators Automate Everything](http://www.johnsansom.com/the-best-database-administrators-automate-everything/)

Here is a quote from that blog entry

> #### Automate Everything
> 
> That’s right, I said everything. Just sit back and take the _time_ to consider this point for a moment. Let it wander around your mind whilst you consider the processes and tasks that you could look to potentially automate. Now eliminate the word _potentially_ from your vocabulary and evaluate how you could automate **e-v-e-r-y-t-h-i-n-g** that you do.
> 
> Even if you believe that there is only a remote possibility that you will need to repeat a given task, just go ahead and automate it anyway! Chances are that when the need to repeat the process comes around again, you will either be under pressure to get it done, or even better have more important_Proactive Mode_ tasks/projects to be getting on with

I have tried my best to follow this advice. I haven’t always succeeded. Many times I just didn’t have the time to spare to write the automation even though it would save me time later. Now with more assistance in my team I am starting to resolve that

My interest in PowerShell, which was piqued when I wanted to organise my photos and a colleague pointed me at a script to sort my photos into year and month, encouraged me to create my favourite automation process which I will describe next time.

photo credit: [emdot](http://www.flickr.com/photos/emdot/33194896/) via [photopin](http://photopin.com) [cc](http://creativecommons.org/licenses/by/2.0/)
