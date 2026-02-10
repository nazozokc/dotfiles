# cd したら自動で ls
function __auto_ls --on-variable PWD
    # 端末幅が狭いと邪魔なので制限
    if test (tput cols) -ge 60
        echo
        if command -q exa
            exa -lh --icons
        else
            ls -lh
        end
    end
end
