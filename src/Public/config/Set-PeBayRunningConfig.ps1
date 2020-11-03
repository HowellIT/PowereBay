Function Set-PeBayRunningConfig {
    [cmdletbinding(
        SupportsShouldProcess,
        ConfirmImpact = 'Low'
    )]
    Param (
        [ArgumentCompleter({
            $config['Stores'].Keys
        })]
        [string]$Store
    )
    if ($PSCmdlet.ShouldProcess($Store)) {
        $config['Store'] = $Store
    }
}