---
title: "Spinach and Database Development- SQLSatExeter Keynote"
date: "2015-04-30"
date: "2015-04-30"
categories:
  - SQL Saturday Exeter
  - Community
tags:
  - Bad Data
  - dadt
  - spinach
  - SQL Saturday Exeter
---

Last weekend, we held our SQL Saturday event in Exeter. It was a brilliant event for many reasons but we were delighted to have a world exclusive keynote video by Phil Factor about Spinach and Database Development. With many thanks to those that made it possible and particularly to Phil Factor I have linked to the video here and also transcribed it. Please watch and read and understand the message

 {{< youtube F8qLrOfncZE >}}

What has spinach got to do with Database Development?

Generations of children were fed spinach in preference to more nutritious things, such as cardboard, because of the persistence of bad data.

It wasn't in fact the decimal point error of legend but confusion over the way that iron was measured in the late 19th century data. As a result nutritionists persisted in believing for generations that it was a rich source of iron that the body needs in order to create bloodcells. In fact, the very little iron that there is in spinach isn't in a form that can be readily absorbed by the body anyway.

The consequences of bad data can be dire

Guarding the quality of your data is about the most important thing that you as a data professional can do. You may think that performance is important but it would just deliver you the wrong answer faster. Resilience? it would just make it more likely that you'd be able to deliver the wrong answer. Delivery? Yep you got it, the wrong answer quicker.

The spinach example is a good one because bad data is hard to detect and can go unnoticed for generations. This is probably because people don't inspect and challenge data as much as they should. You would have thought it strange that a vegetable like spinach should have fifty times as much iron as any other vegetable but the fact came from a very reputable source so people just shrugged and accepted it

We have a touching faith in data,

We, as a culture, assume its correct and complete, we like to believe that it's impossible that either prejudice, bias, criminality or foolishness could affect the result, worse we think that valuable truth can be sifted from any data no matter the source. If there's enough of it then there must be value in it. It's like panning for gold dust from a river. The sad truth is that this is a delusion but very common in our society. We are, in our mass culture, in the bronze age rather than the information age struggling with silvery toys imbued with mystical magical powers

A good database professional must be unequivocal.

Bad data cannot be cleaned in the same way that one can clean mud of a diamond. If data contains bad data then the entire data set must be rejected

There's no such thing as data cleansing.

You as a DBA may be asked to take out data that seems absurd such as ages that are negative or ages that are so great that the person couldn't possibly be alive but then that leaves you in the same dataset, data that is plausible but wrong.

Only in very exceptional circumstances when you know precisely why a minority of your data is wrong would you be justified in correcting it.

Statistics can help us to make very confident assertions about large datasets if they conform to one of the common distributions but they cannot tell us anything about individual items of data. You can of course remove outliers but in fact outliers are just items of data that don't conform to your assumptions about the data and the whole point of data analysis is to test your assumptions. By cleaning data, by removing outliers you can prove almost anything scientifically

A well designed database is defended in depth at every possible opportunity.

Depth is actually an interesting analogy because experience tells us that bad data seems to leak in under pressure, through every crack when the database is working hard. Like you will see in a World War 2 submarine movie, in a well-used OLTP database, we are like the crew, swivelling our eyes in terror savouring the futility of any remediation as ghastly drips run down the walls of our database and wishing we had put in more constraints.

In terms of the defence of data, check constraints and foreign key constraints are excellent of course and triggers are good but there are other ways of getting warnings of errors in data such as sudden changes in the distribution of data and other anomalies. One check I like to do is the tourism check where you check your data all the way through back to source, this technique once famously picked up the fact that a famous motor manufacturer was reporting its deceleration figures in yards per second when it should have been metres per second.

When you start putting in check constraints you say to yourself, this couldn't possibly happen. This is the voice of superstition. A famous programmer of the 1970's took to putting a message in his code saying "this error could never happen" and he put it in places where it couldn’t possibly ever be executed and the funny thing was the more he tested the programme, the more that error appeared on the screen and it is the same with constraints, the more traps you set the more critters you catch and you're left wondering how on earth all that bad data was getting in

Its misleading to go on about the value of the great flood of big data. There's a strong superstition that data has some sort of intrinsic mystical value all of its own.

Unless you can prove that data is correct its valueless because if you trust it you can end up with generations of children compelled to eat spinach for no good reason at all.
