# PowereBay

THIS MODULE IS UNDER DEVELOPMENT. Use at your own risk. Parameter validation, data formatting, etc have not all been implemented as of this writing! Even some of the implemented cmdlets don't have all parameters implemented.

This module is designed to work with the eBay API. It is under development (PRs welcome!) and currently supports retrieving order and shipping information.

In this module's current state it can authenticate and query basic order and shipping info and as of this writing, only an experimental build has been done with some minor testing.

## How to set up
Download or clone this repo and:

```PowerShell
Import-Module $ModulePath\src\PowereBay.psm1
```

Before you can use this module, you must first register for an eBay developer account here: https://developer.ebay.com/signin

Once registered, retrieve your API keys here: https://developer.ebay.com/my/keys

You will need the Client ID and Client Secret from that screen.

Then retrieve the RUName from here: https://developer.ebay.com/my/auth/?env=production&index=0. You will need to expand 'Get a Token from eBay via Your Application' and there should be the 'RUName (eBay Redirect URL name)' value there.

## How to authenticate

With the above mentioned values, retrieve an user token (this will launch a window to have you authenticate to your eBay account):

```PowerShell
Invoke-eBayAuthentication -ClientID $ClientID -ClientSecret $ClientSecret -RUName $RUName
```

This will securely store the token in your registry and make it available to the other cmdlets.

## How to query

To get a single order from eBay:

```PowerShell
Get-eBayOrder -OrderID 'XXXXXXXXXXXX-XXXXXXXXXXXXX!XXXXXXXXXXXXXXX'
```

To get multiple orders based on creation date (it would be the same syntax for LastModifiedDate) with a limit of 100:

```PowerShell
Get-eBayOrder -CreationDateStart (Get-Date).AddMonths(-1) -CreationDateEnd (Get-Date).AddMonths(-1).AddDays(3) -Limit 100
```

To get an order's shipping fulfillment info:

```PowerShell
Get-eBayShippingFulfillment -OrderID 'XXXXXXXXXXXX-XXXXXXXXXXXXX!XXXXXXXXXXXXXXX'
```

To get information on a specific shipping fulfillment:

```PowerShell
Get-eBayShippingFulFillment -OrderID 'XXXXXXXXXXXX-XXXXXXXXXXXXX!XXXXXXXXXXXXXXX' -FulfillmentID 'XXXXXXXXXXXXXXXXXXXXXX'
```