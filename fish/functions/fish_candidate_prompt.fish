# コマンド補完候補を表示
# NOTE: 毎キープレスでの complete -C は重すぎるため無効化済み
# fish_candidate_prompt を有効にする場合は下記をアンコメント
#
# function fish_candidate_prompt --on-event fish_post_key
#     set cmd (commandline -t)
#     if test -z "$cmd"
#         set -g __fzf_candidates ""
#         return
#     end
#     set candidates (complete -C $cmd --do-complete | string trim)
#     if test (count $candidates) -gt 0
#         set -g __fzf_candidates (string join ', ' $candidates)
#     else
#         set -g __fzf_candidates ""
#     end
# end
