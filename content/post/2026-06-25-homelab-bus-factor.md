---
title: "If I Got Hit by a Bus, Could Traci Keep the Lights On?"
date: "2026-06-25"
categories:
  - Blog
  - Homelab
  - AI
tags:
  - Claude
  - AI
  - Homelab
  - Proxmox
  - Documentation
image: assets/uploads/2026/06/homelab-bus-factor.png
---

## The Uncomfortable Thought

Every techie I know has one. A box. Or a stack of boxes. Humming away in a cupboard, under the stairs, in the garage, in the spare room that was supposed to be an office. It started as a bit of fun — "I'll just spin up a little server to learn X" — and then, quietly, over months and years, it became load-bearing.

In my case it's a small cluster of servers running a pile of virtual machines and containers. And here's the thing that crept up on me: it isn't just a toy any more. The heating and the lights run through the home automation on it. The family photos — years of them — live on it. There are dashboards Traci [S](https://bsky.app/profile/tracisewell.com) [L](https://www.linkedin.com/in/traci-sewell-5450452bb) glances at without ever thinking about the machinery underneath. The whole thing backs itself up every night while we sleep.

It all works beautifully. As long as I'm here.

Because the only real documentation for how any of it fits together is the squishy, undocumented one between my ears. And one day — hopefully a very long time from now — that documentation is going to stop being available.

I don't mean to be morbid about it. But it's a fair question, and it's one we techies are very good at not asking: **if I got hit by a bus tomorrow, could Traci keep the lights on?**

Now there is already the [eol-dr from Chrissy](https://github.com/potatoqualitee/eol-dr/blob/main/checklist.md?WT.mc_id=DP-MVP-5002693) — a checklist for what to do if the worst happens. But it doesn't cover the *how*. It doesn't explain how to actually keep the humming box humming, or what to do if it stops. And when I asked Traci if she could.

The honest answer was no. Not because she isn't capable — she's wonderfully capable — but because nobody could. There was nothing to keep them on *with*. No map. No "if this light goes red, do that." Just a humming box and a grieving partner being asked to reverse-engineer years of midnight rabbit-holes.

That bothered me enough to do something about it.

## How I Actually Got Here

I'll be honest about how this started, because it wasn't a noble plan to be a responsible adult. I connected [Claude](https://www.anthropic.com/claude) to the cluster because I wanted to *improve* things — tidy up some storage, sort out a couple of niggles, make it better. Classic.

I'll write about the improvements another day. Because partway through poking at it, I had a much more useful realisation. Claude had just spent a while exploring the whole setup — every machine, every container, every backup job — and described it all back to me in clear, ordinary English. And I sat there thinking: *that's it. That's the thing I've never managed to do. That's the document Traci would actually need.*

The improvements were nice. But the documentation was the genuinely valuable use case staring me in the face. So I changed tack and leaned into it.

## The Steps and the Prompts

The lovely part is that this isn't clever. There's no magic. It's a conversation, and the work is in being clear about who the output is *for*.

**Step one — let it look around.** I gave Claude access to the cluster and turned it loose to discover what was actually there, rather than what I *thought* was there (these are rarely the same thing).

> Connect to my cluster and have a proper look around. List every node, every virtual machine and container, what each one does, where its disk lives, and how it's networked. Don't assume — go and check.

It went and checked. And it found things I'd genuinely forgotten about — a couple of old containers I'd stopped "temporarily" about two years ago, a backup job I couldn't have described accurately from memory. That alone was worth the price of admission.

**Step two — and this is the important bit — tell it who the reader is.**

> Now write this up as documentation. But the reader is **not** a server expert. Assume they have never used this software, don't know the jargon, and just need to keep things running exactly as they are today. Plain English. Explain every term the first time it appears.

This single instruction is the whole trick. The default for any of this tooling is to write for someone like me. The moment you tell it the reader is someone like Traci, everything changes — the tone, the assumptions, the amount it explains rather than assumes.

**Step three — ask for the things a frightened person actually needs.** Not a spec. A runbook.

> Add a glossary for every technical term. Add a five-minute "is everything healthy?" routine anyone could follow. Add a "what do I do if…" section for the things most likely to go wrong — a backup fails, something won't start, a machine needs restarting. And finish with a single one-page reference card I could literally pin to the wall next to the server.

That's it. Three ideas, really: *go and find the truth, write it for a non-expert, and give them what to do when it breaks.*

## The Results

This is the part I actually care about. Below are sanitised snippets — I've stripped out every IP address, and I've quietly cut a couple of personal data feeds (home energy and fitness tracking) because nobody needs those on the internet. But almost everything a homelab is made of is bog-standard generic kit, so the *shape* below is exactly what came back.

### The thirty-second summary

It opened with a summary that even I, who built the thing, found clarifying:

> - There are **three physical server computers** ("nodes") that work together as one team. This team is called a **cluster**.
> - On top of those run **about twenty small virtual machines and containers** — each one a self-contained mini-server doing one job (home automation, photo storage, AI chat, dashboards, and so on).
> - A separate computer — the **backup server** — makes **automatic nightly backups** of everything important.
> - Backups are stored in **two places**: a big network drive (NAS) and a local disk inside the backup server. So there's always a copy in more than one location.

And then — this is the part that made me sit up — it drew me a picture. An actual diagram, from a text description, showing how the whole thing hangs together:

 ```mermaid
flowchart LR
    subgraph CLUSTER["🖥️ The cluster (3 servers working as one)"]
        N1["<b>node 1</b><br/>main workhorse<br/>12 cores / 64 GB"]
        N2["<b>node 2</b><br/>AI / GPU node<br/>24 cores / 94 GB"]
        N3["<b>node 3</b><br/>spare / tie-breaker<br/>4 cores / 31 GB"]
    end

    PBS["💾 <b>Backup server</b>"]
    NAS["🗄️ <b>NAS</b><br/>46 TB"]
    ZFS["💿 <b>Local disk in backup server</b><br/>900 GB"]

    CLUSTER -- "nightly backups" --> PBS
    PBS --> NAS
    PBS --> ZFS

    style CLUSTER fill:#e8f0fe,stroke:#4285f4
    style PBS fill:#fef7e0,stroke:#f9ab00
    style NAS fill:#e6f4ea,stroke:#34a853
    style ZFS fill:#e6f4ea,stroke:#34a853
``` 

For someone who has never logged into any of it, that single picture does an enormous amount of work. Three servers, one backup machine, two copies of everything. That's the whole homelab in one glance.

### The hardware, in plain terms

It laid the physical servers out as a simple table — no expertise required to read it:

> | Server | Cores | Memory | Role |
> |--------|------:|-------:|------|
> | **node 1** | 12 | 64 GB | The main workhorse — runs almost everything. |
> | **node 2** | 24 | 94 GB | The AI / GPU node — runs the local AI models. |
> | **node 3** | 4 | 31 GB | Spare / light node — its main job is to be the third "vote" that keeps the cluster healthy. |

It even explained *why* node 3 matters despite barely doing anything — the cluster needs at least two of the three machines online and agreeing, or it freezes to protect itself. That's exactly the kind of thing that lives only in my head and would utterly baffle someone trying to "just turn the quiet one off to save electricity."

### What's actually running on it

Then the inventory — about twenty mini-servers, each described by its job rather than its jargon. Home automation, the photo library, local AI chat, a handful of dashboards and monitoring tools. And it spotted that two of those mini-servers are **Docker hosts** — machines that themselves run a stack of even smaller app-containers — and listed what was on them. Sanitised (and with my personal bits removed), the picture looked like this:

> | App | Job |
> |-----|-----|
> | **Portainer** | A web page to manage all the Docker app-containers. |
> | **Home Assistant voice** (Piper / Whisper / wake-word) | The text-to-speech, speech-to-text and "hey..." wake-word for voice control. |
> | **Signal notifications** | Sends alerts via the Signal messenger app. |
> | **UniFi monitoring** (unpoller + dashboards) | Pulls statistics from the network gear and graphs them. |
> | **Network scanner** | Watches the network for new or unknown devices. |
> | **Home Assistant AI bridge** | Lets an AI assistant talk to the home automation. |

The genuinely useful bit was the note it added on its own: Docker often renames things behind your back, so *"before you run a command, list what's actually there and copy the exact name."* That's a footgun I'd have never thought to warn anyone about — because I just *know* it.

### The glossary

Then a glossary, so none of the words further up are a wall:

> | Term | Plain-English meaning |
> |------|----------------------|
> | **Node** | One physical server computer. We have three. |
> | **Cluster** | The three computers joined together so they can be managed from one screen. |
> | **Guest** | A catch-all word for "a virtual machine or a container" — a mini-server running inside a node. |
> | **Backup server** | A dedicated machine whose only job is to store backups safely. |
> | **NAS** | A network hard-drive box. Our big backup store. |

### How it protects itself — two copies, every night

This was the section I most wanted to get right, because it's the bit that actually matters if I'm not around. Everything backs itself up automatically, overnight, with no human involved — and crucially, into **two separate places** so a single failure can't wipe out both. Another picture, again drawn straight from the description of how I'd set it up:

 ```mermaid
flowchart LR
    subgraph GUESTS["The mini-servers on the cluster"]
        SMALL["Everyday containers<br/>(dashboards, monitoring...)"]
        HEAVY["Home automation<br/>+ the two Docker hosts"]
        PHOTOS["The photo library"]
    end

    SMALL -- "01:00 nightly" --> ZFE["💿 Local disk in backup server<br/>900 GB"]
    HEAVY -- "02:00 nightly" --> NAS["🗄️ NAS<br/>46 TB"]
    PHOTOS -- "Mondays 03:00" --> NAS

    style ZFE fill:#e6f4ea,stroke:#34a853
    style NAS fill:#e6f4ea,stroke:#34a853
    style HEAVY fill:#fce8e6,stroke:#ea4335
    style PHOTOS fill:#fef7e0,stroke:#f9ab00
``` 

And it spelled out the schedule in a way nobody needs a manual to follow:

> | When | What gets backed up | Where it goes |
> |------|--------------------|---------------|
> | **Every night, 01:00** | All the everyday mini-servers | Local disk inside the backup server |
> | **Every night, 02:00** | Home automation + the two Docker hosts | The NAS |
> | **Every Monday, 03:00** | The photo library (it's big) | The NAS |

It even understood *why* I'd split it up that way — the small stuff backed up quickly with no interruption, the important stuff paused for a few seconds to get a perfectly clean copy, and the irreplaceable photos given their own weekly slot — and it explained that reasoning back to me in plain English. The single most important line it wrote in the whole document was this one, and it's the truest thing in there:

> ✅ **The single most important check:** make sure the nightly backup emails keep arriving. If they stop, something is wrong even if everything *looks* fine.

And then the bit that I think genuinely closes the gap — the "what do I do if…" entries. Here's the one for a failed backup, with the real addresses replaced:

> ### …a backup failed (I got a failure email)
> 1. Open the server dashboard at  `https://<server-address>`  and log in.
> 2. Click the machine → **Tasks** at the bottom → find the red backup task → read the message.
> 3. Most common cause: the backup drive was switched off or unreachable. Check the NAS at  `<nas-address>`  is powered on.
> 4. Re-run it: **Backup → select the job → Run now**.

Nobody needs to *understand* the cluster to follow that. They just need to follow it.

And finally, the thing I asked for to pin on the wall — the one-page card, stripped of the real values:

 ```
CLUSTER:        <name>        (management dashboard: https://<address>)
NODES:          node1 <ip> | node2 <ip> | node3 <ip>
BACKUP SERVER:  <address>     (dashboard: https://<address>)
BIG BACKUP:     NAS at <address>

BACKUPS RUN:    every night, automatically. Alerts email <you@example.com>.

GOLDEN RULES:   • Keep at least two nodes powered on.
                • Keep the NAS powered on — backups need it.
                • Watch for the nightly backup emails. If they stop, something is wrong.
                • Never restart two nodes at once.
``` 

Four golden rules. If Traci only ever read those four lines, she'd be in a dramatically better position than she was the day before I started.

## Same Box, Now With a Map

Here's what struck me most. We talk endlessly about AI writing code, automating tasks, doing the clever stuff. But the use case that actually moved me wasn't clever at all. It was **translation**. Taking the tangle of knowledge that only existed in my head and turning it into something the people I love could genuinely follow on the worst day of their lives.

That's not a small thing. That's the difference between leaving someone a humming mystery and leaving them a manual.

A couple of honest caveats, because regular readers know I don't do the polished-everything-worked routine. First, you have to *check it*. It explored my setup and got it impressively right — but it's your name on the document, and you're the one who knows when it's wrong. Read every line as if you were the non-expert. Second — and this is the one that'll get all of us — **a runbook is only as true as the day you last updated it.** The moment I add a machine or change a backup job and don't update the doc, I've started lying to my future widow. So this isn't a one-off. It's a thing to re-run every now and then and let it tell me what's changed.

But the gap between "it's all in my head" and "it's written down in plain English with a card on the wall" is enormous. And it took an afternoon.

If you've got a box humming in a cupboard that your household quietly depends on, I'd gently suggest you do the same. Point the AI at it, tell it the reader has never seen a server in their life, and ask it for the document you hope nobody ever has to open.

Traci, if you're reading this — it's the file called "Homelab Documentation," it's in the repo that Jess has access to, and it's the one thing I hope you never have to use. But if you do, it should be enough to keep the lights on.

*And no, I'm not planning on going anywhere. But the photos, the heating and the backups don't know that, and neither does the bus.*
