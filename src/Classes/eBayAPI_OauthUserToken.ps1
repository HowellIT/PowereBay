Class eBayAPI_OauthUserToken {
    [datetime]$Expires
    [string]$Token
    [string]$RefreshToken
    [string]$RefreshTokenExpires

    eBayAPI_OauthUserToken(
        [string]$access_token,
        [int]$expires_in,
        [string]$refresh_token,
        [int]$refresh_token_expires_in
    ){
        $this.Expires = (Get-Date).AddSeconds($expires_in)
        $this.Token = $access_token
        $this.RefreshToken = $refresh_token
        $this.RefreshTokenExpires = (Get-Date).AddSeconds($refresh_token_expires_in)
    }

    [string]ToString(){
        return $this.Token
    }

}