{ config, pkgs, lib, ... }:

{
  ##############################
  ## Steam client + Proton-GE ##
  ##############################
  # Steam is now installed via systemPackages with custom wrapper
  # programs.steam.enable = false; # Disabled to avoid conflicts

  ##############################
  ## GameMode for performance ##
  ##############################
  programs.gamemode = {
    enable = true;
    enableRenice = true;
    settings = {
      general = {
        renice = 10;
        ioprio = 0;
        inhibit_screensaver = 1;
        softrealtime = "auto";
        reaper_freq = 5;
        desiredgov = "performance";
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        amd_performance_level = "high";
        # Use discrete AMD GPU
        gpu_power_limit = "auto";
      };
      cpu = {
        park_cores = "no";
        pin_cores = "yes";
        core_count = "8"; # Use 8 cores for games (half of 16)
      };
      custom = {
        start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
        end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
      };
    };
  };

  ####################################
  ## Vulkan / OpenGL / 32-bit stack ##
  ####################################
  hardware.graphics = {
    enable = true;      # Mesa/Vulkan stack
    enable32Bit = true; # Needed for Proton / 32-bit games
    
    # Additional graphics packages for better compatibility
    extraPackages = with pkgs; [
      # AMD drivers and acceleration
      libva
      libva-utils
      vaapiVdpau         # VDPAU backend for VA-API
      libvdpau-va-gl     # VDPAU driver with VA-GL backend
      mesa.opencl        # OpenCL support
      rocmPackages.clr.icd # AMD OpenCL
      amdvlk             # AMD Vulkan driver
      # Keep Intel for integrated GPU
      intel-media-driver # Intel hardware acceleration
      vaapiIntel         # Intel VA-API
    ];
    
    extraPackages32 = with pkgs.pkgsi686Linux; [
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  ####################################
  ## Steam Wayland environment setup ##
  ####################################
  # Ensure Steam uses proper Wayland environment
  

  ####################################
  ## Gaming optimization environment ##
  ####################################
  environment.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    QT_QPA_PLATFORM = "wayland;xcb";
    __GLX_VENDOR_LIBRARY_NAME = "mesa";
    
    # Steam-specific optimizations
    STEAM_FORCE_DESKTOPUI_SCALING = "1";
    STEAM_COMPAT_CLIENT_INSTALL_PATH = "/home/chris/.local/share/Steam";
    STEAM_FRAME_FORCE_CLOSE = "1";
    STEAM_DISABLE_BROWSER_RESTART = "1";
    
    # Use native Wayland for Steam (global setting)
    GDK_BACKEND = "wayland";
    SDL_VIDEODRIVER = "wayland";
    
    # Fix Steam browser overlay in Wayland + Gamescope
    STEAM_ENABLE_WAYLAND_BROWSER = "1";
    CHROMIUM_FLAGS = "--enable-features=UseOzonePlatform --ozone-platform=wayland";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    
    # Graphics optimizations for AMD RADV
    __GL_THREADED_OPTIMIZATIONS = "1";
    __GL_SHADER_CACHE = "1";
    __GL_DXVK_OPTIMIZATIONS = "1";
    MESA_GL_VERSION_OVERRIDE = "4.6";
    MESA_GLSL_VERSION_OVERRIDE = "460";
    
    # COSMIC Desktop Environment optimizations
    ENABLE_WAYLAND_IME = "1";
    XDG_CURRENT_DESKTOP = "COSMIC";
    XDG_SESSION_DESKTOP = "cosmic";
    
    # Vulkan optimizations - AMD primary, Intel fallback
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json:/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json";
    
    # Audio optimizations
    PULSE_LATENCY_MSEC = "60";
    
    # Wine/Proton optimizations
    WINEDLLOVERRIDES = "winemenubuilder.exe=d";
    WINE_CPU_TOPOLOGY = "16:2"; # CPU topology for multi-core systems
    WINE_LARGE_ADDRESS_AWARE = "1";
    
    # DXVK optimizations
    DXVK_HUD = "compiler";
    DXVK_LOG_LEVEL = "none";
    DXVK_STATE_CACHE = "1";
    DXVK_ASYNC = "1"; # Async shader compilation for better performance
    
    # VKD3D-Proton optimizations (DirectX 12 → Vulkan)
    VKD3D_CONFIG = "dxr11,dxr"; # Enable DirectX Raytracing if supported
    VKD3D_SHADER_MODEL = "6_6";
    
    # AMD-specific optimizations
    AMD_VULKAN_ICD = "RADV";
    RADV_PERFTEST = "aco,sam,nggc,RT"; # Added Next-Gen Geometry + Ray Tracing
    RADV_DEBUG = "nocompute"; # Disable compute queue for some games
    mesa_glthread = "true";
    
    # Memory optimizations for large games  
    MALLOC_ARENA_MAX = "4";
    WINE_RT_POLICY = "1";
    
    # GameMode integration (removed global LD_PRELOAD - use gamemoderun instead)
  };
  
  ####################################
  ## Gaming-specific kernel params  ##
  ####################################
  boot.kernel.sysctl = {
    # Increase file descriptor limits for games
    "fs.file-max" = 2097152;
    # Optimize network for gaming
    "net.core.rmem_default" = 31457280;
    "net.core.rmem_max" = 134217728;
    "net.core.wmem_default" = 31457280;
    "net.core.wmem_max" = 134217728;
    "net.core.netdev_max_backlog" = 5000;
    # Memory optimizations for high-memory systems
    "vm.dirty_writeback_centisecs" = 6000;
    "vm.dirty_expire_centisecs" = 6000;
    "vm.swappiness" = 1; # Reduced for systems with abundant RAM
    "vm.vfs_cache_pressure" = 50; # Keep more filesystem cache
    "vm.dirty_ratio" = 15; # Allow more dirty memory before sync
    "vm.dirty_background_ratio" = 5;
    # Game asset streaming optimizations
    "vm.min_free_kbytes" = 1048576; # 1GB minimum free memory
  };
  
  ####################################
  ## Additional gaming packages     ##
  ####################################
  environment.systemPackages = with pkgs; let 
    steamPkg = steam.override {
      extraPkgs = pkgs: with pkgs; [
        xorg.libXcursor
        xorg.libXi
        xorg.libXinerama
        xorg.libXScrnSaver
        libpng
        libpulseaudio
        libvorbis
        stdenv.cc.cc.lib
        libkrb5
        keyutils
      ];
    };
    # Steam with Wayland wrapper
    steamWithWrapper = symlinkJoin {
      name = "steam-with-wrapper";
      paths = [ steamPkg ];
      buildInputs = [ makeWrapper ];
      postBuild = ''
        rm $out/bin/steam
        makeWrapper ${steamPkg}/bin/steam $out/bin/steam \
          --add-flags "" \
          --run "echo 'Steam launched at $(date)' >> /tmp/steam-debug.log" \
          --run "echo 'Parent: $PPID, Args: $@' >> /tmp/steam-debug.log" \
          --run "echo 'Env: GDK_BACKEND=$GDK_BACKEND SDL_VIDEODRIVER=$SDL_VIDEODRIVER WAYLAND_DISPLAY=$WAYLAND_DISPLAY' >> /tmp/steam-debug.log" \
          --set GDK_BACKEND wayland \
          --set SDL_VIDEODRIVER wayland \
          --set WAYLAND_DISPLAY wayland-1 \
          --set STEAM_ENABLE_WAYLAND_BROWSER "1" \
          --set CHROMIUM_FLAGS "--enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland --disable-gpu-sandbox" \
          --set ELECTRON_OZONE_PLATFORM_HINT wayland
      '';
    };
  in [
    steamWithWrapper
    
    # Performance monitoring and optimization
    mangohud
    goverlay
    
    # Gaming session management
    gamescope
    
    # Compatibility tools
    bottles
    lutris
    heroic
    
    # Advanced gaming tools
    gamemode # Already enabled, but include package
    vkbasalt # Post-processing effects layer
    corectrl # AMD GPU control and monitoring
    
    # Audio tools
    pavucontrol
    helvum
    
    # System monitoring
    btop
    nvtopPackages.full
  ];

  # Clean Steam desktop entry for Wayland
  environment.etc."steam.desktop" = {
    text = ''
      [Desktop Entry]
      Name=Steam
      Comment=Application for managing and playing games on Steam
      Exec=steam %U
      Icon=steam
      Terminal=false
      Type=Application
      Categories=Network;FileTransfer;Game;
      MimeType=x-scheme-handler/steam;x-scheme-handler/steamlink;
      Actions=Store;Community;Library;Servers;Screenshots;News;Settings;BigPicture;Friends;
      
      [Desktop Action Store]
      Name=Store
      Exec=steam steam://store
      
      [Desktop Action Community]
      Name=Community
      Exec=steam steam://url/SteamIDControlPage
      
      [Desktop Action Library]
      Name=Library
      Exec=steam steam://open/games
      
      [Desktop Action Servers]
      Name=Servers
      Exec=steam steam://open/servers
      
      [Desktop Action Screenshots]
      Name=Screenshots
      Exec=steam steam://open/screenshots
      
      [Desktop Action News]
      Name=News
      Exec=steam steam://open/news
      
      [Desktop Action Settings]
      Name=Settings
      Exec=steam steam://open/settings
      
      [Desktop Action BigPicture]
      Name=Big Picture
      Exec=steam steam://open/bigpicture
      
      [Desktop Action Friends]
      Name=Friends
      Exec=steam steam://open/friends
    '';
  };

  # Gaming mode Steam entry with consistent Wayland
  environment.etc."steam-gaming.desktop" = {
    text = ''
      [Desktop Entry]
      Name=Steam (Gaming Mode)
      Comment=Launch Steam in Big Picture with GameScope and GameMode optimizations
      Exec=gamemoderun gamescope -W 3840 -H 2160 -r 120 --adaptive-sync --expose-wayland -- steam -gamepadui
      Icon=steam
      Terminal=false
      Type=Application
      Categories=Game;Network;
      StartupNotify=true
    '';
  };

  
  # Override system Steam desktop entry and make custom ones available  
  system.activationScripts.steamGaming = ''
    mkdir -p /usr/share/applications
    # Force our custom Steam entry to override the system one
    ln -sf /etc/steam.desktop /usr/share/applications/steam.desktop
    ln -sf /etc/steam-gaming.desktop /usr/share/applications/steam-gaming.desktop
    # Create a higher priority path for our custom entry
    mkdir -p /home/chris/.local/share/applications
    chown chris:users /home/chris/.local/share/applications
    ln -sf /etc/steam.desktop /home/chris/.local/share/applications/steam.desktop
  '';
}
