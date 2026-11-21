fish_add_path "$HOME/.local/bin"
fish_add_path "$HOME/.cmux/bin"

# WSL でのみ Windows 側 X サーバーへ DISPLAY を向ける (macOS / 素の Linux では設定しない)
if test -n "$WSL_DISTRO_NAME"
    set -l nameserver (grep -m 1 '^nameserver' /etc/resolv.conf | awk '{print $2}')
    if test -n "$nameserver"
        set -gx DISPLAY "$nameserver:0"
    end
end
