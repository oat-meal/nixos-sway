# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## NixOS Modular Desktop Configuration

This is a clean, modular NixOS flake-based configuration for a high-performance Wayland desktop system using SwayFX, Steam, PipeWire, and Home Manager. It's designed for maintainability with strict separation between system-level configuration, user-level configuration, and stable vs unstable package sources.

## Common Commands

### Build and Apply Configuration
```bash
# Navigate to the configuration directory
cd /etc/nixos

# Rebuild and switch to new configuration (most common)
sudo nixos-rebuild switch --flake .#desktop-nixos

# Test configuration without switching (safe testing)
sudo nixos-rebuild test --flake .#desktop-nixos

# Build configuration without activating (dry-run build)
sudo nixos-rebuild build --flake .#desktop-nixos

# Preview what would change without applying
sudo nixos-rebuild dry-activate --flake .#desktop-nixos

# Update flake inputs to latest versions
sudo nix flake update

# Rollback to previous generation if something breaks
sudo nixos-rebuild switch --rollback
```

### Validation and Testing
```bash
# Validate flake syntax and dependencies
nix flake check

# Validate Sway configuration syntax
sway --validate

# Test Home Manager configuration build
home-manager build

# Check system service logs
journalctl -u greetd -b                # Display manager logs
systemctl --user show-environment      # User session environment
```

## Architecture Overview

### Core Structure
- **flake.nix**: Main entry point defining system inputs (nixpkgs stable/unstable, home-manager) and outputs
- **hosts/desktop.nix**: Hardware-specific system configuration including filesystems, users, and core services
- **home/**: Home Manager user configurations
  - `desktop-user.nix`: Main user environment and shell setup
  - `theme.nix`: GTK themes, icons, and styling for Wayland applications
- **modules/**: Modular system components
  - `system-packages.nix`: All system-wide packages (stable nixpkgs)
  - `user-packages.nix`: User-level packages via Home Manager (stable + unstable)
  - `unstable-packages.nix`: Overlay providing access to nixos-unstable packages
  - `sway.nix`: SwayFX compositor configuration
  - `steam.nix`: Gaming environment with Steam, Proton-GE, and Vulkan support

### Key Design Principles
- **Modular Architecture**: Each component is isolated in its own module for maintainability
- **Package Separation**: Clear distinction between system packages and user packages
- **Stable Base + Selective Unstable**: Uses stable nixpkgs as base with unstable overlay for specific packages (like Discord)
- **Wayland-Native**: Configured for Wayland with XWayland fallback for compatibility

### System Features
- **Filesystem**: Btrfs with subvolumes (@, @home, @nix, @log, @swap) for flexible snapshots
- **Boot**: UEFI + systemd-boot loader
- **Login Manager**: greetd launching SwayFX
- **Audio**: PipeWire with WirePlumber, ALSA/PulseAudio compatibility, 32-bit support
- **Graphics**: Vulkan + OpenGL with 32-bit support for gaming
- **Gaming**: Steam with Proton-GE, MangoHud, Gamescope
- **Desktop**: Waybar, Wofi launcher, Mako notifications, swaylock-effects

### Package Management Strategy
- **System packages**: Add to `modules/system-packages.nix` (stable only)
- **User packages**: Add to `modules/user-packages.nix` (prefer stable, use `pkgs.unstable.` prefix for unstable packages)
- **Unstable access**: Available via overlay as `pkgs.unstable.<package>`

### File Locations and Purpose
- **hosts/desktop.nix:174**: Core system configuration, filesystem mounts, user definitions
- **flake.nix:49**: System configuration assembly and Home Manager integration
- **modules/system-packages.nix:7**: All system-wide package definitions
- **modules/user-packages.nix:11**: User application packages
- **home/desktop-user.nix:31**: Home Manager imports and shell configuration
- **home/theme.nix:14**: GTK, Waybar, Wofi, Mako, and swaylock styling

## Important Configuration Notes

### Critical UUID Management
All filesystem UUIDs in `hosts/desktop.nix` must match actual device UUIDs. Use `blkid` to verify:
- Root filesystem (line 38): Uses Btrfs subvolume @ 
- Boot partition (line 44): FAT32 EFI System Partition
- Storage pool (line 80): Separate Btrfs filesystem with compression

### Home Manager Integration
The configuration uses a sophisticated overlay system to make unstable packages available in both system and Home Manager contexts. This is configured in `flake.nix:69-91`.

### Unfree Package Handling
- System allows all unfree packages (`hosts/desktop.nix:120`)
- Home Manager restricts unfree to specific packages like Discord (`home/desktop-user.nix:21-25`)

### Gaming Environment
Steam is configured with Wayland-native support while maintaining X11 compatibility. Includes Proton-GE for better Windows game compatibility and full Vulkan stack for optimal performance.