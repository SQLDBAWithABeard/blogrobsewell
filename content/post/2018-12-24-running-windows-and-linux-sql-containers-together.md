---
title: "Running Windows and Linux SQL Containers together"
categories:
  - Blog

tags:
  - containers
  - dbatools
  - docker

---
Just for fun I decided to spend Christmas Eve getting Windows and Linux SQL containers running together.

WARNING
-------

This is NOT a production ready solution, in fact I would not even recommend that you try it.  
I definitely wouldn’t recommend it on any machine with anything useful on it that you want to use again.  
We will be using a re-compiled dockerd.exe created by someone else and you know the rules about downloading things from the internet don’t you? and trusting unknown unverified people?

Maybe you can try this in an Azure VM or somewhere else safe.

Anyway, with that in mind, lets go.

Linux Containers On Windows
---------------------------

You can run Linux containers on Windows in Docker as follows. You need to be running the latest Docker for Windows.

Right click on the whale in the task bar and select Settings

[![](https://blog.robsewell.com/assets/uploads/2018/12/docker-settings.png)](https://blog.robsewell.com/assets/uploads/2018/12/docker-settings.png)

Notice that I am running Windows Containers as there is a switch to Linux containers option. If you see Switch to Windows containers then click that first.

Click on Daemon and then tick the experimental features tick box and press apply.

[![](https://blog.robsewell.com/assets/uploads/2018/12/docker-daemon-settings.png)](https://blog.robsewell.com/assets/uploads/2018/12/docker-daemon-settings.png)

Docker will restart and you can now run Linux containers alongside windows containers.

So you you can pull the Ubuntu container with

    docker pull ubuntu:18.04

[![](https://blog.robsewell.com/assets/uploads/2018/12/ubuntu-image-pull.png)](https://blog.robsewell.com/assets/uploads/2018/12/ubuntu-image-pull.png)

and then you can run it with

    docker run -it --name ubuntu ubuntu:18.04

[![](https://blog.robsewell.com/assets/uploads/2018/12/ubuntu-coontainer-interactively.png)](https://blog.robsewell.com/assets/uploads/2018/12/ubuntu-coontainer-interactively.png)

There you go one Linux container running 🙂  
A good resource for learning bash for SQL Server DBAs is Kellyn Pot’Vin-Gorman [b](https://dbakevlar.com/) | [t](https://twitter.com/DBAKevlar) [series on Simple Talk](https://www.red-gate.com/simple-talk/sql/sql-linux/how-to-linux-for-sql-server-dbas-part-1/)

Type Exit to get out of the container and to remove it

    docker rm ubuntu

[![](https://blog.robsewell.com/assets/uploads/2018/12/exit-remove-ubuntu.png)](https://blog.robsewell.com/assets/uploads/2018/12/exit-remove-ubuntu.png)

###   
Running SQL Linux Containers On Windows

So can we run SQL Containers ?

Well, we can pull the image successfully.

    docker pull mcr.microsoft.com/mssql/server:2019-CTP2.2-ubuntu

If you try that without the experimental features enabled you will get this error.

> image operating system “linux” cannot be used on this platform

[![](https://blog.robsewell.com/assets/uploads/2018/12/wrong-platform.png)](https://blog.robsewell.com/assets/uploads/2018/12/wrong-platform.png)

So you would think that what you can do is to use the code from Andrew ‘dbafromthecold’ Pruski’s [b](http://DBAfromthecold.com) | [t](https://twitter.com/DBAfromthecold) excellent [container series](https://dbafromthecold.com/2017/03/15/summary-of-my-container-series/)

    docker run -d -p 15789:1433 --env ACCEPT_EULA=Y --env SA_PASSWORD=Testing1122 --name testcontainer mcr.microsoft.com/mssql/server:2019-CTP2.2-ubuntu

When you do, the command will finish successfully but the container won’t be started (as can been seen by the red dot in the docker explorer).

[![](https://blog.robsewell.com/assets/uploads/2018/12/container-wont-run.png)](https://blog.robsewell.com/assets/uploads/2018/12/container-wont-run.png)

If you look at the logs for the container. (I am lazy, I right click on the container and choose show logs in VS Code 🙂 ) you will see

> sqlservr: This program requires a machine with at least 2000 megabytes of memory.  
> /opt/mssql/bin/sqlservr: This program requires a machine with at least 2000 megabytes of memory.

[![](https://blog.robsewell.com/assets/uploads/2018/12/needs-more-memory.png)](https://blog.robsewell.com/assets/uploads/2018/12/needs-more-memory.png)

Now, if you are running Linux containers, this is an easy fix. All you have to do is to right click on the whale in the taskbar, choose Settings, Advanced and move the slider for the Memory and click apply.

[![](https://blog.robsewell.com/assets/uploads/2018/12/linux-containers-memory-increase.png)](https://blog.robsewell.com/assets/uploads/2018/12/linux-containers-memory-increase.png)

But in Windows containers that option is not available.

If you go a-googling you will find that [Shawn Melton](https://twitter.com/wsmelton) created an [issue for thi](https://github.com/Microsoft/mssql-docker/issues/293)s many months ago, which gets referenced by [this issue](https://github.com/Microsoft/opengcs/issues/145) for the guest compute service, which references t[his PR](https://github.com/moby/moby/pull/37296) in moby. But as this hasn’t been merged into master yet it is not available. I got bored of waiting for this and decided to look a bit deeper today.

### Get It Working Just For Fun

So, you read the warning at the top?

Now let’s get it working. I take zero credit here. All of the work was done by Brian Weeteling [b](https://www.brianweet.com/) | [G](https://github.com/brianweet) in [this post](https://www.brianweet.com/2018/04/26/running-mssql-server-linux-using-lcow.html)

So you can follow Brians examples and check out the source code and compile it as he says or you can [download the exe](https://www.brianweet.com/assets/mssql-linux/dockerd.rar) that he has made available (remember the warning?)

Stop Docker for Windows, and with the file downloaded and unzipped, open an admin PowerShell and navigate to the directory the dockerd.exe file is and run

    .\dockerd.exe

You will get an output like this and it will keep going for a while.

[![](https://blog.robsewell.com/assets/uploads/2018/12/running-dockerd.png)](https://blog.robsewell.com/assets/uploads/2018/12/running-dockerd.png)

Leave this window open whilst you are using Docker like this. Once you see

[![](https://blog.robsewell.com/assets/uploads/2018/12/logs.png)](https://blog.robsewell.com/assets/uploads/2018/12/logs.png)

Then open a new PowerShell window or VS Code. You will need to run it as admin. I ran

    docker ps-a

to see if it was up and available.

[![](https://blog.robsewell.com/assets/uploads/2018/12/docker-ps.png)](https://blog.robsewell.com/assets/uploads/2018/12/docker-ps.png)

I also had to create a bootx64.efi file at C:\\Program Files\\Linux Containers which I did by copying and renaming the kernel file in that folder.

[![](https://blog.robsewell.com/assets/uploads/2018/12/bootx64-file.png)](https://blog.robsewell.com/assets/uploads/2018/12/bootx64-file.png)

Now I can use a docker-compose file to create 5 containers. Four will be Windows containers from [Andrews Docker hub repositories](https://hub.docker.com/u/dbafromthecold) or [Microsoft’s Docker Hub](https://hub.docker.com/r/microsoft/mssql-server/) for SQL 2012, SQL 2014, SQL 2016, and SQL 2017 and one will be the latest [Ubuntu SQL 2019 CTP 2.2 image](https://hub.docker.com/r/microsoft/mssql-server). Note that you have to use version 2.4 of docker compose as the platform tag is not available yet in any later version, although it is coming to 3.7 soon.

    version: '2.4'
    
    services:
        sql2019:
            image: mcr.microsoft.com/mssql/server:2019-CTP2.2-ubuntu
            platform: linux
            ports:  
              - "15585:1433"
            environment:
              SA_PASSWORD: "Password0!"
              ACCEPT_EULA: "Y"
        sql2012:
            image: dbafromthecold/sqlserver2012dev:sp4
            platform: windows
            ports:  
              - "15589:1433"
            environment:
              SA_PASSWORD: "Password0!"
              ACCEPT_EULA: "Y"
        sql2014:
            image: dbafromthecold/sqlserver2014dev:sp2
            platform: windows
            ports:  
              - "15588:1433"
            environment:
              SA_PASSWORD: "Password0!"
              ACCEPT_EULA: "Y"
        sql2016:
            image: dbafromthecold/sqlserver2016dev:sp2
            platform: windows
            ports:  
              - "15587:1433"
            environment:
              SA_PASSWORD: "Password0!"
              ACCEPT_EULA: "Y"
        sql2017:
            image: microsoft/mssql-server-windows-developer:2017-latest
            platform: windows
            ports:  
              - "15586:1433"
            environment:
              SA_PASSWORD: "Password0!"
              ACCEPT_EULA: "Y"

Save this code as docker-compose.yml and navigate to the directory in an admin PowerShell or VS Code and run

    docker-compose up -d

[![](https://blog.robsewell.com/assets/uploads/2018/12/all-the-containers.png)](https://blog.robsewell.com/assets/uploads/2018/12/all-the-containers.png)

and now I have Windows and Linux SQL containers running together. This means that I can test some code against all versions of SQL from 2012 to 2019 easily in containers 🙂

[![](https://blog.robsewell.com/assets/uploads/2018/12/containers-in-SSMS.png)](https://blog.robsewell.com/assets/uploads/2018/12/containers-in-SSMS.png)

[![](https://blog.robsewell.com/assets/uploads/2018/12/all-the-containers-dbatools.png)](https://blog.robsewell.com/assets/uploads/2018/12/all-the-containers-dbatools.png)

So that is just a bit of fun.

To return to the normal Docker, simply CTRL and C the admin PowerShell you ran .\\dockerd.exe in and you will see the logs showing it shutting down.

[![](https://blog.robsewell.com/assets/uploads/2018/12/shutdown-docker.png?fit=630%2C142)](https://blog.robsewell.com/assets/uploads/2018/12/shutdown-docker.png)

You will then be able to start Docker For Windows as usual.

I look forward to the time, hopefully early next year when all of the relevant PR’s have been merged and this is available in Docker for Windows.

Happy Automating 🙂