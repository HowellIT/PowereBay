<#
    Code in this file will be added to the end of the .psm1. For example,
    you should set variables or other environment settings here.
#>
Get-ZCrmConfig -Silent
$script:configStack = [System.Collections.Stack]::new()