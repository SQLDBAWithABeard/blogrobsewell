---
title: "Getting SQL Services, Starting, Stopping and Restarting them with dbatools"
date: "2018-12-03"
categories:
  - Blog

tags:
  - automation
  - dbatools
  - PowerShell
  - services
  - slack

---
There was a question in the [#dbatools slack channel ](https://sqlcommunity.slack.com/#dbatools)

[![dbatools question](https://blog.robsewell.com/assets/uploads/2018/12/dbatools-question.png)](https://blog.robsewell.com/assets/uploads/2018/12/dbatools-question.png)

### Getting dbatools

dbatools enables you to administer SQL Server with PowerShell. To get it simply open PowerShell run

`Install-Module dbatools`

You can find more details on [the web-site](http://dbatools.io/install)

### Finding the Command

To find a command you can use the dbatools command [Find-DbaCommand](https://docs.dbatools.io/#Find-DbaCommand)
For commands for service run

`Find-DbaCommand Service`

There are a whole bundle returned

[![find services.png](https://blog.robsewell.com/assets/uploads/2018/12/find-services.png)](https://blog.robsewell.com/assets/uploads/2018/12/find-services.png)

This is how you can find any dbatools command. There is also a -Tag parameter on Find-DbaCommand.

`Find-DbaCommand -Tag Service`

This returns

[![find services tag.png](https://blog.robsewell.com/assets/uploads/2018/12/find-services-tag.png)](https://blog.robsewell.com/assets/uploads/2018/12/find-services-tag.png)

### How to use any PowerShell command

Always always start with `Get-Help`

`Get-Help Get-DbaService -Detailed`

[![get help.png](https://blog.robsewell.com/assets/uploads/2018/12/get-help.png)](https://blog.robsewell.com/assets/uploads/2018/12/get-help.png)

This will show you all the information about the command including examples 🙂

[![help examples.png](https://blog.robsewell.com/assets/uploads/2018/12/help-examples.png)](https://blog.robsewell.com/assets/uploads/2018/12/help-examples.png)

All of these commands below require that the account running the PowerShell is a Local Admin on the host.

### One Host Many Hosts

Now I have used just one host for all of the examples on this page. Do not be fooled, you can always use an array of hosts wherever I have $ComputerName you can set it to as many hosts as you like

`$ComputerName = 'SQL0','SQL1'`

You can even get those names form a database, Excel sheet, CMS.

### Getting the Services

So to get the services on a machine run
```
$ComputerName = 'Name of Computer'
Get-DbaService -ComputerName $ComputerName
```
[![getting servies 1.png](https://blog.robsewell.com/assets/uploads/2018/12/getting-servies-1.png)](https://blog.robsewell.com/assets/uploads/2018/12/getting-servies-1.png)

You can output into a table format.

`Get-DbaService -ComputerName $ComputerName | Format-Table`

I will use the alias `ft` for this in some of the examples, that is fine for the command line but use the full command name in any code that you write that other people use

[![services table.png](https://blog.robsewell.com/assets/uploads/2018/12/services-table.png)](https://blog.robsewell.com/assets/uploads/2018/12/services-table.png)

You have an object returned so you can output to anything if you want – CSV, JSON, text file, email, azure storage, database, the world is your oyster.

### Getting the Services for one instance

The [Get-DbaService](https://docs.dbatools.io/#Get-DbaService) command has a number of parameters. There is an InstanceName parameter enabling you to get only the services for one instance. If we just want the default instance services

`Get-DbaService -ComputerName $ComputerName -InstanceName MSSQLSERVER| Format-Table`

[![default instances.png](https://blog.robsewell.com/assets/uploads/2018/12/default-instances.png)](https://blog.robsewell.com/assets/uploads/2018/12/default-instances.png)

Just the MIRROR instance services

`Get-DbaService -ComputerName $ComputerName -InstanceName MIRROR| Format-Table`

[![mirror instances.png](https://blog.robsewell.com/assets/uploads/2018/12/mirror-instances.png)](https://blog.robsewell.com/assets/uploads/2018/12/mirror-instances.png)

### Getting just the Engine or Agent services

You can also use the -Type parameter to get only services of a particular type. You can get one of the following: “Agent”,”Browser”,”Engine”,”FullText”,”SSAS”,”SSIS”,”SSRS”, “PolyBase”

So to get only the Agent Services

`Get-DbaService -ComputerName $ComputerName -Type Agent`

[![agent services.png](https://blog.robsewell.com/assets/uploads/2018/12/agent-services.png)](https://blog.robsewell.com/assets/uploads/2018/12/agent-services.png)

You can combine the InstanceName and the Type parameters to get say only the default instance engine service

`Get-DbaService -ComputerName $ComputerName -InstanceName MSSQLSERVER -Type Engine`

[![default engine service.png](https://blog.robsewell.com/assets/uploads/2018/12/default-engine-service.png)](https://blog.robsewell.com/assets/uploads/2018/12/default-engine-service.png)

### Starting and stopping and restarting services

You can use [`Start-DbaService`](https://docs.dbatools.io/#Start-DbaService) and [`Stop-DbaService`](https://docs.dbatools.io/#Stop-DbaService) to start and stop the services. They each have `ComputerName`, `InstanceName `and `Type `parameters like `Get-DbaService`.

So if after running

`Get-DbaService -ComputerName $ComputerName | Format-Table`

you find that all services are stopped

[![all stopped.png](https://blog.robsewell.com/assets/uploads/2018/12/all-stopped.png)](https://blog.robsewell.com/assets/uploads/2018/12/all-stopped.png)

### Start All the Services

You can run

`Start-DbaService -ComputerName $ComputerName | Format-Table`

and start them all

[![start them all.png](https://blog.robsewell.com/assets/uploads/2018/12/start-them-all.png)](https://blog.robsewell.com/assets/uploads/2018/12/start-them-all.png)

The full text service was started with the engine service which is why it gave a warning. You can see this if you have all of the services stopped and just want to start the engine services with the type parameter.
```
Get-DbaService -ComputerName $ComputerName | Format-Table
Start-DbaService -ComputerName $ComputerName -Type Engine
Get-DbaService -ComputerName $ComputerName | Format-Table
```
[![all stopped - start engine.png](https://blog.robsewell.com/assets/uploads/2018/12/all-stopped-start-engine.png)](https://blog.robsewell.com/assets/uploads/2018/12/all-stopped-start-engine.png)

If you just want to start the Agent services, you can use

`Start-DbaService -ComputerName $ComputerName -Type Agent`

[![start agent.png](https://blog.robsewell.com/assets/uploads/2018/12/start-agent.png)](https://blog.robsewell.com/assets/uploads/2018/12/start-agent.png)

You can start just the services for one instance

`Start-DbaService -ComputerName $ComputerName -InstanceName MIRROR`

[![start instance services.png](https://blog.robsewell.com/assets/uploads/2018/12/start-instance-services.png)](https://blog.robsewell.com/assets/uploads/2018/12/start-instance-services.png)

### Stopping the services

Stopping the services works in the same way. Lets stop the MIRROR instance services we have just started. This will stop the services for an instance

`Stop-DbaService -ComputerName $ComputerName -InstanceName MIRROR`

[![stopping instance services.png](https://blog.robsewell.com/assets/uploads/2018/12/stopping-instance-services.png)](https://blog.robsewell.com/assets/uploads/2018/12/stopping-instance-services.png)

We can stop them by type as well, although this will show an extra requirement. If we start our MIRROR instance services again and then try to stop just the engine type.
```
Start-DbaService -ComputerName $ComputerName -InstanceName MIRROR | ft
Stop-DbaService -ComputerName $ComputerName -Type Engine
```
[![cant stop.png](https://blog.robsewell.com/assets/uploads/2018/12/cant-stop.png)](https://blog.robsewell.com/assets/uploads/2018/12/cant-stop.png)

You will get a warning due to the dependant services

> WARNING: \[10:31:02\]\[Update-ServiceStatus\] (MSSQL$MIRROR on SQL0) The attempt to stop the service returned the following error: The service cannot be stopped because other services that are running are dependent on it.
> WARNING: \[10:31:02\]\[Update-ServiceStatus\] (MSSQL$MIRROR on SQL0) Run the command with ‘-Force’ switch to force the restart of a dependent SQL Agent

So all you have to do is use the force Luke (or whatever your name is!)

`Stop-DbaService -ComputerName $ComputerName -Type Engine -Force`

[![Use the force.png](https://blog.robsewell.com/assets/uploads/2018/12/Use-the-force.png)](https://blog.robsewell.com/assets/uploads/2018/12/Use-the-force.png)

You can also stop the services for an entire host, again you will need the Force parameter.
```
Start-DbaService -ComputerName $ComputerName |ft
Stop-DbaService -ComputerName $ComputerName -Force | ft
```
[![stop all of them.png](https://blog.robsewell.com/assets/uploads/2018/12/stop-all-of-them.png)](https://blog.robsewell.com/assets/uploads/2018/12/stop-all-of-them.png)

### Restarting Services

It will come as no surprise by now to learn that [`Restart-DbaService`](https://docs.dbatools.io/#Restart-DbaService) follows the same pattern. It also has `ComputerName`, `InstanceName` and `Type` parameters like `Get-DbaService`, `Start-DbaService` and `Stop-DbaService` (Consistency is great, It’s one of the things that is being worked on towards 1.0 as you can see in the [Bill of Health](https://sqlcollaborative.github.io/boh.html))

Again you will need the `-Force` for dependant services, you can restart all of the services on a host with

`Restart-DbaService -ComputerName $ComputerName -Force`

[![restart tehm all.png](https://blog.robsewell.com/assets/uploads/2018/12/restart-tehm-all.png)](https://blog.robsewell.com/assets/uploads/2018/12/restart-tehm-all.png)

or just the services for an instance

`Restart-DbaService -ComputerName $ComputerName -InstanceName MIRROR -Force`

[![restart instance.png](https://blog.robsewell.com/assets/uploads/2018/12/restart-instance.png)](https://blog.robsewell.com/assets/uploads/2018/12/restart-instance.png)

or just the Agent Services

`Restart-DbaService -ComputerName $ComputerName -Type Agent`

[![restart agent.png](https://blog.robsewell.com/assets/uploads/2018/12/restart-agent.png)](https://blog.robsewell.com/assets/uploads/2018/12/restart-agent.png)

### Doing a bit of coding

Now none of that answers @g-kannan’s question. Restarting only services with a certain service account.

With PowerShell you can pipe commands together so that the results of the first command are piped into the second. So we can get all of the engine services on a host for an instance with `Get-DbaService` and start them with `Start-DbaService` like this

`Get-DbaService -ComputerName $ComputerName -Type Engine | Start-DbaService`

[![start.png](https://blog.robsewell.com/assets/uploads/2018/12/start.png)](https://blog.robsewell.com/assets/uploads/2018/12/start.png)

or get all of the engine services for an instance on a host and stop them

`Get-DbaService -ComputerName $ComputerName -Type Engine  -InstanceName Mirror| Stop-DbaService`

[![stop one isntance.png](https://blog.robsewell.com/assets/uploads/2018/12/stop-one-isntance.png)](https://blog.robsewell.com/assets/uploads/2018/12/stop-one-isntance.png)

or maybe you want to get all of the service that have stopped

`(Get-DbaService -ComputerName $ComputerName -Type Engine).Where{$_.State -eq 'Stopped'}`

[![stopped services.png](https://blog.robsewell.com/assets/uploads/2018/12/stopped-services.png)](https://blog.robsewell.com/assets/uploads/2018/12/stopped-services.png)

You can do the same thing with syntax that may make more sense to you if you are used to T-SQL as follows

`(Get-DbaService -ComputerName $ComputerName -Type Engine) | Where State -eq 'Stopped'`

[![T SQL syntax powershell.png](https://blog.robsewell.com/assets/uploads/2018/12/T-SQL-syntax-powershell.png)](https://blog.robsewell.com/assets/uploads/2018/12/T-SQL-syntax-powershell.png)

and then start only those services you could do

`(Get-DbaService -ComputerName $ComputerName -Type Engine) | Where State -eq 'Stopped' | Start-DbaService`

[![start the stopped ones.png](https://blog.robsewell.com/assets/uploads/2018/12/start-the-stopped-ones.png)](https://blog.robsewell.com/assets/uploads/2018/12/start-the-stopped-ones.png)

(note – you would just use `Start-DbaService` in this case as it wont start services that are already started!)
```
\# Stop just one of the engine services
Stop-DbaService -ComputerName $ComputerName -InstanceName MIRROR -Type Engine
\# Get the engine services
Get-DbaService -ComputerName $ComputerName -Type Engine
\# This will only start the one engine service that is stopped
Start-DbaService -ComputerName $ComputerName -Type Engine
```
[![only one service.png](https://blog.robsewell.com/assets/uploads/2018/12/only-one-service.png)](https://blog.robsewell.com/assets/uploads/2018/12/only-one-service.png)

### Come On Rob! Answer the question!

So now that you know a lot more about these commands, you can restart only the services using a particular service account by using Get-DbaService to get the services

`Get-DbaService -ComputerName $ComputerName -Type Engine | Where StartName -eq 'thebeard\\sqlsvc'`

[![services by start name.png](https://blog.robsewell.com/assets/uploads/2018/12/services-by-start-name.png)](https://blog.robsewell.com/assets/uploads/2018/12/services-by-start-name.png)

and then once you know that you have the right ‘query’ you can pipe that to `Restart-DbaService` (Like making sure your `SELECT` query returns the correct rows for your `WHERE` clause before running the `DELETE` or `UPDATE`)

`Get-DbaService -ComputerName $ComputerName -Type Engine | Where StartName -eq 'thebeard\\sqlsvc' | Restart-DbaService`

[![restarting only one.png](https://blog.robsewell.com/assets/uploads/2018/12/restarting-only-one.png)](https://blog.robsewell.com/assets/uploads/2018/12/restarting-only-one.png)

Happy Automating !

