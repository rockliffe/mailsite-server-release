[CmdletBinding()]
param(
    [string]$InstallDir = (Join-Path $env:ProgramFiles "MailSite")
)

$ErrorActionPreference = "Stop"

$Services = @(
    @{ Name = "HTTPMA"; File = "httpma.exe" },
    @{ Name = "EWSMA"; File = "ewsma.exe"; LegacyService = $false },
    @{ Name = "MAPIMA"; File = "mapima.exe"; LegacyService = $false },
    @{ Name = "EASMA"; File = "easma.exe"; LegacyService = $false },
    @{ Name = "IMAP4A"; File = "imap4a.exe" },
    @{ Name = "POP3A"; File = "pop3a.exe" },
    @{ Name = "SMTPRA"; File = "smtpra.exe" },
    @{ Name = "SMTPDA"; File = "smtpda.exe" }
)

$DesktopApps = @(
    @{ Name = "ExpressPro"; File = "expresspro.exe"; ShortcutName = "ExpressPro" },
    @{ Name = "Console"; File = "console.exe"; ShortcutName = "MailSite Console" }
)

$MailSiteKey32 = "HKLM:\SOFTWARE\Wow6432Node\Rockliffe\MailSite"
$InstallMarkerName = "install.json"
$InstallerStateVersion = 2
$FreshInstallStatusInProgress = "InProgress"
$FreshInstallStatusComplete = "Complete"
$script:LogPath = $null

function Get-InstallMarkerPath {
    param([string]$RootDirectory)

    return Join-Path (Join-Path $RootDirectory "Log") $InstallMarkerName
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

function Get-UninstallerStateStatus {
    param([object]$State)

    Assert-UninstallerStateVersion -State $State
    $property = $State.PSObject.Properties["InstallStatus"]
    if ($null -eq $property -or [string]::IsNullOrWhiteSpace([string]$property.Value)) {
        return $FreshInstallStatusComplete
    }
    $status = [string]$property.Value
    if ($status -ne $FreshInstallStatusInProgress -and $status -ne $FreshInstallStatusComplete) {
        throw "Installer state contains unsupported InstallStatus '$status'."
    }
    return $status
}

function Assert-UninstallerStateVersion {
    param([object]$State)

    $versionProperty = $State.PSObject.Properties["StateVersion"]
    if ($null -ne $versionProperty -and [int]$versionProperty.Value -ne $InstallerStateVersion) {
        throw "Installer state uses unsupported StateVersion '$($versionProperty.Value)'."
    }
}

function Resolve-UninstallerStateDirectory {
    param(
        [object]$State,
        [string]$MarkerRoot
    )

    $stateDirectory = [string]$State.InstallDir11
    if ([string]::IsNullOrWhiteSpace($stateDirectory)) {
        return $MarkerRoot
    }
    if (-not (Test-MailSitePathEqual -Left $stateDirectory -Right $MarkerRoot)) {
        throw "Installer state at '$MarkerRoot' belongs to '$stateDirectory'. Rerun uninstall with the original -InstallDir; no changes were made."
    }
    return $stateDirectory
}

function Initialize-UninstallLog {
    param([string]$RootDirectory)

    $logDirectory = Join-Path $RootDirectory "Log"
    New-Item -ItemType Directory -Path $logDirectory -Force | Out-Null
    $script:LogPath = Join-Path $logDirectory "install.log"
    Write-UninstallerMessage "MailSite uninstaller started."
}

function Write-UninstallerMessage {
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

function Write-UninstallerFailure {
    param([string]$Message)

    Write-Host ""
    Write-UninstallerMessage "Uninstall failed: $Message" -Level "ERROR"
    if (-not [string]::IsNullOrWhiteSpace($script:LogPath)) {
        Write-Host "See log: $script:LogPath" -ForegroundColor Yellow
    }
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

function Assert-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "This uninstaller must be run from an elevated PowerShell session."
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

function Get-ServiceImagePathExecutable {
    param([string]$ImagePath)

    if ([string]::IsNullOrWhiteSpace($ImagePath)) {
        return $null
    }

    $trimmed = $ImagePath.Trim()
    if ($trimmed.StartsWith('"')) {
        $match = [regex]::Match($trimmed, '^"([^"]+)"')
        if ($match.Success) {
            return $match.Groups[1].Value
        }
    }
    $match = [regex]::Match($trimmed, '^(.+?\.exe)(?:\s|$)', [Text.RegularExpressions.RegexOptions]::IgnoreCase)
    if ($match.Success) {
        return $match.Groups[1].Value
    }
    return $trimmed
}

function Assert-FreshInstallServiceOwnership {
    param([string]$InstalledDirectory)

    foreach ($service in $Services) {
        if ($null -eq (Get-Service -Name $service.Name -ErrorAction SilentlyContinue)) {
            continue
        }
        $servicePath = "HKLM:\SYSTEM\CurrentControlSet\Services\$($service.Name)"
        $imagePath = (Get-ItemProperty -LiteralPath $servicePath -Name ImagePath).ImagePath
        $actualExecutable = Get-ServiceImagePathExecutable -ImagePath $imagePath
        $expectedExecutable = Join-Path $InstalledDirectory $service.File
        if (-not (Test-MailSitePathEqual -Left $actualExecutable -Right $expectedExecutable)) {
            throw "Refusing fresh uninstall because service $($service.Name) points to '$actualExecutable', not the owned path '$expectedExecutable'. No changes were made."
        }
    }
}

function Test-MailSiteLegacyService {
    param([hashtable]$Service)

    if ($Service.ContainsKey("LegacyService")) {
        return [bool]$Service.LegacyService
    }

    return $true
}

function Resolve-UninstallServiceImagePath {
    param(
        [hashtable]$Service,
        [string]$SavedImagePath
    )

    $savedExecutable = Get-ServiceImagePathExecutable -ImagePath $SavedImagePath
    if (-not [string]::IsNullOrWhiteSpace($savedExecutable) -and (Test-Path -LiteralPath $savedExecutable)) {
        return $SavedImagePath
    }

    $legacyInstallDir = Get-RegistryString -Path $MailSiteKey32 -Name "InstallDir"
    if (-not [string]::IsNullOrWhiteSpace($legacyInstallDir)) {
        $legacyExecutable = Join-Path $legacyInstallDir $Service.File
        if (Test-Path -LiteralPath $legacyExecutable) {
            Write-UninstallerMessage "Saved service path for $($Service.Name) is unavailable; restoring to legacy install path $legacyExecutable." -Level "WARN"
            return "`"$legacyExecutable`""
        }
    }

    # No MailSite 10 binary exists at the saved path or the legacy install dir,
    # so the service cannot be reverted to MailSite 10. The caller reports this.
    return $null
}

function Stop-MailSiteService {
    param([string]$ServiceName)

    $service = Get-Service -Name $ServiceName -ErrorAction Stop
    if ($service.Status -eq "Stopped") {
        Write-UninstallerMessage "$ServiceName is already stopped."
        return $false
    }

    Write-UninstallerMessage "Stopping $ServiceName..."
    Stop-Service -Name $ServiceName -Force -ErrorAction Stop
    $service.WaitForStatus("Stopped", [TimeSpan]::FromSeconds(60))
    return $true
}

function Remove-MailSiteWindowsService {
    param([string]$ServiceName)

    if ($null -eq (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue)) {
        Write-UninstallerMessage "$ServiceName service is not installed."
        return
    }

    & sc.exe delete $ServiceName | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Could not delete the $ServiceName service. sc.exe exited with code $LASTEXITCODE."
    }

    Write-UninstallerMessage "Removed $ServiceName service."
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

        Write-UninstallerMessage "Stopping $($app.Name) desktop app before removing files..."
        $processes | Stop-Process -Force -ErrorAction Stop
        foreach ($process in $processes) {
            try {
                Wait-Process -Id $process.Id -Timeout 15 -ErrorAction Stop
            } catch {
                Write-UninstallerMessage "$($app.Name) process $($process.Id) did not exit within 15 seconds." -Level "WARN"
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

function Remove-MailSiteDesktopShortcuts {
    param([string]$RootDirectory)

    $desktop = Get-PublicDesktopDirectory
    if (-not (Test-Path -LiteralPath $desktop -PathType Container)) {
        return
    }

    $shell = $null
    try {
        $shell = New-Object -ComObject WScript.Shell
        foreach ($app in $DesktopApps) {
            $shortcutName = $app.ShortcutName
            if ([string]::IsNullOrWhiteSpace($shortcutName)) {
                $shortcutName = $app.Name
            }

            $shortcutPath = Join-Path $desktop "$shortcutName.lnk"
            if (-not (Test-Path -LiteralPath $shortcutPath)) {
                continue
            }

            $expectedTarget = Join-Path $RootDirectory $app.File
            $shortcut = $null
            try {
                $shortcut = $shell.CreateShortcut($shortcutPath)
                $targetPath = $shortcut.TargetPath
                if ([string]::Equals($targetPath, $expectedTarget, [StringComparison]::OrdinalIgnoreCase)) {
                    Remove-Item -LiteralPath $shortcutPath -Force
                    Write-UninstallerMessage "Removed all-users desktop shortcut: $shortcutPath"
                } else {
                    Write-UninstallerMessage "Skipping desktop shortcut '$shortcutPath' because it targets '$targetPath', not '$expectedTarget'." -Level "WARN"
                }
            } catch {
                Write-UninstallerMessage "Could not inspect desktop shortcut '$shortcutPath': $($_.Exception.Message)" -Level "WARN"
            } finally {
                if ($null -ne $shortcut) {
                    [Runtime.InteropServices.Marshal]::ReleaseComObject($shortcut) | Out-Null
                }
            }
        }
    } catch {
        Write-UninstallerMessage "Could not remove all-users desktop shortcuts: $($_.Exception.Message)" -Level "WARN"
    } finally {
        if ($null -ne $shell) {
            [Runtime.InteropServices.Marshal]::ReleaseComObject($shell) | Out-Null
        }
    }
}

function Remove-MailSiteFirewallRules {
    if (-not (Get-Command -Name Remove-NetFirewallRule -ErrorAction SilentlyContinue)) {
        Write-UninstallerMessage "Windows firewall cmdlets are not available; skipping MailSite 11 firewall rule cleanup." -Level "WARN"
        return
    }

    foreach ($service in $Services) {
        foreach ($direction in @("Inbound", "Outbound")) {
            $displayName = "MailSite $($service.Name) $direction"
            $rules = Get-NetFirewallRule -DisplayName $displayName -ErrorAction SilentlyContinue
            if ($rules) {
                $rules | Remove-NetFirewallRule | Out-Null
                Write-UninstallerMessage "Removed firewall rule '$displayName'."
            }
        }
    }
}

function Assert-FreshInstallProductRegistryOwnership {
    param(
        [object]$State,
        [string]$InstalledDirectory
    )

    $freshProperty = $State.PSObject.Properties["FreshInstall"]
    if ($null -eq $freshProperty -or -not [bool]$freshProperty.Value) {
        throw "Refusing to remove the MailSite product registry for a non-fresh installer state."
    }
    $preexistingProperty = $State.PSObject.Properties["ProductRegistryExistedBefore"]
    if ($null -ne $preexistingProperty -and [bool]$preexistingProperty.Value) {
        throw "Refusing to remove the MailSite product registry because the installer marker says it predated the fresh-install attempt."
    }
    if (-not (Test-Path -LiteralPath $MailSiteKey32)) {
        return
    }

    $registry = Get-ItemProperty -LiteralPath $MailSiteKey32
    $majorProperty = $registry.PSObject.Properties["ServerMajorVersion"]
    $installDirectoryProperty = $registry.PSObject.Properties["InstallDir11"]
    $status = Get-UninstallerStateStatus -State $State

    if ($null -ne $majorProperty -and [int]$majorProperty.Value -ne 11) {
        throw "Refusing to remove $MailSiteKey32 because ServerMajorVersion is '$($majorProperty.Value)', not 11."
    }
    if ($null -ne $installDirectoryProperty -and
        -not [string]::IsNullOrWhiteSpace([string]$installDirectoryProperty.Value) -and
        -not (Test-MailSitePathEqual -Left ([string]$installDirectoryProperty.Value) -Right $InstalledDirectory)) {
        throw "Refusing to remove $MailSiteKey32 because InstallDir11 points to '$($installDirectoryProperty.Value)', not '$InstalledDirectory'."
    }
    if ($status -eq $FreshInstallStatusComplete) {
        if ($null -eq $majorProperty -or $null -eq $installDirectoryProperty -or
            [string]::IsNullOrWhiteSpace([string]$installDirectoryProperty.Value)) {
            throw "Refusing to remove $MailSiteKey32 because it does not contain both ServerMajorVersion=11 and InstallDir11 ownership values. Remove or repair this ambiguous registry key manually after confirming it is not a MailSite 10 installation."
        }
    }
}

function Remove-FreshInstallProductRegistry {
    param(
        [object]$State,
        [string]$InstalledDirectory
    )

    Assert-FreshInstallProductRegistryOwnership -State $State -InstalledDirectory $InstalledDirectory
    if (-not (Test-Path -LiteralPath $MailSiteKey32)) {
        Write-UninstallerMessage "MailSite product registry key is already absent."
        return
    }

    Write-UninstallerMessage "Removing fresh MailSite 11 configuration from $MailSiteKey32..."
    Remove-Item -LiteralPath $MailSiteKey32 -Recurse -Force
}

function Load-InstallerState {
    $markerPath = Get-InstallMarkerPath -RootDirectory $InstallDir
    if (-not (Test-Path -LiteralPath $markerPath)) {
        throw "MailSite 11 installer state was not found at $markerPath. Cannot safely uninstall."
    }

    $json = Get-Content -LiteralPath $markerPath -Raw
    $state = $json | ConvertFrom-Json
    Assert-UninstallerStateVersion -State $state
    return $state
}

function Confirm-MailSiteUninstall {
    param(
        [object]$State,
        [string]$InstalledDirectory,
        [bool]$FreshInstall
    )

    $targetVersion = $State.TargetVersion
    if ([string]::IsNullOrWhiteSpace($targetVersion)) {
        $targetVersion = "Unknown"
    }

    Write-Host ""
    Write-Host "MailSite 11 Uninstaller"
    Write-Host "======================="
    Write-Host "Installed MailSite 11: $targetVersion"
    Write-Host "Install directory:       $InstalledDirectory"
    Write-Host ""
    Write-Host "This will:"
    Write-Host "  - Stop MailSite services"
    Write-Host "  - Stop MailSite desktop apps"
    if ($FreshInstall) {
        # This MailSite 11 was a fresh install; there is no MailSite 10 to revert to.
        Write-Host "  - Remove MailSite services"
        Write-Host "  - Remove MailSite registry configuration and default-domain accounts"
    } else {
        Write-Host "  - Restore service paths to MailSite 10"
    }
    Write-Host "  - Remove MailSite desktop shortcuts"
    Write-Host "  - Remove MailSite 11 files"
    Write-Host "  - Remove MailSite 11 firewall rules"
    Write-Host ""

    return Read-YesNo -Prompt "Continue uninstall?" -DefaultYes $false
}

function Uninstall-MailSite {
    Assert-Administrator
    $state = Load-InstallerState
    # The marker may be copied or stale. Never let a marker loaded from one
    # command-line root redirect an elevated uninstall to another directory.
    $installedDir = Resolve-UninstallerStateDirectory -State $state -MarkerRoot $InstallDir
    Initialize-UninstallLog -RootDirectory $installedDir

    # MailSite 11 installs written by the fresh-install flow record FreshInstall in
    # the marker: there is no MailSite 10 to revert to, so the services created by
    # the fresh install are deleted outright instead of being re-pointed.
    $freshInstall = $false
    $freshInstallProperty = $state.PSObject.Properties["FreshInstall"]
    if ($null -ne $freshInstallProperty) {
        $freshInstall = [bool]$freshInstallProperty.Value
    }

    # Prove registry ownership before stopping/removing any service. A stale or
    # contradictory marker must leave the existing installation untouched.
    if ($freshInstall) {
        Assert-FreshInstallProductRegistryOwnership -State $state -InstalledDirectory $installedDir
        Assert-FreshInstallServiceOwnership -InstalledDirectory $installedDir
    }

    # Resolve where each service reverts to (its MailSite 10 binary) before making
    # any changes. If MailSite 10 has been removed there is nothing to revert to,
    # so notify the user and stop rather than leaving the services half-reverted.
    $restorePaths = @{}
    if (-not $freshInstall) {
        $unrevertable = @()
        foreach ($service in $Services) {
            if (-not (Test-MailSiteLegacyService -Service $service)) {
                continue
            }

            $previous = $state.PreviousImagePath.($service.Name)
            $restorePath = Resolve-UninstallServiceImagePath -Service $service -SavedImagePath $previous
            if ([string]::IsNullOrWhiteSpace($restorePath)) {
                $unrevertable += $service.Name
            } else {
                $restorePaths[$service.Name] = $restorePath
            }
        }
        if ($unrevertable.Count -gt 0) {
            $legacyDir = Get-RegistryString -Path $MailSiteKey32 -Name "InstallDir"
            Write-UninstallerMessage "MailSite 10 is no longer present, so the uninstaller cannot revert these services to it: $($unrevertable -join ', ')." -Level "WARN"
            if (-not [string]::IsNullOrWhiteSpace($legacyDir)) {
                Write-UninstallerMessage "Restore the MailSite 10 installation (expected at '$legacyDir') and run uninstall again." -Level "WARN"
            }
            Write-UninstallerMessage "No changes were made." -Level "WARN"
            return
        }
    }

    if (-not (Confirm-MailSiteUninstall -State $state -InstalledDirectory $installedDir -FreshInstall $freshInstall)) {
        Write-UninstallerMessage "Uninstall cancelled by user."
        return
    }

    foreach ($service in $Services) {
        # A failed or partially completed fresh install may not have created every
        # service, so tolerate missing services in fresh mode.
        if ($freshInstall -and $null -eq (Get-Service -Name $service.Name -ErrorAction SilentlyContinue)) {
            Write-UninstallerMessage "$($service.Name) service is not installed."
            continue
        }
        Stop-MailSiteService -ServiceName $service.Name | Out-Null
    }

    Stop-MailSiteDesktopApps -RootDirectory $installedDir
    Remove-MailSiteDesktopShortcuts -RootDirectory $installedDir

    if ($freshInstall) {
        foreach ($service in $Services) {
            Remove-MailSiteWindowsService -ServiceName $service.Name
        }
    } else {
        foreach ($service in $Services) {
            if (Test-MailSiteLegacyService -Service $service) {
                $path = "HKLM:\SYSTEM\CurrentControlSet\Services\$($service.Name)"
                Set-ItemProperty -Path $path -Name ImagePath -Value $restorePaths[$service.Name]
                Write-UninstallerMessage "Restored $($service.Name) service path to $($restorePaths[$service.Name])."
            } else {
                Remove-MailSiteWindowsService -ServiceName $service.Name
            }
        }
    }

    Remove-MailSiteFirewallRules

    if ($freshInstall) {
        Remove-FreshInstallProductRegistry -State $state -InstalledDirectory $installedDir
    }

    $markerPath = Get-InstallMarkerPath -RootDirectory $installedDir
    if ((Test-Path -LiteralPath $markerPath) -and (Test-Path -LiteralPath $installedDir)) {
        Write-UninstallerMessage "Removing MailSite 11 files from $installedDir..."
        Remove-Item -Path $installedDir -Recurse -Force
    }

    if ($freshInstall) {
        Write-Host "MailSite 11 uninstall completed successfully. MailSite services were removed."
    } else {
        Write-Host "MailSite 11 uninstall completed successfully. Services were left stopped; start them manually after verification."
    }
}

if ($MyInvocation.InvocationName -ne ".") {
    try {
        Uninstall-MailSite
    } catch {
        Write-UninstallerFailure $_.Exception.Message
        if ($PSCommandPath) {
            exit 1
        }
    }
}
