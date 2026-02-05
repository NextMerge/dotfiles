function __zmux-attacher --description "Attach to tmux window or open in zed if already there"
    set -l session_name $argv[1]
    set -l program_name $argv[2]
    set -l worktree_path $argv[3]

    # Auto-detect session if we're in tmux and no session provided
    if test -z "$session_name" -a -n "$TMUX"
        set session_name (tmux display-message -p "#{session_name}")
    end

    if test -z "$program_name"
        echo "Error: program_name is required"
        return 1
    end

    # If we're in tmux on the target window, open zed and detach
    if test -n "$TMUX"
        set -l current_window (tmux display-message -p "#{window_name}")
        set -l current_session (tmux display-message -p "#{session_name}")

        if test "$current_window" = "$program_name" -a "$current_session" = "$session_name"
            set -l file (cat $ZMUX_TEMP_FILE 2>/dev/null)
            if test -z "$file"
                tmux display-message "zmux: no file stored"
                return 1
            else if test ! -f "$file"
                tmux display-message "zmux: file not found: $file"
                return 1
            else
                zed "$file"
                echo "" >$ZMUX_TEMP_FILE
                tmux detach-client
                return 0
            end
        end
    end

    # Create or focus the window
    if not tmux has-session -t "$session_name" 2>/dev/null
        # Need worktree_path to create new session
        if test -z "$worktree_path"
            echo "Error: worktree_path required to create new session"
            return 1
        end
        tmux new-session -d -s "$session_name" -n "$program_name" -c "$worktree_path"
        tmux send-keys -t "$session_name" "$program_name" Enter
    else
        set -l window_exists (tmux list-windows -t "$session_name" -F '#{window_name}' 2>/dev/null | grep "^$program_name\$")
        if test -z "$window_exists"
            # Need worktree_path to create new window
            if test -z "$worktree_path"
                # Try to get from session's first window
                set worktree_path (tmux display-message -p -t "$session_name:1" "#{pane_current_path}")
            end
            tmux new-window -t "$session_name" -n "$program_name" -c "$worktree_path"
            tmux send-keys -t "$session_name:$program_name" "$program_name" Enter
        else
            tmux select-window -t "$session_name:$program_name"
        end
    end
end
