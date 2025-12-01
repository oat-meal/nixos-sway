{ config, pkgs, lib, inputs, ... }:

{
  ################################
  ## Import system modules
  ################################
  imports = [
    ../modules/system-packages.nix
    ../modules/unstable-packages.nix
    ../modules/steam.nix
    ../modules/sway.nix
    ../modules/noctalia.nix
  ] ++ lib.optional (builtins.pathExists ../modules/experimental-packages.nix) ../modules/experimental-packages.nix;

  ################################
  ## Core system
  ################################
  system.stateVersion = "25.05";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  ################################
  ## Locale & time
  ################################
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/Denver";

  ################################
  ## Bootloader (UEFI + systemd-boot)
  ################################
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  ################################
  ## Stable LTS kernel for hardware compatibility ##
  ################################
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_12;

  ################################
  ## Gaming-optimized kernel     ##
  ################################
  boot.kernelParams = [
    # CPU performance optimizations (AMD-specific)
    "amd_pstate=active"
    # Memory optimizations for large games
    "transparent_hugepage=always"
    "hugepagesz=2M"
    "default_hugepagesz=2M"
    # Gaming-specific scheduler optimizations
    "preempt=full" # Low-latency preemption for better frame times
    # Audio latency reduction
    "snd_hda_intel.power_save=0"
    # USB polling rate optimization (1000Hz for gaming mice)
    "usbhid.mousepoll=1"
    # PCI optimizations for high-end hardware
    "pci=pcie_bus_perf" # PCIe performance mode
    # WiFi suspend/resume fix - prevent WiFi from deep sleep
    "iwlwifi.power_save=0"
    "ath11k_pci.power_save=0"
    # Additional WiFi stability parameters
    "iwlwifi.power_scheme=1"  # Force active power scheme
    "iwlwifi.bt_coex_active=0"  # Disable Bluetooth coexistence
    # Prevent system from entering deep sleep that affects PCIe devices
    "intel_idle.max_cstate=1"  # Limit CPU C-states for PCIe stability
    "acpi_osi=\"!Windows 2012\""  # Force better ACPI compatibility
    # Removed problematic parameters that interfere with WiFi detection:
    # - mitigations=off (security risk)
    # - intel_pstate=disable (wrong for AMD)
    # - processor.max_cstate=1 (power hungry)
    # - idle=poll (power hungry)
    # - pci=realloc (PCIe conflicts)
    # - acpi_enforce_resources=lax (hardware conflicts)
    # - pcie_aspm=off (power management conflicts)
  ];
  
  # CPU frequency scaling for gaming
  powerManagement.cpuFreqGovernor = "performance";
  
  # Enable CPU microcode updates (AMD)
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  ################################
  ## Filesystems
  ## NOTE: UUIDs below are hardware-specific and should be updated 
  ##       for your system using `lsblk -f` or `blkid`
  ################################
  fileSystems."/" = {
    device = "UUID=547e9d27-e12b-48a7-a60c-291ef37587ec";
    fsType = "btrfs";
    options = [ "subvol=@" ];
  };

  fileSystems."/boot" = {
    device = "UUID=4BE5-47A3";
    fsType = "vfat";
  };

  fileSystems."/home" = {
    device = "UUID=547e9d27-e12b-48a7-a60c-291ef37587ec";
    fsType = "btrfs";
    options = [ "subvol=@home" ];
  };

  fileSystems."/nix" = {
    device = "UUID=547e9d27-e12b-48a7-a60c-291ef37587ec";
    fsType = "btrfs";
    options = [ "subvol=@nix" ];
  };

  fileSystems."/var/log" = {
    device = "UUID=547e9d27-e12b-48a7-a60c-291ef37587ec";
    fsType = "btrfs";
    options = [ "subvol=@log" ];
  };

  fileSystems."/swap" = {
    device = "UUID=547e9d27-e12b-48a7-a60c-291ef37587ec";
    fsType = "btrfs";
    options = [ "subvol=@swap" ];
  };

  # Optional swap file on @swap
  # swapDevices = [
  #   { file = "/swap/swapfile"; }
  # ];

  ################################
  ## Storage pool (Btrfs NVMe pool)
  ################################
  fileSystems."/storage" = {
    device = "UUID=5462bbac-d14a-4189-8ca8-aa07cd026c86";
    fsType = "btrfs";
    options = [
      "rw"
      "ssd"
      "relatime"
      "space_cache=v2"
      "compress=zstd"
      "subvol=/"
    ];
  };

  ################################
  ## Display manager: greetd + noctalia
  ################################
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # Launch user's Home Manager Sway session
        command = "sway";
        user = "chris";
      };
    };
  };

  ################################
  ## Networking & host identity
  ################################
  networking.hostName = "desktop-nixos";
  networking.networkmanager.enable = true;
  
  # Enable advanced WiFi support
  networking.networkmanager.wifi.backend = "wpa_supplicant";
  networking.networkmanager.wifi.powersave = false;
  
  # Enable WiFi regulatory domain (helps with WiFi 7)
  hardware.wirelessRegulatoryDatabase = true;

  # Temporary workaround from earlier build issue; can be revisited.
  services.logrotate.enable = false;
  
  ################################
  ## USB Device Support
  ################################
  # Enable USB device support and permissions
  services.udev.enable = true;
  hardware.usb-modeswitch.enable = true;
  
  # USB device permissions for gaming peripherals and AIO coolers
  services.udev.extraRules = ''
    # ASUS ROG devices (AIO coolers, keyboards, etc.)
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0b05", ATTRS{idProduct}=="1aa2", TAG+="uaccess"
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0b05", TAG+="uaccess"
    
    # USB HID devices for user access (gaming peripherals)
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0664", GROUP="input"
    
    # Xbox Wireless Controller support (Bluetooth and USB)
    KERNEL=="hidraw*", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02fd", MODE="0664", GROUP="input", TAG+="uaccess"
    KERNEL=="hidraw*", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="0b12", MODE="0664", GROUP="input", TAG+="uaccess"
    KERNEL=="hidraw*", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="0b13", MODE="0664", GROUP="input", TAG+="uaccess"
    KERNEL=="hidraw*", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="0b20", MODE="0664", GROUP="input", TAG+="uaccess"
    KERNEL=="hidraw*", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="0b21", MODE="0664", GROUP="input", TAG+="uaccess"
    KERNEL=="hidraw*", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="0b22", MODE="0664", GROUP="input", TAG+="uaccess"
    
    # USB audio devices (headsets, DACs, AIO pump controls)
    SUBSYSTEM=="usb", ATTRS{bInterfaceClass}=="01", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{bInterfaceClass}=="03", TAG+="uaccess"
    
    # WiFi power management fixes - prevent WiFi adapters from entering sleep states
    # Disable power management for all network devices
    SUBSYSTEM=="net", ACTION=="add", KERNEL=="wl*", RUN+="/bin/sh -c 'echo on > /sys/class/net/%k/device/power/control'"
    
    # Disable USB power management for network adapters
    SUBSYSTEM=="usb", ATTRS{bInterfaceClass}=="02", ATTR{power/control}="on"
    SUBSYSTEM=="usb", ATTRS{bInterfaceClass}=="09", ATTR{power/control}="on"
    
    # Specific WiFi adapter power management (covers most chipsets)
    SUBSYSTEM=="pci", ATTRS{class}=="0x028000", ATTR{power/control}="on"
  '';

  ################################
  ## System-wide nixpkgs config
  ################################
  nixpkgs.config = {
    allowUnfree = true;

    # While we’re debugging, keep this broad.
    # If you want to lock this down to a predicate later, we can.
    # allowUnfreePredicate = pkg:
    #   builtins.elem (pkgs.lib.getName pkg) [
    #     "discord"
    #   ];
  };

  ################################
  ## User configuration
  ################################
  users.users.chris = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "dialout" "uucp" "plugdev" "input" ];
    shell = pkgs.zsh;
    ignoreShellProgramCheck = true;
  };

  programs.zsh.enable = true;

  ################################
  ## Hardware & services
  ################################
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  
  # Hardware firmware support
  hardware.enableRedistributableFirmware = true;
  hardware.firmware = with pkgs; [
    # Comprehensive firmware for WiFi 7 support
    linux-firmware
    # Specific Qualcomm firmware (may help with QCNCM865)
    wireless-regdb
  ];

  # Enable WiFi 7 specific configurations
  boot.extraModulePackages = with config.boot.kernelPackages; [
    # Ensure WiFi modules are available
  ];

  # Force load WiFi drivers (only load existing modules)
  boot.kernelModules = [
    # Available WiFi drivers in this kernel version
    "iwlwifi"       # Intel WiFi (AX210/AX211 if present)
    "ath11k_pci"    # Qualcomm WiFi 6E (available in kernel 6.12)
    # "ath12k_pci"  # WiFi 7 - not available in this kernel version
    # "mt7925e"     # MediaTek WiFi 7 - not available in this kernel version  
    # "rtw89"       # Realtek WiFi 6/7 - driver exists but hardware not detected
  ];

  # Enable WiFi support
  networking.wireless.enable = false;  # Use NetworkManager instead
  # Note: iwd backend may not be available in NixOS 25.05, using default wpa_supplicant

  
  ################################
  ## Fonts
  ################################
  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];
  };

  ################################
  ## Audio stack (PipeWire)
  ################################
  services.pipewire = {
    enable = true;

    alsa = {
      enable = true;
      support32Bit = true;
    };

    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };
}

