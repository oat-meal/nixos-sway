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


}

