Class eBayAPI_ClientCredentials {
    [string]$ClientID
    [string]$ClientSecret
    [string]$RUName

    eBayAPI_ClientCredentials(
        [string]$ClientID,
        [string]$ClientSecret,
        [string]$RUName
    ){
        $this.ClientID = $ClientID
        $this.ClientSecret = $ClientSecret
        $this.RUName = $RUName
    }
}