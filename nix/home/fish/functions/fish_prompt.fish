# プロンプト（超シンプル）
function fish_prompt
    set p (prompt_pwd)

    # HOME のとき
    if test "$p" = "~"
        set_color cyan --bold
        echo -n '~'
    else
        # 最後の / で分割
        set parent (string replace -r '/[^/]+$' '' $p)
        set base (string replace -r '^.*/' '' $p)

        # 親パス（細字）
        set_color cyan --dim
        echo -n $parent

        # 区切り
        echo -n '/'

        # カレントディレクトリ（太字）
        set_color cyan --bold
        echo -n $base
    end

    # Git ブランチ
    set branch (git_branch)
    if test -n "$branch"
        set_color normal
        echo -n ' '
        set_color magenta
        echo -n $branch
    end

    # プロンプト記号
    set_color normal
    echo -n '・❯ '
end
