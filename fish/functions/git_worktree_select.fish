function git_worktree_select --description "Git Worktree Select - Interactive worktree selection"
    set -l git_dir (pwd)
    if test (count $argv) -gt 0
        set git_dir $argv[1]
    end

    if not git -C "$git_dir" worktree list >/dev/null 2>&1
        echo (set_color red)"Not a git repository"(set_color normal)
        return 1
    end

    # If this isn't a bare repository, return the git directory
    if not test -d "$git_dir/.bare"
        echo "$git_dir"
        return 0
    end

    set -l worktree_list_output (git -C "$git_dir" worktree list | grep -v "(bare)" | string collect)
    set -l formatted_worktrees (echo "$worktree_list_output" | awk '{print $1, substr($0, index($0,$3))}' | sed 's|.*/\([^/]*\) |\1 |')
    set -l selected_worktree

    if test (count $formatted_worktrees) -lt 2
        set selected_worktree $formatted_worktrees[1]
    else
        set selected_worktree (string join \n $formatted_worktrees | tv --input-prompt="Select a worktree" --select-1)
    end

    if test -n "$selected_worktree"
        set -l just_selected_worktree (echo "$selected_worktree" | awk '{print $1}')
        set -l worktree_path (echo "$worktree_list_output" | grep "$just_selected_worktree" | awk '{print $1}')
        echo "$worktree_path"
        return 0
    end
    return 1
end
