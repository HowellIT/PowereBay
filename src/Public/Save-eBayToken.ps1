Function Save-eBayToken {
    Param(
        [Parameter(
            Mandatory = $true
        )]
        [eBayAPI_OauthUserToken]$Token,
        [string]$RegistryPath = 'HKCU:\Software\PowereBay'
    )
    If(-not(Test-Path $RegistryPath)){
        New-Item $RegistryPath
    }
    New-ItemProperty -Path $RegistryPath -Name 'Expires' -Value $Token.Expires -Force | Out-Null
    New-ItemProperty -Path $RegistryPath -Name 'Token' -Value (ConvertFrom-SecureString (ConvertTo-SecureString $Token.Token -AsPlainText -Force)) -Force | Out-Null
    New-ItemProperty -Path $RegistryPath -Name 'RefreshToken' -Value (ConvertFrom-SecureString (ConvertTo-SecureString $Token.RefreshToken -AsPlainText -Force)) -Force | Out-Null
    New-ItemProperty -Path $RegistryPath -Name 'RefreshTokenExpires' -Value $Token.RefreshTokenExpires -Force | Out-Null
    Get-eBayLocalToken
}