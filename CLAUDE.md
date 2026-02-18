# CLAUDE.md — Rob Sewell's Blog

## Scope

All work is in this blog folder (`s:/blogrobsewell`). The `s:/clonedforked/fabric-toolbox/tools/MicrosoftFabricMgmt` folder is **read-only reference** — never modify it.

## Hugo Site Structure

- **Posts**: `content/post/YYYY-MM-DD-slug.md`
- **Images**: `content/assets/uploads/YYYY/` or `content/assets/uploads/YYYY/MM/`
- **New post filename format**: `YYYY-MM-DD-descriptive-slug.md`

## Front Matter

```yaml
---
title: "Title Here"
date: "YYYY-MM-DD"
categories:
  - Blog
  - Microsoft Fabric
tags:
  - PowerShell
  - Microsoft Fabric
image: assets/uploads/YYYY/image-name.png
---
```

## Images

All images **must**:
1. Have suitable, descriptive alt text
2. Be linked to themselves (clicking opens the full image)

Format:
```markdown
[![descriptive alt text](assets/uploads/YYYY/image.png)](assets/uploads/YYYY/image.png)
```

For posts in `content/post/`, paths relative to the site root use `../assets/uploads/...` or `assets/uploads/...` — follow the pattern already used in the post being edited.

## Microsoft Links

All links to Microsoft domains (learn.microsoft.com, docs.microsoft.com, etc.) **must** have the MVP tracking tag appended:

```
?WT.mc_id=DP-MVP-5002693
```

If the URL already has a query string, use `&WT.mc_id=DP-MVP-5002693` instead.

Examples:
- `https://learn.microsoft.com/en-us/fabric/fundamentals/workspaces?WT.mc_id=DP-MVP-5002693`
- `https://www.powershellgallery.com/?WT.mc_id=DP-MVP-5002693`
- `https://code.visualstudio.com/?WT.mc_id=DP-MVP-5002693`

## People — Social Links

When mentioning people, link them using their social profiles. Use the following formats (sourced from `C:\Users\mrrob\AppData\Roaming\Code\User\snippets\markdown.json`):

| Person | Format |
|--------|--------|
| Jess Pomfret | `Jess Pomfret [B](https://jesspomfret.com) [S](https://bsky.app/profile/jpomfret.co.uk) [L](https://www.linkedin.com/in/jpomfret)` |
| Traci (Sewell) | `Traci [S](https://bsky.app/profile/tracisewell.com) [L](https://www.linkedin.com/in/traci-sewell-5450452bb)` |
| Gianluca Sartori | `Gianluca Sartori [Blog](https://spaghettidba.com/) [Twitter](https://twitter.com/spaghettidba)` |
| Chrissy LeMaire | `Chrissy LeMaire [Blog](https://netnerds.net/) [Twitter](https://twitter.com/cl)` |
| Benni De Jagere | `Benni De Jagere [Blog](https://bennidejagere.com/) [Twitter](https://twitter.com/BenniDeJagere)` |
| Dr Greg Low | `Dr Greg Low [Blog](https://blog.greglow.com/) [Twitter](https://twitter.com/greglow)` |
| Cláudio Silva | `Cláudio Silva [Blog](https://claudioessilva.eu/) [Twitter](https://twitter.com/claudioessilva)` |

Key abbreviations: **B** = Blog, **S** = Bluesky, **L** = LinkedIn, **Twitter** = Twitter/X.

For people not listed here, link to their most relevant social profile (blog preferred, then Bluesky, then LinkedIn, then GitHub).

## Common Tool/Resource Links

Use these exact link formats for frequently referenced tools:

```markdown
[dbatools](dbatools.io)
[dbachecks](https://github.com/dataplat/dbachecks/)
[FabricTools](https://github.com/dataplat/FabricTools)  <!-- GitHub -->
[FabricTools](https://www.powershellgallery.com/packages/FabricTools)  <!-- PSGallery -->
[PowerShell Gallery](https://www.powershellgallery.com/?WT.mc_id=DP-MVP-5002693)
[Visual Studio Code](https://code.visualstudio.com/?WT.mc_id=DP-MVP-5002693)
[SQL Server Management Studio](https://learn.microsoft.com/en-us/ssms/?WT.mc_id=DP-MVP-5002693)
[SQLBits](https://sqlbits.com)
[PSConfEU](https://psconf.eu)
```

## Post Structure

Posts typically follow this pattern:

```
## Introduction
(scene-setting, the problem or context)

## [Section headings for the main content]
(practical content, code, screenshots)

## Conclusion
(takeaway, summary, call to action)
```

- Use `##` for main sections, `###` for subsections
- Code blocks use triple backticks with the language specified (` ```powershell `, ` ```sql `, etc.)
- Blockquotes (`>`) are used for error messages, documentation quotes, and key callout phrases

## Voice and Tone

Rob's blog is **conversational, practical, and community-focused**. Key characteristics:

- **First person** throughout — "I", "we" (when working with others)
- **Friendly and approachable** — talks to the reader directly, uses rhetorical questions ("So how do you test Fabric resources with Pester?")
- **Honest and self-deprecating** — admits mistakes, shares failures alongside successes, doesn't oversell
- **Enthusiastic about community** — regularly credits collaborators, mentions mentees, promotes others' work
- **Practical over theoretical** — shows real code, real errors, real workarounds
- **Light humour** — occasional asides, exclamations like "and bingo!", parenthetical jokes, "Sad Trombone"
- **Inclusive** — references wife Traci, shared projects with Jess, mentoring relationships

Avoid: corporate language, excessive hedging, padding, self-promotion without substance.

## Topic Areas

This blog covers:
- **Microsoft Fabric** — workspaces, lakehouses, warehouses, SQL databases, APIs, FabricTools module
- **PowerShell** — automation, dbatools, dbachecks, Pester testing, PSConfEU
- **SQL Server** — DBA topics, contained databases, migrations, performance
- **Community** — mentoring, speaking, T-SQL Tuesday, conferences (SQLBits, PSConfEU, Data Saturday)
- **Personal/hobbies** — learning through side projects, cycling (Festive 500), homelab

## What NOT to Do

- Do not modify anything in `s:/clonedforked/fabric-toolbox/`
- Do not add Microsoft tracking tags to non-Microsoft URLs
- Do not strip existing tracking tags from links
- Do not change the voice to be more formal or corporate
- Do not create new files outside `content/post/` and `assets/uploads/` unless explicitly asked
