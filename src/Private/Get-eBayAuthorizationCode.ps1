Add-Type -AssemblyName System.Web
Add-Type -AssemblyName System.Windows.Forms
Function Get-eBayAuthorizationCode {
    [cmdletbinding()]
    Param(
        [Parameter(
            Mandatory = $true
        )]
        [string]$ClientID,
        [Parameter(
            Mandatory = $true
        )]
        [string]$RUName
    )
    <#
        Doc on flow: https://developer.ebay.com/api-docs/static/oauth-authorization-code-grant.html
    #>
    # URL encode our parameters
    $encodedClientID = [System.Web.HttpUtility]::UrlEncode($ClientID)
    $encodedRUName = [System.Web.HttpUtility]::UrlEncode($RUName)

    # Other variables
    $baseUri = 'https://auth.ebay.com/oauth2/authorize'
    $scope = 'https://api.ebay.com/oauth/api_scope/sell.inventory%20https://api.ebay.com/oauth/api_scope/sell.fulfillment'

    # Build the logon uri
    $logonUri = "$baseUri`?client_id=$encodedClientID&redirect_uri=$encodedRUName&response_type=code&scope=$scope&prompt=login"
    Write-Verbose "Logon URL: $logonUri"

    # Build a form to use with our web object
    $Form = New-Object -TypeName 'System.Windows.Forms.Form' -Property @{
        Width = 680
        Height = 640
    }

    # Build the web object to brows to the logon uri
    $Web = New-Object -TypeName 'System.Windows.Forms.WebBrowser' -Property @{
        Width = 680
        Height = 640
        Url = $logonUri
    }

    # Add the document completed script to detect when the code is in the uri
    $DocumentCompleted_Script = {
        if ($web.Url.AbsoluteUri -match "error=[^&]*|code=[^&]*") {
            $form.Close()
        }
    }

    # Add controls to the form
    $web.ScriptErrorsSuppressed = $true
    $web.Add_DocumentCompleted($DocumentCompleted_Script)
    $form.Controls.Add($web)
    $form.Add_Shown({ $form.Activate() })

    # Run the form
    [void]$form.ShowDialog()

    # Parse the output
    $QueryOutput = [System.Web.HttpUtility]::ParseQueryString($web.Url.Query)
    $Response = @{ }
    foreach ($key in $queryOutput.Keys) {
        $Response["$key"] = $QueryOutput[$key]
    }

    # Return the output
    # eventually this will be something more secure than just outputting it... I hope.
    If($Response['isAuthSuccessful']){
        [eBayAPI_OAuthCode]::new($Response)
    }Else{
        Throw 'Error'
    }
}