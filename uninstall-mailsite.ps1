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

function Test-TuiMenuSupported {
    try {
        return (-not [Console]::IsInputRedirected -and -not [Console]::IsOutputRedirected)
    } catch {
        return $false
    }
}

function Get-TuiConsoleWidth {
    try {
        if ([Console]::WindowWidth -gt 20) {
            return [Console]::WindowWidth
        }
    } catch {
    }

    return 100
}

function Write-TuiLine {
    param([string]$Line)

    $width = Get-TuiConsoleWidth
    if ($width -lt 2) {
        $width = 100
    }

    $text = [string]$Line
    if ($text.Length -gt ($width - 1)) {
        $text = $text.Substring(0, $width - 1)
    }

    Write-Host $text.PadRight($width - 1)
}

function Read-TuiMenuFallback {
    param(
        [string]$Title,
        [string[]]$Lines,
        [string[]]$Options,
        [int]$DefaultIndex = 0
    )

    Write-Host ""
    Write-Host $Title
    Write-Host ("=" * $Title.Length)
    foreach ($line in $Lines) {
        Write-Host $line
    }
    Write-Host ""
    for ($i = 0; $i -lt $Options.Count; $i++) {
        Write-Host ("  {0}. {1}" -f ($i + 1), $Options[$i])
    }

    while ($true) {
        $answer = Read-Host ("Choose [1-{0}] default {1}" -f $Options.Count, ($DefaultIndex + 1))
        if ([string]::IsNullOrWhiteSpace($answer)) {
            return $DefaultIndex
        }

        $choice = 0
        if ([int]::TryParse($answer.Trim(), [ref]$choice) -and $choice -ge 1 -and $choice -le $Options.Count) {
            return ($choice - 1)
        }

        Write-Host "Please enter a number from 1 to $($Options.Count)." -ForegroundColor Yellow
    }
}

function Read-TuiMenu {
    param(
        [string]$Title,
        [string[]]$Lines,
        [string[]]$Options,
        [int]$DefaultIndex = 0
    )

    if ($Options.Count -eq 0) {
        throw "TUI menu requires at least one option."
    }
    if ($DefaultIndex -lt 0 -or $DefaultIndex -ge $Options.Count) {
        $DefaultIndex = 0
    }
    if (-not (Test-TuiMenuSupported)) {
        return Read-TuiMenuFallback -Title $Title -Lines $Lines -Options $Options -DefaultIndex $DefaultIndex
    }

    try {
        $selected = $DefaultIndex
        $top = [Console]::CursorTop
        while ($true) {
            [Console]::SetCursorPosition(0, $top)
            Write-TuiLine ""
            Write-TuiLine $Title
            Write-TuiLine ("=" * $Title.Length)
            foreach ($line in $Lines) {
                Write-TuiLine $line
            }
            Write-TuiLine ""
            for ($i = 0; $i -lt $Options.Count; $i++) {
                $prefix = if ($i -eq $selected) { "  > " } else { "    " }
                Write-TuiLine "$prefix$($Options[$i])"
            }
            Write-TuiLine ""
            Write-TuiLine "Use Up/Down, Enter to select, Esc to cancel."

            $key = [Console]::ReadKey($true)
            switch ($key.Key) {
                "UpArrow" {
                    if ($selected -le 0) {
                        $selected = $Options.Count - 1
                    } else {
                        $selected--
                    }
                }
                "DownArrow" {
                    $selected = ($selected + 1) % $Options.Count
                }
                "Enter" {
                    return $selected
                }
                "Escape" {
                    return ($Options.Count - 1)
                }
            }
        }
    } catch {
        return Read-TuiMenuFallback -Title $Title -Lines $Lines -Options $Options -DefaultIndex $DefaultIndex
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

    $choice = Read-TuiMenu `
        -Title "MailSite 11 Uninstaller" `
        -Lines @(
            "Installed MailSite 11: $targetVersion",
            "Install directory:       $InstalledDirectory",
            "",
            "This will:",
            "  - Stop MailSite services",
            "  - Restore service paths to MailSite 10",
            "  - Remove MailSite 11 files",
            "  - Remove MailSite 11 firewall rules"
        ) `
        -Options @("Continue uninstall", "Cancel") `
        -DefaultIndex 1

    return ($choice -eq 0)
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
