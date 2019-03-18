Class eBayAPI_ClientCredentials {
    [string]$ClientID
    [string]$ClientSecret
    [string]$RUName

    eBayAPI_ClientCredentials(
        [string]$ClientID,
        [string]$ClientSecret,
        [string]$RUName
    ){
        $this.ClientID = $ClientID
        $this.ClientSecret = $ClientSecret
        $this.RUName = $RUName
    }
}
Class eBayAPI_OauthCode {
    [datetime]$Expires
    [string]$Code

    eBayAPI_OauthCode (
        [int]$expires_in,
        [string]$Code
    ){
        $this.Expires = (Get-Date).AddSeconds($expires_in)
        $this.Code = $Code
    }

    eBayAPI_OauthCode(
        [hashtable]$In
    ){
        If($In.ContainsKey('expires_in') -and $In.ContainsKey('code')){
            $this.Expires = (Get-Date).AddSeconds($In['expires_in'])
            $this.Code = $In['Code']
        }Else{
            Throw 'Improperly formatted hash table'
        }
    }

    [bool]IsExpired(){
        return (Get-Date) -gt $this.Expires
    }

    [string]ToString(){
        return $this.Code
    }
}
Class eBayAPI_OauthUserToken {
    [datetime]$Expires
    [string]$Token
    [string]$RefreshToken
    [string]$RefreshTokenExpires

    eBayAPI_OauthUserToken(
        [string]$access_token,
        [datetime]$expires,
        [string]$refresh_token,
        [datetime]$refresh_token_expires
    ){
        $this.Token = $access_token
        $this.Expires = $expires
        $this.RefreshToken = $refresh_token
        $this.RefreshTokenExpires = $refresh_token_expires
    }

    eBayAPI_OauthUserToken(
        [PSCustomObject]$In
    ){
        If(
            $In.PSObject.Properties.Name -contains 'access_token' -and
            $In.PSObject.Properties.Name -contains 'expires_in' -and
            $In.PSObject.Properties.Name -contains 'refresh_token' -and
            $In.PSObject.Properties.Name -contains 'refresh_token_expires_in'
        ){
            $this.Expires = (Get-Date).AddSeconds($In.expires_in)
            $this.Token = $In.access_token
            $this.RefreshToken = $In.refresh_token
            $this.RefreshTokenExpires = (Get-Date).AddSeconds($In.refresh_token_expires_in)
        }Else{
            Throw 'Improperly formatted object'
        }
    }

    [string]ToString(){
        return $this.Token
    }

    [void]Update(
        # Designed to accept the refresh token response
        [PSCustomObject]$In
    ){
        If(
            $In.PSObject.Properties.Name -contains 'access_token' -and
            $In.PSObject.Properties.Name -contains 'expires_in'
        ){
            $this.Expires = (Get-Date).AddSeconds($In.expires_in)
            $this.Token = $In.access_token
        }Else{
            Throw 'Improperly formatted object'
        }
    }
}
Function Get-eBayLocalToken {
    Param(
        [string]$RegistryPath = 'HKCU:\Software\PowereBay'
    )
    Function ConvertTo-PlainText{
        Param(
            [string]$string
        )
        $ss = ConvertTo-SecureString $string
        $creds = New-Object pscredential('eBay',$ss)
        $creds.GetNetworkCredential().Password
    }
    $properties = 'Expires','RefreshTokenExpires'
    $propertiesToConvert = 'Token','RefreshToken','ClientID','ClientSecret','RUName'
    [string[]]$combinedProperties = $properties+$propertiesToConvert
    $obj = Get-ItemProperty $RegistryPath | Select $combinedProperties
    ForEach($property in $propertiesToConvert){
        $obj."$property" = ConvertTo-PlainText $obj."$property"
    }
    $global:eBayAuthConfig = [PSCustomObject]@{
        UserToken = [eBayAPI_OauthUserToken]::new($obj.Token,$obj.Expires,$obj.RefreshToken,$obj.RefreshTokenExpires)
        ClientCredentials = [eBayAPI_ClientCredentials]::new($obj.ClientID,$obj.ClientSecret,$obj.RUName)
    }
    $eBayAuthConfig
}
#https://developer.ebay.com/api-docs/sell/fulfillment/resources/order/methods/getOrders
#https://developer.ebay.com/api-docs/sell/fulfillment/resources/order/methods/getOrder
Function Get-eBayOrder {
    [cmdletbinding(
        DefaultParameterSetName = 'MultipleOrders'
    )]
    Param(
        [string]$Token = $eBayAuthConfig.UserToken.Token, #should be replaced with some sort of global variable or something
        [Parameter(
            ParameterSetName = 'SingleOrder'
        )]
        [string]$OrderID,
        [Parameter(
            ParameterSetName = 'MultipleOrders'
        )]
        [string[]]$OrderIDs,
        #region filter options
        [datetime]$CreationDateStart,
        [datetime]$CreationDateEnd,
        [datetime]$LastModifiedDateStart,
        [datetime]$LastModifiedDateEnd,
        [ValidateSet('NOT_STARTED','IN_PROGRESS','FULFILLED')]
        [string]$OrderFulfillmentStatus,
        [ValidateRange(1,1000)]
        [int]$Limit
        #endregion
    )
    $baseUri = 'https://api.ebay.com/sell/fulfillment/v1/order'
    $headers = @{
        Authorization = "Bearer $token"
        Accept = 'application/json'
    }
    If($PSCmdlet.ParameterSetName -eq 'SingleOrder'){
        Invoke-RestMethod -Method Get -Uri "$baseUri/$OrderID" -Headers $headers
    }ElseIf($PSCmdlet.ParameterSetName -eq 'MultipleOrders'){
        # %5B and %5D are: [ ]
        # .000Z is added because the API spec requires it but PS doesn't add it by default with '-Format s'
        If($PSBoundParameters.ContainsKey('CreationDateStart')){
        #If($CreationDateStart){
            $creationDateFilter = 'creationdate:%5B{CreationDateStart}..{CreationDateEnd}%5D'
            $CreationDateStartUTC = Get-Date -Date $CreationDateStart.ToUniversalTime() -Format s
            $creationDateFilter = $creationDateFilter -replace '{CreationDateStart}',"$CreationDateStartUTC.000Z"
            If($CreationDateEnd){
                $CreationDateEndUTC = Get-Date -Date $CreationDateEnd.ToUniversalTime() -Format s
                $creationDateFilter = $creationDateFilter -replace '{CreationDateEnd}',"$CreationDateEndUTC.000Z"
            }Else{
                $creationDateFilter = $creationDateFilter -replace '{CreationDateEnd}',''
            }
        }ElseIf($PSBoundParameters.ContainsKey('LastModifiedDateStart')){
            $lastModDateFilter = 'lastmodifieddate:%5B{LastModifiedDateStart}..{LastModifiedDateEnd}%5D'
            $lastModDateStartUTC = Get-Date -Date $LastModifiedDateStart.ToUniversalTime() -Format s
            $lastModDateFilter = $lastModDateFilter -replace '{LastModifiedDateStart}',"$lastModDateStartUTC.000Z"
            If($LastModifiedDateEnd){
                $lastModDateEndUTC = Get-Date -Date $LastModifiedDateEnd.ToUniversalTime() -Format s
                $lastModDateFilter = $lastModDateFilter -replace '{LastModifiedDateEnd}',"$lastModDateEndUTC.000Z"
            }Else{
                $lastModDateFilter = $lastModDateFilter -replace '{LastModifiedDateEnd}',''
            }
        }
        $parameters = @()
        If($creationDateFilter){
            $parameters += "filter=$creationDateFilter"
        }ElseIf($lastModDateFilter){
            $parameters += "filter=$lastModDateFilter"
        }
        If($limit){
            $parameters += "limit=$Limit"
        }
        $strParameters = $parameters -join '&'
        Write-Verbose "$baseUri`?$strParameters"
        $response = Invoke-RestMethod -Uri "$baseUri`?$strParameters" -Headers $headers
        $response.Orders
    }
}
#https://developer.ebay.com/devzone/post-order/post-order_v2_return_search__get.html#overview
Function Get-eBayReturns {
    [cmdletbinding()]
    Param(
        [string]$Token = $eBayAuthConfig.UserToken.Token,
        [ValidateRange(1,200)]
        [int]$Limit = 25,
        [datetime]$CreationDateStart,
        [datetime]$CreationDateEnd
    )
    $baseUri = 'https://api.ebay.com/post-order/v2/return/search'
    $headers = @{
        Authorization = "IAF $token"
        Accept = 'application/json'
        'X-EBAY-C-MARKETPLACE-ID' = 'EBAY_US'
        'Content-Type' = 'application/json'
    }

    $params = @()

    If($Limit){
        $params += "limit=$Limit"
    }

    If($PSBoundParameters.ContainsKey('CreationDateStart')){
        $creationDateStartUTC = Get-Date -Date $CreationDateStart.ToUniversalTime() -Format s
        $params += "creation_date_range_from=$CreationDateStartUTC.000Z"
        If($CreationDateEnd){
            $creationDateEndUTC = Get-Date -Date $CreationDateEnd.ToUniversalTime() -Format s
            $params += "creation_date_range_to=$CreationDateEndUTC.000Z"
        }
    }

    $resource = "?$($params -join '&')"

    Write-Verbose "$baseUri$resource"
    $response = Invoke-RestMethod -Uri "$baseUri$resource" -Headers $headers
    $response.members
}
#https://developer.ebay.com/api-docs/sell/fulfillment/resources/order/shipping_fulfillment/methods/getShippingFulfillments
#https://developer.ebay.com/api-docs/sell/fulfillment/resources/order/shipping_fulfillment/methods/getShippingFulfillment
Function Get-eBayShippingFulfillment {
    Param(
        [string]$OrderID,
        [string]$FulfillmentID,
        [string]$Token = $eBayAuthConfig.UserToken.Token
    )
    $baseUri = 'https://api.ebay.com/sell/fulfillment/v1/order/{orderId}/shipping_fulfillment' -replace '{orderid}',$OrderID
    If($FulfillmentID){
        $baseUri = "$baseUri/$FulfillmentID"
    }
    $headers = @{
        Authorization = "Bearer $token"
        Accept = 'application/json'
    }
    Invoke-RestMethod -Method Get -Uri $baseUri -Headers $headers
}
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
    $creds = [eBayAPI_ClientCredentials]::new($ClientID,$ClientSecret,$RUName)
    $code = Get-eBayAuthorizationCode -ClientID $ClientID -RUName $RUName
    $token = Get-eBayUserToken -ClientID $ClientID -ClientSecret $ClientSecret -RuName $RUName -AuthorizationCode $code.ToString()
    Save-eBayToken $token
    Save-eBayCredentials $creds
}
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
Function Save-eBayCredentials {
    Param(
        [Parameter(
            Mandatory = $true
        )]
        [eBayAPI_ClientCredentials]$Creds,
        [string]$RegistryPath = 'HKCU:\Software\PowereBay'
    )
    If(-not(Test-Path $RegistryPath)){
        New-Item $RegistryPath
    }
    New-ItemProperty -Path $RegistryPath -Name 'ClientID' -Value (ConvertFrom-SecureString (ConvertTo-SecureString $Creds.ClientID -AsPlainText -Force)) -Force | Out-Null
    New-ItemProperty -Path $RegistryPath -Name 'ClientSecret' -Value (ConvertFrom-SecureString (ConvertTo-SecureString $Creds.ClientSecret -AsPlainText -Force)) -Force | Out-Null
    New-ItemProperty -Path $RegistryPath -Name 'RUName' -Value (ConvertFrom-SecureString (ConvertTo-SecureString $Creds.RUName -AsPlainText -Force)) -Force | Out-Null
}
Function Save-eBayToken {
    Param(
        [Parameter(
            Mandatory = $true
        )]
        [eBayAPI_OauthUserToken]$Token,
        [string]$RegistryPath = 'HKCU:\Software\PowereBay'
    )
    If(-not(Test-Path $RegistryPath)){
        New-Item $RegistryPath
    }
    New-ItemProperty -Path $RegistryPath -Name 'Expires' -Value $Token.Expires -Force | Out-Null
    New-ItemProperty -Path $RegistryPath -Name 'Token' -Value (ConvertFrom-SecureString (ConvertTo-SecureString $Token.Token -AsPlainText -Force)) -Force | Out-Null
    New-ItemProperty -Path $RegistryPath -Name 'RefreshToken' -Value (ConvertFrom-SecureString (ConvertTo-SecureString $Token.RefreshToken -AsPlainText -Force)) -Force | Out-Null
    New-ItemProperty -Path $RegistryPath -Name 'RefreshTokenExpires' -Value $Token.RefreshTokenExpires -Force | Out-Null
    Get-eBayLocalToken
}
