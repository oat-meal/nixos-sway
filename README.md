# nixos-sway

Below is a clean, sysadmin-friendly **`README.md`** for your NixOS configuration repository.

It includes:

* Repository layout overview
* Installation instructions (fresh install + disk prep)
* How to verify drive UUIDs correctly
* How to manage and update the system safely
* How to add/modify modules
* How to debug builds
* How to avoid the most common NixOS breaking mistakes
* Best practices for long-term maintenance

This is written for **a future sysadmin unfamiliar with NixOS** but competent with Linux.

---

# `README.md`

### **NixOS Desktop Configuration — Modular, Stable + Unstable Mix, SwayFX, Steam**

This repository provides a clean, modular NixOS configuration for a high-performance Wayland desktop system using **SwayFX**, **Steam**, **PipeWire**, and **Home Manager**, with safe exposure to the `nixos-unstable` channel for select packages such as Discord.

It is designed to be maintainable by a sysadmin with limited NixOS experience, with strict separation between:

* **System-level configuration**
* **User-level configuration**
* **Stable vs Unstable package sources**
* **Compositor, gaming, theming, and user programs**

---

## 📁 Repository Structure

```
/etc/nixos
├── flake.nix                   # Top-level flake (entry point)
├── hosts/
│   └── desktop.nix             # Host-level config (FS, users, greetd, hardware)
├── home/
│   ├── desktop-user.nix        # Home Manager for user 'chris'
│   └── theme.nix               # GTK, cursor, Waybar, Wofi, Mako, swaylock styling
└── modules/
    ├── system-packages.nix     # All system-wide packages (stable)
    ├── user-packages.nix       # All user-level packages via Home Manager
    ├── unstable-packages.nix   # Overlay exposing pkgs.unstable
    ├── sway.nix                # SwayFX compositor system settings
    ├── steam.nix               # Steam + Proton + Vulkan settings
    ├── dms.nix                 # Dank Material Shell launcher integration
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

### **View your disks**

```sh
lsblk -f
```

### **Check UUIDs (VERY IMPORTANT):**

```sh
blkid
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

## 3. Mount Filesystems (example)

```sh
mount -o subvol=@ /dev/<UUID> /mnt
mkdir -p /mnt/{boot,home,nix,var/log,swap,storage}

mount -o subvol=@home /dev/<same-UUID> /mnt/home
mount -o subvol=@nix /dev/<same-UUID> /mnt/nix
mount -o subvol=@log /dev/<same-UUID> /mnt/var/log
mount -o subvol=@swap /dev/<same-UUID> /mnt/swap

mount /dev/<UUID-of-boot> /mnt/boot
mount -t btrfs -o compress=zstd /dev/<UUID-storage> /mnt/storage
```

---

## 4. Copy This Repo Into `/mnt/etc/nixos`

Once disks are mounted:

```sh
git clone <your-repo> /mnt/etc/nixos
```

Or manually copy via USB.

---

## 5. Install NixOS with Flakes

```sh
nixos-install --flake /mnt/etc/nixos#desktop-nixos
```

Set root password when prompted.

Reboot:

```sh
reboot
```

---

# 🖥️ System Overview

### Compositor

* **SwayFX** (Wayland)

### Login Manager

* `greetd` + `tuigreet` auto-launching SwayFX

### Audio

* PipeWire + WirePlumber
* ALSA + 32-bit support for Steam

### Gaming

* Steam + Proton-GE
* Vulkan + 32-bit Vulkan
* Gamescope, MangoHud

### Desktop Experience

* Waybar
* Wofi
* Mako
* swww
* Swaylock-effects

### Optional Add-ons

* Dank Material Shell (hotkey: `SUPER + D`)

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

### Validate the Sway config:

```sh
sway --validate
```

### Validate Home Manager:

```sh
home-manager build
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

### **❌ Forgetting to replace `lib.fakeSha256`**

After building Dank Material Shell (DMS), replace the printed hash.

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

# 🎉 Final Notes

This repo is now:

* **Strictly modular**
* **Sysadmin-friendly**
* **Safe to maintain long-term**
* **Easy to extend to multiple hosts** (like your upcoming NixOS server)
* **Aligned with NixOS 25.05 best practices**

If you want, I can also generate:

* A server-ready minimal module set
* A laptop host variant
* Automatic hardware configuration detection module
* A flake template generator (`nix flake init` style)

Just tell me!
