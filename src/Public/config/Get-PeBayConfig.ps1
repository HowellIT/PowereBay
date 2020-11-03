Function Get-PeBayConfig {
    [cmdletbinding()]
    param (
        [switch]$AsHashtable,
        [switch]$Silent
    )
    # Test to be sure the config variable exists as expected
    if ((Get-Variable config -Scope Script -ErrorAction SilentlyContinue) -and
        $config.psobject.TypeNames[0] -eq 'System.Collections.Hashtable' -and
        $config.Keys -contains 'Store' -and
        $config.Keys -contains 'Stores'
    ) {
        Write-Verbose '$config exists'
        # Output the config
        if (-not ($Silent.IsPresent)) {
            if ($AsHashtable.IsPresent){
                Write-Verbose 'Outputting as hashtable'
                $config
            } else {
                Write-Verbose 'Outputting as json'
                $config | ConvertTo-Json
            }
        }
    } else {
        Write-Verbose '$config does not exist'
        $path = Get-PeBayConfigPath
        if (Test-Path $path) {
            Write-Verbose 'Get-PeBayConfigPath exists'
            # Import the config
            $script:config = Get-Content $path | ConvertFrom-Json -AsHashtable
        } else {
            Write-Verbose 'Get-PeBayConfigPath does not exist'
            # Create the config
            New-PeBayConfig
            $params = @{
                Silent = $Silent.IsPresent
                AsHashtable = $AsHashtable.IsPresent
            }
            Get-PeBayConfig @params
        }
        if (-not($Silent.IsPresent)) {
            if ($AsHashtable.IsPresent){
                Write-Verbose 'Outputting as hashtable'
                $config
            } else {
                Write-Verbose 'Outputting as json'
                $config | ConvertTo-Json
            }
        }
    }
}