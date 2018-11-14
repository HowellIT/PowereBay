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

    eBayAPI_OauthCode(
        [hashtable]$In
    ){
        If($In.ContainsKey('expires_in') -and $In.ContainsKey('code')){
            $this.Expires = (Get-Date).AddSeconds($In['expires_in'])
            $this.Code = $In['Code']
        }Else{
            Throw 'Improperly formatted hash table'
        }
    }

    [bool]IsExpired(){
        return (Get-Date) -gt $this.Expires
    }

    [string]ToString(){
        return $this.Code
    }
}