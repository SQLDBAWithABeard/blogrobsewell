---
title: "Alter SQL Mirroring Endpoint Owner with Powershell"
date: "2013-09-08" 
categories:
  - Blog

tags:
  - automate
  - automation
  - endpoint
  - mirroring
  - PowerShell
  - box-of-tricks

---
<P>Whilst using my Drop-SQLLogins function, which is one of my <A href="https://blog.robsewell.com/tags/#box-of-tricks" rel=noopener target=_blank>PowerShell Box Of Tricks </A>series, it failed to delete logins on some servers with the error</P>

>Login domain\user’ has granted one or more permissions. Revoke the permission before dropping the login (Microsoft SQL Server, Error: 15173)

<P>I used the <A href="https://blog.robsewell.com/sql-login-object-permissions-via-powershell" rel=noopener target=_blank>Show-SQLPermissions</A> function and added the .grantor property to try and locate the permission the account had granted but it came back blank. A bit of googling and <A href="http://en.wikipedia.org/wiki/Eureka_effect" rel=noopener target=_blank>a AHA moment</A>&nbsp;and I remembered mirroring</P>
<P>I checked the mirroring endpoints</P>

[![mirroring endpoitn check](https://blog.robsewell.com/assets/uploads/2013/09/mirroring-endpoitn-check.jpg)](https://blog.robsewell.com/assets/uploads/2013/09/mirroring-endpoitn-check.jpg)

<P>and found the endpoints with the user as the owner so I needed to change them</P>
<P>This can be done in T-SQL as follows</P>

[![alter endpoint](https://blog.robsewell.com/assets/uploads/2013/09/alter-endpoint.jpg)](https://blog.robsewell.com/assets/uploads/2013/09/alter-endpoint.jpg)

<P>but to do it on many endpoints it is easier to do it with Powershell</P>

[![alterendpointPS](https://blog.robsewell.com/assets/uploads/2013/09/alterendpointps.jpg)](https://blog.robsewell.com/assets/uploads/2013/09/alterendpointps.jpg)

<P>I could then drop the user successfully</P>


    $svrs = ## list of servers Get-Content from text fiel etc
    
    foreach ($svr in $svrs) {
        $server = New-Object Microsoft.SQLServer.Management.Smo.Server $svrs
        foreach ($endpoint in $server.Endpoints['Mirroring']) {
            if ($endpoint.Owner = 'Domain\User') {
                $endpoint.Owner = 'Domain\NEWUser'
                $endpoint.Alter()
            }        
        }
    }
