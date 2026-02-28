function gbc
    # Gitリポジトリか確認
    if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
        echo "Not a git repository"
        return 1
    end

    # ブランチ一覧を取得（現在のブランチ記号 * を消す）
    set branch (
        git branch --all \
        | sed 's/^[* ]*//' \
        | sed 's|^remotes/||' \
        | sort -u \
        | fzf --prompt="git branch > "
    )

    # 何も選ばなかったら終了
    if test -z "$branch"
        return 0
    end

    # ブランチ切り替え
    git switch $branch 2>/dev/null; or git checkout $branch
end

