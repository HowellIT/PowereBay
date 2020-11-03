Function Push-PeBayConfig {
    [cmdletbinding()]
    param (

    )
    $configStack.Push($config.Clone())
}