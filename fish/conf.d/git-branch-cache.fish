# Git ブランチ名のキャッシュ
# PWD 変更時にのみ git symbolic-ref を実行し、
# git_branch() 関数がキャッシュ変数を返すだけで済むようにする。

set -g __git_branch_cache ""

function __update_git_branch --on-variable PWD
    # gitリポジトリのルートを取得してからブランチを取得
    set -l root (command git rev-parse --show-toplevel 2>/dev/null)
    if test -n "$root"
        # gitリポジトリ内でgitコマンドを実行
        set -g __git_branch_cache (command git -C "$root" symbolic-ref --short HEAD 2>/dev/null)
    else
        set -g __git_branch_cache ""
    end
end

# 起動時の初期化
__update_git_branch
