<div align="center">
  <br>
  <br>
  <br>
  <br>
  <img src="images/fedora-logo.png" alt="Fedora" width="450"/>
  <br>
  <br>
  <br>
  <br>
</div>

# Fedora Workstation Installation Guide

> *Installation guide and **personal** post-installation steps.*  
> *The purpose of this document is to provide a clean, minimalist, secure, gaming-ready, Fedora setup.*
>
> *Scripts are provided for your convenience, but all of them are open and -I hope- legible enough for you to update them at will.*  
> *I've also added comments for the more complex parts, and to offer variants.*
> *Hope you enjoy this guide.*  
>
> *- R.*

## 📖 Table of Contents

- [Fedora Workstation Installation Guide](#fedora-workstation-installation-guide)
  - [📖 Table of Contents](#-table-of-contents)
  - [⏩ Quick Start](#-quick-start)
    - [1.1. Requirements](#11-requirements)
    - [1.2. Available Scripts](#12-available-scripts)
      - [1.2.1. Base Installation](#121-base-installation)
      - [1.2.2. Nvidia Drivers Installation](#122-nvidia-drivers-installation)
      - [1.2.3. Desktop Environment Configuration](#123-desktop-environment-configuration)
      - [1.2.4. Desktop Theme Configuration](#124-desktop-theme-configuration)
    - [1.3. Tweaks](#13-tweaks)
      - [1.3.1. Nvidia Hardware-Acceleration for Mozilla Firefox](#131-nvidia-hardware-acceleration-for-mozilla-firefox)
  - [🔃 Automation](#-automation)
  - [📖 License](#-license)
  - [🤝 Thanks](#-thanks)

## ⏩ Quick Start

### 1.1. Requirements

- basic Fedora installation (Workstation Edition, with GNOME)
- Secure Boot enabled

Highly recommended (but still **not** mandatory):

- TPM 2.0 enabled
- LUKS encryption enabled on all drives

These scripts are better run right after a fresh Fedora installation.  
On the very first reboot, after creating your account:

- disable `Location Services`
- disable `Automatic Problem Reporting`
- enable `Third-Party Repositories`

<div dir='rtl'>
  <a href="#-table-of-contents">⬆️ back to top</a>
</div>

### 1.2. Available Scripts

Then, use the following scripts, in the following order.  
⚠️ Please **reboot** when asked.

#### 1.2.1. Base Installation

First, name your new system:

```bash
# "Pretty" name of the system, without restrictions
# (e.g: "System Name 01")
sudo hostnamectl set-hostname --pretty $pretty_hostname

# Static name of the system, containing only lowercase letters, numbers and/or dashes
# (e.g: "system-name-01")
sudo hostnamectl set-hostname --static $static_hostname
```

Then, run:

```bash
bash -c "$(curl --silent --location https://raw.githubusercontent.com/rolandhemmer/fedora-workstation-guide/main/scripts/00-setup-base.sh)"
# ➡️ Reboot when asked

bash -c "$(curl --silent --location https://raw.githubusercontent.com/rolandhemmer/fedora-workstation-guide/main/scripts/01-setup-hardening.sh)"
# ➡️ Reboot when asked
```

<div dir='rtl'>
  <a href="#-table-of-contents">⬆️ back to top</a>
</div>

#### 1.2.2. Nvidia Drivers Installation

If you have an Nvidia GPU, run:

```bash
bash -c "$(curl --silent --location https://raw.githubusercontent.com/rolandhemmer/fedora-workstation-guide/main/scripts/02-setup-nvidia.sh)"
# ➡️ Reboot when asked
```

⚠️ A password will be asked during this step. This will allow the load of the Nvidia drivers and kernel modules even with Secure Boot enabled.  
At reboot, choose `Enroll MOK`, `Continue`, `Yes`, and enter the selected password. Reboot when done.

<div dir='rtl'>
  <a href="#-table-of-contents">⬆️ back to top</a>
</div>

#### 1.2.3. Desktop Environment Configuration

Finish the basic installation with:

```bash
bash -c "$(curl --silent --location https://raw.githubusercontent.com/rolandhemmer/fedora-workstation-guide/main/scripts/03-setup-codecs.sh)"
# ✅ No reboot needed

bash -c "$(curl --silent --location https://raw.githubusercontent.com/rolandhemmer/fedora-workstation-guide/main/scripts/04-setup-applications.sh)"
# ✅ No reboot needed
```

<div dir='rtl'>
  <a href="#-table-of-contents">⬆️ back to top</a>
</div>

#### 1.2.4. Desktop Theme Configuration

If you want to include a minimalist, flat, macOS-like GNOME theme, run:

```bash
flatpak install --assumeyes --user flathub com.mattjakeman.ExtensionManager
```

Then, open the GNOME Extension Manager, and install the following extensions:

- Alphabetical App Grid
- AppIndicator and KStatusNotifierItem Support
- Blur my Shell
- Dash to Dock
- Hide Top Bar
- User Themes

Then, run:

```bash
bash -c "$(curl --silent --location https://raw.githubusercontent.com/rolandhemmer/fedora-workstation-guide/main/scripts/05-setup-theme.sh)"
# ✅ No reboot needed
```

<div dir='rtl'>
  <a href="#-table-of-contents">⬆️ back to top</a>
</div>

### 1.3. Tweaks

Some additional configurations you can apply, depending on your hardware, **after** all the provided installation scripts.

#### 1.3.1. Nvidia Hardware-Acceleration for Mozilla Firefox

If you have an Nvidia GPU and Mozilla Firefox installed as a Flatpak (as the current guide would suggest), use the following to finish configuring the browser to properly use hardware-acceleration:

```bash
flatpak override --user --env="EGL_PLATFORM=wayland" --env="LIBVA_DRIVER_NAME=nvidia" --env="MOZ_LOG=PlatformDecoderModule:5" org.mozilla.firefox
```

Once done, open the `about:config` page in Mozilla Firefox, and change the following parameters:

| Key                          | Value                                                           |
| ---------------------------- | --------------------------------------------------------------- |
| `gfx.x11-egl.force-enabled`  | `true`                                                          |
| `media.av1.enabled`          | `true` if you have an RTX series 30 or newer, `false` otherwise |
| `media.ffmpeg.vaapi.enabled` | `true`                                                          |
| `media.rdd-ffmpeg.enabled`   | `true`                                                          |

<div dir='rtl'>
  <a href="#-table-of-contents">⬆️ back to top</a>
</div>

## 🔃 Automation

A script is provided to simplify all update chores (RPM, Flatpaks, firmware, etc.), and/or refresh the GNOME theme as well if needed.  
Use the following command to add it to your installation:

```bash
sudo curl --silent --location https://raw.githubusercontent.com/rolandhemmer/fedora-workstation-guide/main/scripts/update.sh --output /usr/bin/update
sudo chmod +x /usr/bin/update
```

Once set up, run:

```bash
update --system
# to refresh RPM packages, Flatpaks and firmware

update --theme
# to refresh the GNOME theme as configured in this guide

update --all
# to do both
```

I recommend [setting up a CRON job](https://fedoramagazine.org/scheduling-tasks-with-cron/) calling this script to keep your system updated without effort.

<div dir='rtl'>
  <a href="#-table-of-contents">⬆️ back to top</a>
</div>

## 📖 License

This guide is published under the MIT license.  
See the [LICENSE.md](LICENSE.md) file for the full license text.

Per this license, the use of the software and scripts downloaded from this repository is done **at your own discretion and risk**.

Fedora and the Fedora logo are trademarks or registered trademarks of [Red Hat, Inc](https://www.redhat.com/en).  
All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.

<div dir='rtl'>
  <a href="#-table-of-contents">⬆️ back to top</a>
</div>

## 🤝 Thanks

This humble guide is merely a compilation of what's existing out here already.  
I did spent **A LOT** of time searching, experimenting and formatting my poor PC to test all of this.

I would like to take a minute and warmly thank the following authors for their work and ideas, which greatly helped bring this guide to life.

- [@Andrei Nevedomskii](https://github.com/monosoul) and his [Nvidia Kernel Module Installation Guide](https://blog.monosoul.dev/2022/05/17/automatically-sign-nvidia-kernel-module-in-fedora-36/)
- [@Madaidans Insecurities](https://github.com/madaidans-insecurities) and its [Linux Hardening Guide](https://madaidans-insecurities.github.io/guides/linux-hardening.html)
- [@Stephen](https://github.com/elFarto) and his [Nvidia VA-API driver](https://github.com/elFarto/nvidia-vaapi-driver)
- [@Thomas Crider](https://github.com/GloriousEggroll) and his [Nobara Project](https://nobaraproject.org/)
- [@Vince](https://github.com/vinceliuice) for the Colloid [GTK](https://github.com/vinceliuice/Colloid-gtk-theme) and [icon & cursor](https://github.com/vinceliuice/Colloid-icon-theme) themes
- [The Linux Foundation IT](https://github.com/lfit) and its [Linux workstation security checklist](https://github.com/lfit/itpol/blob/master/linux-workstation-security.md)
- The RPM Fusion team, and their [Nvidia Guide](https://rpmfusion.org/Howto/NVIDIA)
- (probably more I forgot...)

and of course the Fedora Team for such an amazing Linux distribution!

<div dir='rtl'>
  <a href="#-table-of-contents">⬆️ back to top</a>
</div>
