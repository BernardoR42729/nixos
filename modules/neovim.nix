{ inputs, pkgs, ... }:
{
  enable = true;
  neovim = pkgs.neovim-unwrapped;

  # all files in the `lua/lazy` folder are now autoloaded, so no need
  # for an init.lua in there
  initLua = ''
             require('wyz')
             require('lz.n').load('lazy')

             --vim.lsp.enable({ "fish_lsp", "gleam", "lua_ls", "nixd",
    --"basedpyright", "ts_ls", "marksman", "tinymist", "clangd" })
  '';

  extraBinPath = import ./binaries.nix { inherit pkgs; };

  plugins = {
    start = with pkgs.vimPlugins; [
      # Essentials
      lz-n # Lazy loading, without package management
      which-key-nvim
      plenary-nvim
      telescope-ui-select-nvim
      telescope-fzf-native-nvim
      telescope-nvim
      oil-nvim
      auto-session
      blink-cmp
      conform-nvim
      # fzf-lua
      lsp-progress-nvim
      nvim-autopairs
      nvim-surround
      rainbow-delimiters-nvim
      yazi-nvim

      # Neat features
      # colorful-menu-nvim # Show completion types in color
      # cutlass-nvim
      # fugitive
      # vim-rhubarb # Make `:GBrowse` from fugitive work with Github
      # hlargs-nvim # Highlight function arguments (in supported languages)
      # luasnip
      # nvim-highlight-colors # Highlight hex codes
      # snacks-nvim
      # ts-comments-nvim # Lets me have multiple comment strings for `gcc` action
      # tiny-inline-diagnostic-nvim # Better `virtual_lines` from nvim 0.11

      # mini-nvim stuff
      mini-ai
      mini-comment
      mini-extra # More textobjects for mini-ai
      mini-indentscope
      mini-pick

      # Colorschemes
      catppuccin-nvim
      onedarkpro-nvim
      tokyonight-nvim

     # Filetype-specific
      helpview-nvim
      markdown-preview-nvim
      nvim-jdtls
      typst-preview-nvim
      nvim-treesitter.withAllGrammars

      # Dependencies
      nvim-web-devicons
    ];

    # Anything that you're loading lazily should be put here
    opt = with pkgs.vimPlugins; [
      lualine-nvim
      nvim-lspconfig
      # nvim-treesitter.withAllGrammars
    ];

    dev.config = {

      # you can use lib.fileset to reduce rebuilds here
      # https://noogle.dev/f/lib/fileset/toSource
      pure = ../config/nvim;
      impure =
        # This is a hack it should be a absolute path
        # here it'll only work from this directory
        "/home/bernardo/nixos/config/nvim";
    };
  };
}
