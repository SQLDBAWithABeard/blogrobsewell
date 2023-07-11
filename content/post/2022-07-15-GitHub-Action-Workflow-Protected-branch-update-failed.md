---
title: "GitHub Action Workflow Protected branch update failed"
date: "2022-07-15"
categories:
  - Blog
  - Community
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


image: assets/uploads/2022/noentry.jpg
---

[The last post](/blog/community/dev%20containers/powershell/github/Creating-A-Training-Day-Speakers-List-With-GitHub-Actions-From-A-GitHub-Issue/) showed how we created an easy process to update a web-page using a GitHub Issue and two GitHub Actions.

# Protecting the repository

I opened the repository in the browser and GitHub and was provided with a warning that said

[![protect your branch](assets/uploads/2022/07/protectbranch.png)](assets/uploads/2022/07/protectbranch.png)

Clicking on the protect this branch button gave the reasoning.

>Protect your most important branches
Branch protection rules define whether collaborators can delete or force push to the branch and set requirements for any pushes to the branch, such as passing status checks or a linear commit history.

So I changed the settings so that a Pull Request is required and needs to be reviewed.

[![all protected](assets/uploads/2022/07/branchprotected.png)](assets/uploads/2022/07/branchprotected.png)

# Breaks the workflow

I had already altered the workflow trigger for the workflow to generate the speaker-list.json so that it would run when changes to the speakers directory were pushed to the main branch by adding

````
on:
 workflow_call:
 workflow_dispatch:
 push:
   branches:
     - main
   paths:
     - speakers/*
````

I then approved a PR with a change to that directory and saw that the workflow had started.

Then it failed :-(.

The error message could be seen in the codespaces with the extension [cschleiden.vscode-github-actions](https://marketplace.visualstudio.com/items?itemName=cschleiden.vscode-github-actions)


[![no can do](assets/uploads/2022/07/pushdenied.png)](assets/uploads/2022/07/pushdenied.png)

This is the error message

>Error: To https://github.com/dataplat/DataSpeakers
!	refs/heads/main:refs/heads/main	[remote rejected] (protected branch hook declined)
Done
Pushing to https://github.com/dataplat/DataSpeakers
POST git-receive-pack (604 bytes)
remote: error: GH006: Protected branch update failed for refs/heads/main.
remote: error: At least 1 approving review is required by reviewers with write access.
error: failed to push some refs to 'https://github.com/dataplat/DataSpeakers'

Of course, because I have now protected my branch, I cannot automatically push changes into the main branch.

# Fix it

To fix this, I had to create a new PAT token with `public_repo` scope and save it as a secret for the workflow to access and update the checkout to use this token.

## Create a new PAT token

The instructions to do this are found [in the docs here](https://docs.github.com/en/enterprise-server@3.4/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)

- In the upper-right corner of any page, click your profile photo, then click Settings.
- In the left sidebar, click Developer settings.
- In the left sidebar, click Personal access tokens.
- Click Generate new token.
- Give your token a descriptive name.
- To give your token an expiration.
- Select the scopes, or permissions, you'd like to grant this token.
For this scenario just choose `public_repo`
- Click Generate token.
- Save the generated token somewhere safe like your password manager. ( You **do** have a password manager? - Our family use 1Password)

## Save it as a secret in the repository

You do not ever ever ever want to store secrets in source control. When using GitHub like this you can store your secrets in the settings of the repository [by following this guide](https://github.com/Azure/actions-workflow-samples/blob/master/assets/create-secrets-for-GitHub-workflows.md)


- navigate to the main page of the repository.
- Under your repository name, click on the "Settings" tab.
- In the left sidebar, click Secrets.
- On the right bar, click on "Add a new secret"
- Type a name for your secret in the "Name" input box. I used `REPO_TOKEN`
- Type the value for your secret.
- Click Add secret.

## Use it in your workflow

Now that you have saved your secret, you can use it your workflows. To get rid of the protected branch error it is used in the `actions/checkout` action like this

````
- uses: actions/checkout@v2
  with:
    fetch-depth: 0
    ref: main
    token: ${{ secrets.REPO_TOKEN }}
````

I remembered to do for both workflows!!

I then created a PR to test it and this time it was able to successfully push changes to the main branch

[![its pushed](assets/uploads/2022/07/pushcompleted.png)](assets/uploads/2022/07/pushcompleted.png)

and you can see [the commit here](https://github.com/dataplat/DataSpeakers/commit/80d585ff1de15db22744ad5e7295294260b8fc98) or [the PR](https://github.com/dataplat/DataSpeakers/commit/7046d51de7b1d9e9b9f188879a4981a76f35c3c4) if you wish.

# But thats not all folks

This will work correctly for a PR and it will work for the initial workflow that has been called.

It ***will not work*** for the reusable workflow. When the reusable workflow is called from another workflow it is unable to pick up the token from the secrets. [In that scenario we get this error](https://github.com/dataplat/DataSpeakers/actions/runs/2659979920)

[![Greg Broke it](assets/uploads/2022/07/gregbrokeit.png)](assets/uploads/2022/07/gregbrokeit.png)

> Input required and not supplied: token

for the `actions/checkout@v2` action. This took some tracking down to resolve but finally I found the answer [in a forum post](https://github.community/t/reusable-workflows-secrets-and-environments/203695/18?u=sqldbawithabeard)

In the ***calling*** workflow add a `secrets` entry and pass in the token secret.

````
createSpeakerListJson:
  needs: addNewSpeaker
  uses: dataplat/DataSpeakers/.github/workflows/wesbiteFile.yml@main
  secrets:
    REPO_TOKEN: ${{ secrets.REPO_TOKEN }}
````

and then at the top of the ***reusable workflow*** define the secrets

````
on:
 workflow_call:
  secrets:
    REPO_TOKEN:
      required: true
````
and finally all is well and Dr Greg Low [Blog](https://blog.greglow.com/) [Twitter](https://twitter.com/greglow) can be added ;-)

Happy Automating!
