Function Test-PeBayConfig {
    [cmdletbinding()]
    [OutputType([Bool])]
    Param (

    )

    $noErrors = $true

    if ($config['Stores'].Keys -notcontains $config['Store']) {
        Write-Error "Store '$($config['Store'])' is not present in the config."
        $noErrors = $false
    }

    if ($noErrors){
        $nonNullParams = 'AccessToken','AccessTokenExpires','RefreshToken','Location'
        foreach ($param in $nonNullParams) {
            if ($config['Stores'][$config['Store']][$param].Length -eq 0) {
                Write-Error "No value for '$param' for store '$($config['Store'])' in the config"
                $noErrors = $false
            }
        }
    }

    return $noErrors
}