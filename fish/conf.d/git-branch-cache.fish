# Git ブランチ名のキャッシュ
# PWD 変更時 + 全コマンド実行後に git symbolic-ref を実行し、
# git checkout / git switch 等のディレクトリ移動なしブランチ切替でも反映されるようにする。

set -g __git_branch_cache ""

function __update_git_branch
    set -l root (command git rev-parse --show-toplevel 2>/dev/null)
    if test -n "$root"
        set -g __git_branch_cache (command git -C "$root" symbolic-ref --short HEAD 2>/dev/null)
    else
        set -g __git_branch_cache ""
    end
end

# PWD 変更時
function __update_git_branch_on_pwd --on-variable PWD
    __update_git_branch
end

# 全コマンド実行後（git checkout / switch 等のキャッチのため）
function __update_git_branch_on_postexec --event fish_postexec
    __update_git_branch
end

# 起動時の初期化
__update_git_branch
