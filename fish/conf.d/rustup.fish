set -l rustup_env "$HOME/.cargo/env.fish"

if test -f "$rustup_env"
    source "$rustup_env"
end
