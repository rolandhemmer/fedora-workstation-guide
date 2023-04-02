#!/bin/bash

source common.sh

# ################################################################
# Main
# ################################################################

trap 'handle_errors $LINENO "$BASH_COMMAND"' ERR
sudo echo -e "[ Fedora Workstation Installation Script ]\n"

# ----------------------------------------------------------------

# Enabling Nvidia kernel module auto-signing
log_step "Enabling Nvidia kernel module auto-signing"

dnf_package_install \
    akmods \
    kmodtool \
    mokutil \
    openssl

sudo kmodgenca --auto
sudo mokutil --import /etc/pki/akmods/certs/public_key.der

# ----------------------------------------------------------------

# Installing Nvidia driver and libraries
log_step "Installing Nvidia driver and libraries"

sudo dnf config-manager --set-enable rpmfusion-nonfree-nvidia-driver >$OUTPUT_EMPTY 2>&1

dnf_package_remove *nvidia*

dnf_package_install \
    akmod-nvidia \
    xorg-x11-drv-nvidia \
    xorg-x11-drv-nvidia-cuda \
    xorg-x11-drv-nvidia-cuda-libs \
    xorg-x11-drv-nvidia-libs

dnf_package_install \
    libva \
    libva-utils \
    libva-vdpau-driver \
    libvdpau-va-gl \
    nvidia-vaapi-driver \
    vdpauinfo

sudo grubby --update-kernel=ALL --args='nvidia-drm.modeset=1'

sudo akmods --force >$OUTPUT_EMPTY 2>&1
sudo dracut --force >$OUTPUT_EMPTY 2>&1

# ################################################################
# End
# ################################################################

log_success
ask_reboot
