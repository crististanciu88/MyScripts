param (
    [string]$PackageId
)

# Function to check if the package is installed
function Is-PackageInstalled {
    param (
        [string]$PackageId
    )

    # Query the registry for the installed MSI packages
    $installedPackages = Get-WmiObject -Query "SELECT * FROM Win32_Product WHERE IdentifyingNumber = '$PackageId'" | Select-Object -Property IdentifyingNumber
    
    return $installedPackages -ne $null
}

# Function to uninstall the package
function Uninstall-Package {
    param (
        [string]$PackageId
    )

    Write-Host "Attempting to uninstall package with ID: $PackageId" -ForegroundColor Yellow
    $msiexecCommand = "msiexec.exe /x $PackageId /qn /norestart"

    # Execute the uninstall command
    $process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/x $PackageId /qn /norestart" -PassThru -Wait
    return $process.ExitCode
}

# Check if the PackageId is provided
if (-not $PackageId) {
    Write-Host "Error: Please provide a Package ID." -ForegroundColor Red
    exit 1
}

Write-Host "Checking for package with ID: $PackageId" -ForegroundColor Cyan

# Check if the package is installed
if (Is-PackageInstalled -PackageId $PackageId) {
    Write-Host "Package with ID $PackageId is installed." -ForegroundColor Green
    $exitCode = Uninstall-Package -PackageId $PackageId
    if ($exitCode -eq 0) {
        Write-Host "Successfully uninstalled package with ID: $PackageId" -ForegroundColor Green
    } else {
        Write-Host "Failed to uninstall package with ID: $PackageId. Exit Code: $exitCode" -ForegroundColor Red
    }
} else {
    Write-Host "Package with ID $PackageId is not installed." -ForegroundColor Yellow
}