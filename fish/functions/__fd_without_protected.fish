function __fd_without_protected
    set fd_args $argv
    begin
        fd $fd_args . $HOME -H \
            --exclude Library \
            --exclude node_modules \
            --exclude Pictures \
            --exclude Music \
            --exclude Movies \
            --exclude "iCloud Drive"
        fd $fd_args . "$HOME/Library/Application Support" -H \
            --exclude node_modules
    end
end

