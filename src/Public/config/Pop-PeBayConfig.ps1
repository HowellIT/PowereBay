Function Pop-PeBayConfig {
    [cmdletbinding()]
    param (

    )
    if ($configStack.Count -ge 1) {
        $script:config = $configStack.Pop()
        if (-not($DontSave.IsPresent)) {
            Save-PeBayConfig
        }
    } else {
        Write-Warning "There is nothing in the config stack. Be sure to use 'Push-PeBayConfig' first."
    }
}