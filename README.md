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
| Desktop Environment                       | [Gnome](https://www.gnome.org/)                                         |
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
  - [4. Desktop Setup](#4-desktop-setup)
    - [4.1. Desktop Settings](#41-desktop-settings)
      - [4.1.1. Global](#411-global)
      - [4.1.2. Fonts](#412-fonts)
    - [4.2. Desktop Extensions](#42-desktop-extensions)
      - [4.2.1. Prerequisites](#421-prerequisites)
      - [4.2.2. Extensions List](#422-extensions-list)
    - [4.3. Desktop Theme](#43-desktop-theme)
      - [4.3.1. Prerequisites](#431-prerequisites)
      - [4.3.2. Shell Theme](#432-shell-theme)
      - [4.3.3. Icon Theme](#433-icon-theme)
      - [4.3.4. Cursor Theme](#434-cursor-theme)
  - [5. Terminal Setup](#5-terminal-setup)
    - [5.1. Terminal Settings](#51-terminal-settings)
    - [5.2. Terminal Theme](#52-terminal-theme)

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
  | `sudo reboot`                                   |

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
  | `sudo reboot`                                   |

</div>

**[:arrow_up: Back to Top](#1-table-of-contents)**

### 3.4. Multimedia Codecs

Install the multimedia codecs for hardware-acceleration and content playback:

```bash
sudo dnf config-manager --set-enable fedora-cisco-openh264

sudo dnf install --assumeyes \
    ffmpeg \
    ffmpeg-libs \
    gstreamer1-libav \
    gstreamer1-plugins-{bad-\*,good-\*,base} \
    gstreamer1-plugin-openh264 \
    mozilla-openh264 \
    lame\* \
    --exclude=gstreamer1-plugins-bad-free-devel \
    --exclude=lame-devel

sudo dnf group update --assumeyes --with-optional multimedia
flatpak install --assumeyes org.freedesktop.Platform.ffmpeg-full//22.08
```

**[:arrow_up: Back to Top](#1-table-of-contents)**

## 4. Desktop Setup

### 4.1. Desktop Settings

#### 4.1.1. Global

Use the following to configure GNOME settings:

```bash
gsettings set org.gnome.desktop.calendar show-weekdate true
gsettings set org.gnome.desktop.interface clock-show-date true
gsettings set org.gnome.desktop.interface clock-show-weekday true
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.desktop.interface enable-hot-corners true
gsettings set org.gnome.desktop.wm.preferences button-layout "close,minimize,maximize:appmenu"

gsettings set org.gnome.mutter center-new-windows true

gsettings set org.gnome.nautilus.preferences default-folder-viewer "list-view"
gsettings set org.gnome.nautilus.preferences show-hidden-files true
gsettings set org.gnome.nautilus.window-state sidebar-width 220

gsettings set org.gnome.desktop.interface font-antialiasing "rgba"
gsettings set org.gtk.Settings.FileChooser show-hidden true
```

**[:arrow_up: Back to Top](#1-table-of-contents)**

#### 4.1.2. Fonts

Set up the following fonts:

```bash
sudo dnf install --assumeyes \
  google-roboto-fonts \
  google-roboto-mono-fonts

gsettings set org.gnome.desktop.interface document-font-name "Roboto 11"
gsettings set org.gnome.desktop.interface font-name "Roboto 11"
gsettings set org.gnome.desktop.interface monospace-font-name "Roboto Mono 10"
gsettings set org.gnome.desktop.wm.preferences titlebar-font "Roboto 11"
```

**[:arrow_up: Back to Top](#1-table-of-contents)**

### 4.2. Desktop Extensions

#### 4.2.1. Prerequisites

Install the GNOME extension manager:

```bash
sudo flatpak install --assumeyes flathub org.gnome.Extensions
sudo flatpak override --filesystem=home org.gnome.Extensions
sudo flatpak override --device=dri org.gnome.Extensions
```

Install the GNOME extension installer:

```bash
sudo dnf install --assumeyes \
  bash \
  curl \
  dbus \
  git \
  less \
  perl

wget "https://github.com/brunelli/gnome-shell-extension-installer/raw/master/gnome-shell-extension-installer"
chmod +x gnome-shell-extension-installer
sudo mv --verbose gnome-shell-extension-installer /usr/bin/
```

**[:arrow_up: Back to Top](#1-table-of-contents)**

#### 4.2.2. Extensions List

- Alphabetical App Grid

```bash
cd /usr/share/glib-2.0/schemas
sudo wget "https://raw.githubusercontent.com/stuarthayhurst/alphabetical-grid-extension/master/extension/schemas/org.gnome.shell.extensions.AlphabeticalAppGrid.gschema.xml"
sudo glib-compile-schemas .

gnome-shell-extension-installer --yes 4269
```

- Blur my Shell

```bash
cd /usr/share/glib-2.0/schemas
sudo wget "https://raw.githubusercontent.com/aunetx/blur-my-shell/master/schemas/org.gnome.shell.extensions.blur-my-shell.gschema.xml"
sudo glib-compile-schemas .

gnome-shell-extension-installer --yes 3193
```

- Dash-to-Dock

```bash
cd /usr/share/glib-2.0/schemas
sudo wget "https://raw.githubusercontent.com/micheleg/dash-to-dock/master/schemas/org.gnome.shell.extensions.dash-to-dock.gschema.xml"
sudo glib-compile-schemas .

gnome-shell-extension-installer --yes 307
```

- GNOME User Themes

```bash
cd /usr/share/glib-2.0/schemas
sudo wget "https://gitlab.gnome.org/GNOME/gnome-shell-extensions/-/raw/main/extensions/user-theme/org.gnome.shell.extensions.user-theme.gschema.xml"
sudo glib-compile-schemas .

gnome-shell-extension-installer --yes 19
```

- Hide Top Bar

```bash
cd /usr/share/glib-2.0/schemas
sudo wget "https://raw.githubusercontent.com/tuxor1337/hidetopbar/master/schemas/org.gnome.shell.extensions.hidetopbar.gschema.xml"
sudo glib-compile-schemas .

gnome-shell-extension-installer --yes 545
```

- Tray Icons: Reloaded

```bash
cd /usr/share/glib-2.0/schemas
sudo wget "https://raw.githubusercontent.com/MartinPL/Tray-Icons-Reloaded/master/schemas/org.gnome.shell.extensions.trayIconsReloaded.gschema.xml"
sudo glib-compile-schemas .

gnome-shell-extension-installer --yes 2890
```

<div align="center">

  | :warning: A logout is required after this point |
  | ----------------------------------------------- |
  | `gnome-session-quit --no-prompt`                |

</div>

Once logged back in, run the following commands to:

- enable all the previously installed extensions:

```bash
gnome-extensions disable background-logo@fedorahosted.org

gnome-extensions enable AlphabeticalAppGrid@stuarthayhurst
gnome-extensions enable blur-my-shell@aunetx
gnome-extensions enable dash-to-dock@micxgx.gmail.com
gnome-extensions enable hidetopbar@mathieu.bidon.ca
gnome-extensions enable trayIconsReloaded@selfmade.pl
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
```

- configure them automatically:

```bash
gsettings set org.gnome.shell.extensions.alphabetical-app-grid folder-order-position "alphabetical"
gsettings set org.gnome.shell.extensions.alphabetical-app-grid logging-enabled false
gsettings set org.gnome.shell.extensions.alphabetical-app-grid sort-folder-contents true

gsettings set org.gnome.shell.extensions.blur-my-shell brightness 1.0
gsettings set org.gnome.shell.extensions.blur-my-shell color-and-noise false
gsettings set org.gnome.shell.extensions.blur-my-shell hacks-level 1
gsettings set org.gnome.shell.extensions.blur-my-shell sigma 200
gsettings set org.gnome.shell.extensions.blur-my-shell.appfolder customize false
gsettings set org.gnome.shell.extensions.blur-my-shell.applications blur false
gsettings set org.gnome.shell.extensions.blur-my-shell.applications blur-on-overview false
gsettings set org.gnome.shell.extensions.blur-my-shell.applications customize false
gsettings set org.gnome.shell.extensions.blur-my-shell.applications enable-all false
gsettings set org.gnome.shell.extensions.blur-my-shell.applications opacity 255
gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock blur false
gsettings set org.gnome.shell.extensions.blur-my-shell.hidetopbar compatibility false
gsettings set org.gnome.shell.extensions.blur-my-shell.overview style-components 0
gsettings set org.gnome.shell.extensions.blur-my-shell.panel brightness 1.0
gsettings set org.gnome.shell.extensions.blur-my-shell.panel override-background-dynamically true
gsettings set org.gnome.shell.extensions.blur-my-shell.panel sigma 0
gsettings set org.gnome.shell.extensions.blur-my-shell.panel unblur-in-overview true
gsettings set org.gnome.shell.extensions.blur-my-shell.screenshot blur false

gsettings set org.gnome.shell.extensions.dash-to-dock apply-custom-theme false
gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 0.0
gsettings set org.gnome.shell.extensions.dash-to-dock click-action "minimize"
gsettings set org.gnome.shell.extensions.dash-to-dock custom-background-color false
gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-customize-running-dots true
gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-running-dots-border-color 'rgb(36,36,36)'
gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-shrink true
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 42
gsettings set org.gnome.shell.extensions.dash-to-dock disable-overview-on-startup true
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
gsettings set org.gnome.shell.extensions.dash-to-dock height-fraction 1.0
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide-mode "MAXIMIZED_WINDOWS"
gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts-only-mounted false
gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode "FIXED"

gsettings set org.gnome.shell.extensions.hidetopbar enable-active-window true
gsettings set org.gnome.shell.extensions.hidetopbar enable-intellihide true
gsettings set org.gnome.shell.extensions.hidetopbar hot-corner true
gsettings set org.gnome.shell.extensions.hidetopbar keep-round-corners true
gsettings set org.gnome.shell.extensions.hidetopbar mouse-sensitive false
gsettings set org.gnome.shell.extensions.hidetopbar mouse-sensitive-fullscreen-window false
gsettings set org.gnome.shell.extensions.hidetopbar mouse-triggers-overview true
gsettings set org.gnome.shell.extensions.hidetopbar show-in-overview true

gsettings set org.gnome.shell.extensions.trayIconsReloaded icons-limit 5
```

**[:arrow_up: Back to Top](#1-table-of-contents)**

### 4.3. Desktop Theme

#### 4.3.1. Prerequisites

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

sudo ./tweaks.sh \
  --gdm \
  --icon fedora
```

**[:arrow_up: Back to Top](#1-table-of-contents)**

#### 4.3.3. Icon Theme

Use the following commands to install the [WhiteSur icon theme](https://github.com/vinceliuice/WhiteSur-icon-theme):

```bash
cd ~/.themes/_sources/WhiteSur

git clone "https://github.com/vinceliuice/WhiteSur-icon-theme.git" icons
cd icons

./install.sh \
  --bold

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

## 5. Terminal Setup

### 5.1. Terminal Settings

Install `zsh` and `oh-my-zsh`:

```bash
sudo dnf install --assumeyes \
  neofetch \
  util-linux-user \
  zsh

sudo usermod --shell /bin/zsh $USER
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

<div align="center">

  | :warning: A reboot is required after this point |
  | ----------------------------------------------- |
  | `sudo reboot`                                   |

</div>

**[:arrow_up: Back to Top](#1-table-of-contents)**

### 5.2. Terminal Theme

Install the [Monokai terminal theme](https://github.com/0xcomposure/monokai-gnome-terminal):

```bash
sudo dnf install --assumeyes dconf

mkdir --parents ~/.themes/_sources/Monokai
cd ~/.themes/_sources/Monokai

git clone "https://github.com/0xComposure/monokai-gnome-terminal" terminal
cd terminal

echo "1\nYES\n" | ./install.sh
```

**[:arrow_up: Back to Top](#1-table-of-contents)**
