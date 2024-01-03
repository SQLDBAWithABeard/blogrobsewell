---
title: "Flexing My Bicep - Reusable code with modules for deploying an Azure SQL Server"
date: "2021-05-21" 
categories:
  - Blog
  - Bicep
  - Automation
  - VS Code
tags:
 - Azure
 - SQL Server
 - IaC




image: https://datasaturdays.com/assets/design/twitter/c.twitter%201r.png
---

# Reusable code

We looked at a simple deployment of an Azure SQL Server and a database in the last blog post. You would like to reuse this code though, you will want to create more SQL Instances and SQL databases in the future. With Bicep, you can use modules and parameters to do this.

You can create a module for your SQL Instance. I look up [the resource information from the documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.sql/servers/databases?tabs=bicep?WT.mc_id=DP-MVP-5002693) and create a file named SQLInstance.bicep. I put it in a Resources directory.

# Parameters

At the top of the file you need to define parameters to enabled you to pass in different values for the deployment. You can find information about [Bicep parameters in the docs on GitHub](https://github.com/Azure/bicep/blob/main/docs/spec/parameters.md).

You define a parameter using the keyword `param`. At a minimum you need a name and a datatype. An obvious one for this usecase would be the name of the SQL Instance which could be defined as

````
param SqlInstanceName string
````

Perhaps your organisation has a requirement for all of the data to be stored in a particular region. You might want to have a default value for your location parameter. You can define a default parameter by assigning it with an equals sign.

````
param location string = 'northeurope'
````
Some parameters that you would like to use will only allow certain values. You can define those as follows
````
@allowed([
  'Enabled'
  'Disabled'
])
param transparentDataEncryption string = 'Enabled'
````

````
targetScope = 'resourceGroup'
param SqlInstanceName string
param location string = 'northeurope'
param tags object
param administratorLogin string
param administratorLoginPassword string
param minimalTlsVersion string = '1.0' // 1.0,1.1,1.2
param publicNetworkAccess string = 'Disabled' // 'Disabled','Enabled'
param ActiveDirectoryAdminUser string
param ActiveDirectoryAdminUserSid string
param tenantid string
param azureADOnlyAuthentication bool = false
param ExternalAdministratorPrincipalType string // User Application Group  

param sqlauditActionsAndGroups array  //BATCH_COMPLETED_GROUP,,SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP,FAILED_DATABASE_AUTHENTICATION_GROUP maybe some of these too but the logs will get large,APPLICATION_ROLE_CHANGE_PASSWORD_GROUP,BACKUP_RESTORE_GROUP,DATABASE_LOGOUT_GROUP,DATABASE_OBJECT_CHANGE_GROUP,DATABASE_OBJECT_OWNERSHIP_CHANGE_GROUP,DATABASE_OBJECT_PERMISSION_CHANGE_GROUP,DATABASE_OPERATION_GROUP,DATABASE_PERMISSION_CHANGE_GROUP,DATABASE_PRINCIPAL_CHANGE_GROUP,DATABASE_PRINCIPAL_IMPERSONATION_GROUP,DATABASE_ROLE_MEMBER_CHANGE_GROUP,FAILED_DATABASE_AUTHENTICATION_GROUP,SCHEMA_OBJECT_ACCESS_GROUP,SCHEMA_OBJECT_CHANGE_GROUP,SCHEMA_OBJECT_OWNERSHIP_CHANGE_GROUP,SCHEMA_OBJECT_PERMISSION_CHANGE_GROUP,SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP,USER_CHANGE_PASSWORD_GROUP,BATCH_STARTED_GROUP,BATCH_COMPLETED_GROUP

param SqldatabaseNames array
param dbSkuName string // for example GP_Gen5_2, BC_Gen5_10, HS_Gen5_8, P5, S0 etc
param collation string = 'SQL_Latin1_General_CP1_CI_AS' //
param maxSizeBytes int // The max size of the database expressed in bytes.
param zoneRedundant bool = false // 	Whether or not this database is zone redundant, which means the replicas of this database will be spread across multiple availability zones.
param licenseType string = 'LicenseIncluded' //	The license type to apply for this database. LicenseIncluded if you need a license, or BasePrice if you have a license and are eligible for the Azure Hybrid Benefit. - LicenseIncluded or BasePrice


resource sql 'Microsoft.Sql/servers@2020-11-01-preview' = {
  name: SqlInstanceName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    version: '12.0'
    minimalTlsVersion: minimalTlsVersion
    publicNetworkAccess: publicNetworkAccess
    administrators: {
      administratorType: 'ActiveDirectory'
      login: ActiveDirectoryAdminUser
      sid: ActiveDirectoryAdminUserSid
      tenantId: tenantid
      azureADOnlyAuthentication: azureADOnlyAuthentication
      principalType: ExternalAdministratorPrincipalType
    }
  }
}

// SQL Databases

resource symbolicname 'Microsoft.Sql/servers/databases@2020-11-01-preview' = [for item in SqldatabaseNames:{
  parent: sql
  name: '${item}'
  location: location
  tags: tags
  sku: {
    name: dbSkuName
  }
  properties: {
    collation: collation
    maxSizeBytes: maxSizeBytes
    zoneRedundant: zoneRedundant
    licenseType: licenseType
  }
}]
````


