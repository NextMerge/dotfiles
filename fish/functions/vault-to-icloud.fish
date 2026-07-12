function vault-to-icloud --description "One-way rsync of ~/gitter/Plexus to iCloud Drive"
    set -l src ~/gitter/Plexus/
    set -l dst "~/Library/Mobile Documents/com~apple~CloudDocs/Documents/Plexus Backup/"

    if test (count $argv) -gt 0; and test $argv[1] = "-n"
        echo (set_color yellow)"dry run:"(set_color normal)
        /usr/bin/rsync -avni --delete $src $dst
        return
    end

    set -l start (/bin/date +%s)
    /usr/bin/rsync -a --delete $src $dst
    set -l rsync_status $status
    set -l end (/bin/date +%s)

    if test $rsync_status -eq 0
        echo (set_color green)"done in "(math "$end - $start")"s"(set_color normal)
    else
        echo (set_color red)"rsync failed (exit $rsync_status)"(set_color normal)
    end
end
