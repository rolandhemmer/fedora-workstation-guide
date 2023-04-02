#!/bin/bash

source common.sh

# ################################################################
# Main
# ################################################################

trap 'handle_errors $LINENO "$BASH_COMMAND"' ERR
sudo echo -e "[ Fedora Workstation Installation Script ]\n"

# ----------------------------------------------------------------

# Installing Bleachbit
log_step "Installing Bleachbit"
dnf_package_install bleachbit

# ----------------------------------------------------------------

# Installing Bottles
log_step "Installing Bottles"
flatpak_install com.usebottles.bottles

# ----------------------------------------------------------------

# Installing Clapper
log_step "Installing Clapper"
flatpak_install com.github.rafostar.Clapper

# ----------------------------------------------------------------

# Installing Discord
log_step "Installing Discord"
flatpak_install com.discordapp.Discord

# ----------------------------------------------------------------

# Installing Fedora Media Writer
log_step "Installing Fedora Media Writer"

dnf_package_remove liveusb-creator
flatpak_install org.fedoraproject.MediaWriter

# ----------------------------------------------------------------

# Installing Flatseal
log_step "Installing Flatseal"
flatpak_install com.github.tchx84.Flatseal

# ----------------------------------------------------------------

# Installing ONLYOFFICE
log_step "Installing ONLYOFFICE"
flatpak_install org.onlyoffice.desktopeditors

# ----------------------------------------------------------------

# Installing Steam and Proton tools
log_step "Installing Steam and Proton tools"

dnf_package_install \
    vulkan \
    vulkan-loader \
    vulkan-tools

flatpak_install \
    com.github.Matoking.protontricks \
    com.valvesoftware.Steam \
    net.davidotek.pupgui2

# ----------------------------------------------------------------

# Installing Visual Studio Code
log_step "Installing Visual Studio Code"

sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc >$OUTPUT_EMPTY 2>&1

sudo tee /etc/yum.repos.d/vscode.repo >$OUTPUT_EMPTY 2>&1 <<EOT
[code]
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
name=Visual Studio Code
EOT

sudo dnf check-update --assumeyes --quiet >$OUTPUT_EMPTY 2>&1
dnf_package_install code

# ----------------------------------------------------------------

# Removing unneeded applications
log_step "Removing unneeded applications"

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

# ################################################################
# End
# ################################################################

log_success
