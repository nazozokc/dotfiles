# 右側プロンプト表示関数（コマンド候補表示）
function fish_right_prompt
    if set -q __fzf_candidates
        echo -n $__fzf_candidates
    end
end
