{ config, pkgs, lib, ... }:

{
  ################################
  ## Import system modules
  ################################
  imports = [
    ../modules/system-packages.nix
    ../modules/unstable-packages.nix
    ../modules/sway.nix
    ../modules/steam.nix
    ../modules/dms.nix
  ];

  ################################
  ## Core system
  ################################
  system.stateVersion = "25.05";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  ################################
  ## Locale & time
  ################################
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/Chicago";

  ################################
  ## Bootloader (UEFI + systemd-boot)
  ################################
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  ################################
  ## Filesystems
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
  ## Display manager: greetd + tuigreet
  ################################
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # Launch Sway via tuigreet
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd sway";
        user = "chris";
      };
    };
  };

  ################################
  ## Networking & host identity
  ################################
  networking.hostName = "desktop-nixos";
  networking.networkmanager.enable = true;

  # Temporary workaround from earlier build issue; can be revisited.
  services.logrotate.enable = false;

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
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "dialout" "uucp" ];
    shell = pkgs.zsh;
    ignoreShellProgramCheck = true;
  };

  programs.zsh.enable = true;

  ################################
  ## Hardware & services
  ################################
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  hardware.enableRedistributableFirmware = true;

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

