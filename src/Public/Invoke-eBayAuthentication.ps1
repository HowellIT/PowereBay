Function Invoke-eBayAuthentication {
    Param(
        [Parameter(
            Mandatory = $true
        )]
        [string]$ClientID,
        [Parameter(
            Mandatory = $true
        )]
        [string]$ClientSecret,
        [Parameter(
            Mandatory = $true
        )]
        [string]$RUName
    )
    $creds = [eBayAPI_ClientCredentials]::new($ClientID,$ClientSecret,$RUName)
    $code = Get-eBayAuthorizationCode -ClientID $ClientID -RUName $RUName
    $token = Get-eBayUserToken -ClientID $ClientID -ClientSecret $ClientSecret -RuName $RUName -AuthorizationCode $code.ToString()
    Save-eBayToken $token
    Save-eBayCredentials $creds
}