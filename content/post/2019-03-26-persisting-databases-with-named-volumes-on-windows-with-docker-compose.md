---
title: "Persisting databases with named volumes on Windows with docker compose"
date: "2019-03-26" 
categories:
  - Blog

tags:
  - containers
  - docker
  - volumes


image: assets/uploads/2019/03/image-27.png

---
With all things containers I refer to my good friend Andrew Pruski. Known as [dbafromthecold on twitter](https://twitter.com/dbafromthecold) he blogs at [https://dbafromthecold.com](https://dbafromthecold.com/)

I was reading his latest blog post [Using docker named volumes to persist databases in SQL Server](https://dbafromthecold.com/2019/03/21/using-docker-named-volumes-to-persist-databases-in-sql-server) and decided to give it a try.

His instructions worked perfectly and I thought I would try them using a docker-compose file as I like the ease of spinning up containers with them.

I created a docker-compose file like this which will map my backup folder on my Windows 10 laptop to a directory on the container and two more folders to the system folders on the container in the same way as Andrew has in his blog.

    version: '3.7'
    
    services:
        2019-CTP23:
            image: mcr.microsoft.com/mssql/server:2019-CTP2.    3-ubuntu
            ports:  
              - "15591:1433"
              - "5022:5022"
            environment:
              SA_PASSWORD: "Password0!"
              ACCEPT_EULA: "Y"
            volumes: 
              - C:\MSSQL\BACKUP\KEEP:/var/opt/mssql/backups
              - C:\MSSQL\DockerFiles\datafiles:/var/opt/sqlserver
              - C:\MSSQL\DockerFiles\system:/var/opt/mssql


and then from the directory I ran

    docker-compose up -d

This will build the containers as defined in the docker-compose file. The -d runs the container in the background. This was the result.

UPDATE – 2019-03-27  
  
I have no idea why, but today it has worked as expected using the above docker-compose file. I had tried this a couple of times, restarted docker and restarted my laptop and was consistently getting the results below – however today it has worked

![](https://blog.robsewell.com/assets/uploads/2019/03/image-28.png>)

So feel free to carry on reading, it’s a fun story and it shows how you can persist the databases in a new container but the above docker-compose has worked!

![](https://blog.robsewell.com/assets/uploads/2019/03/image-20.png>)

The command completed successfully but as you can see on the left the container is red because it is not running. (I am using the [Docker Explorer extension for Visual Studio C](https://marketplace.visualstudio.com/items?itemName=formulahendry.docker-explorer)

I inspected the logs from the container using

     docker logs ctp23_2019-CTP23_1


which returned

> This is an evaluation version. There are \[153\] days left in the evaluation period.  
> This program has encountered a fatal error and cannot continue running at Tue Mar 26 19:40:35 20  
> 19  
> The following diagnostic information is available:  
> `Reason: 0x00000006 Status: 0x40000015 Message: Kernel bug check Address: 0x6b643120`  
> Parameters: 0x10861f680  
> Stacktrace: 000000006b72d63f 000000006b64317b 000000006b6305ca  
> 000000006b63ee02 000000006b72b83a 000000006b72a29d  
> 000000006b769c02 000000006b881000 000000006b894000  
> 000000006b89c000 0000000000000001  
> Process: 7 – sqlservr  
> Thread: 11 (application thread 0x4)  
> Instance Id: e01b154f-7986-42c6-ae13-c7d34b8b257d  
> Crash Id: 8cbb1c22-a8d6-4fad-bf8f-01c6aa5389b7  
> Build stamp: 0e53295d0e1704ae5b221538dd6e2322cd46134e0cc32be49c887ca84cdb8c10  
> Distribution: Ubuntu 16.04.6 LTS  
> Processors: 2  
> Total Memory: 4906205184 bytes  
> Timestamp: Tue Mar 26 19:40:35 2019  
> Ubuntu 16.04.6 LTS  
> Capturing core dump and information to /var/opt/mssql/log…  
> dmesg: read kernel buffer failed: Operation not permitted  
> No journal files were found.  
> No journal files were found.  
> Attempting to capture a dump with paldumper  
> WARNING: Capture attempt failure detected  
> Attempting to capture a filtered dump with paldumper  
> WARNING: Attempt to capture dump failed. Reference /var/opt/mssql/log/core.sqlservr.7.temp/log/  
> paldumper-debug.log for details  
> Attempting to capture a dump with gdb  
> WARNING: Unable to capture crash dump with GDB. You may need to  
> allow ptrace debugging, enable the CAP\_SYS\_PTRACE capability, or  
> run as root.

which told me that …………. it hadn’t worked. So I removed the containers with

    docker-compose down

I thought I would create the volumes ahead of time like Andrew’s blog had mentioned with

    docker volume create mssqlsystem
    docker volume create mssqluser

and then use the volume names in the docker-compose file mapped to the system folders in the container, this time the result was

![](https://blog.robsewell.com/assets/uploads/2019/03/image-21.png>)

> ERROR: Named volume “mssqlsystem:/var/opt/sqlserver:rw” is used in service “2019-CTP23” but no declaration was found in the volumes section.

So that didn't work either 🙂

I decided to inspect the volume definition using

     docker volume inspect mssqlsystem


![](https://blog.robsewell.com/assets/uploads/2019/03/image-22.png>)

I can see the mountpoint is /var/lib/docker/volumes/mssqlsystem/_data so I decided to try a docker-compose like this

 version: '3.7'

services:
    2019-CTP23:
        image: mcr.microsoft.com/mssql/server:2019-CTP2.3-ubuntu
        ports:  
          - "15591:1433"
          - "5022:5022"
        environment:
          SA_PASSWORD: "Password0!"
          ACCEPT_EULA: "Y"
        volumes: 
          - C:\MSSQL\BACKUP\KEEP:/var/opt/mssql/backups
          - /var/lib/docker/volumes/mssqluser/_data:/var/opt/sqlserver
          - /var/lib/docker/volumes/mssqlsystem/_data:/var/opt/mssql

and then ran docker-compose up without the -d flag so that I could see all of the output

![](https://blog.robsewell.com/assets/uploads/2019/03/image-23.png>)

You can see in the output that the system database files are being moved. That looks like it is working so I used CTRL + C to stop the container and return the terminal. I then ran docker-compose up -d and

![](https://blog.robsewell.com/assets/uploads/2019/03/image-24.png>)

I created a special database for Andrew.

> This made me laugh out loud…as there's a strong possibility that could happen [https://t.co/sh0pnhtPQy](https://t.co/sh0pnhtPQy)
> 
> — Andrew Pruski 🏴󠁧󠁢󠁷󠁬󠁳󠁿 (@dbafromthecold) [March 23, 2019](https://twitter.com/dbafromthecold/status/1109253907304206336?ref_src=twsrc%5Etfw)

![](https://blog.robsewell.com/assets/uploads/2019/03/image-25.png>)

I could then remove the container with

    docker-compose down

![](https://blog.robsewell.com/assets/uploads/2019/03/image-26.png>)

To make sure there is nothing up my sleeve I altered the docker-compose file to use a different name and port but kept the volume definitions the same.

    version: '3.7'
    
    services:
        2019-CTP23-Mk1:
            image: mcr.microsoft.com/mssql/server:2019-CTP2.    3-ubuntu
            ports:  
              - "15592:1433"
              - "5022:5022"
            environment:
              SA_PASSWORD: "Password0!"
              ACCEPT_EULA: "Y"
            volumes: 
              - C:\MSSQL\BACKUP\KEEP:/var/opt/mssql/backups
                  - /var/lib/docker/volumes/mssqluser/_data:/var/opt/sqlserver
                  - /var/lib/docker/volumes/mssqlsystem/_data:/var/opt/mssql

I ran `docker-compose up -d` again and connected to the new container and lo and behold the container is still there

![](https://blog.robsewell.com/assets/uploads/2019/03/image-27.png>)

So after doing this, I have learned that to persist the databases and to use docker-compose files I had to map the volume to the mountpoint of the docker volume. Except I haven’t, I have learned that sometimes weird things happen with Docker on my laptop!!
