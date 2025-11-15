{ pkgs, ... }:

{
  ########################################
  ## Global system packages (stable)
  ########################################
  environment.systemPackages = with pkgs; [
    ######## Core CLI / admin ########
    git
    wget
    curl
    yazi
    pciutils
    usbutils
    lsb-release
    btrfs-progs

    ######## Shell / editors / terminals ########
    zsh
    neovim
    alacritty

    ######## Audio tools ########
    pavucontrol
    pamixer
    pulseaudio      # pactl, pacmd, etc.
    alsa-utils      # alsamixer, speaker-test

    ######## Wayland / desktop plumbing ########
    wayland
    xwayland
    xwayland-satellite

    # Bar, launcher, notifications, wallpapers, lockscreen, screenshots
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

    ######## Gaming / GPU / Vulkan ########
    mangohud
    gamescope
    vulkan-tools
    vulkan-loader
    vulkan-validation-layers
    libdrm
    libxkbcommon
    (pkgs.pkgsi686Linux.vulkan-loader)  # 32-bit Vulkan for Proton

    ######## Multimedia / misc libs ########
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
