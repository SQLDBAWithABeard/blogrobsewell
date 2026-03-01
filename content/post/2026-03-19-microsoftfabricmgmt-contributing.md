---
title: "MicrosoftFabricMgmt: Contributing - Join the Community"
date: "2026-03-19"
slug: "microsoftfabricmgmt-contributing"
categories:
  - Blog
  - Microsoft Fabric
  - PowerShell
tags:
  - PowerShell
  - Microsoft Fabric
  - MicrosoftFabricMgmt
  - Community
  - Open Source
image: assets/uploads/2026/03/microsoftfabricmgmt-contributing.png
---

## Introduction

This is the final post in the MicrosoftFabricMgmt series. Over the past four weeks we have covered everything from [installation and first authentication](https://blog.robsewell.com/blog/microsoftfabricmgmt-getting-started/) through to [building a complete Fabric environment](https://blog.robsewell.com/blog/microsoftfabricmgmt-complete-environment/) and [production authentication with Service Principals](https://blog.robsewell.com/blog/microsoftfabricmgmt-service-principals/). Now I want to talk about how you can give something back.

## The Project

MicrosoftFabricMgmt lives in the [fabric-toolbox](https://github.com/microsoft/fabric-toolbox) repository on GitHub, under `tools/MicrosoftFabricMgmt`. The module is the result of a collaboration between the Microsoft CAT (Customer Advisory Team), Tiago Balabuch [L](https://www.linkedin.com/in/tiagobalabuch/), Jess Pomfret [B](https://jesspomfret.com) [S](https://bsky.app/profile/jpomfret.co.uk) [L](https://www.linkedin.com/in/jpomfret), and myself. It is open source and contributions are very much welcome.

## Raising Issues

If you find a bug, encounter unexpected behaviour, or think a cmdlet is missing a parameter it should have, raise an issue on GitHub. Good issues include:

- What you ran (the exact command)
- What you expected to happen
- What actually happened (including any error messages)
- The version of the module (`Get-Module MicrosoftFabricMgmt | Select-Object Version`)

The team responds to issues. We take them seriously. An issue you raise today might become a fix or feature in the next release.

## Feature Requests

If there is a Fabric API endpoint that is not covered, or a workflow you wish the module made easier, open a feature request issue. Label it `enhancement` and describe the use case — not just "add cmdlet X" but "I need to be able to do Y, and currently I have to do Z to work around it."

## Contributing Code

The module follows a consistent structure. Each resource type has its own directory under `Public/` with Get, New, Update, and Remove functions following the same patterns. If you want to add support for a new resource type:

1. Fork the repository
2. Create a branch: `git checkout -b feature/add-fabricitem-support`
3. Follow the existing patterns — look at a similar resource type for reference
4. Add Pester tests for your functions
5. Submit a pull request with a clear description of what you have added and why

The team will review, provide feedback, and merge when it is ready. We have had community contributors add support for resource types none of us had prioritised, and it has made the module significantly more complete.

## Installing the Latest Version

The module is published to the [PowerShell Gallery](https://www.powershellgallery.com/packages/MicrosoftFabricMgmt?WT.mc_id=DP-MVP-5002693):

```powershell
# Install
Install-PSResource -Name MicrosoftFabricMgmt

# Update to the latest
Update-PSResource -Name MicrosoftFabricMgmt
```

New versions are released regularly as new Fabric API features arrive and community contributions land.

## Wrapping Up the Series

When Tiago first started this module, it was impressive but rough around the edges. When Jess and I got involved and started making significant improvements, we had a clear goal: make it something we would actually use ourselves in production. I think we got there.

From [intelligent output formatting](https://blog.robsewell.com/blog/microsoftfabricmgmt-goodbye-guids/) to [full pipeline support](https://blog.robsewell.com/blog/microsoftfabricmgmt-pipeline/), from [PSFramework logging](https://blog.robsewell.com/blog/microsoftfabricmgmt-psframework-logging/) to [robust error handling](https://blog.robsewell.com/blog/microsoftfabricmgmt-error-handling/) — the module is production-ready and built to the same standard I hold my own PowerShell tooling to.

If you use it, I would love to hear about it. Find me on Bluesky or leave a comment. And if you find something that could be better — raise an issue, or better yet, submit a PR. That is how open source gets good.

Thanks for following along. See you next time.
