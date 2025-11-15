{ pkgs, ... }:

{
  ########################################
  ## User packages (Home Manager)
  ##
  ## Only applied to "chris" via
  ##   home/desktop-user.nix
  ########################################

  home.packages = with pkgs; [
    ######## Unstable desktop apps ########
    # Discord from unstable because stable often breaks:
    pkgs.unstable.discord

    ######## Stable GUI apps ########
    firefox
    brave
    mpv

    ######## User tools ########
    wl-clipboard
    unzip
    htop
    ripgrep
  ];
}
