{
  # Top-level metadata and configuration for this NixOS system flake.
  description = "NixOS desktop configuration with SwayFX compositor and Steam, using Home Manager.";

  ################################
  ## Flake inputs
  ################################
  inputs = {
    # Stable NixOS 25.05
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    # Unstable Nixpkgs, used for select packages (e.g. Discord)
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager for per-user configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Kept for now (not actively used) in case you later want wayland overlay pkgs
    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
  };

  ################################
  ## Flake outputs
  ################################
  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nixpkgs-wayland, ... }:
    let
      system = "x86_64-linux";

      # Helper to build a NixOS system with shared specialArgs
      mkSystem = modules: nixpkgs.lib.nixosSystem {
        inherit system;

        # Make inputs available to all modules
        specialArgs = {
          inherit system;
          inputs = {
            inherit self nixpkgs nixpkgs-unstable home-manager nixpkgs-wayland;
          };
        };

        modules = modules;
      };
    in {
      ########################################
      ## Desktop machine configuration
      ########################################
      nixosConfigurations.desktop-nixos = mkSystem [
        # Host: hardware, filesystems, users, services, etc.
        ./hosts/desktop.nix

        # System-level modules (strict separation):
        ./modules/system-packages.nix
        ./modules/unstable-packages.nix
        ./modules/sway.nix
        ./modules/steam.nix
        ./modules/dms.nix

        # Home Manager integration
        home-manager.nixosModules.home-manager

        # User "chris" home configuration
        {
          home-manager.users.chris = import ./home/desktop-user.nix;
        }

        # Extra args for Home Manager
        {
          home-manager.extraSpecialArgs = { inherit system; };
          home-manager.backupFileExtension = "hm_bak";
        }
      ];
    };
}
