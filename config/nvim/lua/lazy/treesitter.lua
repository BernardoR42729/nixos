return {
  "nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",

  after = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "lua",
        "bash",
        "nu",
        "python",
        "json",
        "yaml",
        "nix",
        "javascript",
        "typescript",
        "java"
        -- etc
      },
      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "gnn",
          node_incremental = "grn",
          node_decremental = "grm",
        },
      },
    })
  end,
}
