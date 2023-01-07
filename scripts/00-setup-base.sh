#!/bin/bash

# ################################################################
# FUNCTIONS
# ################################################################

export ECHO_BOLD="\033[1m"
export ECHO_GREEN="\033[1;32m"
export ECHO_GREY="\033[0;37m"
export ECHO_RED="\033[1;31m"
export ECHO_RESET="\033[0m"
export ECHO_REPLACE="\033[1A\033[K"

export NO_OUTPUT="/dev/null"

ask_reboot() {
    while true; do
        echo -e "\nA reboot is required to continue. Do you wish to reboot now?"
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

flatpak_install() {
    flatpak install --assumeyes --user flathub $@ >$NO_OUTPUT 2>&1
}

dnf_group_install() {
    sudo dnf group install --allowerasing --assumeyes --best --quiet $@ >$NO_OUTPUT 2>&1
}

dnf_group_update() {
    sudo dnf group update allowerasing --assumeyes --best --quiet --with-optional $@ >$NO_OUTPUT 2>&1
}

dnf_package_install() {
    sudo dnf install --allowerasing --assumeyes --best --quiet $@ >$NO_OUTPUT 2>&1
}

dnf_package_remove() {
    sudo dnf remove --assumeyes --quiet $@ >$NO_OUTPUT 2>&1
}

log_progress() {
    echo -e "[ .. ]\t$1"
}

log_success() {
    echo -e "${ECHO_REPLACE}[ ${ECHO_GREEN}OK${ECHO_RESET} ]\t$1"
}

log_success_alt() {
    echo -e "[ ${ECHO_GREEN}OK${ECHO_RESET} ]\t$1"
}

log_title() {
    echo -e "${ECHO_BOLD}$1${ECHO_RESET}"
}

# ################################################################
# SETUP
# ################################################################

set -e
sudo echo ""

cat <<"EOT"
    ________________  ____  ____  ___       _____ ______________  ______
   / ____/ ____/ __ \/ __ \/ __ \/   |     / ___// ____/_  __/ / / / __ \
  / /_  / __/ / / / / / / / /_/ / /| |     \__ \/ __/   / / / / / / /_/ /
 / __/ / /___/ /_/ / /_/ / _, _/ ___ |    ___/ / /___  / / / /_/ / ____/
/_/   /_____/_____/\____/_/ |_/_/  |_|   /____/_____/ /_/  \____/_/

EOT

log_title "\n==> Configuring system base"

# ----------------------------------------------------------------
# Configuring Git settings
# ----------------------------------------------------------------

log_progress "Configuring Git settings"

git config --global commit.gpgsign true
git config --global core.autocrlf input
git config --global core.editor vim
git config --global core.eol lf
git config --global diff.colormoved zebra
git config --global fetch.prune true
git config --global http.maxrequestbuffer 128M
git config --global http.postbuffer 512M
git config --global pull.rebase true
git config --global submodule.recurse true

log_success "Configuring Git settings"

# ----------------------------------------------------------------
# Updating DNF settings
# ----------------------------------------------------------------

log_progress "Updating DNF settings"

sudo tee --append /etc/dnf/dnf.conf >$NO_OUTPUT 2>&1 <<EOT
deltarpm=true
fastestmirror=1
max_parallel_downloads=20
EOT

log_success "Updating DNF settings"

# ----------------------------------------------------------------
# Updating GNOME Software settings
# ----------------------------------------------------------------

log_progress "Updating GNOME Software settings"

sudo tee --append /usr/share/gnome-shell/search-providers/org.gnome.Software-search-provider.ini >$NO_OUTPUT 2>&1 <<EOT
DefaultDisabled=true
EOT

log_success "Updating GNOME Software settings"

# ----------------------------------------------------------------
# Enabling the Fedora RPM Fusion repositories
# ----------------------------------------------------------------

log_progress "Enabling the Fedora RPM Fusion repositories"

dnf_package_install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm --eval %fedora).noarch.rpm
dnf_package_install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm --eval %fedora).noarch.rpm

dnf_package_install \
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
# Performing a full system upgrade
# ----------------------------------------------------------------

log_progress "Performing a full system upgrade"

sudo dnf clean --assumeyes --quiet all >$NO_OUTPUT 2>&1
sudo dnf upgrade --allowerasing --assumeyes --best --quiet --refresh >$NO_OUTPUT 2>&1

dnf_package_install \
    htop \
    neofetch

log_success "Performing a full system upgrade"

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
flatpak override --user --filesystem=xdg-config/gtk-4.0

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
    sane-backends-libs \
    sane-backends-libs.i686

# The 'fwupdmgr' command exits with '1' (as failure) when no update is needed
sudo fwupdmgr --assume-yes --force refresh >$NO_OUTPUT 2>&1 || true
sudo fwupdmgr --assume-yes --force get-updates >$NO_OUTPUT 2>&1 || true

log_success "Updating system drivers"

# ################################################################
# REBOOT
# ################################################################

echo -e "\n[ ${ECHO_BOLD}OK${ECHO_RESET} ]"

ask_reboot
