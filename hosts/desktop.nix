{ config, pkgs, lib, ... }:

{
  ########################################
  ## System Core
  ########################################

  system.stateVersion = "25.05";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree packages globally (required for e.g. Discord, Steam, etc.)
  nixpkgs.config.allowUnfree = true;

  ########################################
  ## Locale & Time
  ########################################

  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/Chicago"; # Adjust if needed

  ########################################
  ## Bootloader (UEFI + systemd-boot)
  ########################################

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  ########################################
  ## Filesystem Configuration
  ########################################
  # EFI partition: /dev/nvme2n1p1 (FAT32, 2GiB, flags boot,esp)
  # Root partition: /dev/nvme2n1p2 (Btrfs with subvols @, @home, @nix, @log, @swap)

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

  # Optional: swap file on @swap subvolume
  # swapDevices = [
  #   { file = "/swap/swapfile"; }
  # ];

  ########################################
  ## Storage Pool (Btrfs NVMe pool)
  ########################################

  # Mount the main storage pool at /storage
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

  ########################################
  ## Display Manager: greetd + tuigreet
  ########################################

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # Start Sway (via SwayFX) from greetd
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd sway";
        user = "chris";
      };
    };
  };

  ########################################
  ## Hostname & Networking
  ########################################

  networking.hostName = "desktop-nixos";
  networking.networkmanager.enable = true;

  # Temporary workaround for a previous build error; safe to revisit later.
  services.logrotate.enable = false;

  ########################################
  ## User Configuration
  ########################################

  users.users.chris = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "dialout" "uucp" ];
    shell = pkgs.zsh;
    ignoreShellProgramCheck = true;
  };

  # Enable Zsh support at the system level
  programs.zsh.enable = true;

  ########################################
  ## Hardware & Services
  ########################################

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Firmware for various devices (Wi-Fi, GPU, etc.)
  hardware.enableRedistributableFirmware = true;

  ########################################
  ## Fonts
  ########################################

  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];
  };

  ########################################
  ## Audio Stack (PipeWire)
  ########################################

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
