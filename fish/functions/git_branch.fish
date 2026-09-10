# Git ブランチ名をキャッシュ取得
# PWD 変更時にのみ git symbolic-ref を実行し、プロンプトでは
# キャッシュ変数を返すだけにすることでサブプロセス呼び出しを排除する。
# イベントハンドラ登録は conf.d/git-branch-cache.fish で起動時に行う。

function git_branch
    echo "$__git_branch_cache"
end
