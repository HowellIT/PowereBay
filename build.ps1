#Requires -Modules psake
[cmdletbinding()]
param(
    [string[]]$Task = 'manual'
)

$DependentModules = @('Pester','Psake','PlatyPS')
Foreach ($Module in $DependentModules){
    If (-not (Get-Module $module -ListAvailable)){
        Install-Module -name $Module -Scope CurrentUser -Force
    }
    Import-Module $module -ErrorAction Stop
}
$env:ModuleTempDir = "C:\temp" #$env:TEMP
$env:ModuleName = "PowereBay"
$env:Author = "Anthony Howell"
$env:ModuleVersion = "0.0.2"
# Builds the module by invoking psake on the build.psake.ps1 script.
Invoke-PSake $PSScriptRoot\psake.ps1 -taskList $Task
