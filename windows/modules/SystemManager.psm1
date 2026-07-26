# SystemManager.psm1
# Windows system-level settings convergence (registry, features, power)
# Some operations require elevation (admin rights).

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
function Invoke-WindowsSystemConverge {
    param($Config)

    $sys = $Config.WindowsSystem
    if (-not $sys) {
        Write-Skip "No WindowsSystem section in config. Skipping."
        return
    }

    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Warn "Not running as administrator."
        Write-Warn "  Registry and Feature changes require elevation."
        Write-Warn "  Restart with: Start-Process pwsh -Verb RunAs -Args '-File $PSCommandPath'"
    }

    # 1. Registry settings
    if ($sys.Registry) {
        Write-Step "Converging registry settings..."
        foreach ($entry in $sys.Registry) {
            Set-RegistryValue -Path $entry.Path -Name $entry.Name -Value $entry.Value -Type $entry.Type
        }
    }

    # 2. Windows Features
    if ($sys.Features) {
        Write-Step "Converging Windows Features..."
        if (-not $isAdmin) {
            Write-Warn "  Skipping Features — admin required."
        } else {
            foreach ($feature in $sys.Features) {
                Enable-WindowsFeature -Name $feature
            }
        }
    }

    # 3. Power settings
    if ($sys.Power) {
        Write-Step "Converging power settings..."
        if (-not $isAdmin) {
            Write-Warn "  Skipping Power settings — admin required."
        } else {
            Set-PowerSetting -Config $sys.Power
        }
    }
}

# ============================================================
# Registry
# ============================================================
function Set-RegistryValue {
    param(
        [string]$Path,
        [string]$Name,
        $Value,
        [string]$Type = 'DWord'
    )

    # Ensure parent key exists
    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }

    # Check current value
    $current = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
    if ($current -and $current.$Name -eq $Value) {
        Write-Skip "Registry $Path\$Name already set to $Value."
        return
    }

    try {
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -ErrorAction Stop
        Write-Info "Registry $Path\$Name → $Value ($Type)"
    } catch {
        Write-Warn "Failed to set registry $Path\$Name : $_"
    }
}

# ============================================================
# Windows Features
# ============================================================
function Enable-WindowsFeature {
    param([string]$Name)

    # Check if already enabled
    $feature = Get-WindowsOptionalFeature -Online -FeatureName $Name -ErrorAction SilentlyContinue
    if (-not $feature) {
        Write-Warn "Feature '$Name' not found on this system."
        return
    }

    if ($feature.State -eq 'Enabled') {
        Write-Skip "Feature '$Name' is already enabled."
        return
    }

    Write-Info "Enabling Windows Feature: $Name..."
    Enable-WindowsOptionalFeature -Online -FeatureName $Name -NoRestart -ErrorAction Stop
    Write-Info "  Enabled. You may need to restart."
}

# ============================================================
# Power settings (via powercfg)
# ============================================================
function Set-PowerSetting {
    param($Config)

    $map = @{
        SleepTimeout    = @{ Scheme = 'SCHEME_CURRENT'; Subgroup = 'SUB_SLEEP'; Setting = 'STANDBYIDLE' }
        DisplayTimeout  = @{ Scheme = 'SCHEME_CURRENT'; Subgroup = 'SUB_VIDEO'; Setting = 'VIDEOIDLE' }
        HibernateTimeout = @{ Scheme = 'SCHEME_CURRENT'; Subgroup = 'SUB_SLEEP'; Setting = 'HIBERNATEIDLE' }
    }

    foreach ($key in $Config.Keys) {
        if (-not $map.ContainsKey($key)) {
            Write-Skip "Unknown power setting: $key"
            continue
        }
        $m = $map[$key]
        $value = $Config.$key

        # powercfg expects minutes in decimal
        $current = powercfg /q $m.Scheme $m.Subgroup $m.Setting 2>$null
        # Check if already set (simple string match — powercfg output is locale-dependent)
        # Skip the check for now and just apply
        Write-Info "Setting powercfg $($m.Subgroup)\$($m.Setting) = $value min..."
        powercfg /change "$($m.Setting)" $value 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Info "  Power setting $key set to $value min."
        } else {
            Write-Warn "  Failed to set power setting $key. Try running as admin."
        }
    }
}

Export-ModuleMember -Function Invoke-WindowsSystemConverge
