---
title: "PowerShell Pester Testing for Parameter Validation"
date: "2016-01-31"
categories:
  - PowerShell
tags:
  - "error"
  - "pester"
  - PowerShell
---

This error caught me out. I am putting this post here firstly to remind me if I do it again adn also to help others who may hit the same issue.

Today I am rewriting a function to create a Hyper-V VM so that I can properly script the creation of my labs for demos and other things. I am doing this because I want to use DSC to create an availability group and want to be able to tear down and recreate the machines (but thats for another day)

I also have been looking at [Pester](https://github.com/pester/Pester) which is a framework for running unit tests within PowerShell

You will find some good blog posts about starting with Pester [here](https://www.google.co.uk/search?q=PowerShell+pester+tutorial&ie=&oe=)

Here is the start of the function. I validate the VMName parameter to ensure that there a VM with that  name does not already exist

function Create-HyperVMFromBase {
[cmdletbinding()]
param (
 [Parameter(Mandatory = $true,HelpMessage="Enter a VMName for the VM that does not exist")] [ValidateScript({(!(Get-VM -Name $_))})]
[string]$VMName,

and my Pester test looks like this

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. {'$here\$sut'}

Describe "Create Hyper V from Base Tests" {
    Context "Parameter Values,Validations and Errors" {
        It exists {
        test-path function:\create-hypervmfrombase | should be $true
        }
        It "Should error when VMName exists" {
        $VMName = (Get-VM|Select -First 1 Name).Name
        create-hypervmfrombase -VMName $VMName |should throw
        }

I thought that what I was testing was that the function threw an error when an incorrect parameter was passed. The should throw should be true but what I got was

[![pester error3](../assets/uploads/2016/01/pester-error3_thumb.jpg "pester error3")](../assets/uploads/2016/01/pester-error3.jpg)

So I was getting the correct error but not passing the test. It was a simple fix. Simply adding curly braces around the call to the function

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"
Describe "Create Hyper V from Base Tests" {
    Context "Parameter Values,Validations and Errors" {
        It exists {
        test-path function:\create-hypervmfrombase | should be $true
        }
        It "Should error when VMName exists" {
        $VMName = (Get-VM|Select -First 1 Name).Name
        {create-hypervmfrombase -VMName $VMName} |should throw
        }
    }
}

and we pass the test.

[![pester success2](../assets/uploads/2016/01/pester-success2_thumb.jpg "pester success2")](../assets/uploads/2016/01/pester-success2.jpg)


