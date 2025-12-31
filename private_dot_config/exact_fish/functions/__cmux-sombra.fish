function __cmux-sombra
    # Check for --now argument to skip tmux wait-for
    set -l skip_wait false
    for arg in $argv
        if test "$arg" = "--now"
            set skip_wait true
            break
        end
    end

    if test "$skip_wait" = false
        tmux wait-for repo-hydrated
    end

    pnpm --filter sombra run generate:translations

    set -l SUCCESS_MESSAGE "Connection to 127.0.0.1 port 5432 [tcp/postgresql] succeeded!"

    set_color cyan
    echo "Waiting for Postgres Database to be available..."
    set_color normal

    while true
        nc -zv 127.0.0.1 5432
        if test $status -eq 0
            set_color green
            echo "Postgres Database is available!"
            set_color normal
            break
        end
        sleep 3
    end
    
    set_color cyan
    echo "Waiting for Hasura to be available..."
    set_color normal

    while true
        curl -s --fail http://localhost:3011/v1/version >/dev/null 2>&1
        if test $status -eq 0
            set_color green
            echo "Hasura is available!"
            set_color normal
            break
        end
        sleep 3
    end

    pnpm --filter sombra exec hasura metadata apply --endpoint http://localhost:3011 --admin-secret secret --project hasura
    pnpm --filter sombra run generate:gql

    set -l MIGRATION_DETECTED_MESSAGE "Batch [0-9]+ run: [0-9]+ migrations"
    set -l MIGRATION_ERROR_MESSAGE "migration failed with error:"

    # Capture the migration output while still displaying it
    set MIGRATION_OUTPUT (pnpm --filter sombra run db:migrate &| tee /dev/tty)

    # Check for successful migration
    if string match -rq "$MIGRATION_ERROR_MESSAGE" "$MIGRATION_OUTPUT"
        osascript -e 'display notification "Knex migration had an error!" with title "Sombra Alert"'
        return
    else if string match -rq "$MIGRATION_DETECTED_MESSAGE" "$MIGRATION_OUTPUT"
        # Migration ran successfully with changes
        osascript -e 'display notification "Database migrations were detected and completed successfully!" with title "Sombra Alert"'

        pnpm --filter sombra exec hasura metadata apply --endpoint http://localhost:3011 --admin-secret secret --project hasura
        pnpm --filter sombra run generate:gql
    end
    
    open "raycast://confetti"

    pnpm --filter sombra run dev
end
