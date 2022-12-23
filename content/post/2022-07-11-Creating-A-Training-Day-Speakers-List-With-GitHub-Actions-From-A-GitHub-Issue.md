---
title: "Creating A Training Day Speakers List with GitHub Action from a GitHub Issue"
date: "2022-07-11" 
categories:
  - Blog
  - Community
  - Dev Containers
  - PowerShell
  - GitHub


tags:
 - Blog
 - Community
 - Automation
 - speaking
 - pre-con
 - training day
 - GitHub Actions
 - GitHub Issues
 - PowerShell
 - Dev Containers


image: https://images.unsplash.com/photo-1620712943543-bcc4688e7485?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=930&q=80
---

[The last post](/blog/community/Training-Day-Speakers-List) showed the resource that we created to enable speakers to let events know that they have content for pre-cons/training days. This post will describe how the automation was created using a GitHub Issue and two GitHub Actions.

# What do we need?

The idea was to have a form for user input that could easily allow a person to add themselves and some information to a web page. The page holds a list of speakers who can present training day sessions for data platform events. [The web page can be found here](https://callfordataspeakers.com/precon). This page is generated from a JSON file. 

# A new repository

It was decided to use a GitHub repository to hold this information so that it is available publicly as well as via the website. 

# Create a dev container

It's a brand new repository `.devcontainer` directory was created and the files from the [Microsoft VS Code Remote / GitHub Codespaces Container Definitions repository PowerShell containers](https://github.com/microsoft/vscode-dev-containers/tree/main/containers/powershell/.devcontainer) added. This means that whenever I or anyone else wants to work on the repo the development experience will be the same.

## Add extensions

There are a number of default extensions that I install for PowerShell or generic development

- [ms-vscode.powershell](https://marketplace.visualstudio.com/items?itemName=ms-vscode.powershell) - because I am working with PowerShell
- [2gua.rainbow-brackets](https://marketplace.visualstudio.com/items?itemName=2gua.rainbow-brackets) - because I like to easily see which opening bracket matches which closing bracket
- [oderwat.indent-rainbow](https://marketplace.visualstudio.com/items?itemName=oderwat.indent-rainbow) - so that I can quickly see the indentations, invaluable with YAML files
- [usernamehw.errorlens](https://marketplace.visualstudio.com/items?itemName=usernamehw.errorlens) - so that linting errors are displayed in the editor alongside the code
- [eamodio.gitlens](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens) - to make source control easier
- [TylerLeonhardt.vscode-inline-values-powershell](https://marketplace.visualstudio.com/items?itemName=TylerLeonhardt.vscode-inline-values-powershell) - so that you can see inline values when debugging

I also added two more for this repository as we are using GitHub Actions

- [me-dutour-mathieu.vscode-github-actions](https://marketplace.visualstudio.com/items?itemName=me-dutour-mathieu.vscode-github-actions) - for intellisense for GitHub Action files
- [cschleiden.vscode-github-action](https://marketplace.visualstudio.com/items?itemName=cschleiden.vscode-github-actions) - to be able to start/stop/monitor GitHub Actions from the workspace

![the view in codespaces of the GitHub Actions](assets/uploads/2022/07/githubactionsview.png)  


# Gather the Information

People can update repositories using Pull Requests but this needed to be a little more guided and it was decided that it was to be done with [forms via GitHub Issues](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/configuring-issue-templates-for-your-repository#creating-issue-forms)

## Where to put it?

You can create custom GitHub Issues using YAML files in the `.github/ISSUE_TEMPLATE` directory. An Add Speaker issue template file was created. The name and the description will be seen on the [new issues page](https://github.com/dataplat/DataSpeakers/issues/new/choose).

````
name: Add Speaker
description: Add New Speaker information
body:
  - type: markdown
    attributes:
      value: |
       Please follow the instructions to create a new speaker entry.
       We wil display this on callfordataspeakers.com
````

There are a number of `-type` entries. [You can find the definitions in the docs](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/syntax-for-githubs-form-schema) or you can use the intellisense from the extensions. The types are checkboxes, dropdown, input, markdown, textarea

![The intellisense showing the type options](assets/uploads/2022/07/intellisense-ghactions.png)

I used the intellisense to build a quick simple form to gather 5 pieces of information 

- full name
- topics 
- regions 
- sessionize profile URL 
- languages

You can find [the YAML file here](https://github.com/dataplat/DataSpeakers/blob/main/.github/ISSUE_TEMPLATE/Add-Speaker.yml) and [the issue here](https://github.com/dataplat/DataSpeakers/issues/new?assignees=&labels=&template=Add-Speaker.yml)

# Process the information

Now that we have a method of gathering the information, the next stage is to process it automagically. For this we are going to be [using GitHub Actions](https://docs.github.com/en/actions)

## Workflow

GitHub Actions is a platform that can run automated processes called workflows that are defined as YAML files and triggered by events in the repository. We create another directory called `workflows` also in the `.github` directory.

## Triggering the workflow

Many people are comfortable with a DevOps process that will build, test and deploy code when a pull request is raised and approved, GitHub Actions are able to do more as they can be triggered by any events in the repository.  

You can automatically add labels, close stale issues and much more. There are a large number of events open to you as [can be seen here ](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows). Even looking at just issues there are a number of activities types that can be used

- opened
- edited
- deleted
- transferred
- pinned
- unpinned
- closed
- reopened
- assigned
- unassigned
- labeled
- unlabeled
- locked
- unlocked
- milestoned
- demilestoned

(and there are separate ones for issue comments) 

The beginning of the workflow YAML file has the name and then the trigger. This triggers the workflow when an issue is opened.

````
name: Add a new speaker json

on: 
 issues:
   types:
     - "opened"
````

## Getting all the source

The workflow consists of [one or many jobs](https://docs.github.com/en/actions/using-jobs) that can be run on different runners. The first job is named `AddNewSpeaker` and runs on the latest ubuntu version. Each job can have a number of steps and the first step in this scenario is to checkout the latest version of the repository.   

We **_use_** a default **_action_** to checkout and because we push changes back to the repository (more on that later) we choose a `fetch-depth` of 0 to get all of the history and the `ref` main as that is the branch we are working with.

````
jobs:
  addNewSpeaker:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
      with:
        fetch-depth: 0
        ref: main
````

## Being polite

costs nothing so this action from Peter Evans can be used to add or update a comment

````
    - name: Add comment to the issue
      uses: peter-evans/create-or-update-comment@v2
      with:
        issue-number: ${{ github.event.issue.number }}
        body: |
          Hi @${{ github.event.issue.user.login }},
          Thank you so much for your Speaker submission.
          The Action should be running now and adding it to the webpage. It should should update here.
          If it doesn't - get in touch with Rob on Twitter https://twitter.com/sqldbawithbeard
````

### wait a minute, how did you work that out?

The say thank you comment uses `github.event.issue.number` and `github.event.issue.user.login` to ensure that the comment goes on the issue that triggered the workflow and thanks the user that created it. To work out what is available, I used this PowerShell step to write out the GitHub context to the logs as JSON

````
# You also can print the whole GitHub context to the logs to view more details.
    - name: View the GitHub context
      run: Write-Host "$GITHUB_CONTEXT"
      env:
        GITHUB_CONTEXT: ${{ toJson(github) }}
      shell: pwsh 
````
## Get the info into a file

Whilst developing, I first saved the issue body to a file so that I could work with it. As I moved forward I forgot and just left the code in and it works. The issue form creates `### <label>` and then a blank line and then the data that was entered. This enabled me to use some regex and capture each label, grab the data and put it in a `pscustomobject`  

Then I could convert it to Json and save it to a file. I chose to save each speakers information in their own file in case anything else would be needed in the future and also so that if the process failed it only affected this speakers information.

I also add the speaker file name to a text file that I may make use of at some future point.

````
    - name: Get Speaker Information to file
      run: |
        Write-Host "What do we have?"
        # gci -recurse = this is for troubleshooting because paths are hard
        $IssueBody =  "${{ github.event.issue.body }}"
        # Write-Host $IssueBody 
        $IssueBody | Out-File speakers/temp.txt
        # get the temp file contents - I do this so I don't lose anything
        $file = Get-Content ./speakers/temp.txt -Raw
        # parse the issue
        $regexResult = [regex]::Matches($file, '(?ms)fullname\n\n(?<fullname>.*)\n\n### topics\n\n(?<topics>.*)\n\n### regions\n\n(?<regions>.*)\n\n### Sessionize\n\n(?<Sessionize>.*)\n\n### language\n\n(?<language>.*)\n')
        # create an object
        $speakerObject = [PSCustomObject]@{
            name =  $regexResult[0].Groups['fullname'].Value
            topics = $regexResult[0].Groups['topics'].Value
            regions = $regexResult[0].Groups['regions'].Value
            sessionize = $regexResult[0].Groups['Sessionize'].Value
            language = $regexResult[0].Groups['language'].Value
        }
        #save it to a file
        $speakerFileName = $SpeakerObject.name -replace ' ', '-' -replace '''','-' -replace '/','-' -replace '\\','-' -replace ':','-' -replace '\*','-' -replace '\?','-' -replace '"','-' -replace '\|','-'
        $filePath = './speakers/{0}.json' -f $speakerFileName
        $SpeakerObject |ConvertTo-Json | Out-FIle -FilePath $filePath
        $speakerFileName | OUt-File ./speakers/list.txt -Append
      shell: pwsh  
````
### Because Ben is a fantastic tester

All the best testers will do unexpected but valid actions and my wonderful friend Ben Weissman ([Twitter](https://twitter.com/bweissman) [Blog](https://bweissman.azurewebsites.net/)) added some characters into the full name option that made the file save fail. He added his pronouns, which is awesome but not what I expected for a full name option. This is totally my fault for not considering either using pronouns or that as a user input field that is used in code the data should be validated. I used a few replaces to ensure the file name is acceptable.

````
$speakerFileName = $SpeakerObject.name -replace ' ', '-' -replace '''','-' -replace '/','-' -replace '\\','-' -replace ':','-' -replace '\*','-' -replace '\?','-' -replace '"','-' -replace '\|','-'
````

## Let the user know and commit the new file

Next up is another comment, this time to show some progress but also add a link to the created files directory so that the speaker can see it. They can also edit this file if they wish to make any changes. (yes, maybe I should have thought of a way to do it with issues but this is an iterative process).  

I love the `EndBug/add-and-commit` action as it enables me to make changes in a workflow and commit those changes safely back to the repository.

````
    - name: Add another comment to the issue
      uses: peter-evans/create-or-update-comment@v2
      with:
        issue-number: ${{ github.event.issue.number }}
        body: |
          The Speaker Json has been added https://github.com/dataplat/DataSpeakers/tree/main/speakers
    - name: Add & Commit
      uses: EndBug/add-and-commit@v8.0.2
      with:
        author_name: Beardy McBeardFace
        author_email: mrrobsewell@outlook.com
        message: 'The Beard says hooray we have another speaker @${{ github.event.issue.user.login }} - This is an automated message'
````

## DRY

Don't repeat yourself. The idea is to create the JSON file for the web-page from each of the speakers individual json files. People will want to change what they have entered or they will make mistakes, future functionality might require the same steps. With this in mind I created a separate workflow file to create the `speaker-list.json` file. This used two different triggers
- `workflow_calls` so that it can be called from another workflow
- `workflow_dispatch` so that it can be run manually

The other workflow cannot be triggered manually as it relies on an issue to create the required file.

````
on: 
 workflow_call:
 workflow_dispatch:
````

## Only run if

The second workflow file uses a PowerShell action to combine the individual JSONs into a single one and commits that to the repository. It also comments on the issue but it can only do this if the workflow was triggered from the add speaker job and not manually so some conditional logic was required. There were a number of options that I could choose to decide if to run this step but I decided on using the event issue number `if: github.event.issue.number != null` as if there was no issue, there was nothing to comment and this would leave this step open to be used in future coding if required.

````
- name: Add another comment to the issue
  uses: peter-evans/create-or-update-comment@v2
  if: github.event.issue.number != null
  with:
    issue-number: ${{ github.event.issue.number }}
    body: |
      The speaker-list.json file has been recreated ready for the website https://github.com/dataplat/DataSpeakers/blob/main/website/speaker-list.json
      https://callfordataspeakers.com/precon should be updated now
````

## Calling another workflow

To call another workflow in a job you use the `uses:` field and the path to the yaml file and the branch. We also added the `needs:` so that this job will run after the `addNewSpeaker` has completed.

````
createSpeakerListJson:
  needs: addNewSpeaker
  uses: dataplat/DataSpeakers/.github/workflows/wesbiteFile.yml@main
````

## Close the issue

This process needed to be completely automatic and so we use Peter Evans close issue action and tag the speaker and say thankyou as well as closing the issue. We have a `needs:` property so that this job will only run following the successful run of the previous two jobs.

````
closeIssue:
    needs: [addNewSpeaker,createSpeakerListJson]
    runs-on: ubuntu-latest
    steps:
    - name: Close Issue
      uses: peter-evans/close-issue@v2
      with:
        issue-number: ${{ github.event.issue.number }}
        comment: |
          Hey @${{ github.event.issue.user.login }},
          Closing this issue now that the Action has run successfully.
          Thank you so much for adding your information to the list.
          It will be active on callfordataspeakers.com shortly.
          Please share on social media.
          Love and Hugs
          Rob and Daniel
          @SqlDbaWithABeard @dhmacher
````

# Show me what it looks like

You can [take a look at the repo](https://github.com/dataplat/DataSpeakers) there are a [number of issues](https://github.com/dataplat/DataSpeakers/issues?q=is%3Aissue+is%3Aclosed) like [this one from Monica Rathbun](https://github.com/dataplat/DataSpeakers/issues/36) ([Twitter](https://twitter.com/SQLEspresso) - [Blog](https://sqlespresso.com/))

[![Monicas Image](assets/uploads/2022/07/monissue.png)](assets/uploads/2022/07/monissue.png)

you can see the workflows [running here](https://github.com/dataplat/DataSpeakers/actions)

[![workflow run](assets/uploads/2022/07/workflowrun.png)](assets/uploads/2022/07/workflowrun.png)

Happy Automating!
