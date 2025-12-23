{ config, pkgs, inputs, ... }:

{
  ################################
  ## Home Manager identity
  ################################
  home.username = "chris";
  home.homeDirectory = "/home/chris";
  home.stateVersion = "25.05";

  ################################
  ## Home-Manager-specific nixpkgs config
  ## CHANGED: this block is new to allow unfree (discord) on the HM side.
  ################################
  nixpkgs = {
    config = {
      # Allow unfree packages for this user (Home Manager pkgs)
      allowUnfree = true;

      # Optionally restrict which unfree packages are allowed:
      allowUnfreePredicate = pkg:
        builtins.elem (pkgs.lib.getName pkg) [
          "discord"
        ];
    };
  };

  ################################
  ## Imports: user-only modules
  ################################
  imports = [
    ../modules/user-packages.nix
    ./theme.nix
    ./sway-config.nix
    inputs.noctalia.homeModules.default
  ];
  
  ################################
  ## Shell & editor
  ################################
  programs.neovim.enable = true;
  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal.family = "JetBrainsMono Nerd Font";
        size = 14.0;
      };
    };
  };

  programs.zsh = {
    enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "agnoster";
    };

    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initContent = ''
      export PATH="$HOME/.local/bin:$PATH"
    '';
  };

  # Add ~/.local/bin to PATH via Home Manager
  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  ################################
  ## GPG Agent (user-level)
  ################################
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-gtk2;
  };

  ################################
  ## Noctalia Shell Configuration
  ################################
  programs.noctalia-shell = {
    enable = true;
    systemd.enable = true;
  };

  # Fix Noctalia service environment and startup issues
  systemd.user.services.noctalia-shell = {
    # Correct systemd service configuration
    Service = {
      # Clean up stale QuickShell runtime files before starting
      ExecStartPre = "${pkgs.writeShellScript "noctalia-cleanup" ''
        #!/bin/sh
        # Remove stale QuickShell symlinks that cause startup failures
        rm -rf /run/user/$UID/quickshell/by-path/* 2>/dev/null || true
        rm -rf /run/user/$UID/quickshell/by-shell/* 2>/dev/null || true
      ''}";
      
      # Restart on failure to handle Wayland connection issues
      Restart = "on-failure";
      RestartSec = "2s";
      
      # Comprehensive PATH for Noctalia with all required tools
      Environment = [
        "PATH=${pkgs.coreutils}/bin:${pkgs.systemd}/bin:${pkgs.gnugrep}/bin:${pkgs.findutils}/bin:${pkgs.gnused}/bin:${pkgs.gawk}/bin:${pkgs.bash}/bin:${pkgs.sway}/bin:${pkgs.networkmanager}/bin:${pkgs.fontconfig}/bin:${pkgs.util-linux}/bin:/home/chris/.nix-profile/bin:/run/current-system/sw/bin"
      ];
    };

    # Ensure proper startup order
    Unit = {
      # Wait for graphical session target
      After = [ "graphical-session.target" ];
    };
  };

}

