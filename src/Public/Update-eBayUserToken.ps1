# https://developer.ebay.com/api-docs/static/oauth-refresh-token-request.html
Function Update-eBayUserToken {
    Param(
        [eBayAPI_OauthUserToken]$Token = $eBayAuthConfig.UserToken,
        [eBayAPI_ClientCredentials]$Credentials = $eBayAuthConfig.ClientCredentials,
        [string[]]$Scope = @('https://api.ebay.com/oauth/api_scope/sell.inventory','https://api.ebay.com/oauth/api_scope/sell.fulfillment')
    )
    $baseUri = 'https://api.ebay.com/identity/v1/oauth2/token'

    $encodedAuthorization = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$($Credentials.ClientID)`:$($Credentials.ClientSecret)"))
    $scopeString = $Scope -join '%20'

    # Build the headers
    $headers = @{
        'Content-Type' = 'application/x-www-form-urlencoded'
        Authorization = "Basic $encodedAuthorization"
    }

    # URL encode the parameters
    $encodedRefreshToken = [System.Web.HttpUtility]::UrlEncode($($Token.RefreshToken))
    $encodedRUName = [System.Web.HttpUtility]::UrlEncode($($Credentials.RUName))

    # Build the body using the URL encoded parameters
    $body = @(
        "grant_type=refresh_token"
        "&refresh_token=$encodedRefreshToken"
        "&scope=$scopeString"
    ) -join ''


    $newToken = Invoke-RestMethod -Method Post -Uri $baseUri -Body $body -Headers $headers
    If($newToken){
        $Token.Update($newToken)
        Save-eBayToken -Token $Token
    }
}