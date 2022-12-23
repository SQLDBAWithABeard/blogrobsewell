---
title: "Those Pesky ‘s"
categories:
  - Blog

tags:
  - databases
  - development
  - document
  - documentation
  - domain
  - google
  - names
  - oracle
  - paperwork
  - script
  - scripts
  - server
  - spof

---
### Changing Domain Names in a Column

A quick little post for today. Not particularly SQL related but the points at the end are relevant.

I had a task when moving a service to a new development area to change the domain name within columns in several tables from “DOMAIN1\USER” to “DOMAIN2\USER”

In SQL I was able to do this quite easily as follows

    USE [DATABASENAME] 
    GO
    -- Declare variables 
    DECLARE @Live nvarchar(10) 
    DECLARE @Dev nvarchar(10) 
    
    -- Set the variable to the Domains 
    Set @Live = 'Live Domain' 
    Set @Dev = 'Dev Domain' 
    
    --Update tables 
    UPDATE [TABLENAME] 
    SET [User] = REPLACE([User], @Live, @Dev) 
    GO 
    UPDATE [TABLENAME] 
    SET [Group] = REPLACE([Group], @Live, @Dev) 
    GO

I also had to do the same for some Oracle databases too and this is where the fun started!

I needed to create the update scripts for documentation for the Oracle databases.

I wanted to create

    update schema.tablename set userid = replace ('DOMAIN1\USER', 'DOMAIN1', 'DOMAIN2') WHERE USERID = 'DOMAIN1\USER';

for each userid in the table.I had trouble with the script I found in our DBA area as it kept failing with

ORA-00911: invalid character

at the \

as it wouldn’t add the ‘ ‘ around DOMAIN1\USER

Not being an Oracle DBA but wanting to solve the issue once and for all I tried a whole host of solutions trying to find the escape character. i asked the Oracle DBAs but they were unable to help Checking the IT Pros handbook (also known as Google!) made me more confused but in the end I solved it.

    select 'update schema.table set userid = replace (''' || userid || ''', ''DOMAIN1'', ''DOMAIN2'') WHERE USERID = ''' || USERID || ''';' FROM schema.tablename;

A whole host of ‘s in there!!

I put this in my blog as it is relevant to my situation and an experience I have had that I couldn’t easily solve. Maybe it will help another person searching for the same thing.

It raises some interesting points

The script provided ( I use that term loosely, it had the right name and was in the right place to use for this process) had obviously not been run as it didn’t work or someone had manually added the ‘s. I wasn’t go to do that for the number of users required.

If it no good, if it doesn’t do what i expected or is still in development then mark it as so, so that everyone knows. In the name of the script, in the comments in the script or by keeping live tested scripts in one place. Which ever method you choose is fine as long as it is appropriate to your environment and everyone knows about it

I probably say a dozen times a day to my new colleague

“In case you/I get run over by a bus”

It is all very well being the one who knows everything but it is pointless if you aren’t there SPOF’s (Single Points of Failure) apply to people as well as hardware.

Enable your service to be supported by preparing proper documentation.

This doesn’t have to be reams of paperwork. It can sometimes be as simple as placing things in a recognised place or a single comment in the script.

I hold my hands up. I am guilty of this too. I have been so busy I haven’t done this as much as I should have over the last few months of last year. I have tried but not done as well as I should have. In my defence, I have spent plenty of time recently rectifying this, which is why this situation was so memorable.

Some links I have read in the past related to this by  people who know more than me.

[Documentation It Doesn’t Suck – Brent Ozar](http://www.brentozar.com/archive/2013/01/documentation-it-doesnt-suck/)

[Your Lack Of Documentation is Costing you More than you Think – John Samson](http://www.johnsansom.com/your-lack-of-documentation-is-costing-you-more-than-you-think/)

[Do You Document Your SQL Server Instances? – Brad McGhee](http://www.bradmcgehee.com/2012/06/do-you-document-your-sql-server-instances/)
