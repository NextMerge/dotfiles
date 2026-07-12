function vault-to-git --description "Backup Plexus vault to local git repo"
    set -l src ~/gitter/Plexus/
    set -l dst ~/gitter/obsidian-git-backup/

    if not test -d $dst/.git
        echo (set_color red)"error: $dst is not a git repo"(set_color normal)
        return 1
    end

    if test (count $argv) -gt 0; and test $argv[1] = "-n"
        echo "dry run:"
        /usr/bin/rsync -avni --delete --exclude='.git/' --filter='P .git/' $src $dst
        return
    end

    set -l start (/bin/date +%s)

    /usr/bin/rsync -a --delete --exclude='.git/' --filter='P .git/' $src $dst

    git -C $dst add -A
    git -C $dst diff --cached --quiet
    set -l diff_status $status

    if test $diff_status -ne 0
        git -C $dst commit -m "backup: "(/bin/date '+%Y-%m-%d %H:%M:%S')
        set -l end (/bin/date +%s)
        echo (set_color green)"committed in "(math "$end - $start")"s"(set_color normal)
   
        git -C $dst push
        set -l end (/bin/date +%s)
        echo (set_color green)"pushed in "(math "$end - $start")"s"(set_color normal)
    else
        echo (set_color yellow)"no changes"(set_color normal)
    end
end
