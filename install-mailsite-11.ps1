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

$MailSiteKey64 = "HKLM:\SOFTWARE\Rockliffe\MailSite"
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

function Set-MailSiteRegistryValue {
    param(
        [string]$Name,
        [string]$Value
    )

    foreach ($path in @($MailSiteKey64, $MailSiteKey32)) {
        New-Item -Path $path -Force | Out-Null
        New-ItemProperty -Path $path -Name $Name -Value $Value -PropertyType String -Force | Out-Null
    }
}

function Remove-MailSiteRegistryValue {
    param([string]$Name)

    foreach ($path in @($MailSiteKey64, $MailSiteKey32)) {
        if (Test-Path $path) {
            Remove-ItemProperty -Path $path -Name $Name -ErrorAction SilentlyContinue
        }
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
    $version = Get-RegistryString -Path $MailSiteKey32 -Name "Version"
    if ([string]::IsNullOrWhiteSpace($version) -or -not $version.StartsWith("$RequiredMajorVersion.")) {
        throw "This installation of MailSite 11 requires an existing MailSite $RequiredMajorVersion.x installation. Found registry version '$version'."
    }

    $legacyInstallDir = Get-RegistryString -Path $MailSiteKey32 -Name "InstallDir"
    if ([string]::IsNullOrWhiteSpace($legacyInstallDir)) {
        throw "Could not read legacy MailSite InstallDir from $MailSiteKey32."
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
        $json = Get-RegistryString -Path $MailSiteKey64 -Name $InstallerStateName
    }
    if ([string]::IsNullOrWhiteSpace($json)) {
        throw "MailSite 11 installer state was not found. Cannot safely uninstall."
    }

    return $json | ConvertFrom-Json
}

function Install-MailSite11 {
    Assert-MailSite10 | Out-Null

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

        foreach ($service in $Services) {
            if ($state.WasRunning[$service.Name]) {
                Start-MailSiteService -ServiceName $service.Name
            }
        }

        Write-Host "MailSite 11 installation completed successfully."
    } catch {
        if ($servicesStopped -and $null -ne $state) {
            Write-Host "Install failed. Restoring previous service paths and startup state..."
            foreach ($service in $Services) {
                $previous = $state.PreviousImagePath[$service.Name]
                if (-not [string]::IsNullOrWhiteSpace($previous)) {
                    $path = "HKLM:\SYSTEM\CurrentControlSet\Services\$($service.Name)"
                    Set-ItemProperty -Path $path -Name ImagePath -Value $previous
                }
            }
            foreach ($service in $Services) {
                if ($state.WasRunning[$service.Name]) {
                    Start-MailSiteService -ServiceName $service.Name
                }
            }
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
