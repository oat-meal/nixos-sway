{ config, pkgs, lib, ... }:

{
  #############################
  ## GTK / Icons / Cursor
  #############################

  home.pointerCursor = {
    name = "catppuccin-macchiato-dark-cursors";
    package = pkgs.catppuccin-cursors;
    size = 24;
  };

  gtk = {
    enable = true;

    theme = {
      name = "catppuccin-macchiato-mauve-standard+default";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "mauve" ];
        variant = "macchiato";
      };
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.catppuccin-papirus-folders;
    };
  };


  #############################
  ## Wofi styling
  #############################

  xdg.configFile."wofi/style.css".text = ''
    window {
      margin: 5px;
      border: 2px solid #c6a0f6;  /* catppuccin-macchiato mauve */
      background-color: #24273a;  /* catppuccin-macchiato base */
      border-radius: 16px;
    }

    #input {
      margin: 5px;
      border: none;
      color: #cad3f5;  /* catppuccin-macchiato text */
      background-color: #1e2030;  /* catppuccin-macchiato mantle */
      border-radius: 16px;
    }

    #inner-box {
      margin: 5px;
      border: none;
      background-color: #24273a;  /* catppuccin-macchiato base */
      border-radius: 16px;
    }

    #outer-box {
      margin: 5px;
      border: none;
      background-color: #24273a;  /* catppuccin-macchiato base */
      border-radius: 16px;
    }

    #scroll {
      margin: 0px;
      border: none;
      border-radius: 16px;
      margin-bottom: 5px;
    }

    #text {
      margin: 5px;
      border: none;
      color: #cad3f5;  /* catppuccin-macchiato text */
    }

    #entry {
      margin: 5px;
      border: none;
      border-radius: 16px;
      background-color: transparent;
    }

    #entry:selected {
      background-color: #c6a0f6;  /* catppuccin-macchiato mauve */
      color: #24273a;  /* catppuccin-macchiato base */
    }

    #entry:selected #text {
      color: #24273a;  /* catppuccin-macchiato base */
    }
  '';

  #############################
  ## Mako notifications
  #############################

  xdg.configFile."mako/config".text = ''
    background-color=#24273a
    text-color=#cad3f5
    border-color=#c6a0f6
    border-radius=16
    border-size=2
    default-timeout=5000
    margin=10
    padding=15

    [urgency=low]
    border-color=#8bd5ca

    [urgency=normal]
    border-color=#c6a0f6

    [urgency=high]
    border-color=#ed8796
    default-timeout=0

    [mode=dnd]
    invisible=1
  '';

  #############################
  ## Swaylock-effects
  #############################

  xdg.configFile."swaylock/config".text = ''
    font=JetBrains Mono
    color=24273a
    indicator-radius=140
    indicator-thickness=20
    inside-color=24273a
    ring-color=494d64
    line-color=00000000
    separator-color=00000000

    inside-clear-color=f4dbd6
    line-clear-color=00000000
    ring-clear-color=f4dbd6

    inside-ver-color=8bd5ca
    line-ver-color=00000000
    ring-ver-color=8bd5ca

    inside-wrong-color=ed8796
    line-wrong-color=00000000
    ring-wrong-color=ed8796

    key-hl-color=c6a0f6
    bs-hl-color=ed8796
    caps-lock-key-hl-color=f5a97f
    caps-lock-bs-hl-color=ed8796

    text-color=cad3f5
    text-clear-color=24273a
    text-ver-color=24273a
    text-wrong-color=24273a
    text-caps-lock-color=f5a97f

    effect-blur=7x5
    effect-vignette=0.5:0.5
    grace=2
    grace-no-mouse
    grace-no-touch
    datestr="%a, %B %e"
    timestr="%I:%M %p"
    fade-in=0.2
    ignore-empty-password
    show-failed-attempts
  '';
}
