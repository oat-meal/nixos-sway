{ pkgs, inputs, ... }:

{
  # Install Noctalia shell and QuickShell
  environment.systemPackages = [
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.xorg.libxcb  # Required for Qt 6.5.0+ xcb platform plugin
  ] ++ (
    # Add QuickShell from unstable if available, otherwise skip for now
    if (pkgs ? unstable) && (pkgs.unstable ? quickshell) 
    then [ pkgs.unstable.quickshell ]
    else []
  );

  # Recommended system services for Noctalia (NetworkManager and Bluetooth already enabled in desktop.nix)
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  
  # Prevent power-profiles-daemon from managing WiFi power
  systemd.services.power-profiles-daemon.serviceConfig = {
    ExecStart = [
      ""  # Clear default
      "${pkgs.power-profiles-daemon}/bin/power-profiles-daemon --disable-power-save-blocking"
    ];
  };

  # Enable XWayland support for compatibility
  programs.xwayland.enable = true;
  
  # Additional helpful services for desktop shell
  services.dbus.enable = true;
  programs.dconf.enable = true;

  # PAM configuration for lock screen authentication
  security.pam.services.noctalia-lock = {};
  
  # Enable screen locking via loginctl
  services.logind = {
    lidSwitch = "lock";
    lidSwitchExternalPower = "lock";
    powerKey = "lock";
  };

  # Configure lock screen handler for Noctalia
  security.pam.services.login.enableGnomeKeyring = true;
  
  # Set up environment for Noctalia lock screen
  environment.variables = {
    NOCTALIA_LOCK_HANDLER = "${pkgs.writeShellScript "noctalia-lock" ''
      #!/bin/sh
      # Use Noctalia's IPC to trigger lock screen
      exec qs -c noctalia-shell ipc call lockScreen toggle
    ''}";
  };
}