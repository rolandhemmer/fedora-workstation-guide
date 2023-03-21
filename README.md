<div align="center">
  <br>
  <img src="docs/fedora-logo.png" alt="Fedora" width="275"/>
  <br>
  <br>
</div>

<div align="center">

Installation guide and **personal** post-installation steps.  
The purpose of this document is to provide a clean, minimalist, secure, gaming-ready, Fedora setup.

These scripts, while trivially editable and configurable, are built from a **personal** point-of-view, and may not suit all use-cases or preferences.

<br>
<br>
<br>
</div>

## 📖 Table of Contents

- [📖 Table of Contents](#-table-of-contents)
- [🚀 Quick Start](#-quick-start)
  - [1.1. Requirements](#11-requirements)
  - [1.2. Available Scripts](#12-available-scripts)
    - [1.2.1. Base Installation](#121-base-installation)
    - [1.2.2. Nvidia Drivers Installation](#122-nvidia-drivers-installation)
    - [1.2.3. Desktop Environment Configuration](#123-desktop-environment-configuration)
    - [1.2.4. Desktop Theme Configuration](#124-desktop-theme-configuration)
- [🔃 Automation](#-automation)
- [🎓 License](#-license)
- [🤝 Thanks](#-thanks)

## 🚀 Quick Start

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
./scripts/00-setup-base.sh
# ➡️ Reboot when asked

./scripts/01-setup-hardening.sh
# ➡️ Reboot when asked
```

<div dir='rtl'>
  <a href="#-table-of-contents">⬆️ back to top</a>
</div>

#### 1.2.2. Nvidia Drivers Installation

If you have an Nvidia GPU, run:

```bash
./scripts/02-setup-nvidia.sh
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
./scripts/03-setup-codecs.sh
# ✅ No reboot needed

./scripts/04-setup-applications.sh
# ✅ No reboot needed
```

<div dir='rtl'>
  <a href="#-table-of-contents">⬆️ back to top</a>
</div>

#### 1.2.4. Desktop Theme Configuration

To include a minimalist, flat, and consistent GNOME theme, run:

```bash
flatpak install --assumeyes --user flathub com.mattjakeman.ExtensionManager
```

Then, open `Extension Manager`, and install the following extensions:

- Alphabetical App Grid
- AppIndicator and KStatusNotifierItem Support
- Dash to Dock
- User Themes

Then, run:

```bash
./scripts/05-setup-theme.sh
# ✅ No reboot needed
```

<div dir='rtl'>
  <a href="#-table-of-contents">⬆️ back to top</a>
</div>

## 🔃 Automation

A script is provided to simplify all update chores (RPM, Flatpaks, firmware, etc.), and/or refresh the GNOME theme as well if needed.  
Use the following command to install it:

```bash
sudo cp ./scripts/update.sh /usr/bin/update
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

[Setting up a CRON job](https://fedoramagazine.org/scheduling-tasks-with-cron/) calling this script is recommended, to keep your system updated without effort.

<div dir='rtl'>
  <a href="#-table-of-contents">⬆️ back to top</a>
</div>

## 🎓 License

This guide is published under the MIT license.  
See the [LICENSE.md](LICENSE.md) file for the full license text.

Per this license, the use of the software and scripts downloaded from this repository is done **at your own discretion and risk**.  
All logos, trademarks, and copyrights are property of their respective owners and are only mentioned for informative purposes.

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
- [The Linux Foundation IT](https://github.com/lfit) and its [Linux workstation security checklist](https://github.com/lfit/itpol/blob/master/linux-workstation-security.md)
- The RPM Fusion team and their [Nvidia Guide](https://rpmfusion.org/Howto/NVIDIA)
- (probably more I forgot...)

and of course the Fedora Team for such an amazing Linux distribution!

<div dir='rtl'>
  <a href="#-table-of-contents">⬆️ back to top</a>
</div>
