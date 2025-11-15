{ pkgs, ... }:

{
  ########################################
  ## Home-Manager User Packages
  ##
  ## These packages are installed only for the
  ## "chris" user (via Home Manager), not system-wide.
  ########################################

  home.packages = with pkgs; [
    ################################
    # Unstable Desktop Apps
    ################################

    # Discord from unstable:
    #   - unstable often has a working hash/URL
    #   - stable Discord frequently breaks
    pkgs.unstable.discord

    ################################
    # Stable GUI Applications
    ################################
    firefox
    brave
    mpv

    ################################
    # User Tools / Utilities
    ################################
    wl-clipboard
    unzip
    htop
    ripgrep
  ];
}
