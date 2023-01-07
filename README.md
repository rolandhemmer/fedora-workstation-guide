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

*Installation guide and **personal** post-installation steps.  
The purpose of this document is to provide a clean, minimalist, secure, gaming-ready, Fedora setup.*

*Scripts are provided for your convenience, but all of them are open and -I hope- legible enough for you to update them at will.  
I've also added comments for more complex parts, and to offer variants.*

*Hope you enjoy this guide.*

*- R.*

---

## 📖 Table of Contents

- [Fedora Workstation Installation Guide](#fedora-workstation-installation-guide)
  - [📖 Table of Contents](#-table-of-contents)
  - [⏩ Quick Start](#-quick-start)
    - [1.1. Requirements](#11-requirements)
    - [1.2. Available Scripts](#12-available-scripts)
      - [1.2.1. Base Setup](#121-base-setup)
      - [1.2.2. Nvidia Drivers](#122-nvidia-drivers)
      - [1.2.3. Environment](#123-environment)
      - [1.2.4. Theme](#124-theme)
  - [🔃 Automation](#-automation)
  - [📖 License](#-license)
  - [🤝 Thanks](#-thanks)

## ⏩ Quick Start

### 1.1. Requirements

- a basic Fedora installation (Workstation Edition, with GNOME)

Highly recommended (but still **not** mandatory):

- an UEFI platform (the more up-to-date, the better)
- a TPM 2.0 chip
- Secure Boot enabled
- LUKS encryption enabled on all drives

These scripts are better run right after a fresh Fedora installation.  
On the very first reboot, after creating your account:

- disable `Location Services`
- disable `Automatic Problem Reporting`
- enable `Third-Party Repositories`

### 1.2. Available Scripts

Then, use the following scripts, in the following order.  
⚠️ Please **reboot** when asked.

#### 1.2.1. Base Setup

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
curl --location https://raw.githubusercontent.com/rolandhemmer/fedora-workstation-guide/main/scripts/00-setup-base.sh | bash
# ✅ Reboot when asked

curl --location https://raw.githubusercontent.com/rolandhemmer/fedora-workstation-guide/main/scripts/01-setup-harden.sh | bash
# ✅ Reboot when asked
```

#### 1.2.2. Nvidia Drivers

If you have an Nvidia GPU, run:

```bash
curl --location https://raw.githubusercontent.com/rolandhemmer/fedora-workstation-guide/main/scripts/02-setup-nvidia.sh | bash
# ✅ Reboot when asked
```

⚠️ A password will be asked during this step. This will allow the load of the Nvidia drivers and kernel modules even with Secure Boot enabled.  
At reboot, choose `Enroll MOK`, `Continue`, `Yes`, and enter the selected password. Reboot when done.

#### 1.2.3. Environment

Finish the basic installation with:

```bash
curl --location https://raw.githubusercontent.com/rolandhemmer/fedora-workstation-guide/main/scripts/03-setup-codecs.sh | bash

curl --location https://raw.githubusercontent.com/rolandhemmer/fedora-workstation-guide/main/scripts/04-setup-applications.sh | bash
```

#### 1.2.4. Theme

If you want to include a minimalist, flat, macOS-like GNOME theme, run:

```bash
flatpak install --assumeyes --user flathub com.mattjakeman.ExtensionManager
```

Then, open the GNOME Extension Manager, and install the following extensions:

- Alphabetical App Grid
- Blur my Shell
- Dash to Dock
- Hide Top Bar
- User Themes

Then, run:

```bash
curl --location https://raw.githubusercontent.com/rolandhemmer/fedora-workstation-guide/main/scripts/05-setup-theme.sh | bash
```

## 🔃 Automation

A script is provided to simplify all update chores (RPM, Flatpaks, firmware, etc.), and/or refresh the GNOME theme as well if needed.  
Use the following command to add it to your installation:

```bash
sudo curl --location https://raw.githubusercontent.com/rolandhemmer/fedora-workstation-guide/main/scripts/update.sh --output /usr/bin/update
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

## 📖 License

This guide is published under the MIT license.  
See the [LICENSE.md](LICENSE.md) file for the full license text.

Per this license, the use of the software and scripts downloaded from this repository is done **at your own discretion and risk**.

Fedora and the Fedora logo are trademarks or registered trademarks of [Red Hat, Inc](https://www.redhat.com/en).  
All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.

## 🤝 Thanks

This humble guide is merely a compilation of what's existing out here already.  
I did spent **A LOT** of time searching, experimenting and formatting my poor PC to test all of this.

Alongside my own time, here's a list of the resources I used.

I would like to take a minute and warmly thank their respective authors for their work and their ideas, which helped bring this guide to life.

- [@Andrei Nevedomskii](https://github.com/monosoul) and his [Nvidia Kernel Module Installation Guide](https://blog.monosoul.dev/2021/12/29/automatically-sign-nvidia-kernel-module-in-fedora/)
- [@GloriousEggroll](https://github.com/GloriousEggroll) and his [Nobara Project](https://nobaraproject.org/)
- [@Madaidans-Insecurities](https://github.com/madaidans-insecurities) and his [Linux Hardening Guide](https://madaidans-insecurities.github.io/guides/linux-hardening.html)
- [The Linux Foundation IT](https://github.com/lfit) and its [Linux workstation security checklist](https://github.com/lfit/itpol/blob/master/linux-workstation-security.md)
- The RPM Fusion team, and their [Nvidia Guide](https://rpmfusion.org/RPM%20Fusion)
- [@Vinceliuice](https://github.com/vinceliuice) for the Colloid [GTK](https://github.com/vinceliuice/Colloid-gtk-theme) and [icon & cursor](https://github.com/vinceliuice/Colloid-icon-theme) themes
- (probably more I forgot...)

and of course the Fedora Team for such an amazing Linux distribution!
