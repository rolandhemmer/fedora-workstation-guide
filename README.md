<div align="center">
  <br>
  <br>
  <br>
  <img src="images/fedora-logo.png" alt="Fedora" width="450"/>
  <br>
  <br>
  <br>
</div>

# Workstation Installation Guide

**[:arrow_down: Go to Main Content](#1-table-of-contents)**

## 0. Introduction

Installation guide and **personal** post-installation steps.  
This purpose of this document is to provide a quick, clean and minimal Fedora-based setup.

This installation represents a **personal point-of-view**, with a private workstation in mind.  
It does not cover all the use-cases one can expect, or suit a specific need with a specific machine.  
Details provided here are mostly for educational and information purposes, and to complete a personal vision of what a personal operating system should be.

<div align="center">

|                                           |                                                                         |
| ----------------------------------------- | ----------------------------------------------------------------------- |
| Operating System                          | [Fedora Workstation 36](https://getfedora.org/en/workstation/download/) |
| Operating System Version                  | 36 (x86_x64)                                                            |
| Desktop Environment                       | [Pantheon](https://elementary.io/)                                      |
| Desktop Theme                             | [WhiteSur](https://github.com/vinceliuice/WhiteSur-gtk-theme)           |
| Preferred Application Installation Method | [Flatpak](https://flatpak.org/)                                         |
|                                           |                                                                         |
| UEFI                                      | :heavy_check_mark: Enabled                                              |
| UEFI Password                             | :heavy_check_mark: Enabled                                              |
| TPM                                       | :heavy_check_mark: Enabled (v1.2+)                                      |
| Secure Boot                               | :heavy_check_mark: Enabled                                              |
| Disk Encryption                           | :heavy_check_mark: Enabled (LUKS)                                       |

</div>

### 0.1. Disclaimer

The examples and code samples from this repository are provided "as is" without warranty of any kind, either express or implied.  
No advice or information, whether oral or written, obtained by you from the author or from this repository shall create any warranty of any kind.

The use of the software and scripts downloaded on this repository is done at your own discretion and risk and with agreement that you will be solely responsible for any damage to your computer system or loss of data that results from such activities.  
You are solely responsible for adequate protection and backup of the data and equipment used in connection with any of the software, and the author will not be liable for any damages that you may suffer in connection with using, modifying or distributing any of this software.

The author assume no responsibility for errors or omissions in the software or documentation available from this repository.  
In no event shall the author be liable to you or any third parties for any special, punitive, incidental, indirect or consequential damages of any kind, or any damages whatsoever, including, without limitation, those resulting from loss of use, data or profits, and on any theory of liability, arising out of or in connection with the use of this software.

### 0.2. License

This repository is available under the MIT license.  
It also includes external libraries that are available under a variety of licenses.

See the [LICENSE.md](LICENSE.md) file for the full license text.

Fedora and the Fedora logo are trademarks or registered trademarks of Red Hat, Inc.  
All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.

---

## 1. Table of Contents

- [Workstation Installation Guide](#workstation-installation-guide)
  - [0. Introduction](#0-introduction)
    - [0.1. Disclaimer](#01-disclaimer)
    - [0.2. License](#02-license)
  - [1. Table of Contents](#1-table-of-contents)
  - [2. System Installation](#2-system-installation)
  - [3. System Setup](#3-system-setup)
    - [3.1. System Upgrade](#31-system-upgrade)
    - [3.2. System Drivers](#32-system-drivers)
    - [3.3. Nvidia Drivers](#33-nvidia-drivers)
      - [3.3.1. Prerequisites](#331-prerequisites)
      - [3.3.2. Auto Kernel Signing](#332-auto-kernel-signing)
      - [3.3.3. Installation](#333-installation)
    - [3.4. Multimedia Codecs](#34-multimedia-codecs)
  - [4. Environment Setup](#4-environment-setup)
    - [4.1. Desktop Setup](#41-desktop-setup)
    - [4.2. Desktop Settings](#42-desktop-settings)
      - [4.2.1. Global](#421-global)
      - [4.2.1. Fonts](#421-fonts)
    - [4.3. Desktop Theme](#43-desktop-theme)
      - [4.3.1 Prerequisites](#431-prerequisites)
      - [4.3.2. Shell Theme](#432-shell-theme)
      - [4.3.3. Icon Theme](#433-icon-theme)
      - [4.3.4. Cursor Theme](#434-cursor-theme)

## 2. System Installation

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

**[:arrow_up: Back to Top](#1-table-of-contents)**

## 3. System Setup

### 3.1. System Upgrade

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

**[:arrow_up: Back to Top](#1-table-of-contents)**

### 3.2. System Drivers

Add the `fwupd` command, and run it to check for driver and firmware updates:

```bash
sudo dnf install --assumeyes fwupd
sudo fwupdmgr refresh --assume-yes --force
sudo fwupdmgr get-updates --assume-yes
```

**[:arrow_up: Back to Top](#1-table-of-contents)**

### 3.3. Nvidia Drivers

#### 3.3.1. Prerequisites

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

**[:arrow_up: Back to Top](#1-table-of-contents)**

#### 3.3.2. Auto Kernel Signing

Enable Nvidia kernel module auto-signing:

```bash
sudo kmodgenca --auto
sudo mokutil --import /etc/pki/akmods/certs/public_key.der
```

<div align="center">

  | :warning: A reboot is required after this point |
  | ----------------------------------------------- |

  | :red_circle: Manual actions                                                                      |
  | ------------------------------------------------------------------------------------------------ |
  | At reboot, choose `Enroll MOK`, `Continue`, `Yes`, then enter the selected password, and reboot. |

</div>

**[:arrow_up: Back to Top](#1-table-of-contents)**

#### 3.3.3. Installation

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

sudo grubby --update-kernel=ALL --args="nvidia-drm.modeset=1"
sudo dracut --force
```

<div align="center">

  | :warning: A reboot is required after this point |
  | ----------------------------------------------- |

</div>

**[:arrow_up: Back to Top](#1-table-of-contents)**

### 3.4. Multimedia Codecs

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

**[:arrow_up: Back to Top](#1-table-of-contents)**

## 4. Environment Setup

### 4.1. Desktop Setup

Install the Pantheon desktop from elementaryOS:

```bash
sudo dnf group install --assumeyes "Pantheon Desktop"
sudo dnf install --assumeyes lightdm
sudo systemctl disable gdm
sudo systemctl enable lightdm
```

<div align="center">

  | :warning: A reboot is required after this point |
  | ----------------------------------------------- |

</div>

**[:arrow_up: Back to Top](#1-table-of-contents)**

### 4.2. Desktop Settings

#### 4.2.1. Global

Use the following to configure the Pantheon settings:

```bash
gsettings set .io.elementary.terminal.settings unsafe-paste-alert false

gsettings set org.gnome.desktop.calendar show-weekdate true
gsettings set org.gnome.desktop.interface clock-show-date true
gsettings set org.gnome.desktop.interface clock-show-weekday true

gsettings set org.gnome.mutter center-new-windows true

gsettings set org.pantheon.desktop.gala.behavior hotcorner-topleft "show-workspace-view"
```

<div align="center">

| :red_circle: Manual actions                                                                                                                 |
| ------------------------------------------------------------------------------------------------------------------------------------------- |
| Go to `System Settings`, `Tweaks`, and in the `Window Control` page:<br>- select `Force to use dark stylesheet`<br>- select `Layout: macOS` |

</div>

**[:arrow_up: Back to Top](#1-table-of-contents)**

#### 4.2.1. Fonts

Set up the following fonts:

```bash
sudo dnf install --assumeyes \
  google-roboto-fonts \
  google-roboto-mono-fonts

gsettings set org.gnome.desktop.interface document-font-name "Roboto 10"
gsettings set org.gnome.desktop.interface font-name "Roboto 9"
gsettings set org.gnome.desktop.interface monospace-font-name "Roboto Mono 10"
gsettings set org.gnome.desktop.wm.preferences titlebar-font "Roboto 10"
```

**[:arrow_up: Back to Top](#1-table-of-contents)**

### 4.3. Desktop Theme

#### 4.3.1 Prerequisites

```bash
mkdir --parents ~/.themes/_sources/WhiteSur

sudo dnf install --assumeyes \
  glib2-devel \
  inkscape \
  libxml2 \
  optipng \
  sassc
```

**[:arrow_up: Back to Top](#1-table-of-contents)**

#### 4.3.2. Shell Theme

Use the following commands to install the [WhiteSur GTK theme](https://github.com/vinceliuice/WhiteSur-gtk-theme):

```bash
cd ~/.themes/_sources/WhiteSur

git clone "https://github.com/vinceliuice/WhiteSur-gtk-theme.git" shell
cd shell

./install.sh \
  --icon fedora \
  --libadwaita \
  --monterey \
  --opacity solid

gsettings set org.gnome.desktop.interface gtk-theme "WhiteSur-Dark-solid"
gsettings set org.gnome.shell.extensions.user-theme name "WhiteSur-Dark-solid"
```

**[:arrow_up: Back to Top](#1-table-of-contents)**

#### 4.3.3. Icon Theme

Use the following commands to install the [WhiteSur icon theme](https://github.com/vinceliuice/WhiteSur-icon-theme):

```bash
cd ~/.themes/_sources/WhiteSur

git clone "https://github.com/vinceliuice/WhiteSur-icon-theme.git" icons
cd icons

./install.sh

gsettings set org.gnome.desktop.interface icon-theme "WhiteSur-dark"
```

**[:arrow_up: Back to Top](#1-table-of-contents)**

#### 4.3.4. Cursor Theme

Use the following commands to install the [WhiteSur cursor theme](https://github.com/vinceliuice/WhiteSur-cursors):

```bash
cd ~/.themes/_sources/WhiteSur

git clone "https://github.com/vinceliuice/WhiteSur-cursors.git" cursors
cd cursors

./install.sh

gsettings set org.gnome.desktop.interface cursor-theme "WhiteSur-cursors"
```

**[:arrow_up: Back to Top](#1-table-of-contents)**
