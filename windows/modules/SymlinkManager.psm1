# SymlinkManager.psm1
# Declarative symlink convergence for Windows

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
function Invoke-LinkConverge {
    param(
        [string]$RepoRoot,
        $Config
    )

    $links = $Config.Links
    if (-not $links) {
        Write-Warn "No Links section in config. Skipping."
        return
    }

    Write-Step "Converging symlinks..."

    $changed = 0
    $skipped = 0

    foreach ($entry in $links) {
        $targetFull = Join-Path $RepoRoot $entry.From
        $linkFull = [System.Environment]::ExpandEnvironmentVariables($entry.To)

        if (-not (Test-Path $targetFull)) {
            Write-Warn "Source does not exist, skipping: $targetFull"
            $skipped++
            continue
        }

        $result = Set-Symlink -Target $targetFull -Link $linkFull
        if ($result -eq 'changed') { $changed++ }
        else { $skipped++ }
    }

    Write-Info "Done. $changed linked, $skipped up-to-date/skipped."
}

# ============================================================
# Symlink primitive
# ============================================================
function Set-Symlink {
    param(
        [string]$Target,
        [string]$Link
    )

    # Check if symlink already exists and points to the right target
    if (Test-Path $Link) {
        $item = Get-Item $Link -Force
        if ($item.LinkType -eq 'SymbolicLink') {
            $currentTarget = $item.Target
            if ($currentTarget -eq $Target) {
                Write-Skip "Symlink already correct: $Link"
                return 'skipped'
            }
        }
        # Remove existing (file, dir, or wrong symlink)
        Remove-Item -Path $Link -Recurse -Force -ErrorAction SilentlyContinue
        Write-Info "Removed existing: $Link"
    } else {
        # Create parent directory if needed
        $parentDir = Split-Path $Link -Parent
        if (-not (Test-Path $parentDir)) {
            New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
        }
    }

    # Create symlink
    New-Item -ItemType SymbolicLink -Path $Link -Target $Target -Force | Out-Null
    $itemType = if (Test-Path $Target -PathType Container) { "Directory" } else { "File" }
    Write-Info "Linked $Link -> $Target ($itemType)"

    return 'changed'
}

Export-ModuleMember -Function Invoke-LinkConverge
