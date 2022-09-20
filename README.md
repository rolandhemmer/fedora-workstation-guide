# Fedora Workstation

Installation guide and **personal** post-installation steps  
Updated for Fedora Workstation 36

- [Fedora Workstation](#fedora-workstation)
  - [1. System Installation](#1-system-installation)
  - [2. System Setup](#2-system-setup)
    - [2.1. System Upgrade](#21-system-upgrade)
    - [2.2. System Drivers](#22-system-drivers)
    - [2.3. Nvidia Drivers](#23-nvidia-drivers)
      - [2.3.1. Prerequisites](#231-prerequisites)
      - [2.3.2. Auto Kernel Signing](#232-auto-kernel-signing)
      - [2.3.3. Installation](#233-installation)
    - [2.4. Multimedia Codecs](#24-multimedia-codecs)

## 1. System Installation

This installation guide requires an UEFI platform.  
Having a password to access the UEFI menu is **strongly recommended**.

Make sure the UEFI Secure Boot is **enabled**, then boot from the USB installation media.

- From the Fedora GRUB, use `Troubleshooting`, and select `Start Fedora-Workstation-Live in basic graphics mode`.
- From the Fedora live instance, select a default, full-disk English (US) installation with:
  - `BTRFS` as filesystem
  - full `LUKS` disk encryption enabled
- After first boot:
  - disable `Location Services`
  - disable `Automatic Problem Reporting`
  - enable `Third-Party Repositories`

**[:arrow_up: back to top](#fedora-workstation)**

## 2. System Setup

### 2.1. System Upgrade

Perform a full system upgrade:

```bash
gsettings reset org.gnome.desktop.input-sources xkb-options

echo "deltarpm=true" | sudo tee --append /etc/dnf/dnf.conf
echo "fastestmirror=1" | sudo tee --append /etc/dnf/dnf.conf
echo "max_parallel_downloads=20" | sudo tee --append /etc/dnf/dnf.conf

sudo dnf upgrade --assumeyes --refresh

sudo flatpak remote-add --if-not-exists fedora oci+https://registry.fedoraproject.org
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

flatpak repair --user
flatpak update --assumeyes --user
flatpak uninstall --assumeyes --unused --user

sudo flatpak repair --system
sudo flatpak update --assumeyes --system
sudo flatpak uninstall --assumeyes --unused --system

sudo flatpak override --reset
```

Enable RPM Fusion repositories:

```bash
sudo dnf install --assumeyes https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install --assumeyes https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf upgrade --assumeyes --refresh

sudo dnf install --assumeyes \
    fedora-workstation-repositories \
    rpmfusion-free-appstream-data \
    rpmfusion-nonfree-appstream-data

sudo dnf group update core --assumeyes
```

**[:arrow_up: back to top](#fedora-workstation)**

### 2.2. System Drivers

Add the `fwupd` command, and run it to check for driver and firmware updates:

```bash
sudo dnf install --assumeyes fwupd
sudo fwupdmgr refresh --assume-yes --force
sudo fwupdmgr get-updates --assume-yes
```

**[:arrow_up: back to top](#fedora-workstation)**

### 2.3. Nvidia Drivers

#### 2.3.1. Prerequisites

Install the following prerequisites:

```bash
sudo dnf install --assumeyes \
    akmods \
    acpid \
    curl \
    dkms \
    gcc \
    git \
    kernel-devel \
    kernel-headers \
    libglvnd-glx \
    libglvnd-opengl \
    libglvnd-devel \
    make \
    mokutil \
    openssl \
    pkgconfig \
    vim \
    wget
```

**[:arrow_up: back to top](#fedora-workstation)**

#### 2.3.2. Auto Kernel Signing

Enable Nvidia kernel module auto-signing:

```bash
sudo kmodgenca --auto
sudo mokutil --import /etc/pki/akmods/certs/public_key.der
```

:warning: A reboot is required after this point.

At reboot, choose `Enroll MOK`, `Continue`, `Yes`, then enter the selected password, and reboot.

**[:arrow_up: back to top](#fedora-workstation)**

#### 2.3.3. Installation

Install the latest Nvidia drivers:

```bash
sudo dnf config-manager --set-enable rpmfusion-nonfree-nvidia-driver

sudo dnf install --assumeyes \
    akmod-nvidia \
    libva-utils \
    libva-vdpau-driver \
    vdpauinfo \
    xorg-x11-drv-nvidia \
    xorg-x11-drv-nvidia-cuda \
    xorg-x11-drv-nvidia-cuda-libs \
    xorg-x11-drv-nvidia-libs \
    xorg-x11-drv-nvidia-libs.i686 \
    vulkan-loader

echo "%global _with_kmod_nvidia_open 1" | sudo tee --append /etc/rpm/macros-nvidia-kmod
sudo akmods --force

sudo grubby --update-kernel=ALL --args='nvidia-drm.modeset=1'
sudo dracut --force
```

 :warning: A reboot is required after this point.

**[:arrow_up: back to top](#fedora-workstation)**

### 2.4. Multimedia Codecs

Install the multimedia codecs for DRM-protected content:

```bash
sudo dnf install --assumeyes \
    ffmpeg \
    gstreamer1-libav \
    gstreamer1-plugins-{bad-\*,good-\*,base} \
    gstreamer1-plugin-openh264 \
    lame\* \
    --exclude=gstreamer1-plugins-bad-free-devel \
    --exclude=lame-devel

sudo dnf group upgrade --assumeyes --with-optional Multimedia
```

**[:arrow_up: back to top](#fedora-workstation)**
