# PowerShell 7 profile - dotfiles managed
# Symlinked to: ~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1

# ============================================================
# Environment variables
# ============================================================
$env:EDITOR = "nvim"
$env:VISUAL = "nvim"
$env:BROWSER = "wt"  # Windows Terminal can open URLs

# ============================================================
# Starship prompt
# ============================================================
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
    $ENV:STARSHIP_CONFIG = Join-Path $env:USERPROFILE ".config\starship.toml"
}

# ============================================================
# PSReadLine configuration
# ============================================================
Set-PSReadLineOption -EditMode Vi
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -Colors @{
    Command            = "Yellow"
    Parameter          = "Cyan"
    String             = "Green"
    Variable           = "Magenta"
    Operator           = "DarkYellow"
    Number             = "DarkCyan"
    Comment            = "DarkGray"
    ContinuationPrompt = "DarkGray"
}

# Vi mode indicators
Set-PSReadLineOption -ViModeIndicator Script
$script:ViMode = "NORMAL"
$script:ViModeHandler = {
    if ($host.UI.RawUI.KeyAvailable) { return }
    if ($viMode -eq "NORMAL") {
        $host.UI.RawUI.WindowTitle = "NORMAL"
    } else {
        $host.UI.RawUI.WindowTitle = ""
    }
}
Set-PSReadLineActionHandler -ViModeChange $script:ViModeHandler

# Ctrl+r: interactive history search
Set-PSReadLineKeyHandler -Key Ctrl+r -Function ReverseSearchHistory

# ============================================================
# Aliases
# ============================================================
# Quick navigation
function ..    { Set-Location .. }
function ...   { Set-Location ..\.. }
function ....  { Set-Location ..\..\.. }

# Directory listing
function la    { eza -la --icons --group-directories-first @args }
function ll    { eza -l --icons --group-directories-first @args }
function ls    { eza --icons --group-directories-first @args }
function lt    { eza -la --icons --tree --level=2 @args }

# Git aliases
function gs    { git status -sb }
function gd    { git diff }
function gl    { git log --oneline --graph --decorate --all }
function gp    { git push }
function gpl   { git pull }
function gc    { git commit -m @args }
function gca   { git commit --amend -m @args }
function gco   { git checkout @args }
function gcb   { git checkout -b @args }
function ga    { git add @args }
function gaa   { git add --all }
function gst   { git stash }
function gsta  { git stash apply }
function grs   { git reset @args }
function grh   { git reset HEAD~1 }

# Lazygit
function lg    { lazygit }

# File search
function ff    { fd @args }

# Text search
function rgf   { Select-String -Pattern @args }

# Quick edit
function nv    { nvim @args }

# Reload profile
function reload-profile { & $PROFILE }

# ============================================================
# Utility functions
# ============================================================
# Open file in neovim with line number
function nvim-ln {
    param([string]$File, [int]$Line = 0)
    if ($Line -gt 0) {
        nvim "+$Line" $File
    } else {
        nvim $File
    }
}
Set-Alias -Name nvl -Value nvim-ln

# Find in files (ripgrep wrapper)
function grep {
    param([string]$Pattern, [string]$Path = ".")
    rg $Pattern $Path
}

# Quick note taking
function note {
    param([string]$Message)
    $date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $noteDir = Join-Path $env:USERPROFILE "notes"
    if (-not (Test-Path $noteDir)) {
        New-Item -ItemType Directory -Path $noteDir -Force | Out-Null
    }
    $noteFile = Join-Path $noteDir "notes.md"
    "[$date] $Message" | Out-File -FilePath $noteFile -Append
    Write-Host "Note saved to $noteFile" -ForegroundColor Green
}

# ============================================================
# Environment setup
# ============================================================
# Add local bin to PATH
$localBin = Join-Path $env:USERPROFILE ".local\bin"
if (Test-Path $localBin) {
    $env:PATH = "$localBin;$env:PATH"
}

# Scoop shims
$scoopShims = Join-Path $env:USERPROFILE "scoop\shims"
if (Test-Path $scoopShims) {
    $env:PATH = "$scoopShims;$env:PATH"
}
