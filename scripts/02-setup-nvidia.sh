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

log_success_alt() {
    echo -e "[ ${ECHO_GREEN}OK${ECHO_RESET} ]\t$1"
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

dnf_package_install() {
    sudo dnf install --assumeyes --quiet $@ >$NO_OUTPUT
}

dnf_package_remove() {
    sudo dnf remove --assumeyes --quiet $@ >$NO_OUTPUT
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

sudo dnf config-manager --set-enable rpmfusion-nonfree-nvidia-driver >$NO_OUTPUT

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
    xorg-x11-drv-nvidia-libs \
    xorg-x11-drv-nvidia-power

sudo systemctl enable nvidia-{suspend,resume,hibernate} >$NO_OUTPUT

sudo grubby --update-kernel=ALL --args='nvidia-drm.modeset=1' >$NO_OUTPUT

echo "blacklist nouveau" | sudo tee /etc/modprobe.d/blacklist.conf >$NO_OUTPUT
echo "options nvidia_drm modeset=1" | sudo tee /etc/modprobe.d/nvidia.conf >$NO_OUTPUT

sudo tee /etc/dracut.conf.d/nvidia.conf >$NO_OUTPUT <<EOT
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
