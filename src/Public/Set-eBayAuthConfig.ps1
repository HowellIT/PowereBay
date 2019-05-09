Function Set-eBayAuthConfig {
    param (
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
        [string]$RUName,
        [Parameter(
            Mandatory = $true
        )]
        [string]$RefreshToken,
        [Parameter(
            Mandatory = $true
        )]
        [datetime]$RefreshTokenExpirationDate,
        [Parameter()]
        [string]$UserToken,
        [Parameter()]
        [datetime]$UserTokenExpirationDate
    )
    $global:eBayAuthConfig = [PSCustomObject]@{
        UserToken = [eBayAPI_OauthUserToken]::new($UserToken,$UserTokenExpirationDate,$RefreshToken,$RefreshTokenExpirationDate)
        ClientCredentials = [eBayAPI_ClientCredentials]::new($ClientID,$ClientSecret,$RUName)
    }
}