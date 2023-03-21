#!/bin/bash

source common.sh

# ################################################################
# Main
# ################################################################

trap 'handle_errors $LINENO "$BASH_COMMAND"' ERR
sudo echo -e "[ Fedora Workstation Installation Script ]\n"

# ----------------------------------------------------------------

# Installing Nvidia driver prerequisites
log_step "Installing Nvidia driver prerequisites"

dnf_package_install \
    acpid \
    akmods \
    dkms \
    gcc \
    kernel-devel \
    kernel-headers \
    libglvnd-devel \
    libglvnd-glx \
    libglvnd-opengl \
    make \
    mokutil \
    openssl \
    pkgconfig

# ----------------------------------------------------------------

# Enabling Nvidia kernel module auto-signing
log_step "Enabling Nvidia kernel module auto-signing"

sudo kmodgenca --auto
sudo mokutil --import /etc/pki/akmods/certs/public_key.der

# ----------------------------------------------------------------

# Installing Nvidia driver and libraries
log_step "Installing Nvidia driver and libraries"

sudo dnf config-manager --set-enable rpmfusion-nonfree-nvidia-driver >$OUTPUT_EMPTY 2>&1

dnf_package_install \
    akmod-nvidia \
    libva \
    libva-utils \
    libvdpau-va-gl \
    nvidia-vaapi-driver \
    vdpauinfo \
    vulkan \
    vulkan-loader \
    vulkan-tools \
    xorg-x11-drv-nvidia \
    xorg-x11-drv-nvidia-cuda \
    xorg-x11-drv-nvidia-cuda-libs \
    xorg-x11-drv-nvidia-libs

sudo grubby --update-kernel=ALL --args='nvidia-drm.modeset=1' >$OUTPUT_EMPTY 2>&1

echo "blacklist nouveau" | sudo tee /etc/modprobe.d/blacklist.conf >$OUTPUT_EMPTY 2>&1
echo "options nvidia_drm modeset=1" | sudo tee /etc/modprobe.d/nvidia.conf >$OUTPUT_EMPTY 2>&1

sudo tee /etc/dracut.conf.d/nvidia.conf >$OUTPUT_EMPTY 2>&1 <<EOT
add_drivers+=" nvidia nvidia_modeset nvidia_uvm nvidia_drm "
install_items+=" /etc/modprobe.d/nvidia.conf "
EOT

sudo dracut --force --parallel --regenerate-all >$OUTPUT_EMPTY 2>&1

# ################################################################
# End
# ################################################################

log_success
ask_reboot
