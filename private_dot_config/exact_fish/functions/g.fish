function g --description "Interactive git repository navigation with worktree support"
    set -l pre_selected_repos '~/dotfiles' '~/.config/nvim'

    # Find regular git repos
    set -l regular_repos (rg --hidden --files --glob '**/.git/HEAD' --glob '!**/Arhive git/**' --max-depth 6 "$GITTER_DIR" | sed 's|.git/HEAD||' | string replace $GITTER_DIR/ '' | string trim -r -c/)

    # Find bare git repos
    set -l bare_repos (rg --hidden --files --glob '**/.bare/HEAD' --max-depth 6 "$GITTER_DIR" | sed 's|/.bare/HEAD||' | string replace $GITTER_DIR/ '')

    # Combine all repos
    set -l all_repos $regular_repos $bare_repos $pre_selected_repos

    set -l selected_repo (
        string join \n $all_repos | fzf --prompt="Select a directory: " --header="Press CTRL-D to go to gitter folder"
    )

    set -l selected_repo_path
    if contains "$selected_repo" $pre_selected_repos
        set selected_repo_path (string replace '~' $HOME "$selected_repo")
    else
        set selected_repo_path "$GITTER_DIR/$selected_repo"
    end

    if test -z "$selected_repo"
        cd $GITTER_DIR
        return
    end

    if test -d "$selected_repo_path/.bare"
        set -l worktree_path (git_worktree_select "$selected_repo_path")
        if test $status -eq 0
            cd "$worktree_path"
        else
            cd "$selected_repo_path"
        end
    else
        cd "$selected_repo_path"
    end
end

