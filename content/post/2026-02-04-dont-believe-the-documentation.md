---
title: "Don't Believe the Documentation - Coding against the Microsoft Fabric API with PowerShell"
date: "2026-02-04"
categories:
  - Microsoft Fabric
  - PowerShell

tags:
  - Power Bi
  - Microsoft Fabric
  - Security
  - MicrosoftFabricMgmt
image: assets/uploads/2026/02/500.png
---
## Introduction

Firstly, an apology to my friends (especially Randolph) in the documentation team at Microsoft. I know how hard you work to produce accurate and useful documentation, and I appreciate your efforts. This is not a criticism of your work, but rather an observation about the challenges I faced.

This is a story about a recent experience and the lessons learned along the way.

## The challenge

"We need to remove all links that have been shared with the whole organisation from our Fabric tenants"

Excellent, Fabric has an API for that - [Remove All Sharing Links](https://learn.microsoft.com/en-us/rest/api/fabric/admin/sharing-links/remove-all-sharing-links??WT.mc_id=DP-MVP-5002693) Just one call and they are all gone.

"Ah, except for these particular ones. They must stay."

No problem, I can get all the links, filter out the ones to keep, and then remove the rest.

There is an API for that too - [Bulk Remove Sharing Links](https://learn.microsoft.com/en-us/rest/api/fabric/admin/sharing-links/bulk-remove-sharing-links?WT.mc_id=DP-MVP-5002693)

In the documentation it states:

>Limitations
Maximum 10 requests per minute.
Each request can delete organization sharing links for up to 500 Fabric items.

There are about 8,500 links to remove, so I will need to batch them into groups of 500 and make 17 calls. No problem.

"It should take about 20 minutes to complete. Lets say 30 minutes to be safe. I will need to process the entire 100,000 reports as well to be able to match the links that need to be kept, so I will budget a couple of hours for the entire operation." I said confidently.

## The PowerShell

I used the [MicrosoftFabricMgmt PowerShell module from Microsoft's fabric-toolbox](https://github.com/microsoft/fabric-toolbox/tree/main/tools/MicrosoftFabricMgmt) to do this task.

NOTE - Not all of the functionality is available today as I have written it to do this task and it has not been released.

```powershell
# Connect to the Fabric tenant
Set-FabricAPIHeaders -TenantId (Get-Secret -Name "FabricTenantId" -AsPlainText)
# Get all the sharing links in the organisation
$allLinks = Get-FabricWidelySharedLink

# get all of the reports as admin
$reportsasadmin = Get-FabricAdminReport

# Get the list of reports to keep
[array]$filteredReports = $reportsasadmin | Where-Object { $_.name -in $reportstokeep } |
Select-Object name, id, workspaceId| Sort name | ForEach-Object {
    Start-Sleep -Seconds 15
    $Workspace = Get-FabricAdminWorkspace -WorkspaceId $ _. workspaceId
    If($workspace.type -eq 'Personal') {
    $WorkspaceName = "{0} My Workspace" -f $Workspace.name
    } else{
    $WorkspaceName = $Workspace.Name
    }
Write-PSFMessage -Level Important "Exempting report from removal: $($ _. name) in workspace $WorkspaceName ($($ _. workspaceId))"
    [PSCustomObject]@{
      Name = $_.name
      Id = $_.id
      WorkspaceId = $_.workspaceId
    }
  }

$WideSharedReportsToRemove = @()
$WideSharedReportsToRemove = $allLinks.ArtifactAccessEntities |
Where-Object { $_.artifactId -notin $filteredReports.id} | ForEach-Object {
  $reportid = $_.artifactId
  $reportname = $_.displayName
  $workspaceid = ($reportsasadmin | Where-Object { $_.id -eq $reportid }).workspaceId
    [PSCustomObject]@{
      Reportid = $reportid
      ReportName = $reportname
      WorkspaceId = $workspaceid
  }
  Write-PSFMessage -Level Important "Report to remove: $reportname from workspace ($workspaceid)"
}


Write-PSFMessage -Level Important "Found $($WideSharedReportsToRemove.Count) widely shared reports links to delete."

# Create the array of links to remove
$RemovingLinkArray = @()
$RemovingLinkArray = $WideSharedReportsToRemove | ForEach-Object {
[PSCustomObject]@{
    Id = $_.Reportid
    type = "Report"
  }
}
```
I was super careful to double check at each point that each step used the correct data.

With the list of reports to remove created and validated, I can then batch them into groups of 500 and call the Bulk Remove Sharing Links API.

```powershell
$totalReports = $RemovingLinkArray.Count
$x = 0
$batchSize = 500
While ($x -lt $totalReports) {
$batch = $RemovingLinkArray[$x..([Math]::Min($x + $batchSize - 1, $totalReports - 1))]
# Call the API to remove the batch of links
Remove-FabricSharingLinksBulk -Items $batch -Confirm:$false
$x += $batchSize
Write-PSFMessage -Level Important "Total attempted so far: $x out of $totalReports."
Start-Sleep -Seconds 10
}
```

Job done. All links removed except the ones we wanted to keep.

Or so I thought.

When I ran the script, it completed successfully.

But when I check the links remaining there were still thousands of links remaining.

The output from the script showed the OperationId of the long running operation. I used the `Get-FabricLongRunningOperation` cmdlet to check the status of some of them.

which produced this output:
```
{
"status": "Failed",
"createdTimeUtc": "2026-02-09T13:07:28.951536",
"lastUpdatedTimeUtc": "2026-02-09T13:07:28.9983967",
"percentComplete": null,
"error": {
"errorCode": "InternalServerError",
"message": "PowerBISqlOperationException"
}
}
```

which appeared in no search results but seems to indicate an internal server error.

I spent some time investigating, trying different batch sizes, I never got the assync operation to give me a status of running, it either immediately succeeded or failed.

# The solution (well, workaround) ((well, the brute force method))

I worked out that only a batch size of 50 was providing any success and less than that was more reliable.

I had to repeatedly run the script with a batch size of 40 until almost all of the links were removed. Each time, I ran through the entire list of links to remove. In another session I checked every minute or so the number of remaining links. I could run through the whole list of links and no links would be removed, then the next time through I would see a few links removed, then none, then a few more, then none, and so on.

I resynced the number of links and removed the ones that needed to remain a couple of times. In hindsight, I should have stored these in a datastore to make this look up simpler and not so time intensive.

Each time I looped through the links to remove, I hoped that it woud remove all of the links but it was a case of rinse and repeat, and each time I would see some links removed but not all of them. I had to keep running through the list of links to remove until eventually all of the unwanted links were removed.

Then as the script worked through the last couple of hundred of links a batch size of 10, then 5, then finally 1 was the only way that any links would be removed.

An annoying and time consuming process, but eventually all of the unwanted links were removed and luckily the powers that be were understanding of the time taken and the reasons why.
