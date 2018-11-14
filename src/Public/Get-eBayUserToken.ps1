Function Get-eBayUserToken {
    [cmdletbinding()]
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
        [string]$RuName,
        [Parameter(
            Mandatory = $true
        )]
        [string]$AuthorizationCode
    )
    # Base uri for getting user tokens
    $baseUri = 'https://api.ebay.com/identity/v1/oauth2/token/'

    # Format for authorization header
    # Doc on auth format: https://developer.ebay.com/api-docs/static/oauth-base64-credentials.html
    $encodedAuthorization = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$ClientID`:$ClientSecret"))
    Write-Verbose $encodedAuthorization

    # Build the headers
    $headers = @{
        'Content-Type' = 'application/x-www-form-urlencoded'
        Authorization = "Basic $encodedAuthorization"
    }
    Write-Verbose $headers.ToString()

    # URL encode the parameters
    $encodedAuthCode = [System.Web.HttpUtility]::UrlEncode($AuthorizationCode)
    $encodedRUName = [System.Web.HttpUtility]::UrlEncode($RuName)

    # Build the body using the URL encoded parameters
    $body = @(
        "grant_type=authorization_code"
        "&code=$encodedAuthCode"
        "&redirect_uri=$encodedRUName"
    ) -join ''
    Write-Verbose $body.ToString()

    # Send the request
    $response = Invoke-WebRequest -Uri $baseUri -Body $body -Headers $headers -Method Post

    # Return the response
    [eBayAPI_OauthUserToken]::new($($response.Content | ConvertFrom-Json))
}