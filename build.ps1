[cmdletbinding()]
param(
    [string[]]$Task = 'ModuleBuild'
)

$DependentModules = @('PSDeploy','InvokeBuild') # pester
Foreach ($Module in $DependentModules){
    If (-not (Get-Module $module -ListAvailable)){
        Install-Module -name $Module -Scope CurrentUser
    }
    Import-Module $module -ErrorAction Stop
}

Invoke-Build $PSScriptRoot\PowereBay.build.ps1 -Task $Task
