Function Set-PeBayConfig {
    [cmdletbinding(
        SupportsShouldProcess,
        ConfirmImpact = 'Low'
    )]
    Param (
        [ValidateNotNullOrEmpty()]
        [ArgumentCompleter({
            $config['Stores'].Keys
        })]
        [string]$Store = $config['Store'],
        [string]$NewStoreName,
        [string]$AccessToken,
        [datetime]$TokenExpires,
        [string]$RefreshToken,
        [string]$ClientID,
        [string]$ClientSecret,
        [string]$RuName,
        [switch]$DontSave
    )
    $changed = $false

    foreach ($key in ($config['Stores'][$config['Store']].Keys | Where-Object {$PSBoundParameters.Keys -contains $_})) {
        if ($PSCmdlet.ShouldProcess($key)) {
            $script:config['Stores']["$Store"]["$key"] = $PSBoundParameters["$key"]
        }
        $changed = $true
    }

    foreach ($key in ($config['Module'].Keys | Where-Object {$PSBoundParameters.Keys -contains $_})) {
        if ($PSCmdlet.ShouldProcess($key)) {
            $script:config['Module']["$key"] = $PSBoundParameters["$key"]
        }
        $changed = $true
    }

    if ($PSBoundParameters.Keys -contains 'NewStoreName') {
        if ($PSCmdlet.ShouldProcess($key)) {
            $tmp = $config['Stores'][$Store]
            $config['Stores'].Remove($Store)
            $script:config['Stores'][$NewStoreName] = $tmp
            Set-PeBayRunningConfig -Store $NewStoreName
        }
        $changed = $true
    }

    if ($changed) {
        if(-not($DontSave.IsPresent)){
            Write-Verbose 'Saving'
            Save-PeBayConfig
        }
    }
}