{ config, pkgs, lib, ... }:

{
  ##############################
  ## Steam Client + Proton GE ##
  ##############################

  programs.steam = {
    enable = true;

    # Proton-GE for better compatibility
    extraCompatPackages = [ pkgs.proton-ge-bin ];

    # Firewall exceptions for Remote Play, etc.
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = false;
  };

  ####################################
  ## Vulkan, OpenGL, 32-bit Support ##
  ####################################

  hardware.graphics = {
    enable = true;      # Enables Mesa/Vulkan GPU stack
    enable32Bit = true; # REQUIRED for Steam + Proton
  };

  #########################################
  ## Wayland + Steam Environment
  #########################################

  environment.sessionVariables = {
    # Wayland-native Steam UI / SDL
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    XDG_SESSION_TYPE = "wayland";

    # Allow fallback for some Proton games
    QT_QPA_PLATFORM = "wayland;xcb";

    # GPU vendor detection
    __GLX_VENDOR_LIBRARY_NAME = "mesa";

    # Example: Steam UI scaling if needed
    STEAM_FORCE_DESKTOPUI_SCALING = "1";
  };

  ##################
  ## FHS Container ##
  ##################
  #
  # This setting is global (see hosts/desktop.nix) and ensures
  # unfree packages like Steam are allowed:
  #
  #   nixpkgs.config.allowUnfree = true;
  #
}
