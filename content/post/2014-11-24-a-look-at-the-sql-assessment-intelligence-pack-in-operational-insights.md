---
title: "A look at the SQL Assessment Intelligence Pack in Operational Insights"
date: "2014-11-24" 
categories:
  - azure
  - Blog

tags:
  - azure
  - SQL Assessment
  - Operational Insights
  - SCOM


image: /assets/uploads/2014/11/opsman1.jpg
---
Operational Insights is a service that has been added in preview to Azure. It enables you to collect, combine, correlate and visualize all your machine data in one place. It can collect data from all of your machines either via SCOM or by using an agent. Once the data is collected Operational Insights has a number of Intelligence Packs which have pre-configured rules and algorithms to provide analysis in various areas including for SQL Server

[http://azure.microsoft.com/en-gb/services/operational-insights/](http://azure.microsoft.com/en-gb/services/operational-insights/)

I thought I would take a look. I have an installation of SCOM in my lab on my laptop and I read the instructions to see how to connect it to Operational Insights. (You don’t have to have a SCOM installation to use Operational insights you can make use of an agent as well just follow the steps from the page below)

[http://azure.microsoft.com/en-us/trial/operational-insights-get-started/](http://azure.microsoft.com/en-us/trial/operational-insights-get-started/)

It really is very simple

If you have an Azure subscription already you can sign into the portal and join the preview program by clicking

New –> App Services –> Operational Insights

and create a new Operational Insights Workspace.

Once you have done that, if you have an installation of SCOM 2012 you need to be running Service Pack 1 and download and install the System Center Operational Insights Connector for Operations Manager and import the MPB files into SCOM.

If you have SCOM 2012R2 the connector is already installed and to connect your SCOM to Operational Insights is very very easy as you can see on

[http://azure.microsoft.com/en-us/trial/operational-insights-get-started/?step2=withaccount&step3=SCOMcustomer](http://azure.microsoft.com/en-us/trial/operational-insights-get-started/?step2=withaccount&step3=SCOMcustomer)

1.  In the Operations Manager Console, click Administration.
2.  Under Administration, select System Center Advisor, and then click Advisor Connection.
3.  Click Register to Advisor Service.
4.  Sign in with your Microsoft or Organizational account.
5.  Choose an existing Operational Insights workspace from the drop down menu
6.  Confirm your changes.
7.  In the System Center Advisor Overview page, Under Actions, click Add a Computer/Group.
8.  Under Options, select Windows Server or All Instance Groups, and then search and add servers that you want data

That is it. No really, that is it. I was amazed how quickly I was able to get this done in my lab and it would not take very long in a large implementation of SCOM either as you will have your groups of computers defined which will make it easy to decide which groups to use. You could use a separate workspace for each type of server or split up the information per service. It really is very customisable.

Once you have done that, go and add some of the Intelligence Packs. Each intelligence pack will change the amount  and type of data that is collected. At November 23rd there are

- Alert Management – for your SCOM Alerts
- Change Tracking – Tracking Configuration Changes
- Log Management – for event log collection and interrogation
- System Update Assessment – Missing Security Updates
- Malware Assessment – Status of Anti-Malware and Anti-Virus scans
- Capacity Planning – Identify Capacity and Utilisation bottlenecks
- SQL Assessment – The risk and health of SQL Server Environment

There are also two ‘coming soon’ Intelligence packs

- AD Assessment – Risk and health of Active Directory
- Security – Explore security related data and help identify security breaches

You then (if you are like me) have a period of frustration whilst you wait for all of the data to be uploaded and aggregated but once it is you sign into the Operational Insights Portal

[https://preview.opinsights.azure.com](https://preview.opinsights.azure.com) and it will look like this

[![opsman1](https://blog.robsewell.com/assets/uploads/2014/11/opsman1.jpg)](https://blog.robsewell.com/assets/uploads/2014/11/opsman1.jpg)

There is a lot of information there. As it is on my laptop and the lab is not running all of the time and is not connected to the internet most of the time I am not surprised that there are some red parts to my assessment!!

Obviously I was interested in the SQL Assessment and I explored it a bit further

Clicking on the SQL Assessment tile takes you to a screen which shows the SQL Assessment broken down into 6 Focus areas

Security and Compliance, Availability and Business Continuity, Performance and Scalability, Upgrade, Migration and  Deployment, Operations and Monitoring and Change and Configuration Management. MSDN [http://msdn.microsoft.com/en-us/library/azure/dn873967.aspx](http://msdn.microsoft.com/en-us/library/azure/dn873967.aspx?WT.mc_id=DP-MVP-5002693) gives some more information about each one

- **Security and Compliance** – Safeguard the reputation of your organization by defending yourself from security threats and breaches, enforcing corporate policies, and meeting - technical, legal and regulatory compliance requirements.
- **Availability and Business Continuity** – Keep your services available and your business profitable by ensuring the resiliency of your infrastructure and by having the right - level of business protection in the event of a disaster.
- **Performance and Scalability** – Help your organization to grow and innovate by ensuring that your IT environment can meet current performance requirements and can respond - quickly to changing business needs.
- **Upgrade, Migration and Deployment** – Position your IT department to be the key driver of change and innovation, by taking full advantage of new enabling technologies to - unlock more business value for organizational units, workforce and customers.
- **Operations and Monitoring** – Lower your IT maintenance budget by streamlining your IT operations and implementing a comprehensive preventative maintenance program to - maximize business performance.
- **Change and Configuration Management** – Protect the day-to-day operations of your organization and ensure that changes won’t negatively affect the business by establishing change control procedures and by tracking and auditing system configurations.

You will be able to see some dials showing you how well you are doing in each area for the servers whose data has been collected.

[![opsman2](https://blog.robsewell.com/assets/uploads/2014/11/opsman2.jpg)](https://blog.robsewell.com/assets/uploads/2014/11/opsman2.jpg)

Each area will have the High Priority Recommendations shown below the dial and you can click on them to see more information about those recommendations

[![opsman3](https://blog.robsewell.com/assets/uploads/2014/11/opsman3.jpg)](https://blog.robsewell.com/assets/uploads/2014/11/opsman3.jpg)

You can also click the dial or the see all link to enter the search area where you can customise how you wish to see the data that has been collected, this looks a bit confusing at first

[![opsman4](https://blog.robsewell.com/assets/uploads/2014/11/opsman4.jpg)](https://blog.robsewell.com/assets/uploads/2014/11/opsman4.jpg)

The top bar contains the search , the timescale and some buttons to save the search, view the saved searches and view the search history, all of which will be shown in the right hand column below

The left column contains a bar graph for the search and all of the filters. The middle column contains the results of the search and can be viewed in list or tabular format and exported to CSV using the button below. A little bit of experimentation will give you a better understanding of how the filtering works and how you can make use of that for your environment

By looking at the search for the Operations and Monitoring Focus Area shown above

> Type:SQLAssessmentRecommendation IsRollup=true RecommendationPeriod=2014-11 FocusArea=”Operations and Monitoring” RecommendationResult=Failed | sort RecommendationWeight desc

I saw that `RecommendationResult=Failed` and changed it to `RecommendationResult=Passed`. This enabled me to see all of the Recommendations that had been passed in the Focus Area and clicking the export button downloaded a csv file. I deleted `RecommendationResult=Passed` from the search and that gave me all of the recommendations that made up that Focus Area

- Operations and Monitoring Focus Area
- Recommendation
- Enable Remote Desktop on servers.
- Enable Remote Desktop on virtual machines.
- Ensure computers are able to download updates.
- Configure event logs to overwrite or archive old events automatically.
- Review event log configuration to ensure event data is retained automatically. This relates to System Logs
- Review event log configuration to ensure event data is retained automatically. This relates to Application Logs

I decided then to do the same for each of the Focus Areas for the SQL Assessment Intelligence Pack

Security and Compliance Focus Area  
Recommendation
- Change passwords that are the same as the login name.
- Remove logins with blank passwords.
- LAN Manager Hash for Passwords Stored
- Investigate why unsigned kernel modules were loaded.
- Apply security best practices to contained databases.
- Enable User Account control on all computers.
- Consider disabling the xp_cmdshell extended stored procedure.
- Implement Windows authentication on Microsoft Azure-hosted SQL Server deployments.
- Avoid using the Local System account to run the SQL Server service.
- Avoid adding users to the db_owner database role.
- Ensure only essential users are added to the SQL Server sysadmin server role.
- Disable SQL Server guest user in all user databases.
- Avoid running SQL Server Agent jobs using highly-privileged accounts.
- Configure the SQL Server Agent service to use a recommended account.
- Apply Windows password policies to SQL Server logins.
- Investigate failures to validate the integrity of protected files.
- Investigate failures to validate kernel modules.  

Availability and Business Continuity Focus Area  
Recommendation
- Schedule full database backups at least weekly.
- Optimize your backup strategy with Microsoft Azure Blob Storage.
- Avoid using the Simple database recovery model.
- Ensure all installations of Windows are activated.
- Investigate logical disk errors.
- Reduce the maximum Kerberos access token size.
- Investigate connection failures due to SSPI context errors.
- Set the PAGE_VERIFY database option to CHECKSUM.
- Increase free space on system drives.
- Investigate a write error on a disk.
- Check the network access to Active Directory domain controllers.
- Review DNS configuration on non-DNS servers.
- Increase free space on system drives.
- Investigate memory dumps.
- Increase free space on system drives.
- Investigate why the computer shut down unexpectedly.
- Enable dynamic DNS registration for domain-joined servers.  

Performance and Scalability Focus Area  
Recommendation
- Increase the number of tempdb database files.
- Configure the tempdb database to reduce page allocation contention.
- Ensure all tempdb database files have identical initial sizes and growth increments.
- Set autogrowth increments for database files and log files to fixed values rather than percentage values.
- Set autogrowth increments for transaction log files to less than 1GB.
- Modify auto-grow settings to use a fixed size growth increment of less than 1GB and consider enabling Instant File Initialization.
- Change your Affinity Mask and Affinity I/O MASK settings to prevent conflicts.
- Resolve issues caused by excessive virtual log files.
- Modify the database file layout for databases larger than 1TB.
- Set the AUTO_CLOSE option to OFF for frequently accessed databases.
- Review memory requirements on servers with less than 4GB of physical memory installed.
- Configure system SiteName properties to be dynamic.
- Align the Max Degree of Parallelism option to the number of logical processors.
- Align the Max Degree of Parallelism option to the number of logical processors.
- Consider disabling the AUTO_SHRINK database option.
- Review memory requirements on computers with high paging file use.
- Ensure SQL Server does not consume memory required by other applications and system components.
- Consider changing your power saving settings to optimize performance.
- Increase the initial size of the tempdb database.
- Review the configuration of Maximum Transfer Unit (MTU) size.
- Review your paging file settings.
- Review and optimize memory cache configuration.
- Review the configuration of Maximum Transfer Unit (MTU) size.
- Review the system processor scheduling mode.
- Review network provider ordering settings.
- Remove invalid entries from the PATH environment variable.
- Remove network entries from the PATH environment variable.
- Investigate processes that use a large number of threads.
- Avoid hosting user database files on the same disk volume as tempdb database files.
- Review processes with large working set sizes.
- Reduce the length of the PATH environment variable.
- Reduce the number of entries in the PATH environment variable.
- Ensure SQL Server does not consume memory required by other applications and system components.
- Enable the backup compression default configuration option.
- Ensure the DNS Client service is running and is set to start automatically.
- Consider compressing database tables and indexes.

Upgrade, Migration and Deployment Focus Area  
Recommendation
- Ensure all devices run supported operating system versions.
- Ensure that the guest user is enabled in the msdb database.
- Avoid using the Affinity64 Mask configuration setting in new development work.
- Avoid using the Affinity Mask configuration setting in new development work.
- Avoid using the Affinity I/O Mask configuration setting in new development work.
- Avoid using the Allow Updates configuration option in SQL Server.
- Avoid using the Allow Updates configuration option in SQL Server.
- Avoid using the Affinity64 I/O Mask configuration setting in new development work.
- Configure SQL Server to accept incoming connections.
- Configure SQL Server instances and firewalls to allow communication over TCP/IP.

As I have no data for Change and Configuration Management I was not able to see the recommendations in my Operation Insights Workspace.

Edit: Daniele Muscetta has said in the comments that this is a bug which is being tracked

As you can see from the type and description of the recommendations above these are all areas that a DBA will be concerned about and the benefit of having all of this information gathered, pre-sorted, prioritised and presented to you in this manner will enable you to work towards a better SQL environment and track your progress. You can read more about the SQL Assessment Intelligence Pack here

[http://msdn.microsoft.com/en-us/library/azure/dn873958.aspx](http://msdn.microsoft.com/en-us/library/azure/dn873958.aspx?WT.mc_id=DP-MVP-5002693)

As well as the pre-determined queries that are built into the Intelligence pack you can search your data in any way that you require enabling you to present information about the health and risk of your SQL Environment to your team or your management with ease. The “with ease” bit is dependent on you understanding the language and structure of the search queries.

You will need to put this page into your bookmarks

[http://msdn.microsoft.com/library/azure/dn873997.aspx](http://msdn.microsoft.com/library/azure/dn873997.aspx?WT.mc_id=DP-MVP-5002693)

As it contains the syntax and definitions to search your data

A very useful page for a starter like me is

[http://blogs.msdn.com/b/dmuscett/archive/2014/10/19/advisor-searches-collection.aspx](http://blogs.msdn.com/b/dmuscett/archive/2014/10/19/advisor-searches-collection.aspx?WT.mc_id=DP-MVP-5002693)

by Daniele Muscetta which has a list of useful Operational Insights search queries such as

> **SQL Recommendation by Computer**
> 
> Type=SQLAssessmentRecommendation IsRollup=false RecommendationResult=Failed | measure count() by Computer

If you click the star to the right of the search box you will find the saved searches. For the SQL Assessment Intelligence Pack there are

Did the agent pass the prerequisite check (if not, SQL Assessment data won’t be complete) 

Focus Areas  
- How many SQL Recommendation are affecting a Computer a SQL Instance or a - Database?  
- How many times did each unique SQL Recommendation trigger?  
- SQL Assesments passed by Server  
- SQL Recommendation by Computer  
- SQL Recommendation by Database  
- SQL Recommendation by Instance

You can use these and you can save your own searches which show the data in a way that is valuable to you.

Overall I am impressed with this tool and can see how it can be beneficial for a DBA as well as for System Administrators. I was amazed how easy it was to set up and how quickly I was able to start manipulating the data once it had been uploaded.
