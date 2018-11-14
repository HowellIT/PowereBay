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
    $properties = 'Token','Expires','RefreshToken','RefreshTokenExpires'
    $obj = Get-ItemProperty $RegistryPath | Select $properties
    $obj.Token = ConvertTo-PlainText $obj.Token
    $obj.RefreshToken = ConvertTo-PlainText $obj.RefreshToken
    [eBayAPI_OauthUserToken]::new($obj.Token,$obj.Expires,$obj.RefreshToken,$obj.RefreshTokenExpires)
}