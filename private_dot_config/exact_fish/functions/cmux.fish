function cmux --description "Connect to existing cmux session or create new one with worktree selection"
    # Check if any tmux session matching "cmux/*" exists
    set -l existing_sessions (tmux list-sessions 2>/dev/null | grep "^cmux/" | head -1)
    
    if test -n "$existing_sessions"
        # Extract the session name from the first matching session
        set -l session_name (echo "$existing_sessions" | cut -d: -f1)
        echo "Connecting to existing session: $session_name"
        tmux attach-session -t "$session_name"
        return 0
    end

    set -l EXO_PATH "$GITTER_DIR/civalgo/exo"
    set -l MAIN_WORKTREE_NAME "exo-main"
    
    echo "Select a worktree:"
    
    set -l exo_worktree_path (git_worktree_select "$EXO_PATH")
    if test $status -eq 1
        echo "No worktree selected. Exiting."
        return 1
    end
    
    echo "exo_worktree_path: $exo_worktree_path"
    if not string match -q '*exo-main' -- "$exo_worktree_path"
        echo "Copying .env files from exo-main to $exo_worktree_path"
        if test ! -f "$exo_worktree_path/apps/portal/.env"
            cp "$EXO_PATH/$MAIN_WORKTREE_NAME/apps/portal/.env" "$exo_worktree_path/apps/portal/.env"
            echo "Copied Portal's .env from exo-main to $exo_worktree_path/apps/portal/.env"
            sleep 5
        end
        if test ! -f "$exo_worktree_path/services/sombra/.env"
            cp "$EXO_PATH/$MAIN_WORKTREE_NAME/services/sombra/.env" "$exo_worktree_path/services/sombra/.env"
            echo "Copied Sombra's .env from exo-main to $exo_worktree_path/services/sombra/.env"
            sleep 5
        end
    end

    gum confirm "Have you rebased your worktree?"
    if test $status -ne 0
        echo "Exiting."
        return 1
    end

    set -l worktree_name (basename "$exo_worktree_path")
    set -l session_name "cmux/$worktree_name"

    echo "Creating new tmux session: $session_name"

    tmux new-session -d -s "$session_name" -n "watcher" -c "$exo_worktree_path"
    tmux send-keys -t "$session_name:watcher" "__cmux-watcher" Enter

    tmux new-window -t "$session_name" -n "portal" -c "$exo_worktree_path"
    tmux send-keys -t "$session_name:portal" "__cmux-portal" Enter

    tmux new-window -t "$session_name" -n "sombra" -c "$exo_worktree_path"
    tmux send-keys -t "$session_name:sombra" "__cmux-sombra" Enter
    
    tmux new-window -t "$session_name" -n "lego" -c "$exo_worktree_path"
    tmux send-keys -t "$session_name:lego" "__cmux-lego" Enter

    tmux select-window -t "$session_name:watcher"
    tmux attach-session -t "$session_name"
end
