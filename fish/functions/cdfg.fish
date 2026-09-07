# / から全ファイル検索して移動
function cdfg
    # プレビューコマンドを選択
    if command -q bat
        set preview_cmd 'bat --color=always --line-range=:100 {}'
    else if command -q cat
        set preview_cmd 'cat {}'
    end

    set file (
        find / -type f 2>/dev/null \
        | fzf \
            --prompt="cdfg> " \
            --preview $preview_cmd \
            --preview-window=right:60%:wrap
    )

    if test -n "$file"
        cd (dirname "$file")
    end
end
