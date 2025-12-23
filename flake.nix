{
  description = "Personal NixOS desktop configuration with COSMIC Desktop, Home Manager, and modular structure";

  ################################
  ## FLAKE INPUTS
  ################################
  inputs = {
    # Stable (system base)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    # Unstable (for Discord, cutting-edge libs, etc.)
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };


  };

  ################################
  ## FLAKE OUTPUTS
  ################################
  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }:
    let
      system = "x86_64-linux";

      # Builder helper
      mkSystem = modules:
        nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit system;
            inputs = {
              inherit self nixpkgs nixpkgs-unstable home-manager;
            };
          };

          modules = modules;
        };
    in {
      ############################################################
      ## NixOS HOST: desktop-nixos
      ############################################################
      nixosConfigurations.desktop-nixos = mkSystem [

        # Host config
        ./hosts/desktop.nix

        # System-level modules
        ./modules/system-packages.nix
        ./modules/unstable-packages.nix
        ./modules/steam.nix
       # ./modules/usb-audio-fixes.nix
        
        # Experimental packages (absolute path for git-ignored files)
      #  (if builtins.pathExists /etc/nixos/modules/experimental-packages.nix 
     #    then /etc/nixos/modules/experimental-packages.nix 
     #    else { })

        ###############################################
        ## HOME MANAGER INTEGRATION
        ###############################################
        home-manager.nixosModules.home-manager

        ###############################################
        ## CRITICAL FIX — ensure HM sees unstable overlay
        ###############################################
        {
          nixpkgs.overlays = [
            (final: prev: {
              unstable = import nixpkgs-unstable {
                inherit system;
                config = prev.config;
              };
            })
          ];

          home-manager.sharedModules = [
            {
              # Make the SAME overlay available in HM
              nixpkgs.overlays = [
                (final: prev: {
                  unstable = import nixpkgs-unstable {
                    inherit system;
                    config = prev.config;
                  };
                })
              ];
            }
          ];

          # HM user definition
          home-manager.users.chris = import ./home/desktop-user.nix;

          # Extra
          home-manager.extraSpecialArgs = { 
            inherit system; 
            inputs = {
              inherit self nixpkgs nixpkgs-unstable home-manager;
            };
          };
          home-manager.backupFileExtension = "hm_bak";
        }
      ];
    };
}

