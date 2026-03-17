# Git ブランチ名を取得
function git_branch
    command git symbolic-ref --short HEAD 2>/dev/null
end
