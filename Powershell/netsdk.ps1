# Admin check (optional but recommended)
$scriptPath = $MyInvocation.MyCommand.Path
if (-not (Test-Path $scriptPath)) {
    $scriptPath = (Join-Path -Path $PSScriptRoot -ChildPath $MyInvocation.MyCommand.Name)
}
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "This script should be run as Administrator. Relaunching as admin..."
    Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
    exit
}

# Helper: Find installed software by display name patterns
function Get-InstalledSoftware {
    param(
        [string[]]$DisplayNamePatterns
    )

    $uninstallKeys = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    $results = @()
    foreach ($path in $uninstallKeys) {
        try {
            Get-ItemProperty -Path $path -ErrorAction SilentlyContinue | ForEach-Object {
                $name = $_.DisplayName
                if ($null -ne $name -and $DisplayNamePatterns -and $name) {
                    foreach ($pattern in $DisplayNamePatterns) {
                        if ($name -like $pattern) {
                            $results += [pscustomobject]@{
                                DisplayName     = $name
                                UninstallString = $_.UninstallString
                            }
                            break
                        }
                    }
                }
            }
        } catch {
            # Ignore missing path errors
        }
    }
    return $results
}

# Helper: Uninstall a single item using its UninstallString
function Uninstall-SoftwareItem {
    param(
        [pscustomobject]$Item
    )
    if (-not $Item) { return }
    if (-not $Item.UninstallString) {
        Write-Host "No uninstall string found for '$($Item.DisplayName)'. Skipping." -ForegroundColor Yellow
        return
    }

    $uninstallString = $Item.UninstallString
    Write-Host "Uninstalling: $($Item.DisplayName)" -ForegroundColor Cyan

    try {
        # Use cmd /c to execute the uninstall string as-is (handles MSIExec and other uninstallers)
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$uninstallString`"" -Wait -NoNewWindow
        Write-Host "Uninstall command issued for: $($Item.DisplayName)" -ForegroundColor Green
    } catch {
        Write-Error "Failed to uninstall '$($Item.DisplayName)': $_"
    }
}

# 1) .NET Core Windows Server Hosting 6.0
function Uninstall-NetCoreWindowsServerHosting6 {
    $patterns = @(
        "ASP.NET Core Windows Server Hosting 6.0",
        "ASP.NET Core Windows Server Hosting 6.0*",
        "ASP.NET Core Windows Server Hosting 6.*"
    )
    $items = Get-InstalledSoftware -DisplayNamePatterns $patterns
    foreach ($item in $items) {
        try {
            Uninstall-SoftwareItem -Item $item
        } catch {
            Write-Error "Error uninstalling '$($item.DisplayName)': $_"
        }
    }
}

# 2) .NET Runtime 6.0
function Uninstall-NetRuntime6 {
    $patterns = @(
        "*NET Runtime 6.0*",
        "*NET 6.0 Runtime*",
        "*Microsoft .NET Runtime 6.0*",
        "*NET Runtime 6.*" # broader catch-all
    )
    $items = Get-InstalledSoftware -DisplayNamePatterns $patterns
    foreach ($item in $items) {
        try {
            Uninstall-SoftwareItem -Item $item
        } catch {
            Write-Error "Error uninstalling '$($item.DisplayName)': $_"
        }
    }
}

# 3) .NET SDK 3.1
function Uninstall-NetSDK31 {
    $patterns = @(
        "*NET SDK 3.1*",
        "*NET Core SDK 3.1*",
        "*Microsoft .NET SDK 3.1*",
        "*NET SDK 3.1.*"
    )
    $items = Get-InstalledSoftware -DisplayNamePatterns $patterns
    foreach ($item in $items) {
        try {
            Uninstall-SoftwareItem -Item $item
        } catch {
            Write-Error "Error uninstalling '$($item.DisplayName)': $_"
        }
    }
}

# 4) ASP.NET Core 6.0
function Uninstall-AspNetCore6 {
    $patterns = @(
        "*ASP.NET Core 6.0*",
        "*ASP.NET Core 6.0.*",
        "*ASP.NET Core 6.*"
    )
    $items = Get-InstalledSoftware -DisplayNamePatterns $patterns
    foreach ($item in $items) {
        try {
            Uninstall-SoftwareItem -Item $item
        } catch {
            Write-Error "Error uninstalling '$($item.DisplayName)': $_"
        }
    }
}

# Main execution (uncomment the ones you want to run)
# Uninstall-NetCoreWindowsServerHosting6
# Uninstall-NetRuntime6
# Uninstall-NetSDK31
# Uninstall-AspNetCore6

# Optional: Informational footer
# Note: If a reboot is required, the script will not automatically reboot. You may need to reboot manually.
