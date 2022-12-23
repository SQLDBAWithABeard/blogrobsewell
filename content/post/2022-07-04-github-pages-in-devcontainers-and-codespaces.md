---
title: "GitHub Pages in Dev Containers and Codespaces"
date: "2022-07-04" 
categories:
  - Blog
  - Community
  - Dev Containers

tags:
 - Blog
 - Community
 - Automation
 - YAML
 - docker
 - jekyll
 - GitHub Pages
 - codespaces
 - Dev Containers


image: https://images.unsplash.com/photo-1494961104209-3c223057bd26?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1102&q=80
---

# Broken Link

It started with a message from Mikey Bronowski ( [Blog](https://www.bronowski.it/blog/)  [Twitter](https://twitter.com/@MikeyBronowski) )  

![message from Mikey](assets/uploads/2022/07/mikey-dm.png)

Now this means that you get to see my awesome [404 page ](https://blog.robsewell.com/justsomethingsad) which makes me laugh every time! It is not a very good look though and does not help people who are reading the blog.  

## Why do something manual when you can automate it

This blog is running on GitHub Pages via a repository. Every time a change is pushed to the repo a GitHub Action runs which rebuilds the jekyll site and makes it available.

So the easy thing to do is to edit the code to add the corrected link, push the change and have GitHub Pages do its thing. If I wanted to validate it first then I could use docker and containers as discussed in these two blog posts [Running GitHub Pages locally](2021-04-11-locally-viewing-github-pages-new-data-saturdays.md) or [Running GitHub Pages locally with a Remote Theme (this site has a remote theme)](2021-04-15-locally-viewing-github-pages-locally-with-remote-theme.md). Then I could see the changes locally before pushing them to the repository.

But my brain didn't work in that way. Instead it thought "Hmmm maybe I could do this in the browser in [GitHub Codespaces](https://github.com/features/codespaces) and then it could work locally as it will have a dev container (development container) configuration and VS Code will just open that in Docker itself, no need for running docker commands manually and I can write blog posts anywhere there is a browser or VS Code"  

The most wonderful Jess Pomfret [Blog](https://jesspomfret.com) [Twitter](https://twitter.com/@jpomfret) and I delivered a [dbatools](https://dbatools.io) Training Day at SQL Bits this year which we developed and ran using dev containers. We also presented a session at the [PowerShell Conference Europe](psconf.eu) about using dev containers so I had a little knowledge of how it can be done.  

# How easy is it ?

It's super super easy. Surprisingly easy.  

## Open a codespace for your repository

First I went to the repository for my website and opened a codespace by clicking on the green code button and creating a codespace

![the create codespace button](assets/uploads/2022/07/create-codespace.png)

## Add the development container configuration

Using `CTRL SHIFT + P` to open the command palette and typing codespaces and choosing the Add Development Container Configuration Files

![Add the configuration](assets/uploads/2022/07/add-config.png)

and follow the prompts

- Show All Definitions
- Jekyll
- bullseye (or buster if you use Apples)
- lts

## The config files are created

This will create a `.devcontainer` directory with 
- devcontainer.json
- Dockerfile
- post-create.sh

Which will do all that you need. You can stop here. You will just need to run `jekyll serve` to start the website.

## Automatic regeneration

To make it automatically regenerate. I added  

`bundle exec jekyll serve --force-polling`

to the end of the post-create.sh file. This will automatically start the website and regenerate it everytime I make a change :-)

## View the logs

You can watch the logs of the regeneration with View Creation Log from the command palette - Use `CTRL SHIFT + P` to open it. Then you can see the log output in real-time.

![look at the logs](assets/uploads/2022/07/view-creation-log.png)

## Open the website "locally"

To open the website from inside the devcontainers the ports are exposed via the configuration. In the browser in codepaces there is a port tab and a button to press to open the website and show the updates that you have written.

![the ports get forwarded](assets/uploads/2022/07/port-forwards.png)

If you click that you get a live view of the website so that you can validate that it works.

# And VS Code?

This showed it being created in codespaces in the browser, you can have the same effect in VS Code by adding a `.devcontainer` directory and copying the files from the [vs code dev containers repo](https://github.com/microsoft/vscode-dev-containers/tree/v0.238.1/containers/jekyll/.devcontainer)

The rest is pretty much the same except the url!

![running in vs code](assets/uploads/2022/07/vscode.png)

# Rather Have Video ?

If you prefer video then you can find one on Youtube showing the same process. 

{% include youtubePlayer.html id="aFFmPlbjfCw" %}
