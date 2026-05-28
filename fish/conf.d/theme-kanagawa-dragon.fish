# Kanagawa Dragon theme for fish
# Ref: https://github.com/rebelot/kanagawa.nvim

set -l kanagawa_dragon_fg c5c9c5
set -l kanagawa_dragon_gray 727169
set -l kanagawa_dragon_blue 7e9cd8
set -l kanagawa_dragon_red e46876
set -l kanagawa_dragon_cyan 7fb4ca
set -l kanagawa_dragon_green 98bb6c
set -l kanagawa_dragon_orange e6c384
set -l kanagawa_dragon_yellow c0a36e
set -l kanagawa_dragon_purple 957fb8
set -l kanagawa_dragon_teal 6a9589
set -l kanagawa_dragon_user 87a987
set -l kanagawa_dragon_bg_dim 363646

set -g fish_color_normal $kanagawa_dragon_fg
set -g fish_color_command $kanagawa_dragon_blue
set -g fish_color_keyword $kanagawa_dragon_blue
set -g fish_color_param $kanagawa_dragon_green
set -g fish_color_option $kanagawa_dragon_yellow
set -g fish_color_quote $kanagawa_dragon_orange
set -g fish_color_redirection $kanagawa_dragon_teal
set -g fish_color_end $kanagawa_dragon_purple
set -g fish_color_error $kanagawa_dragon_red
set -g fish_color_escape $kanagawa_dragon_cyan
set -g fish_color_autosuggestion $kanagawa_dragon_gray
set -g fish_color_comment $kanagawa_dragon_gray
set -g fish_color_selection --background=$kanagawa_dragon_bg_dim
set -g fish_color_search_match --background=$kanagawa_dragon_bg_dim
set -g fish_color_cancel $kanagawa_dragon_red
set -g fish_color_user $kanagawa_dragon_user
set -g fish_color_host $kanagawa_dragon_blue
set -g fish_color_cwd $kanagawa_dragon_blue
set -g fish_color_valid_path --underline
