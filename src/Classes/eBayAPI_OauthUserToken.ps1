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

    eBayAPI_OauthUserToken(
        [hashtable]$In
    ){
        If(
            $In.ContainsKey('access_token') -and
            $In.ContainsKey('expires_in') -and
            $In.ContainsKey('refresh_token') -and
            $In.ContainsKey('refresh_token_expires_in')
        ){
            $this.Expires = (Get-Date).AddSeconds($In['expires_in'])
            $this.Token = $In['access_token']
            $this.RefreshToken = $In['refresh_token']
            $this.RefreshTokenExpires = (Get-Date).AddSeconds($In['refresh_token_expires_in'])
        }Else{
            Throw 'Improperly formatted hash table'
        }
    }

    [string]ToString(){
        return $this.Token
    }

}