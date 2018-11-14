#https://developer.ebay.com/api-docs/sell/fulfillment/resources/order/methods/getOrders
#https://developer.ebay.com/api-docs/sell/fulfillment/resources/order/methods/getOrder
Function Get-eBayOrder {
    [cmdletbinding(
        DefaultParameterSetName = 'MultipleOrders'
    )]
    Param(
        [string]$Token, #should be replaced with some sort of global variable or something
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
        [string]$OrderFulfillmentStatus
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
        $CreationDateStartUTC = Get-Date -Date $CreationDateStart.ToUniversalTime() -Format s
        $filter = "filter=creationdate:%5B$CreationDateStartUTC.000Z..%5D"
        Write-Verbose "$baseUri`?$filter"
        Invoke-RestMethod -Uri "$baseUri`?$filter" -Headers $headers
    }
}