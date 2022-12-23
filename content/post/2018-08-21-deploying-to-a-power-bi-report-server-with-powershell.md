---
title: "Deploying To a Power Bi Report Server with PowerShell"
date: "2018-08-21" 
categories:
  - Blog

tags:
  - automation
  - deployment
  - PowerShell
  - tfs

---
Just a quick post to share some code that I used to solve a problem I had recently.

I needed to automate the deployment of some Power Bi reports to a Power Bi Report Server PBRS using TFS. I had some modified [historical validation dbachecks](https://blog.robsewell.com/dbachecks-dark-mode-historical-validation-powerbi/) pbix files that I wanted to automate the deployment of and enable the client to be able to quickly and simply deploy the reports as needed.

The manual way
--------------

It is always a good idea to understand how to do a task manually before automating it. To deploy to PBRS you need to use the Power Bi Desktop optimised for Power Bi Report Server. [There are instructions here](https://docs.microsoft.com/en-us/power-bi/report-server/quickstart-create-powerbi-report). Then it is easy to deploy to the PBRS by clicking file and save as and choosing Power Bi Report Server

![manual deploy](https://blog.robsewell.com/assets/uploads/2018/08/manual-deploy.png)

If I then want to set the datasource to use a different set of credentials I navigate to the folder that holds the report in PBRS and click the hamburger menu and Manage

![manage](https://blog.robsewell.com/assets/uploads/2018/08/manage.png)

and I can alter the User Name and Password or the type of connection by clicking on DataSources

![testconn.PNG](https://blog.robsewell.com/assets/uploads/2018/08/testconn.png)

and change it to use the reporting user for example.

Automation
----------

But I dont want to have to do this each time and there will be multiple pbix files, so I wanted to automate the solution. The end result was a VSTS or TFS release process so that I could simply drop the pbix into a git repository, commit my changes, sync them and have the system deploy them automatically.

As with all good ideas, I started with a google and found [this post](http://byobi.com/2018/04/programmatically-deploy-power-bi-reports-to-power-bi-report-server/) by [Bill Anton](https://twitter.com/SQLbyoBI) which gave me a good start ( I could not get the connection string change to work in my test environment but this was not required so I didnt really examine why)

I wrote a function that I can use via TFS or VSTS by embedding it in a PowerShell script. The function requires the [ReportingServicesTools](https://github.com/Microsoft/ReportingServicesTools) module which you can get by

Install-Module -Name ReportingServicesTools

The function below is available via the [PowerShell Gallery](https://www.powershellgallery.com/packages/PublishPBIXFile/1.0.0.2/DisplayScript) also and you can get it with

Install-Script -Name PublishPBIXFile

The source code is on [Github](https://github.com/SQLDBAWithABeard/Functions/blob/master/PublishPBIXFile.ps1)

and the code to call it looks like this

```
$folderName = 'TestFolder'
$ReportServerURI = 'http://localhost/Reports'
$folderLocation = '/'
$pbixfile = 'C:\Temp\test.pbix'
$description = "Descriptions"

$publishPBIXFileSplat = @{
    ReportServerURI    = $ReportServerURI
    folderLocation     = $folderLocation
    description        = $description
    pbixfile           = $pbixfile
    folderName         = $folderName
    AuthenticationType = 'Windows'
    ConnectionUserName = $UserName1
    Secret             = $Password1
    Verbose            = $true
}
Publish-PBIXFile @publishPBIXFileSplat
```

![code1.PNG](https://blog.robsewell.com/assets/uploads/2018/08/code1.png)

which uploads the report to a folder which it will create if it does not exist. It will then upload pbix file, overwriting the existing one if it already exists

![numbe3r1.PNG](https://blog.robsewell.com/assets/uploads/2018/08/numbe3r1.png)

and uses the username and password specified

![code2.PNG](https://blog.robsewell.com/assets/uploads/2018/08/code2.png)

If I wanted to use a Domain reporting user instead I can do
```
$UserName1 = 'TheBeard\ReportingUser'

$publishPBIXFileSplat = @{
    ReportServerURI    = $ReportServerURI
    folderLocation     = $folderLocation
    description        = $description
    pbixfile           = $pbixfile
    folderName         = $folderName
    AuthenticationType = 'Windows'
    ConnectionUserName = $UserName1
    Secret             = $Password1
    Verbose            = $true
}
Publish-PBIXFile @publishPBIXFileSplat
```
and it changes

![code4 reporting](https://blog.robsewell.com/assets/uploads/2018/08/code4-reporting.png)

If we want to use a SQL Authenticated user then
```
$UserName1 = 'TheReportingUserOfBeard'

$publishPBIXFileSplat = @{
    ReportServerURI    = $ReportServerURI
    folderLocation     = $folderLocation
    description        = $description
    pbixfile           = $pbixfile
    folderName         = $folderName
    AuthenticationType = 'SQL'
    # credential = $cred
    ConnectionUserName = $UserName1
    Secret             = $Password1

}
Publish-PBIXFile @publishPBIXFileSplat
```
![sql auth.PNG](https://blog.robsewell.com/assets/uploads/2018/08/sql-auth.png)

Excellent, it all works form the command line. You can pass in a credential object as well as username and password. The reason I enabled username and password? So that I can use TFS or VSTS and store my password as a secret variable.

Now I simply create a repository which has my pbix files and a PowerShell script and build a quick release process to deploy them whenever there is a change 🙂

The deploy script looks like
```
[CmdletBinding()]
Param (
    $PBIXFolder,
    $ConnectionStringPassword
)
$VerbosePreference = 'continue'
$ReportServerURI = 'http://TheBeardsAmazingReports/Reports'
Write-Output "Starting Deployment"
function Publish-PBIXFile {
    [CmdletBinding(DefaultParameterSetName = 'ByUserName', SupportsShouldProcess)]
    Param(
        [Parameter(Mandatory = $true)]
        [string]$FolderName,
        [Parameter(Mandatory = $true)]
        [string]$ReportServerURI,
        [Parameter(Mandatory = $true)]
        [string]$FolderLocation,
        [Parameter(Mandatory = $true)]
        [string]$PBIXFile,
        [Parameter()]
        [string]$Description = "Description of Your report Should go here",
        [Parameter()]
        [ValidateSet('Windows', 'SQL')]
        [string]$AuthenticationType,
        [Parameter(ParameterSetName = 'ByUserName')]
        [string]$ConnectionUserName,
        [Parameter(ParameterSetName = 'ByUserName')]
        [string]$Secret,
        [Parameter(Mandatory = $true, ParameterSetName = 'ByCred')]
        [pscredential]$Credential
    )
    $FolderPath = $FolderLocation + $FolderName
    $PBIXName = $PBIXFile.Split('\')[-1].Replace('.pbix', '')
    try {
        Write-Verbose"Creating a session to the Report Server $ReportServerURI"
        # establish session w/ Report Server
        $session = New-RsRestSession-ReportPortalUri $ReportServerURI
        Write-Verbose"Created a session to the Report Server $ReportServerURI"
    }
    catch {
        Write-Warning"Failed to create a session to the report server $reportserveruri"
        Return
    }
    # create folder (optional)
    try {
        if ($PSCmdlet.ShouldProcess("$ReportServerURI", "Creating a folder called $FolderName at $FolderLocation")) {
            $Null = New-RsRestFolder-WebSession $session-RsFolder $FolderLocation-FolderName $FolderName-ErrorAction Stop
        }
    }
    catch [System.Exception] {
        If ($_.Exception.InnerException.Message -eq 'The remote server returned an error: (409) Conflict.') {
            Write-Warning"The folder already exists - moving on"
        }
    }
    catch {
        Write-Warning"Failed to create a folder called $FolderName at $FolderLocation report server $ReportServerURI but not because it already exists"
        Return
    }
    try {
        if ($PSCmdlet.ShouldProcess("$ReportServerURI", "Uploading the pbix from $PBIXFile to the report server ")) {
            # upload copy of PBIX to new folder
            Write-RsRestCatalogItem-WebSession $session-Path $PBIXFile-RsFolder $folderPath-Description $Description-Overwrite
        }
    }
    catch {
        Write-Warning"Failed to upload the file $PBIXFile to report server $ReportServerURI"
        Return
    }
    try {
        Write-Verbose"Getting the datasources from the pbix file for updating"
        # get data source object
        $datasources = Get-RsRestItemDataSource-WebSession $session-RsItem "$FolderPath/$PBIXName"
        Write-Verbose"Got the datasources for updating"
    }
    catch {
        Write-Warning"Failed to get the datasources"
        Return
    }
    try {
        Write-Verbose"Updating Datasource"

        foreach ($dataSourcein$datasources) {
            if ($AuthenticationType -eq 'SQL') {
                $dataSource.DataModelDataSource.AuthType = 'UsernamePassword'
            }
            else {
                $dataSource.DataModelDataSource.AuthType = 'Windows'
            }
            if ($Credential -or $UserName) {
                if ($Credential) {
                    $UserName = $Credential.UserName
                    $Password = $Credential.GetNetworkCredential().Password
                }
                else {
                    $UserName = $ConnectionUserName
                    $Password = $Secret
                }
                $dataSource.CredentialRetrieval = 'Store'
                $dataSource.DataModelDataSource.Username = $UserName
                $dataSource.DataModelDataSource.Secret = $Password
            }
            if ($PSCmdlet.ShouldProcess("$ReportServerURI", "Updating the data source for the report $PBIXName")) {
                # update data source object on server
                Set-RsRestItemDataSource-WebSession $session-RsItem "$folderPath/$PBIXName"-RsItemType PowerBIReport -DataSources $datasource
            }
        }
    }
    catch {
        Write-Warning"Failed to set the datasource"
        Return
    }
    Write-Verbose"Completed Successfully"
}
foreach ($File in (Get-ChildItem $PBIXFolder\*.pbix)) {
    Write-Output"Processing $($File.FullName)"
    ## to enable further filtering later
    if ($File.FullName -like '*') {
        $folderName = 'ThePlaceForReports'
        $folderLocation = '/'
        $UserName = 'TheBeard\ReportingUser'
        $Password = $ConnectionStringPassword
        $pbixfile = $File.FullName
    }
    if ($File.FullName -like '\*dbachecks\*') {
        $description = "This is the morning daily checks file that....... more info"
    }
    if ($File.FullName -like '\*TheOtherReport\*') {
        $description = "This is hte other report, it reports others"
    }
    $publishPBIXFileSplat = @{
        ReportServerURI    = $ReportServerURI
        folderLocation     = $folderLocation
        description        = $description
        AuthenticationType = 'Windows'
        pbixfile           = $pbixfile
        folderName         = $folderName
        ConnectionUserName = $UserName
        Secret             = $Password
        Verbose            = $true
    }
    $Results = Publish-PBIXFile@publishPBIXFileSplat
    Write-Output$Results
}
```
Although the function does not need to be embedded in the script and can be deployed in a module, I have included it in here to make it easier for people to use quickly. I

[Store the password for the user as a variable in TFS or VSTS](https://docs.microsoft.com/en-us/vsts/pipelines/release/variables?view=vsts&tabs=batch&WT.mc_id=DP-MVP-5002693)

Then create a PowerShell step in VSTS or TFS and call the script with the parameters as shown below and PowerBi files auto deploy to Power Bi Report Server

![vsts.PNG](https://blog.robsewell.com/assets/uploads/2018/08/vsts.png)

and I have my process complete 🙂

Happy Automating 🙂
