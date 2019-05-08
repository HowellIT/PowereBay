$srcPath = "$PSScriptRoot\src"
$buildPath = "$PSScriptRoot\build"
$moduleName = "PowereBay_Core"
$modulePath = "$buildPath\$moduleName"
$author = 'Anthony Howell'
$version = '0.0.3'

task Clean {
    If(Get-Module $moduleName){
        Remove-Module $moduleName
    }
    If(Test-Path $buildPath){
        $null = Remove-Item $modulePath -Recurse -ErrorAction Ignore
    }
}

task ModuleBuild Clean, {
    $classFiles = Get-ChildItem "$srcPath\classes" -Filter *.ps1 -File
    $pubFiles = Get-ChildItem "$srcPath\public" -Filter *.ps1 -File
    $privFiles = Get-ChildItem "$srcPath\private" -Filter *.ps1 -File | Where-Object BaseName -ne 'Get-eBayAuthorizationCode'
    If(-not(Test-Path $modulePath)){
        New-Item $modulePath -ItemType Directory
    }
    ForEach($file in ($classFiles + $pubFiles + $privFiles)) {
        Get-Content $file.FullName | Out-File "$modulePath\$moduleName.psm1" -Append -Encoding utf8
    }
    Copy-Item "$srcPath\$moduleName.psd1" -Destination $modulePath

    $moduleManifestData = @{
        Author = $author
        Copyright = "(c) $((get-date).Year) $author. All rights reserved."
        Path = "$modulePath\$moduleName.psd1"
        FunctionsToExport = $pubFiles.BaseName
        RootModule = "$moduleName.psm1"
        ModuleVersion = $version
        ProjectUri = 'https://github.com/theposhwolf/PowereBay'
    }
    Update-ModuleManifest @moduleManifestData
    Import-Module $modulePath -RequiredVersion $version
}

task Publish {
    Invoke-PSDeploy -Path $PSScriptRoot -Force
}

task All ModuleBuild, Publish