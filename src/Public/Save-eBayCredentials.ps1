Function Save-eBayCredentials {
    Param(
        [Parameter(
            Mandatory = $true
        )]
        [eBayAPI_ClientCredentials]$Creds,
        [string]$RegistryPath = 'HKCU:\Software\PowereBay'
    )
    If(-not(Test-Path $RegistryPath)){
        New-Item $RegistryPath
    }
    New-ItemProperty -Path $RegistryPath -Name 'ClientID' -Value (ConvertFrom-SecureString (ConvertTo-SecureString $Creds.ClientID -AsPlainText -Force)) -Force | Out-Null
    New-ItemProperty -Path $RegistryPath -Name 'ClientSecret' -Value (ConvertFrom-SecureString (ConvertTo-SecureString $Creds.ClientSecret -AsPlainText -Force)) -Force | Out-Null
    New-ItemProperty -Path $RegistryPath -Name 'RUName' -Value (ConvertFrom-SecureString (ConvertTo-SecureString $Creds.RUName -AsPlainText -Force)) -Force | Out-Null
}