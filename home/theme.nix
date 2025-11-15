{ config, pkgs, lib, ... }:

{
  #############################
  ## GTK / Icons / Cursor
  #############################

  home.pointerCursor = {
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 24;
  };

  gtk = {
    enable = true;

    theme = {
      name = "Adwaita-dark";   # Dark base; can be overridden by custom theme files
      package = pkgs.gnome-themes-extra;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  #############################
  ## Waybar styling
  #############################

  xdg.configFile."waybar/style.css".text = ''
    * {
      font-family: "JetBrains Mono", sans-serif;
      background-color: rgba(18, 18, 26, 0.8);
      color: #cdd6f4;
    }
    #workspaces button.focused {
      background-color: #3b3f52;
      color: #ffffff;
      border-radius: 8px;
    }
  '';

  #############################
  ## Wofi styling
  #############################

  xdg.configFile."wofi/style.css".text = ''
    window {
      background-color: #1e1e2e;
      border-radius: 12px;
    }
    entry {
      background-color: #2a2b3c;
      color: #cdd6f4;
      padding: 6px;
      border-radius: 8px;
    }
  '';

  #############################
  ## Mako notifications
  #############################

  xdg.configFile."mako/config".text = ''
    background-color=#1e1e2e
    text-color=#cdd6f4
    border-color=#585b70
    border-radius=10
    default-timeout=5000
  '';

  #############################
  ## Swaylock-effects
  #############################

  xdg.configFile."swaylock/config".text = ''
    font=JetBrains Mono
    color=1e1e2e
    indicator-radius=140
    inside-color=1e1e2e
    ring-color=585b70
    key-hl-color=8aadf4
  '';
}
