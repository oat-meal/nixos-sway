# NixOS COSMIC Desktop Configuration

### **NixOS Configuration with COSMIC Desktop Environment**

This repository provides a modular NixOS configuration for COSMIC desktop and gaming, featuring **COSMIC Desktop Environment**, **comprehensive gaming support**, and hardware-optimized configurations.

**Key Features:**
* 🌌 **COSMIC Desktop Environment** with System76 scheduler for performance
* 🎮 **Gaming optimization** with Steam Wayland wrapper, GameMode, and graphics acceleration
* 🏠 **Home Manager** for user environment and configuration management
* 📦 **Modular design** separating system, user, stable, and unstable packages
* ⚡ **Hardware support** with AMD optimizations, WiFi management, and gaming peripherals
* 🔧 **Administrative integration** with Claude Code system management

---

## 📁 Repository Structure

```
/etc/nixos
├── flake.nix                   # Main flake (nixpkgs stable/unstable, Home Manager)
├── hosts/
│   └── desktop.nix             # Host config (hardware, COSMIC desktop, users)
├── home/
│   ├── desktop-user.nix        # Home Manager user configuration
│   └── theme.nix               # Catppuccin theming (GTK, cursors)
└── modules/
    ├── system-packages.nix     # Core system packages and Wayland tools
    ├── user-packages.nix       # User packages via Home Manager
    ├── unstable-packages.nix   # Unstable overlay for cutting-edge packages
    └── steam.nix               # Gaming environment (Steam wrapper, GameMode, graphics)
```

---

# 🚀 Installation & Setup Instructions

These steps assume:

* Installing NixOS 25.05
* Btrfs filesystem with subvolumes (adaptable to other layouts)
* This repo will be cloned or copied into `/etc/nixos` after partitioning

---

## 1. Boot the NixOS Installer

From the live ISO:

```sh
sudo su -
```

Update system time (VERY important for TLS & flakes):

```sh
timedatectl set-ntp true
```

---

## 2. Partitioning & Disk Setup

**IMPORTANT**: This guide assumes the disks have already been partitioned. For partitioning instructions, see the [NixOS Installation Guide](https://nixos.org/manual/nixos/stable/index.html#sec-installation-partitioning).

### **View disks and partitions**

```sh
# View all block devices and filesystems
lsblk -f

# Alternative detailed view
fdisk -l
```

### **Check UUIDs (CRITICAL STEP):**

```sh
# Get UUIDs for all partitions
blkid

# Save UUIDs to a file for reference during configuration editing
blkid > /tmp/uuids.txt
```

Ensure every UUID in:

```
hosts/desktop.nix
```

matches the actual device UUIDs.

The following paths must be correct:

* `/` (Btrfs subvolume `@`)
* `/home` (subvolume `@home`)
* `/nix` (subvolume `@nix`)
* `/var/log` (subvolume `@log`)
* `/boot` (FAT32, ESP)
* `/swap` (subvolume `@swap`)
* `/storage` (separate Btrfs drive)

> **Warning:**
> Mis-typed UUIDs are the #1 cause of unbootable systems.
> NEVER guess UUIDs. Always verify with `blkid`.

---

## 3. Mount Filesystems

**IMPORTANT**: Replace ALL placeholder UUIDs below with actual UUIDs from `blkid` output.

```sh
# Mount root subvolume (replace YOUR-MAIN-BTRFS-UUID with actual UUID)
mount -o subvol=@ /dev/disk/by-uuid/YOUR-MAIN-BTRFS-UUID /mnt

# Create mount directories
mkdir -p /mnt/{boot,home,nix,var/log,swap,storage}

# Mount Btrfs subvolumes (ALL use the same main Btrfs UUID)
mount -o subvol=@home /dev/disk/by-uuid/YOUR-MAIN-BTRFS-UUID /mnt/home
mount -o subvol=@nix /dev/disk/by-uuid/YOUR-MAIN-BTRFS-UUID /mnt/nix
mount -o subvol=@log /dev/disk/by-uuid/YOUR-MAIN-BTRFS-UUID /mnt/var/log
mount -o subvol=@swap /dev/disk/by-uuid/YOUR-MAIN-BTRFS-UUID /mnt/swap

# Mount boot partition (replace YOUR-BOOT-UUID with actual boot partition UUID)
mount /dev/disk/by-uuid/YOUR-BOOT-UUID /mnt/boot

# Mount storage pool (replace YOUR-STORAGE-UUID with actual storage UUID)
mount -t btrfs -o compress=zstd /dev/disk/by-uuid/YOUR-STORAGE-UUID /mnt/storage
```

**Example with actual UUIDs** (DO NOT copy these - get actual UUIDs from `blkid`):
```sh
# Example only - these UUIDs will not match other systems
mount -o subvol=@ /dev/disk/by-uuid/547e9d27-e12b-48a7-a60c-291ef37587ec /mnt
mount -o subvol=@home /dev/disk/by-uuid/547e9d27-e12b-48a7-a60c-291ef37587ec /mnt/home
mount /dev/disk/by-uuid/4BE5-47A3 /mnt/boot
mount -t btrfs -o compress=zstd /dev/disk/by-uuid/5462bbac-d14a-4189-8ca8-aa07cd026c86 /mnt/storage
```

---

## 4. Copy This Repo Into `/mnt/etc/nixos`

Once disks are mounted:

```sh
# Replace with the actual repository URL
git clone https://github.com/oat-meal/nixos-cosmic.git /mnt/etc/nixos
```

**Alternative methods:**
- Download ZIP from GitHub and extract to `/mnt/etc/nixos`
- Copy via USB drive
- Use `curl` or `wget` to download individual files

**IMPORTANT**: Ensure `/mnt/etc/nixos` contains the `flake.nix` file before proceeding.

---

## 5. Install NixOS with Flakes

**Before installation**, verify the flake configuration is valid:

```sh
# Test the flake from the installer environment
nix flake check /mnt/etc/nixos
```

**Install NixOS:**

```sh
nixos-install --flake /mnt/etc/nixos#desktop-nixos
```

**IMPORTANT**: 
- Set a **strong** root password when prompted
- Installation may take 30-60 minutes depending on internet speed
- Do not interrupt the process

**After installation completes:**

```sh
# Unmount filesystems cleanly
umount -R /mnt

# Reboot into the new system
reboot
```

**Post-reboot verification:**
- Verify login as user `chris` works (password set during installation)
- Verify COSMIC Desktop Environment starts via COSMIC Greeter
- Test basic functionality before proceeding

---

# 🖥️ System Overview

### Desktop Environment

* **Desktop Environment**: COSMIC Desktop Environment with System76 scheduler
* **Display Manager**: COSMIC Greeter
* **Compositor**: Built-in COSMIC compositor
* **Window Management**: COSMIC's built-in tiling window manager
* **Workspaces**: Dynamic workspace management

### Development & User Interface

* **Terminal**: Alacritty with JetBrainsMono Nerd Font (14pt)
* **Shell**: Zsh with Oh-My-Zsh (agnoster theme)
* **Editor**: Neovim (system and user level)
* **Tools**: git, wget, curl, ripgrep, htop, claude-code
* **Fallback Tools**: wofi, waybar, mako available for compatibility

### Audio & Hardware

* **Audio**: PipeWire with ALSA, Pulse, and JACK support
* **Graphics**: Hardware acceleration with 32-bit support for gaming
* **Bluetooth**: Enabled with Blueman integration
* **WiFi**: NetworkManager with power management disabled
* **Gaming Peripherals**: USB HID devices and Xbox controller support

### Gaming Configuration

* **Steam**: Custom Wayland wrapper with browser overlay fixes
* **GameMode**: CPU/GPU optimizations with performance governor
* **Graphics**: AMD RADV optimizations, 32-bit Vulkan support
* **Tools**: MangoHUD, GameScope, Lutris, Heroic, Bottles, CoreCtrl

## 🎮 Gaming Configuration

### **Steam Configuration**

This configuration includes gaming optimizations with COSMIC Desktop Environment, featuring Wayland compatibility and comprehensive graphics support.

#### **Key Features Implemented**

**1. Steam Wayland Integration**:
- **Implementation**: Custom Steam wrapper with Wayland environment variables
- **Browser Overlay**: STEAM_ENABLE_WAYLAND_BROWSER=1 with Chromium Ozone platform
- **Desktop Integration**: Custom desktop entries for standard and gaming mode launches
- **Environment**: Comprehensive gaming environment variables for DXVK, VKD3D, RADV

**2. GameMode Performance Optimization**:
- **CPU Configuration**: 8-core binding with performance governor
- **GPU Optimizations**: AMD-specific optimizations with power management
- **Notifications**: GameMode start/end notifications via libnotify
- **Integration**: Automatic performance optimization during gaming sessions

#### **Hardware Configuration**

**CPU Configuration (AMD with Gaming Optimizations)**:
```nix
# Performance governor for gaming
powerManagement.cpuFreqGovernor = "performance";
# Low-latency kernel preemption
boot.kernelParams = [ "amd_pstate=active" "preempt=full" "hugepagesz=2M" ];
# GameMode: 8 dedicated cores with optimizations
programs.gamemode.settings = {
  cpu = { park_cores = "no"; pin_cores = "yes"; core_count = "8"; };
};
```

**Graphics Configuration (AMD RADV)**:
```nix
# AMD RADV optimizations
RADV_PERFTEST = "aco,sam,nggc,RT";
# DXVK optimizations
DXVK_ASYNC = "1"; DXVK_STATE_CACHE = "1";
# Graphics threading
__GL_THREADED_OPTIMIZATIONS = "1"; mesa_glthread = "true";
# VKD3D-Proton for DirectX 12
VKD3D_CONFIG = "dxr11,dxr"; VKD3D_SHADER_MODEL = "6_6";
```

**Memory & Storage Configuration (Btrfs)**:
```nix
# VM tuning for gaming
boot.kernel.sysctl = {
  "vm.swappiness" = 1;
  "vm.vfs_cache_pressure" = 50;
  "vm.dirty_ratio" = 15;
  "vm.min_free_kbytes" = 1048576;
};
# Btrfs storage with compression
fileSystems."/storage" = {
  options = [ "rw" "ssd" "relatime" "space_cache=v2" "compress=zstd" ];
};
```

#### **Gaming Tools Available**

**Performance Monitoring**:
- MangoHUD for in-game performance overlay
- GameScope for game session management
- CoreCtrl for AMD GPU control and monitoring

**Compatibility Layers**:
- Bottles for Windows application management
- Lutris for game management and compatibility
- Heroic Games Launcher for Epic Games and GOG

**Example GameMode Launch**:
```bash
gamemoderun steam
# Or for specific games:
gamemoderun mangohud %command%
```

#### **Hardware Support**

**USB Gaming Peripherals**:
```nix
# Gaming device support (Xbox controllers, ASUS ROG devices)
services.udev.extraRules = ''
  KERNEL=="hidraw*", MODE="0664", GROUP="input"
  SUBSYSTEM=="usb", ATTRS{idVendor}=="0b05", TAG+="uaccess"
'';
# User permissions for hardware access
users.users.chris.extraGroups = [ "wheel" "audio" "video" "plugdev" "input" ];
```

### COSMIC Desktop Environment

* **Desktop Environment**: COSMIC with built-in tiling window manager
* **Display Manager**: COSMIC Greeter for login
* **Performance**: System76 scheduler for desktop responsiveness
* **Workspaces**: Dynamic workspace management with COSMIC-specific navigation
* **Applications**: COSMIC application launcher and window management

---

# 📦 Package Management Best Practices

### System-wide packages:

Edit:

```
modules/system-packages.nix
```

### User packages:

Edit:

```
modules/user-packages.nix
```

### Unstable packages:

Use:

```
pkgs.unstable.<package>
```

Added in `user-packages.nix` or `system-packages.nix` as needed.

### Why this strategy?

* Stable base = safer updates
* Unstable only for broken packages like Discord
* All unstable logic kept in **one dedicated module**

---

# 🔄 Updating the System

### Update flake inputs:

```sh
sudo nix flake update /etc/nixos
```

### Rebuild:

```sh
sudo nixos-rebuild switch --flake /etc/nixos#desktop-nixos
```

### Preview without applying:

```sh
sudo nixos-rebuild dry-activate --flake /etc/nixos#desktop-nixos
```

### Roll back:

```sh
sudo nixos-rebuild switch --rollback
```

---

# 🧪 Debugging & Validation

### Validate Home Manager:

```sh
home-manager build
```

### Validate the flake:

```sh
nix flake check /etc/nixos
```

### Check COSMIC Greeter logs:

```sh
journalctl -u cosmic-greeter -b
```

### Check COSMIC session:

```sh
systemctl --user status cosmic-session
```

### Validate configuration before applying:

```sh
sudo nixos-rebuild dry-build --flake /etc/nixos#desktop-nixos
```

---

# ⚠️ Common Breaking Mistakes (and how to avoid them)

### **❌ Wrong UUIDs**

Solution: always use:

```sh
blkid
```

and update `hosts/desktop.nix` accordingly.

---

### **❌ Duplicate systemPackages definitions**

We ensure packages are only defined in:

```
modules/system-packages.nix
```

---

### **❌ Putting system modules in Home Manager imports**

Home Manager should only import:

* `user-packages.nix`
* `theme.nix`

---


---

### **❌ Modifying live system without committing**

Always:

```sh
git add .
git commit -m "Update config"
sudo nixos-rebuild switch --flake .#desktop-nixos
```

---

### **❌ Running `nixos-rebuild` outside /etc/nixos with a dirty repo**

Always specify the flake:

```sh
sudo nixos-rebuild switch --flake /etc/nixos#desktop-nixos
```

---

# 📘 Extending the Configuration

To add a new module:

1. Create `modules/new-module.nix`
2. Add:

   ```nix
   imports = [ ../modules/new-module.nix ];
   ```

   inside `hosts/desktop.nix`
3. Rebuild

---

# 🧹 Keeping the Repo Clean

* Commit after every successful rebuild
* Add comments for sysadmins (already done)
* Keep modules small and focused
* Prefer stable pkgs unless absolutely necessary
* Document choices in comments

---

# 🔒 Security Features

### System Security

* **GPG Agent**: User-level GPG agent with GTK2 pinentry
* **Unfree Package Control**: Explicit allowlist for non-free software (Discord)
* **WiFi Security**: Power management disabled to prevent connection issues
* **Hardware Permissions**: Controlled access to USB devices and gaming peripherals

---

# 🆕 Recent Configuration Updates

### **Gaming & Compatibility**
* ✅ **Steam Browser Integration**: Wayland browser overlay functionality working
* ✅ **wofi Launch Stability**: Steam desktop entry conflicts resolved
* ✅ **RDNA 4 Configuration**: RADV features enabled (ACO, SAM, Next-Gen Geometry, RT)
* ✅ **USB Hardware Support**: ASUS ROG device udev rules implemented

### **Visual & Interface**
* ✅ **SwayFX Effects**: Configuration with blur, shadows, rounded corners
* ✅ **Lock Screen**: Auto-lock, PAM authentication, multiple triggers
* ✅ **Noctalia Shell**: Traditional panel replacement with IPC interface
* ✅ **Media Controls**: Playback control via Noctalia IPC

### **System Configuration**
* ✅ **16-Core CPU**: Wine and GameMode configuration for Ryzen 9950X
* ✅ **64GB Memory**: VM parameters tuned for high-memory systems
* ✅ **Documentation**: Technical documentation updated in Obsidian and Git

---

# 🎉 Configuration Approach

This configuration includes:

* **Modular Design**: Separated concerns for system, user, and package management
* **COSMIC Desktop**: System76's COSMIC Desktop Environment with tiling window manager
* **Gaming Focus**: Steam integration with Wayland support and hardware acceleration
* **Hardware Optimization**: AMD CPU/GPU optimizations and gaming-specific kernel parameters
* **Stable Base**: NixOS 25.05 stable with selective unstable packages

---

# 🤖 Claude Administrative Assistant Integration

## **System Administration Assistant**

This configuration is designed to work with **Claude Code** as a system administration assistant, providing automated support for:

### **Primary Administrative Functions**
- **Configuration Management**: NixOS module updates, package management, system tuning
- **Documentation Maintenance**: Synchronizing changes across Obsidian vault, GitHub README, and system files
- **Validation & Testing**: Pre-deployment testing using `nixos-rebuild dry-build` and configuration validation
- **Git Repository Management**: Commit tracking, change documentation, and repository maintenance

### **Administrative Workflows**

**Adding New Packages:**
1. Determine appropriate module (`system-packages.nix` vs `user-packages.nix`)
2. Edit configuration file with new package
3. Validate with `nixos-rebuild dry-build --flake /etc/nixos#desktop-nixos`
4. Apply with `nixos-rebuild switch --flake /etc/nixos#desktop-nixos`
5. Document changes and commit to Git

**System Updates:**
1. Update flake inputs: `sudo nix flake update /etc/nixos`
2. Preview changes: `sudo nixos-rebuild dry-activate --flake /etc/nixos#desktop-nixos`
3. Apply updates: `sudo nixos-rebuild switch --flake /etc/nixos#desktop-nixos`
4. Update documentation if significant changes made

**Configuration Validation:**
```bash
# Multiple validation methods available
sudo nixos-rebuild dry-build --flake /etc/nixos#desktop-nixos  # Validate system config
home-manager build                 # Validate Home Manager
nix flake check /etc/nixos        # Check flake syntax
```

### **Documentation Sources**
- **CLAUDE.md**: System context and administrative guidelines (`/home/chris/.claude/CLAUDE.md`)
- **Obsidian Vault**: Detailed technical documentation (`/home/chris/obsidian-vault/Systems/`)
- **GitHub README**: Installation procedures and public documentation (`/etc/nixos/README.md`)

### **Safety Practices**
- Always test configuration changes in dry-run mode before applying
- Maintain Git commit history for all configuration modifications
- Document significant system changes across all documentation sources
- Validate configurations using appropriate tools before deployment
