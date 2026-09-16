[CmdletBinding()]
param(
    [string]$InstallDir = (Join-Path $env:ProgramFiles 'MailSite'),
    [switch]$Yes,
    [string]$InstallerPath
)
$ErrorActionPreference = 'Stop'
# Standalone companion bootstrap: removal is implemented by the same Rust exe.
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
$temporaryDirectory = $null
try {
    if (-not $InstallerPath) {
        $installed = Join-Path $InstallDir 'mailsite-installer.exe'
        if (Test-Path -LiteralPath $installed -PathType Leaf) { $InstallerPath = $installed }
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
    $installerArguments = @('uninstall', '--install-dir', $InstallDir)
    if ($Yes) { $installerArguments += '--yes' }
    & $InstallerPath @installerArguments
    if ($LASTEXITCODE -ne 0) { throw "MailSite installer exited with code $LASTEXITCODE. Check its error above; contact support@mailsite.com if needed." }
} finally {
    if ($temporaryDirectory -and (Test-Path -LiteralPath $temporaryDirectory)) {
        $resolved = (Resolve-Path -LiteralPath $temporaryDirectory).ProviderPath
        $item = Get-Item -LiteralPath $resolved -Force
        if ($resolved -eq [IO.Path]::GetFullPath($temporaryDirectory) -and
            $item.Parent.FullName -eq [IO.Path]::GetTempPath().TrimEnd('\') -and
            -not ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
            Remove-Item -LiteralPath $resolved -Recurse -Force
        }
    }
}
