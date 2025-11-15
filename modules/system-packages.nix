{ pkgs, ... }:

{
  ########################################
  ## Global System Packages (Stable)
  ##
  ## This module is the single source of truth
  ## for system-wide packages on this host.
  ########################################

  environment.systemPackages = with pkgs; [
    #############################
    # Core CLI / Admin Tools
    #############################
    git
    wget
    curl
    yazi
    pciutils
    usbutils
    lsb-release
    btrfs-progs

    #############################
    # Shell / Editors / Terminals
    #############################
    zsh
    neovim
    alacritty

    #############################
    # Audio / Volume Utilities
    #############################
    pavucontrol       # GUI audio mixer
    pamixer           # Terminal volume control
    pulseaudio        # pactl/pacmd tools
    alsa-utils        # alsamixer, speaker-test

    #############################
    # Wayland / Xwayland / Desktop
    #############################
    wayland
    xwayland
    xwayland-satellite

    # Menu launcher, bar, notifications, wallpapers, etc.
    waybar
    wofi
    mako
    swww
    swaylock-effects
    grim
    slurp
    swappy

    # Cursor + X11 compatibility libs
    bibata-cursors
    xorg.libXcursor
    xorg.libX11
    xorg.libXrandr
    xorg.libXext
    xorg.libxcb

    #############################
    # Gaming / GPU / Vulkan
    #############################
    mangohud
    gamescope
    vulkan-tools
    vulkan-loader
    vulkan-validation-layers
    libdrm
    libxkbcommon

    # 32-bit Vulkan loader for Proton / 32-bit games
    (pkgs.pkgsi686Linux.vulkan-loader)

    #############################
    # Multimedia & Compat Libraries
    #
    # Note:
    #   These are often pulled in as dependencies, but
    #   are listed explicitly here for transparency and
    #   easier debugging if issues arise.
    #############################
    ffmpeg
    libGL
    glib
    gtk3
    libpulseaudio
    libudev0-shim
    alsa-lib
    alsa-plugins
  ];
}
