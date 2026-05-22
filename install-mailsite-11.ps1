[CmdletBinding()]
param(
    [switch]$Uninstall,
    [string]$InstallDir11 = (Join-Path $env:ProgramFiles "MailSite"),
    [string]$PackagePath,
    [string]$PackageUrl = "https://github.com/rockliffe/mailsite-server-release/raw/main/MailSite.zip"
)

$ErrorActionPreference = "Stop"

$Services = @(
    @{ Name = "HTTPMA"; File = "httpma.exe" },
    @{ Name = "IMAP4A"; File = "imap4a.exe" },
    @{ Name = "SMTPRA"; File = "smtpra.exe" },
    @{ Name = "SMTPDA"; File = "smtpda.exe" }
)

$MailSiteKey32 = "HKLM:\SOFTWARE\Wow6432Node\Rockliffe\MailSite"
$InstallerStateName = "MailSite11InstallerState"
$InstallMarkerName = ".mailsite11-install.json"
$RequiredMajorVersion = "10"

function Assert-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "This installer must be run from an elevated PowerShell session."
    }
}

function Get-RegistryString {
    param(
        [string]$Path,
        [string]$Name
    )

    if (-not (Test-Path $Path)) {
        return $null
    }

    $value = (Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue).$Name
    if ([string]::IsNullOrWhiteSpace($value)) {
        return $null
    }

    return [string]$value
}

function Get-RegistryValue {
    param(
        [string]$Path,
        [string]$Name
    )

    if (-not (Test-Path $Path)) {
        return $null
    }

    return (Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue).$Name
}

function Assert-RegistryValuePresent {
    param(
        [string]$Path,
        [string]$Name
    )

    $value = Get-RegistryValue -Path $Path -Name $Name
    if ($null -eq $value -or ([string]$value).Length -eq 0) {
        throw "Required legacy MailSite registry value is missing: $Path\$Name."
    }
}

function Export-MailSiteRegistryBackup {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupPath = Join-Path ([IO.Path]::GetTempPath()) "MailSite-legacy-registry-$timestamp.reg"
    $output = & reg.exe export "HKLM\Software\Rockliffe\MailSite" $backupPath /reg:32 /y 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to export legacy MailSite registry backup: $output"
    }

    return $backupPath
}

function Import-MailSiteRegistryBackup {
    param([string]$BackupPath)

    if ([string]::IsNullOrWhiteSpace($BackupPath) -or -not (Test-Path $BackupPath)) {
        return
    }

    $output = & reg.exe import $BackupPath /reg:32 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Failed to import MailSite registry backup from ${BackupPath}: $output"
    }
}

function Set-MailSiteRegistryValue {
    param(
        [string]$Name,
        [string]$Value
    )

    New-Item -Path $MailSiteKey32 -Force | Out-Null
    if (Get-ItemProperty -Path $MailSiteKey32 -Name $Name -ErrorAction SilentlyContinue) {
        Set-ItemProperty -Path $MailSiteKey32 -Name $Name -Value $Value
    } else {
        New-ItemProperty -Path $MailSiteKey32 -Name $Name -Value $Value -PropertyType String -Force | Out-Null
    }
}

function Remove-MailSiteRegistryValue {
    param([string]$Name)

    if (Test-Path $MailSiteKey32) {
        Remove-ItemProperty -Path $MailSiteKey32 -Name $Name -ErrorAction SilentlyContinue
    }
}

function Get-ServiceImagePath {
    param([string]$ServiceName)

    $path = "HKLM:\SYSTEM\CurrentControlSet\Services\$ServiceName"
    if (-not (Test-Path $path)) {
        throw "Windows service '$ServiceName' is not installed."
    }

    return (Get-ItemProperty -Path $path -Name ImagePath).ImagePath
}

function Set-ServiceImagePath {
    param(
        [string]$ServiceName,
        [string]$ExecutablePath
    )

    $path = "HKLM:\SYSTEM\CurrentControlSet\Services\$ServiceName"
    Set-ItemProperty -Path $path -Name ImagePath -Value "`"$ExecutablePath`""
}

function Stop-MailSiteService {
    param([string]$ServiceName)

    $service = Get-Service -Name $ServiceName -ErrorAction Stop
    if ($service.Status -eq "Stopped") {
        return $false
    }

    Write-Host "Stopping $ServiceName..."
    Stop-Service -Name $ServiceName -Force -ErrorAction Stop
    $service.WaitForStatus("Stopped", [TimeSpan]::FromSeconds(60))
    return $true
}

function Start-MailSiteService {
    param([string]$ServiceName)

    Write-Host "Starting $ServiceName..."
    Start-Service -Name $ServiceName -ErrorAction Stop
}

function Copy-DirectoryAccessRules {
    param(
        [string]$SourceDirectory,
        [string]$DestinationDirectory
    )

    if (-not (Test-Path -LiteralPath $SourceDirectory -PathType Container)) {
        throw "Cannot copy permissions because source directory does not exist: $SourceDirectory"
    }
    if (-not (Test-Path -LiteralPath $DestinationDirectory -PathType Container)) {
        New-Item -ItemType Directory -Path $DestinationDirectory -Force | Out-Null
    }

    $sourceAcl = Get-Acl -LiteralPath $SourceDirectory
    $destinationAcl = Get-Acl -LiteralPath $DestinationDirectory

    $destinationAcl.SetAccessRuleProtection($true, $false)

    foreach ($rule in @($destinationAcl.Access)) {
        [void]$destinationAcl.RemoveAccessRuleSpecific($rule)
    }
    foreach ($rule in $sourceAcl.Access) {
        $destinationAcl.AddAccessRule($rule)
    }

    Set-Acl -LiteralPath $DestinationDirectory -AclObject $destinationAcl
}

function Get-ProductVersion {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        throw "Missing required executable: $Path"
    }

    $versionInfo = [Diagnostics.FileVersionInfo]::GetVersionInfo($Path)
    if (-not [string]::IsNullOrWhiteSpace($versionInfo.FileVersion)) {
        return $versionInfo.FileVersion.Trim()
    }
    return $versionInfo.ProductVersion.Trim()
}

function Assert-MailSite10 {
    if (-not (Test-Path $MailSiteKey32)) {
        throw "This installation of MailSite 11 requires an existing 32-bit MailSite $RequiredMajorVersion.x registry key at $MailSiteKey32."
    }

    foreach ($name in @("Version", "InstallDir", "ClusterVariant", "RegistryFormatVersion", "ServerMajorVersion", "License")) {
        Assert-RegistryValuePresent -Path $MailSiteKey32 -Name $name
    }

    $version = Get-RegistryString -Path $MailSiteKey32 -Name "Version"
    if ([string]::IsNullOrWhiteSpace($version) -or -not $version.StartsWith("$RequiredMajorVersion.")) {
        throw "This installation of MailSite 11 requires an existing MailSite $RequiredMajorVersion.x installation. Found registry version '$version'."
    }

    $legacyInstallDir = Get-RegistryString -Path $MailSiteKey32 -Name "InstallDir"
    $clusterVariant = Get-RegistryValue -Path $MailSiteKey32 -Name "ClusterVariant"
    if ($clusterVariant -eq 4) {
        $sqlConnectorKey = Join-Path $MailSiteKey32 "SqlConnector"
        foreach ($name in @("DataSourceName", "DataSourceUser", "DataSourcePass", "ServerRole")) {
            Assert-RegistryValuePresent -Path $sqlConnectorKey -Name $name
        }
    }

    foreach ($service in $Services) {
        $exe = Join-Path $legacyInstallDir $service.File
        $fileVersion = Get-ProductVersion -Path $exe
        if ([string]::IsNullOrWhiteSpace($fileVersion) -or -not $fileVersion.StartsWith("$RequiredMajorVersion.")) {
            throw "This installation of MailSite 11 requires $($service.Name) from MailSite $RequiredMajorVersion.x. Found '$fileVersion' at $exe."
        }
    }

    return $legacyInstallDir
}

function Resolve-PackagePath {
    if (-not [string]::IsNullOrWhiteSpace($PackagePath)) {
        if (-not (Test-Path $PackagePath)) {
            throw "PackagePath does not exist: $PackagePath"
        }
        return (Resolve-Path $PackagePath).Path
    }

    $sibling = Join-Path $PSScriptRoot "MailSite.zip"
    if (Test-Path $sibling) {
        return (Resolve-Path $sibling).Path
    }

    $downloadPath = Join-Path ([IO.Path]::GetTempPath()) "MailSite.zip"
    Write-Host "Downloading MailSite package from $PackageUrl..."
    try {
        Invoke-WebRequest -Uri $PackageUrl -OutFile $downloadPath -UseBasicParsing
        return $downloadPath
    } catch {
        throw "Could not download MailSite package from $PackageUrl. Run package.sh locally and pass -PackagePath, or publish MailSite.zip to the release repository."
    }
}

function Get-PackageRoot {
    param([string]$ExtractRoot)

    $required = @("httpma.exe", "imap4a.exe", "smtpra.exe", "smtpda.exe")
    $hasExecutables = $required | Where-Object { Test-Path (Join-Path $ExtractRoot $_) }
    if ($hasExecutables.Count -eq $required.Count) {
        return $ExtractRoot
    }

    $children = Get-ChildItem -Path $ExtractRoot -Directory
    if ($children.Count -eq 1) {
        return $children[0].FullName
    }

    throw "Could not determine package root after extracting $ExtractRoot."
}

function Save-InstallerState {
    param([hashtable]$State)

    $json = $State | ConvertTo-Json -Depth 5
    Set-MailSiteRegistryValue -Name $InstallerStateName -Value $json
    $markerPath = Join-Path $InstallDir11 $InstallMarkerName
    Set-Content -Path $markerPath -Value $json -Encoding UTF8
}

function Load-InstallerState {
    $json = Get-RegistryString -Path $MailSiteKey32 -Name $InstallerStateName
    if ([string]::IsNullOrWhiteSpace($json)) {
        throw "MailSite 11 installer state was not found. Cannot safely uninstall."
    }

    return $json | ConvertFrom-Json
}

function Install-MailSite11 {
    $legacyInstallDir = Assert-MailSite10

    $package = Resolve-PackagePath
    $extractRoot = Join-Path ([IO.Path]::GetTempPath()) ("MailSite11-" + [Guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path $extractRoot -Force | Out-Null
    $state = $null
    $servicesStopped = $false

    try {
        Write-Host "Extracting $package..."
        Expand-Archive -Path $package -DestinationPath $extractRoot -Force
        $packageRoot = Get-PackageRoot -ExtractRoot $extractRoot

        $state = @{
            InstalledAtUtc = [DateTimeOffset]::UtcNow.ToString("o")
            InstallDir11 = $InstallDir11
            RegistryBackupPath = Export-MailSiteRegistryBackup
            PreviousImagePath = @{}
            WasRunning = @{}
        }

        foreach ($service in $Services) {
            $state.PreviousImagePath[$service.Name] = Get-ServiceImagePath -ServiceName $service.Name
            $state.WasRunning[$service.Name] = Stop-MailSiteService -ServiceName $service.Name
        }
        $servicesStopped = $true

        Write-Host "Installing MailSite 11 files to $InstallDir11..."
        New-Item -ItemType Directory -Path $InstallDir11 -Force | Out-Null
        Write-Host "Copying directory permissions from $legacyInstallDir to $InstallDir11..."
        Copy-DirectoryAccessRules -SourceDirectory $legacyInstallDir -DestinationDirectory $InstallDir11
        Copy-Item -Path (Join-Path $packageRoot "*") -Destination $InstallDir11 -Recurse -Force

        Set-MailSiteRegistryValue -Name "InstallDir11" -Value $InstallDir11
        Save-InstallerState -State $state

        foreach ($service in $Services) {
            $newExe = Join-Path $InstallDir11 $service.File
            if (-not (Test-Path $newExe)) {
                throw "Package did not install $newExe."
            }
            Set-ServiceImagePath -ServiceName $service.Name -ExecutablePath $newExe
        }

        Write-Host "MailSite 11 installation completed successfully. Services were left stopped; start them manually after verification."
    } catch {
        if ($servicesStopped -and $null -ne $state) {
            Write-Host "Install failed. Restoring previous service paths and registry backup..."
            foreach ($service in $Services) {
                $previous = $state.PreviousImagePath[$service.Name]
                if (-not [string]::IsNullOrWhiteSpace($previous)) {
                    $path = "HKLM:\SYSTEM\CurrentControlSet\Services\$($service.Name)"
                    Set-ItemProperty -Path $path -Name ImagePath -Value $previous
                }
            }
            Import-MailSiteRegistryBackup -BackupPath $state.RegistryBackupPath
        }
        Remove-MailSiteRegistryValue -Name "InstallDir11"
        Remove-MailSiteRegistryValue -Name $InstallerStateName
        throw
    } finally {
        Remove-Item -Path $extractRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function Uninstall-MailSite11 {
    $state = Load-InstallerState
    $installedDir = $state.InstallDir11
    if ([string]::IsNullOrWhiteSpace($installedDir)) {
        $installedDir = $InstallDir11
    }

    foreach ($service in $Services) {
        Stop-MailSiteService -ServiceName $service.Name | Out-Null
    }

    foreach ($service in $Services) {
        $previous = $state.PreviousImagePath.($service.Name)
        if (-not [string]::IsNullOrWhiteSpace($previous)) {
            $path = "HKLM:\SYSTEM\CurrentControlSet\Services\$($service.Name)"
            Set-ItemProperty -Path $path -Name ImagePath -Value $previous
        }
    }

    foreach ($service in $Services) {
        if ($state.WasRunning.($service.Name)) {
            Start-MailSiteService -ServiceName $service.Name
        }
    }

    Remove-MailSiteRegistryValue -Name "InstallDir11"
    Remove-MailSiteRegistryValue -Name $InstallerStateName

    $markerPath = Join-Path $installedDir $InstallMarkerName
    if ((Test-Path $markerPath) -and (Test-Path $installedDir)) {
        Write-Host "Removing MailSite 11 files from $installedDir..."
        Remove-Item -Path $installedDir -Recurse -Force
    }

    Write-Host "MailSite 11 uninstall completed successfully."
}

Assert-Administrator

if ($Uninstall) {
    Uninstall-MailSite11
} else {
    Install-MailSite11
}
