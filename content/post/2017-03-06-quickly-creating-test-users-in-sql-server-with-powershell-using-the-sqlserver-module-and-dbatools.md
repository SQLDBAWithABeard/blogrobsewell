---
title: "Quickly Creating Test Users in SQL Server with PowerShell using the sqlserver module and dbatools"
categories:
  - Blog

tags:
  - automate
  - automation
  - dbatools
  - PowerShell
  - roles
  - smo
  - snippet

header:
  teaser: assets/uploads/2017/02/remove-them-all.png
---
One of the most visited posts on my blog is nearly two and half years old now – <A href="https://blog.robsewell.com/blog/dbatools/powershell/sql%20server/add-user-to-database-role-with-powershell/" target=_blank>Add User to SQL Server Database Role with PowerShell and Quickly Creating Test Users</A>.&nbsp;I thought it was time to update it and use the <A href="https://msdn.microsoft.com/en-us/library/hh245198.aspx" target=_blank>latest sqlserver module</A> and the <A href="https://dbatools.io/" target=_blank>dbatools module</A>.

You can get the latest version of the sqlserver module by installing SSMS 2016. The <A href="https://sqlps.io" target=_blank>PASS PowerShell Virtual Chapter</A>&nbsp;have created a short link to make this easier for you to remember: <A href="https://sqlps.io/dl" target=_blank>https://sqlps.io/dl</A>
Once you have downloaded and installed SSMS you can load the module.

````
Import-Module sqlserver
````
There is one situation where you will get an error loading the sqlserver module into PowerShell. If you have the SQLPS module already imported then you will get the following error:
  
> Import-Module : The following error occurred while loading the extended type data file:
  
![sqlserver-module-error](https://blog.robsewell.com/assets/uploads/2017/02/sqlserver-module-error.png)

In that case you will need to remove the SQLPS module first.

````
Remove-Module sqlps
Import-Module sqlserver
````

The original post dealt with creating a number of test users for a database and assigning them to different roles quickly and easily.
First let’s quickly create a list of Admin users and a list of Service Users and save them in a text file.
````
$i = 0
while ($I -lt 100) {
    "Beard_Service_User$i" | Out-File 'C:\temp\Users.txt' -Append
    $i++
}

$i = 0
while ($I -lt 10) {
    "Beard_Service_Admin_$i" | Out-File 'C:\temp\Admins.txt' -Append
    $i++
}
````
Now that we have those users in files we can assign them to a variable by using `Get-Content`  
  
````$Admins = Get-Content 'C:\temp\Admins.txt'````  
  
Of course we can use any source for our users 
- a database 
- an excel file 
- Active Directory 
- or even just type them in.  

We can use the `Add-SQLLogin` command from the sqlserver module to add our users as SQL Logins, but at present we cannot add them as database users and assign them to a role.  
If we want to add a Windows Group or a Windows User to our SQL Server we can do so using:  

````
Add-SqlLogin -ServerInstance $Server -LoginName $User -LoginType WindowsUser -DefaultDatabase tempdb -Enable -GrantConnectSql  
````
Notice that we need to enable and grant connect SQL to the user. 

If we want to add a SQL login the code is pretty much the same but we either have to enter the password in an authentication box or pass in a PSCredential object holding the username and password. Keeping credentials secure in PowerShell scripts is outside the scope of this post and the requirement is for none-live environments so we will pass in the same password for all users as a string to the script. You may want or be required to achieve this in a different fashion.  

````
$Pass = ConvertTo-SecureString -String $Password -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $Pass
Add-SqlLogin -ServerInstance $Server -LoginName $User -LoginType $LoginType -DefaultDatabase tempdb -Enable -GrantConnectSql -LoginPSCredential $Credential
````
We can ensure that we are not trying to add logins that already exist using  

```` 
if(!($srv.Logins.Contains($User)))
{
````
The `$srv` is a <A href="https://msdn.microsoft.com/en-us/library/microsoft.sqlserver.management.smo.server.aspx" target=_blank>SQL Server Management Server Object</A> which you can create using a snippet. I blogged about <A href="https://blog.robsewell.com/blog/powershell-snippets-a-great-learning-tool/" target=_blank>snippets here</A> and you can find my <A href="https://github.com/SQLDBAWithABeard/Functions/blob/master/Snippets%20List.ps1" target=_blank>list of snippets on GitHub here</A>.&nbsp;However, today I am going to use the <A href="https://dbatools.io" target=_blank>dbatools module </A>to create a SMO Server Object using the <A href="https://dbatools.io/functions/Connect-dbaInstance/" target=_blank>Connect-DbaInstance command</A> and assign the server and the database to a variable:
````
# Create a SQL Server SMO Object
$srv = Connect-DbaInstance  -SqlInstance $server
$db = $srv.Databases[$Database]
````
Once we have our Logins we need to create our database users:
````
$usr = New-Object ('Microsoft.SqlServer.Management.Smo.User') ($db, $User)
$usr.Login = $User
$usr.Create()
````
and add them to a database role.
````
#Add User to the Role
$db.roles[$role].AddMember($User)
````
I created a little function to call in the script and then simply loop through our users and admins and call the function.
```` 
foreach ($User in $Users) {
    Add-UserToRole -Password $Password -User $user -Server $server -Role $Userrole -LoginType SQLLogin
}

foreach ($User in $Admins) {
    Add-UserToRole -Password $Password -User $user -Server $server -Role $adminrole -LoginType SQLLogin
}
````

To check that they have been added correctly I simply use the <A href="https://dbatools.io/Get-DbaDbRoleMember" target=_blank>Get-DbaRoleMember</A>;command from dbatools and output it to <A href="https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.utility/out-gridview" target=_blank>Out-GridView</A>&nbsp;using the alias ogv as I am on the command line:  
 
````
Get-DbaRoleMember -SqlInstance $server |ogv
````
which looks like this:
  
  ![get-dbarole-memebr](https://blog.robsewell.com/assets/uploads/2017/02/get-dbarole-memebr.png)

Once we need to clean up the logins and users we can use the <A href="https://msdn.microsoft.com/hu-hu/mt786484" target=_blank>Get-SQLLogin</A> and <A href="https://msdn.microsoft.com/hu-hu/mt786485" target=_blank>Remove-SQLLogin</A> commands from the sqlserver module to remove the logins and if we do that first we can then use the dbatools command <A href="https://dbatools.io/functions/remove-sqlorphanuser/" target=_blank>Remove-SQLOrphanuser</A> to remove the orphaned users 🙂 (I thought that was rather cunning!)  

````
(Get-SqlLogin -ServerInstance $server).Where{$_.Name -like '*Beard_Service_*'}|Remove-SqlLogin
Remove-SQLOrphanUser -SqlServer $Server -databases $database
````

The Remove-SQLLogin will prompt for confirmation and the result of the Remove-SQLOrphanUser looks like this  

![image](https://blog.robsewell.com/assets/uploads/2017/02/remove-them-all.png)

When you are looking at doing this type of automation with PowerShell, you should remember always to make use of <A href="https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.core/get-command" target=_blank>Get-Command</A>, <A href="https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.core/get-help" target=_blank>Get-Help</A> and <A href="https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.utility/get-member" target=_blank>Get-Member</A>. That will enable you to work out how to do an awful lot. I have a short video on youtube about this:  
  
{% include youtubePlayer.html id="zC-KpI89fkg" %}

and when you get stuck come and ask in the SQL Server Slack at <A href="https://sqlps.io/slack" target=_blank>https://sqlps.io/slack</A>. You will find a powershellhelp channel in there.  
Here is the complete code:  

````
#Requires -module sqlserver
#Requires -module dbatools

### Define some variables
$server = ''
$Password = "Password"
$Database = 'TheBeardsDatabase'
$Admins = Get-Content 'C:\temp\Admins.txt'
$Users = Get-Content 'C:\temp\Users.txt'
$LoginType = 'SQLLogin'
$userrole = &nbsp; 'Users'
$adminrole = 'Admin'

# Create a SQL Server SMO Object
$srv = Connect-DbaSqlServer -SqlServer $server
$db = $srv.Databases[$Database]

function Add-UserToRole {
    param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromRemainingArguments = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Password,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromRemainingArguments = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$User,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromRemainingArguments = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Server,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromRemainingArguments = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Role,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromRemainingArguments = $false)]
        [ValidateSet("SQLLogin", "WindowsGroup", "WindowsUser")]
        [string]$LoginType
    )

    if (!($srv.Logins.Contains($User))) {
        if ($LoginType -eq 'SQLLogin') {
            $Pass = ConvertTo-SecureString -String $Password -AsPlainText -Force
            $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $Pass
            Add-SqlLogin -ServerInstance $Server -LoginName $User -LoginType $LoginType -DefaultDatabase tempdb -Enable -GrantConnectSql -LoginPSCredential $Credential
        }
        elseif ($LoginType -eq 'WindowsGroup' -or $LoginType -eq 'WindowsUser') {
            Add-SqlLogin -ServerInstance $Server -LoginName $User -LoginType $LoginType -DefaultDatabase tempdb -Enable -GrantConnectSql
        }
    }
    if (!($db.Users.Contains($User))) {

        # Add user to database

        $usr = New-Object ('Microsoft.SqlServer.Management.Smo.User') ($db, $User)
        $usr.Login = $User
        $usr.Create()

    }
    #Add User to the Role
    $db.roles[$role].AddMember($User)
}

foreach ($User in $Users) {
    Add-UserToRole -Password $Password -User $user -Server $server -Role $Userrole -LoginType SQLLogin
}

foreach ($User in $Admins) {
    Add-UserToRole -Password $Password -User $user -Server $server -Role $adminrole -LoginType SQLLogin
}

Get-DbaRoleMember -SqlInstance $server | ogv
````
Happy Automating!


