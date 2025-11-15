# modules/unstable-packages.nix
#
# Purpose:
#   Provide a clean, controlled way to use NixOS unstable packages
#   inside a primarily stable NixOS 25.05 system.
#
# Why:
#   - Some packages (like Discord) break frequently on stable.
#   - Unstable updates faster and stays compatible.
#   - This module keeps all unstable usage isolated and easy to audit.
#
# Usage:
#   After enabling this module, all unstable packages are accessible as:
#       pkgs.unstable.<packageName>
#
# Example:
#   environment.systemPackages = [ pkgs.unstable.discord ];
#   home.packages = [ pkgs.unstable.discord ];
#
# NOTE:
#   Requires `nixpkgs-unstable` input defined in flake.nix:
#
#     nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
#

{ pkgs, inputs, ... }:

let
  # Alias to the unstable package set for this system
  unstablePkgs = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system};
in
{
  ########################################
  ## Expose unstable as pkgs.unstable.*
  ########################################

  nixpkgs.overlays = [
    (final: prev: {
      unstable = unstablePkgs;
    })
  ];
}
