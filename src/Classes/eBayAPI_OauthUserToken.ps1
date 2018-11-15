Class eBayAPI_OauthUserToken {
    [datetime]$Expires
    [string]$Token
    [string]$RefreshToken
    [string]$RefreshTokenExpires

    eBayAPI_OauthUserToken(
        [string]$access_token,
        [datetime]$expires,
        [string]$refresh_token,
        [datetime]$refresh_token_expires
    ){
        $this.Token = $access_token
        $this.Expires = $expires
        $this.RefreshToken = $refresh_token
        $this.RefreshTokenExpires = $refresh_token_expires
    }

    eBayAPI_OauthUserToken(
        [PSCustomObject]$In
    ){
        If(
            $In.PSObject.Properties.Name -contains 'access_token' -and
            $In.PSObject.Properties.Name -contains 'expires_in' -and
            $In.PSObject.Properties.Name -contains 'refresh_token' -and
            $In.PSObject.Properties.Name -contains 'refresh_token_expires_in'
        ){
            $this.Expires = (Get-Date).AddSeconds($In.expires_in)
            $this.Token = $In.access_token
            $this.RefreshToken = $In.refresh_token
            $this.RefreshTokenExpires = (Get-Date).AddSeconds($In.refresh_token_expires_in)
        }Else{
            Throw 'Improperly formatted object'
        }
    }

    [string]ToString(){
        return $this.Token
    }

    [void]Update(
        # Designed to accept the refresh token response
        [PSCustomObject]$In
    ){
        If(
            $In.PSObject.Properties.Name -contains 'access_token' -and
            $In.PSObject.Properties.Name -contains 'expires_in'
        ){
            $this.Expires = (Get-Date).AddSeconds($In.expires_in)
            $this.Token = $In.access_token
        }Else{
            Throw 'Improperly formatted object'
        }
    }
}