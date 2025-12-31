return {
  {
    'folke/snacks.nvim',
    keys = {
      { '<leader>e', false },
      { '<leader>E', false },
      {
        '<leader>fr',
        function()
          Snacks.picker.recent({ filter = { cwd = true } })
        end,
        desc = 'Recent (cwd)',
      },
      { '<leader>fR', LazyVim.pick('oldfiles'), desc = 'Recent' },
      {
        '<leader><space>',
        function()
          Snacks.picker.smart()
        end,
        desc = 'Smart Find Files',
      },
    },
    opts = {
      dashboard = {
        preset = {
          keys = {
            { icon = ' ', key = 'f', desc = 'Find File', action = ":lua Snacks.dashboard.pick('files')" },
            { icon = ' ', key = 'g', desc = 'Find Text', action = ":lua Snacks.dashboard.pick('live_grep')" },
            {
              icon = ' ',
              key = 'r',
              desc = 'Recent Files',
              action = ":lua Snacks.dashboard.pick('oldfiles', { filter = { cwd = true } })",
            },
            {
              icon = ' ',
              key = 'c',
              desc = 'Config',
              action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
            },
            { icon = ' ', key = 's', desc = 'Restore Session', section = 'session' },
            { icon = ' ', key = 'x', desc = 'Lazy Extras', action = ':LazyExtras' },
            { icon = '󰒲 ', key = 'l', desc = 'Lazy', action = ':Lazy' },
            { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
          },
        },
      },
      picker = {
        win = {
          input = {
            keys = {
              ['<Esc>'] = { 'close', mode = { 'n', 'i' } },
              ['<C-c>'] = 'cancel',
            },
          },
        },
        sources = {
          smart = {
            multi = { 'buffers', 'recent', 'files', 'git_files' },
            filter = { cwd = true },
          },
          help = {
            win = {
              input = {
                keys = {
                  ['<CR>'] = { 'tab', mode = { 'n', 'i' } },
                },
              },
            },
          },
        },
      },
      scratch = {
        filekey = {
          branch = false,
        },
      },
      words = {
        enabled = false,
      },
    },
  },
  {
    'nvim-mini/mini.files',
    keys = {
      {
        '<leader>e',
        function()
          local mf = require('mini.files')
          if not mf.close() then
            mf.open(vim.api.nvim_buf_get_name(0), true)
          end
        end,
        desc = 'Open mini.files (Directory of Current File)',
      },
      {
        '<leader>E',
        function()
          local mf = require('mini.files')
          if not mf.close() then
            mf.open(vim.uv.cwd(), true)
          end
        end,
        desc = 'Open mini.files (cwd)',
      },
    },
    opts = {
      mappings = {
        go_in_plus = '<CR>',
        go_out_plus = '<BS>',
        mark_goto = '',
        mark_set = '',
        reset = '<Del>',
      },
    },
  },
  {
    'nvim-mini/mini.surround',
    vscode = true,
    opts = {
      mappings = {
        add = 'ma', -- Add surrounding in Normal and Visual modes
        delete = 'md', -- Delete surrounding
        find = 'mf', -- Find surrounding (to the right)
        find_left = 'mF', -- Find surrounding (to the left)
        highlight = 'mh', -- Highlight surrounding
        replace = 'mr', -- Replace surrounding
        update_n_lines = 'mn', -- Update `n_lines`
      },
    },
  },
  {
    'nvim-mini/mini.operators',
    vscode = true,
    lazy = false,
    version = '*',
    opts = {
      -- Evaluate text and replace with output
      evaluate = {
        prefix = 'mo=',
      },

      -- Exchange text regions
      exchange = {
        prefix = 'mox',
      },

      -- Multiply (duplicate) text
      multiply = {
        prefix = 'mom',
      },

      -- Replace text with register
      replace = {
        prefix = 'mor',
      },

      -- Sort text
      sort = {
        prefix = 'mos',
      },
    },
    keys = {
      { 'mo', '', mode = { 'n', 'x' }, desc = '+operators' },
    },
  },
  {
    'nvim-mini/mini.ai',
    opts = {
      custom_textobjects = {
        -- JSX attributes
        j = {
          {
            { '[%S^]%s+%w+=%b{}', '^.()%s+%w+={().*()}()' },
            { '[%S^]%s+%w+=%b""', '^.()%s+%w+="().*()"()' },
          },
        },
        ['-'] = {
          {
            '[%s"]()()[%w-:%[%]]+()%s?()"?',
          },
        },
      },
    },
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    opts = function()
      local tsc = require('treesitter-context')
      Snacks.toggle({
        name = 'Treesitter Context',
        get = tsc.enabled,
        set = function(state)
          if state then
            tsc.enable()
          else
            tsc.disable()
          end
        end,
      }):map('<leader>ut')

      vim.keymap.set('n', '<leader>tc', function()
        tsc.go_to_context(vim.v.count1)
      end, { silent = true, desc = 'Go up Treesitter Code Context' })

      return { mode = 'cursor', max_lines = 3 }
    end,
  },
  {
    'folke/which-key.nvim',
    url = 'https://github.com/NextMerge/which-key.nvim.git',
    opts = {
      delay = 0,
      keys = {
        scroll_down = '<PageDown>',
        scroll_up = '<PageUp>',
      },
      spec = {
        {
          mode = { 'n', 'x' },
          { '<leader>t', group = '+tab/treesitter' },
          { '<leader>h', group = '+gitsigns' },
          { 'm', group = '+mini' },
        },
        {
          mode = 'n',
          { '<leader>y', group = '+yank' },
        },
        {
          mode = 'x',
          { '<leader>d', 'Delete without writing to the copy register' },
        },
      },
    },
    triggers = {
      { '<auto>', mode = 'nixsotc' },
      { 'm', mode = { 'n', 'x' } },
    },
  },
  {
    'nvim-lualine/lualine.nvim',
    opts = function(_, opts)
      local currentSymbolIndex = 5
      table.remove(opts.sections.lualine_c, currentSymbolIndex)
    end,
  },
  {
    'folke/noice.nvim',
    opts = {
      routes = {
        { -- Prevent say, the tailwind LSP from spamming this when you hover a TypeScript file
          filter = {
            event = 'notify',
            find = 'No information available',
          },
          opts = {
            skip = true,
          },
        },
      },
    },
  },
  {
    'saghen/blink.cmp',
    opts = {
      completion = {
        ghost_text = {
          enabled = false,
        },
      },
    },
  },
  {
    'stevearc/conform.nvim',
    keys = {
      {
        "'",
        function()
          vim.api.nvim_exec_autocmds('User', { pattern = 'ConformStart' })
          LazyVim.format({ force = true })
        end,
        mode = { 'n', 'x' },
        desc = 'Format Injected Langs',
      },
    },
  },
  {
    'catppuccin',
    opts = {
      transparent_background = true,
    },
  },
  {
    'akinsho/bufferline.nvim',
    enabled = false,
  },
  {
    'folke/todo-comments.nvim',
    enabled = false,
  },

  -- New plugins

  { -- Autosave
    'okuuva/auto-save.nvim',
    cmd = 'ASToggle', -- optional for lazy loading on command
    event = { 'InsertLeave', 'TextChanged' }, -- optional for lazy loading on trigger events
    opts = {
      trigger_events = {
        cancel_deferred_save = { 'InsertEnter', { 'User', pattern = 'ConformStart' } },
      },
    },
  },
  { -- Line highlighting depending on current mode
    'rasulomaroff/reactive.nvim',
    event = 'VeryLazy',
    opts = {
      load = { 'catppuccin-mocha-cursor', 'catppuccin-mocha-cursorline' },
    },
  },
  {
    'christoomey/vim-tmux-navigator',
    init = function()
      vim.g.tmux_navigator_no_mappings = 1
    end,
    cmd = {
      'TmuxNavigateLeft',
      'TmuxNavigateDown',
      'TmuxNavigateUp',
      'TmuxNavigateRight',
      'TmuxNavigatePrevious',
      'TmuxNavigatorProcessList',
    },
    keys = {
      { '<c-left>', '<cmd>TmuxNavigateLeft<cr>' },
      { '<c-j>', '<cmd>TmuxNavigateDown<cr>' },
      { '<c-k>', '<cmd>TmuxNavigateUp<cr>' },
      { '<c-right>', '<cmd>TmuxNavigateRight<cr>' },
      { '<c-\\>', '<cmd>TmuxNavigatePrevious<cr>' },
    },
  },
  {
    'copilotlsp-nvim/copilot-lsp',
    init = function()
      vim.g.copilot_nes_debounce = 500
      vim.lsp.enable('copilot_ls')
      vim.keymap.set({ 'n', 'i' }, '<C-g>', function()
        -- Try to jump to the start of the suggestion edit.
        -- If already at the start, then apply the pending suggestion and jump to the end of the edit.
        local _ = require('copilot-lsp.nes').walk_cursor_start_edit()
          or (require('copilot-lsp.nes').apply_pending_nes() and require('copilot-lsp.nes').walk_cursor_end_edit())
      end)
    end,
  },
}
