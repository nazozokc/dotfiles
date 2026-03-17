# Ctrl+G で fzf 選択
function fzf_select_candidate
    set cmd (commandline -t)
    if test -z "$cmd"
        return
    end

    set candidates (complete -C $cmd --do-complete | string trim)
    if test (count $candidates) -eq 0
        return
    end

    set chosen (printf "%s\n" $candidates | fzf --height 10 --reverse --inline-info)
    if test -n "$chosen"
        commandline -rt "$chosen"
    end
end
