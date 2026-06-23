[CmdletBinding()]
param(
    [string]$InstallDir = (Join-Path $env:ProgramFiles "MailSite")
)

$ErrorActionPreference = "Stop"

$Services = @(
    @{ Name = "HTTPMA"; File = "httpma.exe" },
    @{ Name = "IMAP4A"; File = "imap4a.exe" },
    @{ Name = "SMTPRA"; File = "smtpra.exe" },
    @{ Name = "SMTPDA"; File = "smtpda.exe" }
)

$DesktopApps = @(
    @{ Name = "ExpressPro"; File = "expresspro.exe"; ShortcutName = "ExpressPro" },
    @{ Name = "Console"; File = "console.exe"; ShortcutName = "MailSite Console" }
)

$MailSiteKey32 = "HKLM:\SOFTWARE\Wow6432Node\Rockliffe\MailSite"
$InstallMarkerName = ".mailsite11-install.json"
$script:LogPath = $null

function Initialize-UninstallLog {
    param([string]$RootDirectory)

    $logDirectory = Join-Path $RootDirectory "Log"
    New-Item -ItemType Directory -Path $logDirectory -Force | Out-Null
    $script:LogPath = Join-Path $logDirectory "install-mailsite.log"
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

    return ($trimmed -split '\s+', 2)[0]
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

function Load-InstallerState {
    $markerPath = Join-Path $InstallDir $InstallMarkerName
    if (-not (Test-Path -LiteralPath $markerPath)) {
        throw "MailSite 11 installer state was not found at $markerPath. Cannot safely uninstall."
    }

    $json = Get-Content -LiteralPath $markerPath -Raw
    return $json | ConvertFrom-Json
}

function Confirm-MailSiteUninstall {
    param(
        [object]$State,
        [string]$InstalledDirectory
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
    Write-Host "  - Restore service paths to MailSite 10"
    Write-Host "  - Remove MailSite desktop shortcuts"
    Write-Host "  - Remove MailSite 11 files"
    Write-Host "  - Remove MailSite 11 firewall rules"
    Write-Host ""

    return Read-YesNo -Prompt "Continue uninstall?" -DefaultYes $false
}

function Uninstall-MailSite {
    Assert-Administrator
    Initialize-UninstallLog -RootDirectory $InstallDir

    $state = Load-InstallerState
    $installedDir = $state.InstallDir11
    if ([string]::IsNullOrWhiteSpace($installedDir)) {
        $installedDir = $InstallDir
    }

    # Resolve where each service reverts to (its MailSite 10 binary) before making
    # any changes. If MailSite 10 has been removed there is nothing to revert to,
    # so notify the user and stop rather than leaving the services half-reverted.
    $restorePaths = @{}
    $unrevertable = @()
    foreach ($service in $Services) {
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

    if (-not (Confirm-MailSiteUninstall -State $state -InstalledDirectory $installedDir)) {
        Write-UninstallerMessage "Uninstall cancelled by user."
        return
    }

    foreach ($service in $Services) {
        Stop-MailSiteService -ServiceName $service.Name | Out-Null
    }

    Stop-MailSiteDesktopApps -RootDirectory $installedDir
    Remove-MailSiteDesktopShortcuts -RootDirectory $installedDir

    foreach ($service in $Services) {
        $path = "HKLM:\SYSTEM\CurrentControlSet\Services\$($service.Name)"
        Set-ItemProperty -Path $path -Name ImagePath -Value $restorePaths[$service.Name]
        Write-UninstallerMessage "Restored $($service.Name) service path to $($restorePaths[$service.Name])."
    }

    Remove-MailSiteFirewallRules

    $markerPath = Join-Path $installedDir $InstallMarkerName
    if ((Test-Path -LiteralPath $markerPath) -and (Test-Path -LiteralPath $installedDir)) {
        Write-UninstallerMessage "Removing MailSite 11 files from $installedDir..."
        Remove-Item -Path $installedDir -Recurse -Force
    }

    Write-Host "MailSite 11 uninstall completed successfully. Services were left stopped; start them manually after verification."
}

try {
    Uninstall-MailSite
} catch {
    Write-UninstallerFailure $_.Exception.Message
    if ($PSCommandPath) {
        exit 1
    }
}
