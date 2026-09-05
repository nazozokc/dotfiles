fish_add_path ~/.local/bin

# WSL でのみ Windows 側 X サーバーへ DISPLAY を向ける (macOS / 素の Linux では設定しない)
if test -n "$WSL_DISTRO_NAME"
    set -gx DISPLAY (cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):0
end
