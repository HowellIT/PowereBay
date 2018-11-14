# PowereBay

THIS MODULE IS UNDER DEVELOPMENT. Use at your own risk. Parameter validation, data formatting, etc have not been implemented as of this writing! Even some of the implemented cmdlets don't have all parameters implemented.

This module is designed to work with the eBay API. It is under development (PRs welcome!) and currently supports retrieving order and shipping information.

I plan to add classes to manage the retrieved data better, but in the current state it can authenticate and query basic order and shipping info.

As of this writing, no builds have been done and the module has not yet been published.

## How to set up
You must first register for an eBay developer account here: https://developer.ebay.com/signin

Once registered, retrieve your API keys here: https://developer.ebay.com/my/keys

You will need the Client ID and Client Secret from that screen.

Then retrieve the RUName from here: https://developer.ebay.com/my/auth/?env=production&index=0. You will need to expand 'Get a Token from eBay via Your Application' and there should be the 'RUName (eBay Redirect URL name)' value there.

## How to authenticate

With the above mentioned values, retrieve an authorization code (this will launch a window to have you authenticate to your eBay account) and use it to get a user token:

```PowerShell
$authCode = Get-eBayAuthenticationCode -ClientID $ClientID -RUName $RUName
$userToken = Get-eBayUserToken -ClientID $ClientID -ClientSecret $ClientSecret -RUName $RUName -AuthorizationCode $authCode
```

## How to query

To get a single order from eBay:

```PowerShell
Get-eBayOrder -OrderID 'XXXXXXXXXXXX-XXXXXXXXXXXXX!XXXXXXXXXXXXXXX' -Token $userToken.access_token
```

To get multiple orders based on creation date:

```PowerShell
Get-eBayOrder -CreationDateStart (Get-Date).AddMonths(-1) -CreationDateEnd (Get-Date).AddMonths(-1).AddDays(3) -Token $userToken.access_token
```

To get an order's shipping fulfillment info:

```PowerShell
Get-eBayShippingFulfillment -OrderID 'XXXXXXXXXXXX-XXXXXXXXXXXXX!XXXXXXXXXXXXXXX' -Token $userToken.access_token
```

To get information on a specific shipping fulfillment:

```PowerShell
Get-eBayShippingFulFillment -OrderID 'XXXXXXXXXXXX-XXXXXXXXXXXXX!XXXXXXXXXXXXXXX' -FulfillmentID 'XXXXXXXXXXXXXXXXXXXXXX' -Token $userToken.access_token
```