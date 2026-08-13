[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$InstallTarget,
    [string]$InstallDir = (Join-Path $env:ProgramFiles "MailSite"),
    [string]$PackagePath,
    [string]$PackageUrl = "https://github.com/rockliffe/mailsite-server-release/releases/latest/download/MailSite.zip",
    [string]$LicenseApiBaseUrl,
    [switch]$GrantServiceControl,
    [switch]$SkipServiceControlGrant
)

$ErrorActionPreference = "Stop"

# Windows PowerShell 5.1 may default to TLS 1.0/1.1, which the license service
# and download hosts reject. OR TLS 1.2 into the current protocol set (never
# replace it) before the first web request.
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

$Services = @(
    @{ Name = "MSDBMA"; File = "msdbma.exe"; Description = "MailSite Message Store and Database Management Agent"; LegacyService = $false },
    @{ Name = "HTTPMA"; File = "httpma.exe"; Description = "MailSite HTTP Management Agent" },
    @{ Name = "EWSMA"; File = "ewsma.exe"; Description = "MailSite EWS Management Agent"; LegacyService = $false },
    @{ Name = "MAPIMA"; File = "mapima.exe"; Description = "MailSite MAPI Management Agent"; LegacyService = $false },
    @{ Name = "EASMA"; File = "easma.exe"; Description = "MailSite Exchange ActiveSync Management Agent"; LegacyService = $false },
    @{ Name = "IMAP4A"; File = "imap4a.exe"; Description = "MailSite IMAP4 Server" },
    @{ Name = "POP3A"; File = "pop3a.exe"; Description = "MailSite POP3 Agent"; VersionDetectionRequired = $false },
    @{ Name = "SMTPRA"; File = "smtpra.exe"; Description = "MailSite SMTP Receiving Agent" },
    @{ Name = "SMTPDA"; File = "smtpda.exe"; Description = "MailSite SMTP Delivery Agent" }
)
$MSDBMAClientServiceNames = @("HTTPMA", "EWSMA", "MAPIMA", "EASMA", "IMAP4A", "POP3A", "SMTPRA", "SMTPDA")
$MSDBMAMasterKeyEnvironmentName = "MSDBMA_AUTH_MASTER_KEY"
$MSDBMAServiceTokenEnvironmentName = "MSDBMA_SERVICE_TOKEN"
$MSDBMACredentialContext = "mailsite-msdbma-client-v1:"

$DesktopApps = @(
    @{ Name = "ExpressPro"; File = "expresspro.exe"; ShortcutName = "ExpressPro" },
    @{ Name = "Console"; File = "console.exe"; ShortcutName = "MailSite Console" }
)

# SMTPRA is a 64-bit service, but legacy SMTP hook DLLs are Win32. This helper
# is therefore a versioned package/install component even though it is not a
# Windows service of its own.
$SmtpHookHost32 = @{ Name = "SMTPHookHost32"; File = "smtp-hook-host32.exe" }
$SmtpHookHost32Machine = [uint16]0x014c

$MailSiteKey32 = "HKLM:\SOFTWARE\Wow6432Node\Rockliffe\MailSite"
$InstallDataDirectoryName = "Install"
$InstallMarkerName = "install.json"
$InstallerStateVersion = 3
$SupportedPreviousInstallerStateVersions = @(2)
$FreshInstallStatusInProgress = "InProgress"
$FreshInstallStatusComplete = "Complete"
$RequiredLegacyMajorVersion = "10"
$TargetMajorVersion = "11"
$MSDBMAIntroducedVersion = "11.0.194"
# DEV PHASE: points at mailsite.dev while v11 licensing is being tested.
# Switch to https://www.mailsite.com (here and in Library's
# DEFAULT_LICENSE_API_BASE_URL) before the first production release.
$DefaultLicenseApiBaseUrl = "https://mailsite.dev"
$FreshTrialLicenseRequest = "__MAILSITE_ONLINE_TRIAL__"
$LicenseValidationCacheName = "license.json"
# Marks authoritative license failures from Assert-MailSite10 so upgrade paths
# can tell them apart from "MailSite 10 is not present" failures.
$LicenseRejectedMessagePrefix = "The existing MailSite license was rejected by the license service:"
$LicenseUnavailableMessagePrefix = "The existing MailSite license could not be validated by the license service:"
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

    $installDataDirectory = Join-Path $RootDirectory $InstallDataDirectoryName
    New-Item -ItemType Directory -Path $installDataDirectory -Force | Out-Null
    $script:LogPath = Join-Path $installDataDirectory "install.log"
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
        # A log-write failure must never abort an install (a mid-upgrade abort
        # also skips rollback, leaving services stopped). Add-Content -Encoding
        # can fail with "Stream was not readable" when another process holds
        # install.log with an incompatible share mode, so append via .NET with
        # permissive sharing and degrade to console-only logging on any error.
        try {
            $stream = [System.IO.FileStream]::new(
                $script:LogPath,
                [System.IO.FileMode]::Append,
                [System.IO.FileAccess]::Write,
                [System.IO.FileShare]::ReadWrite)
            try {
                $writer = [System.IO.StreamWriter]::new($stream, [System.Text.UTF8Encoding]::new($false))
                $writer.WriteLine($line)
                $writer.Flush()
                $writer.Dispose()
            } finally {
                $stream.Dispose()
            }
        } catch {
            $failedLogPath = $script:LogPath
            $script:LogPath = $null
            Write-Host "Could not write to install log $failedLogPath ($($_.Exception.Message)); continuing with console output only." -ForegroundColor Yellow
        }
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

function Get-ServiceExecutablePathFromImagePath {
    param([string]$ImagePath)

    $value = ([string]$ImagePath).Trim()
    if ($value -match '^"([^"]+)"') {
        return $matches[1]
    }
    if ($value -match '^(.+?\.exe)(?:\s|$)') {
        return $matches[1]
    }
    return $value
}

function Get-NormalizedMailSitePath {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return ""
    }
    $fullPath = [IO.Path]::GetFullPath($Path.Trim())
    return $fullPath.TrimEnd([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar).ToLowerInvariant()
}

function Test-MailSitePathEqual {
    param(
        [string]$Left,
        [string]$Right
    )

    return (Get-NormalizedMailSitePath -Path $Left) -ceq (Get-NormalizedMailSitePath -Path $Right)
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

function Assert-MailSiteServiceControlGrantOptions {
    if ($GrantServiceControl -and $SkipServiceControlGrant) {
        throw "-GrantServiceControl and -SkipServiceControlGrant cannot be used together."
    }
}

function Get-MailSiteServiceControlRepairCommand {
    param([string]$HttpmaPath)

    # Single-quote the path so a copy/pasted command cannot expand `$`,
    # backticks, or subexpressions in a caller-selected install directory.
    $quotedPath = $HttpmaPath.Replace("'", "''")
    return "& '$quotedPath' grant-service-control"
}

function Write-MailSiteServiceControlRepairWarning {
    param(
        [string]$HttpmaPath,
        [string]$Reason
    )

    $command = Get-MailSiteServiceControlRepairCommand -HttpmaPath $HttpmaPath
    Write-InstallerMessage "$Reason Run $command from an elevated PowerShell prompt to repair the permissions." -Level "WARN"
}

function Invoke-MailSiteServiceControlPermissionRepair {
    param([string]$HttpmaPath)

    # This audit is deliberately non-fatal. Permission inspection or repair
    # must never roll back an otherwise successful binary/service update.
    try {
        $checkResult = Invoke-MailSiteExecutable `
            -FilePath $HttpmaPath `
            -ArgumentList @("grant-service-control", "--check", "--json")
        if ($checkResult.ExitCode -ne 0) {
            $detail = (@($checkResult.Output) -join [Environment]::NewLine).Trim()
            $reason = "Could not audit MailSite service-control permissions."
            if (-not [string]::IsNullOrWhiteSpace($detail)) {
                $reason += " $detail"
            }
            Write-MailSiteServiceControlRepairWarning -HttpmaPath $HttpmaPath -Reason $reason
            return
        }

        $json = (@($checkResult.Output) -join [Environment]::NewLine).Trim()
        $audit = $json | ConvertFrom-Json -ErrorAction Stop
        $properties = @($audit.PSObject.Properties.Name)
        $requiredProperties = @("schemaVersion", "account", "complete", "grantRequired", "services", "registryKeys")
        foreach ($property in $requiredProperties) {
            if ($properties -notcontains $property) {
                throw "Permission audit JSON is missing '$property'."
            }
        }
        if ([int]$audit.schemaVersion -ne 1) {
            throw "Unsupported permission audit schema version '$($audit.schemaVersion)'."
        }
        if ($audit.complete -isnot [bool] -or $audit.grantRequired -isnot [bool]) {
            throw "Permission audit JSON has invalid completion fields."
        }
        if (-not [bool]$audit.complete) {
            Write-MailSiteServiceControlRepairWarning `
                -HttpmaPath $HttpmaPath `
                -Reason "The MailSite service-control permission audit was incomplete."
            return
        }
        if (-not [bool]$audit.grantRequired) {
            Write-InstallerMessage "MailSite service-control and configuration permissions are already sufficient for $($audit.account)."
            return
        }

        $missingServices = @(
            $audit.services |
                Where-Object { $_.status -eq "needs_grant" } |
                ForEach-Object { [string]$_.name }
        )
        $missingRegistryKeys = @(
            $audit.registryKeys |
                Where-Object { $_.status -eq "needs_grant" } |
                ForEach-Object { [string]$_.path }
        )
        $missingSummary = @()
        if ($missingServices.Count -gt 0) {
            $missingSummary += "services: $($missingServices -join ', ')"
        }
        if ($missingRegistryKeys.Count -gt 0) {
            $missingSummary += "$($missingRegistryKeys.Count) configuration registry key(s)"
        }
        $detail = if ($missingSummary.Count -gt 0) { " ($($missingSummary -join '; '))" } else { "" }

        if ($SkipServiceControlGrant) {
            Write-MailSiteServiceControlRepairWarning `
                -HttpmaPath $HttpmaPath `
                -Reason "Required permissions for $($audit.account)$detail were not changed because -SkipServiceControlGrant was specified."
            return
        }

        Write-InstallerMessage "HTTPMA runs as $($audit.account), but that account is missing required MailSite permissions$detail. Granting them now. This does not change any service Log On As setting."
        $grantResult = Invoke-MailSiteExecutable `
            -FilePath $HttpmaPath `
            -ArgumentList @("grant-service-control")
        if ($grantResult.ExitCode -ne 0) {
            $grantDetail = (@($grantResult.Output) -join [Environment]::NewLine).Trim()
            $reason = "Could not grant all required permissions to $($audit.account)."
            if (-not [string]::IsNullOrWhiteSpace($grantDetail)) {
                $reason += " $grantDetail"
            }
            Write-MailSiteServiceControlRepairWarning -HttpmaPath $HttpmaPath -Reason $reason
            return
        }
        Write-InstallerMessage "MailSite service-control and configuration permissions were granted to $($audit.account)."
    } catch {
        Write-MailSiteServiceControlRepairWarning `
            -HttpmaPath $HttpmaPath `
            -Reason "Could not audit or repair MailSite service-control permissions: $($_.Exception.Message)"
    }
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

function ConvertTo-Base64Url {
    param([Parameter(Mandatory = $true)][byte[]]$Bytes)

    return [Convert]::ToBase64String($Bytes).TrimEnd("=").Replace("+", "-").Replace("/", "_")
}

function ConvertFrom-Base64Url {
    param([Parameter(Mandatory = $true)][string]$Value)

    $base64 = $Value.Trim().Replace("-", "+").Replace("_", "/")
    switch ($base64.Length % 4) {
        0 { }
        2 { $base64 += "==" }
        3 { $base64 += "=" }
        default { throw "MSDBMA authentication master key is not valid base64url." }
    }
    try {
        return [Convert]::FromBase64String($base64)
    } catch {
        throw "MSDBMA authentication master key is not valid base64url."
    }
}

function New-MSDBMAAuthMasterKey {
    $bytes = New-Object byte[] 32
    $generator = [Security.Cryptography.RandomNumberGenerator]::Create()
    try {
        $generator.GetBytes($bytes)
    } finally {
        $generator.Dispose()
    }
    return ConvertTo-Base64Url -Bytes $bytes
}

function Get-MSDBMAServiceToken {
    param(
        [Parameter(Mandatory = $true)][string]$MasterKey,
        [Parameter(Mandatory = $true)][string]$ServiceName
    )

    if ($MSDBMAClientServiceNames -notcontains $ServiceName.ToUpperInvariant()) {
        throw "$ServiceName is not an approved MSDBMA client."
    }
    $key = @(ConvertFrom-Base64Url -Value $MasterKey)
    if ($key.Count -ne 32) {
        throw "MSDBMA authentication master key must encode exactly 32 bytes."
    }
    $message = [Text.Encoding]::UTF8.GetBytes($MSDBMACredentialContext + $ServiceName.ToUpperInvariant())
    $hmac = New-Object Security.Cryptography.HMACSHA256 -ArgumentList (,[byte[]]$key)
    try {
        return ConvertTo-Base64Url -Bytes $hmac.ComputeHash($message)
    } finally {
        $hmac.Dispose()
    }
}

function Get-MailSiteServiceEnvironmentEntries {
    param([Parameter(Mandatory = $true)][string]$ServiceName)

    $path = "HKLM:\SYSTEM\CurrentControlSet\Services\$ServiceName"
    if (-not (Test-Path -LiteralPath $path)) { return @() }
    $property = Get-ItemProperty -LiteralPath $path -Name Environment -ErrorAction SilentlyContinue
    if ($null -eq $property -or $null -eq $property.Environment) { return @() }
    return @($property.Environment | ForEach-Object { [string]$_ })
}

function Set-MailSiteServiceEnvironmentEntries {
    param(
        [Parameter(Mandatory = $true)][string]$ServiceName,
        [string[]]$Entries
    )

    $path = "HKLM:\SYSTEM\CurrentControlSet\Services\$ServiceName"
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Windows service '$ServiceName' is not installed."
    }
    if (@($Entries).Count -eq 0) {
        Remove-ItemProperty -LiteralPath $path -Name Environment -ErrorAction SilentlyContinue
        return
    }
    New-ItemProperty -LiteralPath $path -Name Environment -PropertyType MultiString -Value ([string[]]$Entries) -Force | Out-Null
}

function Get-MailSiteServiceEnvironmentVariable {
    param(
        [Parameter(Mandatory = $true)][string]$ServiceName,
        [Parameter(Mandatory = $true)][string]$Name
    )

    $prefix = "$Name="
    foreach ($entry in @(Get-MailSiteServiceEnvironmentEntries -ServiceName $ServiceName)) {
        if ($entry.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) {
            return $entry.Substring($prefix.Length)
        }
    }
    return $null
}

function Set-MailSiteServiceEnvironmentVariable {
    param(
        [Parameter(Mandatory = $true)][string]$ServiceName,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Value
    )

    $current = Get-MailSiteServiceEnvironmentVariable -ServiceName $ServiceName -Name $Name
    if ($null -ne $current -and $current -ceq $Value) { return $false }
    $prefix = "$Name="
    $entries = @(
        Get-MailSiteServiceEnvironmentEntries -ServiceName $ServiceName |
            Where-Object { -not $_.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase) }
    )
    $entries += "$Name=$Value"
    Set-MailSiteServiceEnvironmentEntries -ServiceName $ServiceName -Entries $entries
    return $true
}

function Remove-MailSiteServiceEnvironmentVariable {
    param(
        [Parameter(Mandatory = $true)][string]$ServiceName,
        [Parameter(Mandatory = $true)][string]$Name
    )

    $prefix = "$Name="
    $before = @(Get-MailSiteServiceEnvironmentEntries -ServiceName $ServiceName)
    $after = @($before | Where-Object { -not $_.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase) })
    if ($before.Count -eq $after.Count) { return $false }
    Set-MailSiteServiceEnvironmentEntries -ServiceName $ServiceName -Entries $after
    return $true
}

function Protect-MailSiteServiceEnvironmentRegistryKey {
    param([Parameter(Mandatory = $true)][string]$ServiceName)

    # SCM injects this value as LocalSystem. The default service-registry ACL
    # grants BUILTIN\Users read access, which is unsuitable for bearer
    # credentials even though Services.msc does not display the value.
    # Use RegistryKey directly. Get-Acl intermittently reports newly updated
    # SCM service keys as absent through the PowerShell registry provider.
    $subkey = "SYSTEM\CurrentControlSet\Services\$ServiceName"
    $rights = [Security.AccessControl.RegistryRights]::ReadPermissions -bor
        [Security.AccessControl.RegistryRights]::ChangePermissions
    $key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey(
        $subkey,
        [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree,
        $rights
    )
    if ($null -eq $key) {
        throw "Windows service registry key '$subkey' does not exist."
    }
    try {
        $acl = $key.GetAccessControl([Security.AccessControl.AccessControlSections]::Access)
        $acl.SetAccessRuleProtection($true, $false)
        foreach ($rule in @($acl.GetAccessRules($true, $true, [Security.Principal.NTAccount]))) {
            [void]$acl.RemoveAccessRuleSpecific($rule)
        }
        foreach ($identity in @("NT AUTHORITY\SYSTEM", "BUILTIN\Administrators")) {
            $rule = [Security.AccessControl.RegistryAccessRule]::new(
                $identity,
                [Security.AccessControl.RegistryRights]::FullControl,
                [Security.AccessControl.InheritanceFlags]::ContainerInherit,
                [Security.AccessControl.PropagationFlags]::None,
                [Security.AccessControl.AccessControlType]::Allow
            )
            $acl.AddAccessRule($rule)
        }
        $key.SetAccessControl($acl)
    }
    finally {
        $key.Dispose()
    }
}

function Get-MailSiteServiceRegistryAccessSddl {
    param([Parameter(Mandatory = $true)][string]$ServiceName)

    $subkey = "SYSTEM\CurrentControlSet\Services\$ServiceName"
    $key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey(
        $subkey,
        [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadSubTree,
        [Security.AccessControl.RegistryRights]::ReadPermissions
    )
    if ($null -eq $key) {
        throw "Windows service registry key '$subkey' does not exist."
    }
    try {
        $acl = $key.GetAccessControl([Security.AccessControl.AccessControlSections]::Access)
        return $acl.GetSecurityDescriptorSddlForm([Security.AccessControl.AccessControlSections]::Access)
    }
    finally {
        $key.Dispose()
    }
}

function Set-MailSiteServiceRegistryAccessSddl {
    param(
        [Parameter(Mandatory = $true)][string]$ServiceName,
        [Parameter(Mandatory = $true)][string]$Sddl
    )

    $subkey = "SYSTEM\CurrentControlSet\Services\$ServiceName"
    $key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey(
        $subkey,
        [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree,
        [Security.AccessControl.RegistryRights]::ChangePermissions
    )
    if ($null -eq $key) {
        throw "Windows service registry key '$subkey' does not exist."
    }
    try {
        $acl = New-Object Security.AccessControl.RegistrySecurity
        $acl.SetSecurityDescriptorSddlForm(
            $Sddl,
            [Security.AccessControl.AccessControlSections]::Access
        )
        $key.SetAccessControl($acl)
    }
    finally {
        $key.Dispose()
    }
}

function Test-MSDBMAServiceCredentialsConfigured {
    if (-not (Test-MailSiteServiceInstalled -ServiceName "MSDBMA")) { return $false }
    $masterKey = Get-MailSiteServiceEnvironmentVariable -ServiceName "MSDBMA" -Name $MSDBMAMasterKeyEnvironmentName
    if ([string]::IsNullOrWhiteSpace($masterKey)) { return $false }
    try {
        foreach ($serviceName in $MSDBMAClientServiceNames) {
            if (-not (Test-MailSiteServiceInstalled -ServiceName $serviceName)) { continue }
            $expected = Get-MSDBMAServiceToken -MasterKey $masterKey -ServiceName $serviceName
            $actual = Get-MailSiteServiceEnvironmentVariable -ServiceName $serviceName -Name $MSDBMAServiceTokenEnvironmentName
            if ($actual -cne $expected) { return $false }
        }
        return $true
    } catch {
        return $false
    }
}

function Set-MSDBMAServiceCredentials {
    if (-not (Test-MailSiteServiceInstalled -ServiceName "MSDBMA")) {
        throw "MSDBMA must be installed before its service credentials can be provisioned."
    }
    $masterKey = Get-MailSiteServiceEnvironmentVariable -ServiceName "MSDBMA" -Name $MSDBMAMasterKeyEnvironmentName
    $created = [string]::IsNullOrWhiteSpace($masterKey)
    $rotated = $false
    if (-not $created) {
        try {
            foreach ($serviceName in $MSDBMAClientServiceNames) {
                [void](Get-MSDBMAServiceToken -MasterKey $masterKey -ServiceName $serviceName)
            }
        } catch {
            $rotated = $true
        }
    }
    if ($created -or $rotated) {
        $masterKey = New-MSDBMAAuthMasterKey
    }
    foreach ($serviceName in $MSDBMAClientServiceNames) {
        [void](Get-MSDBMAServiceToken -MasterKey $masterKey -ServiceName $serviceName)
    }

    $changed = Set-MailSiteServiceEnvironmentVariable -ServiceName "MSDBMA" -Name $MSDBMAMasterKeyEnvironmentName -Value $masterKey
    if (Remove-MailSiteServiceEnvironmentVariable -ServiceName "MSDBMA" -Name $MSDBMAServiceTokenEnvironmentName) {
        $changed = $true
    }
    foreach ($serviceName in $MSDBMAClientServiceNames) {
        if (-not (Test-MailSiteServiceInstalled -ServiceName $serviceName)) { continue }
        $token = Get-MSDBMAServiceToken -MasterKey $masterKey -ServiceName $serviceName
        if (Set-MailSiteServiceEnvironmentVariable -ServiceName $serviceName -Name $MSDBMAServiceTokenEnvironmentName -Value $token) {
            $changed = $true
        }
        if (Remove-MailSiteServiceEnvironmentVariable -ServiceName $serviceName -Name $MSDBMAMasterKeyEnvironmentName) {
            $changed = $true
        }
    }
    foreach ($serviceName in @("MSDBMA") + $MSDBMAClientServiceNames) {
        if (Test-MailSiteServiceInstalled -ServiceName $serviceName) {
            Protect-MailSiteServiceEnvironmentRegistryKey -ServiceName $serviceName
        }
    }
    return [pscustomobject]@{
        Changed = [bool]$changed
        Created = [bool]$created
        Rotated = [bool]$rotated
    }
}

function Remove-MSDBMAClientCredentials {
    $changed = $false
    foreach ($serviceName in $MSDBMAClientServiceNames) {
        if (-not (Test-MailSiteServiceInstalled -ServiceName $serviceName)) { continue }
        if (Remove-MailSiteServiceEnvironmentVariable -ServiceName $serviceName -Name $MSDBMAServiceTokenEnvironmentName) {
            $changed = $true
        }
        if (Remove-MailSiteServiceEnvironmentVariable -ServiceName $serviceName -Name $MSDBMAMasterKeyEnvironmentName) {
            $changed = $true
        }
    }
    return $changed
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

function Test-ShouldImportLegacyDirectoryAccessRules {
    param(
        [hashtable]$InstalledState,
        [hashtable]$LegacyInfo
    )

    # Importing an inheritable DACL can cause Windows to touch every object
    # below the destination. That is required only when creating the v11 tree
    # from MailSite 10. A v11-to-v11 replacement already has its v11 ACL
    # and may contain very large mailbox stores, so never re-propagate it.
    return (
        $null -ne $InstalledState -and
        -not $InstalledState.HasV11Artifacts -and
        $null -ne $LegacyInfo -and
        -not [string]::IsNullOrWhiteSpace([string]$LegacyInfo.LegacyInstallDir) -and
        (Test-Path -LiteralPath $LegacyInfo.LegacyInstallDir -PathType Container)
    )
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

function Get-PortableExecutableMachine {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Missing required executable: $Path"
    }

    $stream = [IO.File]::Open($Path, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::Read)
    try {
        if ($stream.Length -lt 64) {
            throw "Executable $Path is too small to contain a valid PE header."
        }

        $reader = [IO.BinaryReader]::new($stream)
        try {
            if ($reader.ReadUInt16() -ne 0x5a4d) {
                throw "Executable $Path does not have an MZ header."
            }

            $stream.Position = 0x3c
            $peOffset = $reader.ReadUInt32()
            if (([uint64]$peOffset + 6) -gt [uint64]$stream.Length) {
                throw "Executable $Path has an invalid PE header offset."
            }

            $stream.Position = $peOffset
            if ($reader.ReadUInt32() -ne 0x00004550) {
                throw "Executable $Path does not have a valid PE signature."
            }

            return $reader.ReadUInt16()
        } finally {
            $reader.Dispose()
        }
    } finally {
        $stream.Dispose()
    }
}

function Assert-SmtpHookHost32Architecture {
    param([string]$Path)

    $machine = Get-PortableExecutableMachine -Path $Path
    if ($machine -ne $SmtpHookHost32Machine) {
        $actual = "0x{0:X4}" -f $machine
        throw "SMTP hook compatibility host $Path must be Win32 IMAGE_FILE_MACHINE_I386 (0x014C); found PE Machine $actual."
    }
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
    # Packages are published as GitHub Release assets (the zips exceed the
    # 100 MB limit for committed files). The raw/<branch> form is still
    # accepted for repos that keep small packages committed.
    if ($PackageUrl -match '^https://github\.com/([^/]+)/([^/]+)/releases/(?:latest/download|download/[^/]+)/[^/]+\.zip$') {
        return @{
            Owner = $Matches[1]
            Repo = $Matches[2]
            UseReleases = $true
        }
    }

    if ($PackageUrl -match '^https://github\.com/([^/]+)/([^/]+)/raw/([^/]+)/[^/]+\.zip$') {
        return @{
            Owner = $Matches[1]
            Repo = $Matches[2]
            Branch = $Matches[3]
            UseReleases = $false
            RawBaseUrl = "https://github.com/$($Matches[1])/$($Matches[2])/raw/$($Matches[3])"
        }
    }

    return $null
}

function Get-RemotePackageVersions {
    $repoInfo = Get-ReleaseRepositoryInfo
    if ($null -eq $repoInfo) {
        return @()
    }

    $owner = $repoInfo.Owner
    $repo = $repoInfo.Repo

    try {
        $versions = @()
        if ($repoInfo.UseReleases) {
            $releasesUrl = "https://api.github.com/repos/$owner/$repo/releases?per_page=100"
            $releases = Invoke-RestMethod -Uri $releasesUrl -UseBasicParsing
            foreach ($release in $releases) {
                if ($release.draft -or $release.prerelease) {
                    continue
                }
                if ($release.tag_name -match '^v(11\.[0-9]+\.[0-9]+)$') {
                    $versions += [version]$Matches[1]
                }
            }
        } else {
            $branch = $repoInfo.Branch
            $contentsUrl = "https://api.github.com/repos/$owner/$repo/contents?ref=$branch"
            $items = Invoke-RestMethod -Uri $contentsUrl -UseBasicParsing
            foreach ($item in $items) {
                if ($item.name -match '^MailSite\.(11\.[0-9]+\.[0-9]+)\.zip$') {
                    $versions += [version]$Matches[1]
                }
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

    if ($repoInfo.UseReleases) {
        return "https://github.com/$($repoInfo.Owner)/$($repoInfo.Repo)/releases/download/v$Version/MailSite.zip"
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

function Get-LicenseValidationCachePath {
    param([string]$RootDirectory)

    return Join-Path (Join-Path $RootDirectory $InstallDataDirectoryName) $LicenseValidationCacheName
}

function Save-MailSiteLicenseValidationCache {
    param(
        [string]$InstallDirectory,
        [object]$ValidationBody
    )

    if ($null -eq $ValidationBody -or [string]::IsNullOrWhiteSpace($ValidationBody.validationToken)) {
        throw "The MailSite license service did not return the required signed validation assertion."
    }

    try {
        # Install is a fixed product-data directory whose ACL is repaired for
        # every configured MailSite service identity during install/reinstall.
        $cacheDirectory = Join-Path $InstallDirectory $InstallDataDirectoryName
        New-Item -ItemType Directory -Path $cacheDirectory -Force | Out-Null
        $cache = [ordered]@{
            CachedAtUtc = [DateTimeOffset]::UtcNow.ToString("o")
            LicenseKey = $ValidationBody.license.licenseKey
            License = $ValidationBody.license
            Decoded = $ValidationBody.decoded
            Validation = $ValidationBody.validation
            ValidationToken = $ValidationBody.validationToken
        }
        $path = Get-LicenseValidationCachePath -RootDirectory $InstallDirectory
        $cache | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $path -Encoding UTF8
        Write-InstallerMessage "Cached signed license validation through $($ValidationBody.validation.graceUntil)."
    } catch {
        throw "Could not write the required signed license validation cache: $($_.Exception.Message)"
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
    #   2xx with a recognizable body        -> definite valid/invalid result
    #   4xx with a recognizable JSON body   -> definite rejection
    #   anything else (5xx, network error, CDN/proxy error pages, HTML 403s,
    #   unparseable bodies)                 -> unavailable (installation blocks)
    # A bare 4xx without our API's JSON shape is NOT a license verdict: an
    # undeployed endpoint behind CloudFront answers 403 with an HTML page.
    $statusCode = 0
    if ($null -ne $response.StatusCode) {
        $statusCode = [int]$response.StatusCode
    }

    $responseStatus = ""
    if ($null -ne $response.Body -and
        $response.Body.PSObject.Properties.Name -contains "status") {
        $responseStatus = [string]$response.Body.status
    }
    if ($statusCode -eq 429 -or
        $responseStatus -in @("rate_limited", "signing_unavailable")) {
        return @{
            Outcome = "unavailable"
            Status = $responseStatus
            Message = Get-MailSiteLicenseApiResponseMessage -Response $response
            Body = $response.Body
        }
    }

    if ($statusCode -ge 200 -and $statusCode -le 299 -and $null -ne $response.Body) {
        if ($response.Body.valid -eq $true -and
            -not [string]::IsNullOrWhiteSpace($response.Body.validationToken)) {
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

    if ($statusCode -ge 400 -and $statusCode -le 499 -and
        $null -ne $response.Body -and
        $response.Body.PSObject.Properties.Name -contains "status") {
        return @{
            Outcome = "invalid"
            Status = [string]$response.Body.status
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

function Assert-MailSiteLicenseValidatedOnline {
    param(
        [string]$LicenseKey,
        [int[]]$AllowedProductMajors,
        [string]$BlankLicenseWarning
    )

    if ([string]::IsNullOrWhiteSpace($LicenseKey)) {
        Write-InstallerMessage $BlankLicenseWarning -Level "WARN"
        return
    }

    Write-InstallerMessage "Checking existing MailSite license with the MailSite license service..."
    $licenseValidation = Test-MailSiteOnlineLicenseValidation `
        -LicenseKey $LicenseKey `
        -AllowedProductMajors $AllowedProductMajors
    if ($licenseValidation.Outcome -eq "valid") {
        Write-InstallerMessage "Existing MailSite license was accepted and signed by the license service."
        Save-MailSiteLicenseValidationCache -InstallDirectory $InstallDir -ValidationBody $licenseValidation.Body
        return
    }
    if ($licenseValidation.Outcome -eq "invalid") {
        throw "$LicenseRejectedMessagePrefix $($licenseValidation.Message)"
    }
    throw "$LicenseUnavailableMessagePrefix $($licenseValidation.Message)"
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
    Assert-MailSiteLicenseValidatedOnline `
        -LicenseKey $legacyLicenseKey `
        -AllowedProductMajors @(10, 11) `
        -BlankLicenseWarning "The existing MailSite installation has no license key on record (legacy demo install). The upgraded server will need a valid MailSite license key."

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
        throw "Could not download MailSite package. curl.exe exited with code $LASTEXITCODE."
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
        throw "$($_.Exception.Message) Please try again later or contact support@mailsite.com."
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
            Interactive = $false
            SkipConfirm = $false
            Cancelled = $false
        }
    }

    if ($target -match '^11\.[0-9]+\.[0-9]+$') {
        return @{
            RemoteVersion = $target
            ForceReinstall = $false
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

    # Supported v11 archives are flat and keep release notes at the root.
    # MSDBMA is optional here because the installer may deliberately downgrade
    # to a complete package from before the storage authority was introduced.
    $required = @(
        "httpma.exe", "ewsma.exe", "mapima.exe", "easma.exe", "imap4a.exe",
        "pop3a.exe", "smtpra.exe", "smtp-hook-host32.exe", "smtpda.exe",
        "expresspro.exe", "console.exe", "release-notes.html"
    )
    $missing = @($required | Where-Object { -not (Test-Path -LiteralPath (Join-Path $ExtractRoot $_) -PathType Leaf) })
    if ($missing.Count -eq 0) {
        return $ExtractRoot
    }

    throw "Package does not use a supported flat MailSite 11 layout. Missing root artifact(s): $($missing -join ', ')."
}

function Get-PackageServices {
    param([string]$PackageRoot)

    return @($Services | Where-Object {
        $_.Name -ne "MSDBMA" -or
        (Test-Path -LiteralPath (Join-Path $PackageRoot $_.File) -PathType Leaf)
    })
}

function Get-PackageVersion {
    param([string]$PackageRoot)

    $versions = @()
    foreach ($component in @(Get-PackageServices -PackageRoot $PackageRoot) + @($SmtpHookHost32)) {
        $exe = Join-Path $PackageRoot $component.File
        if ($component.Name -eq $SmtpHookHost32.Name) {
            Assert-SmtpHookHost32Architecture -Path $exe
        }
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

    $packageVersion = $uniqueVersions[0]
    $msdbmaPath = Join-Path $PackageRoot "msdbma.exe"
    if (-not (Test-Path -LiteralPath $msdbmaPath -PathType Leaf) -and
        (Compare-MailSiteVersions -Left $packageVersion -Right $MSDBMAIntroducedVersion) -ge 0) {
        throw "MailSite $packageVersion requires msdbma.exe, but the package does not contain it. Only historical packages older than $MSDBMAIntroducedVersion may omit MSDBMA."
    }

    return $packageVersion
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
        HasV11Artifacts = $false
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

        $state.HasV11Artifacts = $true
        $state.ComponentVersions[$service.Name] = ConvertTo-MailSiteDisplayVersion -Version $version
    }

    $hookHost = Join-Path $RootDirectory $SmtpHookHost32.File
    if (-not (Test-Path -LiteralPath $hookHost -PathType Leaf)) {
        $state.MissingComponents += $SmtpHookHost32.Name
    } else {
        try {
            Assert-SmtpHookHost32Architecture -Path $hookHost
            $hookHostVersion = Get-ProductVersion -Path $hookHost
            if ([string]::IsNullOrWhiteSpace($hookHostVersion) -or -not $hookHostVersion.StartsWith("$TargetMajorVersion.")) {
                $state.InvalidComponents += "$($SmtpHookHost32.Name) ($hookHostVersion)"
            } else {
                $state.HasV11Artifacts = $true
                $hookHostDisplayVersion = ConvertTo-MailSiteDisplayVersion -Version $hookHostVersion
                $serviceVersions = @($state.ComponentVersions.Values | Sort-Object -Unique)
                if ($serviceVersions.Count -eq 1 -and $hookHostDisplayVersion -ne $serviceVersions[0]) {
                    # Keep the service version as the installation contract.
                    # A mismatched helper is a repairable corrupt component,
                    # not evidence that the installation may adopt its build.
                    $state.InvalidComponents += "$($SmtpHookHost32.Name) ($hookHostDisplayVersion; expected $($serviceVersions[0]))"
                } else {
                    $state.ComponentVersions[$SmtpHookHost32.Name] = $hookHostDisplayVersion
                }
            }
        } catch {
            $state.InvalidComponents += "$($SmtpHookHost32.Name) ($($_.Exception.Message))"
        }
    }

    $requiredComponentsPresent = @(
        $Services | Where-Object {
            (Test-MailSiteVersionDetectionRequired -Service $_) -and
            -not $state.ComponentVersions.ContainsKey($_.Name)
        }
    ).Count -eq 0
    $state.IsInstalled = $state.HasV11Artifacts -and $requiredComponentsPresent
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

    if ($null -eq $InstalledState -or -not $InstalledState.HasV11Artifacts) {
        return $null
    }

    return $InstalledState.NewestVersion
}

function Get-InstalledMailSiteDisplayVersion {
    param([hashtable]$InstalledState)

    if ($null -eq $InstalledState -or -not $InstalledState.HasV11Artifacts) {
        return $null
    }

    return $InstalledState.DisplayVersion
}

function Test-MailSiteInstallNeedsRepair {
    param([hashtable]$InstalledState)

    return (
        $null -ne $InstalledState -and
        $InstalledState.HasV11Artifacts -and
        ($InstalledState.IsPartial -or $InstalledState.IsMixed -or -not (Test-MSDBMAServiceCredentialsConfigured))
    )
}

function Get-MailSiteComponentVersionSummary {
    param([hashtable]$InstalledState)

    if ($null -eq $InstalledState -or -not $InstalledState.HasV11Artifacts) {
        return ""
    }

    $parts = @()
    foreach ($service in $Services) {
        if ($InstalledState.ComponentVersions.ContainsKey($service.Name)) {
            $parts += "$($service.Name) $($InstalledState.ComponentVersions[$service.Name])"
        }
    }
    if ($InstalledState.ComponentVersions.ContainsKey($SmtpHookHost32.Name)) {
        $parts += "$($SmtpHookHost32.Name) $($InstalledState.ComponentVersions[$SmtpHookHost32.Name])"
    }

    return ($parts -join ", ")
}

function Get-InstallMarkerPath {
    param([string]$RootDirectory)

    return Join-Path (Join-Path $RootDirectory $InstallDataDirectoryName) $InstallMarkerName
}

function Save-InstallerState {
    param([object]$State)

    Assert-InstallerStateVersion -State $State
    [void](Get-InstallerStateStatus -State $State)
    $json = $State | ConvertTo-Json -Depth 5
    $markerPath = Get-InstallMarkerPath -RootDirectory $InstallDir
    $markerDirectory = Split-Path -Parent $markerPath
    New-Item -ItemType Directory -Path $markerDirectory -Force | Out-Null
    $transactionId = [Guid]::NewGuid().ToString('N')
    $temporaryPath = "$markerPath.$transactionId.tmp"
    $backupPath = "$markerPath.$transactionId.bak"
    try {
        $utf8WithoutBom = New-Object System.Text.UTF8Encoding($false)
        [IO.File]::WriteAllText($temporaryPath, $json, $utf8WithoutBom)
        if ([IO.File]::Exists($markerPath)) {
            # PowerShell binds $null to an empty string for File.Replace's
            # backup argument, which is not a legal path. Use a unique sibling
            # backup and remove it immediately after the atomic replacement.
            [IO.File]::Replace($temporaryPath, $markerPath, $backupPath)
        } else {
            [IO.File]::Move($temporaryPath, $markerPath)
        }
    } finally {
        Remove-Item -LiteralPath $temporaryPath -Force -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $backupPath -Force -ErrorAction SilentlyContinue
    }
}

function Get-ExistingInstallerState {
    $markerPath = Get-InstallMarkerPath -RootDirectory $InstallDir
    if (-not (Test-Path -LiteralPath $markerPath)) {
        return $null
    }

    $json = Get-Content -LiteralPath $markerPath -Raw
    $state = $json | ConvertFrom-Json
    $state = ConvertTo-CurrentInstallerState -State $state
    return $state
}

function Test-InstallerStateHasProperty {
    param(
        [object]$State,
        [string]$PropertyName
    )

    if ($null -eq $State) {
        return $false
    }
    if ($State -is [System.Collections.IDictionary]) {
        return $State.Contains($PropertyName)
    }
    return $null -ne $State.PSObject.Properties[$PropertyName]
}

function ConvertTo-CurrentInstallerState {
    param([object]$State)

    if ($null -eq $State) {
        return $null
    }

    $stateVersion = Get-InstallerStatePropertyValue -State $State -PropertyName "StateVersion"
    if ($null -ne $stateVersion -and [int]$stateVersion -eq $InstallerStateVersion) {
        Assert-InstallerStateVersion -State $State
        return $State
    }

    if ($null -eq $stateVersion -or -not ($SupportedPreviousInstallerStateVersions -contains [int]$stateVersion)) {
        Assert-InstallerStateVersion -State $State
    }

    $status = [string](Get-InstallerStatePropertyValue -State $State -PropertyName "InstallStatus")
    if ($status -ne $FreshInstallStatusComplete) {
        throw "Installer state version $stateVersion can be upgraded only when InstallStatus is Complete. Use the matching old installer to recover or remove an interrupted installation."
    }

    $stateDirectory = [string](Get-InstallerStatePropertyValue -State $State -PropertyName "InstallDir11")
    if ([string]::IsNullOrWhiteSpace($stateDirectory) -or -not (Test-MailSitePathEqual -Left $stateDirectory -Right $InstallDir)) {
        throw "Installer state version $stateVersion belongs to '$stateDirectory', not '$InstallDir'. Rerun the installer with the original -InstallDir."
    }

    $targetVersion = [string](Get-InstallerStatePropertyValue -State $State -PropertyName "TargetVersion")
    if (-not (Test-ExactMailSiteVersion -Version $targetVersion)) {
        throw "Installer state version $stateVersion has invalid TargetVersion '$targetVersion' and cannot be upgraded safely."
    }

    $requiredProperties = @(
        "FreshInstall", "PreviousImagePath", "PreviousDescription",
        "PreviousServiceRegistryAccessSddl", "WasRunning"
    )
    $missingProperties = @($requiredProperties | Where-Object { -not (Test-InstallerStateHasProperty -State $State -PropertyName $_) })
    if ($missingProperties.Count -gt 0) {
        throw "Installer state version $stateVersion is missing required property/properties: $($missingProperties -join ', '). Use the matching old uninstaller before installing this build."
    }

    Write-InstallerMessage "MailSite $targetVersion uses installer state version $stateVersion. Upgrading the completed installer state to version $InstallerStateVersion so this v11 installation can be upgraded in place." -Level "WARN"
    Set-InstallerStatePropertyValue -State $State -PropertyName "StateVersion" -Value $InstallerStateVersion
    Save-InstallerState -State $State
    return $State
}

function Get-InstallerStatePropertyValue {
    param(
        [object]$State,
        [string]$PropertyName
    )

    if ($null -eq $State) {
        return $null
    }
    if ($State -is [System.Collections.IDictionary]) {
        if ($State.Contains($PropertyName)) {
            return $State[$PropertyName]
        }
        return $null
    }
    $property = $State.PSObject.Properties[$PropertyName]
    if ($null -eq $property) {
        return $null
    }
    return $property.Value
}

function Set-InstallerStatePropertyValue {
    param(
        [object]$State,
        [string]$PropertyName,
        [object]$Value
    )

    if ($State -is [System.Collections.IDictionary]) {
        $State[$PropertyName] = $Value
        return
    }
    $State | Add-Member -NotePropertyName $PropertyName -NotePropertyValue $Value -Force
}

function Assert-InstallerStateVersion {
    param([object]$State)

    if ($null -eq $State) {
        return
    }
    $stateVersion = Get-InstallerStatePropertyValue -State $State -PropertyName "StateVersion"
    if ($null -eq $stateVersion -or [int]$stateVersion -ne $InstallerStateVersion) {
        $reportedVersion = if ($null -eq $stateVersion) { "missing" } else { [string]$stateVersion }
        throw "Installer state uses unsupported StateVersion '$reportedVersion'; this installer requires StateVersion $InstallerStateVersion. MailSite 11 development installer states are not upgraded. Use the matching old uninstaller if needed, then rebuild the v11 installation."
    }
}

function Get-InstallerStateStatus {
    param([object]$State)

    Assert-InstallerStateVersion -State $State
    $status = Get-InstallerStatePropertyValue -State $State -PropertyName "InstallStatus"
    if ([string]::IsNullOrWhiteSpace([string]$status)) {
        throw "Installer state is missing InstallStatus and is not a current MailSite 11 state. Uninstall the matching old v11 build and rebuild the installation."
    }
    if ($status -ne $FreshInstallStatusInProgress -and $status -ne $FreshInstallStatusComplete) {
        throw "Installer state contains unsupported InstallStatus '$status'."
    }
    return [string]$status
}

function Test-InProgressFreshInstall {
    param([object]$State)

    if ($null -eq $State -or -not [bool](Get-InstallerStatePropertyValue -State $State -PropertyName "FreshInstall")) {
        return $false
    }
    return (Get-InstallerStateStatus -State $State) -eq $FreshInstallStatusInProgress
}

function Assert-FreshInstallStateDirectory {
    param([object]$State)

    $stateDirectory = [string](Get-InstallerStatePropertyValue -State $State -PropertyName "InstallDir11")
    if ([string]::IsNullOrWhiteSpace($stateDirectory) -or -not (Test-MailSitePathEqual -Left $stateDirectory -Right $InstallDir)) {
        throw "Interrupted fresh-install state belongs to '$stateDirectory', not '$InstallDir'. Rerun the installer with the original -InstallDir."
    }
}

function New-FreshInstallState {
    param(
        [string]$TargetVersion,
        [string]$DomainName,
        [string]$ServiceAccountName
    )

    return @{
        StateVersion = $InstallerStateVersion
        InstalledAtUtc = [DateTimeOffset]::UtcNow.ToString("o")
        InstallDir11 = $InstallDir
        TargetVersion = $TargetVersion
        FreshInstall = $true
        InstallStatus = $FreshInstallStatusInProgress
        DomainName = $DomainName
        ServiceAccountName = $ServiceAccountName
        ProductRegistryExistedBefore = $false
        PreviousImagePath = @{}
        PreviousDescription = @{}
        PreviousServiceRegistryAccessSddl = @{}
        WasRunning = @{}
    }
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
    param([object[]]$Versions)

    if ($Versions.Count -eq 0) {
        return $null
    }

    Write-Host ""
    Write-InstallerMessage "Other available MailSite versions:"
    for ($index = 0; $index -lt $Versions.Count; $index++) {
        Write-Host ("  {0}. {1}" -f ($index + 1), $Versions[$index])
    }

    while ($true) {
        $answer = Read-Host (Format-InstallerConsoleMessage -Message "Choose a version number, or press Enter to cancel")
        if ([string]::IsNullOrWhiteSpace($answer)) {
            return $null
        }

        $selection = 0
        if ([int]::TryParse($answer.Trim(), [ref]$selection) -and
            $selection -ge 1 -and $selection -le $Versions.Count) {
            return $Versions[$selection - 1].ToString()
        }
        Write-Host "Please enter a number from 1 to $($Versions.Count), or press Enter to cancel." -ForegroundColor Yellow
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
            return "Upgrade MailSite $installedDisplayVersion to MailSite ${TargetVersion}?"
        }
        return "Downgrade MailSite $installedDisplayVersion to MailSite ${TargetVersion}?"
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
    if ((Test-ExactMailSiteVersion -Version $installedComparisonVersion) -and
        (Test-ExactMailSiteVersion -Version $TargetVersion)) {
        $comparison = Compare-MailSiteVersions -Left $TargetVersion -Right $installedComparisonVersion
        if ($comparison -gt 0) {
            return "Upgrading MailSite $installedDisplayVersion to MailSite $TargetVersion in $InstallDirectory..."
        }
        if ($comparison -lt 0) {
            return "Downgrading MailSite $installedDisplayVersion to MailSite $TargetVersion in $InstallDirectory..."
        }
    }

    $needsRepair = Test-MailSiteInstallNeedsRepair -InstalledState $InstalledState
    if ($needsRepair) {
        return "Repairing MailSite $installedDisplayVersion with MailSite $TargetVersion in $InstallDirectory..."
    }

    return "Reinstalling MailSite $TargetVersion in $InstallDirectory..."
}

function New-InteractiveRemoteInstallRequest {
    param(
        [string]$TargetVersion,
        [string]$InstalledVersion,
        [hashtable]$InstalledState,
        [bool]$UpgradeWarningShown = $false,
        [bool]$DowngradeWarningShown = $false
    )

    $installedComparisonVersion = Get-InstalledMailSiteComparisonVersion -InstalledState $InstalledState
    if ([string]::IsNullOrWhiteSpace($installedComparisonVersion)) {
        $installedComparisonVersion = $InstalledVersion
    }

    if ((Test-ExactMailSiteVersion -Version $TargetVersion) -and (Test-ExactMailSiteVersion -Version $installedComparisonVersion)) {
        Assert-MailSite11VersionTransition -InstalledVersion $installedComparisonVersion -TargetVersion $TargetVersion
    }

    return @{
        RemoteVersion = $TargetVersion
        ForceReinstall = -not [string]::IsNullOrWhiteSpace($installedComparisonVersion)
        Interactive = $true
        SkipConfirm = $true
        Cancelled = $false
        UpgradeWarningShown = $UpgradeWarningShown
        DowngradeWarningShown = $DowngradeWarningShown
    }
}

function Get-AlternativeRemotePackageVersions {
    param(
        [object[]]$Versions,
        [string]$InstalledVersion
    )

    $availableVersions = @($Versions | Select-Object -Skip 1 | ForEach-Object { $_.ToString() })
    if (-not (Test-ExactMailSiteVersion -Version $InstalledVersion)) {
        return $availableVersions
    }

    $selectedVersions = @()
    $olderThanInstalledCount = 0
    foreach ($version in $availableVersions) {
        if (-not (Test-ExactMailSiteVersion -Version $version)) {
            continue
        }
        if ((Compare-MailSiteVersions -Left $version -Right $InstalledVersion) -lt 0) {
            $olderThanInstalledCount++
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
        [hashtable]$InstalledState
    )

    $versions = @(Get-RemotePackageVersions)
    if ($versions.Count -eq 0) {
        throw "Could not find MailSite packages in the release repository."
    }

    $installedComparisonVersion = Get-InstalledMailSiteComparisonVersion -InstalledState $InstalledState
    if ([string]::IsNullOrWhiteSpace($installedComparisonVersion)) {
        $installedComparisonVersion = $InstalledVersion
    }
    $targetVersion = $versions[0].ToString()
    $upgradeWarningShown = $false
    $downgradeWarningShown = $false
    Write-InstallerMessage "Latest available MailSite version: $targetVersion."
    if (Test-ExactMailSiteVersion -Version $installedComparisonVersion) {
        Assert-MailSite11VersionTransition -InstalledVersion $installedComparisonVersion -TargetVersion $targetVersion
        $comparison = Compare-MailSiteVersions -Left $targetVersion -Right $installedComparisonVersion
        if ($comparison -gt 0) {
            Write-MailSite11UpgradeWarning -InstalledVersion $installedComparisonVersion -TargetVersion $targetVersion
            $upgradeWarningShown = $true
        } elseif ($comparison -lt 0) {
            Write-MailSite11DowngradeWarning -InstalledVersion $installedComparisonVersion -TargetVersion $targetVersion
            $downgradeWarningShown = $true
        }
    }

    if (Read-YesNo -Prompt (Get-MailSiteInstallPrompt -InstalledVersion $InstalledVersion -InstalledState $InstalledState -TargetVersion $targetVersion) -DefaultYes $true) {
        return New-InteractiveRemoteInstallRequest -TargetVersion $targetVersion -InstalledVersion $InstalledVersion -InstalledState $InstalledState -UpgradeWarningShown $upgradeWarningShown -DowngradeWarningShown $downgradeWarningShown
    }

    $alternativeVersions = @(Get-AlternativeRemotePackageVersions -Versions $versions -InstalledVersion $installedComparisonVersion)
    $selectedVersion = Read-MailSiteVersionChoice -Versions $alternativeVersions
    if (-not [string]::IsNullOrWhiteSpace($selectedVersion)) {
        $upgradeWarningShown = $false
        $downgradeWarningShown = $false
        if (Test-ExactMailSiteVersion -Version $installedComparisonVersion) {
            $comparison = Compare-MailSiteVersions -Left $selectedVersion -Right $installedComparisonVersion
            if ($comparison -gt 0) {
                Write-MailSite11UpgradeWarning -InstalledVersion $installedComparisonVersion -TargetVersion $selectedVersion
                $upgradeWarningShown = $true
            } elseif ($comparison -lt 0) {
                Write-MailSite11DowngradeWarning -InstalledVersion $installedComparisonVersion -TargetVersion $selectedVersion
                $downgradeWarningShown = $true
            }
        }
        if (Read-YesNo -Prompt (Get-MailSiteInstallPrompt -InstalledVersion $InstalledVersion -InstalledState $InstalledState -TargetVersion $selectedVersion) -DefaultYes $false) {
            return New-InteractiveRemoteInstallRequest -TargetVersion $selectedVersion -InstalledVersion $InstalledVersion -InstalledState $InstalledState -UpgradeWarningShown $upgradeWarningShown -DowngradeWarningShown $downgradeWarningShown
        }
    }

    Write-InstallerMessage "Installation cancelled by user."
    return @{
        RemoteVersion = $null
        ForceReinstall = $false
        Interactive = $true
        SkipConfirm = $true
        Cancelled = $true
    }
}

function Test-ExactMailSiteVersion {
    param([string]$Version)

    return $Version -match '^11\.[0-9]+\.[0-9]+$'
}

function Assert-ExistingMailSite11Contract {
    param(
        [object]$InstallerState,
        [hashtable]$InstalledState
    )

    if ($null -eq $InstalledState) {
        return
    }
    if ($null -eq $InstallerState) {
        if (-not $InstalledState.HasV11Artifacts) {
            return
        }
        throw "MailSite 11 files exist in '$InstallDir', but no current installer state owns them. Earlier v11 builds are not adopted. Use their matching uninstaller or remove the v11-only installation state, then install this build fresh."
    }
    if ((Get-InstallerStateStatus -State $InstallerState) -ne $FreshInstallStatusComplete) {
        throw "The MailSite 11 installer state is not Complete and is not a resumable current fresh install. Use the matching uninstaller, then rebuild the v11 installation."
    }

    $stateTarget = [string](Get-InstallerStatePropertyValue -State $InstallerState -PropertyName "TargetVersion")
    $detectedVersion = Get-InstalledMailSiteComparisonVersion -InstalledState $InstalledState
    if (-not (Test-ExactMailSiteVersion -Version $stateTarget)) {
        throw "The current installer state has invalid TargetVersion '$stateTarget'. It cannot be adopted; uninstall and rebuild the v11 installation."
    }
    if (-not $InstalledState.HasV11Artifacts) {
        return
    }
    if ($InstalledState.IsMixed) {
        throw "Existing MailSite 11 components are from mixed builds: $(Get-MailSiteComponentVersionSummary -InstalledState $InstalledState). Mixed v11 builds cannot be repaired or upgraded in place. Run uninstall-mailsite.ps1, discard v11-only state, and install one matching build."
    }
    if (-not (Test-ExactMailSiteVersion -Version $detectedVersion) -or $detectedVersion -ne $stateTarget) {
        throw "Existing MailSite 11 files report version '$detectedVersion', but the current installer state requires '$stateTarget'. Different v11 builds cannot be combined. Run uninstall-mailsite.ps1, discard v11-only state, and install one matching build."
    }
}

function Assert-MailSite11VersionTransition {
    param(
        [string]$InstalledVersion,
        [string]$TargetVersion
    )

    if (-not (Test-ExactMailSiteVersion -Version $InstalledVersion) -or
        -not (Test-ExactMailSiteVersion -Version $TargetVersion)) {
        throw "Cannot determine a safe MailSite 11 version transition ('$InstalledVersion' -> '$TargetVersion')."
    }
}

function Write-MailSite11UpgradeWarning {
    param(
        [string]$InstalledVersion,
        [string]$TargetVersion
    )

    Write-InstallerMessage "Upgrading MailSite $InstalledVersion to $TargetVersion in place. MailSite 11 is still in development; back up MailSite data first because the installed services may find incompatible development schemas and ask to delete them before restart." -Level "WARN"
}

function Write-MailSite11DowngradeWarning {
    param(
        [string]$InstalledVersion,
        [string]$TargetVersion
    )

    Write-InstallerMessage "Downgrading MailSite $InstalledVersion to $TargetVersion in place. Existing MailSite 11 databases are not rolled back. The installer will check them before restart when the target package supports schema inspection; otherwise it will warn and continue without a schema verdict." -Level "WARN"
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

function Invoke-MailSiteDatabaseSchemaReport {
    param(
        [string]$MsdbmaPath,
        [switch]$DeleteIncompatible
    )

    if ([string]::IsNullOrWhiteSpace($MsdbmaPath) -or
        -not (Test-Path -LiteralPath $MsdbmaPath -PathType Leaf)) {
        return @{
            Available = $false
            Error = "The target package does not include MSDBMA schema inspection."
            Report = $null
        }
    }

    $arguments = @("database-schemas", "--json")
    if ($DeleteIncompatible) {
        $arguments += "--delete-incompatible"
    }

    try {
        $result = Invoke-MailSiteExecutable -FilePath $MsdbmaPath -ArgumentList $arguments
    } catch {
        return @{
            Available = $false
            Error = $_.Exception.Message
            Report = $null
        }
    }
    if ($result.ExitCode -ne 0) {
        return @{
            Available = $false
            Error = "MSDBMA schema inspection exited with code $($result.ExitCode): $($result.Output -join ' ')"
            Report = $null
        }
    }

    try {
        $report = ($result.Output -join [Environment]::NewLine) | ConvertFrom-Json
    } catch {
        return @{
            Available = $false
            Error = "MSDBMA did not return a valid database schema report: $($_.Exception.Message)"
            Report = $null
        }
    }
    if ($null -eq $report -or [int]$report.schemaVersion -ne 1) {
        $reportedVersion = if ($null -eq $report) { "missing" } else { [string]$report.schemaVersion }
        return @{
            Available = $false
            Error = "MSDBMA returned unsupported database schema report version '$reportedVersion'."
            Report = $null
        }
    }
    $requiredProperties = @(
        "buildVersion", "compatible", "databases", "discoveryErrors",
        "deletedDatabases", "deletionErrors"
    )
    $missingProperties = @($requiredProperties | Where-Object { $null -eq $report.PSObject.Properties[$_] })
    if ($missingProperties.Count -gt 0) {
        return @{
            Available = $false
            Error = "MSDBMA database schema report is missing required properties: $($missingProperties -join ', ')."
            Report = $null
        }
    }

    return @{
        Available = $true
        Error = $null
        Report = $report
    }
}

function Resolve-MailSitePostInstallDatabaseSchemas {
    param(
        [string]$MsdbmaPath,
        [switch]$AllowUnavailable
    )

    Write-InstallerMessage "Checking existing MailSite 11 database schemas with the target package's MSDBMA build..."
    $inspection = Invoke-MailSiteDatabaseSchemaReport -MsdbmaPath $MsdbmaPath
    if (-not $inspection.Available) {
        Write-InstallerMessage "Could not verify the existing database schemas: $($inspection.Error)" -Level "WARN"
        if ($AllowUnavailable) {
            Write-InstallerMessage "Continuing the downgrade without database schema verification. The target package does not provide a usable schema checker; its services may fail to start or may be unable to open databases created by a newer build." -Level "WARN"
            return $true
        }
        Write-InstallerMessage "The package remains installed, but MailSite services will stay stopped so an incompatible database is not opened." -Level "WARN"
        return $false
    }

    $report = $inspection.Report
    $discoveryErrors = @($report.discoveryErrors)
    $incompatible = @($report.databases | Where-Object { -not [bool]$_.compatible })
    if ($incompatible.Count -eq 0) {
        if ($discoveryErrors.Count -gt 0) {
            foreach ($errorMessage in $discoveryErrors) {
                Write-InstallerMessage "Database discovery error: $errorMessage" -Level "WARN"
            }
            if ($AllowUnavailable) {
                Write-InstallerMessage "Continuing the downgrade without complete database schema verification. The target services may fail to start or open an undiscovered database." -Level "WARN"
                return $true
            }
            Write-InstallerMessage "The package remains installed, but MailSite services will stay stopped because schema inspection was incomplete." -Level "WARN"
            return $false
        }
        if (-not [bool]$report.compatible) {
            if ($AllowUnavailable) {
                Write-InstallerMessage "MSDBMA could not provide a complete schema verdict. Continuing the downgrade without complete database schema verification; the target services may fail to start or open an existing database." -Level "WARN"
                return $true
            }
            Write-InstallerMessage "MSDBMA reported that the database set is incompatible but did not identify a database that can be removed safely. The package remains installed and MailSite services will stay stopped." -Level "WARN"
            return $false
        }
        Write-InstallerMessage "All discovered MailSite 11 databases are compatible with the installed services."
        return $true
    }

    Write-InstallerMessage "Found $($incompatible.Count) database(s) whose schemas are incompatible with MailSite $($report.buildVersion)." -Level "WARN"
    $groups = @($incompatible | Group-Object databaseKind, actualVersion, requiredVersion)
    foreach ($group in $groups) {
        $sample = $group.Group[0]
        $actualVersion = if ($null -eq $sample.actualVersion) { "unreadable" } else { [string]$sample.actualVersion }
        Write-InstallerMessage "  $($sample.databaseKind): $($group.Count) database(s), actual schema $actualVersion, required schema $($sample.requiredVersion)" -Level "WARN"
    }
    foreach ($database in @($incompatible | Select-Object -First 10)) {
        Write-InstallerMessage "  $($database.path)" -Level "WARN"
        $detailProperty = $database.PSObject.Properties["detail"]
        if ($null -ne $detailProperty -and -not [string]::IsNullOrWhiteSpace([string]$detailProperty.Value)) {
            Write-InstallerMessage "    $($detailProperty.Value)" -Level "WARN"
        }
    }
    if ($incompatible.Count -gt 10) {
        Write-InstallerMessage "  ...and $($incompatible.Count - 10) more incompatible database(s)." -Level "WARN"
    }
    foreach ($errorMessage in $discoveryErrors) {
        Write-InstallerMessage "Database discovery error: $errorMessage" -Level "WARN"
    }

    $deleteAccepted = Read-YesNo -Prompt "Delete the incompatible MailSite 11 databases now? Their contents will be permanently lost." -DefaultYes $false
    if (-not $deleteAccepted) {
        Write-InstallerMessage "The incompatible databases were retained. The package and Windows service registrations are installed, but MailSite services will stay stopped." -Level "WARN"
        return $false
    }

    Write-InstallerMessage "Deleting the incompatible MailSite 11 databases accepted by the operator..." -Level "WARN"
    $cleanup = Invoke-MailSiteDatabaseSchemaReport -MsdbmaPath $MsdbmaPath -DeleteIncompatible
    if (-not $cleanup.Available) {
        Write-InstallerMessage "Database deletion could not be verified: $($cleanup.Error)" -Level "WARN"
        Write-InstallerMessage "The package remains installed, but MailSite services will stay stopped." -Level "WARN"
        return $false
    }

    $cleanupReport = $cleanup.Report
    foreach ($errorMessage in @($cleanupReport.deletionErrors)) {
        Write-InstallerMessage "Database deletion error: $errorMessage" -Level "WARN"
    }
    foreach ($errorMessage in @($cleanupReport.discoveryErrors)) {
        Write-InstallerMessage "Database discovery error after deletion: $errorMessage" -Level "WARN"
    }
    $remaining = @($cleanupReport.databases | Where-Object { -not [bool]$_.compatible })
    if ($remaining.Count -gt 0 -or @($cleanupReport.deletionErrors).Count -gt 0) {
        Write-InstallerMessage "Database cleanup was incomplete; $($remaining.Count) incompatible database(s) remain. MailSite services will stay stopped." -Level "WARN"
        return $false
    }
    if (@($cleanupReport.discoveryErrors).Count -gt 0 -or -not [bool]$cleanupReport.compatible) {
        if ($AllowUnavailable) {
            Write-InstallerMessage "Known incompatible databases were deleted, but schema discovery could not be completed. Continuing the downgrade without complete verification; the target services may fail to start or open an undiscovered database." -Level "WARN"
            return $true
        }
        Write-InstallerMessage "Database cleanup could not be verified completely. MailSite services will stay stopped." -Level "WARN"
        return $false
    }

    Write-InstallerMessage "Deleted $(@($cleanupReport.deletedDatabases).Count) incompatible database(s). MailSite will rebuild them with the installed schema when the services start."
    return $true
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

        if ($trial.Ok -and $null -ne $trial.Body -and $trial.Body.valid -eq $true -and
            -not [string]::IsNullOrWhiteSpace($trial.Body.license.licenseKey) -and
            -not [string]::IsNullOrWhiteSpace($trial.Body.validationToken)) {
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

        if ($null -ne $trialResolution -and $null -ne $trialResolution.OnlineValidation) {
            # Trial issuance already returned the mandatory signed website
            # assertion; use it instead of making a redundant request.
            Write-InstallerMessage "Using the signed validation returned with the MailSite trial license."
            Save-MailSiteLicenseValidationCache -InstallDirectory $InstallDir -ValidationBody $trialResolution.OnlineValidation
            return @{
                LicenseKey = $key
                IsTrial = $true
                OnlineValidation = $trialResolution.OnlineValidation
                Summary = $trialResolution.Summary
            }
        }

        Write-InstallerMessage "Validating MailSite license key with the MailSite license service..."
        $onlineValidation = Test-MailSiteOnlineLicenseValidation -LicenseKey $key -AllowedProductMajors @([int]$TargetMajorVersion)
        if ($onlineValidation.Outcome -eq "valid") {
            Write-InstallerMessage "MailSite license service accepted the license key and returned a signed assertion."
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
        } else {
            Write-InstallerMessage "The license service is unavailable; installation cannot continue without a signed website assertion. $($onlineValidation.Message)" -Level "WARN"
        }
        $key = Read-FreshInstallLicenseKeyRetry
    }
}

function Get-FreshInstallLicenseKeyFromCache {
    $cachePath = Get-LicenseValidationCachePath -RootDirectory $InstallDir
    if (-not (Test-Path -LiteralPath $cachePath -PathType Leaf)) {
        throw "The interrupted fresh install has no signed license cache at $cachePath. Start over with uninstall-mailsite.ps1."
    }
    try {
        $cache = Get-Content -LiteralPath $cachePath -Raw | ConvertFrom-Json
    } catch {
        throw "The signed license cache at $cachePath is not valid JSON. Start over with uninstall-mailsite.ps1. $($_.Exception.Message)"
    }
    $licenseKey = [string]$cache.LicenseKey
    if ([string]::IsNullOrWhiteSpace($licenseKey)) {
        throw "The signed license cache at $cachePath does not contain its license key. Start over with uninstall-mailsite.ps1."
    }
    return $licenseKey.Trim()
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

        return Read-ValidatedFreshInstallServiceAccount -AccountName $candidate
    }
}

function Read-ValidatedFreshInstallServiceAccount {
    param([string]$AccountName)

    while ($true) {
        $password = Read-MaskedInput -Prompt "Password for $AccountName"
        Write-InstallerMessage "Validating credentials for $AccountName..."
        if (Test-ServiceAccountCredential -UserName $AccountName -Password $password) {
            Write-InstallerMessage "Credentials for $AccountName were validated."
            return @{ UserName = $AccountName; Password = $password }
        }
        Write-Host "Could not validate the credentials for '$AccountName'. Please try again." -ForegroundColor Yellow
    }
}

function Read-ResumedFreshInstallServiceAccount {
    param([string]$AccountName)

    if ([string]::IsNullOrWhiteSpace($AccountName) -or $AccountName -ieq "LocalSystem") {
        return $null
    }
    Write-Host "The interrupted install configured MailSite services to run as $AccountName."
    return Read-ValidatedFreshInstallServiceAccount -AccountName $AccountName
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
    param(
        [string]$ServiceName,
        [switch]$RequireRemoval
    )

    if (-not (Test-MailSiteServiceInstalled -ServiceName $ServiceName)) {
        return
    }

    Write-InstallerMessage "Removing newly created $ServiceName Windows service..."
    & sc.exe delete $ServiceName | Out-Null
    if ($LASTEXITCODE -ne 0) {
        $message = "Could not delete the newly created $ServiceName service. sc.exe exited with code $LASTEXITCODE."
        if ($RequireRemoval) {
            throw $message
        }
        Write-InstallerMessage $message -Level "WARN"
        return
    }
    if ($RequireRemoval) {
        Wait-MailSiteServiceRemoved -ServiceName $ServiceName
    }
}

function Wait-MailSiteServiceRemoved {
    param(
        [string]$ServiceName,
        [int]$TimeoutSeconds = 30
    )

    $deadline = [DateTime]::UtcNow.AddSeconds($TimeoutSeconds)
    while ([DateTime]::UtcNow -lt $deadline) {
        if (-not (Test-MailSiteServiceInstalled -ServiceName $ServiceName)) {
            return
        }
        Start-Sleep -Milliseconds 250
    }
    throw "Timed out waiting for the $ServiceName Windows service to be removed."
}

function Retire-MSDBMAForPreMSDBMATarget {
    [void](Remove-MSDBMAClientCredentials)

    if (Test-MailSiteServiceInstalled -ServiceName "MSDBMA") {
        Write-InstallerMessage "The target package predates MSDBMA. Removing the stopped MSDBMA service registration..." -Level "WARN"
        & sc.exe delete "MSDBMA" | Out-Null
        if ($LASTEXITCODE -eq 0) {
            try {
                Wait-MailSiteServiceRemoved -ServiceName "MSDBMA"
            } catch {
                Write-InstallerMessage "MSDBMA was marked for deletion but Windows has not removed it yet. It will remain stopped and will not be restarted by this installation." -Level "WARN"
            }
        } else {
            Write-InstallerMessage "Could not remove the obsolete MSDBMA service registration (sc.exe exit code $LASTEXITCODE). Disabling it so it cannot start with the pre-MSDBMA target package." -Level "WARN"
            try {
                Set-Service -Name "MSDBMA" -StartupType Disabled -ErrorAction Stop
            } catch {
                Write-InstallerMessage "Could not disable the obsolete MSDBMA service: $($_.Exception.Message). It remains stopped, but must be removed or disabled before reboot." -Level "WARN"
            }
        }
    }

    $installedExecutable = Join-Path $InstallDir "msdbma.exe"
    if (Test-Path -LiteralPath $installedExecutable -PathType Leaf) {
        $retiredDirectory = Join-Path (Join-Path $InstallDir $InstallDataDirectoryName) "RetiredComponents"
        New-Item -ItemType Directory -Path $retiredDirectory -Force | Out-Null
        $retiredExecutable = Join-Path $retiredDirectory "msdbma.exe.pre-target"
        try {
            Move-Item -LiteralPath $installedExecutable -Destination $retiredExecutable -Force
            Write-InstallerMessage "Moved the inactive MSDBMA executable out of the target package root."
        } catch {
            Write-InstallerMessage "Could not retire ${installedExecutable}: $($_.Exception.Message). The target services will not start MSDBMA, but a future installer may report the retained executable as a mixed build." -Level "WARN"
        }
    }
}

function Get-InstalledMailSiteServiceNames {
    $installed = @()
    foreach ($service in $Services) {
        if (Test-MailSiteServiceInstalled -ServiceName $service.Name) {
            $installed += $service.Name
        }
    }
    return $installed
}

function Assert-NewFreshInstallHasNoServices {
    $installed = @(Get-InstalledMailSiteServiceNames)
    if ($installed.Count -gt 0) {
        throw "No MailSite registry or v11 installation was found, but these MailSite service names already exist: $($installed -join ', '). Refusing to overwrite services that are not owned by a fresh-install marker."
    }
}

function Remove-InProgressFreshServices {
    param([object]$State)

    if (-not (Test-InProgressFreshInstall -State $State)) {
        throw "Fresh-install service recovery requires an explicit InProgress fresh-install marker."
    }
    Assert-FreshInstallStateDirectory -State $State

    # Validate ownership for every present service before deleting any of them.
    # This prevents a stale marker from partially removing a legacy or custom
    # installation that happens to reuse one of the MailSite service names.
    $ownedServices = @()
    foreach ($service in $Services) {
        if (-not (Test-MailSiteServiceInstalled -ServiceName $service.Name)) {
            continue
        }
        $imagePath = Get-ServiceImagePath -ServiceName $service.Name
        $actualExecutable = Get-ServiceExecutablePathFromImagePath -ImagePath $imagePath
        $expectedExecutable = Join-Path $InstallDir $service.File
        if (-not (Test-MailSitePathEqual -Left $actualExecutable -Right $expectedExecutable)) {
            throw "Cannot recover the interrupted fresh install because service $($service.Name) points to '$actualExecutable', not the owned path '$expectedExecutable'. No services were removed."
        }
        $ownedServices += $service.Name
    }

    foreach ($serviceName in $ownedServices) {
        if (Test-MailSiteServiceInstalled -ServiceName $serviceName) {
            Stop-MailSiteService -ServiceName $serviceName | Out-Null
        }
        Remove-MailSiteWindowsService -ServiceName $serviceName -RequireRemoval
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
        throw "Could not update permissions on ${Directory}: icacls.exe exited with code $($result.ExitCode). $detail"
    }
}

function ConvertTo-MailSiteFileAclSid {
    param([string]$AccountName)

    $normalized = Normalize-ServiceLogOnAccount -AccountName $AccountName
    switch ($normalized) {
        "nt authority\system" { return "*S-1-5-18" }
        "nt authority\localservice" { return "*S-1-5-19" }
        "nt authority\networkservice" { return "*S-1-5-20" }
    }

    try {
        $account = [Security.Principal.NTAccount]::new($normalized)
        $sid = $account.Translate([Security.Principal.SecurityIdentifier])
        return "*$($sid.Value)"
    } catch {
        throw "Could not resolve the MailSite service account '$AccountName' to a Windows SID: $($_.Exception.Message)"
    }
}

function Set-MailSiteInstallDataDirectoryAcl {
    param(
        [string]$RootDirectory,
        [hashtable]$Audit
    )

    $directory = Join-Path $RootDirectory $InstallDataDirectoryName
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    if ($null -eq $Audit) {
        $Audit = Get-MailSiteServiceAccountAudit
    }

    $aclIdentities = [ordered]@{}
    if ($null -ne $Audit.Groups) {
        foreach ($normalizedAccount in @($Audit.Groups.Keys)) {
            # LocalSystem already has full control through the standard Program
            # Files ACL (and the fresh-install root grant). Other built-in and
            # custom identities need an explicit, inheritable Modify grant.
            if ([string]$normalizedAccount -eq "nt authority\system") {
                continue
            }
            $group = $Audit.Groups[$normalizedAccount]
            $sid = ConvertTo-MailSiteFileAclSid -AccountName ([string]$normalizedAccount)
            if (-not $aclIdentities.Contains($sid)) {
                $aclIdentities[$sid] = [string]$group.Display
            }
        }
    }

    if ($aclIdentities.Count -eq 0) {
        Write-InstallerMessage "MailSite install-data permissions require no additional filesystem grants."
        return
    }

    $accounts = @($aclIdentities.Values)
    $arguments = @($directory, "/grant")
    foreach ($sid in $aclIdentities.Keys) {
        $arguments += "${sid}:(OI)(CI)M"
    }
    # Apply recursively because install.log, install.json, and license.json may
    # have been created by this elevated installer before the service identity
    # was audited. Runtime cache replacement requires create/delete/rename.
    $arguments += @("/T", "/C", "/Q")

    Write-InstallerMessage "Granting Modify access on $directory to $($accounts -join ', ')..."
    $result = Invoke-MailSiteExecutable -FilePath "icacls.exe" -ArgumentList $arguments
    if ($result.ExitCode -ne 0) {
        $detail = (@($result.Output) -join [Environment]::NewLine).Trim()
        throw "Could not grant MailSite services write access to ${directory}: icacls.exe exited with code $($result.ExitCode). $detail"
    }
}

function Normalize-PackageReleaseNotes {
    param(
        [string]$PackageRoot,
        [string]$RootDirectory
    )

    $packagePrimaryPath = Join-Path $PackageRoot "release-notes.html"
    $destinationPrimaryPath = Join-Path $RootDirectory "release-notes.html"
    $destinationInstallPath = Join-Path (Join-Path $RootDirectory $InstallDataDirectoryName) "release-notes.html"
    $destinationLegacyPath = Join-Path $RootDirectory "mailsite-release-notes.html"

    if (-not (Test-Path -LiteralPath $packagePrimaryPath -PathType Leaf)) {
        throw "Package is missing root release-notes.html. Older MailSite 11 release-note layouts are not supported; use a package from this build."
    }

    Copy-Item -LiteralPath $packagePrimaryPath -Destination $destinationPrimaryPath -Force
    Remove-Item -LiteralPath $destinationInstallPath -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $destinationLegacyPath -Force -ErrorAction SilentlyContinue
}

function Assert-FreshInstallExecutablesPresent {
    foreach ($service in $Services) {
        $executable = Join-Path $InstallDir $service.File
        if (-not (Test-Path -LiteralPath $executable -PathType Leaf)) {
            throw "Package did not install $executable."
        }
    }
}

function Install-MailSiteFresh {
    param([object]$ResumeState = $null)

    $isResume = $null -ne $ResumeState
    $freshState = $ResumeState
    $extractRoot = $null

    if ($isResume) {
        if (-not (Test-InProgressFreshInstall -State $ResumeState)) {
            throw "Only an explicit InProgress fresh-install marker can be resumed."
        }
        Assert-FreshInstallStateDirectory -State $ResumeState
        $requestedVersion = [string](Get-InstallerStatePropertyValue -State $ResumeState -PropertyName "TargetVersion")
        $domainName = [string](Get-InstallerStatePropertyValue -State $ResumeState -PropertyName "DomainName")
        $serviceAccountName = [string](Get-InstallerStatePropertyValue -State $ResumeState -PropertyName "ServiceAccountName")
        if (-not (Test-ExactMailSiteVersion -Version $requestedVersion) -or [string]::IsNullOrWhiteSpace($domainName)) {
            throw "The interrupted fresh-install marker is missing a valid target version or domain name. Run uninstall-mailsite.ps1 and start again."
        }

        Write-InstallerMessage "Detected an interrupted MailSite $requestedVersion fresh install."
        Write-Host ""
        Write-Host "MailSite 11 Fresh Install Recovery"
        Write-Host "=================================="
        Write-Host (Format-InstallerConsoleMessage -Message "An incomplete MailSite $requestedVersion install can be resumed safely.")
        Write-Host "Install directory: $InstallDir"
        Write-Host "Default domain:    $domainName"
        Write-Host ""
        if (-not (Read-YesNo -Prompt "Resume the interrupted fresh install?" -DefaultYes $true)) {
            Write-InstallerMessage "Fresh-install recovery cancelled by user."
            return
        }

        # Neither password is persisted. Re-prompting lets idempotent setup
        # replace a password that may have been written but never displayed.
        $licenseKey = Get-FreshInstallLicenseKeyFromCache
        $postmaster = Read-FreshInstallPostmasterPassword
        $serviceAccount = Read-ResumedFreshInstallServiceAccount -AccountName $serviceAccountName
        $installRequest = @{ RemoteVersion = $requestedVersion }
    } else {
        Write-InstallerMessage "No existing MailSite installation was detected. Preparing a fresh MailSite $TargetMajorVersion install."
        Assert-NewFreshInstallHasNoServices
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

        # Gather secrets before the long-running package work. License key
        # decoding/validation remains website-only; only its signed assertion
        # is cached for setup and runtime verification.
        Write-Host ""
        Write-Host "MailSite setup needs a few details before installing."
        $licenseKey = Read-FreshInstallLicenseKeyText
        $domainName = Read-FreshInstallDomainName
        $postmaster = Read-FreshInstallPostmasterPassword
        $serviceAccount = Read-FreshInstallServiceAccount
    }

    try {
        if ($isResume) {
            # A prior exe may have registered its SCM entry before failing its
            # post-install work. Remove only services proven to belong to this
            # marker, then reinstall every service under one consistent account.
            Remove-InProgressFreshServices -State $freshState
        }

        $package = $null
        $stagedPackage = Join-Path $InstallDir "MailSite.zip"
        if ($isResume -and (Test-Path -LiteralPath $stagedPackage -PathType Leaf)) {
            try {
                if ((Get-PackageVersionFromZip -Path $stagedPackage) -eq $requestedVersion) {
                    $package = $stagedPackage
                    Write-InstallerMessage "Reusing the staged MailSite $requestedVersion package."
                }
            } catch {
                Write-InstallerMessage "The staged package cannot be reused: $($_.Exception.Message)" -Level "WARN"
            }
        }
        if ([string]::IsNullOrWhiteSpace($package)) {
            $package = Resolve-PackagePath -DestinationDirectory $InstallDir -RemoteVersion $installRequest.RemoteVersion
        }

        $extractRoot = Join-Path ([IO.Path]::GetTempPath()) ("MailSite11-" + [Guid]::NewGuid().ToString("N"))
        New-Item -ItemType Directory -Path $extractRoot -Force | Out-Null
        Write-InstallerMessage "Extracting $package..."
        Expand-Archive -Path $package -DestinationPath $extractRoot -Force
        $packageRoot = Get-PackageRoot -ExtractRoot $extractRoot
        $targetVersion = Get-PackageVersion -PackageRoot $packageRoot
        if (-not (Test-Path -LiteralPath (Join-Path $packageRoot "msdbma.exe") -PathType Leaf)) {
            throw "A pre-MSDBMA MailSite package can be used only to downgrade an existing completed v11 installation; it cannot be used for a fresh install."
        }
        if ($isResume -and $targetVersion -ne $requestedVersion) {
            throw "Interrupted fresh install requires MailSite $requestedVersion, but the prepared package is $targetVersion."
        }

        $licenseResolution = Resolve-FreshInstallLicenseKey -InitialKey $licenseKey
        $licenseKey = $licenseResolution.LicenseKey
        $licenseIsTrial = [bool]$licenseResolution.IsTrial
        $licenseSummary = $licenseResolution.Summary

        if (-not $isResume) {
            if (Test-Path -LiteralPath $MailSiteKey32) {
                throw "The MailSite product registry key appeared during fresh-install preflight. Refusing to overwrite configuration that this attempt does not own."
            }
            $serviceAccountName = if ($null -eq $serviceAccount) { "" } else { $serviceAccount.UserName }
            $freshState = New-FreshInstallState `
                -TargetVersion $targetVersion `
                -DomainName $domainName `
                -ServiceAccountName $serviceAccountName
        }
        Set-InstallerStatePropertyValue -State $freshState -PropertyName "InstallStatus" -Value $FreshInstallStatusInProgress
        Set-InstallerStatePropertyValue -State $freshState -PropertyName "LastAttemptAtUtc" -Value ([DateTimeOffset]::UtcNow.ToString("o"))
        # This atomic marker precedes every machine mutation after license and
        # package validation, so a power loss always leaves a resumable owner.
        Save-InstallerState -State $freshState

        Install-WebView2Runtime

        Write-InstallerMessage "Installing MailSite $targetVersion to $InstallDir..."
        Copy-Item -Path (Join-Path $packageRoot "*") -Destination $InstallDir -Recurse -Force
        Normalize-PackageReleaseNotes -PackageRoot $packageRoot -RootDirectory $InstallDir
        New-MailSiteDesktopShortcuts -RootDirectory $InstallDir

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
        Set-FreshInstallDirectoryAcl -Directory $InstallDir -ServiceAccount $serviceAccount
        Assert-FreshInstallExecutablesPresent

        foreach ($service in $Services) {
            $newExe = Join-Path $InstallDir $service.File
            Install-MailSiteWindowsService -Service $service -ExecutablePath $newExe -ServiceAccount $serviceAccount
            Set-ServiceDescription -ServiceName $service.Name -Description $service.Description
            Set-MailSiteFirewallRules -Service $service -ExecutablePath $newExe
        }

        [void](Set-MSDBMAServiceCredentials)
        Write-InstallerMessage "Provisioned private per-service credentials for MSDBMA authentication."

        $serviceAccountAudit = Get-MailSiteServiceAccountAudit
        Write-MailSiteServiceAccountMismatchWarning -Audit $serviceAccountAudit
        Set-MailSiteInstallDataDirectoryAcl -RootDirectory $InstallDir -Audit $serviceAccountAudit
        [void](Invoke-MailSiteServiceControlPermissionRepair -HttpmaPath (Join-Path $InstallDir "httpma.exe"))

        $startFailures = @()
        foreach ($service in $Services) {
            if (-not (Start-MailSiteService -ServiceName $service.Name)) {
                $startFailures += $service.Name
            }
        }
        if ($startFailures.Count -gt 0) {
            throw "Fresh install could not start these MailSite services: $($startFailures -join ', ')."
        }

        if ($postmaster.Generated) {
            Write-Host ""
            Write-Host "  A password was generated for Postmaster@${domainName}:" -ForegroundColor Yellow
            Write-Host "      $($postmaster.Password)" -ForegroundColor Cyan
            Write-Host "  Record this password now. It is not saved anywhere else and will not be shown again." -ForegroundColor Yellow
            [void](Read-Host "Press Enter after you have recorded the Postmaster password")
            Write-InstallerMessage "An autogenerated Postmaster password was displayed and acknowledged by the operator (not written to this log)."
        }

        # Commit completion only after every service is running and any
        # one-time generated password has been delivered and acknowledged.
        Set-InstallerStatePropertyValue -State $freshState -PropertyName "InstallStatus" -Value $FreshInstallStatusComplete
        Set-InstallerStatePropertyValue -State $freshState -PropertyName "CompletedAtUtc" -Value ([DateTimeOffset]::UtcNow.ToString("o"))
        try {
            Save-InstallerState -State $freshState
        } catch {
            # Keep the in-memory state aligned with the still-InProgress marker
            # so the outer failure handler removes the services it just started.
            Set-InstallerStatePropertyValue -State $freshState -PropertyName "InstallStatus" -Value $FreshInstallStatusInProgress
            throw
        }
        Remove-Item -LiteralPath $package -Force -ErrorAction SilentlyContinue

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
    } catch {
        $installFailure = $_.Exception
        if ($null -ne $freshState -and (Test-InProgressFreshInstall -State $freshState)) {
            Write-InstallerMessage "Fresh install is incomplete. Removing services owned by this attempt; staged files and configuration are retained for a safe retry." -Level "WARN"
            try {
                Remove-InProgressFreshServices -State $freshState
            } catch {
                Write-InstallerMessage "Could not fully clean up fresh-install services: $($_.Exception.Message)" -Level "WARN"
            }
        }
        throw $installFailure
    } finally {
        if (-not [string]::IsNullOrWhiteSpace($extractRoot)) {
            Remove-Item -Path $extractRoot -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

function Install-MailSite {
    Assert-MailSiteServiceControlGrantOptions
    Assert-Administrator
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    Initialize-InstallLog -RootDirectory $InstallDir
    # Repair the currently configured service identities before any online
    # license check creates the new primary cache. This still runs again after
    # service registration so newly added or reinstalled services are covered.
    Set-MailSiteInstallDataDirectoryAcl `
        -RootDirectory $InstallDir `
        -Audit (Get-MailSiteServiceAccountAudit)

    # Explicit state takes precedence over binary/registry heuristics. A fresh
    # attempt may have copied every executable and written part of the registry
    # before failing; classifying that as an upgrade would skip setup and lose
    # the selected service account.
    $installerState = Get-ExistingInstallerState
    if (Test-InProgressFreshInstall -State $installerState) {
        Install-MailSiteFresh -ResumeState $installerState
        return
    }

    $installedState = Get-InstalledMailSite11State -RootDirectory $InstallDir
    Assert-ExistingMailSite11Contract -InstallerState $installerState -InstalledState $installedState
    $hasCurrentV11State = $null -ne $installerState
    if ($hasCurrentV11State -and -not $installedState.HasV11Artifacts) {
        # A current Complete marker is sufficient to repair an installation
        # whose binaries are all missing/corrupt, but never an older marker:
        # Get-ExistingInstallerState rejected those before this point.
        $stateTarget = [string](Get-InstallerStatePropertyValue -State $installerState -PropertyName "TargetVersion")
        $installedState.HasV11Artifacts = $true
        $installedState.IsPartial = $true
        $installedState.ExactVersion = $stateTarget
        $installedState.DisplayVersion = $stateTarget
        $installedState.OldestVersion = $stateTarget
        $installedState.NewestVersion = $stateTarget
    }
    $installedVersion = Get-InstalledMailSiteComparisonVersion -InstalledState $installedState
    $installedDisplayVersion = Get-InstalledMailSiteDisplayVersion -InstalledState $installedState

    if (-not $installedState.HasV11Artifacts) {
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
        if ($installedState.MissingComponents.Count -gt 0) {
            Write-InstallerMessage "Existing MailSite 11 install is missing component(s): $($installedState.MissingComponents -join ', '). An exact-version repair may restore them."
        }
        if ($installedState.InvalidComponents.Count -gt 0) {
            Write-InstallerMessage "Existing MailSite 11 install has invalid component(s): $($installedState.InvalidComponents -join ', '). An exact-version repair may restore them." -Level "WARN"
        }
        # Repairing, reinstalling, or upgrading the existing v11 build. MailSite 10 may
        # still exist after a supported conversion; use it for permission
        # copying, but do not require it for a same-build v11 repair.
        try {
            $legacy = Assert-MailSite10
            Write-InstallerMessage "Detected MailSite $($legacy.RegistryVersion) using $($legacy.ConnectorName)."
        } catch {
            # A rejection or unavailable website is a license-validation
            # block, not evidence that MailSite 10 is gone; re-throw it so the
            # repair stops with the real message.
            if (([string]$_.Exception.Message).StartsWith($LicenseRejectedMessagePrefix) -or
                ([string]$_.Exception.Message).StartsWith($LicenseUnavailableMessagePrefix)) {
                throw
            }
            $legacy = $null
            Write-InstallerMessage "MailSite 10 is no longer present; continuing with the MailSite 11 installation. Rollback to MailSite 10 will not be available." -Level "WARN"
            $installedLicenseKey = Get-RegistryString -Path $MailSiteKey32 -Name "License"
            Assert-MailSiteLicenseValidatedOnline `
                -LicenseKey $installedLicenseKey `
                -AllowedProductMajors @(10, 11) `
                -BlankLicenseWarning "The existing MailSite 11 installation has no license key on record. Services will continue only under the legacy blank-license compatibility exception."
        }
    }

    $installRequest = Resolve-InstallRequest
    if ($installedState.HasV11Artifacts -and $installRequest.ForceReinstall -and
        [string]::IsNullOrWhiteSpace($PackagePath) -and -not (Test-SiblingPackageAvailable)) {
        # `reinstall` means the exact installed build. Downloading "latest"
        # here would silently turn repair into an unrequested v11 upgrade.
        $installRequest.RemoteVersion = $installedVersion
    }

    if ($installRequest.Interactive -and [string]::IsNullOrWhiteSpace($PackagePath) -and -not (Test-SiblingPackageAvailable)) {
        $installRequest = Resolve-InteractiveRemoteInstallRequest -InstalledVersion $installedVersion -InstalledState $installedState
        if ($installRequest.Cancelled) {
            return
        }
        $requestedVersion = $installRequest.RemoteVersion
    } else {
        $requestedVersion = Resolve-RequestedPackageVersion -InstallRequest $installRequest
    }

    if ($installedState.HasV11Artifacts) {
        Assert-MailSite11VersionTransition -InstalledVersion $installedVersion -TargetVersion $requestedVersion
        $versionComparison = Compare-MailSiteVersions -Left $requestedVersion -Right $installedVersion
        if ($versionComparison -ne 0) {
            $installRequest.ForceReinstall = $true
        }
        if ($versionComparison -gt 0) {
            if (-not [bool]$installRequest.UpgradeWarningShown) {
                Write-MailSite11UpgradeWarning -InstalledVersion $installedVersion -TargetVersion $requestedVersion
            }
        } elseif ($versionComparison -lt 0) {
            if (-not [bool]$installRequest.DowngradeWarningShown) {
                Write-MailSite11DowngradeWarning -InstalledVersion $installedVersion -TargetVersion $requestedVersion
            }
        }
        if (-not $installRequest.ForceReinstall -and -not (Test-MailSiteInstallNeedsRepair -InstalledState $installedState)) {
            $serviceAccountAudit = Get-MailSiteServiceAccountAudit
            Write-MailSiteServiceAccountMismatchWarning -Audit $serviceAccountAudit
            Set-MailSiteInstallDataDirectoryAcl -RootDirectory $InstallDir -Audit $serviceAccountAudit
            [void](Invoke-MailSiteServiceControlPermissionRepair -HttpmaPath (Join-Path $InstallDir "httpma.exe"))
            Write-InstallerMessage "MailSite $requestedVersion is already installed. No package changes were made."
            return
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
    $rollbackServiceEnvironment = @{}
    $rollbackServiceRegistryAccessSddl = @{}
    $createdServices = @()
    $servicesStopped = $false

    try {
        Write-InstallerMessage "Extracting $package..."
        Expand-Archive -Path $package -DestinationPath $extractRoot -Force
        $packageRoot = Get-PackageRoot -ExtractRoot $extractRoot
        $targetVersion = Get-PackageVersion -PackageRoot $packageRoot
        $targetServices = @(Get-PackageServices -PackageRoot $packageRoot)
        $targetHasMSDBMA = @($targetServices | Where-Object { $_.Name -eq "MSDBMA" }).Count -eq 1
        $isDowngrade = (Test-ExactMailSiteVersion -Version $installedVersion) -and
            ((Compare-MailSiteVersions -Left $targetVersion -Right $installedVersion) -lt 0)
        if (-not $targetHasMSDBMA -and -not $installedState.HasV11Artifacts) {
            throw "A pre-MSDBMA MailSite package can be used only to downgrade an existing completed v11 installation."
        }

        if (Test-ExactMailSiteVersion -Version $installedVersion) {
            Assert-MailSite11VersionTransition -InstalledVersion $installedVersion -TargetVersion $targetVersion
            if (-not $installRequest.ForceReinstall -and -not (Test-MailSiteInstallNeedsRepair -InstalledState $installedState)) {
                $serviceAccountAudit = Get-MailSiteServiceAccountAudit
                Write-MailSiteServiceAccountMismatchWarning -Audit $serviceAccountAudit
                Set-MailSiteInstallDataDirectoryAcl -RootDirectory $InstallDir -Audit $serviceAccountAudit
                [void](Invoke-MailSiteServiceControlPermissionRepair -HttpmaPath (Join-Path $InstallDir "httpma.exe"))
                Write-InstallerMessage "MailSite $targetVersion is already installed. No package changes were made."
                Remove-Item -LiteralPath $package -Force -ErrorAction SilentlyContinue
                return
            }
        }

        Write-InstallerMessage (Get-MailSiteInstallActionMessage -TargetVersion $targetVersion -InstalledState $installedState -InstallDirectory $InstallDir)

        Install-WebView2Runtime

        $existingState = Get-ExistingInstallerState
        $state = @{
            StateVersion = $InstallerStateVersion
            InstalledAtUtc = [DateTimeOffset]::UtcNow.ToString("o")
            InstallDir11 = $InstallDir
            TargetVersion = $targetVersion
            # Preserve the fresh-install marker across same-version repairs so uninstall keeps
            # deleting the services instead of reverting to a MailSite 10 that
            # never existed on this machine.
            FreshInstall = ($null -ne $existingState -and [bool]$existingState.FreshInstall)
            InstallStatus = $FreshInstallStatusComplete
            DomainName = ([string](Get-InstallerStatePropertyValue -State $existingState -PropertyName "DomainName"))
            ServiceAccountName = ([string](Get-InstallerStatePropertyValue -State $existingState -PropertyName "ServiceAccountName"))
            ProductRegistryExistedBefore = (Get-InstallerStatePropertyValue -State $existingState -PropertyName "ProductRegistryExistedBefore")
            PreviousImagePath = Copy-StateMap -State $existingState -PropertyName "PreviousImagePath"
            PreviousDescription = Copy-StateMap -State $existingState -PropertyName "PreviousDescription"
            PreviousServiceRegistryAccessSddl = Copy-StateMap -State $existingState -PropertyName "PreviousServiceRegistryAccessSddl"
            WasRunning = @{}
        }

        # Stop protocol services before their storage authority. $Services is
        # deliberately start-ordered, with MSDBMA first.
        $stopOrder = @($Services | Where-Object { $_.Name -ne "MSDBMA" }) +
            @($Services | Where-Object { $_.Name -eq "MSDBMA" })
        foreach ($service in $stopOrder) {
            if (Test-MailSiteServiceInstalled -ServiceName $service.Name) {
                $currentImagePath = Get-ServiceImagePath -ServiceName $service.Name
                $rollbackImagePath[$service.Name] = $currentImagePath
                $rollbackServiceEnvironment[$service.Name] = @(
                    Get-MailSiteServiceEnvironmentEntries -ServiceName $service.Name
                )
                $currentRegistryAccessSddl = Get-MailSiteServiceRegistryAccessSddl -ServiceName $service.Name
                $rollbackServiceRegistryAccessSddl[$service.Name] = $currentRegistryAccessSddl
                if (-not $state.PreviousImagePath.ContainsKey($service.Name)) {
                    $state.PreviousImagePath[$service.Name] = $currentImagePath
                }
                if (-not $state.PreviousDescription.ContainsKey($service.Name)) {
                    $state.PreviousDescription[$service.Name] = Get-ServiceDescription -ServiceName $service.Name
                }
                if (-not $state.FreshInstall -and
                    (Test-MailSiteLegacyService -Service $service) -and
                    -not $state.PreviousServiceRegistryAccessSddl.ContainsKey($service.Name)) {
                    # SDDL contains permissions, not credential values. Persisting
                    # it lets uninstall restore the exact pre-v11 service-key ACL
                    # without writing arbitrary service environment secrets into
                    # install.json.
                    $state.PreviousServiceRegistryAccessSddl[$service.Name] = $currentRegistryAccessSddl
                }
                $state.WasRunning[$service.Name] = Stop-MailSiteService -ServiceName $service.Name
            } else {
                if (@($targetServices | Where-Object { $_.Name -eq $service.Name }).Count -gt 0) {
                    Write-InstallerMessage "$($service.Name) Windows service is not installed; it will be created."
                }
                $rollbackImagePath[$service.Name] = $null
                $state.WasRunning[$service.Name] = $false
            }
        }
        $servicesStopped = $true

        Stop-MailSiteDesktopApps -RootDirectory $InstallDir

        if (Test-ShouldImportLegacyDirectoryAccessRules -InstalledState $installedState -LegacyInfo $legacy) {
            Write-InstallerMessage "Copying directory permissions from $($legacy.LegacyInstallDir) to $InstallDir..."
            Copy-DirectoryAccessRules -SourceDirectory $legacy.LegacyInstallDir -DestinationDirectory $InstallDir
        }

        Remove-InstalledExpressProDist -PackageRoot $packageRoot -DestinationRoot $InstallDir
        Copy-Item -Path (Join-Path $packageRoot "*") -Destination $InstallDir -Recurse -Force
        Normalize-PackageReleaseNotes -PackageRoot $packageRoot -RootDirectory $InstallDir
        New-MailSiteDesktopShortcuts -RootDirectory $InstallDir

        Save-InstallerState -State $state

        foreach ($service in $targetServices) {
            $newExe = Join-Path $InstallDir $service.File
            if (-not (Test-Path -LiteralPath $newExe)) {
                throw "Package did not install $newExe."
            }
            if (Test-MailSiteServiceInstalled -ServiceName $service.Name) {
                Set-ServiceImagePath -ServiceName $service.Name -ExecutablePath $newExe
            } else {
                # Services absent from a v10 conversion or damaged current install use the established default:
                # LocalSystem, followed by the normal account-mismatch audit.
                Install-MailSiteWindowsService -Service $service -ExecutablePath $newExe -ServiceAccount $null
                $createdServices += $service.Name
            }
            Set-ServiceDescription -ServiceName $service.Name -Description $service.Description
            Set-MailSiteFirewallRules -Service $service -ExecutablePath $newExe
        }

        if ($targetHasMSDBMA) {
            $credentialProvisioning = Set-MSDBMAServiceCredentials
            if ($credentialProvisioning.Created) {
                Write-InstallerMessage "Provisioned a new MSDBMA authentication master key and private per-service credentials."
            } elseif ($credentialProvisioning.Rotated) {
                Write-InstallerMessage "Replaced an invalid MSDBMA authentication master key and repaired every service credential."
            } elseif ($credentialProvisioning.Changed) {
                Write-InstallerMessage "Repaired MSDBMA private per-service credentials."
            } else {
                Write-InstallerMessage "MSDBMA private per-service credentials are already configured."
            }
        } else {
            [void](Remove-MSDBMAClientCredentials)
            Write-InstallerMessage "The target package predates MSDBMA; removed MSDBMA client credentials from its services." -Level "WARN"
        }

        $serviceAccountAudit = Get-MailSiteServiceAccountAudit
        Write-MailSiteServiceAccountMismatchWarning -Audit $serviceAccountAudit
        Set-MailSiteInstallDataDirectoryAcl -RootDirectory $InstallDir -Audit $serviceAccountAudit
        [void](Invoke-MailSiteServiceControlPermissionRepair -HttpmaPath (Join-Path $InstallDir "httpma.exe"))

        Remove-Item -LiteralPath $package -Force -ErrorAction SilentlyContinue

        $schemaCheckerPath = if ($targetHasMSDBMA) { Join-Path $InstallDir "msdbma.exe" } else { $null }
        $allowUnavailableSchemaCheck = $isDowngrade -or (-not $targetHasMSDBMA -and $installedState.HasV11Artifacts)
        $schemasReady = Resolve-MailSitePostInstallDatabaseSchemas `
            -MsdbmaPath $schemaCheckerPath `
            -AllowUnavailable:$allowUnavailableSchemaCheck
        if (-not $schemasReady) {
            Write-InstallerMessage "MailSite $targetVersion installation completed. Previously running services were deliberately left stopped pending database schema resolution." -Level "WARN"
            return
        }

        $startNewServices = (@($state.WasRunning.Values | Where-Object { $_ -eq $true }).Count -gt 0)
        $restartRequested = @()
        $restartFailures = @()
        foreach ($service in $targetServices) {
            if ($state.WasRunning[$service.Name] -or ($startNewServices -and ($createdServices -contains $service.Name))) {
                $restartRequested += $service.Name
                if (-not (Start-MailSiteService -ServiceName $service.Name)) {
                    $restartFailures += $service.Name
                }
            }
        }

        if (-not $targetHasMSDBMA) {
            Retire-MSDBMAForPreMSDBMATarget
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
                if ($rollbackServiceEnvironment.ContainsKey($service.Name) -and
                    (Test-MailSiteServiceInstalled -ServiceName $service.Name)) {
                    Set-MailSiteServiceEnvironmentEntries `
                        -ServiceName $service.Name `
                        -Entries @($rollbackServiceEnvironment[$service.Name])
                }
                if ($rollbackServiceRegistryAccessSddl.ContainsKey($service.Name) -and
                    (Test-MailSiteServiceInstalled -ServiceName $service.Name)) {
                    Set-MailSiteServiceRegistryAccessSddl `
                        -ServiceName $service.Name `
                        -Sddl $rollbackServiceRegistryAccessSddl[$service.Name]
                }
            }
        }
        throw
    } finally {
        Remove-Item -Path $extractRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}

if ($MyInvocation.InvocationName -ne ".") {
    try {
        Install-MailSite
    } catch {
        Write-InstallerFailure $_.Exception.Message
        if ($PSCommandPath) {
            exit 1
        }
    }
}
