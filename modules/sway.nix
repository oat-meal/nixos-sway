{ config, pkgs, lib, ... }:

{
  ################################
  ## Sway (SwayFX) compositor
  ################################
  programs.sway = {
    enable = true;
    package = pkgs.swayfx;

    wrapperFeatures.gtk = true;

    extraSessionCommands = ''
      export XDG_SESSION_TYPE=wayland
      export MOZ_ENABLE_WAYLAND=1
      export SDL_VIDEODRIVER=wayland
      export WLR_NO_HARDWARE_CURSORS=1
    '';
  };

  # greetd integration lives in hosts/desktop.nix to keep all
  # login/session logic in one place.
}
