#===============================================================================
# Bulk-Regex-Replace.ps1
#===============================================================================
[CmdletBinding()]
param(
    # Optional: switch to force overwrite without prompting
    [switch] $Force
)

# Define your replacement list here.
# Path     = full path to the file
# OldValue = regex pattern to search for
# NewValue = replacement text
$replacements = @(
    [PSCustomObject]@{
        Path     = 'C:\MyConfigs\app.config'
        OldValue = '\\rootpath\\test\\oldvalue'
        NewValue = '\\test\\path\\newvalue'
    },
    [PSCustomObject]@{
        Path     = 'C:\Scripts\start.bat'
        OldValue = '\\\\legacyserver\\share'
        NewValue = '\\newserver\share'
    }
    # â¦ add more entries here â¦
)

foreach ($entry in $replacements) {
    $file = $entry.Path
    $old  = $entry.OldValue
    $new  = $entry.NewValue

    Write-Host "-------------------------------"
    Write-Host "File     : $file"
    Write-Host "Pattern  : $old"
    Write-Host "Replace  : $new"
    if (-not (Test-Path $file)) {
        Write-Warning "File not found, skipping."
        continue
    }

    try {
        # Read entire file as single string
        $text = Get-Content -Path $file -Raw -ErrorAction Stop

        # Count matches
        $matches = [regex]::Matches($text, $old)
        if ($matches.Count -eq 0) {
            Write-Host "No matches found." -ForegroundColor Yellow
            continue
        }

        Write-Host "Matches found: $($matches.Count)" -ForegroundColor Green

        # Perform the replacement
        $newText = [regex]::Replace($text, $old, $new)

        # Backup original?
        $backup = "$file.bak"
        if (-not (Test-Path $backup) -or $Force) {
            Copy-Item -Path $file -Destination $backup -Force:$Force
            Write-Host "Backup saved to: $backup"
        } else {
            Write-Host "Backup already exists: $backup" -ForegroundColor DarkYellow
        }

        # Write the modified content back
        Set-Content -Path $file -Value $newText -Encoding UTF8
        Write-Host "File updated successfully." -ForegroundColor Green
    }
    catch {
        Write-Error "Error processing $file : $_"
    }
}
Write-Host "All done." -ForegroundColor Cyan
