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
    $code = Get-eBayAuthorizationCode -ClientID $ClientID -RUName $RUName
    $token = Get-eBayUserToken -ClientID $ClientID -ClientSecret $ClientSecret -RuName $RUName -AuthorizationCode $code.ToString()
    Save-eBayToken $token
}