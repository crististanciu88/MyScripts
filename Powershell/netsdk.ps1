# Logging helpers
function Get-LogPath {
    $dir = "C:\Temp"
    if (-not (Test-Path $dir)) {
        New-Item -Path $dir -ItemType Directory -Force | Out-Null
    }
    $dateHour = Get-Date -Format "yyyyMMddHH"
    return Join-Path -Path $dir -ChildPath ("script." + $dateHour + ".log")
}

function Add-Log {
    param(
        [Parameter(Mandatory = $true)][string]$Message
    )
    $logPath = Get-LogPath
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$timestamp] $Message"
    Add-Content -Path $logPath -Value $line
}

# Discover installed software from registry uninstall entries
function Get-InstalledSoftware {
    param(
        [Parameter(Mandatory = $true)][string]$NamePattern
    )
    $registries = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
    )

    $results = @()
    foreach ($path in $registries) {
        if (Test-Path $path) {
            Get-ItemProperty -Path "$path\*" -ErrorAction SilentlyContinue | ForEach-Object {
                if ($_.DisplayName -and $_.DisplayName -like "*$NamePattern*") {
                    $results += [pscustomobject]@{
                        DisplayName        = $_.DisplayName
                        UninstallString    = $_.UninstallString
                        QuietUninstallString = $_.QuietUninstallString
                    }
                }
            }
        }
    }
    return $results
}

# Uninstall helper using uninstall command from registry
function Uninstall-FromString {
    param(
        [Parameter(Mandatory = $true)][string]$UninstallString
    )
    if (-not $UninstallString) { return $false }
    try {
        # Use cmd.exe to execute the uninstall command string
        $proc = Start-Process -FilePath "cmd.exe" -ArgumentList "/c", $UninstallString -Wait -PassThru -WindowStyle Hidden
        if ($proc.ExitCode -eq 0) { return $true } else { return $false }
    } catch {
        return $false
    }
}

# Generic writer for whether a component is present and uninstall it
function Uninstall-IfPresent {
    param(
        [Parameter(Mandatory = $true)][string]$DisplayNamePattern,
        [Parameter(Mandatory = $true)][string]$FriendlyName
    )
    try {
        Add-Log "Checking for $FriendlyName..."
        $apps = Get-InstalledSoftware -NamePattern $DisplayNamePattern
        if ($apps -and $apps.Count -gt 0) {
            foreach ($app in $apps) {
                Add-Log "Found: $($app.DisplayName). Attempting uninstall..."
                $uninstallCmd = $app.UninstallString
                if (-not $uninstallCmd) {
                    Add-Log "No UninstallString found for $($app.DisplayName). Skipping."
                    continue
                }
                $success = Uninstall-FromString -UninstallString $uninstallCmd
                if ($success) {
                    Add-Log "Successfully uninstalled: $($app.DisplayName)"
                } else {
                    Add-Log "Failed to uninstall: $($app.DisplayName)"
                }
            }
        } else {
            Add-Log "Not found: $FriendlyName"
        }
    } catch {
        Add-Log "Error while uninstalling $FriendlyName: $_"
    }
}

# 1) .NET Core Windows Server Hosting 6.0
function Uninstall-NETCoreHosting6 {
    # Pattern should match the installed DisplayName. Adjust if necessary.
    Uninstall-IfPresent -DisplayNamePattern "*Microsoft .NET Core Windows Server Hosting 6.0*" -FriendlyName ".NET Core Windows Server Hosting 6.0"
}

# 2) .NET Runtime 6.0
function Uninstall-NETRuntime6 {
    Uninstall-IfPresent -DisplayNamePattern "*Microsoft .NET Runtime 6.0*" -FriendlyName ".NET Runtime 6.0"
}

# 3) .NET SDK 3.1
function Uninstall-NETSDK31 {
    Uninstall-IfPresent -DisplayNamePattern "*Microsoft .NET SDK 3.1*" -FriendlyName ".NET SDK 3.1"
}

# 4) ASP.NET Core 6.0
function Uninstall-ASPNETCore6 {
    Uninstall-IfPresent -DisplayNamePattern "*ASP.NET Core 6.0*" -FriendlyName "ASP.NET Core 6.0"
}

# Example usage (uncomment to run):
# Uninstall-NETCoreHosting6
# Uninstall-NETRuntime6
# Uninstall-NETSDK31
# Uninstall-ASPNETCore6

# End of script
