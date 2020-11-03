Function Get-eBayAccessToken {
    [cmdletbinding(
        DefaultParameterSetName = 'Refresh'
    )]
    param (
        [string]$RefreshToken = $config['Stores'][$config['Store']]['RefreshToken'],
        [string]$AuthorizationCode = $config['Stores'][$config['Store']]['AuthorizationCode'],
        [string]$ClientID = $config['Module']['ClientID'],
        [string]$ClientSecret = $config['Module']['ClientSecret'],
        [string]$RuName = $config['Module']['RuName']
    )

    $grantType = switch ($PSCmdlet.ParameterSetName) {
        'Refresh' {'refresh_token'}
    }

    $rUri = 'identity/v1/oauth2/token/'

    # Format for authorization header
    # Doc on auth format: https://developer.ebay.com/api-docs/static/oauth-base64-credentials.html
    $encodedAuthorization = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$ClientID`:$ClientSecret"))
    Write-Verbose $encodedAuthorization

    # Build the headers
    $headers = @{
        'Content-Type' = 'application/x-www-form-urlencoded'
        Authorization = "Basic $encodedAuthorization"
    }

    switch ($PSCmdlet.ParameterSetName) {
        'Refresh' {
            $encodedToken = [System.Web.HttpUtility]::UrlEncode($RefreshToken)
            $body = @(
                "grant_type=$grantType"
                "refresh_token=$encodedToken"
                "scope=https://api.ebay.com/oauth/api_scope/sell.inventory%20https://api.ebay.com/oauth/api_scope/sell.fulfillment"
            ) -join '&'
        }
        'Authorization' {
            $encodedToken = [System.Web.HttpUtility]::UrlEncode($AuthorizationCode)
            $encodedRUName = [System.Web.HttpUtility]::UrlEncode($RuName)
            $body = @(
                "grant_type=$grantType"
                "code=$encodedToken"
                "redirect_uri=$encodedRUName"
            ) -join '&'
        }
    }

    Invoke-eBayRestMethod -Method 'Post' -RelativeUri $rUri -Header $headers -Body $body -NoAuthorization

    <#if ($resp.error) {
        Write-Error $resp.error
    } else {
        Set-ZCrmConfig -AccessToken $resp.access_token -TokenExpires (Get-Date).AddSeconds($resp.expires_in)
    }#>
}