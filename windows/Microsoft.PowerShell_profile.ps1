# PowerShell profile (PS7 + PS5 compatible)
# Maintained in: <dotfiles>/windows/Microsoft.PowerShell_profile.ps1
# Symlinked to: ~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1  (PS7)
#                ~\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1  (PS5)

# ============================================================
# PS version detection
# ============================================================
$isPS7 = $PSVersionTable.PSVersion.Major -ge 7

# ============================================================
# Environment variables
# ============================================================
$env:EDITOR = "nvim"
$env:VISUAL = "nvim"

# ============================================================
# PATH setup (before anything that uses these tools)
# ============================================================
# Scoop shims
$scoopShims = Join-Path $env:USERPROFILE "scoop\shims"
if (Test-Path $scoopShims) { $env:PATH = "$scoopShims;$env:PATH" }

# Local bin
$localBin = Join-Path $env:USERPROFILE ".local\bin"
if (Test-Path $localBin) { $env:PATH = "$localBin;$env:PATH" }

# ============================================================
# Prompt (Starship)
# ============================================================
if (Get-Command starship -ErrorAction SilentlyContinue) {
    $env:STARSHIP_CONFIG = Join-Path $env:USERPROFILE ".config\starship.toml"
    Invoke-Expression (&starship init powershell)
}

# ============================================================
# PSReadLine configuration
# ============================================================
Set-PSReadLineOption -EditMode Vi
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

# PS7+: prediction / IntelliSense
if ($isPS7) {
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
}

# Vi mode indicator in window title
Set-PSReadLineOption -ViModeIndicator Script
$script:ViModeHandler = {
    param($Mode)
    if ($Mode -eq [Microsoft.PowerShell.ViMode]::Normal) {
        $host.UI.RawUI.WindowTitle = "NORMAL"
    } else {
        $host.UI.RawUI.WindowTitle = ""
    }
}
Set-PSReadLineOption -ViModeChangeHandler $script:ViModeHandler

# ============================================================
# zoxide (smart directory jumping)
# ============================================================
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { $(zoxide init powershell | Out-String) })
}

# ============================================================
# PSFzf (fuzzy finder integration)
# ============================================================
# Overrides default Ctrl+r and Ctrl+t if module is installed
if (Get-Module -ListAvailable -Name PSFzf) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadLineChordProvider 'Ctrl+t' -PSReadLineChordReverseHistory 'Ctrl+r'
    Set-PsFzfOption -TabExpansion
}

# Fallback: if PSFzf is not installed, use basic Ctrl+r
else {
    Set-PSReadLineKeyHandler -Key Ctrl+r -Function ReverseSearchHistory
}

# ============================================================
# Terminal-Icons (file icon rendering in ls/Get-ChildItem)
# ============================================================
if (Get-Module -ListAvailable -Name Terminal-Icons) {
    Import-Module Terminal-Icons
}

# ============================================================
# Aliases
# ============================================================

# Quick navigation
function ..    { Set-Location .. }
function ...   { Set-Location ..\.. }
function ....  { Set-Location ..\..\.. }

# Directory listing (eza)
if (Get-Command eza -ErrorAction SilentlyContinue) {
    function la    { eza -la --icons --group-directories-first @args }
    function ll    { eza -l --icons --group-directories-first @args }
    function ls    { eza --icons --group-directories-first @args }
    function lt    { eza -la --icons --tree --level=2 @args }
} else {
    # Fallback if eza is not installed (e.g. bootstrap phase)
    function la    { Get-ChildItem -Force @args }
    function ll    { Get-ChildItem -Force @args | Format-Table -AutoSize }
    function lt    { Get-ChildItem -Recurse -Depth 2 -Force @args }
}

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

# Text search (ripgrep wrapper)
function grep  { rg @args }

# Quick edit
function nv    { nvim @args }

# Reload profile
function reload-profile { & $PROFILE }

# ============================================================
# Utility functions
# ============================================================

# Open file in neovim with optional line number
function nvim-ln {
    param([string]$File, [int]$Line = 0)
    if ($Line -gt 0) {
        nvim "+$Line" $File
    } else {
        nvim $File
    }
}
Set-Alias -Name nvl -Value nvim-ln

# Quick note taking (appends timestamped line to ~/notes/notes.md)
function note {
    param([string]$Message)
    $date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $noteDir = Join-Path $env:USERPROFILE "notes"
    if (-not (Test-Path $noteDir)) {
        New-Item -ItemType Directory -Path $noteDir -Force | Out-Null
    }
    $noteFile = Join-Path $noteDir "notes.md"
    "[$date] $Message" | Out-File -FilePath $noteFile -Append -Encoding utf8
    Write-Host "Note saved to $noteFile" -ForegroundColor Green
}

# Which command (shows path of a command)
function which {
    param([string]$Command)
    $result = Get-Command $Command -ErrorAction SilentlyContinue
    if ($result) {
        $result.Source
    } else {
        Write-Warn "Command not found: $Command"
    }
}

# Extract archive (auto-detects type)
function extract {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        Write-Warn "File not found: $Path"
        return
    }
    switch -Wildcard ($Path) {
        '*.zip'    { Expand-Archive -Path $Path -DestinationPath (Split-Path $Path -Parent) -Force }
        '*.7z'     { & 7z x $Path "-o$(Split-Path $Path -Parent)" -y }
        '*.tar.gz' { & tar -xzf $Path -C (Split-Path $Path -Parent) }
        '*.tar.xz' { & tar -xJf $Path -C (Split-Path $Path -Parent) }
        default    { Write-Warn "Unknown archive format: $Path" }
    }
}

# Open current directory in Windows Terminal (WT Dev) or File Explorer
function open. {
    if (Get-Command wt -ErrorAction SilentlyContinue) {
        wt -d .
    } else {
        Invoke-Item .
    }
}

# ============================================================
# Startup message
# ============================================================
Write-Host "   PowerShell $($PSVersionTable.PSVersion) — dotfiles managed" -ForegroundColor DarkGray
