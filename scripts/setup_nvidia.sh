#!/bin/bash

source __common__.sh

# --------------------------------
# Functions
# --------------------------------

00_install_nvidia_drivers() {
    __log_title__ "\n==> Installing latest Nvidia drivers"

    # ################################################################
    # Installing prerequisites
    # ################################################################

    __log_progress__ "Installing prerequisites"

    __install_dnf__ \
        akmods \
        acpid \
        curl \
        dkms \
        gcc \
        git \
        kernel-devel \
        kernel-headers \
        libglvnd-glx \
        libglvnd-opengl \
        libglvnd-devel \
        make \
        mokutil \
        openssl \
        pkgconfig \
        vim \
        wget

    __log_success__ "Installing prerequisites"

    # ################################################################
    # Enabling Nvidia kernel module auto-signing
    # ################################################################

    __log_progress__ "Enabling Nvidia kernel module auto-signing"

    sudo kmodgenca --auto
    sudo mokutil --import /etc/pki/akmods/certs/public_key.der

    __log_success_alt__ "Enabling Nvidia kernel module auto-signing"

    # ################################################################
    # Installing latest Nvidia drivers
    # ################################################################

    __log_progress__ "Installing latest Nvidia drivers"

    sudo dnf config-manager --set-enable rpmfusion-nonfree-nvidia-driver >$NO_OUTPUT 2>&1

    __install_dnf__ \
        akmod-nvidia \
        libva-utils \
        libva-vdpau-driver \
        vdpauinfo \
        xorg-x11-drv-nvidia \
        xorg-x11-drv-nvidia-cuda \
        xorg-x11-drv-nvidia-cuda-libs \
        xorg-x11-drv-nvidia-libs \
        xorg-x11-drv-nvidia-libs.i686 \
        vulkan-loader \
        vulkan-loader.i686

    echo "%global _with_kmod_nvidia_open 1" | sudo tee /etc/rpm/macros-nvidia-kmod >$NO_OUTPUT 2>&1
    sudo akmods --force >$NO_OUTPUT 2>&1
    sudo grubby --update-kernel=ALL --args='nvidia-drm.modeset=1' >$NO_OUTPUT 2>&1

    echo "options nvidia_drm modeset=1" | sudo tee /etc/modprobe.d/nvidia.conf >$NO_OUTPUT 2>&1
    echo "blacklist nouveau" | sudo tee /etc/modprobe.d/blacklist.conf >$NO_OUTPUT 2>&1

    sudo tee /etc/dracut.conf.d/nvidia.conf >$NO_OUTPUT 2>&1 <<EOT
add_drivers+=" nvidia nvidia_modeset nvidia_uvm nvidia_drm "
install_items+=" /etc/modprobe.d/nvidia.conf "
EOT

    sudo dracut --force

    __log_success__ "Installing latest Nvidia drivers"

# --------------------------------
# Main
# --------------------------------

set -e
sudo echo ""

cat <<"EOT"
    ________________  ____  ____  ___       _____ ______________  ______
   / ____/ ____/ __ \/ __ \/ __ \/   |     / ___// ____/_  __/ / / / __ \
  / /_  / __/ / / / / / / / /_/ / /| |     \__ \/ __/   / / / / / / /_/ /
 / __/ / /___/ /_/ / /_/ / _, _/ ___ |    ___/ / /___  / / / /_/ / ____/
/_/   /_____/_____/\____/_/ |_/_/  |_|   /____/_____/ /_/  \____/_/

EOT

00_install_nvidia_drivers

echo -e "\n[ ${ECHO_BOLD}OK${ECHO_RESET} ]"
