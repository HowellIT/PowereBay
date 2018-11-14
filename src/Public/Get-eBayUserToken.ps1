Function Get-eBayUserToken {
    [cmdletbinding()]
    Param(
        [string]$ClientID,
        [string]$ClientSecret,
        [string]$RuName,
        [string]$AuthorizationCode
    )
    $baseUri = 'https://api.ebay.com/identity/v1/oauth2/token/'
    # Doc on auth format: https://developer.ebay.com/api-docs/static/oauth-base64-credentials.html
    $encodedAuthorization = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$ClientID`:$ClientSecret")) #this is broken
    Write-Verbose $encodedAuthorization
    $headers = @{
        'Content-Type' = 'application/x-www-form-urlencoded'
        Authorization = "Basic $encodedAuthorization"
    }
    Write-Verbose $headers.ToString()

    $encodedAuthCode = [System.Web.HttpUtility]::UrlEncode($AuthorizationCode)
    $encodedRUName = [System.Web.HttpUtility]::UrlEncode($RuName)

    $body = @(
        "grant_type=authorization_code"
        "&code=$encodedAuthCode"
        "&redirect_uri=$encodedRUName"
    ) -join ''
    Write-Verbose $body.ToString()

    #Invoke-RestMethod -Uri $baseUri -Body $body -Headers $headers -Method Post
    $response = Invoke-WebRequest -Uri $baseUri -Body $body -Headers $headers -Method Post
    $response.Content | ConvertFrom-Json
}