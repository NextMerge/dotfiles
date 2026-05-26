function repos --description "List all git repos on the system, with caching"
    set -l cache ~/.cache/git-repos.list

    if not test -f $cache
        # First run: must build synchronously
        _repos_rebuild
    else if test (math (date +%s) - (stat -f %m $cache)) -gt 3600
        # Stale: kick off background refresh, serve old data now
        fish -c _repos_rebuild &
        disown
    end

    cat $cache
end

function _repos_rebuild --description "Rebuild the git repos cache"
    fd -g .git -HL -t d -d 7 --prune ~ -E Library -E 'Application Support' -E .cache -E '.local/share/nvim/lazy' -E '.config/tmux/plugins' -E '.local/state/yazi' -E '.cursor/plugins' \
        --exec dirname '{}' >~/.cache/git-repos.list.tmp
    and mv ~/.cache/git-repos.list.tmp ~/.cache/git-repos.list
end
