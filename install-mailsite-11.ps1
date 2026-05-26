[CmdletBinding()]
param(
    [switch]$Uninstall,
    [string]$InstallDir11 = (Join-Path $env:ProgramFiles "MailSite"),
    [string]$PackagePath,
    [string]$PackageUrl = "https://github.com/rockliffe/mailsite-server-release/raw/main/MailSite.zip"
)

$ErrorActionPreference = "Stop"

function Invoke-MailSiteScript {
    param(
        [string]$LocalName,
        [string]$RemoteUrl,
        [hashtable]$Parameters
    )

    if (-not [string]::IsNullOrWhiteSpace($PSScriptRoot)) {
        $localPath = Join-Path $PSScriptRoot $LocalName
        if (Test-Path -LiteralPath $localPath) {
            & $localPath @Parameters
            return
        }
    }

    $scriptText = Invoke-RestMethod -Uri $RemoteUrl
    $scriptBlock = [ScriptBlock]::Create($scriptText)
    & $scriptBlock @Parameters
}

if ($Uninstall) {
    Invoke-MailSiteScript `
        -LocalName "uninstall-mailsite.ps1" `
        -RemoteUrl "https://raw.githubusercontent.com/rockliffe/mailsite-server-release/main/uninstall-mailsite.ps1" `
        -Parameters @{ InstallDir = $InstallDir11 }
} else {
    Invoke-MailSiteScript `
        -LocalName "install-mailsite.ps1" `
        -RemoteUrl "https://raw.githubusercontent.com/rockliffe/mailsite-server-release/main/install-mailsite.ps1" `
        -Parameters @{
            InstallDir = $InstallDir11
            PackagePath = $PackagePath
            PackageUrl = $PackageUrl
        }
}
