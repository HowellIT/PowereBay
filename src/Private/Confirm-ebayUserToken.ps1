Function Confirm-eBayUserToken {
    Param(
        [ValidateNotNullOrEmpty()]
        [eBayAPI_OauthUserToken]$UserToken = $eBayAuthConfig.UserToken,
        [ValidateNotNullOrEmpty()]
        [eBayAPI_ClientCredentials]$ClientCredentials = $eBayAuthConfig.ClientCredentials
    )
    If(($UserToken.Expires -lt (Get-Date)) -and ($ClientCredentials)){
        Try{
            Update-eBayUserToken -Token $UserToken -Credentials $ClientCredentials
            $true
        }Catch{
            $false
        }
    }Else{
        $true
    }
}