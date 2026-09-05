# cd したら自動で ls
# NOTE: イベントハンドラは autoload では登録されないため conf.d に置く
# (fish docs: Event handlers only become active once the corresponding
#  function is loaded into the shell)
function __auto_ls --on-variable PWD
    # 端末幅が狭いと邪魔なので制限
    if test (tput cols) -ge 60
        echo
        if command -q eza
            eza -lh --icons
        end
    end
end