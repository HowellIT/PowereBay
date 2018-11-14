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
    $encodedAuthorization = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes("$ClientID`:$ClientSecret")) #this is broken
    Write-Verbose $encodedAuthorization
    $headers = @{
        'Content-Type' = 'application/x-www-form-urlencoded'
        Authorization = "Basic SG93ZWxsSVQtRVNTSG93ZWwtUFJELTAyY2NiZGVlZS1mZWQwZjg4MzpQUkQtMmNjYmRlZWVmMjc5LTQ4MjgtNDAxZC1iNDQwLTkzNTU="
    }
    Write-Verbose $headers.ToString()

    $encodedAuthCode = [System.Web.HttpUtility]::UrlEncode($AuthorizationCode)
    $encodedRUName = [System.Web.HttpUtility]::UrlEncode($RuName)

    $body = @(
        "grant_type=authorization_code"
        "&code=$encodedAuthCode"
        "&redirect_uri=$encodedRUName"
    ) -join ''
    <#$body = @(
        "grant_type=authorization_code"
        "&code=$AuthorizationCode"
        "&redirect_uri=$RuName"
    )#>
    #$body = "grant_type=authorization_code&code=$([System.Web.HttpUtility]::ParseQueryString($AuthorizationCode))&redirect_uri=$([System.Web.HttpUtility]::ParseQueryString($RuName))"
    Write-Verbose $body.ToString()

    #Invoke-RestMethod -Uri $baseUri -Body $body -Headers $headers -Method Post
    Invoke-WebRequest -Uri $baseUri -Body $body -Headers $headers -Method Post
}