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

    if (-not [string]::IsNullOrWhiteSpace($SavedImagePath)) {
        return $SavedImagePath
    }

    throw "Cannot determine restore path for service $($Service.Name)."
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

function Remove-MailSiteFirewallRules {
    if (-not (Get-Command -Name Remove-NetFirewallRule -ErrorAction SilentlyContinue)) {
        Write-UninstallerMessage "Windows firewall cmdlets are not available; skipping MailSite 11 firewall rule cleanup." -Level "WARN"
        return
    }

    foreach ($service in $Services) {
        foreach ($direction in @("Inbound", "Outbound")) {
            $displayName = "MailSite 11 $($service.Name) $direction"
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
    Write-Host "  - Restore service paths to MailSite 10"
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

    if (-not (Confirm-MailSiteUninstall -State $state -InstalledDirectory $installedDir)) {
        Write-UninstallerMessage "Uninstall cancelled by user."
        return
    }

    foreach ($service in $Services) {
        Stop-MailSiteService -ServiceName $service.Name | Out-Null
    }

    foreach ($service in $Services) {
        $previous = $state.PreviousImagePath.($service.Name)
        $restorePath = Resolve-UninstallServiceImagePath -Service $service -SavedImagePath $previous
        $path = "HKLM:\SYSTEM\CurrentControlSet\Services\$($service.Name)"
        Set-ItemProperty -Path $path -Name ImagePath -Value $restorePath
        Write-UninstallerMessage "Restored $($service.Name) service path to $restorePath."
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
