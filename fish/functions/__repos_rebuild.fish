function __repos_rebuild --description "Rebuild the git repos cache"
    fd -g .git -HL -t d -d 7 --prune ~ \
        -E Library \
        -E 'Application Support' \
        -E .cache \
        -E '.local/share/nvim/lazy' \
        -E '.config/tmux/plugins' \
        -E '.local/state/yazi' \
        -E '.cursor/plugins' \
        -E '.config/helix' \
        -E '.pi/agent/git/github.com' \
        -E '.config/raycast/public-extensions-fork' \
        --exec dirname '{}' >~/.cache/git-repos.list.tmp
    and mv ~/.cache/git-repos.list.tmp ~/.cache/git-repos.list
end
