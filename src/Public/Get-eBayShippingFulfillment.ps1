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