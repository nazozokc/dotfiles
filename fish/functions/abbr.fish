# エイリアス (abbr)

abbr --add vim nvim
abbr --add ll ls\ -lh
abbr --add lah ls\ -lah
abbr --add la ls\ -lah
abbr --add l ls\ -CF
abbr --add rm rm\ -rf
abbr --add cp cp\ -i
abbr --add mv mv\ -i
abbr --add grep grep\ --color=auto
abbr --add clr clear
abbr --add q exit
if command -q eza
    abbr --add ls eza\ -lh\ --icons
end

# 複雑なコマンドは function として定義
function ts-enviroment
    npm i typescript tsx esbuild @types/node @types/express $argv
end

function opencodeclear
    rm -rf ~/.local/share/opencode
end

function parllamaclear
    rm -rf /home/nazozokc/.local/share/parllama/chats
end

function claude-ollama
    export ANTHROPIC_AUTH_TOKEN=ollama
    export ANTHROPIC_BASE_URL=http://localhost:11434
end

function 1
    wlr-randr --output eDP-1 --scale 1.0
end

# Git
abbr --add g git
abbr --add gs git\ status
abbr --add ga git\ add

function gc
    git commit $argv
end

function gp
    git push $argv
end

abbr --add gp-rebase git\ pull\ --rebase\ origin\ main
abbr --add gl git\ log\ --oneline\ --graph\ --decorate
abbr --add gd git\ diff
abbr --add gb git\ branch
abbr --add git-graph gh\ graph\ --pixel\ %E2%96%A0

function gco.
    git checkout $argv
end

abbr --add lzg lazygit

# Docker
abbr --add d docker
abbr --add dc docker\ compose
abbr --add lzd lazydocker

# ディレクトリ操作
function ..
    cd .. $argv
end

function ...
    cd ../.. $argv
end

# システム
abbr --add df df\ -h
abbr --add du du\ -h

# nix
abbr --add ns nix-shell
