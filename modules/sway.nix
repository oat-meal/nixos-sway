{ config, pkgs, lib, ... }:

{
  ########################################
  ## Sway (SwayFX) Compositor
  ########################################

  programs.sway = {
    enable = true;
    package = pkgs.swayfx;

    # Provide GTK integration inside the wrapper
    wrapperFeatures.gtk = true;

    # Extra environment variables for Wayland sessions
    extraSessionCommands = ''
      export XDG_SESSION_TYPE=wayland
      export MOZ_ENABLE_WAYLAND=1
      export SDL_VIDEODRIVER=wayland
      export WLR_NO_HARDWARE_CURSORS=1
    '';
  };

  ########################################
  ## Optional greetd override
  ##
  ## NOTE:
  ##   Your main greetd config is in hosts/desktop.nix.
  ##   Keep these lines commented unless you decide to
  ##   centralize greetd logic here instead.
  ########################################

  # services.greetd.settings.default_session = {
  #   command = "${pkgs.swayfx}/bin/sway";
  #   user = "chris";
  # };
}
