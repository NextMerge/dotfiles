function __cmux-portal
    tmux wait-for repo-hydrated

    pnpm --filter portal run paraglide:compile
    pnpm --filter portal run dev
end
