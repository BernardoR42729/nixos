# These arguments (pkgs, inputs, username) are passed from 'specialArgs'
# defined in your flake.nix when Home Manager evaluates this file.
{
  pkgs,
  inputs,
  username,
  ...
}: {
  # Home Manager needs a state version.
  # Update this when you significantly update Home Manager or Nixpkgs.
  # It helps Home Manager manage configuration transitions smoothly.
  home.stateVersion = "24.05"; # Or your current NixOS version (e.g., "24.05" if using unstable)

  # These are fundamental settings for Home Manager.
  home.username = username; # Use the username passed from flake.nix
  home.homeDirectory = "/home/${username}";

  # This allows Home Manager to manage its own necessary files and scripts.
  programs.home-manager.enable = true;

  # Install packages specifically for this user.
  # 'with pkgs;' brings all package names from 'pkgs' into the current scope,
  # so you can write 'git' instead of 'pkgs.git'.
  home.packages = with pkgs; [
    # Add other user-specific command-line tools here, e.g., neofetch, htop
    calibre
    legcord
    protonvpn-gui
    fastfetch

    # browsers
    brave
    vivaldi

    onedrive
    nwg-displays
    obsidian
    gh
    zellij
    gcc
    ripgrep

    # coding
    jetbrains.idea-community
    code-cursor
    vscode
    docker
    helix
    inputs.Lumi.packages.${system}.default
  ];

  # Example: Declaratively configure Git.
  # Home Manager will write the appropriate ~/.gitconfig.
  programs.git = {
    enable = true;
    userName = "bernardo";
    userEmail = "b.rosario@campus.fct.unl.pt";
    extraConfig = {
      credential = {
        helper = "!gh auth git-credential";
      };
    };
  };

  programs.neovim = {
    enable = true;
  };

  programs.zoxide.enable = true;

  # We will add Hyprland's user-specific configuration here later.
  # For example, Hyprland's main config file, Waybar config, Kitty config, etc.
}
