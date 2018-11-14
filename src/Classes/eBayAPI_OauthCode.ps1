Class eBayAPI_OauthCode {
    [datetime]$Expires
    [string]$Code

    eBayAPI_OauthCode (
        [int]$expires_in,
        [string]$Code
    ){
        $this.Expires = (Get-Date).AddSeconds($expires_in)
        $this.Code = $Code
    }

    [bool]IsExpired(){
        return (Get-Date) -gt $this.Expires
    }
}