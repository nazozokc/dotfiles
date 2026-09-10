# Git ブランチ名のキャッシュ
# PWD 変更時にのみ git symbolic-ref を実行し、
# git_branch() 関数がキャッシュ変数を返すだけで済むようにする。

set -g __git_branch_cache ""

function __update_git_branch --on-variable PWD
    set -g __git_branch_cache (command git symbolic-ref --short HEAD 2>/dev/null)
end

# 起動時の初期化
__update_git_branch
