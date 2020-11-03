Function Import-PeBayConfig {
    [CmdletBinding()]
    Param (

    )
    $script:configPath = "$PSScriptRoot\config.json"

    $script:config = Get-Content $configPath | ConvertFrom-Json -AsHashtable
}