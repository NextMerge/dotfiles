function __cmux-lego
  tmux wait-for repo-hydrated

  pnpm --filter lego exec vite build --watch
end
