[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$InstallTarget,
    [string]$InstallDir = (Join-Path $env:ProgramFiles "MailSite"),
    [string]$PackagePath,
    [string]$PackageUrl = "https://github.com/rockliffe/mailsite-server-release/raw/main/MailSite.zip"
)

$ErrorActionPreference = "Stop"

$Services = @(
    @{ Name = "HTTPMA"; File = "httpma.exe"; Description = "MailSite HTTP Management Agent" },
    @{ Name = "IMAP4A"; File = "imap4a.exe"; Description = "MailSite IMAP4 Server" },
    @{ Name = "SMTPRA"; File = "smtpra.exe"; Description = "MailSite SMTP Receiving Agent" },
    @{ Name = "SMTPDA"; File = "smtpda.exe"; Description = "MailSite SMTP Delivery Agent" }
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

function Get-ServiceDescription {
    param([string]$ServiceName)

    $path = "HKLM:\SYSTEM\CurrentControlSet\Services\$ServiceName"
    if (-not (Test-Path $path)) {
        throw "Windows service '$ServiceName' is not installed."
    }

    $description = (Get-ItemProperty -Path $path -Name Description -ErrorAction SilentlyContinue).Description
    if ($null -eq $description) {
        return ""
    }

    return [string]$description
}

function Set-ServiceDescription {
    param(
        [string]$ServiceName,
        [string]$Description
    )

    $path = "HKLM:\SYSTEM\CurrentControlSet\Services\$ServiceName"
    Set-ItemProperty -Path $path -Name Description -Value $Description
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

function Start-MailSiteService {
    param([string]$ServiceName)

    try {
        $service = Get-Service -Name $ServiceName -ErrorAction Stop
        if ($service.Status -eq "Running") {
            Write-InstallerMessage "$ServiceName is already running."
            return $true
        }

        Write-InstallerMessage "Starting $ServiceName..."
        Start-Service -Name $ServiceName -ErrorAction Stop
        $service.WaitForStatus("Running", [TimeSpan]::FromSeconds(60))
        return $true
    } catch {
        Write-InstallerMessage "Failed to start $ServiceName after install: $($_.Exception.Message)" -Level "WARN"
        return $false
    }
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

function Get-ReleaseRepositoryInfo {
    if ($PackageUrl -notmatch '^https://github\.com/([^/]+)/([^/]+)/raw/([^/]+)/[^/]+\.zip$') {
        return $null
    }

    return @{
        Owner = $Matches[1]
        Repo = $Matches[2]
        Branch = $Matches[3]
        RawBaseUrl = "https://github.com/$($Matches[1])/$($Matches[2])/raw/$($Matches[3])"
    }
}

function Get-RemotePackageVersions {
    $repoInfo = Get-ReleaseRepositoryInfo
    if ($null -eq $repoInfo) {
        return @()
    }

    $owner = $repoInfo.Owner
    $repo = $repoInfo.Repo
    $branch = $repoInfo.Branch
    $contentsUrl = "https://api.github.com/repos/$owner/$repo/contents?ref=$branch"

    try {
        $items = Invoke-RestMethod -Uri $contentsUrl -UseBasicParsing
        $versions = @()
        foreach ($item in $items) {
            if ($item.name -match '^MailSite\.(11\.[0-9]+\.[0-9]+)\.zip$') {
                $versions += [version]$Matches[1]
            }
        }

        return @($versions | Sort-Object -Descending)
    } catch {
        Write-InstallerMessage "Could not query MailSite package versions from release repository before download: $($_.Exception.Message)" -Level "WARN"
        return @()
    }
}

function Get-LatestRemotePackageVersion {
    $versions = @(Get-RemotePackageVersions)
    if ($versions.Count -eq 0) {
        return $null
    }

    return ($versions[0].ToString())
}

function Test-SiblingPackageAvailable {
    if ([string]::IsNullOrWhiteSpace($PSScriptRoot)) {
        return $false
    }

    $sibling = Join-Path $PSScriptRoot "MailSite.zip"
    return (Test-Path -LiteralPath $sibling -PathType Leaf)
}

function Get-RemotePackageUrl {
    param([string]$Version)

    if ([string]::IsNullOrWhiteSpace($Version)) {
        return $PackageUrl
    }

    $repoInfo = Get-ReleaseRepositoryInfo
    if ($null -eq $repoInfo) {
        throw "Cannot resolve version-specific package URL from PackageUrl '$PackageUrl'. Pass -PackagePath or use the default release repository URL."
    }

    return "$($repoInfo.RawBaseUrl)/MailSite.$Version.zip"
}

function Assert-MailSite10 {
    if (-not (Test-Path $MailSiteKey32)) {
        throw "This installation of MailSite 11 requires an existing 32-bit MailSite $RequiredLegacyMajorVersion.x registry key at $MailSiteKey32."
    }

    foreach ($name in @("Version", "InstallDir", "RegistryFormatVersion", "ServerMajorVersion", "License")) {
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
    $clusterVariant = 0
    if ($null -ne $clusterVariantRaw -and ([string]$clusterVariantRaw).Length -gt 0) {
        $clusterVariant = [int]$clusterVariantRaw
    }
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

function Assert-ZipPackageValid {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "MailSite package does not exist: $Path"
    }

    $file = Get-Item -LiteralPath $Path
    if ($file.Length -le 0) {
        throw "MailSite package is empty: $Path"
    }

    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue
        $zip = [System.IO.Compression.ZipFile]::OpenRead($Path)
        try {
            if ($zip.Entries.Count -eq 0) {
                throw "Zip archive contains no entries."
            }
        } finally {
            $zip.Dispose()
        }
    } catch {
        throw "MailSite package is not a valid zip file: $Path. $($_.Exception.Message)"
    }
}

function Invoke-MailSitePackageDownload {
    param(
        [string]$Url,
        [string]$DestinationPath
    )

    $curl = Get-Command -Name "curl.exe" -ErrorAction SilentlyContinue
    if ($null -eq $curl) {
        throw "curl.exe is required to download MailSite packages."
    }

    Write-InstallerMessage "Downloading MailSite package from $Url to $DestinationPath..."
    & $curl.Source -f -# -L $Url -o $DestinationPath
    if ($LASTEXITCODE -ne 0) {
        throw "Could not download MailSite package from $Url. curl.exe exited with code $LASTEXITCODE."
    }
}

function Resolve-PackagePath {
    param(
        [string]$DestinationDirectory,
        [string]$RemoteVersion
    )

    $destinationPackage = Join-Path $DestinationDirectory "MailSite.zip"

    if (-not [string]::IsNullOrWhiteSpace($PackagePath)) {
        if (-not (Test-Path -LiteralPath $PackagePath)) {
            throw "PackagePath does not exist: $PackagePath"
        }
        $resolvedPackage = (Resolve-Path -LiteralPath $PackagePath).Path
        if ($resolvedPackage -ne $destinationPackage) {
            Remove-Item -LiteralPath $destinationPackage -Force -ErrorAction SilentlyContinue
            Write-InstallerMessage "Copying MailSite package to $destinationPackage..."
            Copy-Item -LiteralPath $resolvedPackage -Destination $destinationPackage -Force
        }
        Assert-ZipPackageValid -Path $destinationPackage
        return $destinationPackage
    }

    if ([string]::IsNullOrWhiteSpace($RemoteVersion) -and -not [string]::IsNullOrWhiteSpace($PSScriptRoot)) {
        $sibling = Join-Path $PSScriptRoot "MailSite.zip"
        if (-not (Test-Path -LiteralPath $sibling)) {
            $sibling = $null
        }
    } else {
        $sibling = $null
    }

    if (-not [string]::IsNullOrWhiteSpace($sibling)) {
        if ((Resolve-Path -LiteralPath $sibling).Path -ne $destinationPackage) {
            Remove-Item -LiteralPath $destinationPackage -Force -ErrorAction SilentlyContinue
            Write-InstallerMessage "Copying MailSite package to $destinationPackage..."
            Copy-Item -LiteralPath $sibling -Destination $destinationPackage -Force
        }
        Assert-ZipPackageValid -Path $destinationPackage
        return $destinationPackage
    }

    Remove-Item -LiteralPath $destinationPackage -Force -ErrorAction SilentlyContinue
    $downloadUrl = Get-RemotePackageUrl -Version $RemoteVersion
    try {
        Invoke-MailSitePackageDownload -Url $downloadUrl -DestinationPath $destinationPackage
        Assert-ZipPackageValid -Path $destinationPackage
        return $destinationPackage
    } catch {
        throw "Could not prepare MailSite package. Pass -PackagePath or publish the requested MailSite zip to the release repository. $($_.Exception.Message)"
    }
}

function Get-PackageVersionFromZip {
    param([string]$Path)

    Assert-ZipPackageValid -Path $Path
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

function Resolve-InstallRequest {
    $target = $InstallTarget
    if ([string]::IsNullOrWhiteSpace($target)) {
        return @{
            RemoteVersion = $null
            ForceReinstall = $false
            AllowDowngrade = $false
            Interactive = $true
            SkipConfirm = $false
            Cancelled = $false
        }
    }

    $target = $target.Trim()
    if ($target -ieq "reinstall") {
        return @{
            RemoteVersion = $null
            ForceReinstall = $true
            AllowDowngrade = $false
            Interactive = $false
            SkipConfirm = $false
            Cancelled = $false
        }
    }

    if ($target -match '^11\.[0-9]+\.[0-9]+$') {
        return @{
            RemoteVersion = $target
            ForceReinstall = $false
            AllowDowngrade = $true
            Interactive = $false
            SkipConfirm = $false
            Cancelled = $false
        }
    }

    throw "Unknown install target '$target'. Use no argument for latest, 'reinstall' to force latest reinstall, or an exact version such as 11.0.112."
}

function Resolve-RequestedPackageVersion {
    param([hashtable]$InstallRequest)

    if (-not [string]::IsNullOrWhiteSpace($PackagePath)) {
        if (-not (Test-Path -LiteralPath $PackagePath)) {
            throw "PackagePath does not exist: $PackagePath"
        }
        return Get-PackageVersionFromZip -Path (Resolve-Path -LiteralPath $PackagePath).Path
    }

    if (-not [string]::IsNullOrWhiteSpace($InstallRequest.RemoteVersion)) {
        $versions = @(Get-RemotePackageVersions | ForEach-Object { $_.ToString() })
        if ($versions.Count -gt 0 -and -not ($versions -contains $InstallRequest.RemoteVersion)) {
            throw "MailSite $($InstallRequest.RemoteVersion) was not found in the release repository."
        }
        return $InstallRequest.RemoteVersion
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

function Read-YesNo {
    param(
        [string]$Prompt,
        [bool]$DefaultYes
    )

    $suffix = if ($DefaultYes) { "[Y/n]" } else { "[y/N]" }
    while ($true) {
        $answer = Read-Host "$Prompt $suffix"
        if ([string]::IsNullOrWhiteSpace($answer)) {
            return $DefaultYes
        }

        switch -Regex ($answer.Trim()) {
            "^(y|yes)$" { return $true }
            "^(n|no)$" { return $false }
            default { Write-Host "Please enter y or n." -ForegroundColor Yellow }
        }
    }
}

function Confirm-MailSiteInstall {
    param([string]$Version)

    Write-Host ""
    Write-Host "MailSite 11 Installer"
    Write-Host "====================="
    Write-Host "This script will install MailSite $Version."
    Write-Host "Install directory: $InstallDir"
    Write-Host ""
    return Read-YesNo -Prompt "Continue?" -DefaultYes $false
}

function Resolve-InteractiveRemoteInstallRequest {
    param(
        [string]$InstalledVersion,
        [hashtable]$LegacyInfo
    )

    $versions = @(Get-RemotePackageVersions)
    if ($versions.Count -eq 0) {
        throw "Could not find MailSite packages in the release repository."
    }

    $latestVersion = $versions[0].ToString()
    $previousVersion = $null
    if ($versions.Count -gt 1) {
        $previousVersion = $versions[1].ToString()
    }

    Write-InstallerMessage "Latest available MailSite version: $latestVersion."
    Write-Host ""
    Write-Host "MailSite 11 Installer"
    Write-Host "====================="
    Write-Host "Detected:"
    Write-Host "  MailSite 10:       $($LegacyInfo.RegistryVersion)"
    Write-Host "  Connector:         $($LegacyInfo.ConnectorName)"
    Write-Host "  Existing MailSite: $(if ([string]::IsNullOrWhiteSpace($InstalledVersion)) { 'Not installed' } else { $InstalledVersion })"
    Write-Host "  Install path:      $InstallDir"
    Write-Host ""
    Write-Host "Latest available:    $latestVersion"
    Write-Host ""

    if ((Test-ExactMailSiteVersion -Version $latestVersion) -and (Test-ExactMailSiteVersion -Version $InstalledVersion)) {
        $latestComparison = Compare-MailSiteVersions -Left $latestVersion -Right $InstalledVersion
        if ($latestComparison -eq 0) {
            Write-Host "MailSite $latestVersion is already installed."
            if (Read-YesNo -Prompt "Reinstall MailSite $($latestVersion)?" -DefaultYes $false) {
                return @{
                    RemoteVersion = $latestVersion
                    ForceReinstall = $true
                    AllowDowngrade = $false
                    Interactive = $true
                    SkipConfirm = $true
                    Cancelled = $false
                }
            }
        } elseif ($latestComparison -gt 0) {
            if (Read-YesNo -Prompt "Install MailSite $($latestVersion)?" -DefaultYes $true) {
                return @{
                    RemoteVersion = $latestVersion
                    ForceReinstall = $false
                    AllowDowngrade = $false
                    Interactive = $true
                    SkipConfirm = $true
                    Cancelled = $false
                }
            }
        } else {
            Write-InstallerMessage "Installed MailSite $InstalledVersion is newer than the latest available package $latestVersion." -Level "WARN"
        }
    } else {
        if (Read-YesNo -Prompt "Install MailSite $($latestVersion)?" -DefaultYes $true) {
        return @{
            RemoteVersion = $latestVersion
            ForceReinstall = $false
            AllowDowngrade = $false
            Interactive = $true
            SkipConfirm = $true
            Cancelled = $false
        }
        }
    }

    if (-not [string]::IsNullOrWhiteSpace($previousVersion)) {
        Write-Host ""
        Write-Host "Install previous version instead?"
        Write-Host "Previous available: $previousVersion"
        if (Read-YesNo -Prompt "Install MailSite $($previousVersion)?" -DefaultYes $false) {
            return @{
                RemoteVersion = $previousVersion
                ForceReinstall = $true
                AllowDowngrade = $true
                Interactive = $true
                SkipConfirm = $true
                Cancelled = $false
            }
        }
    } else {
        Write-InstallerMessage "No previous MailSite package is available in the release repository." -Level "WARN"
    }

    Write-InstallerMessage "Installation cancelled by user."
    return @{
        RemoteVersion = $null
        ForceReinstall = $false
        AllowDowngrade = $false
        Interactive = $true
        SkipConfirm = $true
        Cancelled = $true
    }
}

function Test-ExactMailSiteVersion {
    param([string]$Version)

    return $Version -match '^11\.[0-9]+\.[0-9]+$'
}

function Compare-MailSiteVersions {
    param(
        [string]$Left,
        [string]$Right
    )

    return ([version]$Left).CompareTo([version]$Right)
}

function Set-MailSiteFirewallRules {
    param(
        [hashtable]$Service,
        [string]$ExecutablePath
    )

    if (-not (Get-Command -Name New-NetFirewallRule -ErrorAction SilentlyContinue)) {
        throw "Windows firewall cmdlets are not available on this system."
    }

    if ($Service.Name -eq "SMTPDA") {
        $directions = @("Outbound")
        $obsoleteDisplayName = "MailSite 11 SMTPDA Inbound"
        $obsoleteRules = Get-NetFirewallRule -DisplayName $obsoleteDisplayName -ErrorAction SilentlyContinue
        if ($obsoleteRules) {
            $obsoleteRules | Remove-NetFirewallRule | Out-Null
            Write-InstallerMessage "Removed obsolete firewall rule '$obsoleteDisplayName'."
        }
    } else {
        $directions = @("Inbound")
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

    $installRequest = Resolve-InstallRequest
    $installedVersion = Get-InstalledMailSite11Version -RootDirectory $InstallDir
    if (-not [string]::IsNullOrWhiteSpace($installedVersion)) {
        Write-InstallerMessage "Detected existing MailSite $installedVersion in $InstallDir."
    }

    if ($installRequest.Interactive -and [string]::IsNullOrWhiteSpace($PackagePath) -and -not (Test-SiblingPackageAvailable)) {
        $installRequest = Resolve-InteractiveRemoteInstallRequest -InstalledVersion $installedVersion -LegacyInfo $legacy
        if ($installRequest.Cancelled) {
            return
        }
        $requestedVersion = $installRequest.RemoteVersion
    } else {
        $requestedVersion = Resolve-RequestedPackageVersion -InstallRequest $installRequest
    }

    if ((Test-ExactMailSiteVersion -Version $requestedVersion) -and (Test-ExactMailSiteVersion -Version $installedVersion)) {
        $requestedComparison = Compare-MailSiteVersions -Left $requestedVersion -Right $installedVersion
        if ($requestedComparison -eq 0 -and -not $installRequest.ForceReinstall) {
            Write-InstallerMessage "MailSite $requestedVersion is already installed. No changes were made."
            return
        }
        if ($requestedComparison -lt 0 -and -not $installRequest.AllowDowngrade) {
            Write-InstallerMessage "MailSite $installedVersion is already installed, which is newer than MailSite $requestedVersion. No changes were made." -Level "WARN"
            return
        }
    }

    if (-not $installRequest.SkipConfirm -and -not (Confirm-MailSiteInstall -Version $requestedVersion)) {
        Write-InstallerMessage "Installation cancelled by user."
        return
    }

    $package = Resolve-PackagePath -DestinationDirectory $InstallDir -RemoteVersion $installRequest.RemoteVersion
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

        if (Test-ExactMailSiteVersion -Version $installedVersion) {
            $targetComparison = Compare-MailSiteVersions -Left $targetVersion -Right $installedVersion
            if ($targetComparison -eq 0 -and -not $installRequest.ForceReinstall) {
                Write-InstallerMessage "MailSite $targetVersion is already installed. No changes were made."
                Remove-Item -LiteralPath $package -Force -ErrorAction SilentlyContinue
                return
            }
            if ($targetComparison -lt 0 -and -not $installRequest.AllowDowngrade) {
                throw "Cannot install MailSite $targetVersion because MailSite $installedVersion is already installed. Download a newer MailSite package and retry."
            }
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
            PreviousDescription = Copy-StateMap -State $existingState -PropertyName "PreviousDescription"
            WasRunning = @{}
        }

        foreach ($service in $Services) {
            $currentImagePath = Get-ServiceImagePath -ServiceName $service.Name
            $rollbackImagePath[$service.Name] = $currentImagePath
            if (-not $state.PreviousImagePath.ContainsKey($service.Name)) {
                $state.PreviousImagePath[$service.Name] = $currentImagePath
            }
            if (-not $state.PreviousDescription.ContainsKey($service.Name)) {
                $state.PreviousDescription[$service.Name] = Get-ServiceDescription -ServiceName $service.Name
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
            Set-ServiceDescription -ServiceName $service.Name -Description $service.Description
            Set-MailSiteFirewallRules -Service $service -ExecutablePath $newExe
        }

        Remove-Item -LiteralPath $package -Force -ErrorAction SilentlyContinue

        $restartRequested = @()
        $restartFailures = @()
        foreach ($service in $Services) {
            if ($state.WasRunning[$service.Name]) {
                $restartRequested += $service.Name
                if (-not (Start-MailSiteService -ServiceName $service.Name)) {
                    $restartFailures += $service.Name
                }
            }
        }

        if ($restartFailures.Count -gt 0) {
            Write-InstallerMessage "MailSite $targetVersion installation completed, but these previously running services could not be restarted: $($restartFailures -join ', ')." -Level "WARN"
        } elseif ($restartRequested.Count -gt 0) {
            Write-InstallerMessage "MailSite $targetVersion installation completed successfully. Restarted previously running services: $($restartRequested -join ', ')."
        } else {
            Write-InstallerMessage "MailSite $targetVersion installation completed successfully. No services were running before install."
        }
    } catch {
        if ($servicesStopped -and $null -ne $state) {
            Write-InstallerMessage "Install failed. Restoring previous service paths and descriptions..." -Level "WARN"
            foreach ($service in $Services) {
                $previous = $rollbackImagePath[$service.Name]
                if (-not [string]::IsNullOrWhiteSpace($previous)) {
                    $path = "HKLM:\SYSTEM\CurrentControlSet\Services\$($service.Name)"
                    Set-ItemProperty -Path $path -Name ImagePath -Value $previous
                }
                if ($state.PreviousDescription.ContainsKey($service.Name)) {
                    Set-ServiceDescription -ServiceName $service.Name -Description $state.PreviousDescription[$service.Name]
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
