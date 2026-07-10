[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$InstallTarget,
    [string]$InstallDir = (Join-Path $env:ProgramFiles "MailSite"),
    [string]$PackagePath,
    [string]$PackageUrl = "https://github.com/rockliffe/mailsite-server-release/raw/main/MailSite.zip",
    [string]$LicenseApiBaseUrl
)

$ErrorActionPreference = "Stop"

# Windows PowerShell 5.1 may default to TLS 1.0/1.1, which the license service
# and download hosts reject. OR TLS 1.2 into the current protocol set (never
# replace it) before the first web request.
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

$Services = @(
    @{ Name = "HTTPMA"; File = "httpma.exe"; Description = "MailSite HTTP Management Agent" },
    @{ Name = "EWSMA"; File = "ewsma.exe"; Description = "MailSite EWS Management Agent"; LegacyService = $false },
    @{ Name = "EASMA"; File = "easma.exe"; Description = "MailSite Exchange ActiveSync Management Agent"; LegacyService = $false },
    @{ Name = "IMAP4A"; File = "imap4a.exe"; Description = "MailSite IMAP4 Server" },
    @{ Name = "POP3A"; File = "pop3a.exe"; Description = "MailSite POP3 Agent"; VersionDetectionRequired = $false },
    @{ Name = "SMTPRA"; File = "smtpra.exe"; Description = "MailSite SMTP Receiving Agent" },
    @{ Name = "SMTPDA"; File = "smtpda.exe"; Description = "MailSite SMTP Delivery Agent" }
)

$DesktopApps = @(
    @{ Name = "ExpressPro"; File = "expresspro.exe"; ShortcutName = "ExpressPro" },
    @{ Name = "Console"; File = "console.exe"; ShortcutName = "MailSite Console" }
)

$MailSiteKey32 = "HKLM:\SOFTWARE\Wow6432Node\Rockliffe\MailSite"
$InstallMarkerName = ".mailsite11-install.json"
$RequiredLegacyMajorVersion = "10"
$TargetMajorVersion = "11"
# DEV PHASE: points at mailsite.dev while v11 licensing is being tested.
# Switch to https://www.mailsite.com (here and in Library's
# DEFAULT_LICENSE_API_BASE_URL) before the first production release.
$DefaultLicenseApiBaseUrl = "https://mailsite.dev"
$FreshTrialLicenseRequest = "__MAILSITE_ONLINE_TRIAL__"
$LicenseValidationCacheName = ".mailsite-license-validation.json"
# Marks license-rejection throws from Assert-MailSite10 so upgrade paths can
# tell them apart from "MailSite 10 is not present" failures.
$LicenseRejectedMessagePrefix = "The existing MailSite license was rejected by the license service:"
$WebView2RuntimeClientGuid = "{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}"
$WebView2BootstrapperUrl = "https://go.microsoft.com/fwlink/p/?LinkId=2124703"
$script:LogPath = $null

function Test-InstallerAnsiSupported {
    try {
        return ($Host.UI.SupportsVirtualTerminal -eq $true)
    } catch {
        return $false
    }
}

function Format-InstallerConsoleMessage {
    param([string]$Message)

    if ([string]::IsNullOrWhiteSpace($Message) -or -not (Test-InstallerAnsiSupported)) {
        return $Message
    }

    $versionColor = [string][char]27 + "[96m"
    $reset = [string][char]27 + "[0m"
    return [regex]::Replace($Message, '\b(?:10|11)\.[0-9]+\.[0-9]+\b', {
        param($match)
        return "$versionColor$($match.Value)$reset"
    })
}

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
        "ERROR" { Write-Host (Format-InstallerConsoleMessage -Message $Message) -ForegroundColor Red }
        "WARN" { Write-Host (Format-InstallerConsoleMessage -Message $Message) -ForegroundColor Yellow }
        default { Write-Host (Format-InstallerConsoleMessage -Message $Message) }
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

function Test-MailSiteServiceInstalled {
    param([string]$ServiceName)

    return ($null -ne (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue))
}

function Get-MailSiteServiceLogOnAccount {
    param([string]$ServiceName)

    $escapedName = $ServiceName.Replace("'", "''")
    $service = Get-CimInstance -ClassName Win32_Service -Filter "Name='$escapedName'" -ErrorAction SilentlyContinue
    if ($null -eq $service) {
        throw "Windows service '$ServiceName' is not installed."
    }
    if ([string]::IsNullOrWhiteSpace($service.StartName)) {
        return $null
    }

    return [string]$service.StartName
}

function Normalize-ServiceLogOnAccount {
    param([string]$AccountName)

    if ([string]::IsNullOrWhiteSpace($AccountName)) {
        return ""
    }

    $lower = $AccountName.Trim().ToLowerInvariant()
    $withoutDot = if ($lower.StartsWith(".\")) { $lower.Substring(2) } else { $lower }
    switch ($withoutDot) {
        "localsystem" { return "nt authority\system" }
        "system" { return "nt authority\system" }
        "nt authority\system" { return "nt authority\system" }
        "localservice" { return "nt authority\localservice" }
        "nt authority\localservice" { return "nt authority\localservice" }
        "networkservice" { return "nt authority\networkservice" }
        "nt authority\networkservice" { return "nt authority\networkservice" }
    }

    if ($lower.StartsWith(".\")) {
        $computer = if ([string]::IsNullOrWhiteSpace($env:COMPUTERNAME)) { "" } else { ([string]$env:COMPUTERNAME).ToLowerInvariant() }
        if ([string]::IsNullOrWhiteSpace($computer)) {
            return $withoutDot
        }
        return "$computer\$withoutDot"
    }

    return $lower
}

function Format-ServiceLogOnAccount {
    param([string]$AccountName)

    switch (Normalize-ServiceLogOnAccount -AccountName $AccountName) {
        "nt authority\system" { return "LocalSystem" }
        "nt authority\localservice" { return "NT AUTHORITY\LocalService" }
        "nt authority\networkservice" { return "NT AUTHORITY\NetworkService" }
        default { return $AccountName.Trim() }
    }
}

function Get-MailSiteServiceAccountAudit {
    $accounts = [ordered]@{}
    $groups = [ordered]@{}

    foreach ($service in $Services) {
        if (-not (Test-MailSiteServiceInstalled -ServiceName $service.Name)) {
            continue
        }

        try {
            $account = Get-MailSiteServiceLogOnAccount -ServiceName $service.Name
        } catch {
            Write-InstallerMessage "Could not read the Log On As account for $($service.Name): $($_.Exception.Message)" -Level "WARN"
            continue
        }

        if ([string]::IsNullOrWhiteSpace($account)) {
            continue
        }

        $accounts[$service.Name] = $account
        $normalized = Normalize-ServiceLogOnAccount -AccountName $account
        if (-not $groups.Contains($normalized)) {
            $groups[$normalized] = [ordered]@{
                Display = Format-ServiceLogOnAccount -AccountName $account
                Services = @()
            }
        }
        $groups[$normalized].Services += $service.Name
    }

    return @{
        Accounts = $accounts
        Groups = $groups
        Mismatch = ($groups.Count -gt 1)
    }
}

function Format-MailSiteServiceAccountGroups {
    param([hashtable]$Audit)

    if ($null -eq $Audit -or $null -eq $Audit.Groups) {
        return ""
    }

    $parts = @()
    foreach ($group in $Audit.Groups.Values) {
        $parts += "$($group.Services -join ', ') = $($group.Display)"
    }
    return ($parts -join "; ")
}

function Write-MailSiteServiceAccountMismatchWarning {
    param([hashtable]$Audit)

    if ($null -eq $Audit -or -not [bool]$Audit.Mismatch) {
        return
    }

    $summary = Format-MailSiteServiceAccountGroups -Audit $Audit
    Write-InstallerMessage "MailSite Windows services are configured with different Log On As accounts: $summary. Configure all MailSite Windows services to use the same account, then restart them." -Level "WARN"
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

function Stop-MailSiteDesktopApps {
    param([string]$RootDirectory)

    foreach ($app in $DesktopApps) {
        $exePath = Join-Path $RootDirectory $app.File
        $processName = [IO.Path]::GetFileNameWithoutExtension($app.File)
        $processes = @(
            Get-Process -Name $processName -ErrorAction SilentlyContinue |
                Where-Object {
                    try {
                        [string]::Equals($_.Path, $exePath, [StringComparison]::OrdinalIgnoreCase)
                    } catch {
                        $false
                    }
                }
        )

        if ($processes.Count -eq 0) {
            continue
        }

        Write-InstallerMessage "Stopping $($app.Name) desktop app before replacing files..."
        $processes | Stop-Process -Force -ErrorAction Stop
        foreach ($process in $processes) {
            try {
                Wait-Process -Id $process.Id -Timeout 15 -ErrorAction Stop
            } catch {
                Write-InstallerMessage "$($app.Name) process $($process.Id) did not exit within 15 seconds." -Level "WARN"
            }
        }
    }
}

function Get-PublicDesktopDirectory {
    $desktop = [Environment]::GetFolderPath([Environment+SpecialFolder]::CommonDesktopDirectory)
    if (-not [string]::IsNullOrWhiteSpace($desktop)) {
        return $desktop
    }

    if (-not [string]::IsNullOrWhiteSpace($env:PUBLIC)) {
        return (Join-Path $env:PUBLIC "Desktop")
    }

    return (Join-Path $env:SystemDrive "Users\Public\Desktop")
}

function New-MailSiteDesktopShortcuts {
    param([string]$RootDirectory)

    $desktop = Get-PublicDesktopDirectory
    New-Item -ItemType Directory -Path $desktop -Force | Out-Null
    $shell = $null

    try {
        $shell = New-Object -ComObject WScript.Shell
        foreach ($app in $DesktopApps) {
            $exePath = Join-Path $RootDirectory $app.File
            if (-not (Test-Path -LiteralPath $exePath)) {
                Write-InstallerMessage "Cannot create $($app.Name) desktop shortcut because $exePath does not exist." -Level "WARN"
                continue
            }

            $shortcutName = $app.ShortcutName
            if ([string]::IsNullOrWhiteSpace($shortcutName)) {
                $shortcutName = $app.Name
            }

            $shortcutPath = Join-Path $desktop "$shortcutName.lnk"
            $shortcut = $null
            try {
                $shortcut = $shell.CreateShortcut($shortcutPath)
                $shortcut.TargetPath = $exePath
                $shortcut.WorkingDirectory = $RootDirectory
                $shortcut.IconLocation = "$exePath,0"
                $shortcut.Description = "Launch $($app.Name)"
                $shortcut.Save()
                Write-InstallerMessage "Created all-users desktop shortcut: $shortcutPath"
            } catch {
                Write-InstallerMessage "Could not create desktop shortcut '$shortcutPath': $($_.Exception.Message)" -Level "WARN"
            } finally {
                if ($null -ne $shortcut) {
                    [Runtime.InteropServices.Marshal]::ReleaseComObject($shortcut) | Out-Null
                }
            }
        }
    } catch {
        Write-InstallerMessage "Could not create all-users desktop shortcuts: $($_.Exception.Message)" -Level "WARN"
    } finally {
        if ($null -ne $shell) {
            [Runtime.InteropServices.Marshal]::ReleaseComObject($shell) | Out-Null
        }
    }
}

function Get-WebView2RuntimeRegistryPaths {
    return @(
        "HKLM:\SOFTWARE\Microsoft\EdgeUpdate\Clients\$WebView2RuntimeClientGuid",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\$WebView2RuntimeClientGuid",
        "HKCU:\SOFTWARE\Microsoft\EdgeUpdate\Clients\$WebView2RuntimeClientGuid",
        "HKCU:\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\$WebView2RuntimeClientGuid"
    )
}

function Test-WebView2RuntimeInstalled {
    foreach ($path in (Get-WebView2RuntimeRegistryPaths)) {
        $version = Get-RegistryString -Path $path -Name "pv"
        if (-not [string]::IsNullOrWhiteSpace($version) -and $version -ne "0.0.0.0") {
            return $true
        }

        $location = Get-RegistryString -Path $path -Name "location"
        if (-not [string]::IsNullOrWhiteSpace($location)) {
            $runtimeExe = Join-Path $location "msedgewebview2.exe"
            if (Test-Path -LiteralPath $runtimeExe) {
                return $true
            }
        }
    }

    $applicationRoots = @()
    if (-not [string]::IsNullOrWhiteSpace(${env:ProgramFiles(x86)})) {
        $applicationRoots += (Join-Path ${env:ProgramFiles(x86)} "Microsoft\EdgeWebView\Application")
    }
    if (-not [string]::IsNullOrWhiteSpace($env:ProgramFiles)) {
        $applicationRoots += (Join-Path $env:ProgramFiles "Microsoft\EdgeWebView\Application")
    }

    foreach ($root in $applicationRoots) {
        if (-not (Test-Path -LiteralPath $root -PathType Container)) {
            continue
        }

        $directRuntimeExe = Join-Path $root "msedgewebview2.exe"
        if (Test-Path -LiteralPath $directRuntimeExe) {
            return $true
        }

        $versionDirectories = @(Get-ChildItem -LiteralPath $root -Directory -ErrorAction SilentlyContinue)
        foreach ($directory in $versionDirectories) {
            $runtimeExe = Join-Path $directory.FullName "msedgewebview2.exe"
            if (Test-Path -LiteralPath $runtimeExe) {
                return $true
            }
        }
    }

    return $false
}

function Install-WebView2Runtime {
    if (Test-WebView2RuntimeInstalled) {
        Write-InstallerMessage "Microsoft Edge WebView2 Runtime is already installed."
        return
    }

    Write-InstallerMessage "Microsoft Edge WebView2 Runtime was not detected. Installing WebView2 Runtime..."
    $tempRoot = Join-Path ([IO.Path]::GetTempPath()) ("MailSite-WebView2-" + [Guid]::NewGuid().ToString("N"))
    $installerPath = Join-Path $tempRoot "MicrosoftEdgeWebView2Setup.exe"

    try {
        New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
        # TLS 1.2 is enabled once at script start.
        Invoke-WebRequest -Uri $WebView2BootstrapperUrl -OutFile $installerPath -UseBasicParsing -ErrorAction Stop

        $process = Start-Process -FilePath $installerPath -ArgumentList "/silent", "/install" -Wait -PassThru
        if ($process.ExitCode -ne 0 -and -not (Test-WebView2RuntimeInstalled)) {
            throw "WebView2 bootstrapper exited with code $($process.ExitCode)."
        }

        if (-not (Test-WebView2RuntimeInstalled)) {
            throw "WebView2 bootstrapper completed, but the runtime still was not detected."
        }

        if ($process.ExitCode -ne 0) {
            Write-InstallerMessage "WebView2 bootstrapper exited with code $($process.ExitCode), but the runtime is now installed." -Level "WARN"
        } else {
            Write-InstallerMessage "Microsoft Edge WebView2 Runtime installed successfully."
        }
    } catch {
        throw "Microsoft Edge WebView2 Runtime is required by ExpressPro and Console, but automatic install failed. Install it from https://developer.microsoft.com/en-us/microsoft-edge/webview2/ and retry. $($_.Exception.Message)"
    } finally {
        Remove-Item -Path $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
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
    if (-not [string]::IsNullOrWhiteSpace($versionInfo.ProductVersion)) {
        return $versionInfo.ProductVersion.Trim()
    }
    throw "Executable $Path has no FileVersion/ProductVersion resource."
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

function Test-MailSiteLegacyService {
    param([hashtable]$Service)

    if ($Service.ContainsKey("LegacyService")) {
        return [bool]$Service.LegacyService
    }

    return $true
}

function Get-MailSiteLicenseApiBaseUrl {
    if (-not [string]::IsNullOrWhiteSpace($LicenseApiBaseUrl)) {
        return $LicenseApiBaseUrl.Trim().TrimEnd("/")
    }

    if (-not [string]::IsNullOrWhiteSpace($env:MAILSITE_LICENSE_API_BASE_URL)) {
        return ([string]$env:MAILSITE_LICENSE_API_BASE_URL).Trim().TrimEnd("/")
    }

    return $DefaultLicenseApiBaseUrl
}

function Join-MailSiteLicenseApiUri {
    param([string]$Path)

    $base = Get-MailSiteLicenseApiBaseUrl
    $relative = if ($Path.StartsWith("/")) { $Path.Substring(1) } else { $Path }
    return "$base/$relative"
}

function ConvertFrom-MailSiteJsonSafe {
    param([string]$Json)

    if ([string]::IsNullOrWhiteSpace($Json)) {
        return $null
    }

    try {
        return ($Json | ConvertFrom-Json)
    } catch {
        return $null
    }
}

function Invoke-MailSiteLicenseApiJson {
    param(
        [string]$Path,
        [hashtable]$Body,
        [Microsoft.PowerShell.Commands.WebRequestSession]$WebSession
    )

    $uri = Join-MailSiteLicenseApiUri -Path $Path
    $json = $Body | ConvertTo-Json -Depth 8
    $arguments = @{
        Uri = $uri
        Method = "Post"
        ContentType = "application/json"
        Body = $json
        TimeoutSec = 20
        ErrorAction = "Stop"
    }
    if ($null -ne $WebSession) {
        $arguments.WebSession = $WebSession
    }

    try {
        $responseBody = Invoke-RestMethod @arguments
        return @{
            Ok = $true
            StatusCode = 200
            Body = $responseBody
            Uri = $uri
            Error = $null
        }
    } catch {
        $statusCode = $null
        if ($_.Exception.Response -and $_.Exception.Response.StatusCode) {
            $statusCode = [int]$_.Exception.Response.StatusCode
        }

        $body = $null
        if ($_.ErrorDetails -and -not [string]::IsNullOrWhiteSpace($_.ErrorDetails.Message)) {
            $body = ConvertFrom-MailSiteJsonSafe -Json $_.ErrorDetails.Message
        }

        return @{
            Ok = $false
            StatusCode = $statusCode
            Body = $body
            Uri = $uri
            Error = $_.Exception.Message
        }
    }
}

function Get-MailSiteLicenseApiResponseMessage {
    param([hashtable]$Response)

    if ($null -ne $Response.Body) {
        if ($Response.Body.PSObject.Properties.Name -contains "message") {
            return [string]$Response.Body.message
        }
        if ($Response.Body -is [string]) {
            return [string]$Response.Body
        }
    }

    if (-not [string]::IsNullOrWhiteSpace($Response.Error)) {
        return [string]$Response.Error
    }

    return "The license service did not return a usable response."
}

function Save-MailSiteLicenseValidationCache {
    param(
        [string]$InstallDirectory,
        [object]$ValidationBody
    )

    if ($null -eq $ValidationBody -or [string]::IsNullOrWhiteSpace($ValidationBody.validationToken)) {
        return
    }

    try {
        New-Item -ItemType Directory -Path $InstallDirectory -Force | Out-Null
        $cache = [ordered]@{
            CachedAtUtc = [DateTimeOffset]::UtcNow.ToString("o")
            LicenseKey = $ValidationBody.license.licenseKey
            SerialNo = $ValidationBody.license.serialNo
            ProductId = $ValidationBody.license.productId
            ProductVersion = $ValidationBody.license.productVersion
            Trial = [bool]$ValidationBody.license.trial
            Validation = $ValidationBody.validation
            ValidationToken = $ValidationBody.validationToken
        }
        $path = Join-Path $InstallDirectory $LicenseValidationCacheName
        $cache | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $path -Encoding UTF8
        Write-InstallerMessage "Cached signed license validation through $($ValidationBody.validation.graceUntil)."
    } catch {
        Write-InstallerMessage "Could not write license validation cache: $($_.Exception.Message)" -Level "WARN"
    }
}

function Test-MailSiteOnlineLicenseValidation {
    param(
        [string]$LicenseKey,
        [int[]]$AllowedProductMajors = @([int]$TargetMajorVersion)
    )

    $response = Invoke-MailSiteLicenseApiJson `
        -Path "/api/license/validate" `
        -Body @{
            licenseKey = $LicenseKey
            allowedProductMajors = @($AllowedProductMajors)
        }

    # Classify by HTTP status code first, then by response body shape:
    #   2xx with a recognizable body -> definite valid/invalid result
    #   4xx                          -> definite rejection
    #   5xx / network error / unparseable 2xx -> unavailable (fail open)
    $statusCode = 0
    if ($null -ne $response.StatusCode) {
        $statusCode = [int]$response.StatusCode
    }

    if ($statusCode -ge 200 -and $statusCode -le 299 -and $null -ne $response.Body) {
        if ($response.Body.valid -eq $true) {
            return @{
                Outcome = "valid"
                Status = [string]$response.Body.status
                Message = [string]$response.Body.message
                Body = $response.Body
            }
        }

        if ($response.Body.PSObject.Properties.Name -contains "status") {
            return @{
                Outcome = "invalid"
                Status = [string]$response.Body.status
                Message = Get-MailSiteLicenseApiResponseMessage -Response $response
                Body = $response.Body
            }
        }
        # A 2xx body without the expected shape falls through to unavailable.
    }

    if ($statusCode -ge 400 -and $statusCode -le 499) {
        $status = $null
        if ($null -ne $response.Body -and $response.Body.PSObject.Properties.Name -contains "status") {
            $status = [string]$response.Body.status
        }
        return @{
            Outcome = "invalid"
            Status = $status
            Message = Get-MailSiteLicenseApiResponseMessage -Response $response
            Body = $response.Body
        }
    }

    return @{
        Outcome = "unavailable"
        Status = $null
        Message = Get-MailSiteLicenseApiResponseMessage -Response $response
        Body = $response.Body
    }
}

function Assert-MailSite10 {
    if (-not (Test-Path $MailSiteKey32)) {
        throw "This installation of MailSite 11 requires an existing 32-bit MailSite $RequiredLegacyMajorVersion.x registry key at $MailSiteKey32."
    }

    # "License" is deliberately not required here: legacy v10 DEMO installs
    # store a blank License value, which is handled with a warning below.
    foreach ($name in @("Version", "InstallDir", "RegistryFormatVersion", "ServerMajorVersion")) {
        Assert-RegistryValuePresent -Path $MailSiteKey32 -Name $name
    }

    $version = Get-RegistryString -Path $MailSiteKey32 -Name "Version"
    if ([string]::IsNullOrWhiteSpace($version) -or -not $version.StartsWith("$RequiredLegacyMajorVersion.")) {
        throw "This installation of MailSite 11 requires an existing MailSite $RequiredLegacyMajorVersion.x installation. Found registry version '$version'."
    }

    $legacyLicenseKey = Get-RegistryString -Path $MailSiteKey32 -Name "License"
    if ([string]::IsNullOrWhiteSpace($legacyLicenseKey)) {
        # Legacy v10 DEMO installs store a blank License value; there is no key
        # to validate online, so don't call the license service.
        Write-InstallerMessage "The existing MailSite installation has no license key on record (legacy demo install). The upgraded server will need a valid MailSite license key." -Level "WARN"
    } else {
        Write-InstallerMessage "Checking existing MailSite license with the MailSite license service..."
        $licenseValidation = Test-MailSiteOnlineLicenseValidation -LicenseKey $legacyLicenseKey -AllowedProductMajors @(10, 11)
        if ($licenseValidation.Outcome -eq "valid") {
            Write-InstallerMessage "Existing MailSite license was accepted by the license service."
            Save-MailSiteLicenseValidationCache -InstallDirectory $InstallDir -ValidationBody $licenseValidation.Body
        } elseif ($licenseValidation.Outcome -eq "invalid") {
            throw "$LicenseRejectedMessagePrefix $($licenseValidation.Message)"
        } else {
            Write-InstallerMessage "Could not reach the MailSite license service; continuing with the local upgrade checks. $($licenseValidation.Message)" -Level "WARN"
        }
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
        if (-not (Test-MailSiteLegacyService -Service $service)) {
            continue
        }

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

    Write-InstallerMessage "Downloading MailSite package to $DestinationPath..."
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

    $required = @("httpma.exe", "ewsma.exe", "easma.exe", "imap4a.exe", "pop3a.exe", "smtpra.exe", "smtpda.exe", "expresspro.exe", "console.exe")
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

function Test-MailSiteVersionDetectionRequired {
    param([hashtable]$Service)

    if ($Service.ContainsKey("VersionDetectionRequired")) {
        return [bool]$Service.VersionDetectionRequired
    }

    return $true
}

function New-EmptyInstalledMailSite11State {
    return @{
        IsInstalled = $false
        IsPartial = $false
        IsMixed = $false
        ExactVersion = $null
        DisplayVersion = $null
        OldestVersion = $null
        NewestVersion = $null
        ComponentVersions = @{}
        MissingComponents = @()
        InvalidComponents = @()
    }
}

function Get-InstalledMailSite11State {
    param([string]$RootDirectory)

    $state = New-EmptyInstalledMailSite11State
    if (-not (Test-Path -LiteralPath $RootDirectory -PathType Container)) {
        return $state
    }

    foreach ($service in $Services) {
        $exe = Join-Path $RootDirectory $service.File
        if (-not (Test-Path -LiteralPath $exe)) {
            $state.MissingComponents += $service.Name
            continue
        }

        try {
            $version = Get-ProductVersion -Path $exe
        } catch {
            $state.InvalidComponents += "$($service.Name) ($($_.Exception.Message))"
            continue
        }

        if ([string]::IsNullOrWhiteSpace($version) -or -not $version.StartsWith("$TargetMajorVersion.")) {
            $state.InvalidComponents += "$($service.Name) ($version)"
            continue
        }

        $state.ComponentVersions[$service.Name] = ConvertTo-MailSiteDisplayVersion -Version $version
    }

    foreach ($service in $Services) {
        if ((Test-MailSiteVersionDetectionRequired -Service $service) -and -not $state.ComponentVersions.ContainsKey($service.Name)) {
            return $state
        }
    }

    $state.IsInstalled = $true
    $state.IsPartial = (($state.MissingComponents.Count -gt 0) -or ($state.InvalidComponents.Count -gt 0))

    $uniqueVersions = @($state.ComponentVersions.Values | Sort-Object -Unique)
    $orderedVersions = @($uniqueVersions | Sort-Object { [version]$_ })
    if ($orderedVersions.Count -eq 0) {
        return $state
    }

    $state.OldestVersion = $orderedVersions[0]
    $state.NewestVersion = $orderedVersions[$orderedVersions.Count - 1]
    if ($orderedVersions.Count -eq 1) {
        $state.ExactVersion = $orderedVersions[0]
        $state.DisplayVersion = $orderedVersions[0]
    } else {
        $state.IsMixed = $true
        $state.DisplayVersion = ($orderedVersions -join ", ")
    }

    return $state
}

function Get-InstalledMailSite11Version {
    param([string]$RootDirectory)

    $state = Get-InstalledMailSite11State -RootDirectory $RootDirectory
    return $state.DisplayVersion
}

function Get-InstalledMailSiteComparisonVersion {
    param([hashtable]$InstalledState)

    if ($null -eq $InstalledState -or -not $InstalledState.IsInstalled) {
        return $null
    }

    return $InstalledState.NewestVersion
}

function Get-InstalledMailSiteDisplayVersion {
    param([hashtable]$InstalledState)

    if ($null -eq $InstalledState -or -not $InstalledState.IsInstalled) {
        return $null
    }

    return $InstalledState.DisplayVersion
}

function Test-MailSiteInstallNeedsRepair {
    param([hashtable]$InstalledState)

    return ($null -ne $InstalledState -and $InstalledState.IsInstalled -and ($InstalledState.IsPartial -or $InstalledState.IsMixed))
}

function Get-MailSiteComponentVersionSummary {
    param([hashtable]$InstalledState)

    if ($null -eq $InstalledState -or -not $InstalledState.IsInstalled) {
        return ""
    }

    $parts = @()
    foreach ($service in $Services) {
        if ($InstalledState.ComponentVersions.ContainsKey($service.Name)) {
            $parts += "$($service.Name) $($InstalledState.ComponentVersions[$service.Name])"
        }
    }

    return ($parts -join ", ")
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
        $answer = Read-Host (Format-InstallerConsoleMessage -Message "$Prompt $suffix")
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

function Read-MailSiteVersionChoice {
    param(
        [string]$InstalledVersion,
        [hashtable]$InstalledState,
        [string[]]$Versions
    )

    if ($Versions.Count -eq 0) {
        return $null
    }

    $installedDisplayVersion = Get-InstalledMailSiteDisplayVersion -InstalledState $InstalledState
    if ([string]::IsNullOrWhiteSpace($installedDisplayVersion)) {
        $installedDisplayVersion = $InstalledVersion
    }

    if (-not [string]::IsNullOrWhiteSpace($installedDisplayVersion)) {
        Write-Host (Format-InstallerConsoleMessage -Message "You are running $installedDisplayVersion. Other versions available:  $($Versions -join ', ')")
    } else {
        Write-Host (Format-InstallerConsoleMessage -Message "Other versions available:  $($Versions -join ', ')")
    }

    while ($true) {
        $answer = Read-Host "Enter the version you would like to install (blank to cancel)"
        if ([string]::IsNullOrWhiteSpace($answer)) {
            return $null
        }

        $candidate = $answer.Trim()
        if ($Versions -contains $candidate) {
            return $candidate
        }

        Write-Host "Please enter one of: $($Versions -join ', ')." -ForegroundColor Yellow
    }
}

function Confirm-MailSiteInstall {
    param(
        [string]$Version,
        [string]$InstalledVersion,
        [hashtable]$InstalledState
    )

    Write-Host ""
    Write-Host "MailSite 11 Installer"
    Write-Host "====================="
    Write-Host "This script will install MailSite $Version."
    Write-Host "Install directory: $InstallDir"
    Write-Host ""
    $prompt = Get-MailSiteInstallPrompt -InstalledVersion $InstalledVersion -InstalledState $InstalledState -TargetVersion $Version
    return Read-YesNo -Prompt $prompt -DefaultYes $false
}

function Get-MailSiteInstallPrompt {
    param(
        [string]$InstalledVersion,
        [hashtable]$InstalledState,
        [string]$TargetVersion
    )

    $installedComparisonVersion = Get-InstalledMailSiteComparisonVersion -InstalledState $InstalledState
    $installedDisplayVersion = Get-InstalledMailSiteDisplayVersion -InstalledState $InstalledState
    $needsRepair = Test-MailSiteInstallNeedsRepair -InstalledState $InstalledState

    if ([string]::IsNullOrWhiteSpace($installedComparisonVersion)) {
        $installedComparisonVersion = $InstalledVersion
    }
    if ([string]::IsNullOrWhiteSpace($installedDisplayVersion)) {
        $installedDisplayVersion = $InstalledVersion
    }

    if ((Test-ExactMailSiteVersion -Version $installedComparisonVersion) -and (Test-ExactMailSiteVersion -Version $TargetVersion)) {
        $comparison = Compare-MailSiteVersions -Left $TargetVersion -Right $installedComparisonVersion
        if ($comparison -eq 0) {
            if ($needsRepair) {
                return "Repair MailSite $installedDisplayVersion with MailSite ${TargetVersion}?"
            }
            return "Reinstall MailSite ${TargetVersion}?"
        }
        if ($comparison -gt 0) {
            if ($InstalledState.IsMixed) {
                return "Repair and upgrade MailSite $installedDisplayVersion to MailSite ${TargetVersion}?"
            }
            return "Upgrade from MailSite $installedDisplayVersion to MailSite ${TargetVersion}?"
        }
        return "Downgrade from MailSite $installedDisplayVersion to MailSite ${TargetVersion}?"
    }

    return "Install MailSite ${TargetVersion}?"
}

function Get-MailSiteInstallActionMessage {
    param(
        [string]$TargetVersion,
        [hashtable]$InstalledState,
        [string]$InstallDirectory
    )

    $installedDisplayVersion = Get-InstalledMailSiteDisplayVersion -InstalledState $InstalledState
    if ([string]::IsNullOrWhiteSpace($installedDisplayVersion)) {
        return "Installing MailSite $TargetVersion to $InstallDirectory..."
    }

    $installedComparisonVersion = Get-InstalledMailSiteComparisonVersion -InstalledState $InstalledState
    $needsRepair = Test-MailSiteInstallNeedsRepair -InstalledState $InstalledState
    if ((Test-ExactMailSiteVersion -Version $TargetVersion) -and (Test-ExactMailSiteVersion -Version $installedComparisonVersion)) {
        $comparison = Compare-MailSiteVersions -Left $TargetVersion -Right $installedComparisonVersion
        if ($comparison -lt 0) {
            return "Downgrading MailSite $installedDisplayVersion to MailSite $TargetVersion in $InstallDirectory..."
        }
        if ($comparison -eq 0 -and $needsRepair) {
            return "Repairing MailSite $installedDisplayVersion with MailSite $TargetVersion in $InstallDirectory..."
        }
    }

    if ($needsRepair -and $InstalledState.IsMixed) {
        return "Repairing and upgrading MailSite $installedDisplayVersion to MailSite $TargetVersion in $InstallDirectory..."
    }

    return "Upgrading MailSite $installedDisplayVersion to MailSite $TargetVersion in $InstallDirectory..."
}

function New-InteractiveRemoteInstallRequest {
    param(
        [string]$TargetVersion,
        [string]$InstalledVersion,
        [hashtable]$InstalledState
    )

    $forceReinstall = $false
    $allowDowngrade = $false
    $installedComparisonVersion = Get-InstalledMailSiteComparisonVersion -InstalledState $InstalledState
    if ([string]::IsNullOrWhiteSpace($installedComparisonVersion)) {
        $installedComparisonVersion = $InstalledVersion
    }

    if ((Test-ExactMailSiteVersion -Version $TargetVersion) -and (Test-ExactMailSiteVersion -Version $installedComparisonVersion)) {
        $comparison = Compare-MailSiteVersions -Left $TargetVersion -Right $installedComparisonVersion
        $forceReinstall = ($comparison -eq 0)
        $allowDowngrade = ($comparison -lt 0)
    }

    return @{
        RemoteVersion = $TargetVersion
        ForceReinstall = $forceReinstall
        AllowDowngrade = $allowDowngrade
        Interactive = $true
        SkipConfirm = $true
        Cancelled = $false
    }
}

function Get-AlternativeRemotePackageVersions {
    param(
        [object[]]$Versions,
        [string]$InstalledVersion,
        [bool]$IncludeLatest = $false
    )

    if ($Versions.Count -eq 0) {
        return @()
    }

    $skipCount = if ($IncludeLatest) { 0 } else { 1 }
    $availableVersions = @($Versions | Select-Object -Skip $skipCount | ForEach-Object { $_.ToString() })
    if (-not (Test-ExactMailSiteVersion -Version $InstalledVersion)) {
        return $availableVersions
    }

    $selectedVersions = @()
    $olderThanInstalledCount = 0
    foreach ($version in $availableVersions) {
        if (-not (Test-ExactMailSiteVersion -Version $version)) {
            continue
        }

        $comparison = Compare-MailSiteVersions -Left $version -Right $InstalledVersion
        if ($comparison -lt 0) {
            $olderThanInstalledCount += 1
            if ($olderThanInstalledCount -gt 2) {
                continue
            }
        }

        $selectedVersions += $version
    }

    return $selectedVersions
}

function Resolve-InteractiveRemoteInstallRequest {
    param(
        [string]$InstalledVersion,
        [hashtable]$InstalledState,
        [hashtable]$LegacyInfo
    )

    $versions = @(Get-RemotePackageVersions)
    if ($versions.Count -eq 0) {
        throw "Could not find MailSite packages in the release repository."
    }

    $latestVersion = $versions[0].ToString()

    Write-InstallerMessage "Latest available MailSite version: $latestVersion."
    $includeLatestInAlternatives = $false
    $installedComparisonVersion = Get-InstalledMailSiteComparisonVersion -InstalledState $InstalledState
    if ([string]::IsNullOrWhiteSpace($installedComparisonVersion)) {
        $installedComparisonVersion = $InstalledVersion
    }
    $installedDisplayVersion = Get-InstalledMailSiteDisplayVersion -InstalledState $InstalledState
    if ([string]::IsNullOrWhiteSpace($installedDisplayVersion)) {
        $installedDisplayVersion = $InstalledVersion
    }

    if ((Test-ExactMailSiteVersion -Version $latestVersion) -and (Test-ExactMailSiteVersion -Version $installedComparisonVersion)) {
        $latestComparison = Compare-MailSiteVersions -Left $latestVersion -Right $installedComparisonVersion
        if ($latestComparison -eq 0) {
            if (Test-MailSiteInstallNeedsRepair -InstalledState $InstalledState) {
                Write-Host (Format-InstallerConsoleMessage -Message "MailSite $latestVersion matches the newest installed component, but the installation needs repair.")
            } else {
                Write-Host (Format-InstallerConsoleMessage -Message "MailSite $latestVersion is already installed.")
            }
            if (Read-YesNo -Prompt (Get-MailSiteInstallPrompt -InstalledVersion $InstalledVersion -InstalledState $InstalledState -TargetVersion $latestVersion) -DefaultYes $true) {
                return New-InteractiveRemoteInstallRequest -TargetVersion $latestVersion -InstalledVersion $InstalledVersion -InstalledState $InstalledState
            }
        } elseif ($latestComparison -gt 0) {
            if (Read-YesNo -Prompt (Get-MailSiteInstallPrompt -InstalledVersion $InstalledVersion -InstalledState $InstalledState -TargetVersion $latestVersion) -DefaultYes $true) {
                return New-InteractiveRemoteInstallRequest -TargetVersion $latestVersion -InstalledVersion $InstalledVersion -InstalledState $InstalledState
            }
        } else {
            Write-InstallerMessage "Installed MailSite $installedDisplayVersion is newer than the latest available package $latestVersion." -Level "WARN"
            $includeLatestInAlternatives = $true
        }
    } else {
        if (Read-YesNo -Prompt (Get-MailSiteInstallPrompt -InstalledVersion $InstalledVersion -InstalledState $InstalledState -TargetVersion $latestVersion) -DefaultYes $true) {
            return New-InteractiveRemoteInstallRequest -TargetVersion $latestVersion -InstalledVersion $InstalledVersion -InstalledState $InstalledState
        }
    }

    $alternativeVersions = @(Get-AlternativeRemotePackageVersions -Versions $versions -InstalledVersion $installedComparisonVersion -IncludeLatest $includeLatestInAlternatives)
    if ($alternativeVersions.Count -gt 0) {
        $selectedVersion = Read-MailSiteVersionChoice -InstalledVersion $InstalledVersion -InstalledState $InstalledState -Versions $alternativeVersions
        if (-not [string]::IsNullOrWhiteSpace($selectedVersion)) {
            return New-InteractiveRemoteInstallRequest -TargetVersion $selectedVersion -InstalledVersion $InstalledVersion -InstalledState $InstalledState
        }
    } else {
        Write-InstallerMessage "No other MailSite packages are available in the release repository." -Level "WARN"
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
    } else {
        $directions = @("Inbound")
    }

    foreach ($direction in $directions) {
        $displayName = "MailSite $($Service.Name) $direction"
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

function Remove-InstalledExpressProDist {
    param(
        [string]$PackageRoot,
        [string]$DestinationRoot
    )

    $packageDist = Join-Path $PackageRoot "WebServices\ExpressPro\dist"
    if (-not (Test-Path -LiteralPath $packageDist -PathType Container)) {
        Write-InstallerMessage "Package does not include ExpressPro dist folder; skipping frontend cleanup." -Level "WARN"
        return
    }

    $installedDist = Join-Path $DestinationRoot "WebServices\ExpressPro\dist"
    if (-not (Test-Path -LiteralPath $installedDist -PathType Container)) {
        return
    }

    Write-InstallerMessage "Removing old ExpressPro dist files from $installedDist..."
    Remove-Item -LiteralPath $installedDist -Recurse -Force
}

function Invoke-MailSiteExecutable {
    param(
        [string]$FilePath,
        [string[]]$ArgumentList
    )

    if (-not (Test-Path -LiteralPath $FilePath) -and $null -eq (Get-Command -Name $FilePath -ErrorAction SilentlyContinue)) {
        throw "Missing required executable: $FilePath"
    }

    # Merge stderr into the captured output without letting native stderr lines
    # become terminating errors under $ErrorActionPreference = "Stop".
    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & $FilePath @ArgumentList 2>&1 | ForEach-Object { $_.ToString() }
        return @{
            ExitCode = $LASTEXITCODE
            Output = @($output)
        }
    } finally {
        $ErrorActionPreference = $previousPreference
    }
}

function Read-MaskedInput {
    param([string]$Prompt)

    $secure = Read-Host -Prompt (Format-InstallerConsoleMessage -Message $Prompt) -AsSecureString
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    try {
        return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
    } finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
    }
}

function New-PostmasterPassword {
    # 16 characters from an unambiguous alphanumeric alphabet (no 0/O/o, 1/I/l/i).
    $alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789"
    $length = 16
    $rejectionLimit = 256 - (256 % $alphabet.Length)
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    try {
        $builder = New-Object System.Text.StringBuilder $length
        $buffer = New-Object byte[] 1
        while ($builder.Length -lt $length) {
            $rng.GetBytes($buffer)
            if ($buffer[0] -ge $rejectionLimit) {
                continue
            }
            [void]$builder.Append($alphabet[$buffer[0] % $alphabet.Length])
        }
        return $builder.ToString()
    } finally {
        $rng.Dispose()
    }
}

function Get-DefaultMailDomainName {
    # Legacy parity: the MailSite 10 installer defaulted the mail domain to the
    # TCP/IP host name plus the DNS domain suffix (when present), lowercased.
    $tcpipParameters = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
    $hostName = Get-RegistryString -Path $tcpipParameters -Name "HostName"
    if ([string]::IsNullOrWhiteSpace($hostName)) {
        $hostName = $env:COMPUTERNAME
    }

    $dnsDomain = Get-RegistryString -Path $tcpipParameters -Name "Domain"
    $default = if ([string]::IsNullOrWhiteSpace($dnsDomain)) { $hostName } else { "$hostName.$dnsDomain" }
    return $default.ToLowerInvariant()
}

function Read-FreshInstallDomainName {
    $default = Get-DefaultMailDomainName
    while ($true) {
        $answer = Read-Host "Mail domain name [$default]"
        $candidate = if ([string]::IsNullOrWhiteSpace($answer)) { $default } else { $answer.Trim() }
        if ($candidate -match '^[A-Za-z0-9][A-Za-z0-9.-]*$') {
            return $candidate.ToLowerInvariant()
        }

        Write-Host "Please enter a valid domain name (letters, digits, dots, and hyphens)." -ForegroundColor Yellow
    }
}

function Read-FreshInstallLicenseKeyText {
    $answer = Read-Host "MailSite license key (blank or TRIAL to sign in and create a 30-day trial)"
    if ([string]::IsNullOrWhiteSpace($answer)) {
        return $FreshTrialLicenseRequest
    }

    $candidate = $answer.Trim()
    if ($candidate -ieq "TRIAL" -or $candidate -ieq "DEMO") {
        return $FreshTrialLicenseRequest
    }

    return $candidate
}

function Test-FreshInstallTrialLicenseRequest {
    param([string]$LicenseKey)

    return [string]::IsNullOrWhiteSpace($LicenseKey) -or $LicenseKey -eq $FreshTrialLicenseRequest
}

function Read-FreshInstallLicenseKeyRetry {
    # Retry prompt after a failed license attempt. Offers an explicit abort so
    # the operator is never stuck looping between the key prompt and a failing
    # validation or trial sign-in.
    if (-not (Read-YesNo -Prompt "Try another license key or trial sign-in? (n aborts the installation)" -DefaultYes $true)) {
        throw "Installation aborted: no valid MailSite license key was provided."
    }

    return Read-FreshInstallLicenseKeyText
}

function Request-MailSiteTrialLicense {
    $baseUrl = Get-MailSiteLicenseApiBaseUrl
    Write-InstallerMessage "A MailSite portal account is required to create a 30-day trial license."
    Write-InstallerMessage "If you need an account, create one at $baseUrl/portal/sign-up, verify the email address, then return here."

    while ($true) {
        $email = Read-Host "MailSite account email (blank to enter a purchased license key instead)"
        if ([string]::IsNullOrWhiteSpace($email)) {
            return $null
        }

        $password = Read-MaskedInput -Prompt "MailSite account password"
        $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
        $login = Invoke-MailSiteLicenseApiJson `
            -Path "/api/auth/login" `
            -Body @{
                email = $email.Trim()
                password = $password
                rememberMe = $false
            } `
            -WebSession $session

        if (-not $login.Ok) {
            Write-InstallerMessage "MailSite account sign-in failed: $(Get-MailSiteLicenseApiResponseMessage -Response $login)" -Level "WARN"
            if (-not (Read-YesNo -Prompt "Try signing in again?" -DefaultYes $true)) {
                return $null
            }
            continue
        }

        $trial = Invoke-MailSiteLicenseApiJson `
            -Path "/api/license/trial" `
            -Body @{} `
            -WebSession $session

        if ($trial.Ok -and $null -ne $trial.Body -and $trial.Body.valid -eq $true -and -not [string]::IsNullOrWhiteSpace($trial.Body.license.licenseKey)) {
            return @{
                LicenseKey = [string]$trial.Body.license.licenseKey
                IsTrial = [bool]$trial.Body.license.trial
                OnlineValidation = $trial.Body
                Summary = "$($trial.Body.license.package), expires $($trial.Body.license.expiresAt)"
            }
        }

        Write-InstallerMessage "The MailSite trial license could not be created: $(Get-MailSiteLicenseApiResponseMessage -Response $trial)" -Level "WARN"
        if (-not (Read-YesNo -Prompt "Try a different MailSite account?" -DefaultYes $true)) {
            return $null
        }
    }
}

function Resolve-FreshInstallLicenseKey {
    param(
        [string]$HttpmaPath,
        [string]$InitialKey
    )

    $key = $InitialKey
    while ($true) {
        # Validation payload returned by trial issuance for the current key,
        # when the key came from Request-MailSiteTrialLicense this iteration.
        $trialResolution = $null
        if (Test-FreshInstallTrialLicenseRequest -LicenseKey $key) {
            $trial = Request-MailSiteTrialLicense
            if ($null -eq $trial) {
                $key = Read-FreshInstallLicenseKeyRetry
                continue
            }
            $key = $trial.LicenseKey
            $trialResolution = $trial
        }

        Write-InstallerMessage "Validating MailSite license key..."
        $result = Invoke-MailSiteExecutable -FilePath $HttpmaPath -ArgumentList @("license-info", "--require-current", $key)
        if ($result.ExitCode -eq 0) {
            foreach ($line in @($result.Output)) {
                if (-not [string]::IsNullOrWhiteSpace($line)) {
                    Write-InstallerMessage "  $line"
                }
            }

            if ($null -ne $trialResolution -and $null -ne $trialResolution.OnlineValidation) {
                # Trial issuance already returned a signed validation payload;
                # use it instead of a redundant re-validate that could
                # transiently fail and drop the trial marker.
                Write-InstallerMessage "Using the license validation returned with the MailSite trial license."
                Save-MailSiteLicenseValidationCache -InstallDirectory $InstallDir -ValidationBody $trialResolution.OnlineValidation
                return @{
                    LicenseKey = $key
                    IsTrial = $true
                    OnlineValidation = $trialResolution.OnlineValidation
                    Summary = $trialResolution.Summary
                }
            }

            $onlineValidation = Test-MailSiteOnlineLicenseValidation -LicenseKey $key -AllowedProductMajors @([int]$TargetMajorVersion)
            if ($onlineValidation.Outcome -eq "valid") {
                Write-InstallerMessage "MailSite license service accepted the license key."
                Save-MailSiteLicenseValidationCache -InstallDirectory $InstallDir -ValidationBody $onlineValidation.Body
                return @{
                    LicenseKey = $key
                    IsTrial = [bool]$onlineValidation.Body.license.trial
                    OnlineValidation = $onlineValidation.Body
                    Summary = "$($onlineValidation.Body.license.package), expires $($onlineValidation.Body.license.expiresAt)"
                }
            }
            if ($onlineValidation.Outcome -eq "invalid") {
                Write-InstallerMessage "The license service rejected the key: $($onlineValidation.Message)" -Level "WARN"
                $key = Read-FreshInstallLicenseKeyRetry
                continue
            }

            Write-InstallerMessage "Could not reach the MailSite license service; accepting the locally decoded license. $($onlineValidation.Message)" -Level "WARN"
            return @{
                LicenseKey = $key
                IsTrial = $false
                OnlineValidation = $null
                Summary = $null
            }
        }

        $detail = (@($result.Output) -join "; ").Trim()
        Write-InstallerMessage "The license key was not accepted: $detail" -Level "WARN"
        $key = Read-FreshInstallLicenseKeyRetry
    }
}

function Read-FreshInstallPostmasterPassword {
    while ($true) {
        $password = Read-MaskedInput -Prompt "Postmaster password (blank to autogenerate)"
        if ([string]::IsNullOrEmpty($password)) {
            Write-InstallerMessage "A random Postmaster password will be generated and shown at the end of the install."
            return @{ Password = New-PostmasterPassword; Generated = $true }
        }

        $confirmation = Read-MaskedInput -Prompt "Confirm Postmaster password"
        if ($password -ceq $confirmation) {
            return @{ Password = $password; Generated = $false }
        }

        Write-Host "The passwords do not match. Please try again." -ForegroundColor Yellow
    }
}

function Test-ServiceAccountCredential {
    param(
        [string]$UserName,
        [string]$Password
    )

    Add-Type -AssemblyName System.DirectoryServices.AccountManagement

    $parts = $UserName.Split('\')
    $domainPart = $parts[0]
    $userPart = $parts[1]
    $isMachineAccount = ($domainPart -eq "." -or $domainPart -ieq $env:COMPUTERNAME)

    $context = $null
    try {
        if ($isMachineAccount) {
            $context = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Machine)
        } else {
            $context = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Domain, $domainPart)
        }
        return $context.ValidateCredentials($userPart, $Password)
    } catch {
        Write-InstallerMessage "Could not validate credentials for '$UserName': $($_.Exception.Message)" -Level "WARN"
        return $false
    } finally {
        if ($null -ne $context) {
            $context.Dispose()
        }
    }
}

function Read-FreshInstallServiceAccount {
    Write-Host "MailSite services run as the LocalSystem account by default."
    while ($true) {
        $answer = Read-Host "Service account (blank for LocalSystem, or DOMAIN\user)"
        if ([string]::IsNullOrWhiteSpace($answer)) {
            return $null
        }

        $candidate = $answer.Trim()
        if ($candidate -ieq "LocalSystem") {
            return $null
        }

        if ($candidate -notmatch '^[^\\]+\\[^\\]+$') {
            Write-Host "Enter the account as DOMAIN\user (or .\user for a local account), or leave blank for LocalSystem." -ForegroundColor Yellow
            continue
        }

        $parts = $candidate.Split('\')
        if ($parts[0] -eq ".") {
            $candidate = "$env:COMPUTERNAME\$($parts[1])"
        }

        $password = Read-MaskedInput -Prompt "Password for $candidate"
        Write-InstallerMessage "Validating credentials for $candidate..."
        if (Test-ServiceAccountCredential -UserName $candidate -Password $password) {
            Write-InstallerMessage "Credentials for $candidate were validated."
            return @{ UserName = $candidate; Password = $password }
        }

        Write-Host "Could not validate the credentials for '$candidate'. Please try again." -ForegroundColor Yellow
    }
}

function Add-LsaRightsType {
    if ("MailSiteLsaRights" -as [type]) {
        return
    }

    Add-Type -TypeDefinition @"
using System;
using System.ComponentModel;
using System.Runtime.InteropServices;

public static class MailSiteLsaRights
{
    [StructLayout(LayoutKind.Sequential)]
    private struct LSA_UNICODE_STRING
    {
        public ushort Length;
        public ushort MaximumLength;
        public IntPtr Buffer;
    }

    [StructLayout(LayoutKind.Sequential)]
    private struct LSA_OBJECT_ATTRIBUTES
    {
        public int Length;
        public IntPtr RootDirectory;
        public IntPtr ObjectName;
        public uint Attributes;
        public IntPtr SecurityDescriptor;
        public IntPtr SecurityQualityOfService;
    }

    [DllImport("advapi32.dll", PreserveSig = true)]
    private static extern uint LsaOpenPolicy(IntPtr SystemName, ref LSA_OBJECT_ATTRIBUTES ObjectAttributes, uint DesiredAccess, out IntPtr PolicyHandle);

    [DllImport("advapi32.dll", PreserveSig = true)]
    private static extern uint LsaAddAccountRights(IntPtr PolicyHandle, IntPtr AccountSid, LSA_UNICODE_STRING[] UserRights, uint CountOfRights);

    [DllImport("advapi32.dll")]
    private static extern uint LsaClose(IntPtr PolicyHandle);

    [DllImport("advapi32.dll")]
    private static extern uint LsaNtStatusToWinError(uint Status);

    private const uint POLICY_CREATE_ACCOUNT = 0x00000010;
    private const uint POLICY_LOOKUP_NAMES = 0x00000800;

    public static void AddAccountRight(byte[] accountSid, string rightName)
    {
        LSA_OBJECT_ATTRIBUTES attributes = new LSA_OBJECT_ATTRIBUTES();
        IntPtr policyHandle;
        uint status = LsaOpenPolicy(IntPtr.Zero, ref attributes, POLICY_CREATE_ACCOUNT | POLICY_LOOKUP_NAMES, out policyHandle);
        if (status != 0)
        {
            throw new Win32Exception((int)LsaNtStatusToWinError(status));
        }

        IntPtr sidPointer = Marshal.AllocHGlobal(accountSid.Length);
        IntPtr rightPointer = Marshal.StringToHGlobalUni(rightName);
        try
        {
            Marshal.Copy(accountSid, 0, sidPointer, accountSid.Length);
            LSA_UNICODE_STRING[] rights = new LSA_UNICODE_STRING[1];
            rights[0].Buffer = rightPointer;
            rights[0].Length = (ushort)(rightName.Length * 2);
            rights[0].MaximumLength = (ushort)((rightName.Length + 1) * 2);
            status = LsaAddAccountRights(policyHandle, sidPointer, rights, 1);
            if (status != 0)
            {
                throw new Win32Exception((int)LsaNtStatusToWinError(status));
            }
        }
        finally
        {
            Marshal.FreeHGlobal(rightPointer);
            Marshal.FreeHGlobal(sidPointer);
            LsaClose(policyHandle);
        }
    }
}
"@
}

function Grant-ServiceLogonRight {
    param([string]$AccountName)

    Add-LsaRightsType
    $account = New-Object System.Security.Principal.NTAccount($AccountName)
    $sid = $account.Translate([System.Security.Principal.SecurityIdentifier])
    $sidBytes = New-Object byte[] ($sid.BinaryLength)
    $sid.GetBinaryForm($sidBytes, 0)
    [MailSiteLsaRights]::AddAccountRight($sidBytes, "SeServiceLogonRight")
    Write-InstallerMessage "Granted 'Log on as a service' (SeServiceLogonRight) to $AccountName."
}

function Invoke-MailSiteFreshSetup {
    param(
        [string]$HttpmaPath,
        [string]$LicenseKey,
        [string]$DomainName,
        [string]$PostmasterPassword,
        [string]$Version,
        [string]$InstallDirectory
    )

    Write-InstallerMessage "Creating MailSite registry defaults, default domain '$DomainName', and the Postmaster mailbox..."
    $arguments = @(
        "setup",
        "--license", $LicenseKey,
        "--domain", $DomainName,
        "--postmaster-password", $PostmasterPassword,
        "--version", $Version,
        "--install-dir", $InstallDirectory
    )
    $result = Invoke-MailSiteExecutable -FilePath $HttpmaPath -ArgumentList $arguments
    if ($result.ExitCode -ne 0) {
        $detail = (@($result.Output) -join [Environment]::NewLine).Trim()
        throw "MailSite setup failed (httpma.exe setup exited with code $($result.ExitCode)). $detail"
    }

    Write-InstallerMessage "MailSite configuration defaults were created."
}

function Install-MailSiteWindowsService {
    param(
        [hashtable]$Service,
        [string]$ExecutablePath,
        [hashtable]$ServiceAccount
    )

    $arguments = @("install")
    if ($null -ne $ServiceAccount) {
        $arguments += @("--username", $ServiceAccount.UserName, "--password", $ServiceAccount.Password)
    }

    Write-InstallerMessage "Installing the $($Service.Name) Windows service..."
    $result = Invoke-MailSiteExecutable -FilePath $ExecutablePath -ArgumentList $arguments
    if ($result.ExitCode -ne 0) {
        $detail = (@($result.Output) -join [Environment]::NewLine).Trim()
        throw "Could not install the $($Service.Name) Windows service ($ExecutablePath install exited with code $($result.ExitCode)). $detail"
    }
}

function Remove-MailSiteWindowsService {
    param([string]$ServiceName)

    if (-not (Test-MailSiteServiceInstalled -ServiceName $ServiceName)) {
        return
    }

    Write-InstallerMessage "Removing newly created $ServiceName Windows service..."
    & sc.exe delete $ServiceName | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-InstallerMessage "Could not delete the newly created $ServiceName service. sc.exe exited with code $LASTEXITCODE." -Level "WARN"
    }
}

function Set-FreshInstallDirectoryAcl {
    param(
        [string]$Directory,
        [hashtable]$ServiceAccount
    )

    # Mirror the legacy installer's PermissionInstallDir step: grant SYSTEM (and the
    # custom service account, when one is used) full control over the install tree.
    # S-1-5-18 is the well-known SYSTEM SID, so this works on localized systems.
    $arguments = @($Directory, "/grant", "*S-1-5-18:(OI)(CI)F")
    $grantSummary = "SYSTEM"
    if ($null -ne $ServiceAccount) {
        $arguments += @("/grant", "$($ServiceAccount.UserName):(OI)(CI)F")
        $grantSummary += " and $($ServiceAccount.UserName)"
    }
    $arguments += @("/T", "/C", "/Q")

    Write-InstallerMessage "Granting full control on $Directory to $grantSummary..."
    $result = Invoke-MailSiteExecutable -FilePath "icacls.exe" -ArgumentList $arguments
    if ($result.ExitCode -ne 0) {
        $detail = (@($result.Output) -join [Environment]::NewLine).Trim()
        Write-InstallerMessage "Could not update permissions on ${Directory}: icacls.exe exited with code $($result.ExitCode). $detail" -Level "WARN"
    }
}

function Install-MailSiteFresh {
    Write-InstallerMessage "No existing MailSite installation was detected. Preparing a fresh MailSite $TargetMajorVersion install."

    $installRequest = Resolve-InstallRequest
    $requestedVersion = Resolve-RequestedPackageVersion -InstallRequest $installRequest

    Write-Host ""
    Write-Host "MailSite 11 Fresh Install"
    Write-Host "========================="
    Write-Host "No existing MailSite installation was detected on this machine."
    Write-Host (Format-InstallerConsoleMessage -Message "This script will perform a fresh install of MailSite $requestedVersion.")
    Write-Host "Install directory: $InstallDir"
    Write-Host ""
    if (-not (Read-YesNo -Prompt "Install MailSite ${requestedVersion}?" -DefaultYes $true)) {
        Write-InstallerMessage "Installation cancelled by user."
        return
    }

    # Gather all interactive input before the long-running download/extract steps.
    # The purchased license key text is collected here and validated after
    # extraction, once the packaged httpma.exe is available to decode it. Trial
    # requests are fulfilled online at that point too, so setup receives a real
    # MailSite license key instead of the old local DEMO placeholder.
    Write-Host ""
    Write-Host "MailSite setup needs a few details before installing."
    $licenseKey = Read-FreshInstallLicenseKeyText
    $domainName = Read-FreshInstallDomainName
    $postmaster = Read-FreshInstallPostmasterPassword
    $serviceAccount = Read-FreshInstallServiceAccount

    $package = Resolve-PackagePath -DestinationDirectory $InstallDir -RemoteVersion $installRequest.RemoteVersion
    $extractRoot = Join-Path ([IO.Path]::GetTempPath()) ("MailSite11-" + [Guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path $extractRoot -Force | Out-Null

    try {
        Write-InstallerMessage "Extracting $package..."
        Expand-Archive -Path $package -DestinationPath $extractRoot -Force
        $packageRoot = Get-PackageRoot -ExtractRoot $extractRoot
        $targetVersion = Get-PackageVersion -PackageRoot $packageRoot

        $licenseResolution = Resolve-FreshInstallLicenseKey -HttpmaPath (Join-Path $packageRoot "httpma.exe") -InitialKey $licenseKey
        $licenseKey = $licenseResolution.LicenseKey
        $licenseIsTrial = [bool]$licenseResolution.IsTrial
        $licenseSummary = $licenseResolution.Summary

        Install-WebView2Runtime

        Write-InstallerMessage "Installing MailSite $targetVersion to $InstallDir..."
        Copy-Item -Path (Join-Path $packageRoot "*") -Destination $InstallDir -Recurse -Force
        New-MailSiteDesktopShortcuts -RootDirectory $InstallDir

        # Save the marker before configuring services so a failed install can still
        # be cleaned up with uninstall-mailsite.ps1. FreshInstall tells the
        # uninstaller to delete the services instead of reverting to MailSite 10.
        Save-InstallerState -State @{
            InstalledAtUtc = [DateTimeOffset]::UtcNow.ToString("o")
            InstallDir11 = $InstallDir
            TargetVersion = $targetVersion
            FreshInstall = $true
            PreviousImagePath = @{}
            PreviousDescription = @{}
            WasRunning = @{}
        }

        Invoke-MailSiteFreshSetup `
            -HttpmaPath (Join-Path $InstallDir "httpma.exe") `
            -LicenseKey $licenseKey `
            -DomainName $domainName `
            -PostmasterPassword $postmaster.Password `
            -Version $targetVersion `
            -InstallDirectory $InstallDir

        if ($null -ne $serviceAccount) {
            Grant-ServiceLogonRight -AccountName $serviceAccount.UserName
        }

        foreach ($service in $Services) {
            $newExe = Join-Path $InstallDir $service.File
            if (-not (Test-Path -LiteralPath $newExe)) {
                throw "Package did not install $newExe."
            }
            Install-MailSiteWindowsService -Service $service -ExecutablePath $newExe -ServiceAccount $serviceAccount
            Set-ServiceDescription -ServiceName $service.Name -Description $service.Description
            Set-MailSiteFirewallRules -Service $service -ExecutablePath $newExe
        }

        Write-MailSiteServiceAccountMismatchWarning -Audit (Get-MailSiteServiceAccountAudit)

        Set-FreshInstallDirectoryAcl -Directory $InstallDir -ServiceAccount $serviceAccount

        Remove-Item -LiteralPath $package -Force -ErrorAction SilentlyContinue

        $startFailures = @()
        foreach ($service in $Services) {
            if (-not (Start-MailSiteService -ServiceName $service.Name)) {
                $startFailures += $service.Name
            }
        }

        $serviceAccountDisplay = if ($null -eq $serviceAccount) { "LocalSystem" } else { $serviceAccount.UserName }
        Write-Host ""
        Write-InstallerMessage "MailSite $targetVersion fresh install completed."
        Write-InstallerMessage "  Install directory:  $InstallDir"
        Write-InstallerMessage "  Default domain:     $domainName"
        Write-InstallerMessage "  Postmaster mailbox: Postmaster@$domainName"
        Write-InstallerMessage "  Service account:    $serviceAccountDisplay"
        if ($licenseIsTrial) {
            Write-InstallerMessage "  License:            30-day trial. Enter a purchased license key in the MailSite Console before the trial expires."
        } elseif (-not [string]::IsNullOrWhiteSpace($licenseSummary)) {
            Write-InstallerMessage "  License:            $licenseSummary"
        }
        if ($postmaster.Generated) {
            Write-Host ""
            Write-Host "  A password was generated for Postmaster@${domainName}:" -ForegroundColor Yellow
            Write-Host "      $($postmaster.Password)" -ForegroundColor Cyan
            Write-Host "  Record this password now. It is not saved anywhere else and will not be shown again." -ForegroundColor Yellow
            Write-InstallerMessage "An autogenerated Postmaster password was displayed to the operator (not written to this log)."
        }
        if ($startFailures.Count -gt 0) {
            Write-InstallerMessage "These services could not be started and may need attention: $($startFailures -join ', ')." -Level "WARN"
        }
    } finally {
        Remove-Item -Path $extractRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function Install-MailSite {
    Assert-Administrator
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    Initialize-InstallLog -RootDirectory $InstallDir

    $installedState = Get-InstalledMailSite11State -RootDirectory $InstallDir
    $installedVersion = Get-InstalledMailSiteComparisonVersion -InstalledState $installedState
    $installedDisplayVersion = Get-InstalledMailSiteDisplayVersion -InstalledState $installedState

    if (-not $installedState.IsInstalled) {
        if (-not (Test-Path $MailSiteKey32)) {
            # No MailSite 11 in $InstallDir and no MailSite registry key at all:
            # this is a genuinely fresh machine, so run the fresh install flow.
            # A present-but-broken MailSite 10 registry key still goes through
            # Assert-MailSite10 below and surfaces its existing errors.
            Install-MailSiteFresh
            return
        }

        # No existing MailSite 11: this is a first-time MailSite 10 -> 11 migration,
        # so a valid MailSite 10 install is required to migrate from.
        $legacy = Assert-MailSite10
        Write-InstallerMessage "Detected MailSite $($legacy.RegistryVersion) using $($legacy.ConnectorName)."
    } else {
        Write-InstallerMessage "Detected existing MailSite $installedDisplayVersion in $InstallDir."
        if ($installedState.IsMixed) {
            Write-InstallerMessage "Detected mixed MailSite 11 component versions: $(Get-MailSiteComponentVersionSummary -InstalledState $installedState)." -Level "WARN"
        }
        if ($installedState.MissingComponents.Count -gt 0) {
            Write-InstallerMessage "Existing MailSite 11 install does not yet have component(s): $($installedState.MissingComponents -join ', '). The installer will add them with this package."
        }
        if ($installedState.InvalidComponents.Count -gt 0) {
            Write-InstallerMessage "Existing MailSite 11 install has component(s) with invalid versions: $($installedState.InvalidComponents -join ', ')." -Level "WARN"
        }
        # Upgrading an existing MailSite 11 install. MailSite 10 may have been
        # removed; use it for permission copying if it's still present, but don't
        # block the upgrade on it.
        try {
            $legacy = Assert-MailSite10
            Write-InstallerMessage "Detected MailSite $($legacy.RegistryVersion) using $($legacy.ConnectorName)."
        } catch {
            # A license rejection is a definite block, not evidence that
            # MailSite 10 is gone; re-throw it so the upgrade stops with the
            # real message instead of misreporting an absent MailSite 10.
            if (([string]$_.Exception.Message).StartsWith($LicenseRejectedMessagePrefix)) {
                throw
            }
            $legacy = $null
            Write-InstallerMessage "MailSite 10 is no longer present; performing a MailSite 11 binary upgrade. Rollback to MailSite 10 will not be available." -Level "WARN"
        }
    }

    $installRequest = Resolve-InstallRequest

    if ($installRequest.Interactive -and [string]::IsNullOrWhiteSpace($PackagePath) -and -not (Test-SiblingPackageAvailable)) {
        $installRequest = Resolve-InteractiveRemoteInstallRequest -InstalledVersion $installedVersion -InstalledState $installedState -LegacyInfo $legacy
        if ($installRequest.Cancelled) {
            return
        }
        $requestedVersion = $installRequest.RemoteVersion
    } else {
        $requestedVersion = Resolve-RequestedPackageVersion -InstallRequest $installRequest
    }

    if ((Test-ExactMailSiteVersion -Version $requestedVersion) -and (Test-ExactMailSiteVersion -Version $installedVersion)) {
        $requestedComparison = Compare-MailSiteVersions -Left $requestedVersion -Right $installedVersion
        if ($requestedComparison -eq 0 -and -not $installRequest.ForceReinstall -and -not (Test-MailSiteInstallNeedsRepair -InstalledState $installedState)) {
            Write-MailSiteServiceAccountMismatchWarning -Audit (Get-MailSiteServiceAccountAudit)
            Write-InstallerMessage "MailSite $requestedVersion is already installed. No changes were made."
            return
        }
        if ($requestedComparison -lt 0 -and -not $installRequest.AllowDowngrade) {
            Write-MailSiteServiceAccountMismatchWarning -Audit (Get-MailSiteServiceAccountAudit)
            Write-InstallerMessage "MailSite $installedDisplayVersion is already installed, which includes a component newer than MailSite $requestedVersion. No changes were made." -Level "WARN"
            return
        }
        if ($requestedComparison -lt 0) {
            Write-InstallerMessage "Downgrading MailSite only replaces binaries; SQLite database schemas are not rolled back. Verify MailSite $requestedVersion can read any schema changes already applied by MailSite $installedDisplayVersion." -Level "WARN"
        }
    }

    if (-not $installRequest.SkipConfirm -and -not (Confirm-MailSiteInstall -Version $requestedVersion -InstalledVersion $installedVersion -InstalledState $installedState)) {
        Write-InstallerMessage "Installation cancelled by user."
        return
    }

    $package = Resolve-PackagePath -DestinationDirectory $InstallDir -RemoteVersion $installRequest.RemoteVersion
    $extractRoot = Join-Path ([IO.Path]::GetTempPath()) ("MailSite11-" + [Guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path $extractRoot -Force | Out-Null

    $state = $null
    $rollbackImagePath = @{}
    $createdServices = @()
    $servicesStopped = $false

    try {
        Write-InstallerMessage "Extracting $package..."
        Expand-Archive -Path $package -DestinationPath $extractRoot -Force
        $packageRoot = Get-PackageRoot -ExtractRoot $extractRoot
        $targetVersion = Get-PackageVersion -PackageRoot $packageRoot

        if (Test-ExactMailSiteVersion -Version $installedVersion) {
            $targetComparison = Compare-MailSiteVersions -Left $targetVersion -Right $installedVersion
            if ($targetComparison -eq 0 -and -not $installRequest.ForceReinstall -and -not (Test-MailSiteInstallNeedsRepair -InstalledState $installedState)) {
                Write-MailSiteServiceAccountMismatchWarning -Audit (Get-MailSiteServiceAccountAudit)
                Write-InstallerMessage "MailSite $targetVersion is already installed. No changes were made."
                Remove-Item -LiteralPath $package -Force -ErrorAction SilentlyContinue
                return
            }
            if ($targetComparison -lt 0 -and -not $installRequest.AllowDowngrade) {
                throw "Cannot install MailSite $targetVersion because installed MailSite components include $installedVersion. Download a newer MailSite package and retry."
            }
            if ($targetComparison -lt 0) {
                Write-InstallerMessage "Continuing with downgrade from MailSite $installedDisplayVersion to MailSite $targetVersion." -Level "WARN"
            }
        }

        Write-InstallerMessage (Get-MailSiteInstallActionMessage -TargetVersion $targetVersion -InstalledState $installedState -InstallDirectory $InstallDir)

        Install-WebView2Runtime

        $existingState = Get-ExistingInstallerState
        $state = @{
            InstalledAtUtc = [DateTimeOffset]::UtcNow.ToString("o")
            InstallDir11 = $InstallDir
            TargetVersion = $targetVersion
            # Preserve the fresh-install marker across upgrades so uninstall keeps
            # deleting the services instead of reverting to a MailSite 10 that
            # never existed on this machine.
            FreshInstall = ($null -ne $existingState -and [bool]$existingState.FreshInstall)
            PreviousImagePath = Copy-StateMap -State $existingState -PropertyName "PreviousImagePath"
            PreviousDescription = Copy-StateMap -State $existingState -PropertyName "PreviousDescription"
            WasRunning = @{}
        }

        foreach ($service in $Services) {
            if (Test-MailSiteServiceInstalled -ServiceName $service.Name) {
                $currentImagePath = Get-ServiceImagePath -ServiceName $service.Name
                $rollbackImagePath[$service.Name] = $currentImagePath
                if (-not $state.PreviousImagePath.ContainsKey($service.Name)) {
                    $state.PreviousImagePath[$service.Name] = $currentImagePath
                }
                if (-not $state.PreviousDescription.ContainsKey($service.Name)) {
                    $state.PreviousDescription[$service.Name] = Get-ServiceDescription -ServiceName $service.Name
                }
                $state.WasRunning[$service.Name] = Stop-MailSiteService -ServiceName $service.Name
            } else {
                Write-InstallerMessage "$($service.Name) Windows service is not installed; it will be created."
                $rollbackImagePath[$service.Name] = $null
                $state.WasRunning[$service.Name] = $false
            }
        }
        $servicesStopped = $true

        Stop-MailSiteDesktopApps -RootDirectory $InstallDir

        if ($legacy -and -not [string]::IsNullOrWhiteSpace($legacy.LegacyInstallDir) -and (Test-Path -LiteralPath $legacy.LegacyInstallDir)) {
            Write-InstallerMessage "Copying directory permissions from $($legacy.LegacyInstallDir) to $InstallDir..."
            Copy-DirectoryAccessRules -SourceDirectory $legacy.LegacyInstallDir -DestinationDirectory $InstallDir
        }

        Remove-InstalledExpressProDist -PackageRoot $packageRoot -DestinationRoot $InstallDir
        Copy-Item -Path (Join-Path $packageRoot "*") -Destination $InstallDir -Recurse -Force
        New-MailSiteDesktopShortcuts -RootDirectory $InstallDir

        Save-InstallerState -State $state

        foreach ($service in $Services) {
            $newExe = Join-Path $InstallDir $service.File
            if (-not (Test-Path -LiteralPath $newExe)) {
                throw "Package did not install $newExe."
            }
            if (Test-MailSiteServiceInstalled -ServiceName $service.Name) {
                Set-ServiceImagePath -ServiceName $service.Name -ExecutablePath $newExe
            } else {
                Install-MailSiteWindowsService -Service $service -ExecutablePath $newExe -ServiceAccount $null
                $createdServices += $service.Name
            }
            Set-ServiceDescription -ServiceName $service.Name -Description $service.Description
            Set-MailSiteFirewallRules -Service $service -ExecutablePath $newExe
        }

        Write-MailSiteServiceAccountMismatchWarning -Audit (Get-MailSiteServiceAccountAudit)

        Remove-Item -LiteralPath $package -Force -ErrorAction SilentlyContinue

        $startNewServices = (@($state.WasRunning.Values | Where-Object { $_ -eq $true }).Count -gt 0)
        $restartRequested = @()
        $restartFailures = @()
        foreach ($service in $Services) {
            if ($state.WasRunning[$service.Name] -or ($startNewServices -and ($createdServices -contains $service.Name))) {
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
                } elseif ($createdServices -contains $service.Name) {
                    Remove-MailSiteWindowsService -ServiceName $service.Name
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
