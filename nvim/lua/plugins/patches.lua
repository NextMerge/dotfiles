-- A collection of fixes and patches for various plugins

return {
  {
    'folke/noice.nvim',
    opts = {
      routes = {
        -- { -- Hide error spam every time autocomplete is triggered
        --   filter = {
        --     error = true,
        --     find = '.*blink.cmp.*reactive.nvim.*',
        --   },
        --   opts = {
        --     skip = true,
        --   },
        -- },
      },
    },
  },
}
