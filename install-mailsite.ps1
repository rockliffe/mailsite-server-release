[CmdletBinding()]
param(
    [Parameter(Position = 0)][string]$InstallTarget = 'latest',
    [string]$InstallDir = (Join-Path $env:ProgramFiles 'MailSite'),
    [string]$PackagePath,
    [string]$PackageUrl,
    [string]$LicenseApiBaseUrl,
    [switch]$GrantServiceControl,
    [switch]$SkipServiceControlGrant,
    [switch]$Yes,
    [string]$InstallerPath
)
$ErrorActionPreference = 'Stop'
# Only download and launch here. All product lifecycle behavior belongs to Rust.
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
$temporaryDirectory = $null
try {
    if (-not $InstallerPath -and $PSScriptRoot) {
        $sibling = Join-Path $PSScriptRoot 'mailsite-installer.exe'
        if (Test-Path -LiteralPath $sibling -PathType Leaf) { $InstallerPath = $sibling }
    }
    if (-not $InstallerPath) {
        $temporaryDirectory = Join-Path ([IO.Path]::GetTempPath()) ('MailSiteBootstrap-' + [guid]::NewGuid().ToString('N'))
        [void][IO.Directory]::CreateDirectory($temporaryDirectory)
        $InstallerPath = Join-Path $temporaryDirectory 'mailsite-installer.exe'
        $url = 'https://github.com/rockliffe/mailsite-server-release/releases/latest/download/mailsite-installer.exe'
        Write-Host 'Downloading MailSite installer...'
        Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $InstallerPath
    }
    $InstallerPath = (Resolve-Path -LiteralPath $InstallerPath).ProviderPath
    $installerArguments = @($InstallTarget, '--install-dir', $InstallDir)
    if ($PackagePath) { $installerArguments += @('--package-path', (Resolve-Path -LiteralPath $PackagePath).ProviderPath) }
    if ($PackageUrl) { $installerArguments += @('--package-url', $PackageUrl) }
    if ($LicenseApiBaseUrl) { $installerArguments += @('--license-api-base-url', $LicenseApiBaseUrl) }
    if ($GrantServiceControl) { $installerArguments += '--grant-service-control' }
    if ($SkipServiceControlGrant) { $installerArguments += '--skip-service-control-grant' }
    if ($Yes) { $installerArguments += '--yes' }
    & $InstallerPath @installerArguments
    if ($LASTEXITCODE -ne 0) { throw "MailSite installer exited with code $LASTEXITCODE. Check its error above; contact support@mailsite.com if needed." }
} finally {
    if ($temporaryDirectory -and (Test-Path -LiteralPath $temporaryDirectory)) {
        # Only the GUID directory created by this invocation beneath Windows temp.
        $resolved = (Resolve-Path -LiteralPath $temporaryDirectory).ProviderPath
        $item = Get-Item -LiteralPath $resolved -Force
        if ($resolved -eq [IO.Path]::GetFullPath($temporaryDirectory) -and
            $item.Parent.FullName -eq [IO.Path]::GetTempPath().TrimEnd('\') -and
            -not ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
            Remove-Item -LiteralPath $resolved -Recurse -Force
        }
    }
}
