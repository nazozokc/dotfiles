# ProfileManager.psm1
# Declarative PowerShell profile convergence

function Write-Step {
    param([string]$Message)
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Write-Info {
    param([string]$Message)
    Write-Host "    $Message" -ForegroundColor Gray
}

function Write-Warn {
    param([string]$Message)
    Write-Host "    [!] $Message" -ForegroundColor Yellow
}

function Write-Skip {
    param([string]$Message)
    Write-Host "    ~ $Message" -ForegroundColor DarkGray
}

# ============================================================
# Entry point
# ============================================================
function Invoke-ProfileConverge {
    param(
        $Config,
        [string]$ScriptRoot
    )

    $profileCfg = $Config.Profile
    if (-not $profileCfg -or -not $profileCfg.Enabled) {
        Write-Skip "Profile management is disabled in config."
        return
    }

    $profilePaths = $profileCfg.Paths
    if (-not $profilePaths) {
        Write-Warn "No Profile.Paths defined in config. Skipping."
        return
    }

    $sourceProfile = Join-Path $ScriptRoot "Microsoft.PowerShell_profile.ps1"
    if (-not (Test-Path $sourceProfile)) {
        Write-Warn "Profile source not found: $sourceProfile"
        return
    }

    Write-Step "Converging PowerShell profiles..."

    foreach ($destPattern in $profilePaths) {
        $destPath = [System.Environment]::ExpandEnvironmentVariables($destPattern)
        Install-ProfileFile -Source $sourceProfile -Destination $destPath
    }
}

# ============================================================
# Profile file installation
# ============================================================
function Install-ProfileFile {
    param(
        [string]$Source,
        [string]$Destination
    )

    $label = Split-Path (Split-Path $Destination -Parent) -Leaf

    # Create parent directory
    $parentDir = Split-Path $Destination -Parent
    if (-not (Test-Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
        Write-Info "[$label] Created directory: $parentDir"
    }

    # Check if already up-to-date
    if (Test-Path $Destination) {
        $srcHash = Get-FileHash $Source -Algorithm MD5
        $dstHash = Get-FileHash $Destination -Algorithm MD5
        if ($srcHash.Hash -eq $dstHash.Hash) {
            Write-Skip "[$label] Profile already up-to-date."
            return
        }

        # Backup
        $backup = "$Destination.backup"
        Copy-Item -Path $Destination -Destination $backup -Force
        Write-Info "[$label] Backed up existing profile to: $backup"
    }

    Copy-Item -Path $Source -Destination $Destination -Force
    Write-Info "[$label] Installed profile"
}

Export-ModuleMember -Function Invoke-ProfileConverge
