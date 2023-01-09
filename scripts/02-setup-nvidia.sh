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

log_title "\n==> Installing latest Nvidia drivers"

# ----------------------------------------------------------------
# Installing prerequisites
# ----------------------------------------------------------------

log_progress "Installing prerequisites"

dnf_package_install \
    acpid \
    akmods \
    curl \
    dkms \
    gcc \
    git \
    kernel-devel \
    kernel-headers \
    libglvnd-devel \
    libglvnd-glx \
    libglvnd-opengl \
    make \
    mokutil \
    openssl \
    pkgconfig \
    vim \
    wget

log_success "Installing prerequisites"

# ----------------------------------------------------------------
# Enabling kernel module auto-signing
# ----------------------------------------------------------------

log_progress "Enabling kernel module auto-signing"

sudo kmodgenca --auto
sudo mokutil --import /etc/pki/akmods/certs/public_key.der

log_success_alt "Enabling kernel module auto-signing"

# ----------------------------------------------------------------
# Installing drivers
# ----------------------------------------------------------------

log_progress "Installing drivers"

sudo dnf config-manager --set-enable rpmfusion-nonfree-nvidia-driver >$NO_OUTPUT 2>&1

dnf_package_install \
    akmod-nvidia \
    libva-vdpau-driver \
    vdpauinfo \
    vulkan \
    vulkan-loader \
    vulkan-loader.i686 \
    vulkan-tools \
    xorg-x11-drv-nvidia \
    xorg-x11-drv-nvidia-cuda \
    xorg-x11-drv-nvidia-cuda-libs \
    xorg-x11-drv-nvidia-cuda-libs.i686 \
    xorg-x11-drv-nvidia-libs \
    xorg-x11-drv-nvidia-libs.i686 \
    xorg-x11-drv-nvidia-power

sudo systemctl enable nvidia-{suspend,resume,hibernate} >$NO_OUTPUT 2>&1

sudo grubby --update-kernel=ALL --args='nvidia-drm.modeset=1' >$NO_OUTPUT 2>&1

echo "options nvidia_drm modeset=1" | sudo tee /etc/modprobe.d/nvidia.conf >$NO_OUTPUT 2>&1
echo "blacklist nouveau" | sudo tee /etc/modprobe.d/blacklist.conf >$NO_OUTPUT 2>&1

sudo tee /etc/dracut.conf.d/nvidia.conf >$NO_OUTPUT 2>&1 <<EOT
add_drivers+=" nvidia nvidia_modeset nvidia_uvm nvidia_drm "
install_items+=" /etc/modprobe.d/nvidia.conf "
EOT

sudo dracut --force --parallel --regenerate-all >$NO_OUTPUT 2>&1

log_success "Installing drivers"

# ################################################################
# REBOOT
# ################################################################

echo -e "\n[ ${ECHO_BOLD}OK${ECHO_RESET} ]"

ask_reboot