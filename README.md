<div align="center">
  <br>
  <br>
  <img src="images/fedora-logo.png" alt="Fedora" width="350"/>
  <br>
  <br>
  <br>
</div>

# Fedora Workstation Installation Guide

Installation guide and **personal** post-installation steps.  
This purpose of this document is to provide a quick, clean, minimalist, gaming-ready, production-ready, Fedora setup.

This installation represents a **personal point-of-view**, with a **private** workstation in mind.  
Details provided here are mostly for educational and information purposes, and to complete a **personal** vision of what a personal operating system should be.

## Quick Start

Requirements are:

- an UEFI platform (the more up-to-date, the better)
- the UEFI Secure Boot enabled
- a TPM 2.0 chip
- a fresher than fresh Fedora installation, with encryption enabled (LUKS)

These scripts are better run right after the fresh Fedora installation.  
On the very first reboot, after creating your account:

- disable `Location Services`
- disable `Automatic Problem Reporting`
- enable `Third-Party Repositories`

Then, run (**not** as `sudo`):

> All script arguments can be combined.

```bash
./00_setup.sh
```

- If you have a Nvidia GPU, run:

```bash
./00_setup.sh --nvidia-drivers
```

- If you have an encrypted LUKS installation **and** a TPM 2.0 chip, run:

```bash
./00_setup.sh --luks-partition="<partition-name>"
```

> See [4.3. LUKS Decryption With TPM](#43-luks-decryption-with-tpm) on how to identify the correct partition name.  
> If the system has been installed on an NVMe disk alone, the partition name will likely be:  
> `/dev/nvme0n1p3`

Once done, reboot to apply changes:

```bash
sudo reboot
```

After reboot, finish the installation with:

```bash
./01_setup.sh
```

Done!

## License

This repository is available under the MIT license.  
It also includes external libraries that are available under a variety of licenses.

Per the MIT license, the use of the software and scripts downloaded from this repository is done at your own discretion and risk.  
See the [LICENSE.md](LICENSE.md) file for the full license text.

<sub>Fedora and the Fedora logo are trademarks or registered trademarks of Red Hat, Inc.<br>All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.</sub>

---

## 0. Details

- [Fedora Workstation Installation Guide](#fedora-workstation-installation-guide)
  - [Quick Start](#quick-start)
  - [License](#license)
  - [0. Details](#0-details)
  - [1. System Setup](#1-system-setup)
    - [1.1. System Upgrade](#11-system-upgrade)
    - [1.2. System Drivers](#12-system-drivers)
    - [1.3. Nvidia Drivers](#13-nvidia-drivers)
      - [1.3.1. Prerequisites](#131-prerequisites)
      - [1.3.2. Kernel Module Auto-Signing](#132-kernel-module-auto-signing)
      - [1.3.3. Installation](#133-installation)
  - [2. System Hardening](#2-system-hardening)
    - [2.1. Kernel Hardening](#21-kernel-hardening)
    - [2.2. Boot Hardening](#22-boot-hardening)
    - [2.3. LUKS Decryption With TPM](#23-luks-decryption-with-tpm)
  - [3. Multimedia Codecs](#3-multimedia-codecs)
  - [4. Desktop Setup](#4-desktop-setup)
    - [4.1. Desktop Settings](#41-desktop-settings)
      - [4.1.1. Global](#411-global)
      - [4.1.2. Fonts](#412-fonts)
    - [4.2. Desktop Theme](#42-desktop-theme)
      - [4.2.1. Shell Theme](#421-shell-theme)
      - [4.2.2. Icon Theme](#422-icon-theme)
      - [4.3.3. Cursor Theme](#433-cursor-theme)
    - [4.3. Desktop Extensions](#43-desktop-extensions)
      - [4.3.1. Prerequisites](#431-prerequisites)
      - [4.3.2. Extensions List](#432-extensions-list)
  - [5. Terminal Theme](#5-terminal-theme)
  - [6. Applications](#6-applications)
  - [7. Gaming](#7-gaming)
  - [8. Cleanup](#8-cleanup)

**[:arrow_up: Back to Top](#0-details)**

## 1. System Setup

### 1.1. System Upgrade

Update DNF settings:

```bash
sudo tee --append /etc/dnf/dnf.conf <<EOT
deltarpm=true
fastestmirror=1
max_parallel_downloads=20
EOT
```

Enable the Flathub repository:

``` bash
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

Update and clean existing installed Flatpaks:

```bash
flatpak repair --user
flatpak update --assumeyes --user
flatpak uninstall --assumeyes --unused --user

sudo flatpak repair --system
sudo flatpak update --assumeyes --system
sudo flatpak uninstall --assumeyes --unused --system

sudo flatpak override --reset
```

Enabling the Fedora RPM Fusion repositories:

```bash
sudo dnf install --assumeyes https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install --assumeyes https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

sudo dnf install --assumeyes \
    fedora-workstation-repositories \
    rpmfusion-free-appstream-data \
    rpmfusion-nonfree-appstream-data

sudo dnf group update core --assumeyes
```

Perform a full system upgrade:

``` bash
sudo dnf upgrade --assumeyes --refresh
```

Install [Preload](https://copr.fedorainfracloud.org/coprs/elxreno/preload/):

> Preload is an adaptive readahead daemon. It monitors which programs you use the most, and caches (part of) them to speed up their load time.

```bash
sudo dnf copr enable --assumeyes elxreno/preload
sudo dnf install --assumeyes preload

sudo systemctl start preload
sudo systemctl enable preload
```

**[:arrow_up: Back to Top](#0-details)**

### 1.2. System Drivers

Add the `fwupd` command, and run it to check for driver and firmware updates:

```bash
sudo dnf install --assumeyes fwupd

sudo fwupdmgr --assume-yes --force refresh
sudo fwupdmgr --assume-yes --force get-updates
```

**[:arrow_up: Back to Top](#0-details)**

### 1.3. Nvidia Drivers

#### 1.3.1. Prerequisites

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

**[:arrow_up: Back to Top](#0-details)**

#### 1.3.2. Kernel Module Auto-Signing

Enable the Nvidia kernel module auto-signing:

> This will allow the load of the Nvidia drivers and kernel modules even with Secure Boot enabled.
> Repeating this operation might be required after each Nvidia driver update.

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

**[:arrow_up: Back to Top](#0-details)**

#### 1.3.3. Installation

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
    vulkan-loader \
    vulkan-loader.i686

echo "%global _with_kmod_nvidia_open 1" | sudo tee --append /etc/rpm/macros-nvidia-kmod
sudo akmods --force
sudo grubby --update-kernel=ALL --args='nvidia-drm.modeset=1'

echo "options nvidia_drm modeset=1" | sudo tee --append /etc/modprobe.d/nvidia.conf

sudo tee --append /etc/dracut.conf.d/nvidia.conf <<EOT
add_drivers+=" nvidia nvidia_modeset nvidia_uvm nvidia_drm "
install_items+=" /etc/modprobe.d/nvidia.conf "
EOT

sudo dracut --force
```

<div align="center">

  | :warning: A reboot is required for this section |
  | ----------------------------------------------- |
  | `sudo reboot`                                   |

</div>

**[:arrow_up: Back to Top](#0-details)**

## 2. System Hardening

### 2.1. Kernel Hardening

Enable the following kernel self-protection parameters:

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

**[:arrow_up: Back to Top](#0-details)**

### 2.2. Boot Hardening

Enable the following boot parameters:

```bash
sudo grubby --update-kernel=ALL --args="debugfs=off init_on_alloc=1 init_on_free=1 lockdown=confidentiality loglevel=0 module.sig_enforce=1 page_alloc.shuffle=1 pti=on randomize_kstack_offset=on slab_nomerge spectre_v2=on spec_store_bypass_disable=on tsx=off tsx_async_abort=full,nosmt mds=full,nosmt l1tf=full,force nosmt=force kvm.nx_huge_pages=force vsyscall=none"
```

Details:

  - `debugfs=off`: removes sensitive kernel information during boot
  - `init_on_alloc=1 init_on_free=1`: mitigates use-after-free vulnerabilities and erases sensitive information in memory
  - `lockdown=confidentiality`: reduces kernel privileges escalation methods via user space (implies `module.sig_enforce=1`)
  - `loglevel=0`: prevents information leaks during boot (implies `quiet` on boot, and `kernel.kptr_restrict=2` on sysctl.conf)
  - `module.sig_enforce=1`: only allows kernel modules that have been signed with a valid key
  - `page_alloc.shuffle=1`: improves security by making page allocations less predictable, and improves performance
  - `pti=on`: mitigates Meltdown and prevents some KASLR bypasses
  - `randomize_kstack_offset=on`: reduces attacks that rely on deterministic kernel stack layout
  - `slab_nomerge`: prevents overwriting objects from merged caches
  - `spectre_v2=on spec_store_bypass_disable=on tsx=off tsx_async_abort=full,nosmt mds=full,nosmt l1tf=full,force nosmt=force kvm.nx_huge_pages=force`: enables all built-in mitigations for all known CPU vulnerabilities (microcode updates should be installed to reduce performance impact)
  - `vsyscall=none`: disables vsyscalls (obsolete, and replaced by vDSO)

<div align="center">

  | :warning: A reboot is required for this section |
  | ----------------------------------------------- |
  | `sudo reboot`                                   |

</div>

**[:arrow_up: Back to Top](#0-details)**

### 2.3. LUKS Decryption With TPM

First, ensure that:

- a **TPM 2.0 chip** is present and enabled in the UEFI settings
- **Secure Boot** is enabled in the UEFI settings

Run the following command to have confimation:

```bash
cat /sys/class/tpm/tpm0/device/description
```

> Expected result should be:  
> `TPM 2.0 Device`

Then, identify the **partition** that houses the LUKS container:

```bash
lsblk
```

The LUKS container should be named `luks-<GUID>`, of type `crypt`.  
Once found, it will give you the **parition name**.

> If the system has been installed on an NVMe disk alone, the partition name will likely be:  
> `/dev/nvme0n1p3`

With all these elements, run:

```bash
sudo dnf install --assumeyes tpm2-tools

sudo systemd-cryptenroll \
  --tpm2-device=auto \
  --tpm2-pcrs=7+8 \
  <$partition_name>

sudo sed --in-place --expression \
  "/^luks-/s/$/,tpm2-device=auto/" \
  /etc/crypttab

echo 'install_optional_items+=" /usr/lib64/libtss2* /usr/lib64/libfido2.so.* /usr/lib64/cryptsetup/libcryptsetup-token-systemd-tpm2.so "' | sudo tee --append /etc/dracut.conf.d/tss2.conf
sudo dracut --force
```

If the operation is a success, at next reboot, the LUKS container should be decrypted automatically.  
Be aware, this operation might be repeated after every kernel update.

<div align="center">

  | :warning: A reboot is required for this section |
  | ----------------------------------------------- |
  | `sudo reboot`                                   |

</div>

**[:arrow_up: Back to Top](#0-details)**

## 3. Multimedia Codecs

Install the multimedia codecs for hardware-acceleration and content playback:

```bash
sudo dnf config-manager --assumeyes --set-enable fedora-cisco-openh264

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
```

**[:arrow_up: Back to Top](#0-details)**

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
gsettings set org.gnome.desktop.interface font-antialiasing "rgba"
gsettings set org.gnome.desktop.wm.preferences button-layout "close,minimize,maximize:appmenu"

gsettings set org.gnome.mutter center-new-windows true

gsettings set org.gnome.nautilus.preferences default-folder-viewer "list-view"
gsettings set org.gnome.nautilus.preferences show-hidden-files true
gsettings set org.gnome.nautilus.window-state sidebar-width 220

gsettings set org.gtk.Settings.FileChooser show-hidden true
```

**[:arrow_up: Back to Top](#0-details)**

#### 4.1.2. Fonts

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

**[:arrow_up: Back to Top](#0-details)**

### 4.2. Desktop Theme

#### 4.2.1. Shell Theme

Use the following commands to install the [Colloid GTK theme](https://github.com/vinceliuice/Colloid-gtk-theme):

```bash
sudo dnf install --assumeyes \
    gtk-murrine-engine \
    gnome-themes-extra \
    gnome-themes-standard \
    sassc

mkdir --parents ~/.themes/_sources/Colloid
cd ~/.themes/_sources/Colloid

git clone "https://github.com/vinceliuice/Colloid-gtk-theme.git" shell
cd shell

./install.sh \
    --color dark \
    --theme default \
    --tweaks rimless

gsettings set org.gnome.desktop.interface gtk-theme "Colloid-Dark"
gsettings set org.gnome.shell.extensions.user-theme name "Colloid-Dark"
```

**[:arrow_up: Back to Top](#0-details)**

#### 4.2.2. Icon Theme

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

**[:arrow_up: Back to Top](#0-details)**

#### 4.3.3. Cursor Theme

Use the following commands to install the [Colloid cursor theme](https://github.com/vinceliuice/Colloid-icon-theme):

```bash
mkdir --parents ~/.themes/_sources/Colloid
cd ~/.themes/_sources/Colloid

git clone "https://github.com/vinceliuice/Colloid-icon-theme.git" cursors
cd cursors/cursors

./install.sh

gsettings set org.gnome.desktop.interface cursor-theme "Colloid-cursors"
```

**[:arrow_up: Back to Top](#0-details)**

### 4.3. Desktop Extensions

#### 4.3.1. Prerequisites

Install [GNOME tweaks](https://gitlab.gnome.org/GNOME/gnome-tweaks):

```bash
sudo dnf install --assumeyes gnome-tweaks
```

Install the [GNOME extension manager](https://flathub.org/apps/details/org.gnome.Extensions):

```bash
flatpak install --assumeyes --user flathub org.gnome.Extensions
sudo flatpak override --user --device=dri org.gnome.Extensions
```

Install the [GNOME extension installer](https://github.com/brunelli/gnome-shell-extension-installer):

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

**[:arrow_up: Back to Top](#0-details)**

#### 4.3.2. Extensions List

- [Alphabetical App Grid](https://extensions.gnome.org/extension/4269/alphabetical-app-grid/)

```bash
cd /usr/share/glib-2.0/schemas
sudo wget "https://raw.githubusercontent.com/stuarthayhurst/alphabetical-grid-extension/master/extension/schemas/org.gnome.shell.extensions.AlphabeticalAppGrid.gschema.xml"
sudo glib-compile-schemas .

gnome-shell-extension-installer --yes 4269
```

- [Blur my Shell](https://extensions.gnome.org/extension/3193/blur-my-shell/)

```bash
cd /usr/share/glib-2.0/schemas
sudo wget "https://raw.githubusercontent.com/aunetx/blur-my-shell/master/schemas/org.gnome.shell.extensions.blur-my-shell.gschema.xml"
sudo glib-compile-schemas .

gnome-shell-extension-installer --yes 3193
```

- [Dash-to-Dock](https://extensions.gnome.org/extension/307/dash-to-dock/)

```bash
cd /usr/share/glib-2.0/schemas
sudo wget "https://raw.githubusercontent.com/micheleg/dash-to-dock/master/schemas/org.gnome.shell.extensions.dash-to-dock.gschema.xml"
sudo glib-compile-schemas .

gnome-shell-extension-installer --yes 307
```

- [Hide Top Bar](https://extensions.gnome.org/extension/545/hide-top-bar/)

```bash
cd /usr/share/glib-2.0/schemas
sudo wget "https://raw.githubusercontent.com/tuxor1337/hidetopbar/master/schemas/org.gnome.shell.extensions.hidetopbar.gschema.xml"
sudo glib-compile-schemas .

gnome-shell-extension-installer --yes 545
```

- [Tray Icons: Reloaded](https://extensions.gnome.org/extension/2890/tray-icons-reloaded/)

```bash
cd /usr/share/glib-2.0/schemas
sudo wget "https://raw.githubusercontent.com/MartinPL/Tray-Icons-Reloaded/master/schemas/org.gnome.shell.extensions.trayIconsReloaded.gschema.xml"
sudo glib-compile-schemas .

gnome-shell-extension-installer --yes 2890
```

- [User Themes](https://extensions.gnome.org/extension/19/user-themes/)

```bash
cd /usr/share/glib-2.0/schemas
sudo wget "https://gitlab.gnome.org/GNOME/gnome-shell-extensions/-/raw/main/extensions/user-theme/org.gnome.shell.extensions.user-theme.gschema.xml"
sudo glib-compile-schemas .

gnome-shell-extension-installer --yes 19
```

<div align="center">

  | :warning: A reboot is required for this section |
  | ----------------------------------------------- |
  | `sudo reboot`                                   |

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

**[:arrow_up: Back to Top](#0-details)**

## 5. Terminal Theme

Install [zsh](https://www.zsh.org/) and [Oh My Zsh](https://ohmyz.sh/):

```bash
sudo dnf install --assumeyes \
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

Install the [Monokai terminal theme](https://github.com/0xcomposure/monokai-gnome-terminal):

```bash
sudo dnf install --assumeyes dconf

mkdir --parents ~/.themes/_sources/Monokai
cd ~/.themes/_sources/Monokai

git clone "https://github.com/0xComposure/monokai-gnome-terminal" terminal
cd terminal

echo "1\nYES\n" | ./install.sh
```

**[:arrow_up: Back to Top](#0-details)**

## 6. Applications

Install the following applications:

> Giving Flatpak applications access to the $HOME folder applies the custom GTK theme on them, even with sandboxing enabled.
> Giving access to the GPU `device=dri` enables hardware-acceleration when possible (which might be more hazardous, depending on the application itself).
> These applications are from trusted sources, as possible.

- [Bleachbit](https://www.bleachbit.org/)

```bash
sudo dnf install --assumeyes bleachbit
```

- [Discord](https://discord.com/)

```bash
flatpak install --assumeyes --user flathub com.discordapp.Discord
sudo flatpak override --user --device=dri com.discordapp.Discord
```

- [Flatseal](https://github.com/tchx84/Flatseal)

```bash
flatpak install --assumeyes --user flathub com.github.tchx84.Flatseal
sudo flatpak override --user --device=dri com.github.tchx84.Flatseal
```

- [Mozilla Firefox](https://www.mozilla.org/en-US/firefox/new/)

> Replacing the pre-installed RPM with its Flatpak variant for better system consistency:

```bash
sudo killall firefox
rm --force --recursive --verbose ~/.mozilla

flatpak install --assumeyes --user flathub org.mozilla.firefox
sudo flatpak override --user --device=dri org.mozilla.firefox
```

- [ONLYOFFICE](https://www.onlyoffice.com/s)

```bash
flatpak install --assumeyes --user flathub org.onlyoffice.desktopeditors
sudo flatpak override --user --device=dri org.onlyoffice.desktopeditors
```

- [Visual Studio Codium](https://vscodium.com/)

> Codium (or VSCodium) is the full open-source variant of Microsoft's Visual Studio Code.
> Using the RPM variant instead of the Flatpak one for better system & terminal integration.

```bash
sudo rpm --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
printf "[gitlab.com_paulcarroty_vscodium_repo]\nname=download.vscodium.com\nbaseurl=https://download.vscodium.com/rpms/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg\nmetadata_expire=1h" | sudo tee --append /etc/yum.repos.d/vscodium.repo
sudo dnf install --assumeyes codium
```

- [VLC](https://www.videolan.org/)

```bash
flatpak install --assumeyes --user flathub org.videolan.VLC
sudo flatpak override --user --device=dri org.videolan.VLC
```

**[:arrow_up: Back to Top](#0-details)**

## 7. Gaming

Install the required 32-bit libraries, as prerequisites:

```bash
sudo dnf install --assumeyes \
    freetype.i686 \
    gnutls.i686 \
    libgpg-error.i686 \
    openldap.i686 \
    pulseaudio-libs.i686 \
    sqlite2.i686 \
    vulkan-loader.i686
```

Then, install the following:

- [Lutris](https://lutris.net/)

```bash
flatpak install --assumeyes --user flathub net.lutris.Lutris
sudo flatpak override --user --device=dri net.lutris.Lutris
```

- [Steam](https://store.steampowered.com/)

```bash
flatpak install --assumeyes --user flathub com.valvesoftware.Steam
sudo flatpak override --user --device=dri com.valvesoftware.Steam
```

> For other clients like the Epic Games Store and GOG, check out the [Heroic Game Launcher](https://heroicgameslauncher.com/).

**[:arrow_up: Back to Top](#0-details)**

## 8. Cleanup

Finish the installation by removing these unneeded applications:

> This section is truly optional, and more personal.

```bash
sudo dnf remove --assumeyes \
    $(rpm --query --all | grep --ignore-case libreoffice) \
    cheese \
    evince \
    gedit \
    gnome-boxes \
    gnome-camera \
    gnome-characters \
    gnome-clocks \
    gnome-connections \
    gnome-contacts \
    gnome-maps \
    gnome-text-editor \
    gnome-tour \
    gnome-weather \
    liveusb-creator \
    rhythmbox \
    totem \
    yelp
```

**[:arrow_up: Back to Top](#0-details)**
