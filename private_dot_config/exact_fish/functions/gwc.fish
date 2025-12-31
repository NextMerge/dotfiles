function gwc --description "Git Worktree Clone - Clone a repository and set up worktree with main branch"
    if test (count $argv) -eq 0
        echo "Usage: gwc <remote-repo>"
        return 1
    end

    set -l DEFAULT_BRANCH (printf "main\nmaster" | fzf --prompt="Select default branch: ")
    if test -z "$DEFAULT_BRANCH"
        echo "No default branch selected, exiting..."
        return 1
    end

    set -l REMOTE_REPO $argv[1]
    set -l WORKTREE_MAIN_NAME (basename (pwd))"-main"

    git clone $REMOTE_REPO --bare .bare
    echo "gitdir: ./.bare" > .git

    git branch | xargs git branch -D
    git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
    git fetch
    git worktree add $WORKTREE_MAIN_NAME -b main --track origin/$DEFAULT_BRANCH
end

