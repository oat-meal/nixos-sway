{ config, pkgs, lib, ... }:

{
  ################################
  ## USB Audio Device Fixes
  ################################
  # Fix for Fiio K7 and other USB audio disconnection issues
  
  # Disable USB autosuspend for audio devices
  services.udev.extraRules = ''
    # Disable autosuspend for Fiio devices
    SUBSYSTEM=="usb", ATTR{idVendor}=="1852", ATTR{power/autosuspend}="-1"
    
    # Disable autosuspend for all USB audio devices
    SUBSYSTEM=="usb", ATTR{bInterfaceClass}=="01", ATTR{power/autosuspend}="-1"
    
    # Reset USB audio devices on connection
    SUBSYSTEM=="usb", ATTR{idVendor}=="1852", ATTR{idProduct}=="7022", RUN+="/bin/sh -c 'echo 0 > /sys/bus/usb/devices/$kernel/power/autosuspend_delay_ms'"
  '';

  # Kernel parameters for USB stability
  boot.kernelParams = [
    # Disable USB autosuspend globally
    "usbcore.autosuspend=-1"
    
    # Fix for ASMedia USB controllers
    "xhci_hcd.quirks=0x00000200"
    
    # Note: usbhid.mousepoll=1 is already set in hosts/desktop.nix gaming section
  ];

  # Module parameters for better USB audio support
  boot.extraModprobeConfig = ''
    # USB audio improvements
    options snd-usb-audio enable_autoclock=0
    options snd-usb-audio autoclock=0
    options snd-usb-audio delayed_register=0
    
    # USB core improvements
    options usbcore autosuspend=-1
    options usbcore use_both_schemes=1
  '';

  # System-level audio improvements
  environment.sessionVariables = {
    # PulseAudio/PipeWire improvements for USB audio
    PULSE_RUNTIME_PATH = "/run/user/1000/pulse";
  };

  # Additional packages for USB audio debugging
  environment.systemPackages = with pkgs; [
    usbutils
    alsa-utils
  ];
}