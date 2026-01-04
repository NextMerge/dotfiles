function gw --description "Git Worktree Switch - Interactive worktree switching"
    set -l worktree_path (git_worktree_select $argv)
    if test -n "$worktree_path"
        cd "$worktree_path"
    end
end