# Targets to look for
$targets = ".NET 3.1",".ASPNET 3.1",".NET 6.0"

# Helper to test a string against any target (case-insensitive)
function MatchesTarget($s){
    if (-not $s) { return $false }
    $targets | ForEach-Object {
        if ($s -imatch [regex]::Escape($_)) { return $true }
    }
    return $false
}

# 1) Check uninstall registry entries (32/64-bit and current user)
$uninstallRoots = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall',
    'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall'
)
"--- Registry: Uninstall keys ---"
foreach ($root in $uninstallRoots) {
    try {
        Get-ChildItem -Path $root -ErrorAction Stop | ForEach-Object {
            $props = Get-ItemProperty -Path $_.PSPath -ErrorAction SilentlyContinue
            $display = $props.DisplayName
            if (MatchesTarget $display) {
                [PSCustomObject]@{
                    Root = $root
                    Key  = $_.PSChildName
                    DisplayName = $display
                    DisplayVersion = $props.DisplayVersion
                    Publisher = $props.Publisher
                }
            }
        }
    } catch { }
}

# 2) Check dotnet-specific install keys
"--- Registry: dotnet setup keys ---"
$dotnetKeys = @(
    'HKLM:\SOFTWARE\dotnet\Setup\InstalledVersions',
    'HKLM:\SOFTWARE\WOW6432Node\dotnet\Setup\InstalledVersions'
)
foreach ($k in $dotnetKeys) {
    try {
        Get-ChildItem -Path $k -Recurse -ErrorAction Stop | ForEach-Object {
            $full = $_.PSPath
            if (MatchesTarget $full -or MatchesTarget $_.Name) {
                [PSCustomObject]@{ KeyPath = $full }
            }
        }
    } catch { }
}

# 3) Look for dotnet/aspnet folders (Program Files / user profile)
"--- File system: common folders ---"
$pathsToCheck = @(
    "$env:ProgramFiles\dotnet",
    "$env:ProgramFiles(x86)\dotnet",
    "$env:ProgramFiles\asp.net",
    "$env:ProgramFiles\dotnet\shared",
    "$env:LOCALAPPDATA\Microsoft\dotnet"
)
foreach ($p in $pathsToCheck) {
    if (Test-Path $p) {
        Get-ChildItem $p -Force -ErrorAction SilentlyContinue | Select-Object @{n='Path';e={$p}}, Name, Mode
    }
}

# 4) dotnet executable and versions (in PATH)
"--- Commands / dotnet.exe ---"
Get-Command dotnet -ErrorAction SilentlyContinue | Select-Object Name,Source,Version
# Also search PATH directories for executables matching targets
($env:PATH -split ';' | Select-Object -Unique) | ForEach-Object {
    $dir = $_.Trim()
    if (-not [string]::IsNullOrWhiteSpace($dir) -and (Test-Path $dir)) {
        Get-ChildItem -Path $dir -Filter "*dotnet*.exe" -ErrorAction SilentlyContinue |
            ForEach-Object { [PSCustomObject]@{ Path=$_.FullName; Size=$_.Length } }
    }
}

# 5) Services and scheduled tasks that mention targets
"--- Services ---"
Get-Service | Where-Object { MatchesTarget $_.Name -or MatchesTarget $_.DisplayName } | Select-Object Name, DisplayName, Status

"--- Scheduled Tasks ---"
try {
    Get-ScheduledTask -ErrorAction Stop | Where-Object { MatchesTarget $_.TaskName -or MatchesTarget $_.TaskPath } | Select-Object TaskName, TaskPath
} catch { "Get-ScheduledTask not available / no permission." }

# 6) Quick registry-wide search for target strings (caution: can be slow)
"--- Registry: quick search under HKLM and HKCU (may take time) ---"
$roots = 'HKLM:\','HKCU:\'
foreach ($r in $roots) {
    try {
        Get-ChildItem -Path $r -Recurse -ErrorAction SilentlyContinue |
            Where-Object { MatchesTarget $_.Name } |
            Select-Object PSPath -First 50
    } catch { }
}
