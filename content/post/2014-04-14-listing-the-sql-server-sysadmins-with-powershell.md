---
title: "Listing the SQL Server SysAdmins With PowerShell"
date: "2014-04-14" 
categories:
  - Blog

tags:
  - audit
  - permissions
  - PowerShell


image: /assets/uploads/2014/04/2014-04-12_152433.jpg


---
A very short blog today just to pass on this little script.

I was required to list all of the SysAdmins across a large estate. Obviously I turned to PowerShell 🙂

I iterated through my server list collection and then created a server SMO object and used the EnumServerRoleMembers method to display all of the sysadmin members

[![2014-04-12_152433](https://blog.robsewell.com/assets/uploads/2014/04/2014-04-12_152433.jpg)](https://blog.robsewell.com/assets/uploads/2014/04/2014-04-12_152433.jpg)

This will work on SQL2000 – SQL2012. You can see how you can easily change the rolename in the script to enumerate other server roles.

Another way you could do it is to use the query

    SELECT c.name AS Sysadmin_Server_Role_Members
    FROM sys.server_principals a
    INNER JOIN sys.server_role_members b
    ON a.principal_id = b.role_principal_id AND a.type = 'R' AND a.name ='sysadmin'
    INNER JOIN sys.server_principals c
    ON b.member_principal_id = c.principal_id


and pass that with `Invoke-SQLCMD` through to every server (if you had to use Powershell 🙂 ). That query won’t work with SQL 2000 though

