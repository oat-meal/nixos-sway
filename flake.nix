{
  # Top-level metadata and configuration for this NixOS system flake.
  description = "NixOS desktop configuration with SwayFX compositor and Steam, using Home Manager.";

  #############################
  ## Flake Inputs
  #############################

  inputs = {
    # Stable NixOS 25.05 channel
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    # Unstable channel, used only for selected packages (e.g. Discord)
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager for per-user configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  #############################
  ## Flake Outputs
  #############################

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }:
    let
      # Target system architecture
      system = "x86_64-linux";

      # Helper: create a NixOS system with shared specialArgs and module list
      mkSystem = modules: nixpkgs.lib.nixosSystem {
        inherit system;

        # Make flake inputs available to all modules
        specialArgs = {
          inherit system;
          inputs = {
            inherit self nixpkgs nixpkgs-unstable home-manager;
          };
        };

        modules = modules;
      };
    in {
      ########################################
      ## Desktop Machine Configuration
      ########################################

      nixosConfigurations.desktop-nixos = mkSystem [
        # Host-specific config: filesystems, users, services, etc.
        ./hosts/desktop.nix

        # Global system packages (stable) and grouping
        ./modules/system-packages.nix

        # Overlay to expose unstable packages under pkgs.unstable.*
        ./modules/unstable-packages.nix

        # Gaming / Steam-specific system configuration
        ./modules/steam.nix

        # SwayFX compositor and Wayland desktop configuration
        ./modules/sway.nix

        # Integrate Home Manager as a NixOS module
        home-manager.nixosModules.home-manager

        # Per-user Home Manager configuration (for user "chris")
        {
          home-manager.users.chris = import ./home/desktop-user.nix;
        }

        # Extra arguments/settings for Home Manager
        {
          home-manager.extraSpecialArgs = { inherit system; };
          home-manager.backupFileExtension = "hm_bak";
        }
      ];
    };
}
