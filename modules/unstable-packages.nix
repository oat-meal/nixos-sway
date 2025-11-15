{ config, pkgs, lib, inputs, system, ... }:

{
  # Provide pkgs.unstable that shares the same nixpkgs.config
  nixpkgs.overlays = [
    (final: prev: {
      unstable = import inputs.nixpkgs-unstable {
        inherit system;
        # Reuse the same config as the main nixpkgs
        config = prev.config;
      };
    })
  ];

  # Example usage (optional):
  # environment.systemPackages = with pkgs; [
  #   unstable.discord
  # ];
}

