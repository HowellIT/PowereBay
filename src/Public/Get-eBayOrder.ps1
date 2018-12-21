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
        If($CreationDateStart){
            $creationDateFilter = 'creationdate:%5B{CreationDateStart}..{CreationDateEnd}%5D'
            $CreationDateStartUTC = Get-Date -Date $CreationDateStart.ToUniversalTime() -Format s
            $creationDateFilter = $creationDateFilter -replace '{CreationDateStart}',"$CreationDateStartUTC.000Z"
            If($CreationDateEnd){
                $CreationDateEndUTC = Get-Date -Date $CreationDateEnd.ToUniversalTime() -Format s
                $creationDateFilter = $creationDateFilter -replace '{CreationDateEnd}',"$CreationDateEndUTC.000Z"
            }Else{
                $creationDateFilter = $creationDateFilter -replace '{CreationDateEnd}',''
            }
        }ElseIf($LastModifiedDateStart){
            $lastModDateFilter = 'creationdate:%5B{LastModifiedDateStart}..{LastModifiedDateEnd}%5D'
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
        Write-Verbose "$baseUri`?$filter"
        $response = Invoke-RestMethod -Uri "$baseUri`?$strParameters" -Headers $headers
        $response.Orders
    }
}