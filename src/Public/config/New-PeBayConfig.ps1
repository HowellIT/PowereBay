Function New-PeBayConfig {
    [cmdletbinding(
        SupportsShouldProcess,
        ConfirmImpact = 'None'
    )]
    Param (

    )
    if ($PSCmdlet.ShouldProcess("$PSScriptRoot\config.json")) {
        $script:config = Get-Content "$PSScriptRoot\config.json" | ConvertFrom-Json -AsHashtable
    }
    Save-PeBayConfig
}