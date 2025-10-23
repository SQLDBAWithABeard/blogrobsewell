---
title: "Uploading a Source Folder to Azure File Storage"
date: "2015-02-01"

categories:
  - Blog
  - Azure
  - PowerShell
tags:
  - Azure
  - azure-file-storage
  - PowerShell
  - windows-azure
  - storage
---

Azure File Storage enables you to present an Azure Storage Account to your IaaS VMs as a share using SMB. You can fid out further details here

[http://azure.microsoft.com/en-gb/documentation/articles/storage-dotnet-how-to-use-files/](http://azure.microsoft.com/en-gb/documentation/articles/storage-dotnet-how-to-use-files/  "http://azure.microsoft.com/en-gb/documentation/articles/storage-dotnet-how-to-use-files/ ") 

Once you have created your Azure File Storage Account and connected your Azure Virtual Machines to it, you may need to upload data from your premises into the storage to enable it to be accessed by the Virtual Machines

To accomplish this I wrote a function and called it Upload-ToAzureFileStorage

I started by creating a source folder and files to test

```
New-Item -Path C:\\temp\\TestUpload\\New1 -ItemType Directory
New-Item -Path C:\\temp\\TestUpload\\New2 -ItemType Directory
New-Item -Path C:\\temp\\TestUpload\\New3 -ItemType Directory
New-Item -Path C:\\temp\\TestUpload\\New4 -ItemType Directory
New-Item -Path C:\\temp\\TestUpload\\New5 -ItemType Directory
New-Item -Path C:\\temp\\TestUpload\\New1\\list -ItemType Directory
New-Item -Path C:\\temp\\TestUpload\\New1\\list\\a -ItemType Directory
New-Item -Path C:\\temp\\TestUpload\\New1\\list\\b -ItemType Directory
New-Item -Path C:\\temp\\TestUpload\\New1\\list\\c -ItemType Directory
New-Item -Path C:\\temp\\TestUpload\\New1\\list\\d -ItemType Directory
New-Item -Path C:\\temp\\TestUpload\\New1\\list\\a\\1 -ItemType Directory
New-Item -Path C:\\temp\\TestUpload\\New1\\list\\a\\2 -ItemType Directory
New-Item -Path C:\\temp\\TestUpload\\New1\\list\\a\\3 -ItemType Directory
New-Item -Path C:\\temp\\TestUpload\\New1\\list\\a\\4 -ItemType Directory

New-Item -Path C:\\temp\\TestUpload\\New1\\file.txt -ItemType File
New-Item -Path C:\\temp\\TestUpload\\New2\\file.txt -ItemType File
New-Item -Path C:\\temp\\TestUpload\\New3\\file.txt -ItemType File
New-Item -Path C:\\temp\\TestUpload\\New4\\file.txt -ItemType File
New-Item -Path C:\\temp\\TestUpload\\New5\\file.txt -ItemType File
New-Item -Path C:\\temp\\TestUpload\\New1\\list\\file.txt -ItemType File
New-Item -Path C:\\temp\\TestUpload\\New1\\list\\a\\file.txt -ItemType File
New-Item -Path C:\\temp\\TestUpload\\New1\\list\\a\\1\\file.txt -ItemType File
New-Item -Path C:\\temp\\TestUpload\\New1\\list\\a\\2\\file.txt -ItemType File
New-Item -Path C:\\temp\\TestUpload\\New1\\list\\a\\3\\file.txt -ItemType File
New-Item -Path C:\\temp\\TestUpload\\New1\\list\\a\\4\\file.txt -ItemType File
```

Then we needed to connect to the subscription, get the storage account access key and create a context to store them

```
#Select Azure Subscription
Select-AzureSubscription -SubscriptionName $AzureSubscriptionName

# Get the Storage Account Key
$StorageAccountKey = (Get-AzureStorageKey -StorageAccountName $StorageAccountName).Primary

# create a context for account and key
$ctx=New-AzureStorageContext $StorageAccountName $StorageAccountKey
```

The [Get-AzureStorageShare  cmdlet](https://msdn.microsoft.com/en-us/library/dn806403.aspx?WT.mc_id=DP-MVP-5002693) shows the shares available for the context so we can check if the share exists

```$S = Get-AzureStorageShare -Context $ctx -ErrorAction SilentlyContinue|Where-Object {$\_.Name -eq $AzureShare}```

and if it doesnt exist create it using [New-AzureStorageShare](https://msdn.microsoft.com/en-us/library/dn806378.aspx?WT.mc_id=DP-MVP-5002693)

```
$s = New-AzureStorageShare $AzureShare -Context $ctx
```

For the sake only of doing it a different way we can check for existence of the directory in Azure File Storage that we are going to upload the files to like this

```
$d = Get-AzureStorageFile -Share $s -ErrorAction SilentlyContinue|select Name

if ($d.Name -notcontains $AzureDirectory)
```

and if it doesnt exist create it using [New-AzureStorageDirectory](https://msdn.microsoft.com/en-us/library/dn806385.aspx?WT.mc_id=DP-MVP-5002693)

```
$d = New-AzureStorageDirectory -Share $s -Path $AzureDirectory
```

Now that we have the directory created in the storage account we need to create any subfolders. First get the folders

```
\# get all the folders in the source directory
$Folders = Get-ChildItem -Path $Source -Directory -Recurse
```

We can then iterate through them using a foreach loop. If we do this and select the FullName property the results will be

```
C:\\temp\\TestUpload\\New1 C:\\temp\\TestUpload\\New2 C:\\temp\\TestUpload\\New3 C:\\temp\\TestUpload\\New4 C:\\temp\\TestUpload\\New5 C:\\temp\\TestUpload\\New1\\list C:\\temp\\TestUpload\\New1\\list\\a C:\\temp\\TestUpload\\New1\\list\\b C:\\temp\\TestUpload\\New1\\list\\c C:\\temp\\TestUpload\\New1\\list\\d C:\\temp\\TestUpload\\New1\\list\\a\\1 C:\\temp\\TestUpload\\New1\\list\\a\\2 C:\\temp\\TestUpload\\New1\\list\\a\\3 C:\\temp\\TestUpload\\New1\\list\\a\\4
```

but to create new folders we need to remove the `"C:\\temp\\TestUpload"` and replace it with the Directory name in Azure. I chose to do this as follows using the substring method and the length of the source folder path.

```
foreach($Folder in $Folders)
 {
 $f = ($Folder.FullName).Substring(($source.Length))
 $Path = $AzureDirectory + $f
 ```

and tested that the results came out as I wanted

```
AppName\\New1 AppName\\New2 AppName\\New3 AppName\\New4 AppName\\New5 AppName\\New1\\list AppName\\New1\\list\\a AppName\\New1\\list\\b AppName\\New1\\list\\c AppName\\New1\\list\\d AppName\\New1\\list\\a\\1 AppName\\New1\\list\\a\\2 AppName\\New1\\list\\a\\3 AppName\\New1\\list\\a\\4
```

I could then create the new folders in azure using [New-AzureStorageDirectory](https://msdn.microsoft.com/en-us/library/dn806385.aspx?WT.mc_id=DP-MVP-5002693) again

```
New-AzureStorageDirectory -Share $s -Path $Path -ErrorAction SilentlyContinue
```

I followed the same process with the files

```
$files = Get-ChildItem -Path $Source -Recurse -File</pre>
<pre>foreach($File in $Files)
 {
 $f = ($file.FullName).Substring(($Source.Length))
 $Path = $AzureDirectory + $f
 ```

and then created the files using [Set-AzureStorageFileContent](https://msdn.microsoft.com/en-us/library/dn806404.aspx?WT.mc_id=DP-MVP-5002693) this has a -Force and a -Confirm switch and I added those into my function by using a \[switch\] Parameter

```
#upload the files to the storage

 if($Confirm)
 {
 Set-AzureStorageFileContent -Share $s -Source $File.FullName -Path $Path -Confirm
 }
 else
 {
 Set-AzureStorageFileContent -Share $s -Source $File.FullName -Path $Path -Force
 }
 ```

You can download the function from the Script Center

[https://gallery.technet.microsoft.com/scriptcenter/Recursively-upload-a-bfb615fe](https://gallery.technet.microsoft.com/scriptcenter/Recursively-upload-a-bfb615fe?WT.mc_id=DP-MVP-5002693)

As also, any comments or queries are welcome and obviously the internet lies so please understand and test all code you find before using it in production
