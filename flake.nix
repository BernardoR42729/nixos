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

    nvim = {
      # url = "github:BernardoR73286/nvim";
      url = "path:/home/bernardo/nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # hyprland = {
    #   url = "github:hyprwm/Hyprland";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # nvf = {
    #   url = "github:notashelf/nvf";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak";
    };

    mnw.url = "github:Gerg-L/mnw";

    # quickshell = {
    #   url = "github:outfoxxed/quickshell";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # DMS shell
    # dgop = {
    #   url = "github:AvengeMedia/dgop";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    dank-material-shell = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # ---
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      # IMPORTANT: we're using "libgbm" and is only available in unstable so ensure
      # to have it up-to-date or simply don't specify the nixpkgs input
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      # Define some reusable variables for your configurations.
      username = "bernardo";
      hostname = "nixos";
      system = "x86_64-linux";
    in
    {
      packages.${system} =
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = inputs.mnw.lib.wrap pkgs ./modules/neovim.nix;
        };

      devShells =
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShellNoCC {
            packages = [
              self.packages.${system}.default.devMode
            ];
          };
        };

      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        inherit system; # Pass the architecture.

        specialArgs = {
          inherit
            inputs
            username
            hostname
            self
            ;
        };

        modules = [
          # Import your main system configuration file.
          ./configuration.nix
          # inputs.mnw.nixosModules.default
          inputs.hjem.nixosModules.default
          inputs.nix-flatpak.nixosModules.nix-flatpak
        ];
      };
    };
}
