---
title: "Changing to Upper Case in VS Code"
date: "2023-08-20"
categories:
  - Blog
  - TipsAndTricks
  - VS Code

tags:
  - PowerShell
  - bash
  - Azure DevOps


image: assets/uploads/2023/uppercase.png

---
# Now I know this!

I was using some code that I had written for Azure Pipelines for a Windows agent which had `$(System.AgentToken)` as the variable name and all other pre-defined variables were the same PascalCase and separated by `.` but the Linux agent needed all upper case and separated by `_`

In VS Code `CTRL SHIFT P` to open the command pallette and then search for uppercase :-)

{{< youtube 0Hkh46dnC7Y >}}

Simples