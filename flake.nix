{
  description = "My Personal NixOS Configuration Flake";

  # Define all external dependencies (inputs) for your configuration
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    Lumi = {
      url = "github:BernardoR42729/Lumi";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nvf,
    ...
  } @ inputs: let
    # Define some reusable variables for your configurations.
    username = "bernardo";
    hostname = "nixos";
    system = "x86_64-linux";
  in {

    packages.${system}.nvf =
      (nvf.lib.neovimConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [./modules/nvf-configuration.nix];
      }).neovim;

    nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
      inherit system; # Pass the architecture.

      specialArgs = {inherit inputs username hostname;};

      modules = [
        # Import your main system configuration file.
        ./configuration.nix

        # Import the Home Manager NixOS module.
        # This integrates Home Manager into the system build process.
        home-manager.nixosModules.home-manager
        {
          # Configure Home Manager settings at the system level.
          home-manager.useGlobalPkgs = true; # Allows Home Manager to see system-wide packages.
          home-manager.useUserPackages = true; # Allows users to install their own packages via Home Manager.
          home-manager.extraSpecialArgs = {inherit inputs username;}; # Pass args to home.nix
          home-manager.users.${username} = {
            # For the specified user, import their Home Manager configuration.
            imports = [
              ./home.nix
              nvf.homeManagerModules.default
            ];
          };
        }
      ];
    };

    # Optionally, you can also expose Home Manager configurations directly.
    # This is useful if you want to manage dotfiles on non-NixOS systems
    # or use the standalone `home-manager switch --flake .#yourusername` command.
    homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system}; # Provide the package set for this user.
      extraSpecialArgs = {inherit inputs username;}; # Pass args to home.nix
      modules = [
        ./home.nix
        nvf.homeManagerModules.default
      ];
    };
  };
}
