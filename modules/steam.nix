{ config, pkgs, lib, ... }:

{
  ##############################
  ## Steam client + Proton-GE ##
  ##############################
  programs.steam = {
    enable = true;

    extraCompatPackages = [ pkgs.proton-ge-bin ];

    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = false;
  };

  ####################################
  ## Vulkan / OpenGL / 32-bit stack ##
  ####################################
  hardware.graphics = {
    enable = true;      # Mesa/Vulkan stack
    enable32Bit = true; # Needed for Proton / 32-bit games
  };

  ####################################
  ## Wayland + Steam session env    ##
  ####################################
  environment.sessionVariables = {
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    XDG_SESSION_TYPE = "wayland";
    QT_QPA_PLATFORM = "wayland;xcb";
    __GLX_VENDOR_LIBRARY_NAME = "mesa";
    STEAM_FORCE_DESKTOPUI_SCALING = "1";
  };
}
