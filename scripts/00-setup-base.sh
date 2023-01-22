#!/bin/bash

# ################################################################
# FORMATTING
# ################################################################

export ECHO_BOLD="\033[1m"
export ECHO_GREEN="\033[1;32m"
export ECHO_RED="\033[1;31m"
export ECHO_REPLACE="\033[1A\033[K"
export ECHO_RESET="\033[0m"

export NO_OUTPUT="/dev/null"

handle_errors() {
    echo -e "\n[ ${ECHO_RED}KO${ECHO_RESET} ] Script failed on line $1"
    exit 1
}

log_progress() {
    echo -e "[ .. ]\t$1"
}

log_success() {
    echo -e "${ECHO_REPLACE}[ ${ECHO_GREEN}OK${ECHO_RESET} ]\t$1"
}

# ################################################################
# BASE METHODS
# ################################################################

ask_reboot() {
    while true; do
        echo -e "\nA reboot is required to continue. Do you wish to reboot now? [Y/N]"
        read yn
        case $yn in
        [Yy]*)
            sudo reboot now
            break
            ;;
        [Nn]*) exit ;;
        *) echo "Please answer yes or no." ;;
        esac
    done
}

dnf_group_install() {
    sudo dnf group install --assumeyes --quiet $@ >$NO_OUTPUT 2>&1
}

dnf_group_update() {
    sudo dnf group update --assumeyes --quiet $@ >$NO_OUTPUT 2>&1
}

dnf_package_install() {
    sudo dnf install --assumeyes --quiet $@ >$NO_OUTPUT 2>&1
}

flatpak_install() {
    flatpak install --assumeyes --user flathub $@ >$NO_OUTPUT 2>&1
}

# ################################################################
# MAIN
# ################################################################

trap 'handle_errors $LINENO' ERR
sudo echo ""

cat <<"EOT"
    ________________  ____  ____  ___       _____ ______________  ______
   / ____/ ____/ __ \/ __ \/ __ \/   |     / ___// ____/_  __/ / / / __ \
  / /_  / __/ / / / / / / / /_/ / /| |     \__ \/ __/   / / / / / / /_/ /
 / __/ / /___/ /_/ / /_/ / _, _/ ___ |    ___/ / /___  / / / /_/ / ____/
/_/   /_____/_____/\____/_/ |_/_/  |_|   /____/_____/ /_/  \____/_/

EOT

# ----------------------------------------------------------------
# Configuring Git settings
# ----------------------------------------------------------------

log_progress "Configuring Git settings"

sudo tee ~/.gitconfig >$NO_OUTPUT 2>&1 <<EOT
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

log_success "Configuring Git settings"

# ----------------------------------------------------------------
# Configuring DNF settings
# ----------------------------------------------------------------

log_progress "Configuring DNF settings"

sudo tee /etc/dnf/dnf.conf >$NO_OUTPUT 2>&1 <<EOT
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

log_success "Configuring DNF settings"

# ----------------------------------------------------------------
# Configuring privacy settings
# ----------------------------------------------------------------

log_progress "Configuring privacy settings"

gsettings set org.gnome.desktop.privacy report-technical-problems false

sudo systemctl disable \
    abrt-journal-core \
    abrt-oops \
    abrt-xorg \
    abrtd >$NO_OUTPUT 2>&1

log_success "Configuring privacy settings"

# ----------------------------------------------------------------
# Enabling the Fedora RPM Fusion repositories
# ----------------------------------------------------------------

log_progress "Enabling the Fedora RPM Fusion repositories"

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

dnf_group_update core

log_success "Enabling the Fedora RPM Fusion repositories"

# ----------------------------------------------------------------
# Updating and cleaning system packages
# ----------------------------------------------------------------

log_progress "Updating and cleaning system packages"

sudo dnf clean --assumeyes --quiet all >$NO_OUTPUT 2>&1
sudo dnf upgrade --assumeyes --quiet --refresh >$NO_OUTPUT 2>&1

dnf_package_install \
    htop \
    neofetch

log_success "Updating and cleaning system packages"

# ----------------------------------------------------------------
# Enabling Flatpak repositories
# ----------------------------------------------------------------

log_progress "Enabling Flatpak repositories"

flatpak remote-add --if-not-exists --user fedora oci+https://registry.fedoraproject.org
flatpak remote-add --if-not-exists --user flathub https://flathub.org/repo/flathub.flatpakrepo

log_success "Enabling Flatpak repositories"

# ----------------------------------------------------------------
# Updating and cleaning system applications
# ----------------------------------------------------------------

log_progress "Updating and cleaning system applications"

sudo flatpak update --system --assumeyes >$NO_OUTPUT 2>&1
sudo flatpak uninstall --system --assumeyes --unused >$NO_OUTPUT 2>&1

log_success "Updating and cleaning system applications"

# ----------------------------------------------------------------
# Updating and cleaning user applications
# ----------------------------------------------------------------

log_progress "Updating and cleaning user applications"

flatpak update --user --assumeyes >$NO_OUTPUT 2>&1
flatpak uninstall --user --assumeyes --unused >$NO_OUTPUT 2>&1

flatpak override --user --reset
flatpak override --user --device=dri

log_success "Updating and cleaning user applications"

# ----------------------------------------------------------------
# Updating system drivers
# ----------------------------------------------------------------

log_progress "Updating system drivers"

dnf_group_install \
    hardware-support \
    networkmanager-submodules \
    printing

dnf_package_install \
    \*-firmware \
    foomatic \
    fwupd \
    hplip \
    numactl \
    sane-backends-libs

# The 'fwupdmgr' command exits with '1' (as failure) when no update is needed.
sudo fwupdmgr --assume-yes --force refresh >$NO_OUTPUT 2>&1 || true
sudo fwupdmgr --assume-yes --force get-updates >$NO_OUTPUT 2>&1 || true

log_success "Updating system drivers"

# ################################################################
# REBOOT
# ################################################################

echo -e "\n[ ${ECHO_BOLD}OK${ECHO_RESET} ]"

ask_reboot
