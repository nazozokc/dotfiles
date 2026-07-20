# windows/link.ps1
# Symlink shared config files to Windows paths
# Run this from the dotfiles repository root

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Write-Info {
    param([string]$Message)
    Write-Host "    $Message" -ForegroundColor Gray
}

function New-Symlink {
    param(
        [string]$Target,  # Where the symlink points to (repo file)
        [string]$Link     # Where the symlink is created (system path)
    )

    $targetFull = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Target)
    $linkFull = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Link)

    # Create parent directory if needed
    $parentDir = Split-Path $linkFull -Parent
    if (-not (Test-Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
        Write-Info "Created directory: $parentDir"
    }

    # Remove existing file/directory/symlink at target
    if (Test-Path $linkFull) {
        Remove-Item -Path $linkFull -Recurse -Force -ErrorAction SilentlyContinue
        Write-Info "Removed existing: $linkFull"
    }

    # Create directory symlink or file symlink
    $itemType = if (Test-Path $targetFull -PathType Container) { "Directory" } else { "File" }
    New-Item -ItemType SymbolicLink -Path $linkFull -Target $targetFull -Force | Out-Null
    Write-Info "Linked $linkFull -> $targetFull ($itemType)"
}

# Repo root (script location parent, assuming repo/is checked out as dotfiles)
$RepoRoot = Split-Path -Parent $PSScriptRoot

# ============================================================
# Config paths mapping
# ============================================================
Write-Step "Linking shared config files..."

# Tools that use ~/.config/ (same as Unix)
$xdgConfigLinks = @{
    "starship/starship.toml" = "~/.config/starship.toml"
    "bat/config"             = "~/.config/bat/config"
    "wezterm"                = "~/.config/wezterm"
}

foreach ($kv in $xdgConfigLinks.GetEnumerator()) {
    $repoPath = Join-Path $RepoRoot $kv.Key
    $systemPath = [System.Environment]::ExpandEnvironmentVariables($kv.Value)
    New-Symlink -Target $repoPath -Link $systemPath
}

# Git config (git reads ~\.config\git\config on Windows too)
$gitLinks = @{
    "git/config"   = "~/.config/git/config"
    "git/aliases"  = "~/.config/git/aliases"
    "git/ignore"   = "~/.config/git/ignore"
}

foreach ($kv in $gitLinks.GetEnumerator()) {
    $repoPath = Join-Path $RepoRoot $kv.Key
    $systemPath = [System.Environment]::ExpandEnvironmentVariables($kv.Value)
    New-Symlink -Target $repoPath -Link $systemPath
}

# Neovim (%LOCALAPPDATA%\nvim)
$nvimRepo = Join-Path $RepoRoot "nvim"
$nvimLink = Join-Path $env:LOCALAPPDATA "nvim"
New-Symlink -Target $nvimRepo -Link $nvimLink

# Lazygit (%APPDATA%\lazygit\config.yml)
$lazygitRepo = Join-Path $RepoRoot "lazygit" "config.yml"
$lazygitLink = Join-Path $env:APPDATA "lazygit" "config.yml"
New-Symlink -Target $lazygitRepo -Link $lazygitLink

# My scripts
$scriptsRepo = Join-Path $RepoRoot "my_scripts"
$scriptsLink = Join-Path $env:USERPROFILE ".scripts"
New-Symlink -Target $scriptsRepo -Link $scriptsLink

Write-Step "Config file linking complete!"
