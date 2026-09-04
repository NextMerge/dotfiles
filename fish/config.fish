fish_add_path $HOME/.local/bin
fish_add_path /Applications/Bear.app/Contents/MacOS/

if not status is-interactive
    return
end

source ~/.config/fish/env.fish
fish_config theme choose catppuccin-mocha

bind ctrl-. forward-token
bind ctrl-comma backward-token
bind \cz 'fg 2>/dev/null; commandline -f repaint' # ctrl-z performs 'fg'

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

set -gx EZA_CONFIG_DIR "$HOME/.config/eza"
abbr -a e 'eza -aF --icons --width=80'

set -gx BAT_THEME "Catppuccin Mocha"
# bat coloring for man pages
set -gx MANPAGER "sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat -p -lman'"

tv init fish | source
zoxide init fish --cmd cd | source

function multicd
    echo cd (string repeat -n (math (string length -- $argv[1]) - 1) ../)
end
abbr -a dotdot --regex '^\.\.+$' --function multicd

abbr x exit
abbr -a n nvim
abbr -a pn pnpm
abbr --add p --command pnpm --position anywhere -- "-F portal"
abbr --add s --command pnpm --position anywhere -- "-F sombra"
abbr --add l --command pnpm --position anywhere -- "-F lego"
abbr -a pnf pnpm -F
abbr -a tka 'tmux kill-server'
abbr -a top topgrade
abbr -a ch 'cd (chezmoi source-path) && nvim'
abbr -a cm chezmoi
abbr -a cma 'chezmoi apply'
abbr -a cms 'chezmoi status'
abbr -a cmd 'chezmoi diff'
abbr -a g 'cd (git_worktree_select (tv git-repos))'
abbr -a gn 'cd (git_worktree_select (tv git-repos)) && nvim'
abbr -a az lazygit
abbr -a oc opencode

# pnpm
set -gx PNPM_HOME '/Users/markjarjour/Library/pnpm'
if not string match -q -- "$PNPM_HOME/bin" $PATH
  set -gx PATH "$PNPM_HOME/bin" $PATH
end
# pnpm end
