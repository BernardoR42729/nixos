{
  description = "My Personal NixOS Configuration Flake";

  # Define all external dependencies (inputs) for your configuration
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # home-manager = {
    #   url = "github:nix-community/home-manager";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    hjem = {
      url = "github:feel-co/hjem";
      # You may want hjem to use your defined nixpkgs input to
      # minimize redundancies.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hjem-rum = {
      url = "github:snugnug/hjem-rum";
      # You may want hjem-rum to use your defined nixpkgs input to
      # minimize redundancies.
      inputs.nixpkgs.follows = "nixpkgs";
      # Same goes for hjem, to avoid discrepancies between the version
      # you use directly and the one hjem-rum uses.
      inputs.hjem.follows = "hjem";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak";
    };

    mnw.url = "github:Gerg-L/mnw";

    # Lumi = {
    #   url = "github:BernardoR42729/Lumi";
    # };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    # Define some reusable variables for your configurations.
    username = "bernardo";
    hostname = "nixos";
    system = "x86_64-linux";
  in {
    packages.${system} = {
      neovim = nixpkgs.legacyPackages.${system}.callPackage ./modules/neovim.nix;
    };

    nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
      inherit system; # Pass the architecture.

      specialArgs = {inherit inputs username hostname self;};

      modules = [
        # Import your main system configuration file.
        ./configuration.nix
        ./modules
        inputs.nvf.nixosModules.default
        inputs.hjem.nixosModules.default
        inputs.nix-flatpak.nixosModules.nix-flatpak
      ];
    };
  };
}
