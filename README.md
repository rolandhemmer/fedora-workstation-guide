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

|                                           |                                                                              |
| ----------------------------------------- | ---------------------------------------------------------------------------- |
| Operating System                          | [Fedora Workstation 36](https://getfedora.org/en/workstation/download/)      |
| Operating System Version                  | 36 (x86_x64)                                                                 |
| Desktop Environment                       | [Gnome](https://www.gnome.org/)                                              |
| GNOME Cursor Theme                        | [Colloid](https://github.com/vinceliuice/Colloid-icon-theme)                 |
| GNOME Icon Theme                          | [Colloid](https://github.com/vinceliuice/Colloid-icon-theme)                 |
| GNOME Shell Theme                         | [Tokyo-Night](https://github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme.git) |
| Preferred Application Installation Method | [Flatpak](https://flatpak.org/)                                              |
|                                           |                                                                              |
| UEFI                                      | :heavy_check_mark: Enabled                                                   |
| UEFI Password                             | :heavy_check_mark: Enabled                                                   |
| TPM                                       | :heavy_check_mark: Enabled (v1.2+)                                           |
| Secure Boot                               | :heavy_check_mark: Enabled                                                   |
| Disk Encryption                           | :heavy_check_mark: Enabled (LUKS)                                            |

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
  - [4. System Hardening](#4-system-hardening)
    - [4.1. Kernel Hardening](#41-kernel-hardening)
    - [4.2. Boot Hardening](#42-boot-hardening)
  - [5. Terminal Setup](#5-terminal-setup)
    - [5.1. Terminal Settings](#51-terminal-settings)
  - [6. Desktop Setup](#6-desktop-setup)
    - [6.1. Desktop Settings](#61-desktop-settings)
      - [6.1.1. Global](#611-global)
      - [6.1.2. Fonts](#612-fonts)
    - [6.2. Desktop Extensions](#62-desktop-extensions)
      - [6.2.1. Prerequisites](#621-prerequisites)
      - [6.2.2. Extensions List](#622-extensions-list)
    - [6.3. Desktop Theme](#63-desktop-theme)
      - [6.3.1. Shell Theme](#631-shell-theme)
      - [6.3.2. Icon Theme](#632-icon-theme)
      - [6.3.3. Cursor Theme](#633-cursor-theme)
      - [6.3.4. Terminal Theme](#634-terminal-theme)

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

sudo tee --append /etc/dnf/dnf.conf > /dev/null << EOT

deltarpm=true
fastestmirror=1
max_parallel_downloads=20
EOT

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

  | :warning: A reboot is required for this section |
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
sudo dracut --regenerate-all --force
```

<div align="center">

  | :warning: A reboot is required for this section |
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
sudo flatpak install --assumeyes org.freedesktop.Platform.ffmpeg-full//22.08
sudo flatpak override --device=dri
```

**[:arrow_up: Back to Top](#1-table-of-contents)**

## 4. System Hardening

### 4.1. Kernel Hardening

Update the following kernel settings:

```bash
sudo tee --append /etc/sysctl.conf > /dev/null << EOT

## Kernel Self-Protection

# Reduces buffer overflows attacks
kernel.randomize_va_space=1

# Mitigates kernel pointer leaks
kernel.kptr_restrict=2

# Restricts the kernel log to the CAP_SYSLOG capability
kernel.dmesg_restrict=1
kernel.printk=3 3 3 3

# Restricts eBPF and reduce its attack surface
kernel.unprivileged_bpf_disabled=1

# Enables JIT hardening techniques
net.core.bpf_jit_harden=2

# Restricts loading TTY line disciplines to the CAP_SYS_MODULE capability
dev.tty.ldisc_autoload=0

# Restricts the userfaultfd() syscall to the CAP_SYS_PTRACE capability
vm.unprivileged_userfaultfd=0

# Disables the kexec system call to avoid abuses
kernel.kexec_load_disabled=1

# Disables the SysRq key completely
kernel.sysrq=0

# Restricts most of the performance events to the CAP_PERFMON capability
kernel.perf_event_paranoid=2

## Network Protection

# Protects against SYN flood attacks
net.ipv4.tcp_syncookies=1

# Protects against time-wait assassination
net.ipv4.tcp_rfc1337=1

# Protects against IP spoofing
net.ipv4.conf.all.rp_filter=1
net.ipv4.conf.default.rp_filter=1

# Avoids Smurf attacks and prevent clock fingerprinting through ICMP timestamps
net.ipv4.icmp_echo_ignore_all=1

## User Space Protection

# Prevents hard links from being created by users that do not have read/write access to the source file, and prevent common TOCTOU races
fs.protected_symlinks=1
fs.protected_hardlinks=1

# Prevents creating files in potentially attacker-controlled environments
fs.protected_fifos=2
fs.protected_regular=2

EOT

sudo sysctl -p
```

<div align="center">

  | :warning: A reboot is required for this section |
  | ----------------------------------------------- |
  | `sudo reboot`                                   |

</div>

**[:arrow_up: Back to Top](#1-table-of-contents)**

### 4.2. Boot Hardening

Update the following boot settings:

```bash
# "debugfs=off" -> removes sensitive kernel information during boot
# "init_on_alloc=1 init_on_free=1" -> mitigates use-after-free vulnerabilities and erases sensitive information in memory
# "lockdown=confidentiality" -> reduces kernel privileges escalation methods via user space (implies "module.sig_enforce=1")
# "loglevel=0" -> prevents information leaks during boot (implies "quiet" on boot, and "kernel.kptr_restrict=2" on sysctl.conf)
# "module.sig_enforce=1" -> only allows kernel modules that have been signed with a valid key
# "page_alloc.shuffle=1" -> improves security by making page allocations less predictable, and improves performance
# "pti=on" -> mitigates Meltdown and prevents some KASLR bypasses
# "randomize_kstack_offset=on" -> reduces attacks that rely on deterministic kernel stack layout
# "slab_nomerge" -> prevents overwriting objects from merged caches
# "spectre_v2=on spec_store_bypass_disable=on tsx=off tsx_async_abort=full,nosmt mds=full,nosmt l1tf=full,force nosmt=force kvm.nx_huge_pages=force" -> enables all built-in mitigations for all known CPU vulnerabilities (microcode updates should be installed to reduce performance impact)
# "vsyscall=none" -> disables vsyscalls (obsolete, and replaced by vDSO)

sudo grubby --update-kernel=ALL --args="debugfs=off init_on_alloc=1 init_on_free=1 lockdown=confidentiality loglevel=0 module.sig_enforce=1 page_alloc.shuffle=1 pti=on randomize_kstack_offset=on slab_nomerge spectre_v2=on spec_store_bypass_disable=on tsx=off tsx_async_abort=full,nosmt mds=full,nosmt l1tf=full,force nosmt=force kvm.nx_huge_pages=force vsyscall=none"
```

<div align="center">

  | :warning: A reboot is required for this section |
  | ----------------------------------------------- |
  | `sudo reboot`                                   |

</div>

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

  | :warning: A reboot is required for this section |
  | ----------------------------------------------- |
  | `sudo reboot`                                   |

</div>

**[:arrow_up: Back to Top](#1-table-of-contents)**

## 6. Desktop Setup

### 6.1. Desktop Settings

#### 6.1.1. Global

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

#### 6.1.2. Fonts

Set up the following fonts:

```bash
sudo dnf install --assumeyes \
  google-roboto-fonts \
  google-roboto-mono-fonts

gsettings set org.gnome.desktop.interface document-font-name "Roboto 11"
gsettings set org.gnome.desktop.interface font-name "Roboto 11"
gsettings set org.gnome.desktop.interface monospace-font-name "Roboto Mono 11"
gsettings set org.gnome.desktop.wm.preferences titlebar-font "Roboto 11"
```

**[:arrow_up: Back to Top](#1-table-of-contents)**

### 6.2. Desktop Extensions

#### 6.2.1. Prerequisites

Install GNOME tweaks:

```bash
sudo dnf install --assumeyes gnome-tweaks
sudo flatpak override --filesystem=xdg-config/gtk-3.0
sudo flatpak override --filesystem=xdg-config/gtk-4.0
```

Install the GNOME extension manager:

```bash
sudo flatpak install --assumeyes flathub org.gnome.Extensions
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

#### 6.2.2. Extensions List

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

  | :warning: A logout is required for this section |
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

### 6.3. Desktop Theme

#### 6.3.1. Shell Theme

Use the following commands to install the [Tokyo-Night GTK theme](https://github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme):

```bash
mkdir --parents ~/.themes/_sources/Tokyo-Night
cd ~/.themes/_sources/Tokyo-Night

git clone "https://github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme.git" shell
cd shell

cd themes
cp --recursive Tokyonight-Dark-BL ~/.themes/

cd Gnome42
cp Tokyonight-Dark-BL.css ~/.config/gtk-4.0/gtk.css

gsettings set org.gnome.desktop.interface gtk-theme "Tokyonight-Dark-BL"
gsettings set org.gnome.shell.extensions.user-theme name "Tokyonight-Dark-BL"
```

**[:arrow_up: Back to Top](#1-table-of-contents)**

#### 6.3.2. Icon Theme

Use the following commands to install the [Colloid icon theme](https://github.com/vinceliuice/Colloid-icon-theme):

```bash
mkdir --parents ~/.themes/_sources/Colloid
cd ~/.themes/_sources/Colloid

git clone "https://github.com/vinceliuice/Colloid-icon-theme.git" icons
cd icons

./install.sh \
  --scheme default \
  --theme default

gsettings set org.gnome.desktop.interface icon-theme "Colloid"
```

**[:arrow_up: Back to Top](#1-table-of-contents)**

#### 6.3.3. Cursor Theme

Use the following commands to install the [Colloid cursor theme](https://github.com/vinceliuice/Colloid-icon-theme):

```bash
mkdir --parents ~/.themes/_sources/Colloid
cd ~/.themes/_sources/Colloid

git clone "https://github.com/vinceliuice/Colloid-icon-theme.git" cursors
cd cursors/cursors

./install.sh

gsettings set org.gnome.desktop.interface cursor-theme "Colloid-cursors"
```

**[:arrow_up: Back to Top](#1-table-of-contents)**

#### 6.3.4. Terminal Theme

Install the [Tokyo-Night terminal theme](https://github.com/nathanroark/tokyo-night-gnome-terminal):

```bash
sh -c "$(curl --fail --location --silent --show-error https://raw.githubusercontent.com/nathanroark/tokyo-night-gnome-terminal/main/tokyo-night.sh)"
```

**[:arrow_up: Back to Top](#1-table-of-contents)**
