function git-repo
    set repo (ghq list | fzf \
        --preview '
            if test -f (ghq root)/{}/README.md
                bat --color=always (ghq root)/{}/README.md
            else
                ls -lah (ghq root)/{}
            end
        ')
    if test -n "$repo"
        cd (ghq root)/$repo
    end
end
