#https://developer.ebay.com/devzone/post-order/post-order_v2_return_search__get.html#overview
Function Get-eBayReturns {
    [cmdletbinding()]
    Param(
        [string]$Token = $eBayAuthConfig.UserToken.Token,
        [ValidateRange(1,200)]
        [int]$Limit
    )
    $baseUri = 'https://api.ebay.com/post-order/v2/return/search'
    $headers = @{
        Authorization = "IAF $token"
        Accept = 'application/json'
        'X-EBAY-C-MARKETPLACE-ID' = 'EBAY_US'
        'Content-Type' = 'application/json'
    }

    Write-Verbose "$baseUri"
    $response = Invoke-RestMethod -Uri "$baseUri" -Headers $headers
    $response.members
}