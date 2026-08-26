# プロンプト（超シンプル）
function fish_prompt
    set repo_root (command git rev-parse --show-toplevel 2>/dev/null)
    if test -n "$repo_root"
        # リポジトリ名は残し、リポジトリ内の親ディレクトリを短縮表示する
        set repo_name (command basename "$repo_root")
        set relative_path (string replace -- "$repo_root" '' "$PWD")
        set components (string split / -- (string trim --chars=/ (string replace -- "$HOME" '~' "$PWD")))
        set p $components[1]
        set last_component $components[-1]

        for component in $components[2..-1]
            if test -n "$component"
                if test "$component" = "$repo_name"; or test "$component" = "$last_component"
                    set display_component $component
                else
                    set display_component (string sub --length 1 "$component")
                end
                set p "$p/$display_component"
            end
        end
    else
        set p (prompt_pwd)
    end

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
        echo -n /

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
