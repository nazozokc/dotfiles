# windows/setup.ps1
# Windows dotfiles bootstrap (PowerShell 7)
# Usage: pwsh -ExecutionPolicy RemoteSigned -File windows/setup.ps1
#
# Prerequisites:
#   - PowerShell 7+ (install via winget: winget install Microsoft.PowerShell)
#   - Windows 10 22H2+ or Windows 11
#   - Run as regular user (not admin; scoop works without admin)
#
# What it does:
#   Delegates to apply.ps1 which reads config.psd1 and converges:
#     1. Installs packages via scoop / winget / PSGallery
#     2. Symlinks shared config files to correct Windows paths
#     3. Installs PowerShell profile (PS7 + PS5)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host " Windows Dotfiles Setup" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

& "$PSScriptRoot\apply.ps1"

Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host " Setup complete!" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "  To update packages later:" -ForegroundColor Cyan
Write-Host "    pwsh windows/apply.ps1" -ForegroundColor Gray
Write-Host "    scoop update && scoop update *" -ForegroundColor Gray
Write-Host "    winget upgrade --all" -ForegroundColor Gray
Write-Host "    Update-Module" -ForegroundColor Gray
Write-Host ""
