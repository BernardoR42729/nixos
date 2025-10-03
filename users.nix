{
  pkgs,
  config,
  username,
  inputs,
  self,
  ...
}: {
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "video" "audio" "disks" "plugdev"]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
    packages = with pkgs; [
      tree
    ];
  };
  # configuration.nix
  hjem = {
    # Importing the modules
    extraModules = [
      inputs.hjem-rum.hjemModules.default
    ];
    # Configuring your user(s)
    users.${username} = {
      enable = true;
      directory = "/home/${username}";
      user = "${username}";
      # files = {
      #   # Hyprland config directory sourced from repo
      #   ".config/hypr/hyprland.conf".source = self + "/config/hyprland.conf";
      # };

      rum.programs.git = {
        enable = true;
        settings = {
          user = {
            email = "b.rosario@campus.fct.unl.pt";
            name = "bernardo";
          };
          init = {
            defaultBranch = "main";
          };
        };
      };

      rum.programs.kitty = {
        enable = true;
        integrations.zsh.enable = true;
        settings = {
          font_size = "12.0";
          shell = ".";
        };
      };
    };
    # You should probably also enable clobberByDefault at least for now.
    clobberByDefault = true;
  };
}
