# ディレクトリ検索して移動（zsh版と同等）
function cdf
    # プレビューコマンドを選択
    if command -q exa
        set preview_cmd 'exa -lh --icons'
    else
        set preview_cmd 'ls -lh'
    end

    set dir (
        find . -type d 2>/dev/null \
        | sed 's|^\./||' \
        | fzf \
            --prompt="cdf> " \
            --preview $preview_cmd \
            --preview-window=right:60%:wrap
    )

    if test -n "$dir"
        cd "$dir"
    end
end
