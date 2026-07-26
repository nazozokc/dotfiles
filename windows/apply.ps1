#!/usr/bin/env pwsh
# windows/apply.ps1
# "nixos-rebuild switch" for Windows dotfiles.
#
# Reads config.psd1 and converges the system to the desired state:
#   1. Packages        — scoop / winget / PSModule
#   2. Symlinks        — config file symlinks
#   3. System settings — registry, features, power
#   4. Profile         — PowerShell profile deployment
#
# Usage: pwsh windows/apply.ps1
# Idempotent: safe to run repeatedly.

$ErrorActionPreference = "Stop"

$ScriptRoot = $PSScriptRoot
$RepoRoot = Split-Path $ScriptRoot -Parent

# ============================================================
# Color helpers
# ============================================================
function Write-Step { param([string]$M) Write-Host "`n==> $M" -ForegroundColor Cyan }
function Write-Info { param([string]$M) Write-Host "    $M" -ForegroundColor Gray }

# ============================================================
# 0. Resolve config
# ============================================================
$configPath = Join-Path $ScriptRoot "config.psd1"
if (-not (Test-Path $configPath)) {
    Write-Host "ERROR: config.psd1 not found at $configPath" -ForegroundColor Red
    Write-Host "Copy config.psd1 from the repo or create one." -ForegroundColor Red
    exit 1
}

Write-Step "Loading desired state from config.psd1..."
$config = Import-PowerShellDataFile -Path $configPath
Write-Info "Config loaded."

# ============================================================
# 1. Load modules
# ============================================================
$modulePaths = @(
    Join-Path $ScriptRoot "modules\PackageManager.psm1"
    Join-Path $ScriptRoot "modules\SymlinkManager.psm1"
    Join-Path $ScriptRoot "modules\ProfileManager.psm1"
    Join-Path $ScriptRoot "modules\SystemManager.psm1"
)

foreach ($mod in $modulePaths) {
    if (-not (Test-Path $mod)) {
        Write-Host "ERROR: Module not found: $mod" -ForegroundColor Red
        exit 1
    }
    Import-Module $mod -Force
}

# ============================================================
# 2. Converge packages
# ============================================================
Write-Step "Phase 1/3: Packages"
Invoke-PackageConverge -Config $config

# ============================================================
# 3. Converge symlinks
# ============================================================
Write-Step "Phase 2/3: Symlinks"
Invoke-LinkConverge -RepoRoot $RepoRoot -Config $config

# ============================================================
# 4. Converge Windows system settings
# ============================================================
Write-Step "Phase 4/4: Windows system settings"
Invoke-WindowsSystemConverge -Config $config

# ============================================================
# 5. Converge profile
# ============================================================
Write-Step "Phase 5/4: PowerShell profile"
Invoke-ProfileConverge -Config $config -ScriptRoot $ScriptRoot

# ============================================================
# 6. Done
# ============================================================
Write-Host ""
Write-Host "All systems converged." -ForegroundColor Green
Write-Host "Restart PowerShell to apply the new profile." -ForegroundColor DarkGray
Write-Host ""
