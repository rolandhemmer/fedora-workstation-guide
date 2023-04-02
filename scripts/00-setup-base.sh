#!/bin/bash

source common.sh

# ################################################################
# Main
# ################################################################

trap 'handle_errors $LINENO "$BASH_COMMAND"' ERR
sudo echo -e "[ Fedora Workstation Installation Script ]\n"

# ----------------------------------------------------------------

# Configuring shell settings
log_step "Configuring shell settings"

export HISTFILESIZE=999999
export HISTSIZE=999999
export HISTTIMEFORMAT="%F %T "

export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

mkdir $HOME/Workspace >$OUTPUT_EMPTY 2>&1 || true
mkdir $HOME/.local/bin >$OUTPUT_EMPTY 2>&1 || true

# ----------------------------------------------------------------

# Configuring Git settings
log_step "Configuring Git settings"

sudo tee $HOME/.gitconfig >$OUTPUT_EMPTY 2>&1 <<EOT
[commit]
gpgsign = true
[core]
autocrlf = input
editor = vim
eol = lf
[diff]
colormoved = zebra
[fetch]
prune = true
[http]
maxrequestbuffer = 128M
postbuffer = 512M
[pull]
rebase = true
[submodule]
recurse = true
EOT

# ----------------------------------------------------------------

# Configuring DNF settings
log_step "Configuring DNF settings"

sudo tee /etc/dnf/dnf.conf >$OUTPUT_EMPTY 2>&1 <<EOT
[main]
best=True
gpgcheck=1
max_parallel_downloads=20
skip_if_unavailable=True
EOT

# Details:
#   - `best=True`: instructs the solver to either use a package with the highest available version or fail.
#   - `gpgcheck=1`: performs GPG signature check on packages found in this repository.
#   - `max_parallel_downloads=20`: sets the maximum number of simultaneous package downloads.
#   - `skip_if_unavailable=True`: on error, disables the repository that couldn’t be synchronized for any reason, and continues running.
#
# All other values are at their respective default level.
# See https://dnf.readthedocs.io/en/latest/conf_ref.html for more.

# ----------------------------------------------------------------

# Configuring privacy settings
log_step "Configuring privacy settings"

gsettings set org.gnome.desktop.privacy report-technical-problems false

sudo systemctl disable \
    abrt-journal-core \
    abrt-oops \
    abrt-xorg \
    abrtd >$OUTPUT_EMPTY 2>&1

# ----------------------------------------------------------------

# Enabling the Fedora RPM Fusion repositories
log_step "Enabling the Fedora RPM Fusion repositories"

dnf_package_install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm --eval %fedora).noarch.rpm
dnf_package_install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm --eval %fedora).noarch.rpm

dnf_package_install \
    dnf-plugins-core \
    fedora-repos \
    fedora-workstation-repositories \
    rpmfusion-free-appstream-data \
    rpmfusion-free-release \
    rpmfusion-free-release-tainted \
    rpmfusion-nonfree-appstream-data \
    rpmfusion-nonfree-release \
    rpmfusion-nonfree-release-tainted

dnf_group_update \
    core \
    --with-optional

# ----------------------------------------------------------------

# Updating and cleaning system packages
log_step "Updating and cleaning system packages"

sudo dnf clean --assumeyes --quiet all >$OUTPUT_EMPTY 2>&1
sudo dnf upgrade --assumeyes --quiet --refresh >$OUTPUT_EMPTY 2>&1

dnf_package_install \
    curl \
    git \
    vim \
    wget

# ----------------------------------------------------------------

# Updating system drivers
log_step "Updating system drivers"

dnf_group_install \
    hardware-support \
    networkmanager-submodules \
    printing \
    --with-optional

dnf_package_install \
    \*-firmware \
    --exclude=*nvidia*

dnf_package_install \
    foomatic \
    fwupd \
    hplip \
    numactl \
    sane-backends-libs

sudo fwupdmgr --assume-yes --force refresh >$OUTPUT_EMPTY 2>&1 || true
sudo fwupdmgr --assume-yes --force get-updates >$OUTPUT_EMPTY 2>&1 || true

# ----------------------------------------------------------------

# Enabling Flatpak repositories
log_step "Enabling Flatpak repositories"

flatpak remote-add --if-not-exists --user fedora oci+https://registry.fedoraproject.org
flatpak remote-add --if-not-exists --user flathub https://flathub.org/repo/flathub.flatpakrepo

# ----------------------------------------------------------------

# Updating and cleaning system applications
log_step "Updating and cleaning system applications"

sudo flatpak update --system --assumeyes >$OUTPUT_EMPTY 2>&1
sudo flatpak uninstall --system --assumeyes --unused >$OUTPUT_EMPTY 2>&1

# ----------------------------------------------------------------

# Updating and cleaning user applications
log_step "Updating and cleaning user applications"

flatpak update --user --assumeyes >$OUTPUT_EMPTY 2>&1
flatpak uninstall --user --assumeyes --unused >$OUTPUT_EMPTY 2>&1

flatpak override --user --reset
flatpak override --user --device=dri

# ################################################################
# End
# ################################################################

log_success
ask_reboot
