# PackageManager.psm1
# Declarative package convergence for Windows (scoop + winget + PSModule)

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
function Invoke-PackageConverge {
    param($Config)

    $packages = $Config.Packages
    $system = $Config.System

    if (-not $packages) {
        Write-Warn "No Packages section in config. Skipping."
        return
    }

    # 1. Ensure scoop
    Ensure-Scoop

    # 2. Add buckets
    foreach ($bucket in $system.ScoopBuckets) {
        Ensure-ScoopBucket -Bucket $bucket
    }

    # 3. Install scoop packages
    if ($packages.Scoop) {
        Write-Step "Converging scoop packages..."
        foreach ($pkg in $packages.Scoop) {
            Install-ScoopPackage -Name $pkg
        }
    }

    # 4. Install winget packages
    if ($packages.Winget) {
        Write-Step "Converging winget packages..."
        foreach ($pkg in $packages.Winget) {
            Install-WingetPackage -Id $pkg.Id -Source $pkg.Source
        }
    }

    # 5. Install PS modules
    if ($packages.PSModule) {
        Write-Step "Converging PowerShell modules..."
        Ensure-PSGallery
        foreach ($mod in $packages.PSModule) {
            Install-PSModule -Name $mod.Name -MinimumVersion $mod.MinimumVersion
        }
    }

    # 6. Scoop global shims
    if ($system.ScoopGlobalShims) {
        Write-Step "Ensuring scoop global shims..."
        scoop config global 1>$null 2>$null
    }
}

# ============================================================
# Scoop
# ============================================================
function Ensure-Scoop {
    Write-Step "Checking scoop..."
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Info "Installing scoop..."
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
    } else {
        Write-Skip "scoop is already installed."
    }
}

function Ensure-ScoopBucket {
    param([string]$Bucket)

    $buckets = scoop bucket list 2>$null | ForEach-Object { ($_ -split '\s+')[0] }
    if ($buckets -notcontains $Bucket) {
        Write-Info "Adding scoop bucket: $Bucket"
        scoop bucket add $Bucket
    } else {
        Write-Skip "scoop bucket '$Bucket' already exists."
    }
}

function Install-ScoopPackage {
    param([string]$Name)

    $installed = scoop list 2>$null | Select-String "^$Name "
    if (-not $installed) {
        Write-Info "Installing $Name..."
        scoop install $Name --no-update-scoop
    } else {
        Write-Skip "$Name is already installed."
    }
}

# ============================================================
# Winget
# ============================================================
function Install-WingetPackage {
    param([string]$Id, [string]$Source)

    $installed = winget list --exact --id $Id -s $Source 2>$null
    if (-not $installed -or $LASTEXITCODE -ne 0) {
        Write-Info "Installing $Id..."
        winget install --exact --id $Id -s $Source --accept-package-agreements --accept-source-agreements
    } else {
        Write-Skip "$Id is already installed."
    }
}

# ============================================================
# PowerShell Gallery
# ============================================================
function Ensure-PSGallery {
    if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
        Write-Info "Installing NuGet package provider..."
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser
    }

    if ((Get-PSRepository -Name PSGallery).InstallationPolicy -ne 'Trusted') {
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    }
}

function Install-PSModule {
    param([string]$Name, [string]$MinimumVersion)

    $installed = Get-Module -ListAvailable -Name $Name |
        Where-Object { $_.Version -ge [version]$MinimumVersion }
    if (-not $installed) {
        Write-Info "Installing PowerShell module: $Name..."
        Install-Module -Name $Name -MinimumVersion $MinimumVersion -Scope CurrentUser -Force -AllowClobber
    } else {
        Write-Skip "PowerShell module '$Name' $MinimumVersion+ is already installed."
    }
}

Export-ModuleMember -Function Invoke-PackageConverge
