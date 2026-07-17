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
    opts = function()
      local gitActions = {
        actions = {
          ['open_file'] = function(picker)
            local currentCommit = picker:current().commit
            picker:close()
            vim.cmd('Gitsigns show ' .. currentCommit)
          end,
        },
        win = {
          input = {
            keys = {
              ['<CR>'] = {
                'open_file',
                desc = 'Open File',
                mode = { 'n', 'i' },
              },
              ['<c-d>'] = {
                'diffview',
                desc = 'Diffview',
                mode = { 'n', 'i' },
              },
            },
          },
        },
      }

      return {
        dashboard = {
          preset = {
            header = '',
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
              filter = {
                cwd = true,
              },
            },
            files = { hidden = true },
            help = {
              win = {
                input = {
                  keys = {
                    ['<CR>'] = { 'tab', mode = { 'n', 'i' } },
                  },
                },
              },
            },
            git_log = gitActions,
            git_log_file = gitActions,
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
      }
    end,
  },
  {
    'folke/flash.nvim',
    opts = {
      label = {
        uppercase = false,
      },
    },
    keys = {
      { 'S', mode = { 'n', 'x', 'o' }, false },
      { 's', mode = { 'o' }, false },
      {
        'gw',
        function()
          local flash_lib = (require)('flash')

          local function format(opts)
            -- always show first and second label
            return {
              { opts.match.label1, 'FlashLabel' },
              { opts.match.label2, 'FlashLabel' },
            }
          end

          flash_lib.jump({
            search = { mode = 'search' },
            label = { after = false, before = { 0, 0 }, uppercase = false, format = format },
            pattern = [[\<]],
            action = function(match, state)
              state:hide()
              flash_lib.jump({
                search = { max_length = 0 },
                highlight = { matches = false },
                label = { format = format },
                matcher = function(win)
                  -- limit matches to the current label
                  return vim.tbl_filter(function(m)
                    return m.label == match.label and m.win == win
                  end, state.results)
                end,
                labeler = function(matches)
                  for _, m in ipairs(matches) do
                    m.label = m.label2 -- use the Second label
                  end
                end,
              })
            end,
            labeler = function(matches, state)
              local labels = state:labels()
              for m, match in ipairs(matches) do
                match.label1 = labels[math.floor((m - 1) / #labels) + 1]
                match.label2 = labels[(m - 1) % #labels + 1]
                match.label = match.label1
              end
            end,
          })
        end,
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
        },
        {
          mode = 'n',
          { '<leader>y', group = '+yank' },
        },
      },
    },
    triggers = {
      { '<auto>', mode = 'nixsotc' },
    },
  },
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc, silent = true })
        end

        -- stylua: ignore start
        map("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next")
          end
        end, "Next Hunk")
        map("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev")
          end
        end, "Prev Hunk")
        map("n", "]H", function() gs.nav_hunk("last") end, "Last Hunk")
        map("n", "[H", function() gs.nav_hunk("first") end, "First Hunk")
        map({ "n", "x" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        map({ "n", "x" }, "dp", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "dP", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
        map("n", "<leader>ghB", function() gs.blame() end, "Blame Buffer")
        map("n", "<leader>ghd", gs.diffthis, "Diff This")
        map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
      end,
    },
  },
  {
    'nvim-lualine/lualine.nvim',
    opts = function(_, opts)
      local currentSymbolIndex = 5
      table.remove(opts.sections.lualine_c, currentSymbolIndex)

      opts.sections.lualine_z = {}
      opts.sections.lualine_y = vim.deepcopy(opts.sections.lualine_x)
      opts.sections.lualine_x = {}
      -- local currentTimeIndex = 0
      -- table.remove(opts.sections.lualine_z, currentTimeIndex)
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
          ---@diagnostic disable-next-line: param-type-mismatch
          vim.api.nvim_exec_autocmds('User', { pattern = 'ConformStart' })
          LazyVim.format({ force = true })
        end,
        mode = { 'n', 'x' },
        desc = 'Format Injected Langs',
      },
    },
  },
  {
    'neovim/nvim-lspconfig',
    opts = {
      inlay_hints = { enabled = false },
      servers = {
        oxlint = {
          enabled = false,
          mason = false,
        },
      },
    },
  },
  {
    'catppuccin',
    -- opts = {
    --   transparent_background = true,
    -- },
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

  {
    'nvim-mini/mini.operators',
    version = '*',
    opts = {
      exchange = {
        prefix = 'cx',

        -- Whether to reindent new text to match previous indent
        reindent_linewise = true,
      },
      replace = {
        prefix = 'cr',

        -- Whether to reindent new text to match previous indent
        reindent_linewise = true,
      },
      sort = {
        prefix = '',
      },
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
  {
    'cbochs/grapple.nvim',
    dependencies = {
      { 'nvim-tree/nvim-web-devicons', lazy = true },
    },
    event = { 'BufReadPost', 'BufNewFile' },
    cmd = 'Grapple',
    opts = {
      scope = 'git',
    },
    keys = {
      { '<leader>m', '<cmd>Grapple toggle<cr>', desc = 'Tag a file' },
      { '<leader>M', '<cmd>Grapple toggle_tags<cr>', desc = 'Toggle tags menu' },
      {
        '<C-h>',
        '<cmd>Grapple select index=1<cr>',
        desc = 'Select tag 1',
      },
      {
        '<C-t>',
        '<cmd>Grapple select index=2<cr>',
        desc = 'Select tag 2',
      },
      {
        '<C-n>',
        '<cmd>Grapple select index=3<cr>',
        desc = 'Select tag 3',
      },
      {
        '<C-s>',
        '<cmd>Grapple select index=4<cr>',
        desc = 'Select tag 4',
      },
    },
  },
  {
    'cursortab/cursortab.nvim',
    lazy = false, -- The server is already lazy loaded
    build = 'cd server && go build',
    opts = {
      log_level = 'debug',
      provider = {
        type = 'mercuryapi',
        api_key_env = 'MERCURY_AI_TOKEN',
      },
    },
  },

  -- Broken with snacks.nvim: https://github.com/rasulomaroff/reactive.nvim/issues/28
  -- Test man thest
  -- { -- Line highlighting depending on current mode
  --   'rasulomaroff/reactive.nvim',
  --   event = 'VeryLazy',
  --   opts = {
  --     load = { 'catppuccin-mocha-cursor', 'catppuccin-mocha-cursorline' },
  --   },
  -- },
}
