#!/bin/bash

# ################################################################
# FUNCTIONS
# ################################################################

export ECHO_BOLD="\033[1m"
export ECHO_GREEN="\033[1;32m"
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

dnf_group_install() {
    sudo dnf group install --allowerasing --assumeyes --best --quiet $@ >$NO_OUTPUT 2>&1
}

dnf_package_install() {
    sudo dnf install --allowerasing --assumeyes --best --quiet $@ >$NO_OUTPUT 2>&1
}

dnf_package_remove() {
    sudo dnf remove --assumeyes --quiet $@ >$NO_OUTPUT 2>&1
}

flatpak_install() {
    flatpak install --assumeyes --user flathub $@ >$NO_OUTPUT 2>&1
}

log_progress() {
    echo -e "[ .. ]\t$1"
}

log_success() {
    echo -e "${ECHO_REPLACE}[ ${ECHO_GREEN}OK${ECHO_RESET} ]\t$1"
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

log_title "\n==> Installing applications"

# ----------------------------------------------------------------
# Installing Bleachbit
# ----------------------------------------------------------------

log_progress "Installing Bleachbit"
flatpak_install org.bleachbit.BleachBit
log_success "Installing Bleachbit"

# ----------------------------------------------------------------
# Installing Clapper
# ----------------------------------------------------------------

log_progress "Installing Clapper"
flatpak_install com.github.rafostar.Clapper
log_success "Installing Clapper"

# ----------------------------------------------------------------
# Installing Discord
# ----------------------------------------------------------------

log_progress "Installing Discord"
flatpak_install com.discordapp.Discord
log_success "Installing Discord"

# ----------------------------------------------------------------
# Installing Fedora Media Writer
# ----------------------------------------------------------------

log_progress "Installing Fedora Media Writer"

dnf_package_remove liveusb-creator
flatpak_install org.fedoraproject.MediaWriter

log_success "Installing Fedora Media Writer"

# ----------------------------------------------------------------
# Installing Flatseal
# ----------------------------------------------------------------

log_progress "Installing Flatseal"
flatpak_install com.github.tchx84.Flatseal
log_success "Installing Flatseal"

# ----------------------------------------------------------------
# Installing Lutris
# ----------------------------------------------------------------

log_progress "Installing Lutris"
flatpak_install net.lutris.Lutris
log_success "Installing Lutris"

# ----------------------------------------------------------------
# Installing Mozilla Firefox
# ----------------------------------------------------------------

log_progress "Installing Mozilla Firefox"

# If you experience hardware acceleration issues, or want better system integration (like password managers), consider keeping the RPM version, and comment this block.

# 'killall' fails is there is no process of that name
sudo killall firefox >$NO_OUTPUT 2>&1 || true

dnf_package_remove firefox
rm --force --recursive ~/.mozilla

flatpak_install org.mozilla.firefox

log_success "Installing Mozilla Firefox"

# ----------------------------------------------------------------
# Installing ONLYOFFICE
# ----------------------------------------------------------------

log_progress "Installing ONLYOFFICE"
flatpak_install org.onlyoffice.desktopeditors
log_success "Installing ONLYOFFICE"

# ----------------------------------------------------------------
# Installing Steam
# ----------------------------------------------------------------

log_progress "Installing Steam"
flatpak_install com.valvesoftware.Steam
log_success "Installing Steam"

# ----------------------------------------------------------------
# Installing Visual Studio Codium
# ----------------------------------------------------------------

log_progress "Installing Visual Studio Codium"

# Codium (or VSCodium) is the full open-source variant of Microsoft's Visual Studio Code.
# https://vscodium.com/
#
# If you want to use the embedded terminal inside of VS, prefer the RPM installation:
#
# > sudo rpmkeys --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
# > printf "[gitlab.com_paulcarroty_vscodium_repo]\nname=download.vscodium.com\nbaseurl=https://download.vscodium.com/rpms/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg\nmetadata_expire=1h" | sudo tee --append /etc/yum.repos.d/vscodium.repo
# > sudo dnf install --assumeyes codium

flatpak_install com.vscodium.codium

log_success "Installing Visual Studio Codium"

# ----------------------------------------------------------------
# Removing unneeded applications
# ----------------------------------------------------------------

log_progress "Removing unneeded applications"

dnf_package_remove \
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
    gnome-photos \
    gnome-text-editor \
    gnome-tour \
    gnome-weather \
    rhythmbox \
    totem \
    yelp

log_success "Removing unneeded applications"

# ################################################################
# DONE
# ################################################################

echo -e "\n[ ${ECHO_BOLD}OK${ECHO_RESET} ]"
