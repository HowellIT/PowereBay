Function Invoke-eBayRestMethod {
    [cmdletbinding()]
    param (
        [ValidateSet('Get','Post','Delete')]
        [string]$Method = 'Get',
        [string]$AccessToken = $config['Stores'][$config['Store']]['AccessToken'],
        [string]$RelativeUri,
        [hashtable]$Body,
        [string]$Query,
        [switch]$NoAuthorization
    )

    $headers = @{
        Authorization = "Bearer $token"
        Accept = 'application/json'
    }

    $uri = "https://api.ebay.com/$($RelativeUri.TrimStart('/'))"

    if ($PSBoundParameters.Keys -contains 'Query') {
        $uri = "$uri`?$Query"
    }

    Write-Verbose "URI: $uri"

    $splat = @{
        Method = $Method
        Uri = $uri
    }

    if (-not $NoAuthorization.IsPresent) {
        $splat['Headers'] = $headers
    }

    if ($Method -ne 'Get' -and $PSBoundParameters.Keys -contains 'Body') {
        $splat['Body'] = $Body | ConvertTo-Json -Compress
        $headers['Content-Type'] = 'application/json'
    }

    Write-Verbose "Headers: $($splat | ConvertTo-Json)"

    Invoke-RestMethod @splat
}