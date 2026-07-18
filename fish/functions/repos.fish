function repos --description "List all git repos on the system, with caching"
    set -l cache ~/.cache/git-repos.list

    if not test -f $cache
        # First run: must build synchronously
        __repos_rebuild
    else #if test (math (date +%s) - (stat -f %m $cache)) -gt 3600
        # Stale: kick off background refresh, serve old data now
        fish -c __repos_rebuild &
        disown
    end

    cat $cache
end
