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