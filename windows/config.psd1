@{
    # ============================================================
    # windows/config.psd1
    # Declarative desired state for Windows dotfiles.
    #
    # Edit this file, then run:
    #   pwsh windows/apply.ps1
    #
    # This file is a PowerShell Data File (.psd1).
    # Syntax: variable-free hashtable literals only.
    # Paths use %ENVVAR% strings; modules expand them at runtime.
    # ============================================================

    # ============================================================
    # System
    # ============================================================
    System = @{
        # Scoop buckets to register
        ScoopBuckets    = @('main', 'extras', 'nerd-fonts', 'versions')

        # Enable scoop global shims (requires admin on first run)
        ScoopGlobalShims = $true
    }

    # ============================================================
    # Packages
    # ============================================================
    Packages = @{
        # Packages installed via scoop
        Scoop = @(
            # Shell / Terminal
            'wezterm'
            'pwsh'

            # Editor
            'neovim'

            # Version control
            'git'
            'gh'
            'lazygit'
            'delta'

            # Prompt
            'starship'

            # CLI tools — essentials
            'bat'
            'eza'
            'fd'
            'ripgrep'
            'fzf'
            'zoxide'
            'yazi'
            'jq'
            'bottom'
            'just'
            'direnv'
            'less'
            'which'

            # CLI tools — archiving
            '7zip'

            # Languages
            'nodejs'

            # Fonts
            'JetBrains-Mono-NF'
        )

        # Packages installed via winget
        Winget = @(
            @{ Id = 'Microsoft.WindowsTerminal';     Source = 'winget' }
            @{ Id = 'Microsoft.OpenSSH.Beta';       Source = 'winget' }
            @{ Id = 'AgileBits.1Password';           Source = 'winget' }
        )

        # PowerShell Gallery modules
        PSModule = @(
            @{ Name = 'PSFzf';          MinimumVersion = '2.5.0' }
            @{ Name = 'Terminal-Icons';  MinimumVersion = '0.8.0' }
        )
    }

    # ============================================================
    # Symlinks
    # From: path relative to dotfiles repo root
    # To:   Windows path (%ENVVAR% expanded at runtime)
    # ============================================================
    Links = @(
        # XDG ~/.config/ (shared with Linux)
        @{ From = 'starship/starship.toml';     To = '%USERPROFILE%\.config\starship.toml' }
        @{ From = 'bat/config';                 To = '%USERPROFILE%\.config\bat\config' }
        @{ From = 'wezterm';                    To = '%USERPROFILE%\.config\wezterm' }
        @{ From = 'opencode';                   To = '%USERPROFILE%\.config\opencode' }
        @{ From = 'efm-langserver/config.yaml'; To = '%USERPROFILE%\.config\efm-langserver\config.yaml' }

        # Git (Windows Git reads ~\.config\git\)
        @{ From = 'git/config';                 To = '%USERPROFILE%\.config\git\config' }
        @{ From = 'git/aliases';                To = '%USERPROFILE%\.config\git\aliases' }
        @{ From = 'git/ignore';                 To = '%USERPROFILE%\.config\git\ignore' }

        # AppData locations (%LOCALAPPDATA%, %APPDATA%)
        @{ From = 'nvim';                       To = '%LOCALAPPDATA%\nvim' }
        @{ From = 'lazygit/config.yml';         To = '%APPDATA%\lazygit\config.yml' }

        # Windows Terminal Dev channel
        @{ From = 'windows/terminal/settings.json'; To = '%USERPROFILE%\.config\wt\settings.json' }

        # WSL config
        @{ From = 'windows/.wslconfig';         To = '%USERPROFILE%\.wslconfig' }

        # Personal scripts
        @{ From = 'my_scripts';                 To = '%USERPROFILE%\.scripts' }
    )

    # ============================================================
    # Windows System settings (registry, features, power)
    # NOTE: Registry/Feature/Power changes require admin rights.
    # Restart with: Start-Process pwsh -Verb RunAs -Args '-File windows/apply.ps1'
    # ============================================================
    WindowsSystem = @{
        # Registry settings (HKCU = current user, no admin needed)
        Registry = @(
            # Explorer: show file extensions
            @{ Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'HideFileExt'; Value = 0; Type = 'DWord' }
            # Explorer: show hidden files
            @{ Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'Hidden'; Value = 1; Type = 'DWord' }
            # Explorer: show path in title bar
            @{ Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState'; Name = 'FullPath'; Value = 1; Type = 'DWord' }
            # Taskbar: align center (0 = left, 1 = center)
            @{ Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'TaskbarAl'; Value = 1; Type = 'DWord' }
            # Taskbar: combine taskbar buttons (0 = always, 1 = when full, 2 = never)
            @{ Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'TaskbarGlomLevel'; Value = 0; Type = 'DWord' }
            # Dark mode: apps
            @{ Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'; Name = 'AppsUseLightTheme'; Value = 0; Type = 'DWord' }
            # Dark mode: system
            @{ Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'; Name = 'SystemUsesLightTheme'; Value = 0; Type = 'DWord' }
            # Keyboard: keyboard repeat delay (ms, 250 = short)
            @{ Path = 'HKCU:\Control Panel\Keyboard'; Name = 'KeyboardDelay'; Value = 0; Type = 'DWord' }
            # Keyboard: keyboard repeat speed (31 = max)
            @{ Path = 'HKCU:\Control Panel\Keyboard'; Name = 'KeyboardSpeed'; Value = 31; Type = 'DWord' }
            # Mouse: pointer speed (1-20, default 10)
            @{ Path = 'HKCU:\Control Panel\Mouse'; Name = 'MouseSensitivity'; Value = 10; Type = 'DWord' }
            # Mouse: enhance pointer precision
            @{ Path = 'HKCU:\Control Panel\Mouse'; Name = 'MouseSpeed'; Value = 0; Type = 'DWord' }
            # Mouse: snap to default button
            @{ Path = 'HKCU:\Control Panel\Mouse'; Name = 'SnapToDefaultButton'; Value = 0; Type = 'DWord' }
            # Start menu: show recommended section (0 = hide)
            @{ Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'Start_ShowRecommended'; Value = 0; Type = 'DWord' }
            # Taskbar: search box style (0 = hidden, 1 = search icon, 2 = search box)
            @{ Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search'; Name = 'SearchboxTaskbarMode'; Value = 0; Type = 'DWord' }
        )

        # Windows Features to enable (requires admin)
        Features = @(
            # 'Microsoft-Windows-Subsystem-Linux'
            # 'VirtualMachinePlatform'
        )

        # Power settings (requires admin)
        Power = @{
            SleepTimeout = 30
            DisplayTimeout = 15
            HibernateTimeout = 0
        }
    }

    # ============================================================
    # PowerShell profile
    # ============================================================
    Profile = @{
        # Enable profile deployment
        Enabled = $true

        # Paths to deploy Microsoft.PowerShell_profile.ps1
        Paths = @(
            '%USERPROFILE%\Documents\PowerShell\Microsoft.PowerShell_profile.ps1'
            '%USERPROFILE%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1'
        )
    }
}
