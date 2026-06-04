-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here


-- The standard
vim.keymap.set('i', '<C-c>', '<Esc>', { desc = 'Break out of insert mode' })

-- Overwrites
vim.keymap.set('n', '<C-left>', '<cmd>wincmd h<cr>', { desc = 'Go to the left window' })
vim.keymap.set('n', '<C-right>', '<cmd>wincmd l<cr>', { desc = 'Go to the right window' })
vim.keymap.set('n', '<C-r>', '<cmd>vertical resize -2<cr>', { desc = 'Decrease Window Width' })
vim.keymap.set('n', '<C-l>', '<cmd>vertical resize +2<cr>', { desc = 'Increase Window Width' })

-- Custom
vim.keymap.set('x', '<leader>p', [["_dP]], { desc = 'Paste without yanking' })
vim.keymap.set({ 'n', 'x' }, 'x', '"_x', { desc = 'Delete character without copying to register' })

vim.keymap.set({ 'n', 'x' }, 'q', '<Nop>')
vim.keymap.set('n', 'Q', '<Nop>')
vim.keymap.set('n', '<C-q>', 'q', { desc = 'Start/Stop recording a macro' })

vim.keymap.set({ 'n', 'x' }, '<C-d>', '<C-d>zz', { desc = 'Scroll down and center screen on cursor' })
vim.keymap.set({ 'n', 'x' }, '<C-u>', '<C-u>zz', { desc = 'Scroll up and center screen on cursor' })

vim.keymap.set('x', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move selection down a line' })
vim.keymap.set('x', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move selection up a line' })

vim.keymap.set({ 'n', 'x' }, 'U', '<cmd>redo<CR>')

vim.keymap.set({ 'n', 'v' }, 'gh', '^')
vim.keymap.set({ 'n', 'v' }, 'gl', '$')

vim.keymap.set('n', '<leader>yf', '<cmd>let @+=expand("%:.")<CR>', { desc = 'Yank filepath' })
vim.keymap.set('n', '<leader>yF', '<cmd>let @+=expand("%:p")<CR>', { desc = 'Yank absolute filepath' })
vim.keymap.set('n', '<leader>yd', '<cmd>let @+=expand("%:.:h")<CR>', { desc = 'Yank directory' })
vim.keymap.set('n', '<leader>yD', '<cmd>let @+=expand("%:p:h")<cr>', { desc = 'yank absolute directory' })

-- Smart line delete that won't write whitespace lines to the copy register
_G.smart_delete_init = function()
  vim.go.operatorfunc = 'v:lua.smart_delete'
  return 'g@l'
end
_G.smart_delete = function()
  local line = vim.api.nvim_get_current_line()
  if line:match('^%s*$') then
    vim.cmd('normal! "_dd')
  else
    vim.cmd('normal! dd')
  end
end
vim.keymap.set('n', 'dd', smart_delete_init, { expr = true })

vim.keymap.set({ 'n', 'x' }, '<leader>oc', function()
  local r, c = unpack(vim.api.nvim_win_get_cursor(0))
  local escaped_path = vim.fn.shellescape(vim.fn.expand('%:p'))
  vim.cmd(string.format(
    'silent !cursor -r --folder-uri file://%s -g %s:%s:%s',
    vim.fn.getcwd(),
    escaped_path,
    r,
    c + 1 -- Add 1 to convert from 0-indexed to 1-indexed
  ))
end, { desc = '[O]pen in [C]ursor' })

local function fast_quit()
  -- Check if we're in a file (not in a directory or empty buffer)
  local file = vim.fn.expand('%:p')
  if file ~= '' then
    return true
  end

  return false
end

if fast_quit() then
  vim.keymap.set('n', 'q', '<cmd>q<CR>', { desc = 'Quit' })
end
