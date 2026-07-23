function git-to-vault --description "Sync git backup back to Obsidian vault"
    set -l src ~/gitter/obsidian-git-backup/
    set -l dst ~/gitter/Plexus/

    if not test -d $src/.git
        echo (set_color red)"error: $src is not a git repo"(set_color normal)
        return 1
    end

    echo "changes that would be applied to $dst:"
    /usr/bin/rsync -acvn --delete --exclude='.git/' --filter='P .git/' $src $dst
    echo

    gum confirm "Apply these changes?"
    if test $status -ne 0
        echo (set_color yellow)"Aborted."(set_color normal)
        return 1
    end

    /usr/bin/rsync -av --delete --exclude='.git/' --filter='P .git/' $src $dst
    echo (set_color green)"synced to $dst"(set_color normal)
end
