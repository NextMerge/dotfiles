-- bootstrap lazy.nvim, LazyVim and your plugins
require('config.lazy')

local function is_root_dir()
  local cwd = vim.fn.getcwd()
  local home = vim.fn.expand('~')
  return cwd == '/' or cwd == home
end

if is_root_dir() then
  for _ = 1, 5 do
    Snacks.notifier.notify(
      'You are currently in the root directory!',
      'warn',
      { style = 'compact', timeout = 10000, title = 'Root Directory Warning' }
    )
  end
end
