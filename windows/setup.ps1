# windows/setup.ps1
# Windows dotfiles bootstrap (PowerShell 7)
# Usage: pwsh -ExecutionPolicy RemoteSigned -File windows/setup.ps1
#
# Prerequisites:
#   - PowerShell 7+ (install via winget: winget install Microsoft.PowerShell)
#   - Windows 10 22H2+ or Windows 11
#   - Run as regular user (not admin, scoop works without admin)
#
# What it does:
#   1. Installs packages via scoop (primary) + winget (supplemental)
#   2. Symlinks shared config files to correct Windows paths
#   3. Installs PowerShell 7 profile
#   4. Links Windows Terminal settings

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host " $Message" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
}

Write-Step "Windows Dotfiles Setup"

# ----------------------------------------------------------
# 1. Install packages
# ----------------------------------------------------------
Write-Step "1/3: Installing packages"
& "$PSScriptRoot\install.ps1"

# ----------------------------------------------------------
# 2. Link config files
# ----------------------------------------------------------
Write-Step "2/3: Linking config files"
& "$PSScriptRoot\link.ps1"

# ----------------------------------------------------------
# 3. Install PowerShell profile
# ----------------------------------------------------------
Write-Step "3/3: Installing PowerShell profile"

$profileDir = Split-Path -Parent $PROFILE.CurrentUserAllHosts
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

$profileRepo = Join-Path $PSScriptRoot "Microsoft.PowerShell_profile.ps1"
if (Test-Path $PROFILE.CurrentUserAllHosts) {
    # Backup existing profile
    $backup = "$($PROFILE.CurrentUserAllHosts).backup"
    Copy-Item -Path $PROFILE.CurrentUserAllHosts -Destination $backup -Force
    Write-Host "    Backed up existing profile to: $backup" -ForegroundColor Gray
}

Copy-Item -Path $profileRepo -Destination $PROFILE.CurrentUserAllHosts -Force
Write-Host "    Installed PowerShell profile" -ForegroundColor Gray

# ----------------------------------------------------------
# Done
# ----------------------------------------------------------
Write-Step "Setup complete!"
Write-Host ""
Write-Host "  Restart PowerShell 7 to apply the profile."
Write-Host "  Run 'wezterm' to start the terminal (config already symlinked)."
Write-Host ""
Write-Host "  To update packages later:" -ForegroundColor Cyan
Write-Host "    scoop update && scoop update *" -ForegroundColor Gray
Write-Host ""
