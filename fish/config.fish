if status is-interactive

  eza -lh --icons
  # ==================================
  # ghq-fzf keybind
  # =================================
function ghq-fzf
    set src (ghq list | fzf \
        --preview '
            set repo (ghq root)/{}
            if ls $repo/README* >/dev/null 2>&1
                bat --color=always --style=header,grid --line-range :80 $repo/README*
            else
                ls -lah $repo
            end
        '
    )

    if test -n "$src"
        cd (ghq root)/$src
        commandline -f repaint
    end
end

bind \cg ghq-fzf
# =========================
# 基本設定
# =========================

 if test -f ~/.last_dir
     set last_dir (cat ~/.last_dir)
     if test -d "$last_dir"
         cd $last_dir
         if command -q exa
             exa -lh --icons
         else
             ls -lh
           end
     end
 end

# 日本語環境
set -x LANG ja_JP.UTF-8
set -x LC_ALL ja_JP.UTF-8

# エディタ
set -x EDITOR nvim
set -x VISUAL nvim

# less を見やすく
set -x LESS "-R"

# =========================
# PATH 設定
# =========================

 # ~/.local/bin を PATH に追加
if not contains $HOME/.local/bin $PATH
    set -x PATH $HOME/.local/bin $PATH
end

# =========================
# ユーティリティ設定
# =========================

# thefuck エイリアス
thefuck --alias | source

# =========================
# エイリアス
# =========================

alias vim "nvim"
alias ll "ls -lh"
alias lah "ls -lah" 
alias la "ls -A"
alias l  "ls -CF"
alias rm "rm -rf"
alias cp "cp -i"
alias mv "mv -i"
alias grep "grep --color=auto"
alias clr "clear"
alias ts-enviroment "sudo npm i -D typescript tsx esbuild @types/node @types/express"
alias q "exit"
if command -q exa
    alias ls "exa -lh --icons"
end
alias opencodeclear "rm -rf ~/.local/share/opencode"
alias parllamaclear "rm -rf /home/nazozokc/.local/share/parllama/chats"   
alias claude-ollama "export ANTHROPIC_AUTH_TOKEN=ollama | export ANTHROPIC_BASE_URL=http://localhost:11434"
alias 1 "wlr-randr --output eDP-1 --scale 1.0"

# Git
alias g  "git"
alias gs "git status"
alias ga "git add"
alias gc "git commit"
alias gp "git push"
alias gp-rebase "git pull --rebase origin main"
alias gl "git log --oneline --graph --decorate"
alias gd "git diff"
alias gb "git branch"
alias git-graph "gh graph --pixel %E2%96%A0"
alias gco. "git checkout"
alias lzg "lazygit"

# Docker
alias d "docker"
alias dc "docker compose"

# ディレクトリ操作
alias .. "cd .."
alias ... "cd ../.."

# システム
alias df "df -h"
alias du "du -h"

# nix
alias ns "nix-shell"

# =========================
# fish 便利機能
# =========================

# 実行に5秒以上かかったコマンドの時間表示
set -g fish_command_timer 1

# 自動補完提案を無効化
set -g fish_autosuggestion_enabled 1

# fishコマンドの補完を無効化
complete --erase --command fish

# pipxコマンドの補完を無効化
complete --erase --command pipx 

# ディレクトリ移動時ls
function __auto_ls --on-variable PWD
    ls -lh --icons
end


# ===========================
# コマンド補完
# ===========================
# Ctrl+G に fzf 選択をバインド
bind \cg fzf_select_candidate

# =========================
# Git プロンプト設定
# =========================
set -Ux __fish_git_prompt_char_branch 
set -Ux __fish_git_prompt_color_branch magenta
set -U fish_greeting ""

# =========================
# Color theme: Kanagawa Dragon
# =========================

set -l foreground DCD7BA
set -l selection 2D4F67
set -l comment 727169
set -l red C34043
set -l orange FF9E64
set -l yellow C0A36E
set -l green 76946A
set -l purple 957FB8
set -l cyan 7AA89F
set -l pink D27E99

# Syntax Highlighting Colors
set -g fish_color_normal $foreground
set -g fish_color_command $cyan
set -g fish_color_keyword $pink
set -g fish_color_quote $yellow
set -g fish_color_redirection $foreground
set -g fish_color_end $orange
set -g fish_color_error $red
set -g fish_color_param $purple
set -g fish_color_comment $comment
set -g fish_color_selection --background=$selection
set -g fish_color_search_match --background=$selection
set -g fish_color_operator $green
set -g fish_color_escape $pink
set -g fish_color_autosuggestion brblack
set -U fish_autosuggestion_strategy history completion

# Completion Pager Colors (補完表示を非表示にするため透明に近い色に設定)
set -g fish_pager_color_progress normal
set -g fish_pager_color_prefix normal
set -g fish_pager_color_completion normal
set -g fish_pager_color_description normal

# =========================
# fzf
# =========================

set -x FZF_DEFAULT_OPTS "
--layout=reverse
--info=inline
--height=60%
--border=rounded
--margin=1
--padding=1
--prompt='> '
--pointer='▶'
--marker='✓'
--preview-window=right:60%:wrap
--color=bg+:#181616,bg:#181616,spinner:#8ba4b0,hl:#c4746e
--color=fg:#c5c9c5,header:#625e5a,info:#8ba4b0,pointer:#c4746e
--color=marker:#c4746e,fg+:#c5c9c5,hl+:#c4746e
--color=prompt:#8ba4b0,hl:#c4746e
 "

end

# opencode
fish_add_path /home/nazozokc/.opencode/bin

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
