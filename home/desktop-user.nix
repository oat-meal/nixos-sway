{ config, pkgs, ... }:

{
  ################################
  ## Home Manager identity
  ################################
  home.username = "chris";
  home.homeDirectory = "/home/chris";
  home.stateVersion = "25.05";

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

    initExtra = ''
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
    pinentryPackage = pkgs.pinentry-gtk2;
  };
}
