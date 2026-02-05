function zmux --description "Attach or create tmux session/window and store filename"
    set -l worktree_path $argv[1]
    set -l filename $argv[2]
    set -l program_name $argv[3]
    
    if test -z "$worktree_path" -o -z "$program_name" -o -z "$filename"
        echo "Usage: zmux <worktree_path> <program_name> <filename>"
        return 1
    end

    if string match -q "*/zed/*" "$worktree_path"; and string match -q "*.json" "$worktree_path"
        echo "Error: Cannot open Zed settings files in zmux"
        return 1
    end

    if test -f "$worktree_path"
        echo "Error: worktree_path must be a directory, not a file"
        return 1
    end

    echo "$filename" >$ZMUX_TEMP_FILE

    set -l session_name (basename "$worktree_path")
    set -l gitter_match (string match -r 'gitter/(.+)' "$worktree_path")
    if test -n "$gitter_match"
        set session_name $gitter_match[2]
    end

    # echo "Worktree Path: $worktree_path"
    # echo "Filename: $filename"
    # echo "Program Name: $program_name"
    # echo "Session name: $session_name"

    __zmux-attacher "$session_name" "$program_name" "$worktree_path"
    tmux attach-session -t "$session_name"
end
