Function Get-eBayAuthenticationCode {
    [cmdletbinding()]
    Param(
        [string]$ClientID,
        [string]$RUName
    )
    <#
        Doc on flow: https://developer.ebay.com/api-docs/static/oauth-authorization-code-grant.html
        Doc on auth format: https://developer.ebay.com/api-docs/static/oauth-base64-credentials.html
    #>
    #$encodedAuthorization = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes("$ClientID`:$ClientSecret"))
    $encodedClientID = [System.Web.HttpUtility]::UrlEncode($ClientID)
    $encodedRUName = [System.Web.HttpUtility]::UrlEncode($RUName)
    $baseUri = 'https://auth.ebay.com/oauth2/authorize'
    $scope = 'https://api.ebay.com/oauth/api_scope/sell.inventory'
    $logonUri = "$baseUri`?client_id=$encodedClientID&redirect_uri=$encodedRUName&response_type=code&scope=$scope&prompt=login"
    Write-Verbose "Logon URL: $logonUri"
    $Form = New-Object -TypeName 'System.Windows.Forms.Form' -Property @{
        Width = 680
        Height = 640
    }
    $Web = New-Object -TypeName 'System.Windows.Forms.WebBrowser' -Property @{
        Width = 680
        Height = 640
        Url = $logonUri
    }
    $DocumentCompleted_Script = {
        if ($web.Url.AbsoluteUri -match "error=[^&]*|code=[^&]*") {
            $form.Close()
        }
    }
    $web.ScriptErrorsSuppressed = $true
    $web.Add_DocumentCompleted($DocumentCompleted_Script)
    $form.Controls.Add($web)
    $form.Add_Shown({ $form.Activate() })
    [void]$form.ShowDialog()

    $QueryOutput = [System.Web.HttpUtility]::ParseQueryString($web.Url.Query)
    $Response = @{ }
    foreach ($key in $queryOutput.Keys) {
        $Response["$key"] = $QueryOutput[$key]
    }
    If($Response['isAuthSuccessful']){
        $Response['code']
    }Else{
        Throw 'Error'
    }
}