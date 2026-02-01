function zmux --description "Attach or create tmux session/window and store filename"
    set -l worktree_path $argv[1]
    set -l filename $argv[2]
    set -l program_name $argv[3]

    if test -z "$worktree_path" -o -z "$program_name" -o -z "$filename"
        echo "Usage: zmux <worktree_path> <program_name> <filename>"
        return 1
    end

    echo "$filename" >$ZMUX_TEMP_FILE

    set -l session_name (basename "$worktree_path")
    set -l gitter_match (string match -r 'gitter/(.+)' "$worktree_path")
    if test -n "$gitter_match"
        set session_name (echo "$gitter_match" | tail -1)
    end

    # echo "Worktree Path: $worktree_path"
    # echo "Filename: $filename"
    # echo "Program Name: $program_name"
    # echo "Session name: $session_name"

    if not tmux has-session -t "$session_name" 2>/dev/null
        tmux new-session -d -s "$session_name" -n "$program_name" -c "$worktree_path"
        tmux send-keys -t "$session_name" "$program_name" Enter
    else
        set -l window_exists (tmux list-windows -t "$session_name" -F '#{window_name}' 2>/dev/null | grep "^$program_name\$")
        echo "Window exists: $window_exists"
        if test -z "$window_exists"
            tmux new-window -t "$session_name" -n "$program_name" -c "$worktree_path"
            tmux send-keys -t "$session_name" "$program_name" Enter
        else
            tmux select-window -t "$session_name:$program_name"
        end
    end

    if test -z "$TMUX"
        tmux attach-session -t "$session_name"
    else
        tmux switch-client -t "$session_name"
    end
end
