function cmux --description "Connect to existing cmux session or create new one with worktree selection"
    # Check if any tmux session matching "cmux/*" exists
    set -l existing_sessions (tmux list-sessions 2>/dev/null | grep "^cmux" | head -1)
    
    if test -n "$existing_sessions"
        set -l session_name (echo "$existing_sessions" | cut -d: -f1)
        tmux attach-session -t "$session_name"
        return 0
    end

    set -l EXO_PATH "$GITTER_DIR/civalgo/exo"

    gum confirm "Have you rebased your worktree?"
    if test $status -ne 0
        echo "Exiting."
        return 1
    end

    set -l session_name "cmux"

    tmux new-session -d -s "$session_name" -n "watcher" -c "$EXO_PATH"
    tmux send-keys -t "$session_name:watcher" "__cmux-watcher" Enter

    tmux new-window -t "$session_name" -n "portal" -c "$EXO_PATH"
    tmux send-keys -t "$session_name:portal" "__cmux-portal" Enter

    tmux new-window -t "$session_name" -n "sombra" -c "$EXO_PATH"
    tmux send-keys -t "$session_name:sombra" "__cmux-sombra" Enter
    
    tmux new-window -t "$session_name" -n "lego" -c "$EXO_PATH"
    tmux send-keys -t "$session_name:lego" "__cmux-lego" Enter

    tmux select-window -t "$session_name:watcher"
    tmux attach-session -t "$session_name"
end
