fish_add_path $HOME/.local/bin
fish_add_path /Applications/Bear.app/Contents/MacOS/

if not status is-interactive
    return
end

source ~/.config/fish/env.fish

fish_config theme choose catppuccin-mocha

set -g fish_greeting ""

set -gx SHELL (which fish)
set -gx EDITOR nvim
set -gx GITTER_DIR "$HOME/gitter"

set -gx hydro_multiline true
set -gx hydro_symbol_start "\n"
set -gx hydro_color_duration yellow
set -gx hydro_color_pwd cyan
set -gx hydro_color_git purple
set -gx HOMEBREW_NO_ENV_HINTS 1
set -gx HOMEBREW_NO_UPDATE_REPORT_NEW 1

# Generic color var for some programs (such as eza)
set -gx LS_COLORS "$(vivid generate catppuccin-mocha)"
set -gx BAT_THEME "Catppuccin Mocha"
# bat coloring for man pages
set -gx MANPAGER "sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat -p -lman'"

bind ctrl-. forward-token
bind ctrl-comma backward-token
bind \cz 'fg 2>/dev/null; commandline -f repaint'

tv init fish | source
zoxide init fish --cmd cd | source

function multicd
    echo cd (string repeat -n (math (string length -- $argv[1]) - 1) ../)
end
abbr -a dotdot --regex '^\.\.+$' --function multicd

abbr -a n nvim
abbr -a pn pnpm
abbr -a por pnpm -F portal
abbr -a som pnpm -F sombra
abbr -a leg pnpm -F lego
abbr -a pnf pnpm -F
abbr -a l 'eza -aF --icons --width=80'
abbr -a tka 'tmux kill-server'
abbr -a top topgrade
abbr -a cm chezmoi
abbr -a cma 'chezmoi apply'
abbr -a cms 'chezmoi status'
abbr -a cmd 'chezmoi diff'
abbr -a oc opencode
abbr -a g 'cd (git_worktree_select (tv gitter))'

# pnpm
set -gx PNPM_HOME "/Users/markjarjour/Library/pnpm"
if not string match -q -- "$PNPM_HOME/bin" $PATH
  set -gx PATH "$PNPM_HOME/bin" $PATH
end
# pnpm end
