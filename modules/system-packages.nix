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

    ######## Networking / WiFi ########
    iw                         # WiFi configuration tool
    iwd                        # Modern WiFi daemon
    networkmanagerapplet       # GUI for NetworkManager (nm-connection-editor)

    ######## VPN / WireGuard ########
   # wgnord
  #  wireguard-tools
   # openresolv

    ######## Shell / editors / terminals ########
    zsh
    neovim
    alacritty
    claude-code

    ######## Audio tools ########
    pavucontrol
    pamixer
    pulseaudio      # pactl, pacmd, etc.
    alsa-utils      # alsamixer, speaker-test

    ######## Wayland / desktop plumbing ########
    wayland
    xwayland
    xwayland-satellite
    swayfx

    # Bar, launcher, notifications, lockscreen, screenshots
    waybar
    wofi
    mako
    swaylock-effects
    grim
    slurp
    swappy

    # Cursor + X11 compatibility libs
    catppuccin-cursors
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
    
    ######## Wine for Windows applications ########
    wine
    winetricks
    protontricks

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
