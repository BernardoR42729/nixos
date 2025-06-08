{
  description = "My Personal NixOS Configuration Flake";

  # Define all external dependencies (inputs) for your configuration
  inputs = {
    # We're using 'nixos-unstable' for newer packages, especially for Hyprland.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager: For managing user-specific dotfiles and packages.
    home-manager = {
      url = "github:nix-community/home-manager";
      # Crucially, tell Home Manager to use the *same* nixpkgs as our system.
      # This prevents version mismatches and ensures consistency.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";

    # Example: If you wanted to add a specific Hyprland plugin from a flake:
    # hyprland-plugins = {
    #   url = "github:hyprwm/hyprland-plugins";
    #   inputs.nixpkgs.follows = "nixpkgs"; # Also use same nixpkgs
    # };

    nvf.url = "github:notashelf/nvf";
  };

  # Define what this flake provides (outputs)
  # The '@inputs' captures all defined inputs for easy access.
  outputs = { self, nixpkgs, home-manager, nvf, ... }@inputs:
    let
      # Define some reusable variables for your configurations.
      # Change 'yourusername' to your actual Linux username.
      username = "bernardo";
      # Change 'nixos-desktop' to your desired system hostname.
      hostname = "nixos";
      # Specify your system architecture.
      system = "x86_64-linux"; # Common for most PCs. Others: "aarch64-linux" (Raspberry Pi 4/5, some Macs)
    in
    {
      # This is where you define your NixOS system configurations.
      # You can define multiple systems here if you manage several machines.

      packages.system.default =
        (nvf.lib.neovimConfiguration {
	  pkgs = nixpkgs.legacyPackages.system;
	  modules = [ ./modules/nvf-configuration.nix ];
	}).neovim;

      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        inherit system; # Pass the architecture.

        # 'specialArgs' allows you to pass custom arguments (like our inputs or variables)
        # to all modules imported below (i.e., to configuration.nix and home.nix).
        # This is how your configuration files will access 'inputs', 'username', etc.
        specialArgs = { inherit inputs username hostname; };


        modules = [
          # Import your main system configuration file.
          ./configuration.nix
	  nvf.nixosModules.default

          # Import the Home Manager NixOS module.
          # This integrates Home Manager into the system build process.
          home-manager.nixosModules.home-manager
          {
            # Configure Home Manager settings at the system level.
            home-manager.useGlobalPkgs = true; # Allows Home Manager to see system-wide packages.
            home-manager.useUserPackages = true; # Allows users to install their own packages via Home Manager.
            home-manager.extraSpecialArgs = { inherit inputs username; }; # Pass args to home.nix
            home-manager.users.${username} = {
              # For the specified user, import their Home Manager configuration.
              imports = [ ./home.nix ];
            };
          }
        ];
      };

      # Optionally, you can also expose Home Manager configurations directly.
      # This is useful if you want to manage dotfiles on non-NixOS systems
      # or use the standalone `home-manager switch --flake .#yourusername` command.
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system}; # Provide the package set for this user.
        extraSpecialArgs = { inherit inputs username; }; # Pass args to home.nix
        modules = [ ./home.nix ];
      };
    };
}

