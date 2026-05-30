function harpoon --description "Stores/reads file paths in a per-working directory temp file"
    set -l cache_dir "$HOME/.cache/fish-harpoon"
    if not test -d $cache_dir
        mkdir $cache_dir
    end

    set -l key (echo $PWD | md5 -r | head -c 16)
    set -l harpoon_file "$cache_dir/$key"

    switch $argv[1]
        case hook
            if test -z "$argv[2]"
                echo "harpoon hook: missing filename" >&2
                return 1
            end
            set -l target $argv[2]
            if not test -f $harpoon_file
                echo $target >$harpoon_file
            else if rg "^$target\$" $harpoon_file
                rg -v "^$target\$" $harpoon_file >$harpoon_file.tmp
                mv $harpoon_file.tmp $harpoon_file
            else
                echo $target >>$harpoon_file
            end
        case get
            if test -z "$argv[2]"
                echo "harpoon get: missing line number" >&2
                return 1
            end
            sed -n "$argv[2]p" $harpoon_file
        case edit
            echo $harpoon_file
        case \*
            echo "Usage: harpoon (hook|get N|edit)"
    end
end
