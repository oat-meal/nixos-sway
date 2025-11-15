{ config, pkgs, ... }:

{
  ##############################################
  ## Home Manager User Identity
  ##############################################

  home.username = "chris";
  home.homeDirectory = "/home/chris";
  home.stateVersion = "25.05";

  ##############################################
  ## Imports (User Packages + Theme)
  ##############################################

  imports = [
    # User-level package list (GUI apps, tools, etc.)
    ../modules/user-packages.nix

    # Theming, GTK, icons, cursors, bar styling, etc.
    ./theme.nix
  ];

  ##############################################
  ## Shell & Editor
  ##############################################

  programs.neovim.enable = true;
  programs.alacritty.enable = true;

  programs.zsh = {
    enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "agnoster";
    };

    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Add ~/.local/bin to PATH inside Zsh
    initExtra = ''
      export PATH="$HOME/.local/bin:$PATH"
    '';
  };

  # Add ~/.local/bin globally to PATH for this user
  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  ##############################################
  ## GPG Agent (User-Level)
  ##############################################

  services.gpg-agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gtk2;
  };
}
