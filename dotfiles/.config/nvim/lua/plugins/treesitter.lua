return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    -- Use pcall so that if it fails, it doesn't break your whole Neovim
    local status, configs = pcall(require, "nvim-treesitter.configs")
    if not status then
      return
    end

    configs.setup({
      ensure_installed = {
        "json", "javascript", "typescript", "tsx", "yaml", "html", "css",
        "c", "cpp", "go", "lua", "vim", "vimdoc",
        "csv", "diff", "xml", "markdown", "markdown_inline", "bash",
      },
      sync_install = false,
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { "markdown" },
      },
      indent = { enable = true },
    })
  end,
}
