[CmdletBinding()]
param(
    [string]$InstallDir = (Join-Path $env:ProgramFiles "MailSite"),
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
$InstallMarkerName = ".mailsite11-install.json"
$RequiredLegacyMajorVersion = "10"
$TargetMajorVersion = "11"
$script:LogPath = $null

function Initialize-InstallLog {
    param([string]$RootDirectory)

    $logDirectory = Join-Path $RootDirectory "Log"
    New-Item -ItemType Directory -Path $logDirectory -Force | Out-Null
    $script:LogPath = Join-Path $logDirectory "install-mailsite.log"
    Write-InstallerMessage "MailSite installer started."
}

function Write-InstallerMessage {
    param(
        [string]$Message,
        [ValidateSet("INFO", "WARN", "ERROR")]
        [string]$Level = "INFO"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$timestamp] [$Level] $Message"
    if (-not [string]::IsNullOrWhiteSpace($script:LogPath)) {
        Add-Content -LiteralPath $script:LogPath -Value $line -Encoding UTF8
    }

    switch ($Level) {
        "ERROR" { Write-Host $Message -ForegroundColor Red }
        "WARN" { Write-Host $Message -ForegroundColor Yellow }
        default { Write-Host $Message }
    }
}

function Write-InstallerFailure {
    param([string]$Message)

    Write-Host ""
    Write-InstallerMessage "Install failed: $Message" -Level "ERROR"
    if (-not [string]::IsNullOrWhiteSpace($script:LogPath)) {
        Write-Host "See log: $script:LogPath" -ForegroundColor Yellow
    }
}

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
        Write-InstallerMessage "$ServiceName is already stopped."
        return $false
    }

    Write-InstallerMessage "Stopping $ServiceName..."
    Stop-Service -Name $ServiceName -Force -ErrorAction Stop
    $service.WaitForStatus("Stopped", [TimeSpan]::FromSeconds(60))
    return $true
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
    $accessSections = [System.Security.AccessControl.AccessControlSections]::Access

    # Copy the DACL as SDDL so unresolved legacy SIDs are preserved without name translation.
    $sourceAccessSddl = $sourceAcl.GetSecurityDescriptorSddlForm($accessSections)
    $destinationAcl.SetSecurityDescriptorSddlForm($sourceAccessSddl, $accessSections)

    Set-Acl -LiteralPath $DestinationDirectory -AclObject $destinationAcl
}

function Get-ProductVersion {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Missing required executable: $Path"
    }

    $versionInfo = [Diagnostics.FileVersionInfo]::GetVersionInfo($Path)
    if (-not [string]::IsNullOrWhiteSpace($versionInfo.FileVersion)) {
        return $versionInfo.FileVersion.Trim()
    }
    return $versionInfo.ProductVersion.Trim()
}

function ConvertTo-MailSiteDisplayVersion {
    param([string]$Version)

    if ([string]::IsNullOrWhiteSpace($Version)) {
        return $Version
    }

    try {
        $parsed = [version]$Version.Trim()
        if ($parsed.Build -ge 0) {
            return "$($parsed.Major).$($parsed.Minor).$($parsed.Build)"
        }
    } catch {
        return $Version.Trim()
    }

    return $Version.Trim()
}

function Get-ClusterVariantName {
    param([int]$ClusterVariant)

    switch ($ClusterVariant) {
        0 { return "Registry Connector" }
        4 { return "SQL Connector" }
        5 { return "LDAP Connector" }
        default { return "Unknown Connector" }
    }
}

function Get-LatestRemotePackageVersion {
    if ($PackageUrl -notmatch '^https://github\.com/([^/]+)/([^/]+)/raw/([^/]+)/MailSite\.zip$') {
        return $null
    }

    $owner = $Matches[1]
    $repo = $Matches[2]
    $branch = $Matches[3]
    $contentsUrl = "https://api.github.com/repos/$owner/$repo/contents?ref=$branch"

    try {
        $items = Invoke-RestMethod -Uri $contentsUrl -UseBasicParsing
        $versions = @()
        foreach ($item in $items) {
            if ($item.name -match '^MailSite\.(11\.[0-9]+\.[0-9]+)\.zip$') {
                $versions += [version]$Matches[1]
            }
        }

        if ($versions.Count -eq 0) {
            return $null
        }

        return (($versions | Sort-Object -Descending | Select-Object -First 1).ToString())
    } catch {
        Write-InstallerMessage "Could not determine latest MailSite package version from release repository before download: $($_.Exception.Message)" -Level "WARN"
        return $null
    }
}

function Assert-MailSite10 {
    if (-not (Test-Path $MailSiteKey32)) {
        throw "This installation of MailSite 11 requires an existing 32-bit MailSite $RequiredLegacyMajorVersion.x registry key at $MailSiteKey32."
    }

    foreach ($name in @("Version", "InstallDir", "ClusterVariant", "RegistryFormatVersion", "ServerMajorVersion", "License")) {
        Assert-RegistryValuePresent -Path $MailSiteKey32 -Name $name
    }

    $version = Get-RegistryString -Path $MailSiteKey32 -Name "Version"
    if ([string]::IsNullOrWhiteSpace($version) -or -not $version.StartsWith("$RequiredLegacyMajorVersion.")) {
        throw "This installation of MailSite 11 requires an existing MailSite $RequiredLegacyMajorVersion.x installation. Found registry version '$version'."
    }

    $legacyInstallDir = Get-RegistryString -Path $MailSiteKey32 -Name "InstallDir"
    if (-not (Test-Path -LiteralPath $legacyInstallDir -PathType Container)) {
        throw "Legacy MailSite InstallDir does not exist: $legacyInstallDir"
    }

    $clusterVariantRaw = Get-RegistryValue -Path $MailSiteKey32 -Name "ClusterVariant"
    $clusterVariant = [int]$clusterVariantRaw
    $connectorName = Get-ClusterVariantName -ClusterVariant $clusterVariant

    if ($clusterVariant -eq 4) {
        $sqlConnectorKey = Join-Path $MailSiteKey32 "SqlConnector"
        if (-not (Test-Path $sqlConnectorKey)) {
            throw "MailSite is configured for SQL Connector, but $sqlConnectorKey is missing."
        }
        foreach ($name in @("DataSourceName", "DataSourceUser", "DataSourcePass")) {
            Assert-RegistryValuePresent -Path $sqlConnectorKey -Name $name
        }
    } elseif ($clusterVariant -ne 0) {
        throw "Unsupported MailSite connector '$connectorName' (ClusterVariant=$clusterVariant). This installer supports Registry Connector and SQL Connector."
    }

    foreach ($service in $Services) {
        $exe = Join-Path $legacyInstallDir $service.File
        $fileVersion = Get-ProductVersion -Path $exe
        if ([string]::IsNullOrWhiteSpace($fileVersion) -or -not $fileVersion.StartsWith("$RequiredLegacyMajorVersion.")) {
            throw "This installation of MailSite 11 requires $($service.Name) from MailSite $RequiredLegacyMajorVersion.x. Found '$fileVersion' at $exe."
        }
    }

    return @{
        LegacyInstallDir = $legacyInstallDir
        RegistryVersion = $version
        ConnectorName = $connectorName
    }
}

function Resolve-PackagePath {
    param([string]$DestinationDirectory)

    $destinationPackage = Join-Path $DestinationDirectory "MailSite.zip"

    if (-not [string]::IsNullOrWhiteSpace($PackagePath)) {
        if (-not (Test-Path -LiteralPath $PackagePath)) {
            throw "PackagePath does not exist: $PackagePath"
        }
        $resolvedPackage = (Resolve-Path -LiteralPath $PackagePath).Path
        if ($resolvedPackage -ne $destinationPackage) {
            Write-InstallerMessage "Copying MailSite package to $destinationPackage..."
            Copy-Item -LiteralPath $resolvedPackage -Destination $destinationPackage -Force
        }
        return $destinationPackage
    }

    $sibling = Join-Path $PSScriptRoot "MailSite.zip"
    if (-not [string]::IsNullOrWhiteSpace($PSScriptRoot) -and (Test-Path -LiteralPath $sibling)) {
        if ((Resolve-Path -LiteralPath $sibling).Path -ne $destinationPackage) {
            Write-InstallerMessage "Copying MailSite package to $destinationPackage..."
            Copy-Item -LiteralPath $sibling -Destination $destinationPackage -Force
        }
        return $destinationPackage
    }

    Write-InstallerMessage "Downloading MailSite package from $PackageUrl to $destinationPackage..."
    try {
        Invoke-WebRequest -Uri $PackageUrl -OutFile $destinationPackage -UseBasicParsing
        return $destinationPackage
    } catch {
        throw "Could not download MailSite package from $PackageUrl. Pass -PackagePath or publish MailSite.zip to the release repository. $($_.Exception.Message)"
    }
}

function Get-PackageVersionFromZip {
    param([string]$Path)

    $extractRoot = Join-Path ([IO.Path]::GetTempPath()) ("MailSite11-version-" + [Guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path $extractRoot -Force | Out-Null
    try {
        Expand-Archive -Path $Path -DestinationPath $extractRoot -Force
        $packageRoot = Get-PackageRoot -ExtractRoot $extractRoot
        return Get-PackageVersion -PackageRoot $packageRoot
    } finally {
        Remove-Item -Path $extractRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function Resolve-RequestedPackageVersion {
    if (-not [string]::IsNullOrWhiteSpace($PackagePath)) {
        if (-not (Test-Path -LiteralPath $PackagePath)) {
            throw "PackagePath does not exist: $PackagePath"
        }
        return Get-PackageVersionFromZip -Path (Resolve-Path -LiteralPath $PackagePath).Path
    }

    if (-not [string]::IsNullOrWhiteSpace($PSScriptRoot)) {
        $sibling = Join-Path $PSScriptRoot "MailSite.zip"
        if (Test-Path -LiteralPath $sibling) {
            return Get-PackageVersionFromZip -Path (Resolve-Path -LiteralPath $sibling).Path
        }
    }

    $remoteVersion = Get-LatestRemotePackageVersion
    if (-not [string]::IsNullOrWhiteSpace($remoteVersion)) {
        return $remoteVersion
    }

    return "11.N.NNN"
}

function Get-PackageRoot {
    param([string]$ExtractRoot)

    $required = @("httpma.exe", "imap4a.exe", "smtpra.exe", "smtpda.exe")
    $hasExecutables = $required | Where-Object { Test-Path -LiteralPath (Join-Path $ExtractRoot $_) }
    if ($hasExecutables.Count -eq $required.Count) {
        return $ExtractRoot
    }

    $children = Get-ChildItem -Path $ExtractRoot -Directory
    if ($children.Count -eq 1) {
        return $children[0].FullName
    }

    throw "Could not determine package root after extracting $ExtractRoot."
}

function Get-PackageVersion {
    param([string]$PackageRoot)

    $versions = @()
    foreach ($service in $Services) {
        $exe = Join-Path $PackageRoot $service.File
        $version = Get-ProductVersion -Path $exe
        if ([string]::IsNullOrWhiteSpace($version) -or -not $version.StartsWith("$TargetMajorVersion.")) {
            throw "Package executable $exe has unexpected version '$version'."
        }
        $versions += ConvertTo-MailSiteDisplayVersion -Version $version
    }

    $uniqueVersions = @($versions | Sort-Object -Unique)
    if ($uniqueVersions.Count -ne 1) {
        throw "Package contains mixed executable versions: $($uniqueVersions -join ', ')."
    }

    return $uniqueVersions[0]
}

function Get-InstalledMailSite11Version {
    param([string]$RootDirectory)

    if (-not (Test-Path -LiteralPath $RootDirectory -PathType Container)) {
        return $null
    }

    $versions = @()
    foreach ($service in $Services) {
        $exe = Join-Path $RootDirectory $service.File
        if (-not (Test-Path -LiteralPath $exe)) {
            return $null
        }
        $version = Get-ProductVersion -Path $exe
        if ([string]::IsNullOrWhiteSpace($version) -or -not $version.StartsWith("$TargetMajorVersion.")) {
            return $null
        }
        $versions += ConvertTo-MailSiteDisplayVersion -Version $version
    }

    $uniqueVersions = @($versions | Sort-Object -Unique)
    if ($uniqueVersions.Count -eq 1) {
        return $uniqueVersions[0]
    }

    return ($uniqueVersions -join ", ")
}

function Save-InstallerState {
    param([hashtable]$State)

    $json = $State | ConvertTo-Json -Depth 5
    $markerPath = Join-Path $InstallDir $InstallMarkerName
    Set-Content -Path $markerPath -Value $json -Encoding UTF8
}

function Get-ExistingInstallerState {
    $markerPath = Join-Path $InstallDir $InstallMarkerName
    if (-not (Test-Path -LiteralPath $markerPath)) {
        return $null
    }

    $json = Get-Content -LiteralPath $markerPath -Raw
    return $json | ConvertFrom-Json
}

function Copy-StateMap {
    param(
        [object]$State,
        [string]$PropertyName
    )

    $result = @{}
    if ($null -eq $State -or $null -eq $State.$PropertyName) {
        return $result
    }

    foreach ($property in $State.$PropertyName.PSObject.Properties) {
        $result[$property.Name] = $property.Value
    }
    return $result
}

function Confirm-MailSiteInstall {
    param([string]$Version)

    while ($true) {
        $answer = Read-Host "This script will install MailSite $Version. Do you wish to continue [y/n]?"
        switch -Regex ($answer.Trim()) {
            "^(y|yes)$" { return $true }
            "^(n|no)$" { return $false }
            default { Write-Host "Please enter y or n." -ForegroundColor Yellow }
        }
    }
}

function Test-ExactMailSiteVersion {
    param([string]$Version)

    return $Version -match '^11\.[0-9]+\.[0-9]+$'
}

function Set-MailSiteFirewallRules {
    param(
        [hashtable]$Service,
        [string]$ExecutablePath
    )

    if (-not (Get-Command -Name New-NetFirewallRule -ErrorAction SilentlyContinue)) {
        throw "Windows firewall cmdlets are not available on this system."
    }

    $directions = @("Inbound")
    if ($Service.Name -eq "SMTPDA") {
        $directions += "Outbound"
    } else {
        $obsoleteDisplayName = "MailSite 11 $($Service.Name) Outbound"
        $obsoleteRules = Get-NetFirewallRule -DisplayName $obsoleteDisplayName -ErrorAction SilentlyContinue
        if ($obsoleteRules) {
            $obsoleteRules | Remove-NetFirewallRule | Out-Null
            Write-InstallerMessage "Removed obsolete firewall rule '$obsoleteDisplayName'."
        }
    }

    foreach ($direction in $directions) {
        $displayName = "MailSite 11 $($Service.Name) $direction"
        $existingRules = Get-NetFirewallRule -DisplayName $displayName -ErrorAction SilentlyContinue
        if ($existingRules) {
            foreach ($rule in $existingRules) {
                Set-NetFirewallRule -Name $rule.Name -Enabled True -Action Allow -Direction $direction -Profile Any | Out-Null
                Get-NetFirewallApplicationFilter -AssociatedNetFirewallRule $rule |
                    Set-NetFirewallApplicationFilter -Program $ExecutablePath | Out-Null
            }
            Write-InstallerMessage "Updated firewall rule '$displayName'."
        } else {
            New-NetFirewallRule `
                -DisplayName $displayName `
                -Direction $direction `
                -Program $ExecutablePath `
                -Action Allow `
                -Enabled True `
                -Profile Any | Out-Null
            Write-InstallerMessage "Created firewall rule '$displayName'."
        }
    }
}

function Install-MailSite {
    Assert-Administrator
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    Initialize-InstallLog -RootDirectory $InstallDir

    $legacy = Assert-MailSite10
    Write-InstallerMessage "Detected MailSite $($legacy.RegistryVersion) using $($legacy.ConnectorName)."

    $requestedVersion = Resolve-RequestedPackageVersion
    $installedVersion = Get-InstalledMailSite11Version -RootDirectory $InstallDir
    if ((Test-ExactMailSiteVersion -Version $requestedVersion) -and $installedVersion -eq $requestedVersion) {
        Write-InstallerMessage "MailSite $requestedVersion is already installed. No changes were made."
        return
    }

    if (-not (Confirm-MailSiteInstall -Version $requestedVersion)) {
        Write-InstallerMessage "Installation cancelled by user."
        return
    }

    $package = Resolve-PackagePath -DestinationDirectory $InstallDir
    $extractRoot = Join-Path ([IO.Path]::GetTempPath()) ("MailSite11-" + [Guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path $extractRoot -Force | Out-Null

    $state = $null
    $rollbackImagePath = @{}
    $servicesStopped = $false

    try {
        Write-InstallerMessage "Extracting $package..."
        Expand-Archive -Path $package -DestinationPath $extractRoot -Force
        $packageRoot = Get-PackageRoot -ExtractRoot $extractRoot
        $targetVersion = Get-PackageVersion -PackageRoot $packageRoot

        if ($installedVersion -eq $targetVersion) {
            Write-InstallerMessage "MailSite $targetVersion is already installed. No changes were made."
            Remove-Item -LiteralPath $package -Force -ErrorAction SilentlyContinue
            return
        }

        if ([string]::IsNullOrWhiteSpace($installedVersion)) {
            Write-InstallerMessage "Installing MailSite $targetVersion to $InstallDir..."
        } else {
            Write-InstallerMessage "Upgrading MailSite $installedVersion to MailSite $targetVersion in $InstallDir..."
        }

        $existingState = Get-ExistingInstallerState
        $state = @{
            InstalledAtUtc = [DateTimeOffset]::UtcNow.ToString("o")
            InstallDir11 = $InstallDir
            TargetVersion = $targetVersion
            PreviousImagePath = Copy-StateMap -State $existingState -PropertyName "PreviousImagePath"
            WasRunning = @{}
        }

        foreach ($service in $Services) {
            $currentImagePath = Get-ServiceImagePath -ServiceName $service.Name
            $rollbackImagePath[$service.Name] = $currentImagePath
            if (-not $state.PreviousImagePath.ContainsKey($service.Name)) {
                $state.PreviousImagePath[$service.Name] = $currentImagePath
            }
            $state.WasRunning[$service.Name] = Stop-MailSiteService -ServiceName $service.Name
        }
        $servicesStopped = $true

        Write-InstallerMessage "Copying directory permissions from $($legacy.LegacyInstallDir) to $InstallDir..."
        Copy-DirectoryAccessRules -SourceDirectory $legacy.LegacyInstallDir -DestinationDirectory $InstallDir

        Copy-Item -Path (Join-Path $packageRoot "*") -Destination $InstallDir -Recurse -Force

        Save-InstallerState -State $state

        foreach ($service in $Services) {
            $newExe = Join-Path $InstallDir $service.File
            if (-not (Test-Path -LiteralPath $newExe)) {
                throw "Package did not install $newExe."
            }
            Set-ServiceImagePath -ServiceName $service.Name -ExecutablePath $newExe
            Set-MailSiteFirewallRules -Service $service -ExecutablePath $newExe
        }

        Remove-Item -LiteralPath $package -Force -ErrorAction SilentlyContinue
        Write-InstallerMessage "MailSite $targetVersion installation completed successfully. Services were left stopped; start them manually after verification."
    } catch {
        if ($servicesStopped -and $null -ne $state) {
            Write-InstallerMessage "Install failed. Restoring previous service paths..." -Level "WARN"
            foreach ($service in $Services) {
                $previous = $rollbackImagePath[$service.Name]
                if (-not [string]::IsNullOrWhiteSpace($previous)) {
                    $path = "HKLM:\SYSTEM\CurrentControlSet\Services\$($service.Name)"
                    Set-ItemProperty -Path $path -Name ImagePath -Value $previous
                }
            }
        }
        throw
    } finally {
        Remove-Item -Path $extractRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}

try {
    Install-MailSite
} catch {
    Write-InstallerFailure $_.Exception.Message
    if ($PSCommandPath) {
        exit 1
    }
}
