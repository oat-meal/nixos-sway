# modules/unstable-packages.nix
#
# Purpose:
#   Expose the NixOS unstable package set as pkgs.unstable.<name>
#   in an otherwise stable 25.05 system.
#
# Usage:
#   - system level: environment.systemPackages = [ pkgs.unstable.discord ];
#   - user level:   home.packages = [ pkgs.unstable.discord ];
#
# Requirements:
#   - flake input: nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

{ pkgs, inputs, ... }:

let
  unstablePkgs = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system};
in
{
  nixpkgs.overlays = [
    (final: prev: {
      unstable = unstablePkgs;
    })
  ];
}
