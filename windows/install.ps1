# windows/install.ps1
# Package installation for Windows (scoop + winget)
# Run this script with PowerShell 7

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Write-Info {
    param([string]$Message)
    Write-Host "    $Message" -ForegroundColor Gray
}

# ============================================================
# 1. Install scoop (if not present)
# ============================================================
Write-Step "Checking scoop..."
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Info "Installing scoop..."
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
} else {
    Write-Info "scoop is already installed."
}

# Add required buckets
foreach ($bucket in @("main", "extras", "nerd-fonts", "versions")) {
    if (-not (scoop bucket list | Select-String $bucket)) {
        Write-Info "Adding scoop bucket: $bucket"
        scoop bucket add $bucket
    }
}

# ============================================================
# 2. Install packages via scoop
# ============================================================
Write-Step "Installing packages via scoop..."

$scoopPackages = @(
    # Shell / Terminal
    "wezterm"
    "pwsh"  # PowerShell 7 (latest)

    # Editor
    "neovim"

    # Version control
    "git"
    "gh"
    "lazygit"
    "delta"

    # Prompt
    "starship"

    # CLI tools
    "bat"
    "eza"
    "fd"
    "ripgrep"
    "fzf"
    "zoxide"
    "yazi"
    "jq"
    "bottom"
    "just"
    "direnv"

    # Languages
    "nodejs"
    "python"

    # Fonts (nerd fonts for dev icons)
    "JetBrains-Mono-NF"
)

foreach ($pkg in $scoopPackages) {
    $installed = scoop list | Select-String "^$pkg "
    if (-not $installed) {
        Write-Info "Installing $pkg..."
        scoop install $pkg
    } else {
        Write-Info "$pkg is already installed."
    }
}

# ============================================================
# 3. Install packages via winget (supplemental)
# ============================================================
Write-Step "Checking winget packages..."

$wingetPackages = @(
    # Windows Terminal
    @{ Id = "Microsoft.WindowsTerminal"; Source = "winget" }

    # OpenSSH Client
    @{ Id = "Microsoft.OpenSSH.Beta"; Source = "winget" }
)

foreach ($pkg in $wingetPackages) {
    $installed = winget list --exact --id $pkg.Id -s $pkg.Source 2>$null
    if (-not $installed) {
        Write-Info "Installing $($pkg.Id)..."
        winget install --exact --id $pkg.Id -s $pkg.Source --accept-package-agreements --accept-source-agreements
    } else {
        Write-Info "$($pkg.Id) is already installed."
    }
}

# ============================================================
# 4. Scoop global shims setup
# ============================================================
Write-Step "Ensuring scoop global shims..."
scoop config global 1>$null 2>$null

Write-Step "Package installation complete!"
