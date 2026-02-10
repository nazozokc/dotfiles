# コマンド補完候補を表示
function fish_candidate_prompt --on-event fish_post_key
    set cmd (commandline -t)
    # 入力が空なら何も表示しない
    if test -z "$cmd"
        set -g __fzf_candidates ""
        return
    end

    # 候補を取得（改行区切り）
    set candidates (complete -C $cmd --do-complete | string trim)

    # 候補を1行で表示（右プロンプト用にコンマ区切り）
    if test (count $candidates) -gt 0
        set -g __fzf_candidates (string join ', ' $candidates)
    else
        set -g __fzf_candidates ""
    end
end
