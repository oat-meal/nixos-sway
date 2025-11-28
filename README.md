# NixOS Gaming Desktop Configuration

### **NixOS Configuration: Ryzen 9950X + RX 9070 XT + 64GB RAM**

This repository provides a modular NixOS configuration for Wayland gaming and productivity, featuring **SwayFX compositor**, **Noctalia shell**, and gaming-specific optimizations.

**Hardware Specifications**: Ryzen 9950X (16-core) + RX 9070 XT RDNA 4 + 64GB RAM

**Key Features:**
* 🎨 **SwayFX visual effects** with blur, rounded corners, and shadows
* 🖥️ **Noctalia shell** replacing traditional panels with IPC-based interface
* 🔒 **Auto-lock functionality** with PAM authentication and multiple triggers
* 🎮 **Steam integration** with Wayland browser support, RADV features, and GameMode
* 🏠 **Home Manager** for user environment and configuration management
* 📦 **Modular design** separating system, user, stable, and unstable packages
* ⚡ **Hardware-specific tuning** for 16-core CPU topology and 64GB memory

---

## 📁 Repository Structure

```
/etc/nixos
├── flake.nix                   # Main flake (nixpkgs stable/unstable, HM, Noctalia)
├── hosts/
│   └── desktop.nix             # Host config (hardware, filesystems, greetd, users)
├── home/
│   ├── desktop-user.nix        # Home Manager user configuration
│   ├── theme.nix               # Catppuccin theming (GTK, cursors, notifications)
│   └── sway-config.nix         # Comprehensive Sway config with Niri workflow
└── modules/
    ├── system-packages.nix     # Core system packages (stable channel)
    ├── user-packages.nix       # User packages via Home Manager
    ├── unstable-packages.nix   # Unstable overlay for cutting-edge packages
    ├── sway.nix                # SwayFX compositor system configuration
    ├── steam.nix               # Gaming environment (Steam, Proton, Vulkan)
    └── noctalia.nix            # Noctalia shell with lock screen integration
```

---

# 🚀 Installation & Setup Instructions

These steps assume:

* You are installing NixOS 25.05
* You have 2 NVMe drives (as per your system), but the instructions work on any layout
* You will clone or copy this repo into `/etc/nixos` after partitioning

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

**IMPORTANT**: This guide assumes you have already partitioned your disks. If you need partitioning instructions, see the [NixOS Installation Guide](https://nixos.org/manual/nixos/stable/index.html#sec-installation-partitioning).

### **View your disks and partitions**

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

**Example with actual UUIDs** (DO NOT copy these - use your own from `blkid`):
```sh
# Example only - these UUIDs will not match your system
mount -o subvol=@ /dev/disk/by-uuid/547e9d27-e12b-48a7-a60c-291ef37587ec /mnt
mount -o subvol=@home /dev/disk/by-uuid/547e9d27-e12b-48a7-a60c-291ef37587ec /mnt/home
mount /dev/disk/by-uuid/4BE5-47A3 /mnt/boot
mount -t btrfs -o compress=zstd /dev/disk/by-uuid/5462bbac-d14a-4189-8ca8-aa07cd026c86 /mnt/storage
```

---

## 4. Copy This Repo Into `/mnt/etc/nixos`

Once disks are mounted:

```sh
# Replace with your actual repository URL
git clone https://github.com/your-username/nixos-sway.git /mnt/etc/nixos
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
- Verify you can log in as user `chris` (password set during installation)
- Verify Sway starts automatically via greetd
- Test basic functionality before proceeding

---

# 🖥️ System Overview

### Display Environment

* **Compositor**: SwayFX with blur, rounded corners, and shadows
* **Shell**: Noctalia (modern Qt-based shell replacing traditional bars)
* **Login**: greetd with automatic Sway session launch
* **Lock Screen**: Noctalia IPC-based with auto-lock and multiple triggers
* **Notifications**: Mako with Catppuccin theming

### Window Management

* **Layout**: Niri-inspired horizontal column workflow
* **Navigation**: Vi-keys and arrow keys for focus/movement
* **Workspaces**: Traditional numbered workspaces (1-10)
* **Gaps**: Smart gaps (8px inner, 4px outer)
* **Borders**: Minimal borders with theme-matched colors

### User Interface

* **Launcher**: wofi with image support
* **Notifications**: Mako with rounded corners and theming
* **Terminal**: Alacritty with JetBrainsMono Nerd Font
* **Shell**: Zsh with Oh-My-Zsh (agnoster theme)

### Audio & Hardware

* **Audio**: PipeWire with ALSA, Pulse, and JACK support
* **Input**: Optimized keyboard/touchpad/mouse settings
* **Bluetooth**: Enabled with Blueman integration

### Gaming

* **Steam**: Full Steam integration with Proton support
* **Graphics**: Vulkan + 32-bit support  
* **Tools**: Gamescope, MangoHud for performance monitoring

## 🎮 Gaming Configuration

### **Steam Configuration**

This configuration includes gaming optimizations for **Ryzen 9950X + RX 9070 XT RDNA 4 + 64GB RAM** systems, with Wayland compatibility and hardware-specific tuning.

#### **Integration Issues Resolved**

**1. Steam Browser Overlay Issues**:
- **Problem**: Browser menus in games (Pax Dei) cause black screens in Wayland + gamescope environments
- **Root Cause**: Steam's CEF browser conflicts with Wayland compositor integration
- **Solution**: Complete browser compatibility stack with Ozone platform forcing
- **Implementation**: 
  ```nix
  STEAM_ENABLE_WAYLAND_BROWSER = "1";
  CHROMIUM_FLAGS = "--enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland --disable-gpu-sandbox";
  ```

**2. wofi Launcher Desktop Entry Conflicts**:
- **Problem**: Steam fails to launch properly via wofi while working from terminal
- **Root Cause**: System vs. custom Steam desktop entry priority conflicts
- **Solution**: User-level desktop entry override system with proper environment variables
- **Files**: `/etc/nixos/modules/steam.nix:42-86`

#### **Hardware-Specific Configuration**

**CPU Configuration (Ryzen 9950X - 16 Cores)**:
```nix
# Wine topology matching 16-core hardware
WINE_CPU_TOPOLOGY = "16:2";
# Low-latency kernel preemption for gaming
boot.kernelParams = [ "preempt=full" "hugepagesz=2M" "pci=pcie_bus_perf" ];
# Performance governor for consistent high clocks
powerManagement.cpuFreqGovernor = "performance";
# GameMode: 8 dedicated cores with core parking disabled
programs.gamemode.settings = {
  cpu = { park_cores = "no"; pin_cores = "yes"; core_count = "8"; };
};
```

**GPU Configuration (RX 9070 XT RDNA 4)**:
```nix
# RADV cutting-edge features for RDNA 4
RADV_PERFTEST = "aco,sam,nggc,RT"; # ACO compiler + Smart Access Memory + Next-Gen Geometry + Ray Tracing
# DirectX 12 → Vulkan with DXR ray tracing
VKD3D_CONFIG = "dxr11,dxr"; VKD3D_SHADER_MODEL = "6_6";
# Advanced DXVK optimizations
DXVK_ASYNC = "1"; DXVK_STATE_CACHE = "1";
# Threading optimizations
__GL_THREADED_OPTIMIZATIONS = "1"; mesa_glthread = "true";
```

**Memory & Storage Configuration (64GB + Btrfs)**:
```nix
# High-memory system VM tuning
boot.kernel.sysctl = {
  "vm.swappiness" = 1;                    # Minimize swapping with abundant RAM
  "vm.vfs_cache_pressure" = 50;           # Balanced cache retention
  "vm.dirty_ratio" = 15;                  # Large dirty buffer for 64GB
  "vm.min_free_kbytes" = 1048576;         # 1GB minimum free for streaming
};
# Btrfs with compression for game storage
fileSystems."/storage" = {
  options = [ "rw" "ssd" "relatime" "space_cache=v2" "compress=zstd" ];
};
# Transparent huge pages for large game assets
boot.kernelParams = [ "transparent_hugepage=always" ];
```

#### **Game Launch Configurations**

**Large Open Worlds** (Pax Dei, Cyberpunk 2077):
```bash
gamemoderun gamescope -W 3840 -H 2160 -w 2560 -h 1440 \
  --force-grab-cursor --fullscreen --prefer-vk-device 1002 \
  --adaptive-sync --filter fsr --expose-wayland --mangoapp \
  -- env STEAM_ENABLE_WAYLAND_BROWSER=1 %command%
```

**Space Simulations** (Elite Dangerous, Star Citizen):
```bash
gamemoderun mangohud env RADV_PERFTEST=aco,sam,nggc,RT %command%
```

**Competitive Gaming** (CS2, Valorant):
```bash
gamemoderun env RADV_DEBUG=nocompute %command%
```

#### **Anti-Aliasing Options**

- **TSR (Temporal Super Resolution)**: Available in supported games
- **SMAA**: Lower VRAM usage option
- **MSAA 4x**: Traditional anti-aliasing option

#### **USB Hardware Support**

**ASUS ROG Device Integration**:
```nix
# ASUS ROG hardware (AIO coolers, keyboards, RGB devices)
services.udev.extraRules = ''
  SUBSYSTEM=="usb", ATTRS{idVendor}=="0b05", TAG+="uaccess"
  KERNEL=="hidraw*", MODE="0664", GROUP="input"
'';
# Hardware access permissions
users.users.chris.extraGroups = [ "wheel" "audio" "video" "plugdev" "input" ];
```

#### **Configuration Results**

- **CPU**: Topology optimization and GameMode core binding implemented
- **GPU**: RADV features and async shader compilation enabled
- **Memory**: VM parameters tuned for 64GB systems
- **Storage**: Btrfs compression and SSD optimization configured
- **Browser**: Wayland Steam overlay functionality working

### Key Bindings

* **Modifier**: Super (Mod4) key
* **Terminal**: `Super+Enter` (Alacritty)
* **Launcher**: `Super+d` (wofi)
* **Lock Screen**: `Super+Delete` (Noctalia IPC)
* **Screenshots**: `Print` (full) / `Shift+Print` (selection)
* **Media**: Hardware keys + `Super+p/[/]` alternatives

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

### Test lock screen functionality:

```sh
# Manual lock test
qs ipc --id $(qs list --all | head -1 | grep -o "Instance [^:]*" | cut -d" " -f2 | head -c2) call lockScreen lock
```

### Validate Sway config:

```sh
sway --validate
```

### Validate Home Manager:

```sh
home-manager build
```

### Check Noctalia status:

```sh
# List Noctalia instances
qs list --all

# Check if Noctalia is running
systemctl --user status noctalia-shell
```

### Validate the flake:

```sh
nix flake check
```

### Check greeter logs:

```sh
journalctl -u greetd -b
```

### Check user session env:

```sh
systemctl --user show-environment
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

1. Create `modules/my-module.nix`
2. Add:

   ```nix
   imports = [ ../modules/my-module.nix ];
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

### Lock Screen Integration

* **Auto-lock**: Automatically locks after login (3-second delay)
* **Triggers**: Lid close, power button, manual activation
* **Authentication**: PAM integration for secure unlock
* **IPC Control**: Lock/unlock via Noctalia IPC commands

### Key Binding

```
Super+Delete    # Lock screen immediately
```

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
* **Hardware Tuning**: Configurations specific to Ryzen 9950X + RX 9070 XT + 64GB RAM
* **Wayland Focus**: Native Wayland applications and compatibility
* **Visual Effects**: SwayFX compositor with blur, shadows, and rounded corners
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
sway --validate                    # Validate Sway configuration
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
