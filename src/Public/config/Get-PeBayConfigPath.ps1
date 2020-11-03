Function Get-PeBayConfigPath {
    Param (
        $FileName = 'config.json'
    )
    if ($PSVersionTable.PSVersion.Major -ge 6) {
        if ($IsLinux) {
            $saveDir = $env:HOME
        } elseif ($IsWindows) {
            $saveDir = $env:USERPROFILE
        }
    } else {
        $saveDir = $env:USERPROFILE
    }
    "$saveDir\.powerebay\$FileName"
}