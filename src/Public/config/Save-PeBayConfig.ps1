Function Save-PeBayConfig {
    [cmdletbinding()]
    Param (
        [switch]$Force
    )
    $path = Get-PeBayConfigPath
    $dir = Split-Path $path
    if (-not(Test-Path $dir -PathType Container)) {
        New-Item $dir -ItemType Directory
    }
    if (-not(Test-Path $path -PathType Leaf)) {
        New-Item $path -ItemType File
    }
    if ($Force.IsPresent) {
        $config | ConvertTo-Json | Out-File $path -Force
    } else {
        $config | ConvertTo-Json | Out-File $path
    }
}