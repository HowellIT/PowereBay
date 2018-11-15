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