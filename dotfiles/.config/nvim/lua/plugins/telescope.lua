return {
  'nvim-telescope/telescope.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = {
    defaults = {
      preview = {
        -- This fixes the 'ft_to_lang' nil value error
        treesitter = false,
      },
      mappings = {
        i = {
          -- Make it feel more like a menu: Esc once to close
          ["<esc>"] = function(...) return require("telescope.actions").close(...) end,
        },
      },
    }
  }
}
